package com.lbms.controller;

import com.lbms.dao.BookDAO;
import com.lbms.dao.CommentDAO;
import com.lbms.dao.CommentReplyDAO;
import com.lbms.model.Book;
import com.lbms.model.Comment;
import com.lbms.model.CommentReply;
import com.lbms.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(urlPatterns = { "/admin/feedback", "/admin/feedback/*" })
public class AdminFeedbackController extends HttpServlet {

    private CommentDAO commentDAO;
    private CommentReplyDAO replyDAO;
    private BookDAO bookDAO;

    @Override
    public void init() {
        commentDAO = new CommentDAO();
        replyDAO = new CommentReplyDAO();
        bookDAO = new BookDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String path = req.getParameter("action") == null ? "list" : req.getParameter("action");
        try {
            switch (path) {
                case "list":
                    showList(req, resp);
                    break;
                case "view":
                    showDetail(req, resp);
                    break;
                default:
                    showList(req, resp);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String action = req.getParameter("action");
        try {
            if ("delete".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                // currentUser.getId() is long - DAO expects int userId, cast explicitly
                commentDAO.deleteComment(id, (int) currentUser.getId(), true);
                resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=list");
                return;
            } else if ("reply".equals(action)) {
                long commentId = Long.parseLong(req.getParameter("commentId"));
                String content = req.getParameter("replyContent");
                CommentReply r = new CommentReply();
                r.setCommentId(commentId);
                // adminId in CommentReply is int; cast from long
                r.setAdminId((int) currentUser.getId());
                r.setContent(content);
                replyDAO.insertReply(r);
                resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=view&id=" + commentId);
                return;
            } else if ("editReply".equals(action)) {
                long replyId = Long.parseLong(req.getParameter("replyId"));
                String content = req.getParameter("replyContent");
                long commentId = Long.parseLong(req.getParameter("commentId"));
                
                // Kiểm tra xem reply có tồn tại và thuộc về user hiện tại không
                CommentReply existing = replyDAO.findById(replyId);
                if (existing != null && existing.getAdminId() == (int) currentUser.getId()) {
                    replyDAO.updateReply(replyId, content, (int) currentUser.getId());
                }
                resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=view&id=" + commentId);
                return;
            } else if ("deleteReply".equals(action)) {
                long replyId = Long.parseLong(req.getParameter("replyId"));
                long commentId = Long.parseLong(req.getParameter("commentId"));
                
                // Kiểm tra xem reply có tồn tại và thuộc về user hiện tại không
                CommentReply existing = replyDAO.findById(replyId);
                if (existing != null && existing.getAdminId() == (int) currentUser.getId()) {
                    replyDAO.deleteReply(replyId, (int) currentUser.getId());
                }
                resp.sendRedirect(req.getContextPath() + "/admin/feedback?action=view&id=" + commentId);
                return;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
        resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
    }

    private void showList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String filter = req.getParameter("filter"); // "all", "replied", "unreplied"
        if (filter == null) filter = "all";
        
        List<Comment> comments = commentDAO.listAllComments();
        List<Comment> filtered = new ArrayList<>();
        
        for (Comment c : comments) {
            if ("all".equals(filter)) {
                filtered.add(c);
            } else if ("replied".equals(filter)) {
                // Kiểm tra xem comment này có reply không
                List<CommentReply> replies = replyDAO.findByCommentId(c.getCommentId());
                if (!replies.isEmpty()) {
                    filtered.add(c);
                }
            } else if ("unreplied".equals(filter)) {
                // Chỉ hiển thị comment chưa được reply
                List<CommentReply> replies = replyDAO.findByCommentId(c.getCommentId());
                if (replies.isEmpty()) {
                    filtered.add(c);
                }
            }
        }
        
        req.setAttribute("comments", filtered);
        req.setAttribute("filter", filter);
        req.getRequestDispatcher("/WEB-INF/views/admin/library/feedback_list.jsp").forward(req, resp);
    }

    private void showDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        long id = Long.parseLong(req.getParameter("id"));
        Comment c = commentDAO.findById(id);
        if (c == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        
        // Load replies từ DB
        List<CommentReply> replies = null;
        try {
            replies = replyDAO.findByCommentId(id);
            System.out.println("DEBUG: Found " + (replies != null ? replies.size() : 0) + " replies for comment " + id);
        } catch (Exception e) {
            System.err.println("ERROR loading replies: " + e.getMessage());
            e.printStackTrace();
            replies = new java.util.ArrayList<>();
        }
        
        // Load book info để hiển thị tên sách
        Book book = null;
        try {
            book = bookDAO.findById((long) c.getBookId());
        } catch (Exception e) {
            System.err.println("ERROR loading book: " + e.getMessage());
        }
        
        req.setAttribute("comment", c);
        req.setAttribute("replies", replies != null ? replies : new java.util.ArrayList<>());
        req.setAttribute("book", book);
        req.getRequestDispatcher("/WEB-INF/views/admin/library/feedback_detail.jsp").forward(req, resp);
    }
}