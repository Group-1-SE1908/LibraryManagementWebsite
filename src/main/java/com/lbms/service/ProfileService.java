package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import com.lbms.util.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
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

    public void updateProfile(long userId,
            String fullName,
            String phone,
            String address) throws Exception {

        String sql = "UPDATE [User] SET name = ?, phone = ?, address = ? WHERE user_id = ?";

        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, phone);
            ps.setString(3, address);
            ps.setLong(4, userId);

            ps.executeUpdate();
        }
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
