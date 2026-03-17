package com.lbms.controller;

import com.lbms.dao.*;
import com.lbms.model.Book;
import com.lbms.model.Comment;
import com.lbms.model.CommentReport;
import com.lbms.model.User;
import com.lbms.service.BookService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(urlPatterns = {
        "/books", "/books/new", "/books/edit", "/books/delete", "/books/detail", "/books/search", "/books/restock",
        "/staff/books", "/staff/books/new", "/staff/books/edit", "/staff/books/delete", "/staff/books/detail",
        "/staff/books/search", "/staff/books/restock",
        "/admin/books", "/admin/books/new", "/admin/books/edit", "/admin/books/delete", "/admin/books/detail",
        "/admin/books/search", "/admin/books/restock"
})
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class BookController extends HttpServlet {

    private static final int BOOKS_PER_PAGE = 8;
    private UserDAO userDAO;
    private BookService bookService;
    private CategoryDAO categoryDAO;
    private CommentDAO commentDAO;
    private CommentReplyDAO replyDAO;
    private ReservationDAO reservationDAO;
    private CommentReportDAO reportDAO;

    @Override
    public void init() {
        this.bookService = new BookService();
        this.categoryDAO = new CategoryDAO();
        this.commentDAO = new CommentDAO();
        this.replyDAO = new CommentReplyDAO();
        this.reservationDAO = new ReservationDAO();
        this.reportDAO = new CommentReportDAO();
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String normalizedPath = normalizeBooksPath(path);
        String booksBasePath = resolveBooksBasePath(path);
        req.setAttribute("booksBasePath", booksBasePath);
        try {
            String action = req.getParameter("action");
            String rawId = req.getParameter("id");
            if ("viewImportList".equals(action)) {
                handleImportList(req, resp);
                return;
            }
            switch (normalizedPath) {
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
                    req.getRequestDispatcher("/WEB-INF/views/admin/library/book_form.jsp").forward(req, resp);
                    break;
                case "/books/edit":
                    handleEditForm(req, resp);
                    break;
                case "/books/delete":
                    int delId = Integer.parseInt(req.getParameter("id"));
                    bookService.delete(delId, ((User) req.getSession().getAttribute("currentUser")).getId());
                    resp.sendRedirect(req.getContextPath() + booksBasePath);
                    break;

                case "/books/restock":
                    if (rawId != null && !rawId.isEmpty()) {
                        int restockId = Integer.parseInt(rawId);
                        Book bookToRestock = bookService.findById(restockId);
                        req.setAttribute("book", bookToRestock);
                        req.getRequestDispatcher("/WEB-INF/views/admin/library/book_restock.jsp").forward(req, resp);
                    } else {
                        resp.sendRedirect(req.getContextPath() + booksBasePath + "?action=viewImportList");
                    }
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
        String normalizedPath = normalizeBooksPath(path);
        String booksBasePath = resolveBooksBasePath(path);
        req.setAttribute("booksBasePath", booksBasePath);
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");

        try {

            // 2. Lấy thông tin người dùng
            HttpSession session = req.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            long userId = currentUser.getId();

            // 3. Thực hiện tạo mới hoặc cập nhật
            if ("/books/new".equals(normalizedPath)) {
                String imagePath = uploadImage(req);
                Book b = readBookFromRequest(req);
                b.setImage(imagePath);
                b.setQuantity(0);
                bookService.create(b, userId);
            } else if ("/books/edit".equals(normalizedPath)) {
                String imagePath = uploadImage(req);
                int id = Integer.parseInt(req.getParameter("id"));

                Book existingBook = bookService.findById(id);
                Book b = readBookFromRequest(req);

                b.setId(id);
                b.setImage(imagePath);

                b.setQuantity(existingBook.getQuantity());
                bookService.update(b, userId);
            } else if ("restock".equals(action)) {
                int bookId = Integer.parseInt(req.getParameter("bookId"));
                int amount = Integer.parseInt(req.getParameter("amount"));

                boolean success = bookService.restockBook(bookId, amount, userId);
                if (success) {
                    req.getSession().setAttribute("flash", "Nhập hàng thành công!");
                } else {
                    req.getSession().setAttribute("flash", "Lỗi khi nhập hàng.");
                }
                resp.sendRedirect(req.getContextPath() + booksBasePath + "?action=viewImportList");
                return;
            }

            // Nếu thành công thì redirect về danh sách
            resp.sendRedirect(req.getContextPath() + booksBasePath);

        } catch (IllegalArgumentException ex) {
            // ĐÂY LÀ NƠI XỬ LÝ LỖI TRÙNG ISBN HOẶC VALIDATION
            req.setAttribute("error", ex.getMessage());
            req.setAttribute("mode", normalizedPath.contains("new") ? "create" : "edit");
            req.setAttribute("booksBasePath", booksBasePath);

            // Đổ lại dữ liệu cũ vào form để người dùng không phải nhập lại
            req.setAttribute("book", readBookFromRequest(req));

            try {
                req.setAttribute("categories", categoryDAO.listAll());
            } catch (SQLException ex1) {
                Logger.getLogger(BookController.class.getName()).log(Level.SEVERE, null, ex1);
            }

            // Forward quay lại trang form thay vì redirect để hiện thông báo lỗi
            req.getRequestDispatcher("/WEB-INF/views/admin/library/book_form.jsp").forward(req, resp);

        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private String uploadImage(HttpServletRequest req) throws IOException, ServletException {
        Part filePart = req.getPart("imageFile");
        if (filePart == null || filePart.getSize() <= 0) {
            return req.getParameter("currentImage");
        }

        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String relativePath = "assets/images/books/" + fileName;
        String uploadPath = getServletContext().getRealPath("/") + relativePath;

        File uploadDir = new File(getServletContext().getRealPath("/") + "assets/images/books/");
        if (!uploadDir.exists()) {
            uploadDir.mkdirs();
        }

        filePart.write(uploadPath);
        return relativePath;
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String keyword = normalizeKeyword(req);
        Long categoryId = parseCategoryId(req);
        int requestedPage = parsePage(req.getParameter("page"));
        int totalBooks = bookService.countByCategory(keyword, categoryId);
        int totalPages = totalBooks == 0 ? 1 : (int) Math.ceil((double) totalBooks / BOOKS_PER_PAGE);
        int currentPage = Math.min(requestedPage, totalPages);
        List<Book> books = totalBooks == 0
                ? Collections.emptyList()
                : bookService.searchByCategory(keyword, categoryId, currentPage, BOOKS_PER_PAGE);

        int startPage = Math.max(1, currentPage - 2);
        int endPage = Math.min(totalPages, startPage + 4);
        startPage = Math.max(1, endPage - 4);

        req.setAttribute("books", books);
        req.setAttribute("categories", categoryDAO.listAll());
        req.setAttribute("totalBooks", totalBooks);
        req.setAttribute("searchKeyword", keyword == null ? "" : keyword);
        req.setAttribute("selectedCategoryId", categoryId);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("startPage", startPage);
        req.setAttribute("endPage", endPage);
        req.setAttribute("hasPreviousPage", currentPage > 1);
        req.setAttribute("hasNextPage", currentPage < totalPages);
        req.getRequestDispatcher("/WEB-INF/views/book_list.jsp").forward(req, resp);
    }

    private String normalizeKeyword(HttpServletRequest req) {
        String keyword = req.getParameter("search");
        if (keyword == null || keyword.isBlank()) {
            keyword = req.getParameter("q");
        }
        if (keyword == null) {
            return null;
        }
        String normalized = keyword.trim();
        return normalized.isEmpty() ? null : normalized;
    }

    private Long parseCategoryId(HttpServletRequest req) {
        String rawCategoryId = req.getParameter("category");
        if (rawCategoryId == null || rawCategoryId.isBlank()) {
            rawCategoryId = req.getParameter("categoryId");
        }
        if (rawCategoryId == null || rawCategoryId.isBlank()) {
            return null;
        }
        try {
            Long categoryId = Long.valueOf(rawCategoryId.trim());
            return categoryId > 0 ? categoryId : null;
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private int parsePage(String rawPage) {
        if (rawPage == null || rawPage.isBlank()) {
            return 1;
        }
        try {
            int page = Integer.parseInt(rawPage.trim());
            return page > 0 ? page : 1;
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private void handleEditForm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Book b = bookService.findById(id);
        req.setAttribute("book", b);
        req.setAttribute("mode", "edit");
        req.setAttribute("categories", categoryDAO.listAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/library/book_form.jsp").forward(req, resp);
    }

    private void handleDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        Book book = bookService.findById(id);
        req.setAttribute("book", book);

        List<Comment> comments = commentDAO.getCommentsByBook(id);

        // Load replies for each comment
        for (Comment comment : comments) {
            List<com.lbms.model.CommentReply> replies = this.replyDAO.findByCommentId(comment.getCommentId());
            comment.setReplies(replies);
        }

        req.setAttribute("comments", comments);

        // Lấy rating trung bình và số lượt đánh giá
        double averageRating = commentDAO.getAverageRating(id);
        int ratingCount = commentDAO.getRatingCount(id);
        req.setAttribute("averageRating", averageRating);
        req.setAttribute("ratingCount", ratingCount);

        // Kiểm tra xem user hiện tại đã comment cho sách này chưa
        HttpSession session = req.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        req.setAttribute("reportsBasePath", resolveReportsBasePath(req.getServletPath(), currentUser));
        if (currentUser != null) {
            boolean hasCommented = commentDAO.hasUserCommented(id, (int) currentUser.getId());
            req.setAttribute("hasCommented", hasCommented);

            // Kiểm tra xem user đã đặt trước sách này chưa
            boolean hasReserved = reservationDAO.existsActive((int) currentUser.getId(), id);
            req.setAttribute("hasReserved", hasReserved);
            boolean isCommentLocked = userDAO.isCommentLocked(currentUser.getId());
            req.setAttribute("isCommentLocked", isCommentLocked);

            // Librarian/admin views can moderate reported comments directly from detail
            // page
            if (hasOperationalRole(currentUser)) {
                List<CommentReport> bookReports = reportDAO.getReportsByBook(id);
                req.setAttribute("bookReports", bookReports);
            }
        } else {
            req.setAttribute("hasCommented", false);
            req.setAttribute("hasReserved", false);
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

        // String qtyStr = req.getParameter("quantity");
        // b.setQuantity(qtyStr != null ? Integer.parseInt(qtyStr) : 0);

        String catIdStr = req.getParameter("categoryId");
        if (catIdStr != null && !catIdStr.isEmpty()) {
            b.setCategoryId(Long.valueOf(catIdStr));
        } else {
            b.setCategoryId(null);
        }
        return b;
    }

    private void handleImportList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String keyword = req.getParameter("searchImport");
        String searchKeyword = (keyword != null && !keyword.isBlank()) ? keyword.trim() : null;

        List<Book> books = bookService.searchByCategory(searchKeyword, null, 1, 100);

        req.setAttribute("bookList", books);
        req.setAttribute("lastSearch", searchKeyword);
        req.getRequestDispatcher("/WEB-INF/views/admin/library/import_list.jsp").forward(req, resp);
    }

    private String resolveBooksBasePath(String path) {
        if (path != null && path.startsWith("/admin/books")) {
            return "/admin/books";
        }
        if (path != null && path.startsWith("/staff/books")) {
            return "/staff/books";
        }
        return "/books";
    }

    private String normalizeBooksPath(String path) {
        if (path == null) {
            return "";
        }
        if (path.startsWith("/admin/books")) {
            return "/books" + path.substring("/admin/books".length());
        }
        if (path.startsWith("/staff/books")) {
            return "/books" + path.substring("/staff/books".length());
        }
        return path;
    }

    private String resolveReportsBasePath(String servletPath, User currentUser) {
        if (servletPath != null && servletPath.startsWith("/admin/")) {
            return "/admin/reports";
        }
        if (servletPath != null && servletPath.startsWith("/staff/")) {
            return "/staff/reports";
        }

        if (currentUser != null && currentUser.getRole() != null) {
            String role = currentUser.getRole().getName();
            if ("ADMIN".equalsIgnoreCase(role)) {
                return "/admin/reports";
            }
        }
        return "/staff/reports";
    }

    private boolean hasOperationalRole(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        String role = user.getRole().getName();
        return "LIBRARIAN".equalsIgnoreCase(role) || "ADMIN".equalsIgnoreCase(role);
    }
}