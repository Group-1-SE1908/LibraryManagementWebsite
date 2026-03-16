package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.NotificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

@WebServlet("/notifications")
public class NotificationController extends HttpServlet {

    private final NotificationService notifService = new NotificationService();

    // ── GET: hiển thị trang danh sách thông báo ───────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Map<String, Object>> notifications =
                    notifService.listByUser(currentUser.getId());
            int unreadCount = notifService.countUnread(currentUser.getId());

            req.setAttribute("notifications", notifications);
            req.setAttribute("unreadCount", unreadCount);

            req.getRequestDispatcher("/WEB-INF/views/notifications.jsp")
                    .forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    // ── POST: đánh dấu đã đọc ─────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null) action = "";

        try {
            switch (action) {

                case "markRead" -> {
                    long notifId = Long.parseLong(req.getParameter("notifId"));
                    notifService.markRead(notifId, currentUser.getId());
                    resp.sendRedirect(req.getContextPath() + "/notifications");
                }

                case "markAllRead" -> {
                    notifService.markAllRead(currentUser.getId());
                    resp.sendRedirect(req.getContextPath() + "/notifications");
                }

                default -> resp.sendRedirect(req.getContextPath() + "/notifications");
            }

        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/notifications");
        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("currentUser");
    }
}