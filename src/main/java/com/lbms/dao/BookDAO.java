package com.lbms.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.lbms.model.Book;
import com.lbms.util.DBConnection;

public class BookDAO {

    private final LibrarianActivityLogDAO logDAO = new LibrarianActivityLogDAO();

    public List<Book> search(String q) throws SQLException {
        String like = (q == null || q.trim().isEmpty()) ? "%" : "%" + q.trim() + "%";
        // Chọn tất cả các cột bao gồm cả cột image và availability (computed column)
        String sql = "SELECT * FROM Book WHERE title LIKE ? OR author LIKE ? OR isbn LIKE ? ORDER BY book_id DESC";

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);

            List<Book> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapBook(rs));
                }
            }
            return out;
        }
    }

    public List<Book> searchByCategory(String q, Long categoryId) throws SQLException {
        String like = (q == null || q.trim().isEmpty()) ? "%" : "%" + q.trim() + "%";
        StringBuilder sql = new StringBuilder("SELECT * FROM Book WHERE (title LIKE ? OR author LIKE ?)");

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND category_id = ?");
        }
        sql.append(" ORDER BY book_id DESC");

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            ps.setString(1, like);
            ps.setString(2, like);
            if (categoryId != null && categoryId > 0) {
                ps.setLong(3, categoryId);
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
        String sql = "SELECT * FROM Book WHERE book_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapBook(rs);
                }
            }
        }
        return null;
    }

    public long create(Book b, long userId) throws SQLException {
        String sql = "INSERT INTO Book (title, author, category_id, price, quantity, isbn, image) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());
            if (b.getCategoryId() != null) {
                ps.setLong(3, b.getCategoryId());
            } else {
                ps.setNull(3, Types.INTEGER);
            }
            ps.setBigDecimal(4, BigDecimal.valueOf(b.getPrice() != null ? b.getPrice() : 0));
            ps.setInt(5, b.getQuantity());
            //ps.setString(6, b.getIsbn());
            String isbn = b.getIsbn();
            if (isbn != null && !isbn.isBlank() && !isbn.startsWith("LIB-")) {
                isbn = "ISBN-" + isbn;
            }
            ps.setString(6, isbn);
            ps.setString(7, b.getImage()); // Lưu đường dẫn ảnh

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    long newId = rs.getLong(1);
                    // Ghi log hoạt động sau khi tạo sách mới
                    logDAO.addActivityLog((int) userId, "Đã thêm sách mới: " + b.getTitle());
                    return newId;
                }
            }
        }
        return 0;
    }

    public void update(Book b, long userId) throws SQLException {

        String sql = "UPDATE Book SET title=?, author=?, price=?, quantity=?, image=?, category_id=? WHERE book_id=?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getAuthor());

            ps.setBigDecimal(3, java.math.BigDecimal.valueOf(b.getPrice() != null ? b.getPrice() : 0));
            ps.setInt(4, b.getQuantity());
            ps.setString(5, b.getImage());

            if (b.getCategoryId() != null && b.getCategoryId() > 0) {
                //ps.setLong(6, b.getCategoryId());
                String isbn = b.getIsbn();
                if (isbn != null && !isbn.isBlank() && !isbn.startsWith("LIB-")) {
                    isbn = "ISBN-" + isbn;
                }
                ps.setString(6, isbn);
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }

            ps.setLong(7, b.getId());
            // Lấy tên sách trước khi cập nhật để log
            int rowAffected = ps.executeUpdate();
            if (rowAffected > 0) {
                logDAO.addActivityLog((int) userId, "Đã cập nhật sách: " + b.getTitle() + " (ID: " + b.getId() + ")");
            }
        }
    }

    public void delete(long id, long userId) throws SQLException {
        // Lấy tên sách trước khi xóa để log rõ ràng hơn
        Book b = findById(id);
        String bookTitle = (b != null) ? b.getTitle() : "N/A";
        String sql = "DELETE FROM Book WHERE book_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            // Kiểm tra để ghi vào log
            int rowAffected = ps.executeUpdate();
            if (rowAffected > 0) {
                logDAO.addActivityLog((int) userId, "Đã xóa sách ID: " + id + " (Tiêu đề: " + bookTitle + ")");
            }
        }
    }

    private Book mapBook(ResultSet rs) throws SQLException {
        Book b = new Book();

        b.setId(rs.getLong("book_id"));
        b.setTitle(rs.getString("title"));
        b.setAuthor(rs.getString("author"));
        b.setPrice(rs.getDouble("price"));
        b.setIsbn(rs.getString("isbn"));
        b.setQuantity(rs.getInt("quantity"));
        b.setAvailability(b.getQuantity() > 0);
        b.setImage(rs.getString("image"));

        b.setCategoryId(rs.getObject("category_id") != null ? rs.getLong("category_id") : null);
        return b;
    }
}
