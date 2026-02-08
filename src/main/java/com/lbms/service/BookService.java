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

    // 1. Lấy danh sách tất cả sách
    public List<Book> listAll() throws SQLException {
        return bookDAO.listAll();
    }

    // 2. Tìm sách theo ID
    public Book findById(int id) throws SQLException {
        return bookDAO.findById(id);
    }

    // 3. Tìm kiếm sách theo từ khóa
    public List<Book> search(String keyword) throws SQLException {
        return bookDAO.search(keyword);
    }

    // 4. Thêm sách mới
    public void create(Book b) throws SQLException {
        // --- VALIDATION (Kiểm tra dữ liệu đầu vào) ---
        if (b.getTitle() == null || b.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên sách không được để trống!");
        }
        if (b.getAuthor() == null || b.getAuthor().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên tác giả không được để trống!");
        }
        if (b.getPrice() != null && b.getPrice().signum() < 0) {
            throw new IllegalArgumentException("Giá sách không được là số âm!");
        }

        // Gọi DAO để lưu
        bookDAO.create(b);
    }

    // 5. Cập nhật thông tin sách (Tên, Giá, Ảnh, Tác giả...)
    public void update(Book b) throws SQLException {
        // --- VALIDATION ---
        if (b.getBookId() <= 0) {
            throw new IllegalArgumentException("ID sách không hợp lệ!");
        }
        if (b.getTitle() == null || b.getTitle().trim().isEmpty()) {
            throw new IllegalArgumentException("Tên sách không được để trống!");
        }
        
        // Gọi DAO để update
        bookDAO.update(b);
    }

    // 6. Cập nhật trạng thái Sẵn có / Hết hàng
    public void updateAvailability(int bookId, boolean isAvailable) throws SQLException {
        if (bookId <= 0) {
            throw new IllegalArgumentException("ID sách không hợp lệ!");
        }
        bookDAO.updateAvailability(bookId, isAvailable);
    }

    // 7. Xóa sách
    public void delete(int id) throws SQLException {
        // Lưu ý: Nếu sách đang có trong phiếu mượn (BorrowRecord), 
        // SQL Server sẽ báo lỗi Foreign Key Constraint. 
        // Bạn có thể try-catch ở đây để báo lỗi thân thiện hơn nếu muốn.
        try {
            bookDAO.delete(id);
        } catch (SQLException e) {
            if (e.getMessage().contains("REFERENCE constraint")) {
                throw new IllegalArgumentException("Không thể xóa sách này vì đang có người mượn hoặc nằm trong lịch sử giao dịch!");
            }
            throw e; // Ném tiếp lỗi nếu không phải lỗi ràng buộc
        }
    }
}