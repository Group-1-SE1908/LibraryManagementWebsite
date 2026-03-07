package com.lbms.dao;

import com.lbms.model.*;
import com.lbms.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class LibrarianActivityLogDAO {

    public List<LibrarianActivityLog> getAllActivityLogs() {

        List<LibrarianActivityLog> logs = new ArrayList<>();

        String sql = "SELECT l.log_id, l.action, l.timestamp, " +
                "u.user_id, u.full_name, u.email, u.avatar, " +
                "r.role_id, r.role_name " +
                "FROM LibrarianActivityLog l " +
                "INNER JOIN [User] u ON l.user_id = u.user_id " +
                "INNER JOIN [Role] r ON u.role_id = r.role_id " + "WHERE r.role_name = 'LIBRARIAN' " +
                "ORDER BY l.log_id ASC";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement stmt = c.prepareStatement(sql);
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {

                // ROLE
                Role role = new Role();
                role.setId(rs.getInt("role_id"));
                role.setName(rs.getString("role_name"));

                // USER
                User user = new User();
                user.setId(rs.getInt("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setAvatar(rs.getString("avatar"));
                user.setRole(role);

                // LOG
                LibrarianActivityLog log = new LibrarianActivityLog();
                log.setLogId(rs.getInt("log_id"));
                log.setAction(rs.getString("action"));
                log.setTimestamp(rs.getTimestamp("timestamp"));
                log.setUser(user);

                logs.add(log);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return logs;
    }

    public void addActivityLog(int userId, String action) {

        String sql = "INSERT INTO LibrarianActivityLog (user_id, action, timestamp) " +
                "VALUES (?, ?, CURRENT_TIMESTAMP)";

        try (Connection c = DBConnection.getConnection();
                PreparedStatement stmt = c.prepareStatement(sql)) {

            stmt.setInt(1, userId);
            stmt.setString(2, action);
            stmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public List<LibrarianActivityLog> getActivityLogsFiltered(String filterType) {
        List<LibrarianActivityLog> logs = new ArrayList<>();

        // Base SQL
        StringBuilder sql = new StringBuilder(
                "SELECT l.log_id, l.action, l.timestamp, " +
                        "u.user_id, u.full_name, u.email, u.avatar, " +
                        "r.role_id, r.role_name " +
                        "FROM LibrarianActivityLog l " +
                        "INNER JOIN [User] u ON l.user_id = u.user_id " +
                        "INNER JOIN [Role] r ON u.role_id = r.role_id " +
                        "WHERE r.role_name = 'LIBRARIAN' ");

        if ("BOOK".equals(filterType)) {
            // Lọc các hoạt động Thêm, Sửa, Xóa sách
            sql.append(
                    "AND (l.action LIKE N'%Thêm sách%' OR l.action LIKE N'%Cập nhật sách%' OR l.action LIKE N'%Xóa sách%') ");
        } else if ("BORROW".equals(filterType)) {
            // Lọc các hoạt động Duyệt, Từ chối, Nhận trả sách
            sql.append(
                    "AND (l.action LIKE N'%Duyệt%' OR l.action LIKE N'%Từ chối%' OR l.action LIKE N'%trả sách%' OR l.action LIKE N'%mượn trực tiếp%') ");
        }

        sql.append("ORDER BY l.log_id DESC"); // Để log mới nhất hiện lên đầu

        try (Connection c = DBConnection.getConnection();
                PreparedStatement stmt = c.prepareStatement(sql.toString());
                ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Role role = new Role();
                role.setId(rs.getInt("role_id"));
                role.setName(rs.getString("role_name"));

                User user = new User();
                user.setId(rs.getInt("user_id"));
                user.setFullName(rs.getString("full_name"));
                user.setEmail(rs.getString("email"));
                user.setAvatar(rs.getString("avatar"));
                user.setRole(role);

                LibrarianActivityLog log = new LibrarianActivityLog();
                log.setLogId(rs.getInt("log_id"));
                log.setAction(rs.getString("action"));
                log.setTimestamp(rs.getTimestamp("timestamp"));
                log.setUser(user);

                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
}