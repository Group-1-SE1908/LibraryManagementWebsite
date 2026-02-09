package com.lbms.controller;

import com.lbms.dao.BookDAO;
import com.lbms.dao.CategoryDAO;
import com.lbms.model.Book;
import com.lbms.model.Category;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = { "/", "/home" })
public class HomeController extends HttpServlet {
    private BookDAO bookDAO;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        this.bookDAO = new BookDAO();
        this.categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            if ("/".equals(path) || "/home".equals(path)) {
                handleHome(req, resp);
            } else {
                resp.sendError(404);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleHome(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        // Get featured books (latest 6 books)
        List<Book> featuredBooks = bookDAO.search(null);
        if (featuredBooks.size() > 6) {
            featuredBooks = featuredBooks.subList(0, 6);
        }

        // Get categories
        List<Category> categories = categoryDAO.listAll();

        req.setAttribute("featuredBooks", featuredBooks);
        req.setAttribute("categories", categories);
        req.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(req, resp);
    }
}
