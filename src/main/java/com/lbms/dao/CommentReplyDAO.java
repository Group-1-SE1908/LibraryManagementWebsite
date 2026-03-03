package com.lbms.dao;

import com.lbms.model.CommentReply;
import com.lbms.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class CommentReplyDAO {

    public void insertReply(CommentReply reply) throws Exception {
        String sql = "INSERT INTO CommentReply(comment_id, admin_id, content, created_at) VALUES (?, ?, ?, GETDATE())";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, reply.getCommentId());
            ps.setInt(2, reply.getAdminId());
            ps.setString(3, reply.getContent());

            ps.executeUpdate();
        }
    }

    public List<CommentReply> findByCommentId(long commentId) throws Exception {
        List<CommentReply> list = new ArrayList<>();

        String sql =
                "SELECT cr.comment_reply_id, cr.comment_id, cr.admin_id, cr.content, cr.created_at, u.full_name " +
                        "FROM CommentReply cr " +
                        "INNER JOIN [User] u ON cr.admin_id = u.user_id " +
                        "WHERE cr.comment_id = ? " +
                        "ORDER BY cr.created_at ASC";

        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setLong(1, commentId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CommentReply r = new CommentReply();
                    r.setReplyId(rs.getLong("comment_reply_id"));
                    r.setCommentId(rs.getLong("comment_id"));
                    r.setAdminId(rs.getInt("admin_id"));
                    r.setContent(rs.getString("content"));
                    r.setAdminName(rs.getString("full_name"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(r);
                }
            }
        }

        return list;
    }

    // Cập nhật reply
    public boolean updateReply(long replyId, String content, int adminId) throws Exception {
        String sql = "UPDATE CommentReply SET content = ? WHERE comment_reply_id = ? AND admin_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, content);
            ps.setLong(2, replyId);
            ps.setInt(3, adminId);
            return ps.executeUpdate() > 0;
        }
    }

    // Xóa reply
    public boolean deleteReply(long replyId, int adminId) throws Exception {
        String sql = "DELETE FROM CommentReply WHERE comment_reply_id = ? AND admin_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, replyId);
            ps.setInt(2, adminId);
            return ps.executeUpdate() > 0;
        }
    }

    // Tìm reply theo ID
    public CommentReply findById(long replyId) throws Exception {
        String sql = "SELECT cr.comment_reply_id, cr.comment_id, cr.admin_id, cr.content, cr.created_at, u.full_name " +
                     "FROM CommentReply cr " +
                     "INNER JOIN [User] u ON cr.admin_id = u.user_id " +
                     "WHERE cr.comment_reply_id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, replyId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    CommentReply r = new CommentReply();
                    r.setReplyId(rs.getLong("comment_reply_id"));
                    r.setCommentId(rs.getLong("comment_id"));
                    r.setAdminId(rs.getInt("admin_id"));
                    r.setContent(rs.getString("content"));
                    r.setAdminName(rs.getString("full_name"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    return r;
                }
            }
        }
        return null;
    }

}