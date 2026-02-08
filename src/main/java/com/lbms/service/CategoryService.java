package com.lbms.service;

import com.lbms.dao.CategoryDAO;
import com.lbms.model.Category;
import java.sql.SQLException;
import java.util.List;

public class CategoryService {
    private final CategoryDAO categoryDAO;

    public CategoryService() {
        this.categoryDAO = new CategoryDAO();
    }

    public List<Category> listAll() throws SQLException {
        return categoryDAO.listAll();
    }
    
    public Category findById(int id) throws SQLException {
        return categoryDAO.findById(id);
    }
}