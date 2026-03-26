package com.lbms.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
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
        return searchByCategory(q, null);
    }

    public List<Book> searchByCategory(String q, Long categoryId) throws SQLException {
        String like = (q == null || q.trim().isEmpty()) ? "%" : "%" + q.trim() + "%";
        StringBuilder sql = new StringBuilder(
                "SELECT * FROM Book WHERE (title LIKE ? OR author LIKE ? OR isbn LIKE ?)");

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND category_id = ?");
        }
        sql.append(" ORDER BY book_id DESC");

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            ps.setString(1, like);
            ps.setString(2, like);
            ps.setString(3, like);
            if (categoryId != null && categoryId > 0) {
                ps.setLong(4, categoryId);
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

    public List<Book> searchByCategoryPaged(String q, Long categoryId, int offset, int limit) throws SQLException {
        String like = (q == null || q.trim().isEmpty()) ? "%" : "%" + q.trim() + "%";
        StringBuilder sql = new StringBuilder(
                "SELECT * FROM Book WHERE (title LIKE ? OR author LIKE ? OR isbn LIKE ?)");

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND category_id = ?");
        }
        sql.append(" ORDER BY book_id DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            int nextIndex = bindSearchParameters(ps, like, categoryId);
            ps.setInt(nextIndex++, Math.max(offset, 0));
            ps.setInt(nextIndex, Math.max(limit, 1));

            List<Book> out = new ArrayList<>();
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapBook(rs));
                }
            }
            return out;
        }
    }

    public int countByCategory(String q, Long categoryId) throws SQLException {
        String like = (q == null || q.trim().isEmpty()) ? "%" : "%" + q.trim() + "%";
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM Book WHERE (title LIKE ? OR author LIKE ? OR isbn LIKE ?)");

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND category_id = ?");
        }

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            bindSearchParameters(ps, like, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
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
        try (Connection c = DBConnection.getConnection()) {
            boolean hasDescriptionColumn = hasColumn(c, "Book", "description");
            String sql = hasDescriptionColumn
                    ? "INSERT INTO Book (title, author, category_id, price, quantity, isbn, image, description) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
                    : "INSERT INTO Book (title, author, category_id, price, quantity, isbn, image) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

                ps.setString(1, b.getTitle());
                ps.setString(2, b.getAuthor());
                if (b.getCategoryId() != null) {
                    ps.setLong(3, b.getCategoryId());
                } else {
                    ps.setNull(3, Types.INTEGER);
                }
                ps.setBigDecimal(4, BigDecimal.valueOf(b.getPrice() != null ? b.getPrice() : 0));
                ps.setInt(5, b.getQuantity());
                String isbn = b.getIsbn();
                if (isbn != null && !isbn.isBlank() && !isbn.startsWith("ISBN-")) {
                    isbn = "ISBN-" + isbn;
                }
                ps.setString(6, isbn);
                ps.setString(7, b.getImage());
                if (hasDescriptionColumn) {
                    ps.setString(8, b.getDescription());
                }

                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        long newId = rs.getLong(1);
                        // Ghi log hoạt động sau khi tạo sách mới
                        logDAO.addActivityLog((int) userId, "Thêm sách mới: " + b.getTitle() + " [ID:" + newId + "]");
                        return newId;
                    }
                }
            }
        }
        return 0;
    }

    public void update(Book b, long userId) throws SQLException {

        try (Connection c = DBConnection.getConnection()) {
            boolean hasDescriptionColumn = hasColumn(c, "Book", "description");
            String sql = hasDescriptionColumn
                    ? "UPDATE Book SET title=?, author=?, price=?, quantity=?, image=?, category_id=?, isbn=?, description=? WHERE book_id=?"
                    : "UPDATE Book SET title=?, author=?, price=?, quantity=?, image=?, category_id=?, isbn=? WHERE book_id=?";

            try (PreparedStatement ps = c.prepareStatement(sql)) {
                ps.setString(1, b.getTitle());
                ps.setString(2, b.getAuthor());

                ps.setBigDecimal(3, java.math.BigDecimal.valueOf(b.getPrice() != null ? b.getPrice() : 0));
                ps.setInt(4, b.getQuantity());
                ps.setString(5, b.getImage());

                if (b.getCategoryId() != null && b.getCategoryId() > 0) {
                    ps.setLong(6, b.getCategoryId());
                } else {
                    ps.setNull(6, java.sql.Types.INTEGER);
                }

                ps.setString(7, b.getIsbn());
                if (hasDescriptionColumn) {
                    ps.setString(8, b.getDescription());
                    ps.setLong(9, b.getId());
                } else {
                    ps.setLong(8, b.getId());
                }

                // Lấy tên sách trước khi cập nhật để log
                int rowAffected = ps.executeUpdate();
                if (rowAffected > 0) {
                    logDAO.addActivityLog((int) userId, "Cập nhật sách: " + b.getTitle() + " [ID:" + b.getId() + "]");
                }
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
                logDAO.addActivityLog((int) userId, "Xóa sách: " + bookTitle + " [ID:" + id + "]");
            }
        }
    }

    private int bindSearchParameters(PreparedStatement ps, String like, Long categoryId) throws SQLException {
        ps.setString(1, like);
        ps.setString(2, like);
        ps.setString(3, like);

        int nextIndex = 4;
        if (categoryId != null && categoryId > 0) {
            ps.setLong(nextIndex++, categoryId);
        }
        return nextIndex;
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
        b.setDescription(readOptionalColumn(rs, "description"));

        b.setCategoryId(rs.getObject("category_id") != null ? rs.getLong("category_id") : null);
        return b;
    }

    private boolean hasColumn(Connection connection, String tableName, String columnName) throws SQLException {
        try (ResultSet rs = connection.getMetaData().getColumns(null, null, tableName, columnName)) {
            return rs.next();
        }
    }

    private String readOptionalColumn(ResultSet rs, String columnName) throws SQLException {
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();
        for (int index = 1; index <= columnCount; index++) {
            String label = metaData.getColumnLabel(index);
            String name = metaData.getColumnName(index);
            if (columnName.equalsIgnoreCase(label) || columnName.equalsIgnoreCase(name)) {
                return rs.getString(columnName);
            }
        }
        return null;
    }

    public boolean existsByIsbn(String isbn) {
        String sql = "SELECT COUNT(*) FROM Book WHERE ISBN = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, isbn);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    // public boolean restockBook(int bookId, int additionalQuantity) {
    // String sql = "UPDATE Book SET quantity = quantity + ? WHERE book_id = ?";
    // try (Connection conn = DBConnection.getConnection(); PreparedStatement ps =
    // conn.prepareStatement(sql)) {
    // ps.setInt(1, additionalQuantity);
    // ps.setInt(2, bookId);
    // return ps.executeUpdate() > 1;
    // } catch (Exception e) {
    // e.printStackTrace();
    // }
    // return false;
    // }
    public boolean restockBook(int bookId, int additionalQuantity, long userId) {
        String bookTitle = "N/A";
        try {
            Book b = findById(bookId);
            if (b != null) {
                bookTitle = b.getTitle();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        String sql = "UPDATE Book SET quantity = quantity + ? WHERE book_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, additionalQuantity);
            ps.setInt(2, bookId);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                // Ghi log nghiệp vụ nhập kho
                logDAO.addActivityLog((int) userId,
                        "Nhập thêm " + additionalQuantity + " quyển sách: " + bookTitle + " [ID:" + bookId + "]");
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // Thêm phương thức này vào BookDAO.java

    public boolean hasBorrowRecords(int bookId) throws SQLException {
        // Truy vấn đếm số lượng bản ghi mượn dựa trên cấu trúc DB mới
        String sql = "SELECT COUNT(*) FROM borrow_records br "
                + "JOIN BookCopy bc ON br.copy_id = bc.copy_id "
                + "WHERE bc.book_id = ?";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            // Log lỗi để dễ debug nếu có sai sót tên cột
            System.err.println("Lỗi truy vấn hasBorrowRecords: " + e.getMessage());
            throw e;
        }
        return false;
    }
}
