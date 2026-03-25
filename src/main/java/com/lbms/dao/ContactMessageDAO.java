package com.lbms.dao;

import com.lbms.model.ContactMessage;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ContactMessageDAO {

    public ContactMessageDAO() {
        createTableIfNotExists();
    }

    private void createTableIfNotExists() {
        String sql = "IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='contact_messages' AND xtype='U') " +
                     "CREATE TABLE contact_messages (" +
                     "    id INT IDENTITY(1,1) PRIMARY KEY," +
                     "    full_name NVARCHAR(100) NOT NULL," +
                     "    email VARCHAR(255) NOT NULL," +
                     "    phone VARCHAR(20) NOT NULL," +
                     "    feedback_type NVARCHAR(50) NOT NULL," +
                     "    message NVARCHAR(MAX) NOT NULL," +
                     "    status VARCHAR(20) DEFAULT 'PENDING'," +
                     "    created_at DATETIME DEFAULT GETDATE()" +
                     ")";
        try (Connection c = DBConnection.getConnection();
             Statement stmt = c.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            // Log or ignore if already exists/fails
            System.err.println("Error initializing contact_messages table: " + e.getMessage());
        }
    }

    public List<ContactMessage> findAll() throws SQLException {
        return findByFilter("all");
    }

    public List<ContactMessage> findByEmailAndFilter(String email, String filter) throws SQLException {
        String sql = "SELECT * FROM contact_messages WHERE email = ? ";
        if ("pending".equals(filter)) {
            sql += "AND status = 'PENDING' ";
        } else if ("resolved".equals(filter)) {
            sql += "AND status IN ('RESOLVED', 'IGNORED') ";
        } else if ("cancelled".equals(filter)) {
            sql += "AND status IN ('CANCELLED', 'CLOSED') ";
        }
        sql += "ORDER BY created_at DESC";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                List<ContactMessage> out = new ArrayList<>();
                while (rs.next()) {
                    out.add(map(rs));
                }
                return out;
            }
        }
    }

    public List<ContactMessage> findByFilter(String filter) throws SQLException {
        String sql = "SELECT * FROM contact_messages ";
        if ("pending".equals(filter)) {
            sql += "WHERE status = 'PENDING' ";
        } else if ("resolved".equals(filter)) {
            sql += "WHERE status != 'PENDING' ";
        }
        sql += "ORDER BY created_at DESC";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<ContactMessage> out = new ArrayList<>();
            while (rs.next()) {
                out.add(map(rs));
            }
            return out;
        }
    }

    public ContactMessage findById(int id) throws SQLException {
        String sql = "SELECT * FROM contact_messages WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return map(rs);
                return null;
            }
        }
    }

    public int create(ContactMessage msg) throws SQLException {
        String sql = "INSERT INTO contact_messages (full_name, email, phone, feedback_type, message, status) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, msg.getFullName());
            ps.setString(2, msg.getEmail());
            ps.setString(3, msg.getPhone());
            ps.setString(4, msg.getFeedbackType());
            ps.setString(5, msg.getMessage());
            ps.setString(6, msg.getStatus());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
                return 0;
            }
        }
    }

    public void updateStatus(int id, String status) throws SQLException {
        String sql = "UPDATE contact_messages SET status = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    public void updateMessage(int id, String feedbackType, String message) throws SQLException {
        String sql = "UPDATE contact_messages SET feedback_type = ?, message = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, feedbackType);
            ps.setString(2, message);
            ps.setInt(3, id);
            ps.executeUpdate();
        }
    }

    private ContactMessage map(ResultSet rs) throws SQLException {
        ContactMessage msg = new ContactMessage();
        msg.setId(rs.getInt("id"));
        msg.setFullName(rs.getString("full_name"));
        msg.setEmail(rs.getString("email"));
        msg.setPhone(rs.getString("phone"));
        msg.setFeedbackType(rs.getString("feedback_type"));
        msg.setMessage(rs.getString("message"));
        msg.setStatus(rs.getString("status"));
        Timestamp ts = rs.getTimestamp("created_at");
        if(ts != null) msg.setCreatedAt(ts.toLocalDateTime());
        return msg;
    }
}
