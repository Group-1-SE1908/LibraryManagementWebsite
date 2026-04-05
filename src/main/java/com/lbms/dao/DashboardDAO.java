package com.lbms.dao;

import com.lbms.model.DashboardSummary;
import com.lbms.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    public DashboardSummary getDashboardData(String startDate, String endDate, int userLimit) {
        DashboardSummary ds = new DashboardSummary();

        boolean hasFilter = (startDate != null && !startDate.trim().isEmpty()
                && endDate != null && !endDate.trim().isEmpty());

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                String sqlStats = "SELECT "
                        + "(SELECT COUNT(*) FROM Book) as totalBooks, "
                        + "(SELECT COUNT(*) FROM [User] WHERE status = 'ACTIVE') as activeUsers, "
                        + "(SELECT ISNULL(SUM(quantity), 0) FROM borrow_records WHERE return_date IS NULL AND due_date >= CAST(GETDATE() AS DATE)"
                        + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "") + ") as pendingReturns, "
                        + "(SELECT ISNULL(SUM(quantity), 0) FROM borrow_records WHERE return_date IS NULL AND due_date < CAST(GETDATE() AS DATE)"
                        + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "") + ") as overdueBooks, "
                        + "(SELECT ISNULL(SUM(fine_amount), 0) FROM borrow_records WHERE is_paid = 1"
                        + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "") + ") AS finesCollected, "
                        + "(SELECT ISNULL(SUM(fine_amount), 0) FROM borrow_records WHERE is_paid = 0"
                        + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "") + ") AS finesPending, "
                        + "(SELECT ISNULL(SUM(deposit_amount), 0) FROM borrow_records WHERE status IN ('BORROWED', 'REQUESTED', 'SHIPPING')"
                        + (hasFilter ? " AND borrow_date BETWEEN ? AND ?" : "") + ") AS totalDeposits, "

                        + "(SELECT ISNULL(AVG(CAST(rating AS DECIMAL(3,2))), 0) FROM Comment WHERE status = 'VISIBLE'"
                        + (hasFilter ? " AND created_at BETWEEN ? AND ?" : "") + ") AS avgRating";

                try (PreparedStatement ps = conn.prepareStatement(sqlStats)) {
                    if (hasFilter) {

                        for (int i = 1; i <= 12; i += 2) {
                            ps.setString(i, startDate);
                            ps.setString(i + 1, endDate);
                        }
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            ds.setTotalBooks(rs.getInt("totalBooks"));
                            ds.setActiveUsers(rs.getInt("activeUsers"));
                            ds.setPendingReturns(rs.getInt("pendingReturns"));
                            ds.setOverdueBooks(rs.getInt("overdueBooks"));
                            ds.setFinesCollected(rs.getDouble("finesCollected"));
                            ds.setFinesPending(rs.getDouble("finesPending"));
                            ds.setTotalDeposits(rs.getDouble("totalDeposits"));

                            ds.setAverageRating(rs.getDouble("avgRating"));
                        }
                    }
                }

                String sqlTopUsers = "SELECT TOP (?) "
                        + "u.user_id, u.full_name, u.email, u.phone, u.address, u.status, u.avatar, r.role_name, "
                        + "COUNT(br.id) as totalBorrows "
                        + "FROM [User] u "
                        + "LEFT JOIN [Role] r ON u.role_id = r.role_id "
                        + "LEFT JOIN borrow_records br ON u.user_id = br.user_id "
                        + (hasFilter ? "WHERE br.borrow_date BETWEEN ? AND ? " : "")
                        + "GROUP BY u.user_id, u.full_name, u.email, u.phone, u.address, u.status, u.avatar, r.role_name "
                        + "ORDER BY totalBorrows DESC";

                try (PreparedStatement ps = conn.prepareStatement(sqlTopUsers)) {
                    ps.setInt(1, userLimit);
                    if (hasFilter) {
                        ps.setString(2, startDate);
                        ps.setString(3, endDate);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        List<DashboardSummary.TopUser> userList = new ArrayList<>();
                        while (rs.next()) {
                            userList.add(new DashboardSummary.TopUser(
                                    rs.getInt("user_id"), rs.getString("full_name"),
                                    rs.getString("email"), rs.getString("phone"),
                                    rs.getString("address"), rs.getString("status"),
                                    rs.getString("avatar"), rs.getString("role_name"),
                                    rs.getInt("totalBorrows")));
                        }
                        ds.setTopUsers(userList);
                    }
                }

                String sqlTopBooks = "SELECT TOP 5 b.title, b.isbn, COUNT(br.id) as borrowCount "
                        + "FROM borrow_records br JOIN Book b ON br.book_id = b.book_id "
                        + (hasFilter ? "WHERE br.borrow_date BETWEEN ? AND ? " : "")
                        + "GROUP BY b.book_id, b.title, b.isbn "
                        + "ORDER BY borrowCount DESC";

                try (PreparedStatement ps = conn.prepareStatement(sqlTopBooks)) {
                    if (hasFilter) {
                        ps.setString(1, startDate);
                        ps.setString(2, endDate);
                    }
                    try (ResultSet rs = ps.executeQuery()) {
                        List<DashboardSummary.TopBook> bookList = new ArrayList<>();
                        while (rs.next()) {
                            bookList.add(new DashboardSummary.TopBook(
                                    rs.getString("title"), rs.getString("isbn"),
                                    rs.getInt("borrowCount")));
                        }
                        ds.setTopBooks(bookList);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return ds;
    }
}