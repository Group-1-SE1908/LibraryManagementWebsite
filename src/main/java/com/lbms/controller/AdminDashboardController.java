package com.lbms.controller;

import com.lbms.dao.DashboardDAO;
import com.lbms.model.User;
import com.lbms.dao.UserDAO;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = { "/admin", "/admin/dashboard" })
public class AdminDashboardController extends HttpServlet {
    private DashboardDAO dashboardDAO;

    @Override
    public void init() throws ServletException {
        dashboardDAO = new DashboardDAO();

    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {

            Map<String, Object> stats = dashboardDAO.getDashboardStats();

            List<Map<String, Object>> topBorrowers = dashboardDAO.getTopBorrowers(5);

            request.setAttribute("totalBooks", stats.get("totalBooks"));
            request.setAttribute("activeUsers", stats.get("activeUsers"));
            request.setAttribute("pendingReturns", stats.get("pendingReturns"));
            request.setAttribute("totalShipments", stats.get("totalShipments"));
            request.setAttribute("topBorrowers", topBorrowers);

            request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp")
                    .forward(request, response);

        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
