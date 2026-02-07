package com.lbms.dao;

import com.lbms.model.Role;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public List<User> listAll() throws SQLException {
        String sql = "SELECT u.id, u.email, u.password_hash, u.full_name, u.status, u.role_id, r.name AS role_name " +
                "FROM users u JOIN roles r ON u.role_id = r.id ORDER BY u.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<User> out = new ArrayList<>();
            while (rs.next()) {
                out.add(mapUser(rs));
            }
            return out;
        }
    }

    public void updateStatus(long userId, String status) throws SQLException {
        String sql = "UPDATE users SET status = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateRole(long userId, String roleName) throws SQLException {
        long roleId = getRoleIdByName(roleName);
        String sql = "UPDATE users SET role_id = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.id, u.email, u.password_hash, u.full_name, u.status, u.role_id, r.name AS role_name " +
                "FROM users u JOIN roles r ON u.role_id = r.id WHERE u.email = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapUser(rs);
            }
        }
    }

    public User findById(long id) throws SQLException {
        String sql = "SELECT u.id, u.email, u.password_hash, u.full_name, u.status, u.role_id, r.name AS role_name " +
                "FROM users u JOIN roles r ON u.role_id = r.id WHERE u.id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapUser(rs);
            }
        }
    }

    public void updateFullName(long userId, String fullName) throws SQLException {
        String sql = "UPDATE users SET full_name = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void updatePasswordHash(long userId, String passwordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public long createUser(String email, String passwordHash, String fullName, String roleName) throws SQLException {
        long roleId = getRoleIdByName(roleName);
        String sql = "INSERT INTO users(email, password_hash, full_name, status, role_id) VALUES(?, ?, ?, 'ACTIVE', ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setLong(4, roleId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
                return 0;
            }
        }
    }

    private long getRoleIdByName(String roleName) throws SQLException {
        String sql = "SELECT id FROM roles WHERE name = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) throw new SQLException("Role not found: " + roleName);
                return rs.getLong("id");
            }
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getLong("id"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setFullName(rs.getString("full_name"));
        u.setStatus(rs.getString("status"));
        Role r = new Role(rs.getLong("role_id"), rs.getString("role_name"));
        u.setRole(r);
        return u;
    }
}
