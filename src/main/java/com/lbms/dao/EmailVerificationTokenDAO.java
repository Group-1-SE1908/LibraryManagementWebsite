package com.lbms.dao;

import com.lbms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;

public class EmailVerificationTokenDAO {

    public void create(long userId, String codeHash, Instant expiresAt) throws SQLException {
        String sql = "INSERT INTO email_verification_token(user_id, code, expired_at) VALUES(?, ?, ?)";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, codeHash);
            ps.setTimestamp(3, Timestamp.from(expiresAt));
            ps.executeUpdate();
        }
    }

    public boolean consumeCode(long userId, String codeHash) throws SQLException {
        String sql = "UPDATE email_verification_token SET used = 1 WHERE user_id = ? AND code = ? AND used = 0 AND expired_at > GETDATE()";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, codeHash);
            return ps.executeUpdate() > 0;
        }
    }

    public void invalidateTokens(long userId) throws SQLException {
        String sql = "UPDATE email_verification_token SET used = 1 WHERE user_id = ? AND used = 0";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.executeUpdate();
        }
    }
}
