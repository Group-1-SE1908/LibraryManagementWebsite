package com.lbms.controller;

import com.lbms.model.Book;
import com.lbms.model.Category;
import com.lbms.service.BookService;
import com.lbms.service.CategoryService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig; // Cần thiết cho Upload File
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.List;
import java.util.UUID;

@WebServlet(urlPatterns = {
    "/books", // Danh sách
    "/books/search", // Tìm kiếm
    "/books/new", // Form thêm
    "/books/edit", // Form sửa
    "/books/delete" // Xóa
})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class BookController extends HttpServlet {

    private BookService bookService;
    private CategoryService categoryService;

    @Override
    public void init() {
        this.bookService = new BookService();
        this.categoryService = new CategoryService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/books" ->
                    handleList(req, resp);

                case "/books/search" ->
                    handleSearch(req, resp);

                case "/books/new" -> {
                    // Load danh sách Category để đổ vào Dropdown
                    List<Category> categories = categoryService.listAll();
                    req.setAttribute("categories", categories);

                    req.setAttribute("mode", "create");
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                }

                case "/books/edit" -> {
                    String idStr = req.getParameter("id");
                    if (idStr == null || idStr.isBlank()) {
                        resp.sendRedirect(req.getContextPath() + "/books");
                        return;
                    }

                    Book b = bookService.findById(Integer.parseInt(idStr));
                    if (b == null) {
                        req.setAttribute("error", "Không tìm thấy sách có ID: " + idStr);
                        handleList(req, resp);
                        return;
                    }

                    // Load Category và Book lên form
                    List<Category> categories = categoryService.listAll();
                    req.setAttribute("categories", categories);

                    req.setAttribute("mode", "edit");
                    req.setAttribute("book", b);
                    req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
                }

                case "/books/delete" -> {
                    String idStr = req.getParameter("id");
                    if (idStr != null) {
                        try {
                            bookService.delete(Integer.parseInt(idStr));
                        } catch (Exception e) {
                            // Nếu xóa lỗi (do ràng buộc), quay lại danh sách và báo lỗi
                            req.getSession().setAttribute("globalError", e.getMessage());
                        }
                    }
                    resp.sendRedirect(req.getContextPath() + "/books");
                }

                default ->
                    resp.sendError(404);
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
            if ("/books/new".equals(path) || "/books/edit".equals(path)) {

                // 1. Đọc dữ liệu từ Form
                Book b = new Book();
                // Nếu là edit thì lấy ID
                if ("/books/edit".equals(path)) {
                    b.setBookId(Integer.parseInt(req.getParameter("id")));
                }

                b.setTitle(req.getParameter("title"));
                b.setAuthor(req.getParameter("author"));

                String rawIsbn = req.getParameter("isbn");
                b.setIsbn(normalizeISBN(rawIsbn));

                String catId = req.getParameter("categoryId");
                b.setCategoryId((catId == null || catId.isEmpty()) ? 0 : Integer.parseInt(catId));

                String priceStr = req.getParameter("price");
                b.setPrice((priceStr == null || priceStr.isEmpty()) ? BigDecimal.ZERO : new BigDecimal(priceStr));

                String qtyStr = req.getParameter("quantity");
                b.setQuantity((qtyStr == null || qtyStr.isEmpty()) ? 0 : Integer.parseInt(qtyStr));

                // 2. Xử lý Upload Ảnh
                Part filePart = req.getPart("imageFile"); // Input name="imageFile"
                String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

                if (fileName != null && !fileName.isEmpty()) {
                    // Người dùng có chọn file ảnh mới -> Upload và Lưu

                    // Đường dẫn thực trên server: .../webapp/assets/images/books
                    String uploadPath = getServletContext().getRealPath("") + File.separator + "assets" + File.separator + "images" + File.separator + "books";

                    // Tạo thư mục nếu chưa có
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }

                    // Đổi tên file để tránh trùng (Dùng UUID)
                    String newFileName = UUID.randomUUID().toString() + "_" + fileName;

                    // Ghi file
                    filePart.write(uploadPath + File.separator + newFileName);

                    // Lưu đường dẫn tương đối vào DB
                    b.setImage("assets/images/books/" + newFileName);
                } else {
                    // Không chọn ảnh mới -> Giữ ảnh cũ (Lấy từ hidden field)
                    b.setImage(req.getParameter("currentImage"));
                }

                // 3. Gọi Service để xử lý nghiệp vụ
                if ("/books/new".equals(path)) {
                    bookService.create(b);
                } else {
                    bookService.update(b);
                }

                // Thành công -> Về trang danh sách
                resp.sendRedirect(req.getContextPath() + "/books");
            }
        } catch (Exception ex) {
            // Xảy ra lỗi (Validate, Trùng ISBN...) -> Ở lại trang Form và hiện lỗi
            req.setAttribute("error", ex.getMessage());

            // Cần load lại categories để dropdown không bị trống
            try {
                req.setAttribute("categories", categoryService.listAll());
            } catch (Exception e) {
            }

            // Map lại dữ liệu vừa nhập để người dùng không phải nhập lại từ đầu
            Book b = new Book();
            b.setTitle(req.getParameter("title"));
            b.setAuthor(req.getParameter("author"));
            b.setIsbn(req.getParameter("isbn"));
            b.setImage(req.getParameter("currentImage")); // Giữ ảnh cũ để preview
            // ... (map thêm các trường khác nếu cần thiết hiển thị lại)
            try {
                b.setQuantity(Integer.parseInt(req.getParameter("quantity")));
            } catch (Exception e) {
            }
            try {
                b.setPrice(new BigDecimal(req.getParameter("price")));
            } catch (Exception e) {
            }
            try {
                b.setCategoryId(Integer.parseInt(req.getParameter("categoryId")));
            } catch (Exception e) {
            }

            req.setAttribute("book", b);
            req.setAttribute("mode", path.contains("new") ? "create" : "edit");
            req.getRequestDispatcher("/WEB-INF/views/book_form.jsp").forward(req, resp);
        }
    }

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

    private String normalizeISBN(String input) {
        if (input == null || input.trim().isEmpty()) {
            return null;
        }

        String trimmedInput = input.trim();

        // Kiểm tra xem đã có tiền tố "ISBN-" chưa (không phân biệt hoa thường)
        if (trimmedInput.toUpperCase().startsWith("ISBN-")) {
            // Nếu có rồi, chỉ cần đảm bảo chữ ISBN viết hoa cho đẹp
            return "ISBN-" + trimmedInput.substring(5);
        } else {
            // Nếu chưa có (ví dụ chỉ nhập "13"), thì nối thêm vào
            return "ISBN-" + trimmedInput;
        }
    }
}
