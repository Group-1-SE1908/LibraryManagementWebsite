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
}
