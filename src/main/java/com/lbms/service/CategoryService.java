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

    public List<Category> listAllCategories() throws SQLException {
        return categoryDAO.listAll();
    }

    public Category getCategoryById(long id) throws SQLException {
        return categoryDAO.findById(id);
    }

    public long createCategory(Category category) throws SQLException {
        if (category.getName() == null || category.getName().isBlank()) {
            throw new IllegalArgumentException("Tên danh mục không được để trống");
        }
        String trimmed = category.getName().trim();
        if (trimmed.length() > 100) {
            throw new IllegalArgumentException("Tên danh mục không được vượt quá 100 ký tự");
        }
        if (categoryDAO.existsByName(trimmed)) {
            throw new IllegalArgumentException("Danh mục \"" + trimmed + "\" đã tồn tại");
        }
        category.setName(trimmed);
        return categoryDAO.create(category);
    }

    public void updateCategory(Category category) throws SQLException {
        if (category.getId() <= 0) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ");
        }
        if (category.getName() == null || category.getName().isBlank()) {
            throw new IllegalArgumentException("Tên danh mục không được để trống");
        }
        String trimmed = category.getName().trim();
        if (trimmed.length() > 100) {
            throw new IllegalArgumentException("Tên danh mục không được vượt quá 100 ký tự");
        }
        Category existing = categoryDAO.findById(category.getId());
        if (existing == null) {
            throw new IllegalArgumentException("Danh mục không tồn tại");
        }
        if (categoryDAO.existsByNameExcludingId(trimmed, category.getId())) {
            throw new IllegalArgumentException("Danh mục \"" + trimmed + "\" đã tồn tại");
        }
        category.setName(trimmed);
        categoryDAO.update(category);
    }

    public void deleteCategory(long id) throws SQLException {
        if (id <= 0) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ");
        }
        if (categoryDAO.findById(id) == null) {
            throw new IllegalArgumentException("Danh mục không tồn tại");
        }
        int bookCount = categoryDAO.countBooksByCategory(id);
        if (bookCount > 0) {
            throw new IllegalArgumentException("Không thể xóa danh mục này vì đang có " + bookCount
                    + " cuốn sách sử dụng danh mục này. Vui lòng xóa hoặc cập nhật các cuốn sách trước.");
        }
        categoryDAO.delete(id);
    }
}
