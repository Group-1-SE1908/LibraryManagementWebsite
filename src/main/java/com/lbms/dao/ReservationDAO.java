package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.model.Reservation;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    public boolean existsActive(long userId, long bookId) throws SQLException {
        String sql = "SELECT TOP 1 1 FROM Borrowing WHERE user_id=? AND book_id=? AND status IN ('WAITING','NOTIFIED')";
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
        String sql = "INSERT INTO Borrowing(user_id, book_id, borrow_date, status) VALUES(?, ?, GETDATE(), 'WAITING')";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getLong(1);
                return 0;
            }
        }
    }

    public void cancel(long reservationId, long userId) throws SQLException {
        String sql = "UPDATE Borrowing SET status='CANCELLED' WHERE borrowing_id=? AND user_id=?";
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
        return "SELECT b.borrowing_id, b.user_id, b.book_id, b.status, b.borrow_date, " +
                "u.email AS user_email, u.name AS user_full_name, " +
                "bk.title AS book_title, bk.author AS book_author, bk.price AS book_quantity, bk.availability AS book_status "
                +
                "FROM Borrowing b " +
                "JOIN [User] u ON b.user_id = u.user_id " +
                "JOIN Book bk ON b.book_id = bk.book_id";
    }

    private List<Reservation> mapList(ResultSet rs) throws SQLException {
        List<Reservation> out = new ArrayList<>();
        while (rs.next())
            out.add(mapOne(rs));
        return out;
    }

    private Reservation mapOne(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getLong("borrowing_id"));
        r.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("borrow_date");
        r.setCreatedAt(ts == null ? null : ts.toInstant());

        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("user_email"));
        u.setFullName(rs.getString("user_full_name"));
        r.setUser(u);

        Book b = new Book();
        b.setId(rs.getLong("book_id"));
        b.setTitle(rs.getString("book_title"));
        b.setAuthor(rs.getString("book_author"));
        r.setBook(b);

        return r;
    }
}
