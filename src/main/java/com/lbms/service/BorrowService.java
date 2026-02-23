package com.lbms.service;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

import com.lbms.util.DBConnection;

public class BorrowService {
    public static final int MAX_ACTIVE_BORROWS = 3;
    public static final int LOAN_DAYS = 14;
    public static final BigDecimal FINE_PER_DAY = new BigDecimal("5000");

    private final BorrowDAO borrowDAO;
    private final BookDAO bookDAO;

    public BorrowService() {
        this.borrowDAO = new BorrowDAO();
        this.bookDAO = new BookDAO();
    }

    public long requestBorrow(long userId, int bookId) throws SQLException {
        Book b = bookDAO.findById(bookId);
        if (b == null)
            throw new IllegalArgumentException("Sách không tồn tại");
        if (b.getQuantity() <= 0)
            throw new IllegalArgumentException("Sách đã hết");

        int active = borrowDAO.countActiveBorrows(userId);
        if (active >= MAX_ACTIVE_BORROWS) {
            throw new IllegalArgumentException("Bạn đã mượn tối đa " + MAX_ACTIVE_BORROWS + " sách");
        }

        return borrowDAO.createRequest(userId, bookId);
    }

    // --- HÀM APPROVE ĐÃ SỬA LỖI SQL SERVER VÀ TÍCH HỢP BARCODE ---
    public void approve(long borrowId, String barcode) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) throw new IllegalArgumentException("Yêu cầu không tồn tại");
        if (!"REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ để duyệt");
        }

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Kiểm tra Barcode (Sử dụng WITH (UPDLOCK, ROWLOCK) cho SQL Server)
                int copyId = -1;
                String sqlCopy = "SELECT copy_id, book_id, status FROM BookCopy WITH (UPDLOCK, ROWLOCK) WHERE barcode=?";
                try (var ps = c.prepareStatement(sqlCopy)) {
                    ps.setString(1, barcode);
                    try (var rs = ps.executeQuery()) {
                        if (!rs.next()) throw new IllegalArgumentException("Mã vạch (Barcode) không tồn tại.");
                        if (!"AVAILABLE".equalsIgnoreCase(rs.getString("status"))) {
                            throw new IllegalArgumentException("Cuốn sách vật lý này hiện không có sẵn (hoặc đã cho mượn).");
                        }
                        if (rs.getInt("book_id") != br.getBook().getBookId()) {
                            throw new IllegalArgumentException("Mã vạch không khớp với đầu sách mà khách đã yêu cầu.");
                        }
                        copyId = rs.getInt("copy_id");
                    }
                }

                // 2. Trừ số lượng sách tổng
                try (var ps = c.prepareStatement("UPDATE Book SET quantity = quantity - 1 WHERE book_id=?")) {
                    ps.setLong(1, br.getBook().getBookId());
                    ps.executeUpdate();
                }

                // 3. Cập nhật trạng thái bản vật lý (BookCopy) thành Đang mượn
                try (var ps = c.prepareStatement("UPDATE BookCopy SET status='BORROWED' WHERE copy_id=?")) {
                    ps.setInt(1, copyId);
                    ps.executeUpdate();
                }

                // 4. Cập nhật phiếu mượn (Lưu copy_id vào phiếu)
                LocalDate today = LocalDate.now();
                LocalDate dueDate = today.plusDays(LOAN_DAYS);
                try (var ps = c.prepareStatement(
                        "UPDATE borrow_records SET status='BORROWED', borrow_date=?, due_date=?, copy_id=? WHERE id=?")) {
                    ps.setDate(1, java.sql.Date.valueOf(today));
                    ps.setDate(2, java.sql.Date.valueOf(dueDate));
                    ps.setInt(3, copyId);
                    ps.setLong(4, borrowId);
                    ps.executeUpdate();
                }
                c.commit();
            } catch (Exception ex) {
                c.rollback();
                if (ex instanceof SQLException) throw (SQLException) ex;
                if (ex instanceof RuntimeException) throw (RuntimeException) ex;
                throw new RuntimeException(ex);
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    public void reject(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null)
            throw new IllegalArgumentException("Yêu cầu không tồn tại");
        if (!"REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ để từ chối");
        }
        borrowDAO.updateStatus(borrowId, "REJECTED");
    }

    // --- HÀM RETURN BOOK ĐÃ TÍCH HỢP BARCODE ---
    public BigDecimal returnBook(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        if (!"BORROWED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể trả khi sách đang được mượn (BORROWED)");
        }

        LocalDate today = LocalDate.now();
        BigDecimal fine = calculateFine(br.getDueDate(), today);

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // Lấy copyId từ phiếu mượn
                int copyId = -1;
                if (br.getBookCopy() != null) {
                    copyId = br.getBookCopy().getCopyId();
                } else {
                    try (var ps = c.prepareStatement("SELECT copy_id FROM borrow_records WHERE id=?")) {
                        ps.setLong(1, borrowId);
                        try (var rs = ps.executeQuery()) {
                            if (rs.next()) copyId = rs.getInt("copy_id");
                        }
                    }
                }

                // 1. Cộng lại số lượng sách tổng
                try (var ps = c.prepareStatement("UPDATE Book SET quantity = quantity + 1 WHERE book_id=?")) {
                    ps.setLong(1, br.getBook().getBookId());
                    ps.executeUpdate();
                }

                // 2. Chuyển bản vật lý về trạng thái AVAILABLE
                if (copyId > 0) {
                    try (var ps = c.prepareStatement("UPDATE BookCopy SET status='AVAILABLE' WHERE copy_id=?")) {
                        ps.setInt(1, copyId);
                        ps.executeUpdate();
                    }
                }

                // 3. Đánh dấu trả sách
                borrowDAO.markReturned(borrowId, today, fine);

                c.commit();
            } catch (Exception ex) {
                c.rollback();
                if (ex instanceof SQLException) throw (SQLException) ex;
                if (ex instanceof RuntimeException) throw (RuntimeException) ex;
                throw new RuntimeException(ex);
            } finally {
                c.setAutoCommit(true);
            }
        }
        return fine;
    }

    public BigDecimal calculateFine(LocalDate dueDate, LocalDate returnDate) {
        if (dueDate == null || returnDate == null)
            return BigDecimal.ZERO;
        long lateDays = ChronoUnit.DAYS.between(dueDate, returnDate);
        if (lateDays <= 0)
            return BigDecimal.ZERO;
        return FINE_PER_DAY.multiply(BigDecimal.valueOf(lateDays));
    }
    
    public List<BorrowRecord> getOverdueList() throws SQLException {
        return borrowDAO.listOverdue();
    }
}