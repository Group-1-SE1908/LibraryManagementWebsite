package com.lbms.dao;

import com.lbms.model.Role;
import com.lbms.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class RoleDAO {

    public List<Role> getAllRoles() throws SQLException {
        List<Role> roles = new ArrayList<>();
        String sql = "SELECT role_id, role_name FROM Role ORDER BY role_name ASC";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Role role = new Role(
                        rs.getInt("role_id"),
                        rs.getString("role_name"));
                roles.add(role);
            }

        }
        return roles;
    }

    public Role getRoleById(int roleId) throws SQLException {
        String sql = "SELECT role_id, role_name FROM Role WHERE role_id = ?";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setInt(1, roleId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Role(
                            rs.getInt("role_id"),
                            rs.getString("role_name"));
                }
            }
        }
        return null;
    }

    public boolean addRole(String roleName) throws SQLException {
        String sql = "INSERT INTO Role (role_name) VALUES (?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, roleName);
            return ps.executeUpdate() > 0;
        }
    }

    public Role getRoleByName(String roleName) throws SQLException {
        String sql = "SELECT role_id, role_name FROM Role WHERE role_name = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Role(
                            rs.getLong("role_id"),
                            rs.getString("role_name"));
                }
            }
        }
        return null;
    }

    public boolean isRoleNameExists(String roleName) throws SQLException {
        String sql = "SELECT COUNT(*) FROM Role WHERE role_name = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, roleName);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
}
