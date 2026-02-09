package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.UserManagementService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = { "/admin", "/admin/dashboard" })
public class AdminDashboardController extends HttpServlet {
    private UserManagementService userManagementService;

    @Override
    public void init() {
        this.userManagementService = new UserManagementService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<User> users = new ArrayList<>();

            // Get user data for the user management table
            try {
                users = userManagementService.listAllUsers();
                // Limit to first 4 users for display
                if (users.size() > 4) {
                    users = users.subList(0, 4);
                }
            } catch (Exception e) {
                // If there's any error getting users, just use empty list
                e.printStackTrace();
            }

            req.setAttribute("users", users);

            // Forward to dashboard view
            req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }
}
