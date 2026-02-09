package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BookDAO {


    public List<Book> listAll() throws SQLException {
        String sql = "SELECT b.book_id, b.title, b.author, b.price, b.isbn, b.quantity, b.image, b.category_id, c.category_name " +
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

 
    public void create(Book b) throws SQLException {
       
        String sql = "INSERT INTO Book (title, author, price, image, category_id, isbn, quantity) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            ps.setBigDecimal(3, b.getPrice());
            // ps.setBoolean(4, ...); -> XÓA DÒNG NÀY
            ps.setString(4, b.getImage()); 
            
            if (b.getCategoryId() > 0) {
                ps.setInt(5, b.getCategoryId());
            } else {
                ps.setNull(5, Types.INTEGER);
            }

            ps.setString(6, b.getIsbn()); 
            ps.setInt(7, b.getQuantity());
            
            ps.executeUpdate();
        }
    }

  
    public void update(Book b) throws SQLException {
        String sql = "UPDATE Book SET title=?, author=?, price=?, quantity=?, image=?, category_id=? WHERE book_id=?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            ps.setBigDecimal(3, b.getPrice());
            ps.setInt(4, b.getQuantity());   
            ps.setString(5, b.getImage());
            if(b.getCategoryId() > 0) ps.setInt(6, b.getCategoryId()); else ps.setNull(6, Types.INTEGER);
            ps.setInt(7, b.getBookId());
            ps.executeUpdate();
        }
    }

    
    public void updateAvailability(int bookId, boolean isAvailable) throws SQLException {
     
        int qty = isAvailable ? 1 : 0;
        String sql = "UPDATE Book SET quantity=? WHERE book_id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, qty);
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
        String sql = "SELECT b.book_id, b.title, b.author, b.price, b.isbn, b.quantity, b.image, b.category_id, c.category_name " +
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
        
     
        String sql = "SELECT b.book_id, b.title, b.author, b.price, b.isbn, b.quantity, b.image, b.category_id, c.category_name " +
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

    public Book findByIsbn(String isbn) throws SQLException{
       
        String sql= "SELECT b.book_id, b.title, b.author, b.price, b.isbn, b.quantity, b.image, b.category_id, c.category_name " +
                    "FROM Book b LEFT JOIN Category c ON b.category_id = c.category_id WHERE isbn = ?";
        try(Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)){
            ps.setString(1, isbn);
            try(ResultSet rs = ps.executeQuery()){
                if(rs.next()) return mapRow(rs);
                return null;
            }
        } 
    }
    
   
    private Book mapRow(ResultSet rs) throws SQLException {
        Book b = new Book();
        b.setBookId(rs.getInt("book_id"));
        b.setTitle(rs.getString("title"));
        b.setAuthor(rs.getString("author"));
        b.setPrice(rs.getBigDecimal("price"));
        b.setIsbn(rs.getString("isbn"));
        b.setQuantity((rs.getInt("quantity")));
        
        
        b.setAvailability(b.getQuantity() > 0); 
        
        b.setImage(rs.getString("image")); 
        b.setCategoryId(rs.getInt("category_id"));
        
        try {
            String catName = rs.getString("category_name");
            b.setCategoryName(catName != null ? catName : "Không xác định");
        } catch (SQLException e) {}
        
        return b;
    }
}