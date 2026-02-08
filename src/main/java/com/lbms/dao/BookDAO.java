package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {

    // 1. SELECT: Thêm cột b.image
    public List<Book> listAll() throws SQLException {
        String sql = "SELECT b.book_id, b.title, b.author, b.price, b.availability, b.image, b.category_id, c.category_name " +
                     "FROM Book b " +
                     "LEFT JOIN Category c ON b.category_id = c.category_id " +
                     "ORDER BY b.book_id DESC";
        
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            List<Book> list = new ArrayList<>();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
            return list;
        }
    }

    // 2. INSERT: Thêm cột image vào câu lệnh
    public void create(Book b) throws SQLException {
        String sql = "INSERT INTO Book (title, author, price, availability, image, category_id) VALUES (?, ?, ?, ?, ?, ?)";
        
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            ps.setBigDecimal(3, b.getPrice());
            ps.setBoolean(4, b.isAvailability());
            ps.setString(5, b.getImage()); // <-- Thêm dòng này
            
            if (b.getCategoryId() > 0) {
                ps.setInt(6, b.getCategoryId());
            } else {
                ps.setNull(6, Types.INTEGER);
            }
            
            ps.executeUpdate();
        }
    }

    // 3. UPDATE: Thêm image=? vào câu lệnh
    public void update(Book b) throws SQLException {
        String sql = "UPDATE Book SET title=?, author=?, price=?, image=?, category_id=? WHERE book_id=?";
        
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            ps.setBigDecimal(3, b.getPrice());
            ps.setString(4, b.getImage()); // <-- Thêm dòng này
            
            if (b.getCategoryId() > 0) {
                ps.setInt(5, b.getCategoryId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }
            
            ps.setInt(6, b.getBookId());
            ps.executeUpdate();
        }
    }

    public void updateAvailability(int bookId, boolean isAvailable) throws SQLException {
        String sql = "UPDATE Book SET availability=? WHERE book_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setBoolean(1, isAvailable);
            ps.setInt(2, bookId);
            ps.executeUpdate();
        }
    }

    public void delete(int bookId) throws SQLException {
        String sql = "DELETE FROM Book WHERE book_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.executeUpdate();
        }
    }

    public Book findById(int bookId) throws SQLException {
        String sql = "SELECT b.book_id, b.title, b.author, b.price, b.availability, b.image, b.category_id, c.category_name " +
                     "FROM Book b " +
                     "LEFT JOIN Category c ON b.category_id = c.category_id " +
                     "WHERE b.book_id = ?";
                     
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRow(rs);
                return null;
            }
        }
    }
    
    public List<Book> search(String keyword) throws SQLException {
        if (keyword == null || keyword.trim().isEmpty()) {
            return listAll();
        }
        
        String sql = "SELECT b.book_id, b.title, b.author, b.price, b.availability, b.image, b.category_id, c.category_name " +
                     "FROM Book b " +
                     "LEFT JOIN Category c ON b.category_id = c.category_id " +
                     "WHERE b.title LIKE ? OR b.author LIKE ? " +
                     "ORDER BY b.book_id DESC";
                     
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            String pattern = "%" + keyword.trim() + "%";
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            try (ResultSet rs = ps.executeQuery()) {
                List<Book> list = new ArrayList<>();
                while (rs.next()) list.add(mapRow(rs));
                return list;
            }
        }
    }

    // --- MAP ROW: Thêm map cột image ---
    private Book mapRow(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setBookId(rs.getInt("book_id"));
        b.setTitle(rs.getString("title"));
        b.setAuthor(rs.getString("author"));
        b.setPrice(rs.getBigDecimal("price"));
        b.setAvailability(rs.getBoolean("availability"));
        b.setImage(rs.getString("image")); // <-- Thêm dòng này
        b.setCategoryId(rs.getInt("category_id"));
        
        try {
            String catName = rs.getString("category_name");
            b.setCategoryName(catName != null ? catName : "Không xác định");
        } catch (SQLException e) {}
        
        return b;
    }
}