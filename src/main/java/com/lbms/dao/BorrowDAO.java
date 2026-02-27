package com.lbms.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

import com.lbms.model.Book;
import com.lbms.model.BookCopy;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

public class BorrowDAO {

    static {
        ensureBorrowMethodColumn();
    }

    public long createRequest(long userId, long bookId, String method) throws SQLException {
        // Thêm cột borrow_method vào câu lệnh INSERT
        String sql = "INSERT INTO borrow_records(user_id, book_id, borrow_date, return_date, status, borrow_method) "
                + "VALUES(?, ?, GETDATE(), NULL, 'REQUESTED', ?)";

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setString(3, method);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
                return 0;
            }
        }
    }

    public List<BorrowRecord> listAll() throws SQLException {
        String sql = baseSelect() + " ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    public List<BorrowRecord> listByUser(long userId) throws SQLException {
        String sql = baseSelect() + " WHERE br.user_id = ? ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public int countActiveBorrows(long userId) throws SQLException {
        String sql = "SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status IN ('APPROVED','BORROWED')";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("c");
            }
        }
    }

    public BorrowRecord findById(long id) throws SQLException {
        String sql = baseSelect() + " WHERE br.id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                return mapOne(rs);
            }
        }
    }

    public void updateStatus(long id, String status) throws SQLException {
        String sql = "UPDATE borrow_records SET status = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void markReturned(long id, LocalDate returnDate, BigDecimal fineAmount) throws SQLException {
        String sql = "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(returnDate));
            ps.setBigDecimal(2, fineAmount);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    private String baseSelect() {
        return "SELECT br.id AS borrowing_id, br.user_id, br.book_id, br.copy_id, br.borrow_date, br.due_date, br.return_date, "
                + "br.status, br.fine_amount, br.borrow_method, "
                + "u.email AS user_email, u.full_name AS user_full_name, "
                + "bk.title AS book_title, bk.author AS book_author, bk.isbn AS book_isbn, bk.image AS book_image "
                + "FROM borrow_records br "
                + "JOIN [User] u ON br.user_id = u.user_id "
                + "JOIN Book bk ON br.book_id = bk.book_id";
    }

    private List<BorrowRecord> mapList(ResultSet rs) throws SQLException {
        List<BorrowRecord> out = new ArrayList<>();
        while (rs.next()) {
            out.add(mapOne(rs));
        }
        return out;
    }

    public BorrowRecord mapOne(ResultSet rs) throws SQLException {
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getLong("borrowing_id"));

        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("user_email"));
        u.setFullName(rs.getString("user_full_name"));
        br.setUser(u);

        Book b = new Book();
        b.setId(rs.getLong("book_id"));
        b.setTitle(rs.getString("book_title"));
        b.setAuthor(rs.getString("book_author"));
        b.setImage(rs.getString("book_image"));
        br.setBook(b);

        Date bd = rs.getDate("borrow_date");
        br.setBorrowDate(bd == null ? null : bd.toLocalDate());

        Date rd = rs.getDate("return_date");
        br.setReturnDate(rd == null ? null : rd.toLocalDate());

        Date dd = rs.getDate("due_date");
        br.setDueDate(dd == null ? null : dd.toLocalDate());

        br.setStatus(rs.getString("status"));
        br.setFineAmount(rs.getBigDecimal("fine_amount"));
        br.setBorrowMethod(rs.getString("borrow_method"));
        long cid = rs.getLong("copy_id");
        if (cid > 0) {
            BookCopy bc = new BookCopy();
            bc.setCopyId((int) cid);
            br.setBookCopy(bc);
        }
        
        return br;
    }

    public List<BorrowRecord> listOverdue() throws SQLException {
        String sql = baseSelect()
                + " WHERE br.status = 'BORROWED' AND br.due_date < GETDATE() ORDER BY br.due_date ASC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    // Thêm vào BorrowDAO.java
    public List<BorrowRecord> listByMethod(String method) throws SQLException {
        // baseSelect() đã bao gồm các cột cần thiết và JOIN bảng
        String sql = baseSelect() + " WHERE br.borrow_method = ? ORDER BY br.id DESC";

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, method); // "ONLINE" hoặc "IN_PERSON"
            try (ResultSet rs = ps.executeQuery()) {
                List<BorrowRecord> out = new ArrayList<>();
                while (rs.next()) {
                    out.add(mapOne(rs)); // mapOne đã được cập nhật map cột borrow_method
                }
                return out;
            }
        }
    }

    private static void ensureBorrowMethodColumn() {
        String checkSql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='borrow_records' AND COLUMN_NAME='borrow_method'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(checkSql); ResultSet rs = ps.executeQuery()) {

            if (!rs.next()) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD borrow_method VARCHAR(20) NULL;");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể đồng bộ schema borrow_records", e);
        }
    }
}
