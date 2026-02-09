package com.lbms.controller;

import com.lbms.model.Book;
import com.lbms.model.Category;
import com.lbms.service.BookService;
import com.lbms.dao.CategoryDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = { "/books", "/books/new", "/books/edit", "/books/delete", "/books/detail" })
public class BookController extends HttpServlet {
    private BookService bookService;
    private CategoryDAO categoryDAO;

    @Override
    public void init() {
        this.bookService = new BookService();
        this.categoryDAO = new CategoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/books":
                    handleList(req, resp);
                    break;
                case "/books/detail":
                    handleDetail(req, resp);
                    break;
                case "/books/new":
                    req.setAttribute("mode", "create");
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                    break;
                case "/books/edit":
                    String idStr = req.getParameter("id");
                    if (idStr == null) {
                        resp.sendRedirect(req.getContextPath() + "/books");
                        return;
                    }
                    Book b = bookService.findById(Long.parseLong(idStr));
                    if (b == null) {
                        resp.sendRedirect(req.getContextPath() + "/books");
                        return;
                    }
                    req.setAttribute("mode", "edit");
                    req.setAttribute("book", b);
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                    break;
                case "/books/delete":
                    String delId = req.getParameter("id");
                    if (delId != null) {
                        bookService.delete(Long.parseLong(delId));
                    }
                    resp.sendRedirect(req.getContextPath() + "/books");
                    break;
                default:
                    resp.sendError(404);
                    break;
            }
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
                case "/books/new":
                    handleCreate(req, resp);
                    break;
                case "/books/edit":
                    handleUpdate(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            if ("/books/new".equals(path)) {
                req.setAttribute("mode", "create");
            } else {
                req.setAttribute("mode", "edit");
            }
            req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String q = req.getParameter("q");
        String categoryIdStr = req.getParameter("category");
        Long categoryId = null;

        if (categoryIdStr != null && !categoryIdStr.isEmpty() && !categoryIdStr.equals("0")) {
            try {
                categoryId = Long.parseLong(categoryIdStr);
            } catch (NumberFormatException e) {
                categoryId = null;
            }
        }

        List<Book> books;
        if (categoryId != null) {
            books = bookService.searchByCategory(q, categoryId);
        } else {
            books = bookService.search(q);
        }

        List<Category> categories = categoryDAO.listAll();

        req.setAttribute("books", books);
        req.setAttribute("categories", categories);
        req.setAttribute("q", q);
        req.setAttribute("selectedCategory", categoryId);
        req.getRequestDispatcher("/WEB-INF/views/book_list.jsp").forward(req, resp);
    }

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/books");
            return;
        }
        long id = Long.parseLong(idStr);
        Book book = bookService.findById(id);
        if (book == null) {
            resp.sendError(404, "Không tìm thấy sách");
            return;
        }
        req.setAttribute("book", book);
        req.getRequestDispatcher("/WEB-INF/views/book_detail.jsp").forward(req, resp);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Book b = readBookFromRequest(req);
        bookService.create(b);
        resp.sendRedirect(req.getContextPath() + "/books");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank())
            throw new IllegalArgumentException("Thiếu id");
        Book b = readBookFromRequest(req);
        b.setId(Long.parseLong(idStr));
        bookService.update(b);
        resp.sendRedirect(req.getContextPath() + "/books");
    }

    private Book readBookFromRequest(HttpServletRequest req) {
        Book b = new Book();
        b.setIsbn(req.getParameter("isbn"));
        b.setTitle(req.getParameter("title"));
        b.setAuthor(req.getParameter("author"));
        b.setPublisher(req.getParameter("publisher"));

        String yearStr = req.getParameter("publishYear");
        if (yearStr == null || yearStr.isBlank()) {
            b.setPublishYear(null);
        } else {
            b.setPublishYear(Integer.parseInt(yearStr));
        }

        String qtyStr = req.getParameter("quantity");
        if (qtyStr == null || qtyStr.isBlank()) {
            b.setQuantity(0);
        } else {
            b.setQuantity(Integer.parseInt(qtyStr));
        }

        String status = req.getParameter("status");
        b.setStatus(status == null || status.isBlank() ? "AVAILABLE" : status);
        return b;
    }
}
