package com.lbms.controller;

import com.lbms.model.Book;
import com.lbms.model.Category;
import com.lbms.service.BookService;
import com.lbms.dao.CategoryDAO;
import com.lbms.dao.CommentDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(urlPatterns = { "/books", "/books/new", "/books/edit", "/books/delete", "/books/detail", "/books/search" })

@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class BookController extends HttpServlet {
    private BookService bookService;
    private CategoryDAO categoryDAO;
    private CommentDAO commentDAO;

    @Override
    public void init() {
        this.bookService = new BookService();
        this.categoryDAO = new CategoryDAO();
        this.commentDAO = new CommentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/books":
                case "/books/search":
                    handleList(req, resp);
                    break;
                case "/books/detail":
                    handleDetail(req, resp);
                    break;
                case "/books/new":
                    req.setAttribute("mode", "create");
                    req.setAttribute("categories", categoryDAO.listAll());
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                    break;
                case "/books/edit":
                    handleEditForm(req, resp);
                    break;
                case "/books/delete":
                    int delId = Integer.parseInt(req.getParameter("id"));
                    bookService.delete(delId);
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
          
            String imagePath = uploadImage(req);

            if ("/books/new".equals(path)) {
                Book b = readBookFromRequest(req);
                b.setImage(imagePath); 
                bookService.create(b);
            } else if ("/books/edit".equals(path)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Book b = readBookFromRequest(req);
                b.setId(id);
                b.setImage(imagePath); 
                bookService.update(b);
            }
            resp.sendRedirect(req.getContextPath() + "/books");
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            req.setAttribute("mode", path.contains("new") ? "create" : "edit");
            try {
                req.setAttribute("categories", categoryDAO.listAll());
            } catch (SQLException ex1) {
                Logger.getLogger(BookController.class.getName()).log(Level.SEVERE, null, ex1);
            }
            req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    
    private String uploadImage(HttpServletRequest req) throws IOException, ServletException {
        Part filePart = req.getPart("imageFile"); // Khớp với name="imageFile" trong book_form.jsp
        
       
        if (filePart == null || filePart.getSize() <= 0) {
            return req.getParameter("currentImage");
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String relativePath = "assets/images/books/" + fileName;
        
        
        String uploadPath = getServletContext().getRealPath("/") + relativePath;
        
        File uploadDir = new File(getServletContext().getRealPath("/") + "assets/images/books/");
        if (!uploadDir.exists()) uploadDir.mkdirs();

        filePart.write(uploadPath); 
        return relativePath; 
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String keyword = req.getParameter("q");
        List<Book> books = bookService.search(keyword);
        req.setAttribute("books", books);
        req.getRequestDispatcher("/WEB-INF/views/book_list.jsp").forward(req, resp);
    }

    private void handleEditForm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Book b = bookService.findById(id);
        req.setAttribute("book", b);
        req.setAttribute("mode", "edit");
        req.setAttribute("categories", categoryDAO.listAll());
        req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
    }

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Book book = bookService.findById(id);
        req.setAttribute("book", book);
        
        // Load comments for the book
        try {
            req.setAttribute("comments", commentDAO.getCommentsByBook(id));
        } catch (Exception e) {
            Logger.getLogger(BookController.class.getName()).log(Level.WARNING, "Error loading comments", e);
            req.setAttribute("comments", new java.util.ArrayList<>());
        }
        
        req.getRequestDispatcher("/WEB-INF/views/book_detail.jsp").forward(req, resp);
    }

    private Book readBookFromRequest(HttpServletRequest req) {
    Book b = new Book();
    b.setIsbn(req.getParameter("isbn"));
    b.setTitle(req.getParameter("title"));
    b.setAuthor(req.getParameter("author"));
    
    String priceStr = req.getParameter("price");
    if (priceStr != null && !priceStr.isBlank()) {
        
        b.setPrice(Double.valueOf(priceStr)); 
    }

    String qtyStr = req.getParameter("quantity");
    b.setQuantity(qtyStr != null ? Integer.parseInt(qtyStr) : 0);
    
    String catIdStr = req.getParameter("categoryId");
    
    if (catIdStr != null && !catIdStr.isEmpty()) {
        b.setCategoryId(Long.valueOf(catIdStr));
    } else {
        b.setCategoryId(null); 
    }
    
    return b;
}
}