package com.lbms.service;

import com.lbms.dao.LibrarianBorrowDAO;
import com.lbms.dao.RenewalRequestDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.RenewalRequest;
import com.lbms.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import com.lbms.dao.LibrarianActivityLogDAO;

public class LibrarianBorrowService {

    private final LibrarianBorrowDAO libDAO = new LibrarianBorrowDAO();
    private final LibrarianActivityLogDAO logDAO = new LibrarianActivityLogDAO();
    private final RenewalRequestDAO renewalRequestDAO = new RenewalRequestDAO();

    public BigDecimal returnBook(long borrowId, String inputBarcode) throws SQLException {
        if (inputBarcode == null || inputBarcode.trim().isEmpty()) {
            throw new IllegalArgumentException("Vui lòng quét hoặc nhập mã vạch sách.");
        }

        // Chuẩn hóa đầu vào: bỏ khoảng trắng thừa
        String cleanInput = inputBarcode.trim();

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Lấy thông tin đối chiếu (Sử dụng TRIM trong SQL để loại bỏ khoảng trắng ẩn
                // trong DB)
                String sqlCheck = "SELECT LTRIM(RTRIM(bc.barcode)) as barcode, br.book_id, br.status, br.due_date "
                        + "FROM borrow_records br "
                        + "JOIN BookCopy bc ON br.copy_id = bc.copy_id "
                        + "WHERE br.id = ?";

                String correctBarcode = "";
                long bookId = -1;
                String currentStatus = "";
                LocalDate dueDate = null;

                try (PreparedStatement ps = c.prepareStatement(sqlCheck)) {
                    ps.setLong(1, borrowId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            correctBarcode = rs.getString("barcode");
                            bookId = rs.getLong("book_id");
                            currentStatus = rs.getString("status");
                            java.sql.Date dueDateSql = rs.getDate("due_date");
                            if (dueDateSql != null) {
                                dueDate = dueDateSql.toLocalDate();
                            }
                        } else {
                            throw new IllegalArgumentException(
                                    "Lỗi: Phiếu mượn này chưa được gán mã vạch (copy_id bị NULL hoặc không tồn tại).");
                        }
                    }
                }

                // 2. So khớp Barcode (Sử dụng equalsIgnoreCase và hiển thị lỗi chi tiết nếu
                // sai)
                if (correctBarcode == null || !correctBarcode.equalsIgnoreCase(cleanInput)) {
                    throw new IllegalArgumentException("Sai mã vạch! Phiếu này yêu cầu mã '" + correctBarcode
                            + "', nhưng bạn lại quét mã '" + cleanInput + "'.");
                }

                // 3. Cập nhật trạng thái bản sao sách về khả dụng
                String updateCopy = "UPDATE BookCopy SET status = 'AVAILABLE' WHERE copy_id = "
                        + "(SELECT copy_id FROM borrow_records WHERE id = ?)";
                try (PreparedStatement ps = c.prepareStatement(updateCopy)) {
                    ps.setLong(1, borrowId);
                    ps.executeUpdate();
                }

                // 4. Tăng số lượng đầu sách trong kho (Chỉ tăng nếu trạng thái cũ là đang
                // mượn/giao)
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
                return fineAmount;
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
                String sqlInfo = "SELECT b.title, u.full_name FROM borrow_records br " +
                        "JOIN Book b ON br.book_id = b.book_id " +
                        "JOIN [User] u ON br.user_id = u.user_id WHERE br.id = ?";
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
            throw new IllegalArgumentException("Không tìm thấy phiếu mượn với ID: " + borrowId);
        }
        String bookTitle = record.getBook().getTitle();
        String userName = record.getUser().getFullName();
        libDAO.rejectRequest(borrowId, reason);
        logDAO.addActivityLog((int) staffId,
                "Từ chối mượn: " + bookTitle + " - Độc giả: " + userName + " [ID:" + borrowId + "]");
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
                if (currentBorrowed + barcodes.size() > 5) {
                    throw new IllegalArgumentException(
                            "Vượt quá giới hạn mượn (Tối đa 5 cuốn). Đang mượn: " + currentBorrowed);
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

    public RenewalRequest getRenewalRequest(long renewalId) throws SQLException {
        RenewalRequest request = renewalRequestDAO.findById(renewalId);
        if (request != null) {
            BorrowRecord record = libDAO.findById(request.getBorrowId());
            request.setBorrowRecord(record);
        }
        return request;
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

        String bookTitle = record.getBook() != null ? record.getBook().getTitle() : "N/A";
        String userName = record.getUser() != null ? record.getUser().getFullName() : "N/A";
        logDAO.addActivityLog((int) staffId,
                "Phê duyệt gia hạn: " + bookTitle + " - Độc giả: " + userName + " [Phiếu " + record.getId() + "]");
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

        String bookTitle = record.getBook() != null ? record.getBook().getTitle() : "N/A";
        String userName = record.getUser() != null ? record.getUser().getFullName() : "N/A";
        String note = trimmedNote != null ? trimmedNote : "Không có lý do";
        logDAO.addActivityLog((int) staffId,
                "Từ chối gia hạn: " + bookTitle + " - Độc giả: " + userName + " [Phiếu " + record.getId() + "] - "
                        + note);
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
}