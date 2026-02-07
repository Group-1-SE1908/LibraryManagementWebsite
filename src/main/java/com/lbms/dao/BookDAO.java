package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    public List<Book> search(String q) throws SQLException {
        String like = q == null ? null : ("%" + q.trim() + "%");
        String sql = "SELECT book_id AS id, title, author, price, availability, category_id FROM Book " +
                "WHERE (? IS NULL OR title LIKE ? OR author LIKE ?) ORDER BY book_id DESC";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            if (like == null || like.equals("%%")) {
                ps.setNull(1, Types.VARCHAR);
                ps.setNull(2, Types.VARCHAR);
                ps.setNull(3, Types.VARCHAR);
            } else {
                ps.setString(1, like);
                ps.setString(2, like);
                ps.setString(3, like);
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
        String sql = "SELECT book_id AS id, title, author, price, availability, category_id FROM Book WHERE book_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    return null;
                return mapBook(rs);
            }
        }
    }

    public long create(Book b) throws SQLException {
        String sql = "INSERT INTO Book(title, author, price, availability, category_id) VALUES(?, ?, ?, 1, ?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            ps.setBigDecimal(3, BigDecimal.valueOf(b.getPrice() != null ? b.getPrice() : 0));
            if (b.getCategoryId() == null)
                ps.setNull(4, Types.INTEGER);
            else
                ps.setInt(4, b.getCategoryId().intValue());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getLong(1);
                return 0;
            }
        }
    }

    public void update(Book b) throws SQLException {
        String sql = "UPDATE Book SET title=?, author=?, price=?, availability=?, category_id=? WHERE book_id=?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            ps.setBigDecimal(3, BigDecimal.valueOf(b.getPrice() != null ? b.getPrice() : 0));
            ps.setInt(4, b.isAvailability() ? 1 : 0);
            if (b.getCategoryId() == null)
                ps.setNull(5, Types.INTEGER);
            else
                ps.setInt(5, b.getCategoryId().intValue());
            ps.setLong(6, b.getId());
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM Book WHERE book_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    private Book mapBook(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setId(rs.getLong("id"));
        b.setTitle(rs.getString("title"));
        b.setAuthor(rs.getString("author"));
        b.setPrice(rs.getDouble("price"));
        b.setAvailability(rs.getInt("availability") > 0);
        b.setCategoryId(rs.getLong("category_id"));
        return b;
    }
}
