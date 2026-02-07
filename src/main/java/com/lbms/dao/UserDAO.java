package com.lbms.dao;

import com.lbms.model.Role;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public List<User> listAll() throws SQLException {
        String sql = "SELECT u.user_id, u.email, u.password, u.name, u.role_id, r.role_name " +
                "FROM [User] u JOIN Role r ON u.role_id = r.role_id ORDER BY u.user_id DESC";
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
        String sql = "UPDATE [User] SET status = ? WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void updateRole(long userId, String roleName) throws SQLException {
        long roleId = getRoleIdByName(roleName);
        String sql = "UPDATE [User] SET role_id = ? WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, roleId);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.user_id, u.email, u.password, u.name, u.role_id, r.role_name " +
                "FROM [User] u JOIN Role r ON u.role_id = r.role_id WHERE u.email = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    return null;
                return mapUser(rs);
            }
        }
    }

    public User findById(long id) throws SQLException {
        String sql = "SELECT u.user_id, u.email, u.password, u.name, u.role_id, r.role_name " +
                "FROM [User] u JOIN Role r ON u.role_id = r.role_id WHERE u.user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    return null;
                return mapUser(rs);
            }
        }
    }

    public void updateFullName(long userId, String fullName) throws SQLException {
        String sql = "UPDATE [User] SET name = ? WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void updatePasswordHash(long userId, String passwordHash) throws SQLException {
        String sql = "UPDATE [User] SET password = ? WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, passwordHash);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public long createUser(String email, String passwordHash, String fullName, String roleName) throws SQLException {
        long roleId = getRoleIdByName(roleName);
        String sql = "INSERT INTO [User](email, password, name, role_id) VALUES(?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, email);
            ps.setString(2, passwordHash);
            ps.setString(3, fullName);
            ps.setLong(4, roleId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getLong(1);
                return 0;
            }
        }
    }

    private long getRoleIdByName(String roleName) throws SQLException {
        String sql = "SELECT role_id FROM Role WHERE role_name = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    throw new SQLException("Role not found: " + roleName);
                return rs.getLong("role_id");
            }
        }
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password"));
        u.setFullName(rs.getString("name"));
        Role r = new Role(rs.getLong("role_id"), rs.getString("role_name"));
        u.setRole(r);
        return u;
    }
}
