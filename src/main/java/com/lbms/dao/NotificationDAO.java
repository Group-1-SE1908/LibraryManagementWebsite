package com.lbms.dao;

import com.lbms.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class NotificationDAO {

    // Hàm insert cơ bản dùng chung cho các thông báo tự động
    public void insert(long userId, String type, String title, String message) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, type, title, message, created_at) VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, message);
            ps.executeUpdate();
        }
    }

    // Gửi cho một user cụ thể (có sender)
    public void insertToUser(int receiverId, int senderId, String senderRole, String type, String title, String message)
            throws SQLException {
        String sql = "INSERT INTO notifications (user_id, sender_id, sender_role, type, title, message, is_read, sent_to_all, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, 0, 0, GETDATE())";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            ps.setInt(2, senderId);
            ps.setString(3, senderRole);
            ps.setString(4, type);
            ps.setString(5, title);
            ps.setString(6, message);
            ps.executeUpdate();
        }
    }

    // Gửi toàn hệ thống
    public void insertToAll(int senderId, String type, String title, String message) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, sender_id, sender_role, type, title, message, is_read, sent_to_all, created_at) "
                + "SELECT user_id, ?, 'ADMIN', ?, ?, ?, 0, 1, GETDATE() "
                + "FROM [User] WHERE status = 'ACTIVE' AND user_id <> ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, message);
            ps.setInt(5, senderId);
            ps.executeUpdate();
        }
    }

    // Gửi theo Role
    public int insertToRole(String targetRoleName, int senderId, String senderRole, String type, String title,
            String message) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, sender_id, sender_role, type, title, message, is_read, sent_to_all, created_at) "
                + "SELECT u.user_id, ?, ?, ?, ?, ?, 0, 1, GETDATE() "
                + "FROM [User] u INNER JOIN Role r ON u.role_id = r.role_id "
                + "WHERE r.role_name = ? AND u.status = 'ACTIVE' AND u.user_id <> ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setString(2, senderRole);
            ps.setString(3, type);
            ps.setString(4, title);
            ps.setString(5, message);
            ps.setString(6, targetRoleName);
            ps.setInt(7, senderId);
            return ps.executeUpdate();
        }
    }

    public List<Map<String, Object>> listByUser(long userId) throws SQLException {
        String sql = "SELECT TOP 50 id, type, title, message, is_read, created_at FROM notifications WHERE user_id = ? ORDER BY created_at DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(Map.of("id", rs.getLong("id"), "type", rs.getString("type"), "title", rs.getString("title"),
                        "message", rs.getString("message"), "isRead", rs.getBoolean("is_read"), "createdAt",
                        rs.getTimestamp("created_at")));
            }
        }
        return list;
    }

    public void markRead(long id, long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void markAllRead(long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.executeUpdate();
        }
    }

    public int getUnreadCount(long userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }
}