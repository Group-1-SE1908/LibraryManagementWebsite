package com.lbms.controller;

import com.lbms.model.CommentReply;
import com.lbms.dao.CommentDAO;
import com.lbms.dao.CommentReplyDAO;
import com.lbms.dao.CommentReportDAO;
import com.lbms.dao.UserDAO;
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
    private CommentReplyDAO commentReplyDAO;
    private CommentDAO commentDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        this.reportDAO = new CommentReportDAO();
        this.commentDAO = new CommentDAO();
        this.commentReplyDAO = new CommentReplyDAO();
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");
        if (user == null || (!"ADMIN".equals(user.getRole().getName()) &&
                !"LIBRARIAN".equals(user.getRole().getName()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        try {
            String action = request.getParameter("action");

            // Xử lý action=view (Xem & Trả lời)
            if ("view".equals(action)) {
                long commentId = Long.parseLong(request.getParameter("id"));

                Comment comment = commentDAO.findById(commentId);
                List<CommentReply> replies = commentReplyDAO.findByCommentId(commentId);

                request.setAttribute("comment", comment);
                request.setAttribute("replies", replies);

                request.getRequestDispatcher("/WEB-INF/views/admin/library/feedback_detail.jsp")
                        .forward(request, response);
                return;
            }

            // Load reports (tab Bình luận bị báo cáo)
            List<CommentReport> reports = reportDAO.getAllReports();
            request.setAttribute("reports", reports);

            // Load comments (tab Phản hồi cần trả lời)
            String filter = request.getParameter("filter");
            if (filter == null || filter.isEmpty())
                filter = "all";

            List<Comment> comments;
            if ("unreplied".equals(filter)) {
                comments = commentDAO.getCommentsWithoutReplies();
            } else {
                comments = commentDAO.listAllComments();
            }

            request.setAttribute("comments", comments);
            request.setAttribute("filter", filter);

            // Badge: luôn tính số chưa phản hồi từ DB (không phụ thuộc filter)
            List<Comment> unrepliedComments = commentDAO.getCommentsWithoutReplies();
            request.setAttribute("unrepliedCount", unrepliedComments.size());

            // Giữ tab active nếu redirect từ POST
            String activeTab = request.getParameter("tab");
            if (activeTab != null) {
                request.setAttribute("activeTab", activeTab);
            }

            request.getRequestDispatcher("/WEB-INF/views/admin/library/feedback_list.jsp")
                    .forward(request, response);

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
        if (user == null || (!"ADMIN".equals(user.getRole().getName()) &&
                !"LIBRARIAN".equals(user.getRole().getName()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("resolve".equals(action)) {
                long reportId = Long.parseLong(request.getParameter("reportId"));
                reportDAO.updateReportStatus(reportId, "RESOLVED");
                response.sendRedirect(request.getContextPath() + "/admin/feedback?tab=reports");

            } else if ("ignore".equals(action)) {
                long reportId = Long.parseLong(request.getParameter("reportId"));
                reportDAO.updateReportStatus(reportId, "IGNORED");
                response.sendRedirect(request.getContextPath() + "/admin/feedback?tab=reports");

            } else if ("deleteComment".equals(action)) {
                long reportId = Long.parseLong(request.getParameter("reportId"));
                CommentReport report = getReportById(reportId);
                if (report != null) {
                    commentDAO.deleteComment(report.getCommentId(), 0, true);
                    reportDAO.updateReportStatus(reportId, "RESOLVED");
                    reportDAO.updateDescription(reportId, "Đã xóa bình luận vi phạm");
                }
                response.sendRedirect(request.getContextPath() + "/admin/feedback?tab=reports");

            } else if ("lockComment".equals(action)) {
                long reportId = Long.parseLong(request.getParameter("reportId"));
                int lockDays = Integer.parseInt(request.getParameter("lockDays"));
                CommentReport report = getReportById(reportId);
                if (report != null) {
                    int commentOwnerId = commentDAO.getCommentUserId(report.getCommentId());
                    userDAO.lockCommentAccess(commentOwnerId, lockDays);
                    commentDAO.deleteAllCommentsByUser(commentOwnerId);
                    reportDAO.updateReportStatus(reportId, "RESOLVED");
                    reportDAO.updateDescription(reportId,
                            "Đã khóa comment " + lockDays + " ngày và xóa toàn bộ bình luận");
                }
                response.sendRedirect(request.getContextPath() + "/admin/feedback?tab=reports");

            } else if ("delete".equals(action)) {
                // Xóa comment từ tab phản hồi
                long commentId = Long.parseLong(request.getParameter("id"));
                commentDAO.deleteComment(commentId, (int) user.getId(), true);
                response.sendRedirect(request.getContextPath() + "/admin/feedback?tab=feedback");

            } else if ("reply".equals(action)) {
                long commentId = Long.parseLong(request.getParameter("commentId"));
                String replyContent = request.getParameter("replyContent");

                CommentReply reply = new CommentReply();
                reply.setCommentId(commentId);
                reply.setAdminId((int) user.getId());
                reply.setContent(replyContent);

                commentReplyDAO.insertReply(reply);

                response.sendRedirect(request.getContextPath() + "/admin/feedback?tab=feedback");
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            Logger.getLogger(AdminFeedbackController.class.getName()).log(Level.SEVERE, null, e);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error");
        }
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
