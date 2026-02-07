package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.SQLException;

public class ProfileService {
    private final UserDAO userDAO;

    public ProfileService() {
        this.userDAO = new UserDAO();
    }

    public User refreshUser(long userId) throws SQLException {
        return userDAO.findById(userId);
    }

    public void updateFullName(long userId, String fullName) throws SQLException {
        if (fullName != null && fullName.length() > 255) {
            throw new IllegalArgumentException("Họ tên quá dài");
        }
        userDAO.updateFullName(userId, fullName);
    }

    public void changePassword(long userId, String oldPassword, String newPassword) throws SQLException {
        if (oldPassword == null || oldPassword.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập mật khẩu hiện tại");
        }
        if (newPassword == null || newPassword.isBlank() || newPassword.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu mới tối thiểu 6 ký tự");
        }

        User u = userDAO.findById(userId);
        if (u == null) throw new IllegalArgumentException("User không tồn tại");

        if (!BCrypt.checkpw(oldPassword, u.getPasswordHash())) {
            throw new IllegalArgumentException("Mật khẩu hiện tại không đúng");
        }

        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
        userDAO.updatePasswordHash(userId, newHash);
    }
}
