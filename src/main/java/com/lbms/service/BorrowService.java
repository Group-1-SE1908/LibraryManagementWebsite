package com.lbms.service;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.List;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
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

   
    public long requestBorrow(long userId, long bookId, String method) throws SQLException {
        Book b = bookDAO.findById(bookId);
        if (b == null) {
            throw new IllegalArgumentException("Sách không tồn tại");
        }
        if (b.getQuantity() <= 0) {
            throw new IllegalArgumentException("Sách đã hết");
        }

        int active = borrowDAO.countActiveBorrows(userId);
        if (active >= MAX_ACTIVE_BORROWS) {
            throw new IllegalArgumentException("Bạn đã mượn tối đa " + MAX_ACTIVE_BORROWS + " sách");
        }

        
        return borrowDAO.createRequest(userId, bookId, method);
    }

    public void approve(long borrowId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Tìm bản sao sách (BookCopy) và khóa hàng (SQL Server syntax)
                long copyId = -1;
                String findCopySql = "SELECT copy_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'";
                try (PreparedStatement ps = c.prepareStatement(findCopySql)) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getLong("copy_id");
                        } else {
                            throw new IllegalArgumentException("Mã vạch không hợp lệ hoặc sách đã được mượn!");
                        }
                    }
                }

                // 2. Cập nhật trạng thái bản sao sách
                try (PreparedStatement ps = c.prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                    ps.setLong(1, copyId);
                    ps.executeUpdate();
                }

                // 3. Cập nhật phiếu mượn (status, copy_id, ngày mượn, hạn trả)
                LocalDate today = LocalDate.now();
                LocalDate dueDate = today.plusDays(LOAN_DAYS);
                String updateBrSql = "UPDATE borrow_records SET status='BORROWED', borrow_date=?, due_date=?, copy_id=? WHERE id=?";
                try (PreparedStatement ps = c.prepareStatement(updateBrSql)) {
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

    public BigDecimal returnBook(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) {
            throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        }
        if (!"BORROWED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể trả khi đang BORROWED");
        }

        LocalDate today = LocalDate.now();
        BigDecimal fine = calculateFine(br.getDueDate(), today);

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // increase availability
                try (var ps = c.prepareStatement("UPDATE Book SET availability = availability + 1 WHERE book_id=?")) {
                    ps.setLong(1, br.getBook().getId());
                    ps.executeUpdate();
                }

                // mark returned
                try (var ps = c.prepareStatement(
                        "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=? WHERE id=?")) {
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

        return fine;
    }

    public BigDecimal calculateFine(LocalDate dueDate, LocalDate returnDate) {
        if (dueDate == null || returnDate == null) {
            return BigDecimal.ZERO;
        }
        long lateDays = ChronoUnit.DAYS.between(dueDate, returnDate);
        if (lateDays <= 0) {
            return BigDecimal.ZERO;
        }
        return FINE_PER_DAY.multiply(BigDecimal.valueOf(lateDays));
    }
    // Thêm vào BorrowService.java

    public void borrowInPerson(long userId, long bookId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Kiểm tra BookCopy và lấy copyId (Giống logic approve)
                long copyId = -1;
                String findCopySql = "SELECT copy_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'";
                try (PreparedStatement ps = c.prepareStatement(findCopySql)) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getLong("copy_id");
                        } else {
                            throw new IllegalArgumentException("Mã vạch không hợp lệ hoặc sách đã được mượn!");
                        }
                    }
                }

                // 2. Tạo bản ghi borrow_records mới trực tiếp ở trạng thái BORROWED
                LocalDate today = LocalDate.now();
                LocalDate dueDate = today.plusDays(LOAN_DAYS);
                String insertSql = "INSERT INTO borrow_records(user_id, book_id, borrow_date, due_date, status, borrow_method, copy_id) "
                        + "VALUES(?, ?, ?, ?, 'BORROWED', 'IN_PERSON', ?)";
                try (PreparedStatement ps = c.prepareStatement(insertSql)) {
                    ps.setLong(1, userId);
                    ps.setLong(2, bookId);
                    ps.setDate(3, java.sql.Date.valueOf(today));
                    ps.setDate(4, java.sql.Date.valueOf(dueDate));
                    ps.setLong(5, copyId);
                    ps.executeUpdate();
                }

                // 3. Cập nhật trạng thái BookCopy thành BORROWED
                try (PreparedStatement ps = c.prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
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
}
