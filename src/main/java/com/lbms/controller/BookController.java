package com.lbms.controller;

import com.lbms.model.Book;
import com.lbms.service.BookService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/books", "/books/new", "/books/edit", "/books/delete"})
public class BookController extends HttpServlet {
    private BookService bookService;

    @Override
    public void init() {
        this.bookService = new BookService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/books" -> handleList(req, resp);
                case "/books/new" -> {
                    req.setAttribute("mode", "create");
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                }
                case "/books/edit" -> {
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
                }
                case "/books/delete" -> {
                    String idStr = req.getParameter("id");
                    if (idStr != null) {
                        bookService.delete(Long.parseLong(idStr));
                    }
                    resp.sendRedirect(req.getContextPath() + "/books");
                }
                default -> resp.sendError(404);
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
                case "/books/new" -> handleCreate(req, resp);
                case "/books/edit" -> handleUpdate(req, resp);
                default -> resp.sendError(405);
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
        List<Book> books = bookService.search(q);
        req.setAttribute("books", books);
        req.setAttribute("q", q);
        req.getRequestDispatcher("/WEB-INF/views/book_list.jsp").forward(req, resp);
    }

    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        Book b = readBookFromRequest(req);
        bookService.create(b);
        resp.sendRedirect(req.getContextPath() + "/books");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String idStr = req.getParameter("id");
        if (idStr == null || idStr.isBlank()) throw new IllegalArgumentException("Thiếu id");
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
