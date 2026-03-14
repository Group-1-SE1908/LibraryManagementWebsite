package com.lbms.dao;

import com.lbms.model.Reservation;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    // ── existsActive: Service gọi để kiểm tra đã reserve chưa ────────────
    public boolean existsActive(long userId, long bookId) throws SQLException {
        String sql = "SELECT COUNT(1) FROM reservations " +
                "WHERE user_id = ? AND book_id = ? " +
                "AND status NOT IN ('CANCELLED', 'EXPIRED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    // ── findByUserAndBook: tìm reservation của user cho book ───────────────
    public Reservation findByUserAndBook(long userId, long bookId) throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, " +
                "b.author AS book_author, " +
                "b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.user_id = ? AND r.book_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
            return null;
        }
    }

    // ── create: insert reservation mới, trả về id vừa tạo ────────────────
    public long create(long userId, long bookId) throws SQLException {
        String sql = "INSERT INTO reservations (user_id, book_id, status, created_at) " +
                "VALUES (?, ?, 'WAITING', GETDATE())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql,
                     Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getLong(1);
            throw new SQLException("Không lấy được ID sau khi insert reservation");
        }
    }

    // ── cancel: hủy reservation (chỉ của chính user, đang WAITING/AVAILABLE)
    public void cancel(long reservationId, long userId) throws SQLException {
        String sql = "UPDATE reservations " +
                "SET status = 'CANCELLED', " +
                "updated_at = GETDATE() " +
                "WHERE id = ? " +
                "AND user_id = ? " +
                "AND status IN ('WAITING', 'AVAILABLE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            ps.setLong(2, userId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new IllegalStateException(
                        "Không thể hủy: reservation không tồn tại hoặc không thuộc về bạn");
            }
        }
    }

    // ── updateStatus: cập nhật status của reservation ──────────────────────
    public void updateStatus(long reservationId, String status) throws SQLException {
        String sql = "UPDATE reservations SET status = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, reservationId);
            ps.executeUpdate();
        }
    }

    // ── listByUser: danh sách reserve của 1 user, kèm thông tin sách ──────
    public List<Reservation> listByUser(long userId) throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, " +
                "b.author AS book_author, " +
                "b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.user_id = ? " +
                "ORDER BY r.created_at DESC";
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // ── listAll: toàn bộ reservations (dành cho Librarian/Admin) ──────────
    public List<Reservation> listAll() throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, " +
                "b.author AS book_author, " +
                "b.image AS book_image, " +
                "u.full_name AS user_name " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "INNER JOIN [User] u ON r.user_id = u.user_id " +
                "ORDER BY r.created_at DESC";
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Reservation r = mapRow(rs);
                r.setUserName(rs.getString("user_name"));
                list.add(r);
            }
        }
        return list;
    }

    // ── getById ───────────────────────────────────────────────────────────
    public Reservation getById(long id) throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, " +
                "b.author AS book_author, " +
                "b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        }
        return null;
    }

    // ── mapRow helper ─────────────────────────────────────────────────────
    private Reservation mapRow(ResultSet rs) throws SQLException {
        Reservation r = new Reservation();
        r.setId(rs.getLong("id"));
        r.setUserId(rs.getInt("user_id"));
        r.setBookId(rs.getInt("book_id"));
        r.setStatus(rs.getString("status"));
        r.setNote(rs.getString("note"));
        r.setNotifiedAt(rs.getTimestamp("notified_at"));
        r.setExpiredAt(rs.getTimestamp("expired_at"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        r.setBookTitle(rs.getString("book_title"));
        r.setBookAuthor(rs.getString("book_author"));
        r.setBookImage(rs.getString("book_image"));
        return r;
    }
}