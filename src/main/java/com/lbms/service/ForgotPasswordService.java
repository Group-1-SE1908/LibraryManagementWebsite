package com.lbms.service;

import com.lbms.dao.PasswordResetTokenDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import com.lbms.config.AppConfig;
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
        if (email == null || email.isBlank())
            return;

        User u = userDAO.findByEmail(email.trim());
        // Không tiết lộ email có tồn tại hay không
        if (u == null)
            return;

        String code = generateCode();
        tokenDAO.invalidateTokensForUser(u.getId());
        String tokenHash = CryptoUtil.sha256Hex(code);
        Instant expiresAt = Instant.now().plus(AppConfig.RESET_TOKEN_MINUTES, ChronoUnit.MINUTES);

        tokenDAO.create(u.getId(), tokenHash, expiresAt);

        String subject = "LBMS - Đặt lại mật khẩu";
        String body = "<p>Bạn vừa yêu cầu đặt lại mật khẩu.</p>"
                + "<p>Mã xác thực của bạn là <strong>" + code + "</strong> và có hiệu lực trong "
                + AppConfig.RESET_TOKEN_MINUTES + " phút.</p>"
                + "<p>Nhập mã này trên trang <a href='" + AppConfig.APP_BASE_URL
                + "/reset-password'>Đặt lại mật khẩu</a> để tạo mật khẩu mới.</p>"
                + "<p>Nếu bạn không thực hiện, hãy bỏ qua email này.</p>";

        emailService.send(u.getEmail(), subject, body);
    }

    public void resetPassword(String email, String code, String newPassword) throws SQLException {
        if (email == null || email.isBlank() || code == null || code.isBlank()) {
            throw new IllegalArgumentException("Email và mã xác thực là bắt buộc");
        }
        if (newPassword == null || newPassword.isBlank() || newPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu tối thiểu 6 ký tự");
        }

        User user = userDAO.findByEmail(email.trim());
        if (user == null) {
            throw new IllegalArgumentException("Email hoặc mã xác thực không hợp lệ");
        }

        String tokenHash = CryptoUtil.sha256Hex(code.trim());
        Long userId = tokenDAO.findValidUserIdByTokenHash(tokenHash);
        if (userId == null || userId != user.getId())
            throw new IllegalArgumentException("Email hoặc mã xác thực không hợp lệ");

        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));

        // Transaction: update user password + mark token used
        try (Connection c = DBConnection.getConnection()) {
            c.setAutoCommit(false);
            try {
                try (var ps = c.prepareStatement("UPDATE [User] SET password = ? WHERE user_id = ?")) {
                    ps.setString(1, newHash);
                    ps.setLong(2, userId);
                    ps.executeUpdate();
                }

                try (var ps = c
                        .prepareStatement("UPDATE password_reset_token SET used = 1 WHERE token = ? AND used = 0")) {
                    ps.setString(1, tokenHash);
                    ps.executeUpdate();
                }

                c.commit();
            } catch (Exception ex) {
                c.rollback();
                if (ex instanceof SQLException)
                    throw (SQLException) ex;
                if (ex instanceof RuntimeException)
                    throw (RuntimeException) ex;
                throw new RuntimeException(ex);
            } finally {
                c.setAutoCommit(true);
            }
        }
    }

    private String generateCode() {
        int value = random.nextInt(1_000_000);
        return String.format("%06d", value);
    }
}
