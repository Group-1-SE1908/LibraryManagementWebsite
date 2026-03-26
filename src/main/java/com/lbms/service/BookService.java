package com.lbms.service;

import com.lbms.dao.BookDAO;
import com.lbms.model.Book;

import java.sql.SQLException;
import java.util.List;

public class BookService {

    private final BookDAO bookDAO;

    public BookService() {
        this.bookDAO = new BookDAO();
    }

    public List<Book> search(String q) throws SQLException {
        return bookDAO.search(q);
    }

    public List<Book> searchByCategory(String q, Long categoryId) throws SQLException {
        return bookDAO.searchByCategory(q, categoryId);
    }

    public List<Book> searchByCategory(String q, Long categoryId, int page, int pageSize) throws SQLException {
        int safePage = Math.max(page, 1);
        int safePageSize = Math.max(pageSize, 1);
        int offset = (safePage - 1) * safePageSize;
        return bookDAO.searchByCategoryPaged(q, categoryId, offset, safePageSize);
    }

    public int countByCategory(String q, Long categoryId) throws SQLException {
        return bookDAO.countByCategory(q, categoryId);
    }

    public Book findById(long id) throws SQLException {
        return bookDAO.findById(id);
    }

    // public long create(Book b, long userId) throws SQLException {
    // validate(b);
    // if (b.getStatus() == null || b.getStatus().isBlank())
    // b.setStatus("AVAILABLE");
    // return bookDAO.create(b, userId);
    // }
    public long create(Book b, long userId) throws SQLException {
        validate(b);

        String isbnToCheck = b.getIsbn();
        if (isbnToCheck != null && !isbnToCheck.isBlank() && !isbnToCheck.startsWith("ISBN-")) {
            isbnToCheck = "ISBN-" + isbnToCheck;
        }

        if (bookDAO.existsByIsbn(isbnToCheck)) {
            throw new IllegalArgumentException("Mã ISBN '" + isbnToCheck + "' đã tồn tại trong hệ thống.");
        }

        if (b.getStatus() == null || b.getStatus().isBlank()) {
            b.setStatus("AVAILABLE");
        }
        return bookDAO.create(b, userId);
    }

    public void update(Book b, long userId) throws SQLException {
        validate(b);
        if (b.getStatus() == null || b.getStatus().isBlank()) {
            b.setStatus("AVAILABLE");
        }
        bookDAO.update(b, userId);
    }

    public void delete(long id, long userId) throws SQLException {
        bookDAO.delete(id, userId);
    }

    private void validate(Book b) {
        if (b == null) {
            throw new IllegalArgumentException("Dữ liệu sách không hợp lệ");
        }
        if (b.getIsbn() == null || b.getIsbn().isBlank()) {
            throw new IllegalArgumentException("ISBN là bắt buộc");
        }
        if (b.getTitle() == null || b.getTitle().isBlank()) {
            throw new IllegalArgumentException("Tên sách là bắt buộc");
        }
        if (b.getAuthor() == null || b.getAuthor().isBlank()) {
            throw new IllegalArgumentException("Tác giả là bắt buộc");
        }
        if (b.getQuantity() < 0) {
            throw new IllegalArgumentException("Số lượng không hợp lệ");
        }
    }


    public boolean restockBook(int bookId, int additionalQuantity, long userId) throws SQLException {
        // 1. Kiểm tra nghiệp vụ
        if (additionalQuantity <= 0) {
            throw new IllegalArgumentException("Số lượng nhập thêm phải lớn hơn 0");
        }

        // 2. Kiểm tra sách tồn tại
        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new IllegalArgumentException("Không tìm thấy đầu sách để nhập hàng");
        }

        // 3. Gọi DAO và truyền thêm userId để ghi log
        boolean success = bookDAO.restockBook(bookId, additionalQuantity, userId);
        
        // 4. Nếu nhập hàng thành công, tự động thông báo cho các bạn đọc đang nằm trong hàng chờ (nếu có)
        if (success) {
            try {
                com.lbms.service.ReservationService reservationService = new com.lbms.service.ReservationService();
                for (int i = 0; i < additionalQuantity; i++) {
                    reservationService.onBookReturned(bookId); // Mỗi lượt lôi 1 người ở đầu hàng chờ lên để cấp sách
                }
            } catch (Exception e) {
                System.err.println("[BookService] Lỗi khi notify hàng chờ sau khi thêm lượng sách: " + e.getMessage());
            }
        }
        
        return success;
    }
}
