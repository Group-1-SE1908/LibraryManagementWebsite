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

    public List<Book> listAll() throws SQLException {
        return bookDAO.listAll();
    }

    public Book findById(int id) throws SQLException {
        return bookDAO.findById(id);
    }

    public List<Book> search(String keyword) throws SQLException {
        return bookDAO.search(keyword);
    }

    // --- CHỨC NĂNG THÊM MỚI ---
    public void create(Book b) throws SQLException {
        // 1. Kiểm tra dữ liệu cơ bản
        validateBook(b);

        // 2. Kiểm tra ISBN trùng lặp
        if (b.getIsbn() == null || b.getIsbn().trim().isEmpty()) {
            throw new IllegalArgumentException("Mã ISBN không được để trống!");
        }

        Book existingBook = bookDAO.findByIsbn(b.getIsbn());
        if (existingBook != null) {
            throw new IllegalArgumentException("Lỗi: Sách có ISBN '" + b.getIsbn() + "' đã tồn tại trong hệ thống!");
        }

        // 3. Gọi DAO lưu xuống DB
        bookDAO.create(b);
    }

    // --- CHỨC NĂNG CẬP NHẬT ---
    public void update(Book b) throws SQLException {
        // 1. Kiểm tra dữ liệu cơ bản
        validateBook(b);

        if (b.getBookId() <= 0) {
            throw new IllegalArgumentException("ID sách không hợp lệ!");
        }

        // Lưu ý: Thường thì ISBN không được sửa, hoặc nếu sửa phải check trùng với sách khác.
        // Ở đây ta giả định ISBN không thay đổi hoặc DAO sẽ xử lý update.
        bookDAO.update(b);
    }

    // --- CHỨC NĂNG XÓA ---
    public void delete(int id) throws SQLException {
        try {
            bookDAO.delete(id);
        } catch (SQLException e) {
            // Bắt lỗi khóa ngoại (Foreign Key) nếu sách đang có trong phiếu mượn
            if (e.getMessage().contains("REFERENCE constraint")) {
                throw new IllegalArgumentException("Không thể xóa: Sách này đang có trong lịch sử mượn/trả!");
            }
            throw e;
        }
    }

    // --- HÀM VALIDATE CHUNG ---
    private void validateBook(Book b) {
        if (b.getTitle() == null || b.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên sách không được để trống!");
        }
        if (b.getAuthor() == null || b.getAuthor().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên tác giả không được để trống!");
        }
        if (b.getCategoryId() <= 0) {
            throw new IllegalArgumentException("Vui lòng chọn Thể loại (Category) cho sách!");
        }
        if (b.getPrice() != null && b.getPrice().signum() < 0) {
            throw new IllegalArgumentException("Giá sách không được là số âm!");
        }
        if (b.getQuantity() < 0) {
            throw new IllegalArgumentException("Số lượng sách không được là số âm!");
        }
    }

    public void updateAvailability(int bookId, boolean isAvailable) throws SQLException {
        bookDAO.updateAvailability(bookId, isAvailable);
    }
}
