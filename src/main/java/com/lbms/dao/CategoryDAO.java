package com.lbms.dao;

import com.lbms.model.Category;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    public List<Category> listAll() throws SQLException {
        String sql = "SELECT category_id AS id, category_name AS name FROM Category ORDER BY category_id DESC";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            List<Category> out = new ArrayList<>();
            while (rs.next()) {
                out.add(mapCategory(rs));
            }
            return out;
        }
    }

    public Category findById(long id) throws SQLException {
        String sql = "SELECT category_id AS id, category_name AS name FROM Category WHERE category_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next())
                    return null;
                return mapCategory(rs);
            }
        }
    }

    public long create(Category cat) throws SQLException {
        String sql = "INSERT INTO Category(category_name) VALUES(?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, cat.getName());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getLong(1);
                return 0;
            }
        }
    }

    public void update(Category cat) throws SQLException {
        String sql = "UPDATE Category SET category_name=? WHERE category_id=?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, cat.getName());
            ps.setLong(2, cat.getId());
            ps.executeUpdate();
        }
    }

    public void delete(long id) throws SQLException {
        String sql = "DELETE FROM Category WHERE category_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    public int countBooksByCategory(long categoryId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM Book WHERE category_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, categoryId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("count");
                }
                return 0;
            }
        }
    }

    private Category mapCategory(ResultSet rs) throws SQLException {
        Category cat = new Category();
        cat.setId(rs.getLong("id"));
        cat.setName(rs.getString("name"));
        return cat;
    }
}
