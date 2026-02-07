package com.lbms.service;

import com.lbms.dao.RoleDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Role;
import com.lbms.model.User;

import java.sql.SQLException;
import java.util.List;

public class UserManagementService {
    private final UserDAO userDAO;
    private final RoleDAO roleDAO;

    public UserManagementService() {
        this.userDAO = new UserDAO();
        this.roleDAO = new RoleDAO();
    }

    public List<User> listAllUsers() throws SQLException {
        return userDAO.listAll();
    }

    public List<Role> listAllRoles() throws SQLException {
        return roleDAO.listAll();
    }

    public void setUserStatus(long userId, String status) throws SQLException {
        if (status == null || status.isBlank()) throw new IllegalArgumentException("Status không hợp lệ");
        String st = status.trim().toUpperCase();
        if (!"ACTIVE".equals(st) && !"LOCKED".equals(st)) {
            throw new IllegalArgumentException("Status chỉ cho phép ACTIVE hoặc LOCKED");
        }
        userDAO.updateStatus(userId, st);
    }

    public void setUserRole(long userId, String roleName) throws SQLException {
        if (roleName == null || roleName.isBlank()) throw new IllegalArgumentException("Role không hợp lệ");
        Role r = roleDAO.findByName(roleName.trim().toUpperCase());
        if (r == null) throw new IllegalArgumentException("Role không tồn tại");
        userDAO.updateRole(userId, r.getName());
    }
}
