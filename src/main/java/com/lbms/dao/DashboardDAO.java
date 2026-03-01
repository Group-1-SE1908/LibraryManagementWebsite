/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.lbms.dao;

import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.*;

public class DashboardDAO {

    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();

        String query = """
                    SELECT
                        (SELECT COUNT(*) FROM Book) as totalBooks,
                        (SELECT COUNT(*) FROM [User] WHERE status = 'ACTIVE') as activeUsers,
                        (SELECT COUNT(*) FROM borrow_records
                         WHERE status IN ('BORROWED', 'OVERDUE')
                         AND return_date IS NULL) as pendingReturns,
                        (SELECT COUNT(*) FROM borrow_records
                         WHERE borrow_method = 'DELIVERY'
                         AND borrow_date >= DATEADD(MONTH, -1, GETDATE())) as totalShipments
                """;

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query);
                ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                stats.put("totalBooks", rs.getInt("totalBooks"));
                stats.put("activeUsers", rs.getInt("activeUsers"));
                stats.put("pendingReturns", rs.getInt("pendingReturns"));
                stats.put("totalShipments", rs.getInt("totalShipments"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            stats.put("totalBooks", 0);
            stats.put("activeUsers", 0);
            stats.put("pendingReturns", 0);
            stats.put("totalShipments", 0);
        }

        return stats;
    }

    public List<Map<String, Object>> getTopBorrowers(int limit) {
        List<Map<String, Object>> topBorrowers = new ArrayList<>();

        String query = """
                    SELECT TOP(?)
                        u.user_id,
                        u.full_name,
                        u.email,
                        u.phone,
                        u.address,
                        u.status,
                        r.role_name,
                        COUNT(DISTINCT br.id) as totalBorrows,
                        MAX(br.borrow_date) as lastBorrowDate
                    FROM [User] u
                    LEFT JOIN [Role] r ON u.role_id = r.role_id
                    LEFT JOIN borrow_records br ON u.user_id = br.user_id
                    GROUP BY u.user_id, u.full_name, u.email, u.phone, u.address, u.status, r.role_name
                    ORDER BY totalBorrows DESC
                """;

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(query)) {

            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> user = new HashMap<>();
                    user.put("userId", rs.getInt("user_id"));
                    user.put("fullName", rs.getString("full_name"));
                    user.put("email", rs.getString("email"));
                    user.put("phone", rs.getString("phone")); // Thêm mới
                    user.put("address", rs.getString("address")); // Thêm mới
                    user.put("status", rs.getString("status"));
                    user.put("roleName", rs.getString("role_name"));
                    user.put("totalBorrows", rs.getInt("totalBorrows"));

                    Timestamp lastBorrow = rs.getTimestamp("lastBorrowDate");
                    user.put("lastActive", lastBorrow != null ? calculateTimeAgo(lastBorrow) : "Never");

                    topBorrowers.add(user);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return topBorrowers;
    }

    private String calculateTimeAgo(Timestamp timestamp) {
        long diff = System.currentTimeMillis() - timestamp.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;

        if (days > 0) {
            return days + " day" + (days > 1 ? "s" : "") + " ago";
        } else if (hours > 0) {
            return hours + " hour" + (hours > 1 ? "s" : "") + " ago";
        } else if (minutes > 0) {
            return minutes + " min" + (minutes > 1 ? "s" : "") + " ago";
        } else {
            return "Just now";
        }
    }
}
