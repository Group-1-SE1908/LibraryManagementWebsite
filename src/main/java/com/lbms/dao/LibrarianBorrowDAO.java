package com.lbms.dao;

import com.lbms.model.*;
import com.lbms.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class LibrarianBorrowDAO {

    static {
        ensureBorrowMethodColumn();
    }

    // NÂNG CẤP: JOIN thêm bảng [User] để lấy phone/address và BookCopy để lấy barcode
    private String baseSelect() {
        return "SELECT br.id AS borrowing_id, br.user_id, br.book_id, br.copy_id, br.borrow_date, br.due_date, br.return_date, "
                + "br.status, br.fine_amount, br.borrow_method, "
                + "u.email AS user_email, u.full_name AS user_full_name, u.phone AS user_phone, u.address AS user_address, "
                + "bk.title AS book_title, bk.author AS book_author, bk.isbn AS book_isbn, bk.image AS book_image, "
                + "bc.barcode AS book_barcode "
                + "FROM borrow_records br "
                + "JOIN [User] u ON br.user_id = u.user_id "
                + "JOIN Book bk ON br.book_id = bk.book_id "
                + "LEFT JOIN BookCopy bc ON br.copy_id = bc.copy_id";
    }

    // --- CÁC PHƯƠNG THỨC SAO CHÉP TỪ BorrowDAO VÀ TỐI ƯU ---
    public long createRequest(long userId, long bookId, String method) throws SQLException {
        String sql = "INSERT INTO borrow_records(user_id, book_id, borrow_date, return_date, status, borrow_method) "
                + "VALUES(?, ?, GETDATE(), NULL, 'REQUESTED', ?)";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setString(3, method);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        }
    }

    public List<BorrowRecord> listAll() throws SQLException {
        String sql = baseSelect() + " ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    public List<BorrowRecord> listByUser(long userId) throws SQLException {
        String sql = baseSelect() + " WHERE br.user_id = ? ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public int countActiveBorrows(long userId) throws SQLException {
        String sql = "SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status IN ('APPROVED','BORROWED')";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt("c");
            }
        }
    }

    public BorrowRecord findById(long id) throws SQLException {
        String sql = baseSelect() + " WHERE br.id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapOne(rs) : null;
            }
        }
    }

    public void updateStatus(long id, String status) throws SQLException {
        String sql = "UPDATE borrow_records SET status = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void markReturned(long id, LocalDate returnDate, BigDecimal fineAmount) throws SQLException {
        String sql = "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(returnDate));
            ps.setBigDecimal(2, fineAmount);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    public List<BorrowRecord> listOverdue() throws SQLException {
        String sql = baseSelect() + " WHERE br.status = 'BORROWED' AND br.due_date < GETDATE() ORDER BY br.due_date ASC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            return mapList(rs);
        }
    }

    public List<BorrowRecord> listByMethod(String method) throws SQLException {
        String sql = baseSelect() + " WHERE br.borrow_method = ? ORDER BY br.id DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, method);
            try (ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    // --- LOGIC TÌM KIẾM TỔNG HỢP CHO THỦ THƯ ---
    public List<BorrowRecord> searchBorrowings(String q, String status, String method) throws SQLException {
        StringBuilder sql = new StringBuilder(baseSelect() + " WHERE 1=1 ");
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

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
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

    // --- ÁNH XẠ DỮ LIỆU (MAPPER) ---
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

        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("user_email"));
        u.setFullName(rs.getString("user_full_name"));
        u.setPhone(rs.getString("user_phone")); // Nâng cấp
        u.setAddress(rs.getString("user_address")); // Nâng cấp
        br.setUser(u);

        Book b = new Book();
        b.setId(rs.getLong("book_id"));
        b.setTitle(rs.getString("book_title"));
        b.setAuthor(rs.getString("book_author"));
        b.setIsbn(rs.getString("book_isbn"));
        b.setImage(rs.getString("book_image"));
        br.setBook(b);

        br.setBorrowDate(rs.getDate("borrow_date") != null ? rs.getDate("borrow_date").toLocalDate() : null);
        br.setDueDate(rs.getDate("due_date") != null ? rs.getDate("due_date").toLocalDate() : null);
        br.setReturnDate(rs.getDate("return_date") != null ? rs.getDate("return_date").toLocalDate() : null);
        br.setStatus(rs.getString("status"));
        br.setFineAmount(rs.getBigDecimal("fine_amount"));
        br.setBorrowMethod(rs.getString("borrow_method"));

        long cid = rs.getLong("copy_id");
        if (cid > 0) {
            BookCopy bc = new BookCopy();
            bc.setCopyId((int) cid);
            bc.setBarcode(rs.getString("book_barcode")); // Nâng cấp
            br.setBookCopy(bc);
        }
        return br;
    }

    private static void ensureBorrowMethodColumn() {
        String checkSql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='borrow_records' AND COLUMN_NAME='borrow_method'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(checkSql); ResultSet rs = ps.executeQuery()) {
            if (!rs.next()) {
                try (Statement stmt = c.createStatement()) {
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

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            for (int i = 1; i <= 5; i++) {
                ps.setLong(i, userId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                UserBorrowingSummary s = new UserBorrowingSummary();
                if (rs.next()) {
                    s.setCurrentBorrowed(rs.getInt("current_borrowed"));
                    s.setHasOverdue(rs.getInt("has_overdue") == 1);
                    s.setUnpaidFines(rs.getBigDecimal("unpaid_fines"));
                    s.setTotalHistory(rs.getInt("total_history"));
                    s.setOverdueCount(rs.getInt("overdue_count"));
                }
                return s;
            }
        }
    }

    public void rejectRequest(long id, String reason) throws SQLException {
        String sql = "UPDATE borrow_records SET status = 'REJECTED', reject_reason = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, reason);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

}
