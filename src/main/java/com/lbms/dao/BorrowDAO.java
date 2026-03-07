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
import com.lbms.util.DBConnection;

public class BorrowDAO {

    static {
        ensureRequiredColumns();
    }

    private static void ensureRequiredColumns() {
        try (Connection c = DBConnection.getConnection()) {
            if (!columnExists(c, "borrow_records", "borrow_method")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD borrow_method VARCHAR(20) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "copy_id")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD copy_id INT NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_recipient")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_recipient NVARCHAR(255) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_phone")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_phone VARCHAR(30) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_street")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_street NVARCHAR(255) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_residence")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_residence NVARCHAR(255) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_ward")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_ward NVARCHAR(255) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_district")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_district NVARCHAR(255) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "shipping_city")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD shipping_city NVARCHAR(255) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "is_paid")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD is_paid BIT NOT NULL DEFAULT 0;");
                }
            }
            if (!columnExists(c, "borrow_records", "deposit_amount")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD deposit_amount DECIMAL(18,2) NULL;");
                }
            }
            if (!columnExists(c, "borrow_records", "group_code")) {
                try (Statement stmt = c.createStatement()) {
                    stmt.executeUpdate("ALTER TABLE borrow_records ADD group_code VARCHAR(100) NULL;");
                }
            }
        } catch (SQLException e) {
            throw new RuntimeException("Không thể đồng bộ schema borrow_records", e);
        }
    }   // ← chỉ 1 dấu } đóng ensureRequiredColumns, KHÔNG có } thừa ở đây

    private static boolean columnExists(Connection c, String tableName, String columnName) throws SQLException {
        String checkSql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME=? AND COLUMN_NAME=?";
        try (PreparedStatement ps = c.prepareStatement(checkSql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long createRequest(long userId, long bookId, int quantity, String method, ShippingDetails shippingDetails)
            throws SQLException {

        double depositAmount = quantity * 50000;

        String sql = "INSERT INTO borrow_records (user_id, book_id, quantity, borrow_method, status, deposit_amount, "
                + "shipping_recipient, shipping_phone, shipping_street, shipping_residence, shipping_ward, "
                + "shipping_district, shipping_city) "
                + "VALUES (?, ?, ?, ?, 'REQUESTED', ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setInt(3, quantity);
            ps.setString(4, method);
            ps.setDouble(5, depositAmount);

            ps.setString(6, shippingDetails != null ? shippingDetails.getRecipient() : null);
            ps.setString(7, shippingDetails != null ? shippingDetails.getPhone() : null);
            ps.setString(8, shippingDetails != null ? shippingDetails.getStreet() : null);
            ps.setString(9, shippingDetails != null ? shippingDetails.getResidence() : null);
            ps.setString(10, shippingDetails != null ? shippingDetails.getWard() : null);
            ps.setString(11, shippingDetails != null ? shippingDetails.getDistrict() : null);
            ps.setString(12, shippingDetails != null ? shippingDetails.getCity() : null);

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    public long createRequest(long userId, long bookId, int quantity, String method,
                              ShippingDetails shippingDetails, String groupCode, BigDecimal depositAmount)
            throws SQLException {
        String sql = "INSERT INTO borrow_records (user_id, book_id, quantity, borrow_method, status, group_code, deposit_amount, "
                + "shipping_recipient, shipping_phone, shipping_street, shipping_residence, shipping_ward, "
                + "shipping_district, shipping_city) "
                + "VALUES (?, ?, ?, ?, 'REQUESTED', ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setInt(3, quantity);
            ps.setString(4, method);
            ps.setString(5, groupCode);
            ps.setBigDecimal(6, depositAmount);
            ps.setString(7, shippingDetails != null ? shippingDetails.getRecipient() : null);
            ps.setString(8, shippingDetails != null ? shippingDetails.getPhone() : null);
            ps.setString(9, shippingDetails != null ? shippingDetails.getStreet() : null);
            ps.setString(10, shippingDetails != null ? shippingDetails.getResidence() : null);
            ps.setString(11, shippingDetails != null ? shippingDetails.getWard() : null);
            ps.setString(12, shippingDetails != null ? shippingDetails.getDistrict() : null);
            ps.setString(13, shippingDetails != null ? shippingDetails.getCity() : null);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getLong(1) : 0;
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
        String sql = "SELECT SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE quantity END) AS c "
                + "FROM borrow_records WHERE user_id = ? AND status IN ('REQUESTED','APPROVED','BORROWED')";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    int total = rs.getInt("c");
                    return rs.wasNull() ? 0 : total;
                }
            }
        }
        return 0;
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
        
        return "SELECT br.id AS borrowing_id, br.user_id, br.book_id, br.quantity, br.copy_id, "
                + "br.borrow_date, br.due_date, br.return_date, br.status, br.fine_amount, "
                + "br.deposit_amount, br.is_paid, br.borrow_method, "
                + "u.email AS user_email, u.full_name AS user_full_name, u.phone AS user_phone, "
                + "bk.title AS book_title, bk.author AS book_author, bk.isbn AS book_isbn, bk.image AS book_image, "
                + "br.shipping_recipient, br.shipping_phone, br.shipping_street, br.shipping_residence, "
                + "br.shipping_ward, br.shipping_district, br.shipping_city "
                + "FROM borrow_records br "
                + "JOIN [User] u ON br.user_id = u.user_id "
                + "JOIN Book bk ON br.book_id = bk.book_id";
    }

    private List<BorrowRecord> mapList(ResultSet rs) throws SQLException {
        List<BorrowRecord> out = new ArrayList<>();
        while (rs.next()) out.add(mapOne(rs));
        return out;
    }

    public BorrowRecord mapOne(ResultSet rs) throws SQLException {
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getLong("borrowing_id"));

        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("user_email"));
        u.setFullName(rs.getString("user_full_name"));
        br.setUser(u);

        Book b = new Book();
        b.setId(rs.getLong("book_id"));
        b.setTitle(rs.getString("book_title"));
        b.setAuthor(rs.getString("book_author"));
        b.setImage(rs.getString("book_image"));
        br.setBook(b);

        Date bd = rs.getDate("borrow_date");
        br.setBorrowDate(bd == null ? null : bd.toLocalDate());

        Date rd = rs.getDate("return_date");
        br.setReturnDate(rd == null ? null : rd.toLocalDate());

        Date dd = rs.getDate("due_date");
        br.setDueDate(dd == null ? null : dd.toLocalDate());

        br.setStatus(rs.getString("status"));
        br.setQuantity(rs.getInt("quantity"));
        br.setFineAmount(rs.getBigDecimal("fine_amount"));
        br.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        br.setPaid(rs.getBoolean("is_paid"));
        br.setBorrowMethod(rs.getString("borrow_method"));

        ShippingDetails shipping = new ShippingDetails();
        shipping.setRecipient(rs.getString("shipping_recipient"));
        shipping.setPhone(rs.getString("shipping_phone"));
        shipping.setStreet(rs.getString("shipping_street"));
        shipping.setResidence(rs.getString("shipping_residence"));
        shipping.setWard(rs.getString("shipping_ward"));
        shipping.setDistrict(rs.getString("shipping_district"));
        shipping.setCity(rs.getString("shipping_city"));
        if ((shipping.getRecipient() != null && !shipping.getRecipient().isBlank())
                || (shipping.getPhone() != null && !shipping.getPhone().isBlank())
                || (shipping.getStreet() != null && !shipping.getStreet().isBlank())
                || (shipping.getResidence() != null && !shipping.getResidence().isBlank())
                || (shipping.getWard() != null && !shipping.getWard().isBlank())
                || (shipping.getDistrict() != null && !shipping.getDistrict().isBlank())
                || (shipping.getCity() != null && !shipping.getCity().isBlank())) {
            br.setShippingDetails(shipping);
        }

        String userPhone = rs.getString("user_phone");
        if (userPhone != null && !userPhone.isBlank()) {
            br.getUser().setPhone(userPhone);
        }

        long cid = rs.getLong("copy_id");
        if (cid > 0) {
            BookCopy bc = new BookCopy();
            bc.setCopyId((int) cid);
            br.setBookCopy(bc);
        }

        return br;
    }

    public List<BorrowRecord> listOverdue() throws SQLException {
        String sql = baseSelect()
                + " WHERE br.status = 'BORROWED' AND br.due_date < GETDATE() ORDER BY br.due_date ASC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    public List<BorrowRecord> listUnpaidFinesByUser(long userId) throws SQLException {
        String sql = baseSelect()
                + " WHERE br.user_id = ? AND br.fine_amount > 0 AND br.is_paid = 0 ORDER BY br.due_date ASC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public List<BorrowRecord> listFineHistoryByUser(long userId) throws SQLException {
        String sql = baseSelect()
                + " WHERE br.user_id = ? AND br.fine_amount > 0 ORDER BY br.return_date DESC, br.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public void markFinePaid(long id) throws SQLException {
        String sql = "UPDATE borrow_records SET is_paid = 1 WHERE id = ? AND fine_amount > 0";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    public List<BorrowRecord> listByMethod(String method) throws SQLException {
        String sql = baseSelect() + " WHERE br.borrow_method = ? ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, method);
            try (ResultSet rs = ps.executeQuery()) {
                List<BorrowRecord> out = new ArrayList<>();
                while (rs.next()) out.add(mapOne(rs));
                return out;
            }
        }
    }
}