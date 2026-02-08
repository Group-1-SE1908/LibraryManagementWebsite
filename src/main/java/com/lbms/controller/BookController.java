package com.lbms.controller;

import com.lbms.model.Book;
import com.lbms.model.Category; // Import Model
import com.lbms.service.BookService;
import com.lbms.service.CategoryService; // Import Service

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = {
    
    "/books",
    "/books/search",
    "/books/new",
    "/books/edit",
    "/books/availability",
    "/books/delete"
})
public class BookController extends HttpServlet {
    private BookService bookService;
    private CategoryService categoryService; // Đã khai báo

    @Override
    public void init() {
        this.bookService = new BookService();
        this.categoryService = new CategoryService(); // Đã khởi tạo
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/books" -> handleList(req, resp);
                
                case "/books/search" -> handleSearch(req, resp);

                case "/books/new" -> {
                    // --- ĐÃ UNCOMMENT & SỬ DỤNG ---
                    // Lấy danh sách thể loại để đổ vào thẻ <select> trong JSP
                    List<Category> categories = categoryService.listAll();
                    req.setAttribute("categories", categories);
                    // ------------------------------
                    
                    req.setAttribute("mode", "create");
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                }

                case "/books/edit" -> {
                    String idStr = req.getParameter("id");
                    if (idStr == null || idStr.isBlank()) {
                        resp.sendRedirect(req.getContextPath() + "/books");
                        return;
                    }
                    int id = Integer.parseInt(idStr);
                    Book b = bookService.findById(id);
                    if (b == null) {
                        req.setAttribute("error", "Không tìm thấy sách!");
                        handleList(req, resp);
                        return;
                    }
                    
                    // --- ĐÃ UNCOMMENT & SỬ DỤNG ---
                    List<Category> categories = categoryService.listAll();
                    req.setAttribute("categories", categories);
                    // ------------------------------

                    req.setAttribute("mode", "edit");
                    req.setAttribute("book", b);
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                }

                case "/books/availability" -> {
                    String idStr = req.getParameter("id");
                    String statusStr = req.getParameter("status");
                    if (idStr != null && statusStr != null) {
                        int id = Integer.parseInt(idStr);
                        boolean currentStatus = Boolean.parseBoolean(statusStr);
                        bookService.updateAvailability(id, !currentStatus);
                    }
                    resp.sendRedirect(req.getContextPath() + "/books");
                }

                case "/books/delete" -> {
                    String idStr = req.getParameter("id");
                    if (idStr != null) {
                        bookService.delete(Integer.parseInt(idStr));
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
            if ("/books/new".equals(path)) {
                Book b = readBookFromRequest(req);
                b.setAvailability(true);
                bookService.create(b);
                resp.sendRedirect(req.getContextPath() + "/books");
            } 
            else if ("/books/edit".equals(path)) {
                Book b = readBookFromRequest(req);
                b.setBookId(Integer.parseInt(req.getParameter("id")));
                bookService.update(b);
                resp.sendRedirect(req.getContextPath() + "/books");
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            req.setAttribute("book", readBookFromRequest(req));
            
            // Nếu lỗi, cần load lại category để form không bị mất dropdown
            try {
                req.setAttribute("categories", categoryService.listAll());
            } catch (Exception e) {}
            
            req.setAttribute("mode", path.contains("new") ? "create" : "edit");
            req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // ... Giữ nguyên các hàm handleList, handleSearch ...
    
    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Book> books = bookService.listAll();
        req.setAttribute("books", books);
        req.getRequestDispatcher("/WEB-INF/views/book_list.jsp").forward(req, resp);
    }
    
    private void handleSearch(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String keyword = req.getParameter("q");
        List<Book> books = bookService.search(keyword);
        req.setAttribute("books", books);
        req.setAttribute("q", keyword);
        req.getRequestDispatcher("/WEB-INF/views/book_list.jsp").forward(req, resp);
    }

    private Book readBookFromRequest(HttpServletRequest req) {
        Book b = new Book();
        b.setTitle(req.getParameter("title"));
        b.setAuthor(req.getParameter("author"));
        b.setImage(req.getParameter("image"));
        
        String priceStr = req.getParameter("price");
        if (priceStr == null || priceStr.trim().isEmpty()) {
            b.setPrice(BigDecimal.ZERO);
        } else {
            try {
                b.setPrice(new BigDecimal(priceStr.trim()));
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("Giá sách phải là số hợp lệ");
            }
        }

        String catIdStr = req.getParameter("categoryId");
        if (catIdStr != null && !catIdStr.isBlank()) {
            b.setCategoryId(Integer.parseInt(catIdStr));
        }

        return b;
    }
}