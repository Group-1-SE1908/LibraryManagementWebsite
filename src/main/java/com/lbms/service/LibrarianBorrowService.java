package com.lbms.service;

import com.lbms.dao.BorrowDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class LibrarianBorrowService {

    private final BorrowDAO borrowDAO = new BorrowDAO();

    public void returnBook(long borrowId, String inputBarcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // 1. Kiểm tra Barcode có khớp với phiếu mượn không
                String sqlCheck = "SELECT bc.barcode, br.book_id FROM borrow_records br "
                        + "JOIN BookCopy bc ON br.copy_id = bc.copy_id WHERE br.id = ?";
                String correctBarcode = "";
                long bookId = -1;

                try (PreparedStatement ps = c.prepareStatement(sqlCheck)) {
                    ps.setLong(1, borrowId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            correctBarcode = rs.getString("barcode");
                            bookId = rs.getLong("book_id");
                        } else {
                            throw new IllegalArgumentException("Không tìm thấy thông tin bản sao cho phiếu mượn này.");
                        }
                    }
                }

                // 2. So khớp Barcode (Truy xuất ngược nếu sai)
                if (!correctBarcode.equalsIgnoreCase(inputBarcode)) {
                    String ownerName = "";
                    String sqlReverse = "SELECT u.full_name FROM borrow_records br "
                            + "JOIN BookCopy bc ON br.copy_id = bc.copy_id "
                            + "JOIN [User] u ON br.user_id = u.user_id "
                            + "WHERE bc.barcode = ? AND br.status = 'BORROWED'";
                    try (PreparedStatement ps = c.prepareStatement(sqlReverse)) {
                        ps.setString(1, inputBarcode);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                ownerName = rs.getString("full_name");
                            }
                        }
                    }
                    if (!ownerName.isEmpty()) {
                        throw new IllegalArgumentException("Sai sách! Mã vạch này thuộc về khách hàng: " + ownerName);
                    } else {
                        throw new IllegalArgumentException("Mã vạch không khớp với bất kỳ phiếu mượn nào.");
                    }
                }

                // 3. Cập nhật BookCopy thành AVAILABLE
                String updateCopy = "UPDATE BookCopy SET status = 'AVAILABLE' WHERE barcode = ?";
                try (PreparedStatement ps = c.prepareStatement(updateCopy)) {
                    ps.setString(1, inputBarcode);
                    ps.executeUpdate();
                }

                // 4. Tăng quantity bảng Book
                String updateQty = "UPDATE Book SET quantity = quantity + 1 WHERE book_id = ?";
                try (PreparedStatement ps = c.prepareStatement(updateQty)) {
                    ps.setLong(1, bookId);
                    ps.executeUpdate();
                }

                // 5. Kết thúc phiếu mượn
                String updateBr = "UPDATE borrow_records SET status='RETURNED', return_date=GETDATE() WHERE id=?";
                try (PreparedStatement ps = c.prepareStatement(updateBr)) {
                    ps.setLong(1, borrowId);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception e) {
                c.rollback();
                throw e;
            }
        }
    }

    public void approveRequest(long borrowId, String barcode) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false); // Bắt đầu Transaction
            try {
                // 1. Kiểm tra mã vạch (Barcode) có tồn tại và đang sẵn sàng không
                int copyId = -1;
                long bookIdFromCopy = -1;
                String checkCopy = "SELECT copy_id, book_id FROM BookCopy WHERE barcode = ? AND status = 'AVAILABLE'";
                try (PreparedStatement ps = c.prepareStatement(checkCopy)) {
                    ps.setString(1, barcode);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            copyId = rs.getInt("copy_id");
                            bookIdFromCopy = rs.getLong("book_id");
                        } else {
                            throw new IllegalArgumentException("Mã vạch không hợp lệ hoặc sách đã bị mượn/hỏng.");
                        }
                    }
                }

                // 2. Lấy thông tin phiếu mượn và kiểm tra khớp đầu sách (Tránh quét lộn Barcode của sách khác)
                String checkBr = "SELECT book_id FROM borrow_records WHERE id = ?";
                try (PreparedStatement ps = c.prepareStatement(checkBr)) {
                    ps.setLong(1, borrowId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            if (rs.getLong("book_id") != bookIdFromCopy) {
                                throw new IllegalArgumentException("Mã vạch này thuộc về đầu sách khác, không phải cuốn người dùng yêu cầu.");
                            }
                        }
                    }
                }

                // 3. Cập nhật trạng thái BookCopy sang BORROWED
                String updateCopy = "UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?";
                try (PreparedStatement ps = c.prepareStatement(updateCopy)) {
                    ps.setInt(1, copyId);
                    ps.executeUpdate();
                }

                // 4. Cập nhật phiếu mượn: Chuyển sang BORROWED, set ngày mượn/hạn trả và gán copy_id
                LocalDate borrowDate = LocalDate.now();
                LocalDate dueDate = borrowDate.plusDays(14); // Hạn 14 ngày
                String updateBr = "UPDATE borrow_records SET status = 'BORROWED', borrow_date = ?, due_date = ?, copy_id = ? WHERE id = ?";
                try (PreparedStatement ps = c.prepareStatement(updateBr)) {
                    ps.setDate(1, java.sql.Date.valueOf(borrowDate));
                    ps.setDate(2, java.sql.Date.valueOf(dueDate));
                    ps.setInt(3, copyId);
                    ps.setLong(4, borrowId);
                    ps.executeUpdate();
                }

                // 5. Trừ số lượng (quantity) trong bảng Book
                String updateQty = "UPDATE Book SET quantity = quantity - 1 WHERE book_id = ? AND quantity > 0";
                try (PreparedStatement ps = c.prepareStatement(updateQty)) {
                    ps.setLong(1, bookIdFromCopy);
                    ps.executeUpdate();
                }

                c.commit(); // Hoàn tất
            } catch (Exception e) {
                c.rollback();
                throw e;
            }
        }
    }

    public BorrowRecord findActiveBorrowingByBarcode(String barcode) throws SQLException {
        // Câu truy vấn join để lấy thông tin User và Sách dựa trên Barcode đang mượn
        String sql = "SELECT br.*, u.full_name, u.phone, b.title "
                + "FROM borrow_records br "
                + "JOIN [User] u ON br.user_id = u.user_id "
                + "JOIN Book b ON br.book_id = b.book_id "
                + "JOIN BookCopy bc ON br.copy_id = bc.copy_id "
                + "WHERE bc.barcode = ? AND br.status = 'BORROWED'";

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, barcode);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Bạn có thể dùng mapOne của DAO hoặc map thủ công ở đây
                    BorrowRecord br = new BorrowRecord();
                    br.setId(rs.getLong("id"));
                    br.setStatus(rs.getString("status"));
                    // ... map các thông tin cần hiển thị
                    return br;
                }
            }
        }
        return null; // Không có ai đang mượn cuốn có Barcode này
    }

    public void rejectRequest(long borrowId) throws SQLException {
        String sql = "UPDATE borrow_records SET status = 'REJECTED' WHERE id = ? AND status = 'REQUESTED'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            ps.executeUpdate();
        }
    }

    public List<BorrowRecord> searchBorrowings(String keyword, String status) throws SQLException {
        // Đây là phương thức thực thi lọc chính xác
        List<BorrowRecord> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT br.id AS borrowing_id, br.user_id, br.book_id, br.copy_id, br.borrow_date, br.due_date, br.return_date, "
            + "br.status, br.fine_amount, br.borrow_method, "
            + "u.email AS user_email, u.full_name AS user_full_name, "
            + "bk.title AS book_title, bk.author AS book_author, bk.isbn AS book_isbn, bk.image AS book_image "
            + "FROM borrow_records br "
            + "JOIN [User] u ON br.user_id = u.user_id "
            + "JOIN Book bk ON br.book_id = bk.book_id WHERE 1=1 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (u.full_name LIKE ? OR bk.title LIKE ?) ");
        }
        if (status != null && !status.trim().isEmpty()) {
            sql.append("AND br.status = ? ");
        }
        sql.append("ORDER BY br.id DESC");

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql.toString())) {
            int idx = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                String k = "%" + keyword.trim() + "%";
                ps.setString(idx++, k);
                ps.setString(idx++, k);
            }
            if (status != null && !status.trim().isEmpty()) {
                ps.setString(idx++, status);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    // Tận dụng logic map dữ liệu của bạn
                    list.add(borrowDAO.mapOne(rs));
                }
            }
        }
        return list;
    }
}
