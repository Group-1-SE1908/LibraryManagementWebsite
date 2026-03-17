package com.lbms.controller;

import com.lbms.dao.CommentReportDAO;
import com.lbms.model.CommentReport;
import com.lbms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AdminReportController", urlPatterns = { "/staff/reports", "/admin/reports" })
public class AdminReportController extends HttpServlet {
    private CommentReportDAO reportDAO;

    @Override
    public void init() {
        this.reportDAO = new CommentReportDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (!hasOperationalRole(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String path = request.getServletPath();
        String reportsBasePath = resolveBasePath(path);

        try {
            if (reportsBasePath.equals(path)) {
                List<CommentReport> reports = reportDAO.getAllReports();
                request.setAttribute("reports", reports);
                request.setAttribute("reportsBasePath", reportsBasePath);
                request.getRequestDispatcher("/WEB-INF/views/admin/reports_management.jsp").forward(request, response);
            } else {
                response.sendError(404);
            }
        } catch (Exception e) {
            Logger.getLogger(AdminReportController.class.getName()).log(Level.SEVERE, null, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (!hasOperationalRole(user)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String action = request.getParameter("action");
        long reportId = Long.parseLong(request.getParameter("reportId"));

        try {
            if ("resolve".equals(action)) {
                reportDAO.updateReportStatus(reportId, "RESOLVED");
            } else if ("ignore".equals(action)) {
                reportDAO.updateReportStatus(reportId, "IGNORED");
            } else if ("delete".equals(action)) {
                // Get commentId from report
                CommentReport report = getReportById(reportId);
                if (report != null) {
                    reportDAO.deleteComment(report.getCommentId());
                    reportDAO.updateReportStatus(reportId, "RESOLVED");
                }
            }
            response.sendRedirect(request.getContextPath() + resolveBasePath(request.getServletPath()));
        } catch (SQLException e) {
            Logger.getLogger(AdminReportController.class.getName()).log(Level.SEVERE, null, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
    }

    private boolean hasOperationalRole(User user) {
        if (user == null || user.getRole() == null) {
            return false;
        }
        String role = user.getRole().getName();
        return "LIBRARIAN".equalsIgnoreCase(role) || "ADMIN".equalsIgnoreCase(role);
    }

    private String resolveBasePath(String path) {
        if (path != null && path.startsWith("/admin/")) {
            return "/admin/reports";
        }
        return "/staff/reports";
    }

    private CommentReport getReportById(long reportId) throws SQLException {
        // This is a simple implementation; in real app, you might want a getReportById
        // method
        List<CommentReport> reports = reportDAO.getAllReports();
        for (CommentReport report : reports) {
            if (report.getReportId() == reportId) {
                return report;
            }
        }
        return null;
    }
}