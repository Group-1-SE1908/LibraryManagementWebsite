package com.lbms.service;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import org.mindrot.jbcrypt.BCrypt;

import java.sql.SQLException;

public class AuthService {
    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    public User login(String email, String password) throws SQLException {
        User u = userDAO.findByEmail(email);
        if (u == null) return null;
        if (!"ACTIVE".equalsIgnoreCase(u.getStatus())) return null;
        if (!BCrypt.checkpw(password, u.getPasswordHash())) return null;
        return u;
    }

    public long register(String email, String password, String fullName) throws SQLException {
        if (userDAO.findByEmail(email) != null) {
            throw new IllegalArgumentException("Email đã tồn tại");
        }
        String hash = BCrypt.hashpw(password, BCrypt.gensalt(10));
        return userDAO.createUser(email, hash, fullName, "USER");
    }
}
