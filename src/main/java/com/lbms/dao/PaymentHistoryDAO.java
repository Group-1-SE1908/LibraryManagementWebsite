package com.lbms.dao;

import com.lbms.model.PaymentHistory;
import com.lbms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class PaymentHistoryDAO {

    /**
     * Ensure the payment_history table exists, auto-creating it if needed.
     * This lets the app run even before the DBA applies schema.sql updates.
     */
    public void ensureTableExists() {
        String ddl = "IF OBJECT_ID('payment_history','U') IS NULL "
                + "CREATE TABLE payment_history ("
                + "  id             BIGINT IDENTITY(1,1) PRIMARY KEY,"
                + "  user_id        INT            NOT NULL,"
                + "  payment_method VARCHAR(20)    NOT NULL,"
                + "  payment_type   VARCHAR(30)    NOT NULL,"
                + "  amount         DECIMAL(14,2)  NOT NULL,"
                + "  description    NVARCHAR(255)  NULL,"
                + "  reference      VARCHAR(255)   NULL,"
                + "  status         VARCHAR(20)    NOT NULL DEFAULT 'SUCCESS',"
                + "  borrow_id      BIGINT         NULL,"
                + "  created_at     DATETIME       NOT NULL DEFAULT GETDATE()"
                + ")";
        try (Connection c = DBConnection.getConnection(); Statement st = c.createStatement()) {
            st.execute(ddl);
        } catch (SQLException e) {
            System.err.println("[PaymentHistoryDAO] ensureTableExists error: " + e.getMessage());
        }
    }

    public void save(PaymentHistory ph) throws SQLException {
        ensureTableExists();
        String sql = "INSERT INTO payment_history "
                + "(user_id, payment_method, payment_type, amount, description, reference, status, borrow_id) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, ph.getUserId());
            ps.setString(2, ph.getPaymentMethod());
            ps.setString(3, ph.getPaymentType());
            ps.setBigDecimal(4, ph.getAmount());
            ps.setString(5, ph.getDescription());
            ps.setString(6, ph.getReference());
            ps.setString(7, ph.getStatus() != null ? ph.getStatus() : PaymentHistory.STATUS_SUCCESS);
            if (ph.getBorrowId() != null) {
                ps.setLong(8, ph.getBorrowId());
            } else {
                ps.setNull(8, Types.BIGINT);
            }
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    ph.setId(rs.getLong(1));
            }
        }
    }

    public List<PaymentHistory> findByUserId(long userId) throws SQLException {
        ensureTableExists();
        String sql = "SELECT id, user_id, payment_method, payment_type, amount, description, reference, status, borrow_id, created_at "
                + "FROM payment_history "
                + "WHERE user_id = ? "
                + "ORDER BY created_at DESC";
        List<PaymentHistory> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(map(rs));
            }
        }
        return list;
    }

    private PaymentHistory map(ResultSet rs) throws SQLException {
        PaymentHistory ph = new PaymentHistory();
        ph.setId(rs.getLong("id"));
        ph.setUserId(rs.getLong("user_id"));
        ph.setPaymentMethod(rs.getString("payment_method"));
        ph.setPaymentType(rs.getString("payment_type"));
        BigDecimal amt = rs.getBigDecimal("amount");
        ph.setAmount(amt != null ? amt : BigDecimal.ZERO);
        ph.setDescription(rs.getString("description"));
        ph.setReference(rs.getString("reference"));
        ph.setStatus(rs.getString("status"));
        long bid = rs.getLong("borrow_id");
        if (!rs.wasNull())
            ph.setBorrowId(bid);
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null)
            ph.setCreatedAt(new Date(ts.getTime()));
        return ph;
    }
}
