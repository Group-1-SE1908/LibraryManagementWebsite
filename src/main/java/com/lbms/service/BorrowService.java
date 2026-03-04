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

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.ShippingDetails;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

public class BorrowService {

    public static final int MAX_ACTIVE_BORROWS = 5;
    public static final int LOAN_DAYS = 14;
    public static final BigDecimal FINE_PER_DAY = new BigDecimal("5000");

    private final BorrowDAO borrowDAO;
    private final BookDAO bookDAO;
    private final UserDAO userDAO;

    public BorrowService() {
        this.borrowDAO = new BorrowDAO();
        this.bookDAO = new BookDAO();
        this.userDAO = new UserDAO();
    }

    public long requestBorrow(long userId, long bookId, String method, ShippingDetails shippingDetails)
            throws SQLException {
        return requestBorrow(userId, bookId, 1, method, shippingDetails);
    }

    public long requestBorrow(long userId, long bookId, int quantity, String method, ShippingDetails shippingDetails)
            throws SQLException {
        List<Long> ids = requestBorrowCopies(userId, bookId, method, shippingDetails, quantity);
        return ids.isEmpty() ? 0 : ids.get(0);
    }

    public List<Long> requestBorrowCopies(long userId, long bookId, String method,
            ShippingDetails shippingDetails, int quantity) throws SQLException {
        if (quantity <= 0) {
            throw new IllegalArgumentException("Số lượng mượn phải lớn hơn 0");
        }

        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new IllegalArgumentException("Sách không tồn tại");
        }
        if (book.getQuantity() <= 0) {
            throw new IllegalArgumentException("Sách đã hết");
        }
        if (quantity > book.getQuantity()) {
            throw new IllegalArgumentException("Không thể mượn nhiều hơn số lượng đang có");
        }

        int active = borrowDAO.countActiveBorrows(userId);
        if (active + quantity > MAX_ACTIVE_BORROWS) {
            throw new IllegalArgumentException(
                    "Bạn chỉ có thể mượn tối đa " + MAX_ACTIVE_BORROWS
                            + " cuốn cùng lúc (bao gồm đang chờ duyệt)");
        }

        if ("IN_PERSON".equalsIgnoreCase(method) && shippingDetails == null) {
            User currentUser = userDAO.findById(userId);
            if (currentUser != null) {
                shippingDetails = new ShippingDetails();
                shippingDetails.setRecipient(currentUser.getFullName());
                shippingDetails.setPhone(currentUser.getPhone());

                String userAddr = currentUser.getAddress();
                shippingDetails.setStreet((userAddr != null && !userAddr.isBlank()) ? userAddr : "Nhận tại quầy");
                shippingDetails.setCity("");
                shippingDetails.setDistrict("");
                shippingDetails.setWard("");
            }
        }

        List<Long> ids = new ArrayList<>(quantity);
        for (int i = 0; i < quantity; i++) {
            ids.add(borrowDAO.createRequest(userId, bookId, 1, method, shippingDetails));
        }
        return ids;
    }

    public int countActiveBorrows(long userId) throws SQLException {
        return borrowDAO.countActiveBorrows(userId);
    }

    public void approve(long borrowId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                long copyId = -1;
                String findCopySql = "SELECT copy_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'";
                try (PreparedStatement ps = c.prepareStatement(findCopySql)) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getLong("copy_id");
                        } else {
                            throw new IllegalArgumentException(
                                    "Mã vạch không hợp lệ hoặc sách đã được mượn!");
                        }
                    }
                }

                try (PreparedStatement ps = c
                        .prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                    ps.setLong(1, copyId);
                    ps.executeUpdate();
                }

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
                try (var ps = c.prepareStatement("UPDATE Book SET availability = availability + 1 WHERE book_id=?")) {
                    ps.setLong(1, br.getBook().getId());
                    ps.executeUpdate();
                }

                try (var ps = c.prepareStatement(
                        "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=?, is_paid=0 WHERE id=?")) {
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

    public void markFinePaid(long borrowId) throws SQLException {
        borrowDAO.markFinePaid(borrowId);
    }

    public void borrowInPerson(long userId, long bookId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                long copyId = -1;
                String findCopySql = "SELECT copy_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'";
                try (PreparedStatement ps = c.prepareStatement(findCopySql)) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getLong("copy_id");
                        } else {
                            throw new IllegalArgumentException(
                                    "Mã vạch không hợp lệ hoặc sách đã được mượn!");
                        }
                    }
                }

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

                try (PreparedStatement ps = c
                        .prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
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