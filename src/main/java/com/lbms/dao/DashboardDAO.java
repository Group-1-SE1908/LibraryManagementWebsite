package com.lbms.dao;

import com.lbms.model.DashboardModel;
import com.lbms.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    public DashboardModel getDashboardData(String startDate, String endDate, int userLimit) {
        DashboardModel ds = new DashboardModel();

        String start = (startDate == null || startDate.trim().isEmpty()) ? "1900-01-01" : startDate;
        String end = (endDate == null || endDate.trim().isEmpty()) ? "2099-12-31" : endDate;

        String sqlStats = "SELECT "
                + "(SELECT COUNT(*) FROM Book) as totalBooks, "
                + "(SELECT COUNT(*) FROM [User] WHERE status = 'ACTIVE') as activeUsers, "
                + "(SELECT COUNT(*) FROM borrow_records WHERE return_date IS NULL AND due_date >= CAST(GETDATE() AS DATE) AND borrow_date BETWEEN ? AND ?) as pendingReturns, "
                + "(SELECT COUNT(*) FROM borrow_records WHERE return_date IS NULL AND due_date < CAST(GETDATE() AS DATE) AND borrow_date BETWEEN ? AND ?) as overdueBooks, "
                + "(SELECT ISNULL(SUM(fine_amount), 0) FROM borrow_records WHERE is_paid = 1 AND borrow_date BETWEEN ? AND ?) AS finesCollected, "
                + "(SELECT ISNULL(SUM(fine_amount), 0) FROM borrow_records WHERE is_paid = 0 AND borrow_date BETWEEN ? AND ?) AS finesPending";

        String sqlTopUsers = "SELECT TOP (?) "
                + "u.user_id, u.full_name, u.email, u.phone, u.address, u.status, u.avatar, r.role_name, "
                + "COUNT(br.id) as totalBorrows "
                + "FROM [User] u "
                + "LEFT JOIN [Role] r ON u.role_id = r.role_id "
                + "LEFT JOIN borrow_records br ON u.user_id = br.user_id "
                + "WHERE br.borrow_date BETWEEN ? AND ? OR br.borrow_date IS NULL "
                + "GROUP BY u.user_id, u.full_name, u.email, u.phone, u.address, u.status, u.avatar, r.role_name "
                + "ORDER BY totalBorrows DESC";

        String sqlTopBooks = "SELECT TOP 5 "
                + "b.title, b.isbn, COUNT(br.id) as borrowCount "
                + "FROM borrow_records br "
                + "JOIN Book b ON br.book_id = b.book_id "
                + "WHERE br.borrow_date BETWEEN ? AND ? "
                + "GROUP BY b.book_id, b.title, b.isbn "
                + "ORDER BY borrowCount DESC";

        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {

                try (PreparedStatement ps = conn.prepareStatement(sqlStats)) {
                    ps.setString(1, start);
                    ps.setString(2, end);
                    ps.setString(3, start);
                    ps.setString(4, end);
                    ps.setString(5, start);
                    ps.setString(6, end);
                    ps.setString(7, start);
                    ps.setString(8, end);

                    try (ResultSet rs = ps.executeQuery()) {
                        if (rs.next()) {
                            ds.setTotalBooks(rs.getInt("totalBooks"));
                            ds.setActiveUsers(rs.getInt("activeUsers"));
                            ds.setPendingReturns(rs.getInt("pendingReturns"));
                            ds.setOverdueBooks(rs.getInt("overdueBooks"));
                            ds.setFinesCollected(rs.getDouble("finesCollected"));
                            ds.setFinesPending(rs.getDouble("finesPending"));
                        }
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlTopUsers)) {
                    ps.setInt(1, userLimit);
                    ps.setString(2, start);
                    ps.setString(3, end);
                    try (ResultSet rs = ps.executeQuery()) {
                        List<DashboardModel.TopUser> userList = new ArrayList<>();
                        while (rs.next()) {
                            userList.add(new DashboardModel.TopUser(
                                    rs.getInt("user_id"),
                                    rs.getString("full_name"),
                                    rs.getString("email"),
                                    rs.getString("phone"),
                                    rs.getString("address"),
                                    rs.getString("status"),
                                    rs.getString("avatar"),
                                    rs.getString("role_name"),
                                    rs.getInt("totalBorrows")));
                        }
                        ds.setTopUsers(userList);
                    }
                }

                try (PreparedStatement ps = conn.prepareStatement(sqlTopBooks)) {
                    ps.setString(1, start);
                    ps.setString(2, end);
                    try (ResultSet rs = ps.executeQuery()) {
                        List<DashboardModel.TopBook> bookList = new ArrayList<>();
                        while (rs.next()) {
                            bookList.add(new DashboardModel.TopBook(
                                    rs.getString("title"),
                                    rs.getString("isbn"),
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