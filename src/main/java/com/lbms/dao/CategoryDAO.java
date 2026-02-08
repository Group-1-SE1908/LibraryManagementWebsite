package com.lbms.dao;

import com.lbms.model.Category;
import com.lbms.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {

    // Lấy tất cả danh mục để hiển thị lên Combobox (Dropdown)
    public List<Category> listAll() throws SQLException {
        List<Category> list = new ArrayList<>();
        String sql = "SELECT category_id, category_name FROM Category ORDER BY category_id ASC";
        
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Category cat = new Category();
                cat.setCategoryId(rs.getInt("category_id"));
                cat.setCategoryName(rs.getString("category_name"));
                list.add(cat);
            }
        }
        return list;
    }
    
    // Tìm theo ID (để hiển thị tên nếu cần)
    public Category findById(int id) throws SQLException {
        String sql = "SELECT category_id, category_name FROM Category WHERE category_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new Category(rs.getInt("category_id"), rs.getString("category_name"));
                }
            }
        }
        return null;
    }
}