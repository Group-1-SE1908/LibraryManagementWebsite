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
import com.lbms.model.ShippingDetails;
import com.lbms.model.User;
import com.lbms.model.UserBorrowingSummary;
import com.lbms.util.DBConnection;

public class LibrarianBorrowDAO {

    static {
        ensureBorrowMethodColumn();
    }

    private String baseSelect(BorrowSchemaSupport.BorrowSchemaInfo schema) {
        return "SELECT br.id AS borrowing_id, br.user_id, br.book_id, "
                + BorrowSchemaSupport.copyIdExpression(schema) + ", "
                + "br.borrow_date, br.due_date, br.return_date, "
                + BorrowSchemaSupport.quantityExpression(schema, "borrow_qty") + ", "
                + "br.status AS borrow_status, br.fine_amount, "
                + BorrowSchemaSupport.borrowMethodExpression(schema) + ", "
                + BorrowSchemaSupport.groupCodeExpression(schema) + ", "
                + BorrowSchemaSupport.shippingRecipientExpression(schema) + ", "
                + BorrowSchemaSupport.shippingPhoneExpression(schema) + ", "
                + BorrowSchemaSupport.shippingStreetExpression(schema) + ", "
                + BorrowSchemaSupport.shippingResidenceExpression(schema) + ", "
                + BorrowSchemaSupport.shippingWardExpression(schema) + ", "
                + BorrowSchemaSupport.shippingDistrictExpression(schema) + ", "
                + BorrowSchemaSupport.shippingCityExpression(schema) + ", "
                + "u.email AS user_email, u.full_name AS user_full_name, u.phone AS user_phone, u.address AS user_address, "
                + "bk.title AS book_title, bk.author AS book_author, bk.isbn AS book_isbn, bk.image AS book_image, "
                + "bk.quantity AS book_qty_stock, bc.barcode AS book_barcode "
                + "FROM borrow_records br "
                + "JOIN [User] u ON br.user_id = u.user_id "
                + "JOIN Book bk ON br.book_id = bk.book_id "
                + "LEFT JOIN BookCopy bc ON br.copy_id = bc.copy_id";
    }

    // --- CÁC PHƯƠNG THỨC SAO CHÉP TỪ BorrowDAO VÀ TỐI ƯU ---
    public long createRequest(long userId, long bookId, String method, int qty, String groupCode) throws SQLException {
        String sql = "INSERT INTO borrow_records(user_id, book_id, borrow_date, status, borrow_method, quantity,group_code) "
                + "VALUES(?, ?, GETDATE(), 'REQUESTED', ?, ?, ?)";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setString(3, method);
            ps.setInt(4, qty);
            ps.setString(5, groupCode);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    public List<BorrowRecord> listAll() throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " ORDER BY br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public List<BorrowRecord> listByUser(long userId) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " WHERE br.user_id = ? ORDER BY br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }

    public int countActiveBorrows(long userId) throws SQLException {
        String sql = "SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status IN ('APPROVED','BORROWED')";
        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("c");
            }
        }
    }

    public BorrowRecord findById(long id) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " WHERE br.id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    return rs.next() ? mapOne(rs) : null;
                }
            }
        }
    }

    public void updateStatus(long id, String status) throws SQLException {
        String sql = "UPDATE borrow_records SET status = ? WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void markReturned(long id, LocalDate returnDate, BigDecimal fineAmount) throws SQLException {
        String sql = "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=? WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(returnDate));
            ps.setBigDecimal(2, fineAmount);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    public List<BorrowRecord> listOverdue() throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema)
                    + " WHERE br.status = 'BORROWED' AND br.due_date < GETDATE() ORDER BY br.due_date ASC";
            try (PreparedStatement ps = connection.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public List<BorrowRecord> listByMethod(String method) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            if (!schema.hasBorrowMethod()) {
                return new ArrayList<>();
            }
            String sql = baseSelect(schema) + " WHERE br.borrow_method = ? ORDER BY br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, method);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }

    public List<BorrowRecord> searchBorrowings(String q, String status, String method) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            if (method != null && !method.isBlank() && !schema.hasBorrowMethod()) {
                return new ArrayList<>();
            }

            StringBuilder sql = new StringBuilder(baseSelect(schema)).append(" WHERE 1=1 ");
            if (q != null && !q.isBlank()) {
                sql.append("AND (u.full_name LIKE ? OR bk.title LIKE ?) ");
            }
            if (status != null && !status.isBlank()) {
                sql.append("AND br.status = ? ");
            }
            if (method != null && !method.isBlank()) {
                sql.append("AND br.borrow_method = ? ");
            }
            sql.append("ORDER BY br.id DESC");

            try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
                int idx = 1;
                if (q != null && !q.isBlank()) {
                    String like = "%" + q.trim() + "%";
                    ps.setString(idx++, like);
                    ps.setString(idx++, like);
                }
                if (status != null && !status.isBlank()) {
                    ps.setString(idx++, status);
                }
                if (method != null && !method.isBlank()) {
                    ps.setString(idx++, method);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
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

        User user = new User();
        user.setId(rs.getLong("user_id"));
        user.setEmail(rs.getString("user_email"));
        user.setFullName(rs.getString("user_full_name"));
        user.setPhone(rs.getString("user_phone"));
        user.setAddress(rs.getString("user_address"));
        br.setUser(user);

        Book book = new Book();
        book.setId(rs.getLong("book_id"));
        book.setTitle(rs.getString("book_title"));
        book.setAuthor(rs.getString("book_author"));
        book.setIsbn(rs.getString("book_isbn"));
        book.setImage(rs.getString("book_image"));
        book.setQuantity(rs.getInt("book_qty_stock"));
        br.setBook(book);

        br.setBorrowDate(rs.getDate("borrow_date") != null ? rs.getDate("borrow_date").toLocalDate() : null);
        br.setDueDate(rs.getDate("due_date") != null ? rs.getDate("due_date").toLocalDate() : null);
        br.setReturnDate(rs.getDate("return_date") != null ? rs.getDate("return_date").toLocalDate() : null);

        br.setQuantity(rs.getInt("borrow_qty"));
        br.setStatus(rs.getString("borrow_status"));
        br.setFineAmount(rs.getBigDecimal("fine_amount"));
        br.setBorrowMethod(rs.getString("borrow_method"));
        br.setGroupCode(rs.getString("group_code"));

        ShippingDetails shipping = new ShippingDetails();
        shipping.setRecipient(rs.getString("shipping_recipient"));
        shipping.setPhone(rs.getString("shipping_phone"));
        shipping.setStreet(rs.getString("shipping_street"));
        shipping.setResidence(rs.getString("shipping_residence"));
        shipping.setWard(rs.getString("shipping_ward"));
        shipping.setDistrict(rs.getString("shipping_district"));
        shipping.setCity(rs.getString("shipping_city"));
        br.setShippingDetails(shipping);

        long copyId = rs.getLong("copy_id");
        if (copyId > 0) {
            BookCopy bookCopy = new BookCopy();
            bookCopy.setCopyId((int) copyId);
            bookCopy.setBarcode(rs.getString("book_barcode"));
            br.setBookCopy(bookCopy);
        }
        return br;
    }

    private static void ensureBorrowMethodColumn() {
        try (Connection connection = DBConnection.getConnection()) {
            if (!BorrowSchemaSupport.columnExists(connection, "borrow_records", "borrow_method")) {
                try (Statement stmt = connection.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD borrow_method VARCHAR(20) NULL;");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể đồng bộ schema", e);
        }
    }

    public UserBorrowingSummary getUserSummary(long userId) throws SQLException {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM borrow_records WHERE user_id = ? AND status = 'RECEIVED') as current_borrowed, "
                + "(SELECT CASE WHEN EXISTS (SELECT 1 FROM borrow_records WHERE user_id = ? AND status = 'RECEIVED' AND due_date < GETDATE()) THEN 1 ELSE 0 END) as has_overdue, "
                + "(SELECT ISNULL(SUM(fine_amount), 0) FROM borrow_records WHERE user_id = ? AND is_paid = 0) as unpaid_fines, "
                + "(SELECT COUNT(*) FROM borrow_records WHERE user_id = ?) as total_history, "
                + "(SELECT COUNT(*) FROM borrow_records WHERE user_id = ? AND (status = 'OVERDUE' OR (return_date > due_date))) as overdue_count";

        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) {
                ps.setLong(i, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                UserBorrowingSummary summary = new UserBorrowingSummary();
                if (rs.next()) {
                    summary.setCurrentBorrowed(rs.getInt("current_borrowed"));
                    summary.setHasOverdue(rs.getInt("has_overdue") == 1);
                    summary.setUnpaidFines(rs.getBigDecimal("unpaid_fines"));
                    summary.setTotalHistory(rs.getInt("total_history"));
                    summary.setOverdueCount(rs.getInt("overdue_count"));
                }
                return summary;
            }
        }
    }

    public void rejectRequest(long id, String reason) throws SQLException {
        String sql = "UPDATE borrow_records SET status = 'REJECTED', reject_reason = ? WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public List<BorrowRecord> findByGroupCode(String groupCode) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            if (!schema.hasGroupCode()) {
                return new ArrayList<>();
            }
            String sql = baseSelect(schema) + " WHERE br.group_code = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, groupCode);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }
}