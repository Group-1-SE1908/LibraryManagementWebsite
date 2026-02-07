package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    public List<Book> search(String q) throws SQLException {
        String like = q == null ? null : ("%" + q.trim() + "%");
        String sql = "SELECT id, isbn, title, author, publisher, publish_year, quantity, status FROM books " +
                "WHERE (? IS NULL OR title LIKE ? OR author LIKE ? OR isbn LIKE ?) ORDER BY id DESC";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            if (like == null || like.equals("%%")) {
                ps.setNull(1, Types.VARCHAR);
                ps.setNull(2, Types.VARCHAR);
                ps.setNull(3, Types.VARCHAR);
                ps.setNull(4, Types.VARCHAR);
            } else {
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
                ps.setString(4, like);
            }

            List<Book> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapBook(rs));
                }
            }
            return out;
        }
    }

    public Book findById(long id) throws SQLException {
        String sql = "SELECT id, isbn, title, author, publisher, publish_year, quantity, status FROM books WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapBook(rs);
            }
        }
    }

    public long create(Book b) throws SQLException {
        String sql = "INSERT INTO books(isbn, title, author, publisher, publish_year, quantity, status) VALUES(?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, b.getIsbn());
            ps.setString(2, b.getTitle());
            ps.setString(3, b.getAuthor());
            ps.setString(4, b.getPublisher());
            if (b.getPublishYear() == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, b.getPublishYear());
            ps.setInt(6, b.getQuantity());
            ps.setString(7, b.getStatus());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
                return 0;
            }
        }
    }

    public void update(Book b) throws SQLException {
        String sql = "UPDATE books SET isbn=?, title=?, author=?, publisher=?, publish_year=?, quantity=?, status=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getIsbn());
            ps.setString(2, b.getTitle());
            ps.setString(3, b.getAuthor());
            ps.setString(4, b.getPublisher());
            if (b.getPublishYear() == null) ps.setNull(5, Types.INTEGER); else ps.setInt(5, b.getPublishYear());
            ps.setInt(6, b.getQuantity());
            ps.setString(7, b.getStatus());
            ps.setLong(8, b.getId());
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM books WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    private Book mapBook(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setId(rs.getLong("id"));
        b.setIsbn(rs.getString("isbn"));
        b.setTitle(rs.getString("title"));
        b.setAuthor(rs.getString("author"));
        b.setPublisher(rs.getString("publisher"));
        int y = rs.getInt("publish_year");
        b.setPublishYear(rs.wasNull() ? null : y);
        b.setQuantity(rs.getInt("quantity"));
        b.setStatus(rs.getString("status"));
        return b;
    }
}
