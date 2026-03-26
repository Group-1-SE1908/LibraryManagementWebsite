/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.lbms.controller;

import com.lbms.dao.CommentDAO;
import com.lbms.dao.CommentReplyDAO;
import com.lbms.dao.CommentReportDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Comment;
import com.lbms.model.CommentReply;
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

/**
 * CommentController - Xử lý các thao tác comment trên sách
 */
@WebServlet(name = "CommentController", urlPatterns = { "/comment" })
public class CommentController extends HttpServlet {
    private CommentDAO commentDAO;
    private CommentReplyDAO replyDAO;
    private CommentReportDAO reportDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        this.commentDAO = new CommentDAO();
        this.replyDAO = new CommentReplyDAO();
        this.reportDAO = new CommentReportDAO();
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("getComments".equals(action)) {
                handleGetComments(request, response);
            } else if ("delete".equals(action)) {
                handleDeleteComment(request, response);
            } else {
                response.sendError(404);
            }
        } catch (Exception ex) {
            Logger.getLogger(CommentController.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("add".equals(action)) {
                handleAddComment(request, response);
            } else if ("update".equals(action)) {
                handleUpdateComment(request, response);
            } else if ("delete".equals(action)) {
                handleDeleteComment(request, response);
            } else if ("reply".equals(action)) {
                handleReply(request, response);
            } else {
                response.sendError(404);
            }
        } catch (Exception ex) {
            Logger.getLogger(CommentController.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(500);
        }
    }

    /**
     * Xử lý lấy danh sách comments cho một cuốn sách
     */
    private void handleGetComments(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        int bookId = Integer.parseInt(request.getParameter("bookId"));
        List<Comment> comments = commentDAO.getCommentsByBook(bookId);

        // Load replies cho mỗi comment
        for (Comment comment : comments) {
            comment.setReplies(replyDAO.findByCommentId(comment.getCommentId()));
        }

        request.setAttribute("comments", comments);
        request.setAttribute("bookId", bookId);

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        request.setAttribute("reportsBasePath", resolveReportsBasePath(currentUser));

        if (currentUser != null && currentUser.getRole() != null
                && ("LIBRARIAN".equalsIgnoreCase(currentUser.getRole().getName())
                        || "ADMIN".equalsIgnoreCase(currentUser.getRole().getName()))) {
            List<CommentReport> bookReports = reportDAO.getReportsByBook(bookId);
            request.setAttribute("bookReports", bookReports);
        }

        request.getRequestDispatcher("/WEB-INF/views/comments_list.jsp").forward(request, response);
    }

    /**
     * Xử lý thêm comment mới
     */
    private void handleAddComment(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendError(401, "Unauthorized - User not logged in");
            return;
        }

        // Kiểm tra user có đang bị khóa comment không
        if (userDAO.isCommentLocked(user.getId())) {
            session.setAttribute("errorMessage", "Tài khoản của bạn đang bị hạn chế bình luận. Vui lòng thử lại sau.");
            int bookId = Integer.parseInt(request.getParameter("bookId"));
            response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
            return;
        }

        int bookId = Integer.parseInt(request.getParameter("bookId"));
        String content = request.getParameter("content");
        int rating = Integer.parseInt(request.getParameter("rating"));

        if (content == null || content.trim().isEmpty() || rating < 1 || rating > 5) {
            response.sendError(400, "Invalid input");
            return;
        }

        if (commentDAO.hasUserCommented(bookId, (int) user.getId())) {
            response.sendError(400, "Bạn đã đánh giá và bình luận cho cuốn sách này rồi!");
            return;
        }

        Comment comment = new Comment();
        comment.setBookId(bookId);
        comment.setUserId((int) user.getId());
        comment.setContent(content.trim());
        comment.setRating(rating);

        commentDAO.insertComment(comment);

        session.setAttribute("message", "Bình luận đã được thêm thành công!");
        response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
    }

    /**
     * Xử lý cập nhật comment
     */
    private void handleUpdateComment(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendError(401, "Unauthorized - User not logged in");
            return;
        }

        try {
            long commentId = Long.parseLong(request.getParameter("commentId"));
            String content = request.getParameter("content");
            String ratingStr = request.getParameter("rating");
            int bookId = Integer.parseInt(request.getParameter("bookId"));

            if (content == null || content.trim().isEmpty() || ratingStr == null) {
                response.sendError(400, "Invalid input");
                return;
            }

            int rating = Integer.parseInt(ratingStr);
            if (rating < 1 || rating > 5) {
                response.sendError(400, "Invalid rating");
                return;
            }

            boolean isAdmin = (user.getRole() != null &&
                    ("ADMIN".equals(user.getRole().getName()) ||
                            "LIBRARIAN".equals(user.getRole().getName())));

            Comment comment = new Comment();
            comment.setCommentId(commentId);
            comment.setUserId((int) user.getId());
            comment.setContent(content.trim());
            comment.setRating(rating);

            boolean updated = commentDAO.updateComment(comment, isAdmin);

            if (updated) {
                session.setAttribute("message", "Bình luận đã được cập nhật thành công!");
                response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
            } else {
                response.sendError(403, "Forbidden - You can only update your own comments");
            }
        } catch (NumberFormatException e) {
            Logger.getLogger(CommentController.class.getName()).log(Level.SEVERE, null, e);
            response.sendError(400, "Invalid number format");
        }
    }

    /**
     * Xử lý xóa comment
     */
    private void handleDeleteComment(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendError(401, "Unauthorized - User not logged in");
            return;
        }

        long commentId = Long.parseLong(request.getParameter("commentId"));
        int bookId = Integer.parseInt(request.getParameter("bookId"));

        boolean isAdmin = (user.getRole() != null &&
                ("ADMIN".equals(user.getRole().getName()) ||
                        "LIBRARIAN".equals(user.getRole().getName())));

        boolean deleted = commentDAO.deleteComment(commentId, (int) user.getId(), isAdmin);

        if (deleted) {
            session.setAttribute("message", "Bình luận đã được xóa thành công!");
            response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
        } else {
            response.sendError(403, "Forbidden - You can only delete your own comments");
        }
    }

    /**
     * Xử lý phản hồi comment từ thủ thư
     */
    private void handleReply(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        if (user == null) {
            response.sendError(401, "Unauthorized - User not logged in");
            return;
        }

        boolean isAdmin = (user.getRole() != null &&
                ("ADMIN".equals(user.getRole().getName()) ||
                        "LIBRARIAN".equals(user.getRole().getName())));

        if (!isAdmin) {
            response.sendError(403, "Forbidden - Only librarians and admins can reply");
            return;
        }

        long commentId = Long.parseLong(request.getParameter("commentId"));
        String content = request.getParameter("content");
        int bookId = Integer.parseInt(request.getParameter("bookId"));

        if (content == null || content.trim().isEmpty()) {
            response.sendError(400, "Content is required");
            return;
        }

        CommentReply reply = new CommentReply();
        reply.setCommentId(commentId);
        reply.setAdminId((int) user.getId());
        reply.setContent(content.trim());

        replyDAO.insertReply(reply);

        session.setAttribute("message", "Phản hồi đã được gửi thành công!");
        response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
    }

    @Override
    public String getServletInfo() {
        return "Comment Controller for managing book comments";
    }

    private String resolveReportsBasePath(User user) {
        if (user != null && user.getRole() != null && "ADMIN".equalsIgnoreCase(user.getRole().getName())) {
            return "/admin/reports";
        }
        return "/staff/reports";
    }
}