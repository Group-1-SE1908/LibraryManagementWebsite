package com.lbms.service;

import com.lbms.dao.PasswordResetTokenDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import com.lbms.util.AppConfig;
import com.lbms.util.CryptoUtil;
import org.mindrot.jbcrypt.BCrypt;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.SQLException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

import com.lbms.util.DBConnection;

public class ForgotPasswordService {
    private final UserDAO userDAO;
    private final PasswordResetTokenDAO tokenDAO;
    private final EmailService emailService;
    private final SecureRandom random;

    public ForgotPasswordService() {
        this.userDAO = new UserDAO();
        this.tokenDAO = new PasswordResetTokenDAO();
        this.emailService = new EmailService();
        this.random = new SecureRandom();
    }

    public void requestReset(String email) throws SQLException {
        if (email == null || email.isBlank()) return;

        User u = userDAO.findByEmail(email.trim());
        // Không tiết lộ email có tồn tại hay không
        if (u == null) return;

        String token = generateToken();
        String tokenHash = CryptoUtil.sha256Hex(token);
        Instant expiresAt = Instant.now().plus(AppConfig.RESET_TOKEN_MINUTES, ChronoUnit.MINUTES);

        tokenDAO.create(u.getId(), tokenHash, expiresAt);

        String link = AppConfig.APP_BASE_URL + "/reset-password?token=" + token;
        String subject = "LBMS - Đặt lại mật khẩu";
        String body = "<p>Bạn vừa yêu cầu đặt lại mật khẩu.</p>" +
                "<p>Nhấn vào link sau để đặt lại mật khẩu (hết hạn sau " + AppConfig.RESET_TOKEN_MINUTES + " phút):</p>" +
                "<p><a href='" + link + "'>" + link + "</a></p>" +
                "<p>Nếu bạn không yêu cầu, vui lòng bỏ qua email này.</p>";

        emailService.send(u.getEmail(), subject, body);
    }

    public void resetPassword(String rawToken, String newPassword) throws SQLException {
        if (rawToken == null || rawToken.isBlank()) throw new IllegalArgumentException("Token không hợp lệ");
        if (newPassword == null || newPassword.isBlank() || newPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu tối thiểu 6 ký tự");
        }

        String tokenHash = CryptoUtil.sha256Hex(rawToken);
        Long userId = tokenDAO.findValidUserIdByTokenHash(tokenHash);
        if (userId == null) throw new IllegalArgumentException("Token không hợp lệ hoặc đã hết hạn");

        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));

        // Transaction: update user password + mark token used
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (var ps = c.prepareStatement("UPDATE users SET password_hash = ? WHERE id = ?")) {
                    ps.setString(1, newHash);
                    ps.setLong(2, userId);
                    ps.executeUpdate();
                }

                try (var ps = c.prepareStatement("UPDATE password_reset_tokens SET used_at = CURRENT_TIMESTAMP WHERE token_hash = ? AND used_at IS NULL")) {
                    ps.setString(1, tokenHash);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception ex) {
                c.rollback();
                if (ex instanceof SQLException) throw (SQLException) ex;
                if (ex instanceof RuntimeException) throw (RuntimeException) ex;
                throw new RuntimeException(ex);
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    private String generateToken() {
        byte[] bytes = new byte[32];
        random.nextBytes(bytes);
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) sb.append(String.format("%02x", b));
        return sb.toString();
    }
}
