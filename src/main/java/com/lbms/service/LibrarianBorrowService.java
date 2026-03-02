package com.lbms.service;

import com.lbms.dao.LibrarianBorrowDAO; // Đã đổi sang DAO mới
import com.lbms.model.BorrowRecord;
import com.lbms.util.DBConnection;
import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class LibrarianBorrowService {

    private final LibrarianBorrowDAO libDAO = new LibrarianBorrowDAO();

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

                // 2. So khớp Barcode
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
            c.setAutoCommit(false);
            try {
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

                try (PreparedStatement ps = c.prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                    ps.setInt(1, copyId);
                    ps.executeUpdate();
                }

                LocalDate borrowDate = LocalDate.now();
                LocalDate dueDate = borrowDate.plusDays(14);
                String updateBr = "UPDATE borrow_records SET status = 'BORROWED', borrow_date = ?, due_date = ?, copy_id = ? WHERE id = ?";
                try (PreparedStatement ps = c.prepareStatement(updateBr)) {
                    ps.setDate(1, java.sql.Date.valueOf(borrowDate));
                    ps.setDate(2, java.sql.Date.valueOf(dueDate));
                    ps.setInt(3, copyId);
                    ps.setLong(4, borrowId);
                    ps.executeUpdate();
                }

                try (PreparedStatement ps = c.prepareStatement("UPDATE Book SET quantity = quantity - 1 WHERE book_id = ? AND quantity > 0")) {
                    ps.setLong(1, bookIdFromCopy);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception e) {
                c.rollback();
                throw e;
            }
        }
    }

    public void rejectRequest(long borrowId) throws SQLException {
        // Sử dụng hàm updateStatus đã được copy sang libDAO
        libDAO.updateStatus(borrowId, "REJECTED");
    }

    public void borrowMultipleInPerson(long userId, List<String> barcodes) throws SQLException {
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                String checkUserSql = "SELECT status, full_name FROM [User] WHERE user_id = ?";
                try (PreparedStatement ps = c.prepareStatement(checkUserSql)) {
                    ps.setLong(1, userId);
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            String uStatus = rs.getString("status");
                            if ("INACTIVE".equalsIgnoreCase(uStatus) || "BANNED".equalsIgnoreCase(uStatus)) {
                                throw new IllegalArgumentException("Tài khoản độc giả (" + rs.getString("full_name") + ") đang bị khóa.");
                            }
                        } else {
                            throw new IllegalArgumentException("Không tìm thấy độc giả có ID: " + userId);
                        }
                    }
                }

                // Gọi hàm countActiveBorrows từ libDAO
                int currentBorrowed = libDAO.countActiveBorrows(userId);
                if (currentBorrowed + barcodes.size() > 5) {
                    throw new IllegalArgumentException("Vượt quá giới hạn mượn (Tối đa 5 cuốn). Đang mượn: " + currentBorrowed);
                }

                LocalDate borrowDate = LocalDate.now();
                LocalDate dueDate = borrowDate.plusDays(14);

                for (String barcode : barcodes) {
                    if (barcode.trim().isEmpty()) continue;

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
                                throw new IllegalArgumentException("Mã vạch '" + barcode + "' không khả dụng.");
                            }
                        }
                    }

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

                    try (PreparedStatement ps = c.prepareStatement("UPDATE BookCopy SET status = 'BORROWED' WHERE copy_id = ?")) {
                        ps.setInt(1, copyId);
                        ps.executeUpdate();
                    }

                    try (PreparedStatement ps = c.prepareStatement("UPDATE Book SET quantity = quantity - 1 WHERE book_id = ?")) {
                        ps.setLong(1, bookId);
                        ps.executeUpdate();
                    }
                }
                c.commit();
            } catch (Exception ex) {
                c.rollback();
                throw ex;
            }
        }
    }

    public List<BorrowRecord> searchBorrowings(String keyword, String status, String method) throws SQLException {
        // Logic tìm kiếm đã được tối ưu trong LibrarianBorrowDAO
        return libDAO.searchBorrowings(keyword, status, method);
    }
    
    // Hàm bổ sung để lấy chi tiết phiếu mượn qua DAO mới
    public BorrowRecord getDetail(long id) throws SQLException {
        return libDAO.findById(id);
    }
}