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

    public Book findById(long id) throws SQLException {
        return bookDAO.findById(id);
    }

    public long create(Book b) throws SQLException {
        validate(b);
        if (b.getStatus() == null || b.getStatus().isBlank())
            b.setStatus("AVAILABLE");
        return bookDAO.create(b);
    }

    public void update(Book b) throws SQLException {
        validate(b);
        if (b.getStatus() == null || b.getStatus().isBlank())
            b.setStatus("AVAILABLE");
        bookDAO.update(b);
    }

    public void delete(long id) throws SQLException {
        bookDAO.delete(id);
    }

    private void validate(Book b) {
        if (b == null)
            throw new IllegalArgumentException("Dữ liệu sách không hợp lệ");
        if (b.getIsbn() == null || b.getIsbn().isBlank())
            throw new IllegalArgumentException("ISBN là bắt buộc");
        if (b.getTitle() == null || b.getTitle().isBlank())
            throw new IllegalArgumentException("Tên sách là bắt buộc");
        if (b.getAuthor() == null || b.getAuthor().isBlank())
            throw new IllegalArgumentException("Tác giả là bắt buộc");
        if (b.getQuantity() < 0)
            throw new IllegalArgumentException("Số lượng không hợp lệ");
    }
}
