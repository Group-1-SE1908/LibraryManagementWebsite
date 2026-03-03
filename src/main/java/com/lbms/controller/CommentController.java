/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.lbms.controller;

import com.lbms.dao.CommentDAO;
import com.lbms.dao.CommentReplyDAO;
import com.lbms.model.Comment;
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
 *
 * @author Trien
 */
@WebServlet(name = "CommentController", urlPatterns = {"/comment"})
public class CommentController extends HttpServlet {
    private CommentDAO commentDAO;
    private CommentReplyDAO replyDAO;

    @Override
    public void init() {
        this.commentDAO = new CommentDAO();
        this.replyDAO = new CommentReplyDAO();
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
        request.getRequestDispatcher("/WEB-INF/views/comments_list.jsp").forward(request, response);
    }

    /**
     * Xử lý thêm comment mới
     */
    private void handleAddComment(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("currentUser");

        // Kiểm tra xem người dùng đã đăng nhập hay chưa
        if (user == null) {
            response.sendError(401, "Unauthorized - User not logged in");
            return;
        }

        int bookId = Integer.parseInt(request.getParameter("bookId"));
        String content = request.getParameter("content");
        int rating = Integer.parseInt(request.getParameter("rating"));

        // Validate input
        if (content == null || content.trim().isEmpty() || rating < 1 || rating > 5) {
            response.sendError(400, "Invalid input");
            return;
        }

        Comment comment = new Comment();
        comment.setBookId(bookId);
        comment.setUserId((int) user.getId());
        comment.setContent(content.trim());
        comment.setRating(rating);

        commentDAO.insertComment(comment);

        // Quay trở lại trang chi tiết sách
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

            // Kiểm tra xem user có phải là admin/librarian hay không
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

        // Kiểm tra xem user có phải là admin hay không
        boolean isAdmin = (user.getRole() != null &&
                ("ADMIN".equals(user.getRole().getName()) ||
                        "LIBRARIAN".equals(user.getRole().getName())));

        boolean deleted = commentDAO.deleteComment(commentId, (int) user.getId(), isAdmin);

        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/books/detail?id=" + bookId);
        } else {
            response.sendError(403, "Forbidden - You can only delete your own comments");
        }
    }

    @Override
    public String getServletInfo() {
        return "Comment Controller for managing book comments";
    }
}
