package com.lbms.dao;

import com.lbms.model.Reservation;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ReservationDAO {

    // ── existsActive: kiểm tra user đã có reservation đang active cho book chưa ──
    public boolean existsActive(long userId, long bookId) throws SQLException {
        String sql = "SELECT COUNT(1) FROM reservations " +
                "WHERE user_id = ? AND book_id = ? " +
                "AND status IN ('WAITING', 'AVAILABLE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ResultSet rs = ps.executeQuery();
            return rs.next() && rs.getInt(1) > 0;
        }
    }

    // ── countActive: đếm số reservation đang active của user (để check giới hạn) ──
    public int countActive(long userId) throws SQLException {
        String sql = "SELECT COUNT(1) FROM reservations " +
                "WHERE user_id = ? AND status IN ('WAITING', 'AVAILABLE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    // ── getNextQueuePosition: lấy vị trí kế tiếp trong hàng chờ của 1 cuốn sách ──
    public int getNextQueuePosition(long bookId) throws SQLException {
        String sql = "SELECT ISNULL(MAX(queue_position), 0) + 1 " +
                "FROM reservations " +
                "WHERE book_id = ? AND status IN ('WAITING', 'AVAILABLE')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 1;
        }
    }

    // ── create: insert reservation mới với queue_position, trả về id vừa tạo ──
    public long create(long userId, long bookId, int queuePosition) throws SQLException {
        String sql = "INSERT INTO reservations " +
                "(user_id, book_id, status, queue_position, created_at) " +
                "VALUES (?, ?, 'WAITING', ?, GETDATE())";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql,
                     Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ps.setInt(3, queuePosition);
            ps.executeUpdate();
            ResultSet keys = ps.getGeneratedKeys();
            if (keys.next()) return keys.getLong(1);
            throw new SQLException("Không lấy được ID sau khi insert reservation");
        }
    }

    // ── reactivate: kích hoạt lại reservation CANCELLED/EXPIRED với queue mới ──
    public void reactivate(long reservationId, int queuePosition) throws SQLException {
        String sql = "UPDATE reservations " +
                "SET status = 'WAITING', " +
                "    queue_position = ?, " +
                "    notified_at = NULL, " +
                "    expired_at = NULL, " +
                "    updated_at = GETDATE() " +
                "WHERE id = ? AND status IN ('CANCELLED', 'EXPIRED')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, queuePosition);
            ps.setLong(2, reservationId);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new IllegalStateException("Không thể tái kích hoạt reservation");
            }
        }
    }

    // ── cancel: hủy reservation của chính user (đang WAITING hoặc AVAILABLE) ──
    public void cancel(long reservationId, long userId) throws SQLException {
        // Lấy thông tin trước khi hủy để re-order queue
        Reservation res = getById(reservationId);

        String sql = "UPDATE reservations " +
                "SET status = 'CANCELLED', " +
                "    queue_position = NULL, " +
                "    updated_at = GETDATE() " +
                "WHERE id = ? AND user_id = ? " +
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

        // Re-order queue: giảm queue_position của các người sau xuống 1
        if (res != null && res.getQueuePosition() != null) {
            reorderQueueAfterRemoval(res.getBookId(), res.getQueuePosition());
        }
    }

    // ── reorderQueueAfterRemoval: cập nhật lại queue_position sau khi 1 người rời hàng ──
    private void reorderQueueAfterRemoval(long bookId, int removedPosition) throws SQLException {
        String sql = "UPDATE reservations " +
                "SET queue_position = queue_position - 1, " +
                "    updated_at = GETDATE() " +
                "WHERE book_id = ? " +
                "AND status IN ('WAITING', 'AVAILABLE') " +
                "AND queue_position > ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ps.setInt(2, removedPosition);
            ps.executeUpdate();
        }
    }

    // ── updateStatus: cập nhật status, tùy chọn set expired_at và notified_at ──
    public void updateStatus(long reservationId, String status) throws SQLException {
        String sql = "UPDATE reservations SET status = ?, updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, reservationId);
            ps.executeUpdate();
        }
    }

    // ── markAvailable: set status=AVAILABLE, notified_at=now, expired_at=now+3days ──
    public void markAvailable(long reservationId) throws SQLException {
        String sql = "UPDATE reservations " +
                "SET status = 'AVAILABLE', " +
                "    notified_at = GETDATE(), " +
                "    expired_at = DATEADD(DAY, 3, GETDATE()), " +
                "    queue_position = 1, " +
                "    updated_at = GETDATE() " +
                "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            ps.executeUpdate();
        }
    }

    // ── getFirstWaiting: lấy người đầu tiên trong hàng chờ của 1 cuốn sách ──
    public Reservation getFirstWaiting(long bookId) throws SQLException {
        String sql = "SELECT TOP 1 r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.book_id = ? AND r.status = 'WAITING' " +
                "ORDER BY r.queue_position ASC, r.created_at ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
            return null;
        }
    }

    // ── findExpiredAvailable: tìm các reservation AVAILABLE đã quá hạn ──
    public List<Reservation> findExpiredAvailable() throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.status = 'AVAILABLE' " +
                "AND r.expired_at IS NOT NULL " +
                "AND r.expired_at < GETDATE()";
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // ── findExpiringAvailable: tìm AVAILABLE sắp hết hạn trong vòng 1 ngày (để nhắc nhở) ──
    public List<Reservation> findExpiringAvailable() throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.status = 'AVAILABLE' " +
                "AND r.expired_at IS NOT NULL " +
                "AND r.expired_at BETWEEN GETDATE() AND DATEADD(DAY, 1, GETDATE()) " +
                "AND r.note NOT LIKE '%REMINDED%'";
        List<Reservation> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) list.add(mapRow(rs));
        }
        return list;
    }

    // ── markReminded: đánh dấu đã nhắc để không gửi lại ──
    public void markReminded(long reservationId) throws SQLException {
        String sql = "UPDATE reservations SET note = ISNULL(note,'') + ' [REMINDED]', " +
                "updated_at = GETDATE() WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, reservationId);
            ps.executeUpdate();
        }
    }

    // ── findByUserAndBook: tìm reservation CANCELLED/EXPIRED của user cho book ──
    public Reservation findCancelledOrExpired(long userId, long bookId) throws SQLException {
        String sql = "SELECT TOP 1 r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image " +
                "FROM reservations r " +
                "INNER JOIN Book b ON r.book_id = b.book_id " +
                "WHERE r.user_id = ? AND r.book_id = ? " +
                "AND r.status IN ('CANCELLED', 'EXPIRED') " +
                "ORDER BY r.updated_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setLong(2, bookId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
            return null;
        }
    }

    // ── listByUser ──────────────────────────────────────────────────────────
    public List<Reservation> listByUser(long userId) throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image " +
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

    // ── listAll: toàn bộ (dành cho Librarian/Admin) ─────────────────────────
    public List<Reservation> listAll() throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image, " +
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

    // ── getById ──────────────────────────────────────────────────────────────
    public Reservation getById(long id) throws SQLException {
        String sql = "SELECT r.id, r.user_id, r.book_id, r.status, " +
                "r.note, r.notified_at, r.expired_at, r.queue_position, " +
                "r.created_at, r.updated_at, " +
                "b.title AS book_title, b.author AS book_author, b.image AS book_image " +
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

    // ── mapRow helper ────────────────────────────────────────────────────────
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
        // queue_position có thể NULL
        int qp = rs.getInt("queue_position");
        r.setQueuePosition(rs.wasNull() ? null : qp);
        return r;
    }
}