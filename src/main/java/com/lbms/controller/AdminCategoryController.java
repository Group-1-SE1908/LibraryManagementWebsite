package com.lbms.controller;

import com.lbms.model.Category;
import com.lbms.service.CategoryService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = { "/admin/categories", "/admin/categories/create", "/admin/categories/update",
        "/admin/categories/delete" })
public class AdminCategoryController extends HttpServlet {
    private CategoryService categoryService;

    @Override
    public void init() {
        this.categoryService = new CategoryService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        if (!"/admin/categories".equals(path)) {
            resp.sendError(404);
            return;
        }

        try {
            List<Category> categories = categoryService.listAllCategories();
            req.setAttribute("categories", categories);

            Object flash = req.getSession().getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash);
                req.getSession().removeAttribute("flash");
            }

            req.getRequestDispatcher("/WEB-INF/views/admin/category_list.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        req.setCharacterEncoding("UTF-8");

        try {
            switch (path) {
                case "/admin/categories/create":
                    handleCreate(req, resp);
                    break;
                case "/admin/categories/update":
                    handleUpdate(req, resp);
                    break;
                case "/admin/categories/delete":
                    handleDelete(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/admin/categories");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String name = req.getParameter("name");
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Tên danh mục không được để trống");
        }

        Category category = new Category();
        category.setName(name.trim());
        categoryService.createCategory(category);

        req.getSession().setAttribute("flash", "Tạo danh mục thành công");
        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String idStr = req.getParameter("id");
        String name = req.getParameter("name");

        if (idStr == null || idStr.isBlank()) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ");
        }
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("Tên danh mục không được để trống");
        }

        try {
            long id = Long.parseLong(idStr);
            Category category = new Category();
            category.setId(id);
            category.setName(name.trim());
            categoryService.updateCategory(category);

            req.getSession().setAttribute("flash", "Cập nhật danh mục thành công");
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }

    private void handleDelete(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String idStr = req.getParameter("id");

        if (idStr == null || idStr.isBlank()) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ");
        }

        try {
            long id = Long.parseLong(idStr);
            categoryService.deleteCategory(id);
            req.getSession().setAttribute("flash", "Xóa danh mục thành công");
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("ID danh mục không hợp lệ");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }
}
