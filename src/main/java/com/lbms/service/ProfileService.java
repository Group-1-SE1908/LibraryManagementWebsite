package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import java.sql.SQLException;
import org.mindrot.jbcrypt.BCrypt;

public class ProfileService {

    private final UserDAO userDAO;

    public ProfileService() {
        this.userDAO = new UserDAO();
    }

    // Refresh user
    public User refreshUser(long userId) throws Exception {
        return userDAO.findById(userId);
    }

    public void updateProfile(Long userId,
            String fullName,
            String phone,
            String address,
            String city,
            String district,
            String ward) throws Exception {

        // validate cơ bản
        if (fullName == null || fullName.trim().isEmpty()) {
            throw new IllegalArgumentException("Họ tên không được để trống.");
        }

        // Trim phone
        if (phone != null) {
            phone = phone.trim();
        }

        // Validate phone format
        if (phone == null || phone.isEmpty()) {
            throw new IllegalArgumentException("Số điện thoại không được để trống.");
        }

        if (!phone.matches("\\d{10}")) {
            throw new IllegalArgumentException("Số điện thoại phải đúng 10 số.");
        }

        // CHECK TRÙNG PHONE - ngoại trừ số điện thoại hiện tại của user
        if (userDAO.isPhoneExists(phone, userId)) {
            throw new IllegalArgumentException("Số điện thoại này đã được sử dụng. Vui lòng nhập số khác.");
        }

        userDAO.updateProfile(userId, fullName, phone, address, city, district, ward);
    }

    // Change password
    public void changePassword(long userId,
            String oldPassword,
            String newPassword) throws Exception {

        if (oldPassword == null || oldPassword.isBlank()) {
            throw new IllegalArgumentException(
                    "Vui lòng nhập mật khẩu hiện tại");
        }

        if (newPassword == null || newPassword.length() < 6) {
            throw new IllegalArgumentException(
                    "Mật khẩu mới tối thiểu 6 ký tự");
        }

        User u = userDAO.findById(userId);

        if (!BCrypt.checkpw(oldPassword, u.getPasswordHash())) {
            throw new IllegalArgumentException(
                    "Mật khẩu hiện tại không đúng");
        }

        String newHash = BCrypt.hashpw(newPassword, BCrypt.gensalt(10));
        userDAO.updatePasswordHash(userId, newHash);
    }

    public void updateAvatar(long userId, String avatar) throws SQLException, Exception {
        userDAO.updateAvatar(userId, avatar);
    }

}
