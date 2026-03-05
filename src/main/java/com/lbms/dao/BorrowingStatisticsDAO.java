package com.lbms.dao;

import com.lbms.model.BorrowingStatistics;
import com.lbms.util.DBConnection;
import java.sql.*;
import java.util.*;

public class BorrowingStatisticsDAO {

    public BorrowingStatistics getStatistics(String startDate, String endDate) throws SQLException {
        BorrowingStatistics stats = new BorrowingStatistics();
        boolean hasFilter = (startDate != null && !startDate.isEmpty() && endDate != null && !endDate.isEmpty());

        try (Connection conn = DBConnection.getConnection()) {
            // Tổng số sách
            String sqlBooks = "SELECT COUNT(*) FROM Book";
            try (PreparedStatement stmt = conn.prepareStatement(sqlBooks);
                    ResultSet rs = stmt.executeQuery()) {
                if (rs.next())
                    stats.setTotalBooks(rs.getInt(1));
            }

            // Người dùng hoạt động
            String sqlUsers = "SELECT COUNT(*) FROM [User] WHERE status = 'ACTIVE'";
            try (PreparedStatement stmt = conn.prepareStatement(sqlUsers);
                    ResultSet rs = stmt.executeQuery()) {
                if (rs.next())
                    stats.setActiveUsers(rs.getInt(1));
            }

            // Tổng lượt mượn
            String sqlBorrows = "SELECT COUNT(*) FROM borrow_records WHERE 1=1"
                    + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "");
            try (PreparedStatement stmt = conn.prepareStatement(sqlBorrows)) {
                if (hasFilter) {
                    stmt.setString(1, startDate);
                    stmt.setString(2, endDate);
                }
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next())
                        stats.setTotalBorrows(rs.getInt(1));
                }
            }

            // 4. Sách quá hạn
            String sqlOverdue = "SELECT COUNT(*) FROM borrow_records WHERE (status = 'OVERDUE' OR (due_date < GETDATE() AND return_date IS NULL))"
                    + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "");
            try (PreparedStatement stmt = conn.prepareStatement(sqlOverdue)) {
                if (hasFilter) {
                    stmt.setString(1, startDate);
                    stmt.setString(2, endDate);
                }
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next())
                        stats.setOverdueBooks(rs.getInt(1));
                }
            }

            // 5. Thống kê trạng thái
            String sqlStatus = "SELECT status, COUNT(*) FROM borrow_records WHERE 1=1"
                    + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "") + " GROUP BY status";
            Map<String, Integer> statusMap = new HashMap<>();
            try (PreparedStatement stmt = conn.prepareStatement(sqlStatus)) {
                if (hasFilter) {
                    stmt.setString(1, startDate);
                    stmt.setString(2, endDate);
                }
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next())
                        statusMap.put(rs.getString(1), rs.getInt(2));
                }
            }
            stats.setStatusCounts(statusMap);

            // Top 5 sách mượn nhiều nhất
            String sqlTop = "SELECT TOP 5 b.title, c.category_name, COUNT(br.id) as bc " +
                    "FROM borrow_records br JOIN Book b ON br.book_id = b.book_id " +
                    "JOIN Category c ON b.category_id = c.category_id " +
                    "WHERE 1=1" + (hasFilter ? " AND br.borrow_date BETWEEN ? AND ?" : "") +
                    " GROUP BY b.title, c.category_name ORDER BY bc DESC";
            List<BorrowingStatistics.TopBook> topList = new ArrayList<>();
            try (PreparedStatement stmt = conn.prepareStatement(sqlTop)) {
                if (hasFilter) {
                    stmt.setString(1, startDate);
                    stmt.setString(2, endDate);
                }
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        topList.add(new BorrowingStatistics.TopBook(rs.getString(1), rs.getString(2), rs.getInt(3)));
                    }
                }
            }
            stats.setTopBooks(topList);

            // DANH SÁCH CHI TIẾT
            String sqlDetailed = "SELECT br.id, u.full_name, u.email, b.title, bc.barcode, " +
                    "br.borrow_date, br.due_date, br.return_date, br.status, br.fine_amount " +
                    "FROM borrow_records br " +
                    "JOIN [User] u ON br.user_id = u.user_id " +
                    "JOIN Book b ON br.book_id = b.book_id " +
                    "LEFT JOIN BookCopy bc ON br.copy_id = bc.copy_id " + // Lấy Barcode từ bảng Copy
                    "WHERE 1=1 " + (hasFilter ? "AND br.borrow_date BETWEEN ? AND ?" : "") +
                    " ORDER BY br.borrow_date DESC";

            List<BorrowingStatistics.BorrowingDetail> detailedList = new ArrayList<>();
            try (PreparedStatement stmt = conn.prepareStatement(sqlDetailed)) {
                if (hasFilter) {
                    stmt.setString(1, startDate);
                    stmt.setString(2, endDate);
                }
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        detailedList.add(new BorrowingStatistics.BorrowingDetail(
                                rs.getInt("id"),
                                rs.getString("full_name"),
                                rs.getString("email"),
                                rs.getString("title"),
                                rs.getString("barcode"),
                                rs.getString("borrow_date"),
                                rs.getString("due_date"),
                                rs.getString("return_date"),
                                rs.getString("status"),
                                rs.getDouble("fine_amount")));
                    }
                }
            }
            stats.setDetailedRecords(detailedList);
        }
        return stats;
    }
}