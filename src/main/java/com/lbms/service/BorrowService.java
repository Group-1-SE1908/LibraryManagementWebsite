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

    public long requestBorrow(long userId, long bookId) throws SQLException {
        Book b = bookDAO.findById(bookId);
        if (b == null) throw new IllegalArgumentException("Sách không tồn tại");
        if (b.getQuantity() <= 0) throw new IllegalArgumentException("Sách đã hết");

        int active = borrowDAO.countActiveBorrows(userId);
        if (active >= MAX_ACTIVE_BORROWS) {
            throw new IllegalArgumentException("Bạn đã mượn tối đa " + MAX_ACTIVE_BORROWS + " sách");
        }

        // create request
        return borrowDAO.createRequest(userId, bookId);
    }

    public void approve(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) throw new IllegalArgumentException("Yêu cầu không tồn tại");
        if (!"REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ để duyệt");
        }

        // Transaction: update borrow status + reduce book quantity
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // re-check quantity with lock
                try (var ps = c.prepareStatement("SELECT quantity FROM books WHERE id=? FOR UPDATE")) {
                    ps.setLong(1, br.getBook().getId());
                    try (var rs = ps.executeQuery()) {
                        if (!rs.next()) throw new SQLException("Book not found");
                        int qty = rs.getInt(1);
                        if (qty <= 0) throw new IllegalArgumentException("Sách đã hết");
                    }
                }

                // reduce qty
                try (var ps = c.prepareStatement("UPDATE books SET quantity = quantity - 1 WHERE id=?")) {
                    ps.setLong(1, br.getBook().getId());
                    ps.executeUpdate();
                }

                // set borrow_date/due_date/status BORROWED
                LocalDate today = LocalDate.now();
                LocalDate due = today.plusDays(LOAN_DAYS);
                try (var ps = c.prepareStatement(
                        "UPDATE borrow_records SET status='BORROWED', borrow_date=?, due_date=? WHERE id=?")) {
                    ps.setDate(1, java.sql.Date.valueOf(today));
                    ps.setDate(2, java.sql.Date.valueOf(due));
                    ps.setLong(3, borrowId);
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
        if (br == null) throw new IllegalArgumentException("Yêu cầu không tồn tại");
        if (!"REQUESTED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ để từ chối");
        }
        borrowDAO.updateStatus(borrowId, "REJECTED");
    }

    public BigDecimal returnBook(long borrowId) throws SQLException {
        BorrowRecord br = borrowDAO.findById(borrowId);
        if (br == null) throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        if (!"BORROWED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ có thể trả khi đang BORROWED");
        }

        LocalDate today = LocalDate.now();
        BigDecimal fine = calculateFine(br.getDueDate(), today);

        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // increase qty
                try (var ps = c.prepareStatement("UPDATE books SET quantity = quantity + 1 WHERE id=?")) {
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
        if (dueDate == null || returnDate == null) return BigDecimal.ZERO;
        long lateDays = ChronoUnit.DAYS.between(dueDate, returnDate);
        if (lateDays <= 0) return BigDecimal.ZERO;
        return FINE_PER_DAY.multiply(BigDecimal.valueOf(lateDays));
    }
}
