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
                + "WHERE c.book_id = ? AND c.status = 'VISIBLE' "
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

    // Phương thức để xóa comment
    public boolean deleteComment(long commentId, int userId, boolean isAdmin) throws Exception {

        String sql;

        if (isAdmin) {
            sql = "UPDATE Comment SET status='DELETED', deleted_at=GETDATE() WHERE comment_id=?";
        } else {
            sql = "UPDATE Comment SET status='DELETED', deleted_at=GETDATE() WHERE comment_id=? AND user_id=?";
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
}