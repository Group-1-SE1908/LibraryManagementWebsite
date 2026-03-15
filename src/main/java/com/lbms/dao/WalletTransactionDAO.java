package com.lbms.dao;

import com.lbms.model.WalletTransaction;
import com.lbms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class WalletTransactionDAO {

    public void save(WalletTransaction transaction) throws SQLException {
        if (transaction == null) {
            throw new IllegalArgumentException("Transaction cannot be null");
        }
        String sql = "INSERT INTO wallet_transaction (user_id, type, source, description, amount, reference) "
                + "VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, transaction.getUserId());
            ps.setString(2, transaction.getType());
            ps.setString(3, transaction.getSource());
            ps.setString(4, transaction.getDescription());
            ps.setBigDecimal(5, transaction.getAmount());
            ps.setString(6, transaction.getReference());

            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    transaction.setTransactionId(rs.getLong(1));
                }
            }
        }
    }

    public List<WalletTransaction> findRecentForUser(long userId, int limit) throws SQLException {
        int fetchLimit = limit > 0 ? limit : 6;
        String sql = "SELECT transaction_id, user_id, type, source, description, amount, reference, created_at "
                + "FROM wallet_transaction "
                + "WHERE user_id = ? "
                + "ORDER BY created_at DESC "
                + "OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        List<WalletTransaction> history = new ArrayList<>();
        try (Connection connection = DBConnection.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setInt(2, fetchLimit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    history.add(map(rs));
                }
            }
        }
        return history;
    }

    private WalletTransaction map(ResultSet rs) throws SQLException {
        WalletTransaction tx = new WalletTransaction();
        tx.setTransactionId(rs.getLong("transaction_id"));
        tx.setUserId(rs.getLong("user_id"));
        tx.setType(rs.getString("type"));
        tx.setSource(rs.getString("source"));
        tx.setDescription(rs.getString("description"));
        BigDecimal amount = rs.getBigDecimal("amount");
        if (amount != null) {
            tx.setAmount(amount);
        }
        tx.setReference(rs.getString("reference"));
        Timestamp timestamp = rs.getTimestamp("created_at");
        if (timestamp != null) {
            tx.setCreatedAt(new Date(timestamp.getTime()));
        }
        return tx;
    }
}
