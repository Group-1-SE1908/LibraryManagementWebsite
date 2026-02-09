package com.lbms.dao;

import com.lbms.model.Role;
import com.lbms.model.User;
import com.lbms.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {

    public boolean updateUser(User user) throws SQLException {
        String sql = "UPDATE [User] SET name = ?, email = ?, password = ?, role_id = ? WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setLong(4, user.getRole().getId());
            ps.setLong(5, user.getId());
            return ps.executeUpdate() > 0;
        }
    }

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT u.user_id, u.email, u.password, u.name, u.status, u.role_id, r.role_name " +
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
        String sql = "SELECT u.user_id, u.email, u.password, u.name, u.status, u.role_id, r.role_name " +
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
        String sql = "INSERT INTO [User](email, password, name, status, role_id) VALUES(?, ?, ?, 'ACTIVE', ?)";
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

    public boolean createUserAccount(User user) throws SQLException {
        String sql = "INSERT INTO [User] (name, email, password, role_id, status) VALUES (?, ?, ?, ?, 'ACTIVE')";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPasswordHash());
            ps.setLong(4, user.getRole().getId());
            return ps.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(long userId, String status) throws SQLException {
        String sql = "UPDATE [User] SET status = ? WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, userId);
            return ps.executeUpdate() > 0;
        }
    }

    public boolean isEmailExists(String email, int excludeUserId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM [User] WHERE email = ? AND user_id != ?";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, email);
            ps.setInt(2, excludeUserId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    public List<User> getAllUsers(int page, int pageSize, String keyword) throws SQLException {
        List<User> list = new ArrayList<>();
        int offset = (page - 1) * pageSize;
        String sql = "SELECT u.user_id, u.name, u.email, u.password, u.status, u.role_id, r.role_name " +
                "FROM [User] u LEFT JOIN Role r ON u.role_id = r.role_id " +
                "WHERE u.name LIKE ? OR u.email LIKE ? " +
                "ORDER BY u.user_id ASC " +
                "OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
            ps.setInt(3, offset);
            ps.setInt(4, pageSize);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        }
        return list;
    }

    public int getTotalUserCount(String keyword) {
        String sql = "SELECT COUNT(*) FROM [User] WHERE name LIKE ? OR email LIKE ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            String searchPattern = "%" + keyword + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getLong("user_id"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password"));
        u.setFullName(rs.getString("name"));
        u.setStatus(rs.getString("status"));
        Role r = new Role(rs.getLong("role_id"), rs.getString("role_name"));
        u.setRole(r);
        return u;
    }
}
