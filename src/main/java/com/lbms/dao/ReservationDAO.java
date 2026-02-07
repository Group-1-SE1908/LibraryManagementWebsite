package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.model.Reservation;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    public boolean existsActive(long userId, long bookId) throws SQLException {
        String sql = "SELECT 1 FROM reservations WHERE user_id=? AND book_id=? AND status IN ('WAITING','NOTIFIED') LIMIT 1";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long create(long userId, long bookId) throws SQLException {
        String sql = "INSERT INTO reservations(user_id, book_id, status) VALUES(?, ?, 'WAITING')";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
                return 0;
            }
        }
    }

    public void cancel(long reservationId, long userId) throws SQLException {
        String sql = "UPDATE reservations SET status='CANCELLED' WHERE id=? AND user_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public List<Reservation> listByUser(long userId) throws SQLException {
        String sql = baseSelect() + " WHERE r.user_id=? ORDER BY r.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public List<Reservation> listAll() throws SQLException {
        String sql = baseSelect() + " ORDER BY r.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    private String baseSelect() {
        return "SELECT r.id, r.user_id, r.book_id, r.status, r.created_at, " +
                "u.email AS user_email, u.full_name AS user_full_name, " +
                "b.isbn AS book_isbn, b.title AS book_title, b.author AS book_author, b.quantity AS book_quantity, b.status AS book_status " +
                "FROM reservations r " +
                "JOIN users u ON r.user_id = u.id " +
                "JOIN books b ON r.book_id = b.id";
    }

    private List<Reservation> mapList(ResultSet rs) throws SQLException {
        List<Reservation> out = new ArrayList<>();
        while (rs.next()) out.add(mapOne(rs));
        return out;
    }

    private Reservation mapOne(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getLong("id"));
        r.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("created_at");
        r.setCreatedAt(ts == null ? null : ts.toInstant());

        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("user_email"));
        u.setFullName(rs.getString("user_full_name"));
        r.setUser(u);

        Book b = new Book();
        b.setId(rs.getLong("book_id"));
        b.setIsbn(rs.getString("book_isbn"));
        b.setTitle(rs.getString("book_title"));
        b.setAuthor(rs.getString("book_author"));
        b.setQuantity(rs.getInt("book_quantity"));
        b.setStatus(rs.getString("book_status"));
        r.setBook(b);

        return r;
    }
}
