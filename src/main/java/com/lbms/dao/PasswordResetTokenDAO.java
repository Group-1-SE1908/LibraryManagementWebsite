package com.lbms.dao;

import com.lbms.util.DBConnection;

import java.sql.*;
import java.time.Instant;

public class PasswordResetTokenDAO {

    public void create(long userId, String tokenHash, Instant expiresAt) throws SQLException {
        String sql = "INSERT INTO password_reset_tokens(user_id, token_hash, expires_at, used_at) VALUES(?, ?, ?, NULL)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, tokenHash);
            ps.setTimestamp(3, Timestamp.from(expiresAt));
            ps.executeUpdate();
        }
    }

    public Long findValidUserIdByTokenHash(String tokenHash) throws SQLException {
        String sql = "SELECT TOP 1 user_id FROM password_reset_tokens " +
                "WHERE token_hash = ? AND used_at IS NULL AND expires_at > CURRENT_TIMESTAMP ORDER BY id DESC";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    return null;
                return rs.getLong("user_id");
            }
        }
    }

    public void markUsed(String tokenHash) throws SQLException {
        String sql = "UPDATE password_reset_tokens SET used_at = CURRENT_TIMESTAMP WHERE token_hash = ? AND used_at IS NULL";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ps.executeUpdate();
        }
    }
}
