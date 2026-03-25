package com.lbms.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.dao.RenewalRequestDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.RenewalRequest;
import com.lbms.model.ShippingDetails;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

public class BorrowService {

    private static final Logger logger = Logger.getLogger(BorrowService.class.getName());

    public static final int MAX_ACTIVE_BORROWS = 5;
    public static final int LOAN_DAYS = 14;
    public static final BigDecimal FINE_PER_DAY = new BigDecimal("5000");

    private final BorrowDAO borrowDAO;
    private final BookDAO bookDAO;
    private final RenewalRequestDAO renewalRequestDAO;
    private final UserDAO userDAO;
    private final ReservationService reservationService; // ← THÊM MỚI
    private final WalletService walletService;
    private final NotificationService notificationService;

    public BorrowService() {
        this.borrowDAO = new BorrowDAO();
        this.bookDAO = new BookDAO();
        this.renewalRequestDAO = new RenewalRequestDAO();
        this.userDAO = new UserDAO();
        this.reservationService = new ReservationService(); // ← THÊM MỚI
        this.walletService = new WalletService();
        this.notificationService = new NotificationService();
    }

    // ═══════════════════════════════════════════════════════════════
    // TRẢ SÁCH – UC-RES-02 Basic Flow
    // Sau khi trả thành công → gọi onBookReturned() để xử lý queue
    // ═══════════════════════════════════════════════════════════════
    public BigDecimal returnBook(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);

        if (br == null) {
            throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        }
        if (!"BORROWED".equalsIgnoreCase(br.getStatus())
                && !"APPROVED".equalsIgnoreCase(br.getStatus())
                && !"RECEIVED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể trả khi sách đang mượn");
        }

        LocalDate today = LocalDate.now();
        BigDecimal fine = calculateFine(br.getDueDate(), today);
        long bookId = br.getBook().getId(); // lưu lại trước khi xử lý

        // ── Bước 1-6 UC-RES-02: Cập nhật trạng thái trả sách ────────────
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // Tăng quantity của sách (availability là computed column, tự tính lại)
                try (var ps = c.prepareStatement(
                        "UPDATE Book SET quantity = quantity + 1 WHERE book_id = ?")) {
                    ps.setLong(1, bookId);
                    ps.executeUpdate();
                }

                // Cập nhật borrow_record → RETURNED
                try (var ps = c.prepareStatement(
                        "UPDATE borrow_records "
                        + "SET status = 'RETURNED', return_date = ?, fine_amount = ?, is_paid = 0 "
                        + "WHERE id = ?")) {
                    ps.setDate(1, java.sql.Date.valueOf(today));
                    ps.setBigDecimal(2, fine);
                    ps.setLong(3, borrowId);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception ex) {
                c.rollback();
                if (ex instanceof SQLException) {
                    throw (SQLException) ex;
                }
                if (ex instanceof RuntimeException) {
                    throw (RuntimeException) ex;
                }
                throw new RuntimeException(ex);
            } finally {
                c.setAutoCommit(true);
            }
        }
        // ── Hoàn 50% tiền cọc vào ví người mượn ───────────────────────────────
        BigDecimal deposit = br.getDepositAmount();
        if (deposit != null && deposit.compareTo(BigDecimal.ZERO) > 0) {
            BigDecimal depositRefund = deposit.multiply(new BigDecimal("0.5"));

            try {
                walletService.creditWallet(br.getUser().getId(), depositRefund, "DEPOSIT_REFUND",
                        "Hoàn 50% tiền cọc phiếu #" + borrowId, "DEPOSIT-REFUND-" + borrowId);
                notificationService.notifyDepositRefunded(
                        br.getUser().getId(),
                        br.getBook().getTitle(),
                        depositRefund,
                        "Hệ thống đã hoàn lại 50% tiền cọc"
                );

            } catch (Exception e) {
                logger.log(Level.WARNING,
                        "[BorrowService] Lỗi hoàn tiền cọc borrowId=" + borrowId, e);
            }
        }
        // ── Bước 7-10 UC-RES-02: Kiểm tra & xử lý reservation queue ─────
        // Gọi NGOÀI transaction để tránh deadlock
        // Nếu lỗi reservation → chỉ log, không làm hỏng luồng trả sách
        try {
            reservationService.onBookReturned(bookId);
        } catch (Exception e) {
            logger.log(Level.WARNING,
                    "[BorrowService] Lỗi khi xử lý reservation sau khi trả sách bookId=" + bookId, e);
        }

        return fine;
    }

    public long requestBorrow(long userId, long bookId, String method, ShippingDetails shippingDetails)
            throws SQLException {
        return requestBorrow(userId, bookId, 1, method, shippingDetails);
    }

    public long requestBorrow(long userId, long bookId, int quantity, String method,
            ShippingDetails shippingDetails) throws SQLException {

        String groupCode = "REQ-" + System.currentTimeMillis() + "CCCCCCCC";

        // Gọi hàm chính (có depositAmount), truyền null để tự tính bên trong
        List<Long> ids = requestBorrowCopies(userId, bookId, method, shippingDetails,
                quantity, groupCode, null);

        return ids.isEmpty() ? 0 : ids.get(0);
    }

    /**
     * Yêu cầu mượn nhiều sách từ giỏ hàng (Online Cart) TẤT CẢ sách trong cùng
     * một đơn thanh toán sẽ có CHUNG groupCode
     */
    public List<Long> requestBorrowCopies(long userId, long bookId, String method,
            ShippingDetails shippingDetails, int quantity, String groupCode,
            BigDecimal depositAmount) throws SQLException {

        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0");
        }

        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new IllegalArgumentException("Sách không tồn tại");
        }
        if (book.getQuantity() < quantity) {
            throw new IllegalArgumentException("Sách chỉ còn " + book.getQuantity() + " cuốn");
        }

        int active = borrowDAO.countActiveBorrows(userId);
        if (active + quantity > MAX_ACTIVE_BORROWS) {
            throw new IllegalArgumentException("Vượt quá giới hạn mượn (Tối đa " + MAX_ACTIVE_BORROWS + " cuốn)");
        }

        // [XỬ LÝ CHÍNH XÁC GROUP CODE]: Chỉ tạo mới nếu Controller không truyền vào
        String finalCode = (groupCode != null && !groupCode.trim().isEmpty())
                ? groupCode
                : "REQ-" + System.currentTimeMillis() + "QUYNN";

        shippingDetails = fillInPersonShipping(userId, method, shippingDetails);

        List<Long> createdIds = new ArrayList<>();
        // Tách mỗi cuốn thành 1 bản ghi riêng biệt nhưng dùng chung finalCode
        for (int i = 0; i < quantity; i++) {
            long newId = borrowDAO.createRequest(
                    userId,
                    bookId,
                    1,
                    method,
                    shippingDetails,
                    finalCode,
                    (depositAmount != null ? depositAmount : BigDecimal.ZERO)
            );
            createdIds.add(newId);
        }
        return createdIds;
    }

//    public List<Long> requestBorrowCopies(long userId, long bookId, String method,
//            ShippingDetails shippingDetails, int quantity, String groupCode) throws SQLException {
//        if (quantity <= 0) {
//            throw new IllegalArgumentException("Số lượng mượn phải lớn hơn 0");
//        }
//
//        Book book = bookDAO.findById(bookId);
//        if (book == null) {
//            throw new IllegalArgumentException("Sách không tồn tại");
//        }
//        if (book.getQuantity() <= 0) {
//            throw new IllegalArgumentException("Sách đã hết");
//        }
//        if (quantity > book.getQuantity()) {
//            throw new IllegalArgumentException("Không thể mượn nhiều hơn số lượng đang có");
//        }
//
//        int active = borrowDAO.countActiveBorrows(userId);
//        if (active + quantity > MAX_ACTIVE_BORROWS) {
//            throw new IllegalArgumentException(
//                    "Bạn chỉ có thể mượn tối đa " + MAX_ACTIVE_BORROWS
//                    + " cuốn cùng lúc (bao gồm đang chờ duyệt)");
//        }
//
//        shippingDetails = fillInPersonShipping(userId, method, shippingDetails);
//
//        BigDecimal price = book.getPrice() != null
//                ? BigDecimal.valueOf(book.getPrice())
//                : BigDecimal.ZERO;
//        BigDecimal depositAmount = price.multiply(BigDecimal.valueOf(0.5));
//
//        List<Long> ids = new ArrayList<>(quantity);
//        for (int i = 0; i < quantity; i++) {
//            ids.add(borrowDAO.createRequest(userId, bookId, 1, method,
//                    shippingDetails, groupCode, depositAmount));
//        }
//        return ids;
//    }
    public int countActiveBorrows(long userId) throws SQLException {
        return borrowDAO.countActiveBorrows(userId);
    }

    public void approve(long borrowId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                long copyId = -1;
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT copy_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'")) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getLong("copy_id");
                        } else {
                            throw new IllegalArgumentException("Mã vạch không hợp lệ hoặc sách đã được mượn!");
                        }
                    }
                }

                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                    ps.setLong(1, copyId);
                    ps.executeUpdate();
                }

                LocalDate today = LocalDate.now();
                LocalDate dueDate = today.plusDays(LOAN_DAYS);
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE borrow_records SET status='BORROWED', borrow_date=?, due_date=?, copy_id=? WHERE id=?")) {
                    ps.setDate(1, Date.valueOf(today));
                    ps.setDate(2, Date.valueOf(dueDate));
                    ps.setLong(3, copyId);
                    ps.setLong(4, borrowId);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public List<BorrowRecord> getOverdueList() throws SQLException {
        return borrowDAO.listOverdue();
    }

    public void reject(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) {
            throw new IllegalArgumentException("Yêu cầu không tồn tại");
        }
        if (!"REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ để từ chối");
        }
        borrowDAO.updateStatus(borrowId, "REJECTED");
    }

    public void cancelRenewalRequest(long userId, long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) {
            throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        }
        if (br.getUser() == null || br.getUser().getId() != userId) {
            throw new IllegalArgumentException("Bạn không có quyền hủy yêu cầu này");
        }
        if (!"RENEWAL_REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể hủy khi đang chờ duyệt gia hạn");
        }
        if (!renewalRequestDAO.existsPendingForBorrow(borrowId)) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu gia hạn đang xử lý");
        }

        renewalRequestDAO.cancelPendingForBorrow(borrowId);
        borrowDAO.updateStatus(borrowId, "BORROWED");
    }

    public void cancelRequest(long borrowId, long userId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) {
            throw new IllegalArgumentException("Yêu cầu không tồn tại");
        }
        if (br.getUser().getId() != userId) {
            throw new IllegalArgumentException("Bạn không có quyền hủy yêu cầu này");
        }
        if (!"REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể hủy yêu cầu khi đang chờ duyệt");
        }
        borrowDAO.updateStatus(borrowId, "CANCELLED");
    }

    public long requestRenewal(long userId, long borrowId, String reason,
            String contactName, String contactPhone, String contactEmail) throws SQLException {
        String cleanReason = reason != null ? reason.trim() : "";
        if (cleanReason.isBlank()) {
            throw new IllegalArgumentException("Vui lòng mô tả lý do gia hạn");
        }

        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) {
            throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        }
        if (br.getUser() == null || br.getUser().getId() != userId) {
            throw new IllegalArgumentException("Bạn không có quyền gửi yêu cầu này");
        }
        if (!"BORROWED".equalsIgnoreCase(br.getStatus())
                && !"APPROVED".equalsIgnoreCase(br.getStatus())
                && !"RECEIVED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể gia hạn khi sách đang mượn");
        }
        if (renewalRequestDAO.existsPendingForBorrow(borrowId)) {
            throw new IllegalArgumentException("Bạn đã gửi yêu cầu gia hạn trước đó, vui lòng chờ duyệt");
        }

        String finalName = notBlank(contactName, br.getUser().getFullName());
        String finalPhone = notBlank(contactPhone, br.getUser().getPhone());
        String finalEmail = notBlank(contactEmail, br.getUser().getEmail());

        borrowDAO.updateStatus(borrowId, "RENEWAL_REQUESTED");
        return renewalRequestDAO.createRequest(borrowId, userId, cleanReason,
                finalName, finalPhone, finalEmail);
    }

    public List<RenewalRequest> getRenewalRequestsForBorrow(long borrowId) throws SQLException {
        return renewalRequestDAO.listByBorrowId(borrowId);
    }

    public BigDecimal calculateFine(LocalDate dueDate, LocalDate returnDate) {
        if (dueDate == null || returnDate == null) {
            return BigDecimal.ZERO;
        }
        long lateDays = ChronoUnit.DAYS.between(dueDate, returnDate);
        return lateDays <= 0 ? BigDecimal.ZERO
                : FINE_PER_DAY.multiply(BigDecimal.valueOf(lateDays));
    }

    public void markFinePaid(long borrowId) throws SQLException {
        borrowDAO.markFinePaid(borrowId);
    }

    public void borrowInPerson(long userId, long bookId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                long copyId = -1;
                try (PreparedStatement ps = c.prepareStatement(
                        "SELECT copy_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'")) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getLong("copy_id");
                        } else {
                            throw new IllegalArgumentException("Mã vạch không hợp lệ hoặc sách đã được mượn!");
                        }
                    }
                }

                LocalDate today = LocalDate.now();
                LocalDate dueDate = today.plusDays(LOAN_DAYS);
                try (PreparedStatement ps = c.prepareStatement(
                        "INSERT INTO borrow_records(user_id, book_id, borrow_date, due_date, status, borrow_method, copy_id) "
                        + "VALUES(?, ?, ?, ?, 'BORROWED', 'IN_PERSON', ?)")) {
                    ps.setLong(1, userId);
                    ps.setLong(2, bookId);
                    ps.setDate(3, java.sql.Date.valueOf(today));
                    ps.setDate(4, java.sql.Date.valueOf(dueDate));
                    ps.setLong(5, copyId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                    ps.setLong(1, copyId);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    // ── Private helpers ───────────────────────────────────────────
    private ShippingDetails fillInPersonShipping(long userId, String method,
            ShippingDetails shippingDetails) throws SQLException {
        if ("IN_PERSON".equalsIgnoreCase(method) && shippingDetails == null) {
            User currentUser = userDAO.findById(userId);
            if (currentUser != null) {
                ShippingDetails sd = new ShippingDetails();
                sd.setRecipient(currentUser.getFullName());
                sd.setPhone(currentUser.getPhone());
                String addr = currentUser.getAddress();
                sd.setStreet((addr != null && !addr.isBlank()) ? addr : "Nhận tại quầy");
                sd.setCity("");
                sd.setDistrict("");
                sd.setWard("");
                return sd;
            }
        }
        return shippingDetails;
    }

    private static String notBlank(String value, String fallback) {
        return (value != null && !value.isBlank()) ? value.trim()
                : (fallback != null ? fallback : "");
    }
}
