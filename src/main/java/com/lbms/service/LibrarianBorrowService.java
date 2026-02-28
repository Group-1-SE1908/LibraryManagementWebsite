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

    // 1. Mượn tại quầy: Tạo phiếu mượn và Trừ kho ngay lập tức
    public void borrowMultipleInPerson(long userId, List<String> barcodes) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                // kiểm tra ID User có hợp lệ không
                String checkUserSql = "SELECT status, full_name FROM [User] WHERE user_id = ?";
                try (PreparedStatement ps = c.prepareStatement(checkUserSql)) {
                    ps.setLong(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String uStatus = rs.getString("status");
                            if ("INACTIVE".equalsIgnoreCase(uStatus) || "BANNED".equalsIgnoreCase(uStatus)) {
                                throw new IllegalArgumentException("Tài khoản độc giả (" + rs.getString("full_name") + ") đang bị khóa, không thể mượn sách.");
                            }
                        } else {
                            throw new IllegalArgumentException("Không tìm thấy độc giả nào có ID là: " + userId);
                        }
                    }
                }

                // 1. Kiểm tra giới hạn mượn (Ví dụ: Tối đa 5 cuốn đang mượn)
                int currentBorrowed = borrowDAO.countActiveBorrows(userId);
                if (currentBorrowed + barcodes.size() > 5) {
                    throw new IllegalArgumentException("Độc giả này sẽ vượt quá giới hạn mượn (Tối đa 5 cuốn). Đang mượn: " + currentBorrowed);
                }

                java.time.LocalDate borrowDate = java.time.LocalDate.now();
                java.time.LocalDate dueDate = borrowDate.plusDays(14);

                for (String barcode : barcodes) {
                    barcode = barcode.trim();
                    if (barcode.isEmpty()) {
                        continue;
                    }

                    // 2. Tìm ID sách và Copy ID từ Barcode
                    int copyId = -1;
                    long bookId = -1;
                    String checkCopySql = "SELECT copy_id, book_id FROM BookCopy WITH (UPDLOCK) WHERE barcode = ? AND status = 'AVAILABLE'";
                    try (PreparedStatement ps = c.prepareStatement(checkCopySql)) {
                        ps.setString(1, barcode);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (rs.next()) {
                                copyId = rs.getInt("copy_id");
                                bookId = rs.getLong("book_id");
                            } else {
                                throw new IllegalArgumentException("Mã vạch '" + barcode + "' không tồn tại hoặc sách đã có người mượn.");
                            }
                        }
                    }

                    // 3. Tạo phiếu mượn riêng biệt cho từng cuốn sách
                    String insertBrSql = "INSERT INTO borrow_records(user_id, book_id, copy_id, borrow_date, due_date, status, borrow_method) "
                            + "VALUES(?, ?, ?, ?, ?, 'BORROWED', 'IN_PERSON')";
                    try (PreparedStatement ps = c.prepareStatement(insertBrSql)) {
                        ps.setLong(1, userId);
                        ps.setLong(2, bookId);
                        ps.setInt(3, copyId);
                        ps.setDate(4, java.sql.Date.valueOf(borrowDate));
                        ps.setDate(5, java.sql.Date.valueOf(dueDate));
                        ps.executeUpdate();
                    }

                    // 4. Cập nhật trạng thái sách vật lý
                    try (PreparedStatement ps = c.prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                        ps.setInt(1, copyId);
                        ps.executeUpdate();
                    }

                    // 5. Trừ số lượng kho
                    try (PreparedStatement ps = c.prepareStatement("UPDATE Book SET quantity = quantity - 1 WHERE book_id = ?")) {
                        ps.setLong(1, bookId);
                        ps.executeUpdate();
                    }

                }

                c.commit(); // Hoàn tất thành công cho TẤT CẢ mã vạch
            } catch (Exception ex) {
                c.rollback(); // Có lỗi ở bất kỳ cuốn nào thì hoàn tác toàn bộ
                throw ex;
            }
        }
    }

    // 2. Lọc nâng cao (Hỗ trợ tham số method từ Header)
    public List<BorrowRecord> searchBorrowings(String keyword, String status, String method) throws SQLException {
        List<BorrowRecord> list = new ArrayList<>();

        // Đã khôi phục ĐẦY ĐỦ các cột: user_email, book_author, book_isbn... để khớp với mapOne
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
        if (method != null && !method.trim().isEmpty()) {
            sql.append("AND br.borrow_method = ? ");
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
            if (method != null && !method.trim().isEmpty()) {
                ps.setString(idx++, method);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(borrowDAO.mapOne(rs));
                }
            }
        }
        return list;
    }
}
