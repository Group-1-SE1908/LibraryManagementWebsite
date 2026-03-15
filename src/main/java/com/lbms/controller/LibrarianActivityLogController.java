/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.lbms.controller;

import com.lbms.dao.LibrarianActivityLogDAO;
import com.lbms.model.LibrarianActivityLog;
import jakarta.servlet.RequestDispatcher;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;

/**
 *
 * @author ASUS
 */
@WebServlet(name = "LibrarianActivityLogController", urlPatterns = { "/admin/librarianActivityLog" })
public class LibrarianActivityLogController extends HttpServlet {

    private LibrarianActivityLogDAO activityLogDAO;

    @Override
    public void init() {
        activityLogDAO = new LibrarianActivityLogDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<LibrarianActivityLog> logs = activityLogDAO.getAllActivityLogs();
        String filterType = request.getParameter("type");
        if (filterType != null && !filterType.isEmpty()) {
            logs = activityLogDAO.getActivityLogsFiltered(filterType);
        }
        request.setAttribute("activityLogs", logs);
        request.setAttribute("filterType", filterType);

        RequestDispatcher dispatcher = request.getRequestDispatcher("/WEB-INF/views/admin/librarianActivityLog.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int userId = Integer.parseInt(request.getParameter("user_id"));
            String action = request.getParameter("action");

            activityLogDAO.addActivityLog(userId, action);

            response.sendRedirect("librarianActivityLog");
        } catch (NumberFormatException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid User ID format");
        }
    }

    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
