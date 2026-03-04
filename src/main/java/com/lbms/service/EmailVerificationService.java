package com.lbms.service;

import com.lbms.config.AppConfig;
import com.lbms.dao.EmailVerificationTokenDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import com.lbms.model.UserStatus;
import com.lbms.util.CryptoUtil;

import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.Instant;
import java.time.temporal.ChronoUnit;

public class EmailVerificationService {
    private final UserDAO userDAO;
    private final EmailVerificationTokenDAO tokenDAO;
    private final EmailService emailService;
    private final SecureRandom random;

    public EmailVerificationService() {
        this.userDAO = new UserDAO();
        this.tokenDAO = new EmailVerificationTokenDAO();
        this.emailService = new EmailService();
        this.random = new SecureRandom();
    }

    public void sendVerificationCode(long userId, String email) throws SQLException {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email không thể rỗng");
        }
        tokenDAO.invalidateTokens(userId);
        String code = generateCode();
        String codeHash = CryptoUtil.sha256Hex(code);
        Instant expiresAt = Instant.now().plus(AppConfig.EMAIL_VERIFICATION_CODE_MINUTES, ChronoUnit.MINUTES);
        tokenDAO.create(userId, codeHash, expiresAt);

        String subject = "LBMS - Xác thực email";
        String body = "<p>Bạn vừa đăng ký tài khoản LBMS.</p>"
                + "<p>Mã xác thực của bạn là <strong>" + code + "</strong>. Mã có hiệu lực trong "
                + AppConfig.EMAIL_VERIFICATION_CODE_MINUTES + " phút.</p>"
                + "<p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email.</p>";
        emailService.send(email, subject, body);
    }

    public void resendCode(String email) throws SQLException {
        if (email == null || email.isBlank()) {
            throw new IllegalArgumentException("Email không thể rỗng");
        }
        User user = userDAO.findByEmail(email.trim());
        if (user == null) {
            throw new IllegalArgumentException("Email không tồn tại");
        }
        if (!UserStatus.PENDING.equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản đã được kích hoạt hoặc đang bị khóa");
        }
        sendVerificationCode(user.getId(), user.getEmail());
    }

    public void verifyCode(String email, String code) throws SQLException {
        if (email == null || email.isBlank() || code == null || code.isBlank()) {
            throw new IllegalArgumentException("Email và mã xác thực là bắt buộc");
        }
        User user = userDAO.findByEmail(email.trim());
        if (user == null) {
            throw new IllegalArgumentException("Email hoặc mã xác thực không hợp lệ");
        }
        if (!UserStatus.PENDING.equalsIgnoreCase(user.getStatus())) {
            throw new IllegalArgumentException("Tài khoản đã được kích hoạt hoặc không hợp lệ");
        }
        String codeHash = CryptoUtil.sha256Hex(code.trim());
        boolean consumed = tokenDAO.consumeCode(user.getId(), codeHash);
        if (!consumed) {
            throw new IllegalArgumentException("Mã xác thực không tồn tại hoặc đã hết hạn");
        }
        boolean updated = userDAO.updateStatus(user.getId(), UserStatus.ACTIVE);
        if (!updated) {
            throw new IllegalStateException("Không thể cập nhật trạng thái tài khoản");
        }
    }

    private String generateCode() {
        int value = random.nextInt(1_000_000);
        return String.format("%06d", value);
    }
}
