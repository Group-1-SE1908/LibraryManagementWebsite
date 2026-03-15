package com.lbms.dao;

import com.lbms.model.Comment;
import com.lbms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class CommentDAO {

    // Phương thức để thêm comment
    public void insertComment(Comment c) throws Exception {

        String sql = "INSERT INTO Comment(book_id, user_id, content, rating, created_at, status) "
                + "VALUES (?, ?, ?, ?, GETDATE(), 'VISIBLE')";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, c.getBookId());
            ps.setInt(2, c.getUserId());
            ps.setString(3, c.getContent());
            ps.setInt(4, c.getRating());

            ps.executeUpdate();
        }
    }

    //Phương thức để mà hiển thị comment ( chỉ visible)
    public List<Comment> getCommentsByBook(int bookId) throws Exception {

        List<Comment> list = new ArrayList<>();

        String sql = "SELECT c.*, u.full_name, u.avatar "
                + "FROM Comment c "
                + "JOIN [User] u ON c.user_id = u.user_id "
                + "WHERE c.book_id = ? "
                + "ORDER BY c.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, bookId);

            try (ResultSet rs = ps.executeQuery()) {

                while (rs.next()) {
                    Comment c = new Comment();
                    c.setCommentId(rs.getLong("comment_id"));
                    c.setBookId(rs.getInt("book_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setContent(rs.getString("content"));
                    c.setRating(rs.getInt("rating"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setFullName(rs.getString("full_name"));
                    c.setAvatar(rs.getString("avatar"));

                    list.add(c);
                }
            }
        }

        return list;
    }

    //Phương thức để edit comment
    public boolean updateComment(Comment c) throws Exception {
        String sql = "UPDATE Comment SET content = ?, rating = ?, updated_at = GETDATE() WHERE comment_id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, c.getContent());
            ps.setInt(2, c.getRating());
            ps.setLong(3, c.getCommentId());
            ps.setInt(4, c.getUserId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    //Phương thức để edit comment (với quyền admin)
    public boolean updateComment(Comment c, boolean isAdmin) throws Exception {
        String sql;
        
        if (isAdmin) {
            sql = "UPDATE Comment SET content = ?, rating = ?, updated_at = GETDATE() WHERE comment_id = ?";
        } else {
            sql = "UPDATE Comment SET content = ?, rating = ?, updated_at = GETDATE() WHERE comment_id = ? AND user_id = ?";
        }
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, c.getContent());
            ps.setInt(2, c.getRating());
            ps.setLong(3, c.getCommentId());
            
            if (!isAdmin) {
                ps.setInt(4, c.getUserId());
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }
    }

    // Lấy danh sách toàn bộ comment (dùng cho admin) - chỉ lấy VISIBLE
    public List<Comment> listAllComments() throws Exception {
        List<Comment> list = new ArrayList<>();
        String sql = "SELECT c.*, u.full_name, u.avatar FROM Comment c JOIN [User] u ON c.user_id = u.user_id WHERE c.status = 'VISIBLE' ORDER BY c.created_at DESC";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Comment c = new Comment();
                    c.setCommentId(rs.getLong("comment_id"));
                    c.setBookId(rs.getInt("book_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setContent(rs.getString("content"));
                    c.setRating(rs.getInt("rating"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setFullName(rs.getString("full_name"));
                    c.setAvatar(rs.getString("avatar"));
                    c.setStatus(rs.getString("status"));
                    list.add(c);
                }
            }
        }
        return list;
    }

    // Tìm comment theo id
    public Comment findById(long commentId) throws Exception {
        String sql = "SELECT c.*, u.full_name, u.avatar FROM Comment c JOIN [User] u ON c.user_id = u.user_id WHERE c.comment_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, commentId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Comment c = new Comment();
                    c.setCommentId(rs.getLong("comment_id"));
                    c.setBookId(rs.getInt("book_id"));
                    c.setUserId(rs.getInt("user_id"));
                    c.setContent(rs.getString("content"));
                    c.setRating(rs.getInt("rating"));
                    c.setCreatedAt(rs.getTimestamp("created_at"));
                    c.setFullName(rs.getString("full_name"));
                    c.setAvatar(rs.getString("avatar"));
                    c.setStatus(rs.getString("status"));
                    return c;
                }
            }
        }
        return null;
    }

    // Phương thức để xóa comment
    public boolean deleteComment(long commentId, int userId, boolean isAdmin) throws Exception {

        String sql;

        if (isAdmin) {
            sql = "DELETE FROM Comment WHERE comment_id=?";
        } else {
            sql = "DELETE FROM Comment WHERE comment_id=? AND user_id=?";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, commentId);

            if (!isAdmin) {
                ps.setInt(2, userId);
            }

            return ps.executeUpdate() > 0;
        }
    }

    // Phương thức để lấy rating trung bình của một cuốn sách
    public double getAverageRating(int bookId) throws Exception {
        String sql = "SELECT AVG(CAST(rating AS FLOAT)) as avg_rating FROM Comment WHERE book_id = ? AND status = 'VISIBLE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    double avgRating = rs.getDouble("avg_rating");
                    return Double.isNaN(avgRating) ? 0 : avgRating;
                }
            }
        }
        return 0;
    }

    // Phương thức để đếm số lượt đánh giá của một cuốn sách
    public int getRatingCount(int bookId) throws Exception {
        String sql = "SELECT COUNT(*) as rating_count FROM Comment WHERE book_id = ? AND status = 'VISIBLE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("rating_count");
                }
            }
        }
        return 0;
    }

    // Phương thức kiểm tra xem user đã comment cho sách này chưa
    public boolean hasUserCommented(int bookId, int userId) throws Exception {
        String sql = "SELECT COUNT(*) as comment_count FROM Comment WHERE book_id = ? AND user_id = ? AND status = 'VISIBLE'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bookId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("comment_count") > 0;
                }
            }
        }
        return false;
    }

    // Get userId of a comment
    public int getCommentUserId(long commentId) throws Exception {
        String sql = "SELECT user_id FROM Comment WHERE comment_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, commentId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("user_id");
                }
            }
        }
        throw new Exception("Comment not found");
    }

    // Get comments that have no replies from librarians
    public List<Comment> getCommentsWithoutReplies() throws Exception {
        List<Comment> list = new ArrayList<>();

        String sql = "SELECT c.*, u.full_name, u.avatar "
                + "FROM Comment c "
                + "JOIN [User] u ON c.user_id = u.user_id "
                + "WHERE c.status = 'VISIBLE' "
                + "AND NOT EXISTS (SELECT 1 FROM CommentReply cr WHERE cr.comment_id = c.comment_id) "
                + "ORDER BY c.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Comment comment = new Comment();
                comment.setCommentId(rs.getLong("comment_id"));
                comment.setBookId(rs.getInt("book_id"));
                comment.setUserId(rs.getInt("user_id"));
                comment.setContent(rs.getString("content"));
                comment.setRating(rs.getInt("rating"));
                comment.setStatus(rs.getString("status"));
                comment.setCreatedAt(rs.getTimestamp("created_at"));
                comment.setUpdatedAt(rs.getTimestamp("updated_at"));
                comment.setDeletedAt(rs.getTimestamp("deleted_at"));
                comment.setFullName(rs.getString("full_name"));
                comment.setAvatar(rs.getString("avatar"));
                list.add(comment);
            }
        }
        return list;
    }


    /**
     * Xóa toàn bộ comment của một user (dùng khi khóa)
     */
    public void deleteAllCommentsByUser(int userId) throws Exception {
        String sql = "DELETE FROM Comment WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.executeUpdate();
        }
    }
}