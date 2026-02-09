package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.dao.UserDAO;

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
    private UserDAO userDAO;

    @Override
    public void init() {
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<User> users = new ArrayList<>();

            // Get user data for the user management table
            try {
                // Use UserDAO to fetch first 4 users for dashboard
                users = userDAO.getAllUsers(1, 4, "");
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
