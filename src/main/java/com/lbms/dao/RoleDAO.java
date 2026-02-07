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

    public List<Role> listAll() throws SQLException {
        String sql = "SELECT id, name FROM roles ORDER BY name";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Role> out = new ArrayList<>();
            while (rs.next()) {
                out.add(new Role(rs.getLong("id"), rs.getString("name")));
            }
            return out;
        }
    }

    public Role findByName(String name) throws SQLException {
        String sql = "SELECT id, name FROM roles WHERE name = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return new Role(rs.getLong("id"), rs.getString("name"));
            }
        }
    }
}
