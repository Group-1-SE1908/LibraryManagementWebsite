package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class BorrowDAO {

    public long createRequest(long userId, long bookId) throws SQLException {
        String sql = "INSERT INTO borrow_records(user_id, book_id, borrow_date, due_date, return_date, status, fine_amount) " +
                "VALUES(?, ?, ?, ?, NULL, 'REQUESTED', 0)";

        LocalDate today = LocalDate.now();
        LocalDate due = today.plusDays(14);

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setDate(3, Date.valueOf(today));
            ps.setDate(4, Date.valueOf(due));
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
                return 0;
            }
        }
    }

    public List<BorrowRecord> listAll() throws SQLException {
        String sql = baseSelect() + " ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    public List<BorrowRecord> listByUser(long userId) throws SQLException {
        String sql = baseSelect() + " WHERE br.user_id = ? ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public int countActiveBorrows(long userId) throws SQLException {
        String sql = "SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status IN ('APPROVED','BORROWED')";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("c");
            }
        }
    }

    public BorrowRecord findById(long id) throws SQLException {
        String sql = baseSelect() + " WHERE br.id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapOne(rs);
            }
        }
    }

    public void updateStatus(long id, String status) throws SQLException {
        String sql = "UPDATE borrow_records SET status = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void markReturned(long id, LocalDate returnDate, BigDecimal fineAmount) throws SQLException {
        String sql = "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(returnDate));
            ps.setBigDecimal(2, fineAmount);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    private String baseSelect() {
        return "SELECT br.id, br.user_id, br.book_id, br.borrow_date, br.due_date, br.return_date, br.status, br.fine_amount, " +
                "u.email AS user_email, u.full_name AS user_full_name, " +
                "b.isbn AS book_isbn, b.title AS book_title, b.author AS book_author, b.quantity AS book_quantity, b.status AS book_status " +
                "FROM borrow_records br " +
                "JOIN users u ON br.user_id = u.id " +
                "JOIN books b ON br.book_id = b.id";
    }

    private List<BorrowRecord> mapList(ResultSet rs) throws SQLException {
        List<BorrowRecord> out = new ArrayList<>();
        while (rs.next()) out.add(mapOne(rs));
        return out;
    }

    private BorrowRecord mapOne(ResultSet rs) throws SQLException {
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getLong("id"));

        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("user_email"));
        u.setFullName(rs.getString("user_full_name"));
        br.setUser(u);

        Book b = new Book();
        b.setId(rs.getLong("book_id"));
        b.setIsbn(rs.getString("book_isbn"));
        b.setTitle(rs.getString("book_title"));
        b.setAuthor(rs.getString("book_author"));
        b.setQuantity(rs.getInt("book_quantity"));
        b.setStatus(rs.getString("book_status"));
        br.setBook(b);

        Date bd = rs.getDate("borrow_date");
        br.setBorrowDate(bd == null ? null : bd.toLocalDate());

        Date dd = rs.getDate("due_date");
        br.setDueDate(dd == null ? null : dd.toLocalDate());

        Date rd = rs.getDate("return_date");
        br.setReturnDate(rd == null ? null : rd.toLocalDate());

        br.setStatus(rs.getString("status"));
        br.setFineAmount(rs.getBigDecimal("fine_amount"));
        return br;
    }
}
