package com.lbms.service;

import com.lbms.dao.RoleDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Role;
import com.lbms.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.security.SecureRandom;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserService {
    private static final Logger logger = Logger.getLogger(UserService.class.getName());
    private final UserDAO userDAO = new UserDAO();
    private final RoleDAO roleDAO = new RoleDAO();
    private final EmailService emailService = new EmailService();

    public List<String> createUser(User user, String roleIdStr) throws SQLException {

        List<String> errors = validateUserInput(user, roleIdStr, true);

        if (errors.isEmpty()) {

            String randomPassword = generateRandomPassword();
            user.setPasswordHash(hashPassword(randomPassword));

            Role role = roleDAO.getRoleById(Integer.parseInt(roleIdStr));
            user.setRole(role);

            if (userDAO.createUserAccount(user)) {
                sendWelcomeEmail(user.getEmail(), user.getFullName(), randomPassword);
                return new ArrayList<>();
            } else {
                errors.add("Lỗi hệ thống: Không thể lưu thông tin vào cơ sở dữ liệu.");
            }
        }
        return errors;
    }

    public List<String> updateUser(User user, String roleIdStr, boolean isResetRequested) throws SQLException {
        User existingUser = userDAO.findById((int) user.getId());
        if (existingUser == null) {
            return List.of("Người dùng không tồn tại trên hệ thống.");
        }

        List<String> errors = validateUserInput(user, roleIdStr, false);

        if (errors.isEmpty()) {
            String newPwd = null;
            if (isResetRequested) {
                newPwd = generateRandomPassword();
                user.setPasswordHash(hashPassword(newPwd));
            } else {
                user.setPasswordHash(existingUser.getPasswordHash());
            }

            Role role = roleDAO.getRoleById(Integer.parseInt(roleIdStr));
            user.setRole(role);

            if (userDAO.updateUser(user)) {
                sendUpdateEmail(user.getEmail(), existingUser.getEmail(), user.getFullName(), newPwd, isResetRequested);
                return new ArrayList<>();
            } else {
                errors.add("Cập nhật thất bại do lỗi cơ sở dữ liệu.");
            }
        }
        return errors;
    }

    private List<String> validateUserInput(User user, String roleIdStr, boolean isCreate) throws SQLException {
        List<String> errors = new ArrayList<>();
        int excludeUserId = isCreate ? 0 : (int) user.getId();

        if (user.getFullName() == null || user.getFullName().trim().isEmpty()) {
            errors.add("Họ tên không được để trống.");
        } else if (user.getFullName().trim().length() > 100) {
            errors.add("Họ tên không được vượt quá 100 ký tự.");
        }

        String email = user.getEmail() != null ? user.getEmail().trim() : "";
        if (email.isEmpty()) {
            errors.add("Email không được để trống.");
        } else if (!email.matches("^[a-zA-Z0-9_+&*-]+(?:\\.[a-zA-Z0-9_+&*-]+)*@(?:[a-zA-Z0-9-]+\\.)+[a-zA-Z]{2,7}$")) {
            errors.add("Định dạng email không hợp lệ.");
        } else if (userDAO.isEmailExists(email, excludeUserId)) {
            errors.add("Email này đã tồn tại trong hệ thống.");
        }

        String phone = user.getPhone() != null ? user.getPhone().trim() : "";
        if (phone.isEmpty()) {
            errors.add("Số điện thoại không được để trống.");
        } else if (!phone.matches("^0\\d{9,10}$")) {
            errors.add("Số điện thoại không hợp lệ (phải bắt đầu bằng số 0, từ 10-11 chữ số).");
        } else if (userDAO.isPhoneExists(phone, excludeUserId)) {
            errors.add("Số điện thoại này đã được sử dụng bởi một tài khoản khác.");
        }

        if (user.getAddress() == null || user.getAddress().trim().isEmpty()) {
            errors.add("Địa chỉ không được để trống.");
        } else if (user.getAddress().trim().length() > 255) {
            errors.add("Địa chỉ không được vượt quá 255 ký tự.");
        }

        if (roleIdStr == null || roleIdStr.trim().isEmpty()) {
            errors.add("Vui lòng chọn vai trò.");
        } else {
            try {
                int roleId = Integer.parseInt(roleIdStr);
                if (roleDAO.getRoleById(roleId) == null) {
                    errors.add("Vai trò không hợp lệ.");
                }
            } catch (NumberFormatException e) {
                errors.add("Vai trò phải là định dạng số.");
            }
        }

        return errors;
    }

    public String updateStatus(long targetId, String status, User currentUser) throws SQLException {
        if (currentUser != null && targetId == currentUser.getId()) {
            return "Lỗi: Bạn không thể tự khóa tài khoản của chính mình!";
        }
        return userDAO.updateStatus(targetId, status) ? "SUCCESS" : "Lỗi: Không thể cập nhật trạng thái.";
    }

    public List<User> listUsers(int page, int pageSize, String keyword) throws SQLException {
        return userDAO.getAllUsers(page, pageSize, (keyword == null) ? "" : keyword.trim());
    }

    public int getTotalCount(String keyword) throws SQLException {
        return userDAO.getTotalUserCount((keyword == null) ? "" : keyword.trim());
    }

    public User getUserById(int id) throws SQLException {
        return userDAO.findById(id);
    }

    private void sendWelcomeEmail(String email, String name, String password) {
        new Thread(() -> {
            try {
                String subject = "🔑 Thông tin tài khoản LBMS của bạn";
                String body = "<h3>Chào mừng " + name + "!</h3>" +
                        "<p>Tài khoản của bạn đã được khởi tạo thành công trên hệ thống LBMS.</p>" +
                        "<b>Email:</b> " + email + "<br>" +
                        "<b>Mật khẩu:</b> <span style='color:red;'>" + password + "</span><br>" +
                        "<p><i>Vui lòng đăng nhập và đổi mật khẩu để bảo mật.</i></p>";
                emailService.send(email, subject, body);
            } catch (Exception e) {
                logger.log(Level.WARNING, "Lỗi gửi mail chào mừng", e);
            }
        }).start();
    }

    private void sendUpdateEmail(String newEmail, String oldEmail, String name, String newPwd, boolean wasReset) {
        new Thread(() -> {
            try {
                String subject = "🔔 Thông báo cập nhật tài khoản LBMS";
                String body = "<h3>Xin chào " + name + "</h3>" +
                        "<p>Thông tin tài khoản đã được cập nhật.</p>" +
                        (wasReset ? "<p>Mật khẩu mới: <b style='color:red;'>" + newPwd + "</b></p>" : "") +
                        "<p>Email đăng nhập: " + newEmail + "</p>";
                emailService.send(newEmail, subject, body);
                if (!newEmail.equalsIgnoreCase(oldEmail)) {
                    emailService.send(oldEmail, "⚠️ Thay đổi Email",
                            "Tài khoản của bạn đã chuyển sang email: " + newEmail);
                }
            } catch (Exception e) {
                logger.log(Level.WARNING, "Lỗi gửi mail cập nhật", e);
            }
        }).start();
    }

    private String hashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    private String generateRandomPassword() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 10; i++)
            sb.append(chars.charAt(random.nextInt(chars.length())));
        return sb.toString();
    }
}