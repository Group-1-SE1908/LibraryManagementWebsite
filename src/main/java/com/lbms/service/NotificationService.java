package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class NotificationService {

    private static final Logger logger = Logger.getLogger(NotificationService.class.getName());

    private final EmailService emailService = new EmailService();
    private final UserDAO userDAO = new UserDAO();

    // ════════════════════════════════════════════════════════════════
    // SỰ KIỆN 1: Sách đã có sẵn
    // ════════════════════════════════════════════════════════════════
    public void notifyBookAvailable(long userId, String bookTitle) throws SQLException {
        String title = "Sách đã sẵn sàng để nhận!";
        String message = "Cuốn sách \"" + bookTitle + "\" bạn đặt trước đã có sẵn. " +
                "Vui lòng đến thư viện nhận sách trong vòng 3 ngày. " +
                "Nếu không đến đúng hạn, đặt trước sẽ bị hủy tự động.";
        insertNotification(userId, "RESERVATION_AVAILABLE", title, message);
        try {
            sendEmail(userId, "📚 " + title, buildEmailHtml(
                    "📚 Sách đã sẵn sàng!",
                    "Cuốn sách <strong>\"" + bookTitle + "\"</strong> bạn đặt trước đã có sẵn tại thư viện.",
                    "⚠️ Bạn có <strong>3 ngày</strong> để đến nhận sách. Sau thời hạn, đặt trước sẽ bị hủy tự động.",
                    "#22c55e", "🏃 Đến nhận sách ngay"));
        } catch (Exception e) {
            logger.log(Level.WARNING, "[Notification] Bỏ qua lỗi email userId=" + userId + ": " + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════
    // SỰ KIỆN 2: Sắp hết hạn
    // ════════════════════════════════════════════════════════════════
    public void notifyBookExpiringSoon(long userId, String bookTitle,
            Timestamp expiredAt) throws SQLException {
        String deadline = new SimpleDateFormat("HH:mm - dd/MM/yyyy").format(expiredAt);
        String title = "Sắp hết hạn nhận sách!";
        String message = "Bạn chỉ còn 1 ngày để nhận cuốn sách \"" + bookTitle + "\". " +
                "Hạn cuối: " + deadline + ".";
        insertNotification(userId, "RESERVATION_EXPIRING", title, message);
        try {
            sendEmail(userId, "⏰ " + title, buildEmailHtml(
                    "⏰ Còn 1 ngày để nhận sách!",
                    "Đặt trước cuốn sách <strong>\"" + bookTitle + "\"</strong> của bạn sắp hết hạn.",
                    "🗓️ Hạn cuối: <strong>" + deadline + "</strong>. Vui lòng đến thư viện trước thời hạn này.",
                    "#f59e0b", "🏃 Đến nhận sách ngay"));
        } catch (Exception e) {
            logger.log(Level.WARNING, "[Notification] Bỏ qua lỗi email userId=" + userId + ": " + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════
    // SỰ KIỆN 3: Đã hết hạn
    // ════════════════════════════════════════════════════════════════
    public void notifyReservationExpired(long userId, String bookTitle) throws SQLException {
        String title = "Đặt trước đã bị hủy do hết hạn";
        String message = "Đặt trước cho cuốn sách \"" + bookTitle + "\" đã bị hủy tự động " +
                "vì bạn không đến nhận trong 3 ngày. Bạn có thể đặt trước lại nếu muốn.";
        insertNotification(userId, "RESERVATION_EXPIRED", title, message);
        try {
            sendEmail(userId, "❌ " + title, buildEmailHtml(
                    "❌ Đặt trước đã bị hủy",
                    "Đặt trước cho cuốn sách <strong>\"" + bookTitle + "\"</strong> đã bị hủy tự động.",
                    "📌 Lý do: Bạn không đến nhận sách trong vòng 3 ngày. " +
                            "Bạn có thể tìm kiếm và đặt trước lại cuốn sách này nếu muốn.",
                    "#ef4444", "🔍 Tìm sách đặt lại"));
        } catch (Exception e) {
            logger.log(Level.WARNING, "[Notification] Bỏ qua lỗi email userId=" + userId + ": " + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════
    // SỰ KIỆN 4: User tự hủy
    // ════════════════════════════════════════════════════════════════
    public void notifyReservationCancelled(long userId, String bookTitle) throws SQLException {
        String title = "Đặt trước đã được hủy";
        String message = "Đặt trước cho cuốn sách \"" + bookTitle + "\" đã được hủy thành công.";
        insertNotification(userId, "RESERVATION_CANCELLED", title, message);
        try {
            sendEmail(userId, "🗑️ " + title, buildEmailHtml(
                    "🗑️ Hủy đặt trước thành công",
                    "Đặt trước cho cuốn sách <strong>\"" + bookTitle + "\"</strong> đã được hủy theo yêu cầu của bạn.",
                    "💡 Nếu bạn muốn đặt trước lại, hãy tìm kiếm cuốn sách trên hệ thống.",
                    "#64748b", "🔍 Tìm sách khác"));
        } catch (Exception e) {
            logger.log(Level.WARNING, "[Notification] Bỏ qua lỗi email userId=" + userId + ": " + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  SỰ KIỆN 5: Đặt trước đã được chuyển thành mượn
    // ════════════════════════════════════════════════════════════════
    public void notifyReservationBorrowed(long userId, String bookTitle) throws SQLException {
        String title   = "Đặt trước đã được xác nhận";
        String message = "Bạn đã nhận sách \"" + bookTitle + "\" thành công. Thời hạn mượn là 7 ngày.";
        insertNotification(userId, "RESERVATION_BORROWED", title, message);
        try {
            sendEmail(userId, "✅ " + title, buildEmailHtml(
                    "✅ Xác nhận nhận sách",
                    "Bạn đã nhận sách <strong>\"" + bookTitle + "\"</strong> thành công từ thư viện.",
                    "⏰ Thời hạn mượn: <strong>7 ngày</strong>. Vui lòng trả sách đúng hạn để tránh phạt.",
                    "#22c55e", "📖 Xem sách của tôi"));
        } catch (Exception e) {
            logger.log(Level.WARNING, "[Notification] Bỏ qua lỗi email userId=" + userId + ": " + e.getMessage());
        }
    }

    // ════════════════════════════════════════════════════════════════
    //  QUERY METHODS
    // ════════════════════════════════════════════════════════════════

    public int countUnread(long userId) throws SQLException {
        String sql = "SELECT COUNT(1) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

    public List<Map<String, Object>> listByUser(long userId) throws SQLException {
        String sql = "SELECT TOP 50 id, type, title, message, is_read, created_at " +
                "FROM notifications WHERE user_id = ? " +
                "ORDER BY created_at DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(Map.of(
                        "id", rs.getLong("id"),
                        "type", rs.getString("type"),
                        "title", rs.getString("title"),
                        "message", rs.getString("message"),
                        "isRead", rs.getBoolean("is_read"),
                        "createdAt", rs.getTimestamp("created_at")));
            }
        }
        return list;
    }

    public void markRead(long notificationId, long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, notificationId);
            ps.setLong(2, userId);
            ps.executeUpdate();
        }
    }

    public void markAllRead(long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.executeUpdate();
        }
    }

    // ════════════════════════════════════════════════════════════════
    // PRIVATE HELPERS
    // ════════════════════════════════════════════════════════════════

    private void insertNotification(long userId, String type,
            String title, String message) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, type, title, message, created_at) " +
                "VALUES (?, ?, ?, ?, GETDATE())";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, userId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, message);
            ps.executeUpdate();
        }
    }

    private void sendEmail(long userId, String subject, String htmlBody) {
        try {
            User user = userDAO.findById(userId);
            if (user == null || user.getEmail() == null || user.getEmail().isBlank()) {
                logger.warning("[Notification] Không tìm thấy email của userId=" + userId);
                return;
            }
            emailService.send(user.getEmail(), subject, htmlBody);
            logger.info("[Notification] Đã gửi email → " + user.getEmail());
        } catch (Exception e) {
            logger.log(Level.WARNING,
                    "[Notification] Gửi email thất bại userId=" + userId + ": " + e.getMessage());
        }
    }

    private String buildEmailHtml(String heading, String mainText,
            String noteText, String accentColor, String ctaText) {
        String appUrl = com.lbms.config.AppConfig.APP_BASE_URL;
        return "<!DOCTYPE html>" +
                "<html lang='vi'><head><meta charset='UTF-8'/></head>" +
                "<body style='margin:0;padding:0;background:#f0f4f8;font-family:Segoe UI,Arial,sans-serif;'>" +
                "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f0f4f8;padding:40px 0;'>" +
                "<tr><td align='center'>" +
                "<table width='560' cellpadding='0' cellspacing='0' " +
                "style='background:#fff;border-radius:12px;overflow:hidden;box-shadow:0 4px 16px rgba(0,0,0,0.08);'>" +
                "<tr><td style='background:" + accentColor + ";padding:28px 40px;text-align:center;'>" +
                "<h1 style='margin:0;color:#fff;font-size:1.2rem;font-weight:700;'>" + heading + "</h1>" +
                "</td></tr>" +
                "<tr><td style='padding:32px 40px;'>" +
                "<p style='margin:0 0 16px;color:#1e293b;font-size:0.95rem;line-height:1.6;'>" + mainText + "</p>" +
                "<div style='background:#f8fafc;border-left:4px solid " + accentColor
                + ";border-radius:6px;padding:14px 18px;margin:20px 0;'>" +
                "<p style='margin:0;color:#475569;font-size:0.88rem;line-height:1.5;'>" + noteText + "</p>" +
                "</div></td></tr>" +
                "<tr><td style='padding:0 40px 32px;text-align:center;'>" +
                "<a href='" + appUrl + "/reservation' style='display:inline-block;background:" + accentColor
                + ";color:#fff;" +
                "text-decoration:none;padding:12px 32px;border-radius:8px;font-size:0.9rem;font-weight:600;'>" + ctaText
                + "</a>" +
                "</td></tr>" +
                "<tr><td style='background:#f8fafc;padding:20px 40px;text-align:center;border-top:1px solid #e2e8f0;'>"
                +
                "<p style='margin:0;color:#94a3b8;font-size:0.78rem;'>Email này được gửi tự động từ hệ thống LBMS.<br/>Vui lòng không trả lời email này.</p>"
                +
                "</td></tr>" +
                "</table></td></tr></table></body></html>";
    }

    /**
     * 1. GỬI CHO MỘT USER CỤ THỂ
     * 
     */
    public void sendNotificationToUser(int receiverId, int senderId, String senderRole,
            String type, String title, String message) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, sender_id, sender_role, type, title, message, "
                + "is_read, sent_to_all, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, 0, 0, GETDATE())";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            ps.setInt(2, senderId);
            ps.setString(3, senderRole);
            ps.setString(4, type);
            ps.setString(5, title);
            ps.setString(6, message);
            ps.executeUpdate();
            logger.info("[Notification] Sent to User ID: " + receiverId);
        }
    }

    /**
     * 2. GỬI CHO TOÀN BỘ HỆ THỐNG (Chỉ dành cho ADMIN)
     * 
     */
    public void sendSystemNotificationToAll(int senderId, String type, String title, String message)
            throws SQLException {

        String sql = "INSERT INTO notifications (user_id, sender_id, sender_role, type, title, message, is_read, sent_to_all, created_at) "
                + "SELECT user_id, ?, 'ADMIN', ?, ?, ?, 0, 1, GETDATE() "
                + "FROM [User] WHERE status = 'ACTIVE' AND user_id <> ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setString(2, type);
            ps.setString(3, title);
            ps.setString(4, message);
            ps.setInt(5, senderId);
            int rows = ps.executeUpdate();
            logger.info("[Notification] System broadcast sent to " + rows + " users.");
        }
    }

    /**
     * 3. GỬI THEO NHÓM ROLE (USER hoặc LIBRARIAN)
     * 
     */
    public void sendNotificationToRole(String targetRoleName, int senderId, String senderRole,
            String type, String title, String message) throws SQLException {

        // JOIN với bảng Role để lọc chính xác tên Role (ví dụ: 'USER', 'LIBRARIAN')
        String sql = "INSERT INTO notifications (user_id, sender_id, sender_role, type, title, message, is_read, sent_to_all, created_at) "
                + "SELECT u.user_id, ?, ?, ?, ?, ?, 0, 1, GETDATE() "
                + "FROM [User] u "
                + "INNER JOIN Role r ON u.role_id = r.role_id "
                + "WHERE r.role_name = ? AND u.status = 'ACTIVE' AND u.user_id <> ?";

        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, senderId);
            ps.setString(2, senderRole);
            ps.setString(3, type);
            ps.setString(4, title);
            ps.setString(5, message);
            ps.setString(6, targetRoleName); // 'USER' hoặc 'LIBRARIAN'
            ps.setInt(7, senderId);
            int rows = ps.executeUpdate();
            logger.info("[Notification] Sent to all " + targetRoleName + "s (" + rows + " records)");
        }
    }

    /**
     * 4. ĐÁNH DẤU ĐÃ ĐỌC
     */
    public void markAsRead(long notificationId, int userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, notificationId);
            ps.setInt(2, userId);
            ps.executeUpdate();
        }
    }

    /**
     * 5. ĐẾM THÔNG BÁO CHƯA ĐỌC (Hiển thị Badge trên Header)
     */
    public int getUnreadCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0";
        try (Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        }
    }

}