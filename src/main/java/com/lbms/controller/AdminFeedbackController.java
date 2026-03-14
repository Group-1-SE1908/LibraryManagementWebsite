package com.lbms.controller;

import com.lbms.dao.CommentDAO;
import com.lbms.dao.CommentReportDAO;
import com.lbms.model.Comment;
import com.lbms.model.CommentReport;
import com.lbms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "AdminFeedbackController", urlPatterns = { "/staff/feedback", "/admin/feedback" })
public class AdminFeedbackController extends HttpServlet {
    private CommentReportDAO reportDAO;
    private CommentDAO commentDAO;

    @Override
    public void init() {
        this.reportDAO = new CommentReportDAO();
        this.commentDAO = new CommentDAO();
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

        try {
            request.setAttribute("feedbackBasePath", resolveBasePath(request.getServletPath()));
            List<CommentReport> reports = reportDAO.getAllReports();
            request.setAttribute("reports", reports);
            List<Comment> pendingReplies = commentDAO.getCommentsWithoutReplies();
            request.setAttribute("pendingReplies", pendingReplies);
            request.getRequestDispatcher("/WEB-INF/views/admin/feedback_list.jsp").forward(request, response);
        } catch (Exception e) {
            Logger.getLogger(AdminFeedbackController.class.getName()).log(Level.SEVERE, null, e);
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
        } catch (Exception e) {
            Logger.getLogger(AdminFeedbackController.class.getName()).log(Level.SEVERE, null, e);
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
            return "/admin/feedback";
        }
        return "/staff/feedback";
    }

    private CommentReport getReportById(long reportId) {
        try {
            List<CommentReport> reports = reportDAO.getAllReports();
            for (CommentReport report : reports) {
                if (report.getReportId() == reportId) {
                    return report;
                }
            }
        } catch (Exception e) {
            Logger.getLogger(AdminFeedbackController.class.getName()).log(Level.SEVERE, null, e);
        }
        return null;
    }
}