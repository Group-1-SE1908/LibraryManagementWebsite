package com.lbms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.lbms.model.RenewalRequest;
import com.lbms.util.DBConnection;

public class RenewalRequestDAO {

    public long createRequest(long borrowId, long userId, String reason, String contactName, String contactPhone,
            String contactEmail) throws SQLException {
        String sql = "INSERT INTO renewal_requests (borrow_id, user_id, reason, contact_name, contact_phone, contact_email) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, borrowId);
            ps.setLong(2, userId);
            ps.setString(3, reason);
            ps.setString(4, contactName);
            ps.setString(5, contactPhone);
            ps.setString(6, contactEmail);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return 0;
    }

    public boolean existsPendingForBorrow(long borrowId) throws SQLException {
        String sql = "SELECT 1 FROM renewal_requests WHERE borrow_id = ? AND status = 'PENDING'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<RenewalRequest> listByBorrowId(long borrowId) throws SQLException {
        List<RenewalRequest> out = new ArrayList<>();
        String sql = "SELECT * FROM renewal_requests WHERE borrow_id = ? ORDER BY requested_at DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RenewalRequest request = new RenewalRequest();
                    request.setId(rs.getLong("id"));
                    request.setBorrowId(rs.getLong("borrow_id"));
                    request.setUserId(rs.getLong("user_id"));
                    request.setReason(rs.getString("reason"));
                    request.setContactName(rs.getString("contact_name"));
                    request.setContactPhone(rs.getString("contact_phone"));
                    request.setContactEmail(rs.getString("contact_email"));
                    request.setStatus(rs.getString("status"));
                    java.sql.Timestamp ts = rs.getTimestamp("requested_at");
                    if (ts != null) {
                        request.setRequestedAt(ts.toLocalDateTime());
                    }
                    out.add(request);
                }
            }
        }
        return out;
    }

    public int cancelPendingForBorrow(long borrowId) throws SQLException {
        String sql = "UPDATE renewal_requests SET status = 'CANCELLED' WHERE borrow_id = ? AND status = 'PENDING'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            return ps.executeUpdate();
        }
    }
}
