package com.lbms.dao;

import com.lbms.util.DBConnection;

import java.sql.*;
import java.time.Instant;

public class PasswordResetTokenDAO {

    public void create(long userId, String tokenHash, Instant expiresAt) throws SQLException {
        String sql = "INSERT INTO password_reset_token(user_id, token, expired_at, used) VALUES(?, ?, ?, 0)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, tokenHash);
            ps.setTimestamp(3, Timestamp.from(expiresAt));
            ps.executeUpdate();
        }
    }

    public Long findValidUserIdByTokenHash(String tokenHash) throws SQLException {
        String sql = "SELECT TOP 1 user_id FROM password_reset_token " +
                "WHERE token = ? AND used = 0 AND expired_at > GETDATE() ORDER BY token_id DESC";
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
        String sql = "UPDATE password_reset_token SET used = 1 WHERE token = ? AND used = 0";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, tokenHash);
            ps.executeUpdate();
        }
    }
}
