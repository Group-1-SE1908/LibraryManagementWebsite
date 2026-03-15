package com.lbms.controller;

import com.lbms.dao.CommentDAO;
import com.lbms.dao.CommentReportDAO;
import com.lbms.model.CommentReport;
import com.lbms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ReportCommentServlet", urlPatterns = {"/reportComment"})
@MultipartConfig
public class ReportCommentServlet extends HttpServlet {
    private CommentReportDAO reportDAO;
    private CommentDAO commentDAO;

    @Override
    public void init() {
        this.reportDAO = new CommentReportDAO();
        this.commentDAO = new CommentDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.setContentType("application/json");
            response.getWriter().write("{\"success\": false, \"message\": \"Bạn cần đăng nhập để gửi báo cáo\"}");
            return;
        }

        String action = request.getParameter("action");
        if ("submit".equals(action)) {
            handleSubmitReport(request, response, user);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    private void handleSubmitReport(HttpServletRequest request, HttpServletResponse response, User user)
            throws IOException {

        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        try {
            long commentId = Long.parseLong(request.getParameter("commentId"));
            String reason = request.getParameter("reason");
            String description = request.getParameter("description");

            // Get comment owner
            int commentUserId = commentDAO.getCommentUserId(commentId);

            // Check if user is trying to report their own comment
            if ((int) user.getId() == commentUserId) {
                out.write("{\"success\": false, \"message\": \"You cannot report your own comment\"}");
                return;
            }

            // Validate reason
            if (reason == null || reason.trim().isEmpty()) {
                out.write("{\"success\": false, \"message\": \"Reason is required\"}");
                return;
            }

            // Check if user already reported this comment
            if (reportDAO.hasUserReportedComment((int) user.getId(), commentId)) {
                out.write("{\"success\": false, \"message\": \"You have already reported this comment\"}");
                return;
            }

            // Create report
            CommentReport report = new CommentReport(commentId, (int) user.getId(), reason, description);
            reportDAO.insertReport(report);

            out.write("{\"success\": true, \"message\": \"Report submitted successfully\"}");

        } catch (Exception e) {
            Logger.getLogger(ReportCommentServlet.class.getName()).log(Level.SEVERE, null, e);
            out.write("{\"success\": false, \"message\": \"An error occurred\"}");
        }
    }
}