package com.lbms.service;

import com.lbms.dao.LibrarianBorrowDAO;
import com.lbms.dao.RenewalRequestDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.RenewalRequest;
import com.lbms.model.Reservation;
import com.lbms.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import com.lbms.dao.LibrarianActivityLogDAO;

public class LibrarianBorrowService {

    private final LibrarianBorrowDAO libDAO = new LibrarianBorrowDAO();
    private final LibrarianActivityLogDAO logDAO = new LibrarianActivityLogDAO();
    private final RenewalRequestDAO renewalRequestDAO = new RenewalRequestDAO();
    private final ReservationService reservationService = new ReservationService();
    private final WalletService walletService = new WalletService();
    private final NotificationService notificationService = new NotificationService();
    public static final BigDecimal FIXED_SHIPPING_FEE = new BigDecimal("30000"); // 30k tiền ship
    public static final BigDecimal RETENTION_RATE = new BigDecimal("0.25");    // Giữ lại 25% cọc

//    public BigDecimal[] returnBook(long borrowId, String inputBarcode) throws SQLException {
//        if (inputBarcode == null || inputBarcode.trim().isEmpty()) {
//            throw new IllegalArgumentException("Vui lòng quét hoặc nhập mã vạch sách.");
//        }
//
//        // Chuẩn hóa đầu vào: bỏ khoảng trắng thừa
//        String cleanInput = inputBarcode.trim();
//
//        try (Connection c = DBConnection.getConnection()) {
//            c.setAutoCommit(false);
//            try {
//                // 1. Lấy thông tin đối chiếu (Sử dụng TRIM trong SQL để loại bỏ khoảng trắng ẩn
//                // trong DB)
//                // String sqlCheck = "SELECT LTRIM(RTRIM(bc.barcode)) as barcode, br.book_id,
//                // br.status, br.due_date "
//                // + "FROM borrow_records br "
//                // + "JOIN BookCopy bc ON br.copy_id = bc.copy_id "
//                // + "WHERE br.id = ?";
//
//                String sqlCheck = "SELECT br.status, br.due_date, br.copy_id, br.book_id, bc.barcode, "
//                        + "br.user_id, br.deposit_amount, b.title AS book_title,br.borrow_method "
//                        + "FROM borrow_records br "
//                        + "LEFT JOIN BookCopy bc ON br.copy_id = bc.copy_id "
//                        + "LEFT JOIN Book b ON br.book_id = b.book_id "
//                        + "WHERE br.id = ? AND br.status IN ('BORROWED', 'RECEIVED', 'RETURN_REQUESTED')";
//                String correctBarcode = "";
//                long bookId = -1;
//                LocalDate dueDate = null;
//                long borrowUserId = -1;
//                BigDecimal depositAmount = null;
//                String bookTitle = "";
//
//                try (PreparedStatement ps = c.prepareStatement(sqlCheck)) {
//                    ps.setLong(1, borrowId);
//                    try (ResultSet rs = ps.executeQuery()) {
//                        if (rs.next()) {
//                            correctBarcode = rs.getString("barcode");
//                            bookId = rs.getLong("book_id");
//                            java.sql.Date dueDateSql = rs.getDate("due_date");
//                            if (dueDateSql != null) {
//                                dueDate = dueDateSql.toLocalDate();
//                            }
//                            borrowUserId = rs.getLong("user_id");
//                            depositAmount = rs.getBigDecimal("deposit_amount");
//                            String borrowMethod = rs.getString("borrow_method");
//                            bookTitle = rs.getString("book_title");
//                            if (bookTitle == null)
//                                bookTitle = "";
//                        } else {
//                            throw new IllegalArgumentException(
//                                    "Lỗi: Phiếu mượn này chưa được gán mã vạch (copy_id bị NULL hoặc không tồn tại).");
//                        }
//                        
//                    }
//                }
//
//                // 2. So khớp Barcode (Sử dụng equalsIgnoreCase và hiển thị lỗi chi tiết nếu
//                // sai)
//                if (correctBarcode == null || !correctBarcode.equalsIgnoreCase(cleanInput)) {
//                    throw new IllegalArgumentException("Sai mã vạch! Phiếu này yêu cầu mã '" + correctBarcode
//                            + "', nhưng bạn lại quét mã '" + cleanInput + "'.");
//                }
//
//                // 3. Cập nhật trạng thái bản sao sách về khả dụng
//                String updateCopy = "UPDATE BookCopy SET status = 'AVAILABLE' WHERE copy_id = "
//                        + "(SELECT copy_id FROM borrow_records WHERE id = ?)";
//                try (PreparedStatement ps = c.prepareStatement(updateCopy)) {
//                    ps.setLong(1, borrowId);
//                    ps.executeUpdate();
//                }
//
//                // 4. Tăng số lượng đầu sách trong kho (Chỉ tăng nếu trạng thái cũ là đang
//                // mượn/giao)
//                String updateQty = "UPDATE Book SET quantity = quantity + 1 WHERE book_id = ?";
//                try (PreparedStatement ps = c.prepareStatement(updateQty)) {
//                    ps.setLong(1, bookId);
//                    ps.executeUpdate();
//                }
//
//                // 5. Cập nhật phiếu mượn thành công
//                String updateBr = "UPDATE borrow_records SET status='RETURNED', return_date=GETDATE() WHERE id=?";
//                try (PreparedStatement ps = c.prepareStatement(updateBr)) {
//                    ps.setLong(1, borrowId);
//                    ps.executeUpdate();
//                }
//
//                // 6. Tính tiền phạt nếu trễ hạn
//                LocalDate returnDate = LocalDate.now();
//                BigDecimal fineAmount = calculateFine(dueDate, returnDate);
//
//                c.commit();
//
//                // Hoàn tiền cọc vào ví người mượn
//                BigDecimal depositRefund = BigDecimal.ZERO;
//                if (depositAmount != null && depositAmount.compareTo(BigDecimal.ZERO) > 0 && borrowUserId > 0) {
    ////                    depositRefund = depositAmount.multiply(new BigDecimal("0.5"));
////                    try {
////                        walletService.creditWallet(borrowUserId, depositRefund, "DEPOSIT_REFUND",
////                                "Hoàn 50% tiền cọc phiếu #" + borrowId, "DEPOSIT-REFUND-" + borrowId);
////                        notificationService.notifyDepositRefunded(borrowUserId, bookTitle, depositRefund);
////                    } catch (Exception e) {
////                        System.err.println("[LibrarianBorrowService] Lỗi hoàn tiền cọc borrowId=" + borrowId
////                                + ": " + e.getMessage());
////                    }
//                        
//                }
//
//                // Gọi ngoài transaction để tránh deadlock
////                try {
////                    reservationService.onBookReturned(bookId);
////                } catch (Exception e) {
////                    // Chỉ log, không làm hỏng luồng trả sách
////                    System.err.println("[LibrarianBorrowService] Lỗi xử lý reservation sau trả sách bookId=" + bookId
////                            + ": " + e.getMessage());
////                }
//
//                  if ("ONLINE".equalsIgnoreCase(borrowMethod)) {
//                    // Mượn Online: Giữ lại 30k ship + 25% cọc
//                    BigDecimal shipFee = new BigDecimal("30000");
//                    BigDecimal retentionRate = new BigDecimal("0.25");
//                    BigDecimal retentionAmount = depositAmount.multiply(retentionRate).add(shipFee);
//                    depositRefund = depositAmount.subtract(retentionAmount);
//                } else {
//                    // Mượn tại chỗ (IN_PERSON): Hoàn 50% như cũ
//                    depositRefund = depositAmount.multiply(new BigDecimal("0.5"));
//                }
//
//                // Đảm bảo không hoàn số âm
//                if (depositRefund.compareTo(BigDecimal.ZERO) < 0) depositRefund = BigDecimal.ZERO;
//
//                try {
//                    String note = "ONLINE".equalsIgnoreCase(borrowMethod) 
//                        ? "Hoàn cọc phiếu #" + borrowId + " (Đã trừ 30k ship & 25% phí)"
//                        : "Hoàn 50% tiền cọc phiếu #" + borrowId;
//                    
//                    walletService.creditWallet(borrowUserId, depositRefund, "DEPOSIT_REFUND", note, "DEPOSIT-REFUND-" + borrowId);
//                    notificationService.notifyDepositRefunded(borrowUserId, bookTitle, depositRefund);
//                } catch (Exception e) {
//                    System.err.println("[LibrarianBorrowService] Lỗi hoàn tiền: " + e.getMessage());
//                }
//            }  
//
//
//                return new BigDecimal[] { fineAmount, depositRefund };
//            } catch (Exception e) {
//                c.rollback();
//                throw e;
//            }
//        }
    
            // Các hằng số nên được khai báo ở đầu lớp LibrarianBorrowService hoặc trong BorrowService


public BigDecimal[] returnBook(long borrowId, String inputBarcode) throws SQLException {
        if (inputBarcode == null || inputBarcode.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng quét hoặc nhập mã vạch sách.");
        }

        String cleanInput = inputBarcode.trim();

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Lấy thông tin đối chiếu, bao gồm cả borrow_method để phân loại phí
                String sqlCheck = "SELECT br.status, br.due_date, br.copy_id, br.book_id, bc.barcode, "
                        + "br.user_id, br.deposit_amount, b.title AS book_title, br.borrow_method "
                        + "FROM borrow_records br "
                        + "LEFT JOIN BookCopy bc ON br.copy_id = bc.copy_id "
                        + "LEFT JOIN Book b ON br.book_id = b.book_id "
                        + "WHERE br.id = ? AND br.status IN ('BORROWED', 'RECEIVED', 'RETURN_REQUESTED')";

                String correctBarcode = "";
                long bookId = -1;
                LocalDate dueDate = null;
                long borrowUserId = -1;
                BigDecimal depositAmount = null;
                String bookTitle = "";
                String borrowMethod = "";

                try (PreparedStatement ps = c.prepareStatement(sqlCheck)) {
                    ps.setLong(1, borrowId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            correctBarcode = rs.getString("barcode");
                            bookId = rs.getLong("book_id");
                            java.sql.Date dueDateSql = rs.getDate("due_date");
                            if (dueDateSql != null) {
                                dueDate = dueDateSql.toLocalDate();
                            }
                            borrowUserId = rs.getLong("user_id");
                            depositAmount = rs.getBigDecimal("deposit_amount");
                            bookTitle = rs.getString("book_title");
                            borrowMethod = rs.getString("borrow_method");
                            if (bookTitle == null) {
                                bookTitle = "";
                            }
                        } else {
                            throw new IllegalArgumentException("Lỗi: Phiếu mượn không hợp lệ hoặc không ở trạng thái có thể trả.");
                        }
                    }
                }

                // 2. So khớp Barcode
                if (correctBarcode == null || !correctBarcode.equalsIgnoreCase(cleanInput)) {
                    throw new IllegalArgumentException("Sai mã vạch! Phiếu này yêu cầu mã '" + correctBarcode
                            + "', nhưng bạn lại quét mã '" + cleanInput + "'.");
                }

                // 3. Cập nhật trạng thái bản sao sách về AVAILABLE
                String updateCopy = "UPDATE BookCopy SET status = 'AVAILABLE' WHERE copy_id = "
                        + "(SELECT copy_id FROM borrow_records WHERE id = ?)";
                try (PreparedStatement ps = c.prepareStatement(updateCopy)) {
                    ps.setLong(1, borrowId);
                    ps.executeUpdate();
                }

                // 4. Tăng số lượng đầu sách trong kho
                String updateQty = "UPDATE Book SET quantity = quantity + 1 WHERE book_id = ?";
                try (PreparedStatement ps = c.prepareStatement(updateQty)) {
                    ps.setLong(1, bookId);
                    ps.executeUpdate();
                }

                // 5. Cập nhật phiếu mượn thành công
                String updateBr = "UPDATE borrow_records SET status='RETURNED', return_date=GETDATE() WHERE id=?";
                try (PreparedStatement ps = c.prepareStatement(updateBr)) {
                    ps.setLong(1, borrowId);
                    ps.executeUpdate();
                }

                // 6. Tính tiền phạt nếu trễ hạn
                LocalDate returnDate = LocalDate.now();
                BigDecimal fineAmount = calculateFine(dueDate, returnDate);

                c.commit();

                // 7. Xử lý hoàn tiền cọc dựa trên borrow_method
                BigDecimal depositRefund = BigDecimal.ZERO;
                if (depositAmount != null && depositAmount.compareTo(BigDecimal.ZERO) > 0 && borrowUserId > 0) {
                    String note;
                    if ("ONLINE".equalsIgnoreCase(borrowMethod)) {
                        // Logic Online: Giữ lại 30k ship + 25% cọc
                        BigDecimal shipFee = new BigDecimal("30000");
                        BigDecimal retentionAmount = depositAmount.multiply(new BigDecimal("0.25")).add(shipFee);
                        depositRefund = depositAmount.subtract(retentionAmount);

                        note = "Hoàn tiền cọc sau khi trừ 30k ship và 25% phí vận hành";
                    } else {
                        // Logic Tại chỗ: Hoàn 50% cọc (như bạn đã thống nhất cho BorrowService)
                        depositRefund = depositAmount.multiply(new BigDecimal("0.5"));
                        note = "Hoàn lại 50% tiền cọc (mượn tại chỗ)";
                    }

                    if (depositRefund.compareTo(BigDecimal.ZERO) < 0) {
                        depositRefund = BigDecimal.ZERO;
                    }

                    try {
                        walletService.creditWallet(borrowUserId, depositRefund, "DEPOSIT_REFUND", note, "DEPOSIT-REFUND-" + borrowId);
                        notificationService.notifyDepositRefunded(borrowUserId, bookTitle, depositRefund, note);
                    } catch (Exception e) {
                        System.err.println("[LibrarianBorrowService] Lỗi hoàn tiền khi trả sách: " + e.getMessage());
                    }
                }

                return new BigDecimal[]{fineAmount, depositRefund};
            } catch (Exception e) {
                c.rollback();
                throw e;
            }
        }
    }

    public void approveRequest(long borrowId, String barcode, long staffId) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                String bookTitle = "N/A";
                String userName = "N/A";
                String sqlInfo = "SELECT b.title, u.full_name FROM borrow_records br "
                        + "JOIN Book b ON br.book_id = b.book_id "
                        + "JOIN [User] u ON br.user_id = u.user_id WHERE br.id = ?";
                try (PreparedStatement psInfo = c.prepareStatement(sqlInfo)) {
                    psInfo.setLong(1, borrowId);
                    try (ResultSet rs = psInfo.executeQuery()) {
                        if (rs.next()) {
                            bookTitle = rs.getString("title");
                            userName = rs.getString("full_name");
                        }
                    }
                }
                int copyId = -1;
                long bookIdFromCopy = -1;

                // 1. Kiểm tra mã vạch
                String checkCopy = "SELECT copy_id, book_id FROM BookCopy WHERE barcode = ? AND status = 'AVAILABLE'";
                try (PreparedStatement ps = c.prepareStatement(checkCopy)) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getInt("copy_id");
                            bookIdFromCopy = rs.getLong("book_id");
                        } else {
                            throw new IllegalArgumentException(
                                    "Mã vạch không hợp lệ, sách đã bị mượn hoặc không tồn tại.");
                        }
                    }
                }

                // 2. Kiểm tra đầu sách
                String checkBr = "SELECT book_id FROM borrow_records WHERE id = ?";
                try (PreparedStatement ps = c.prepareStatement(checkBr)) {
                    ps.setLong(1, borrowId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            if (rs.getLong("book_id") != bookIdFromCopy) {
                                throw new IllegalArgumentException(
                                        "Mã vạch này thuộc về đầu sách khác, không đúng với yêu cầu của độc giả.");
                            }
                        } else {
                            throw new IllegalArgumentException("Không tìm thấy phiếu yêu cầu mượn này.");
                        }
                    }
                }

                // 3. Cập nhật trạng thái bản sao sách (BookCopy) thành 'BORROWED' để giữ chỗ
                try (PreparedStatement ps = c
                        .prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                    ps.setInt(1, copyId);
                    ps.executeUpdate();
                }

                // 4. [ĐÃ SỬA LỖI TẠI ĐÂY] Cập nhật phiếu mượn: Chuyển sang APPROVED để UI hiện
                // nút GHTK hoặc Xác nhận lấy
                String updateBr = "UPDATE borrow_records SET status = 'APPROVED', copy_id = ? WHERE id = ?";
                try (PreparedStatement ps = c.prepareStatement(updateBr)) {
                    ps.setInt(1, copyId);
                    ps.setLong(2, borrowId);
                    ps.executeUpdate();
                }

                // 5. Trừ số lượng sách trong kho
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE Book SET quantity = quantity - 1 WHERE book_id = ? AND quantity > 0")) {
                    ps.setLong(1, bookIdFromCopy);
                    int rowsAffected = ps.executeUpdate();
                    if (rowsAffected == 0) {
                        throw new SQLException("Sách đã hết trong kho, không thể duyệt.");
                    }
                }

                // 6. Ghi log hoạt động
                logDAO.addActivityLog((int) staffId,
                        "Duyệt mượn: " + bookTitle + " - Độc giả: " + userName + " [ID:" + borrowId + "]");

                c.commit();
            } catch (Exception e) {
                c.rollback();
                throw e;
            }
        }
    }

    public void confirmReceive(long borrowId) throws SQLException {
        LocalDate borrowDate = LocalDate.now();
        LocalDate dueDate = borrowDate.plusDays(7);

        String sql = "UPDATE borrow_records SET status = 'RECEIVED', borrow_date = ?, due_date = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, java.sql.Date.valueOf(borrowDate));
            ps.setDate(2, java.sql.Date.valueOf(dueDate));
            ps.setLong(3, borrowId);
            ps.executeUpdate();
        }
    }

    public void rejectRequest(long borrowId, String reason, long staffId) throws SQLException {
        BorrowRecord record = libDAO.findById(borrowId);
        if (record == null) {
            throw new IllegalArgumentException("Không tìm thấy phiếu mượn.");
        }

        BigDecimal depositAmount = record.getDepositAmount();
        long userId = record.getUser().getId();
        String bookTitle = record.getBook().getTitle();

        // 1. Cập nhật trạng thái REJECTED (để lưu lý do từ chối)
        libDAO.rejectRequest(borrowId, reason);

        // 2. HOÀN TIỀN 100%: Nếu là đơn Online có đặt cọc thì trả lại ví
        if (depositAmount != null && depositAmount.compareTo(BigDecimal.ZERO) > 0) {
            try {
                String note = "Hoàn 100% tiền cọc do yêu cầu mượn bị từ chối: " + reason;
                // Nạp lại tiền vào ví khách hàng
                walletService.creditWallet(userId, depositAmount, "REJECT_REFUND",
                        note, "REJECT-REFUND-" + borrowId);

                // Gửi thông báo cho khách (nếu có hệ thống Notification)
                notificationService.notifyDepositRefunded(userId, bookTitle, depositAmount, note);
            } catch (Exception e) {
                System.err.println("Lỗi hoàn tiền khi từ chối: " + e.getMessage());
            }
        }

        // Ghi log hoạt động của thủ thư
        logDAO.addActivityLog((int) staffId, "Từ chối mượn: " + bookTitle + " [ID:" + borrowId + "]");
    }

    public void borrowMultipleInPerson(long userId, List<String> barcodes) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                String checkUserSql = "SELECT status, full_name FROM [User] WHERE user_id = ?";
                try (PreparedStatement ps = c.prepareStatement(checkUserSql)) {
                    ps.setLong(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String uStatus = rs.getString("status");
                            if ("INACTIVE".equalsIgnoreCase(uStatus) || "BANNED".equalsIgnoreCase(uStatus)) {
                                throw new IllegalArgumentException(
                                        "Tài khoản độc giả (" + rs.getString("full_name") + ") đang bị khóa.");
                            }
                        } else {
                            throw new IllegalArgumentException("Không tìm thấy độc giả có ID: " + userId);
                        }
                    }
                }

                int currentBorrowed = libDAO.countActiveBorrows(userId);
                if (currentBorrowed + barcodes.size() > BorrowService.MAX_ACTIVE_BORROWS) {
                    throw new IllegalArgumentException(
                            "Vượt quá giới hạn mượn (Tối đa " + BorrowService.MAX_ACTIVE_BORROWS + " cuốn). Đang mượn: "
                            + currentBorrowed);
                }

                LocalDate borrowDate = LocalDate.now();
                LocalDate dueDate = borrowDate.plusDays(14);

                for (String barcode : barcodes) {
                    if (barcode.trim().isEmpty()) {
                        continue;
                    }

                    int copyId = -1;
                    long bookId = -1;
                    String checkCopySql = "SELECT copy_id, book_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'";
                    try (PreparedStatement ps = c.prepareStatement(checkCopySql)) {
                        ps.setString(1, barcode);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                copyId = rs.getInt("copy_id");
                                bookId = rs.getLong("book_id");
                            } else {
                                throw new IllegalArgumentException("Mã vạch '" + barcode + "' không khả dụng.");
                            }
                        }
                    }

                    String insertBrSql = "INSERT INTO borrow_records(user_id, book_id, copy_id, borrow_date, due_date, status, borrow_method) "
                            + "VALUES(?, ?, ?, ?, ?, 'BORROWED', 'IN_PERSON')";
                    try (PreparedStatement ps = c.prepareStatement(insertBrSql)) {
                        ps.setLong(1, userId);
                        ps.setLong(2, bookId);
                        ps.setInt(3, copyId);
                        ps.setDate(4, java.sql.Date.valueOf(borrowDate));
                        ps.setDate(5, java.sql.Date.valueOf(dueDate));
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = c
                            .prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                        ps.setInt(1, copyId);
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = c
                            .prepareStatement("UPDATE Book SET quantity = quantity - 1 WHERE book_id = ?")) {
                        ps.setLong(1, bookId);
                        ps.executeUpdate();
                    }
                }
                c.commit();
            } catch (Exception ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    public List<RenewalRequest> listPendingRenewalRequests() throws SQLException {
        List<RenewalRequest> pending = renewalRequestDAO.listPending();
        for (RenewalRequest request : pending) {
            BorrowRecord record = libDAO.findById(request.getBorrowId());
            request.setBorrowRecord(record);
        }
        return pending;
    }

    public int countRenewalRequestsForBorrow(long borrowId) throws SQLException {
        return renewalRequestDAO.countByBorrowId(borrowId);
    }

    public RenewalRequest getRenewalRequest(long renewalId) throws SQLException {
        RenewalRequest request = renewalRequestDAO.findById(renewalId);
        if (request != null) {
            BorrowRecord record = libDAO.findById(request.getBorrowId());
            request.setBorrowRecord(record);
        }
        return request;
    }

    public List<Reservation> listWaitingReservations(long bookId) throws SQLException {
        return reservationService.listWaitingQueue(bookId);
    }

    public void approveRenewalRequest(long renewalId, long staffId) throws SQLException {
        RenewalRequest request = renewalRequestDAO.findById(renewalId);
        if (request == null) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu gia hạn này.");
        }
        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new IllegalArgumentException("Yêu cầu đã được xử lý trước đó.");
        }
        BorrowRecord record = libDAO.findById(request.getBorrowId());
        if (record == null) {
            throw new IllegalArgumentException("Không tìm thấy phiếu mượn tương ứng.");
        }

        LocalDate baseDate = record.getDueDate() != null ? record.getDueDate() : LocalDate.now();
        LocalDate nextDue = baseDate.plusDays(BorrowService.LOAN_DAYS);

        try (Connection c = DBConnection.getConnection()) {
            boolean originalAuto = c.getAutoCommit();
            c.setAutoCommit(false);
            try {
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE borrow_records SET due_date = ?, status = 'BORROWED' WHERE id = ?")) {
                    ps.setDate(1, Date.valueOf(nextDue));
                    ps.setLong(2, record.getId());
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE renewal_requests SET status = 'APPROVED' WHERE id = ?")) {
                    ps.setLong(1, renewalId);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (Exception ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(originalAuto);
            }
        }

    }

    public void rejectRenewalRequest(long renewalId, String reason, long staffId) throws SQLException {
        RenewalRequest request = renewalRequestDAO.findById(renewalId);
        if (request == null) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu gia hạn này.");
        }
        if (!"PENDING".equalsIgnoreCase(request.getStatus())) {
            throw new IllegalArgumentException("Yêu cầu đã được xử lý trước đó.");
        }
        BorrowRecord record = libDAO.findById(request.getBorrowId());
        if (record == null) {
            throw new IllegalArgumentException("Không tìm thấy phiếu mượn tương ứng.");
        }

        String trimmedNote = (reason != null && !reason.isBlank()) ? reason.trim() : null;
        try (Connection c = DBConnection.getConnection()) {
            boolean originalAuto = c.getAutoCommit();
            c.setAutoCommit(false);
            try {
                try (PreparedStatement ps = c
                        .prepareStatement("UPDATE borrow_records SET status = 'BORROWED' WHERE id = ?")) {
                    ps.setLong(1, record.getId());
                    ps.executeUpdate();
                }
                try (PreparedStatement ps = c.prepareStatement(
                        "UPDATE renewal_requests SET status = 'REJECTED', rejection_reason = ? WHERE id = ?")) {
                    ps.setString(1, trimmedNote);
                    ps.setLong(2, renewalId);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (Exception ex) {
                c.rollback();
                throw ex;
            } finally {
                c.setAutoCommit(originalAuto);
            }
        }

    }

    public List<BorrowRecord> searchBorrowings(String keyword, String status, String method) throws SQLException {
        return libDAO.searchBorrowings(keyword, status, method);
    }

    public BorrowRecord getDetail(long id) throws SQLException {
        return libDAO.findById(id);
    }

    private BigDecimal calculateFine(LocalDate dueDate, LocalDate returnDate) {
        if (dueDate == null || returnDate == null || !returnDate.isAfter(dueDate)) {
            return BigDecimal.ZERO;
        }
        long lateDays = java.time.temporal.ChronoUnit.DAYS.between(dueDate, returnDate);
        return BorrowService.FINE_PER_DAY.multiply(BigDecimal.valueOf(lateDays));
    }

    public com.lbms.model.BookCopy getBookByBarcode(String barcode) {
        try {
            // Gọi hàm vừa tạo ở DAO
            return libDAO.findCopyByBarcode(barcode);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    public void confirmReceiveOnline(long borrowId) throws SQLException {
        LocalDate today = LocalDate.now();
        // Chốt ngày mượn là hôm nay, ngày trả là 14 ngày sau
        LocalDate dueDate = today.plusDays(14);

        try (Connection c = DBConnection.getConnection()) {
            String sql = "UPDATE borrow_records SET status = 'RECEIVED', borrow_date = ?, due_date = ? WHERE id = ?";
            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setDate(1, java.sql.Date.valueOf(today));
                ps.setDate(2, java.sql.Date.valueOf(dueDate));
                ps.setLong(3, borrowId);
                ps.executeUpdate();
            }
        }
    }

    public void updateStatus(long id, String status) throws SQLException {
        libDAO.updateStatus(id, status); // Gọi hàm updateStatus đã có trong LibrarianBorrowDAO
    }
}
