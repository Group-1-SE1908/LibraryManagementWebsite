package com.lbms.dao;

import com.lbms.model.CommentReport;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CommentReportDAO {

    // Insert a new report
    public void insertReport(CommentReport report) throws SQLException {
        String sql = "INSERT INTO CommentReport (comment_id, reporter_user_id, reason, description, status) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, report.getCommentId());
            ps.setInt(2, report.getReporterUserId());
            ps.setString(3, report.getReason());
            ps.setString(4, report.getDescription());
            ps.setString(5, report.getStatus());

            ps.executeUpdate();
        }
    }

    // Check if user has already reported this comment
    public boolean hasUserReportedComment(int userId, long commentId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM CommentReport WHERE reporter_user_id = ? AND comment_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            ps.setLong(2, commentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }

    /**
     * Cập nhật description (chi tiết hành động xử lý)
     */
    public void updateDescription(long reportId, String description) throws SQLException {
        String sql = "UPDATE CommentReport SET description = ? WHERE report_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, description);
            ps.setLong(2, reportId);
            ps.executeUpdate();
        }
    }

    // Get all reports for admin
    public List<CommentReport> getAllReports() throws SQLException {
        List<CommentReport> reports = new ArrayList<>();
        String sql = "SELECT cr.*, u1.full_name AS reporter_full_name, c.content AS comment_content, u2.full_name AS comment_user_full_name "
                +
                "FROM CommentReport cr " +
                "JOIN [User] u1 ON cr.reporter_user_id = u1.user_id " +
                "JOIN Comment c ON cr.comment_id = c.comment_id " +
                "JOIN [User] u2 ON c.user_id = u2.user_id " +
                "ORDER BY cr.report_time DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                CommentReport report = new CommentReport();
                report.setReportId(rs.getLong("report_id"));
                report.setCommentId(rs.getLong("comment_id"));
                report.setReporterUserId(rs.getInt("reporter_user_id"));
                report.setReason(rs.getString("reason"));
                report.setDescription(rs.getString("description"));
                report.setReportTime(rs.getTimestamp("report_time"));
                report.setStatus(rs.getString("status"));
                report.setReporterFullName(rs.getString("reporter_full_name"));
                report.setCommentContent(rs.getString("comment_content"));
                report.setCommentUserFullName(rs.getString("comment_user_full_name"));
                reports.add(report);
            }
        }
        return reports;
    }

    // Update report status
    public void updateReportStatus(long reportId, String status) throws SQLException {
        String sql = "UPDATE CommentReport SET status = ? WHERE report_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, status);
            ps.setLong(2, reportId);

            ps.executeUpdate();
        }
    }

    // Delete comment (set status to DELETED or actually delete)
    public void deleteComment(long commentId) throws SQLException {
        String sql = "UPDATE Comment SET status = 'DELETED', deleted_at = GETDATE() WHERE comment_id = ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, commentId);

            ps.executeUpdate();
        }
    }

    // Get reports for a specific book (for librarians) - only pending reports
    public List<CommentReport> getReportsByBook(long bookId) throws SQLException {
        List<CommentReport> reports = new ArrayList<>();
        String sql = "SELECT cr.*, u1.full_name AS reporter_full_name, c.content AS comment_content, u2.full_name AS comment_user_full_name " +
                     "FROM CommentReport cr " +
                     "JOIN [User] u1 ON cr.reporter_user_id = u1.user_id " +
                     "JOIN Comment c ON cr.comment_id = c.comment_id " +
                     "JOIN [User] u2 ON c.user_id = u2.user_id " +
                     "JOIN Book b ON c.book_id = b.book_id " +
                     "WHERE b.book_id = ? AND cr.status = 'PENDING' " +
                     "ORDER BY cr.report_time DESC";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CommentReport report = new CommentReport();
                    report.setReportId(rs.getLong("report_id"));
                    report.setCommentId(rs.getLong("comment_id"));
                    report.setReporterUserId(rs.getInt("reporter_user_id"));
                    report.setReason(rs.getString("reason"));
                    report.setDescription(rs.getString("description"));
                    report.setReportTime(rs.getTimestamp("report_time"));
                    report.setStatus(rs.getString("status"));
                    report.setReporterFullName(rs.getString("reporter_full_name"));
                    report.setCommentContent(rs.getString("comment_content"));
                    report.setCommentUserFullName(rs.getString("comment_user_full_name"));
                    reports.add(report);
                }
            }
        }
        return reports;
    }
}