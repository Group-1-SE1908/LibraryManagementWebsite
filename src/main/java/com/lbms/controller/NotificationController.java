package com.lbms.controller;

import com.lbms.dao.UserDAO;
import com.lbms.model.User;
import com.lbms.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/notifications")
public class NotificationController extends HttpServlet {

    private static final Logger logger = Logger.getLogger(NotificationController.class.getName());
    private final NotificationService notificationService = new NotificationService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int userId = (int) currentUser.getId();

            List<Map<String, Object>> notifications = notificationService.listByUser(userId);
            int unreadCount = notificationService.getUnreadCount(userId);

            req.setAttribute("notifications", notifications);
            req.setAttribute("unreadCount", unreadCount);

            String role = currentUser.getRole().getName().toUpperCase();
            if ("ADMIN".equals(role) || "LIBRARIAN".equals(role)) {
                List<User> targetUsers;
                if ("ADMIN".equals(role)) {

                    targetUsers = userDAO.findAllActiveExceptMe(userId);
                } else {

                    targetUsers = userDAO.findByRoleName("MEMBER");
                }
                req.setAttribute("users", targetUsers);
                req.setAttribute("isAdmin", "ADMIN".equals(role));
            }

            req.getRequestDispatcher("/WEB-INF/views/notifications.jsp").forward(req, resp);

        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Lỗi tải dữ liệu thông báo", e);
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        HttpSession session = req.getSession();

        try {
            if ("create".equals(action)) {
                handleSendLogic(req, currentUser);
                session.setAttribute("successMessage", "Thông báo đã được gửi thành công!");
            } else if ("markRead".equals(action)) {
                long notifId = Long.parseLong(req.getParameter("notifId"));
                notificationService.markAsRead(notifId, (int) currentUser.getId());
            } else if ("markAllRead".equals(action)) {
                notificationService.markAllRead(currentUser.getId());
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Thao tác thông báo thất bại", e);
            session.setAttribute("errorMessage", "Lỗi: " + e.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/notifications");
    }

    private void handleSendLogic(HttpServletRequest req, User sender) throws SQLException {
        String role = sender.getRole().getName().toUpperCase();
        String mode = req.getParameter("notification_mode");
        String title = req.getParameter("title");
        String message = req.getParameter("message");
        String type = "GENERAL_NOTICE";
        int senderId = (int) sender.getId();

        if (title == null || title.isBlank() || message == null || message.isBlank()) {
            throw new IllegalArgumentException("Tiêu đề và nội dung không được để trống!");
        }

        if ("ADMIN".equals(role)) {
            switch (mode) {
                case "ALL_SYSTEM" -> notificationService.sendToAll(senderId, type, title, message);
                case "ALL_LIBRARIANS" ->
                    notificationService.sendToRole("LIBRARIAN", senderId, "ADMIN", type, title, message);
                case "ALL_USERS" ->
                    notificationService.sendToRole("MEMBER", senderId, "ADMIN", type, title, message);
                case "SPECIFIC" -> {
                    String receiverId = req.getParameter("receiver_id");
                    if (receiverId != null && !receiverId.isEmpty()) {
                        notificationService.sendToUser(Integer.parseInt(receiverId), senderId, "ADMIN", type, title,
                                message);
                    } else {
                        throw new IllegalArgumentException("Vui lòng chọn người nhận cụ thể!");
                    }
                }
            }
        } else if ("LIBRARIAN".equals(role)) {
            if ("ALL_USERS".equals(mode)) {
                notificationService.sendToRole("MEMBER", senderId, "LIBRARIAN", type, title, message);
            } else if ("SPECIFIC".equals(mode)) {
                String receiverId = req.getParameter("receiver_id");
                if (receiverId != null && !receiverId.isEmpty()) {
                    notificationService.sendToUser(Integer.parseInt(receiverId), senderId, "LIBRARIAN", type, title,
                            message);
                } else {
                    throw new IllegalArgumentException("Vui lòng chọn người nhận cụ thể!");
                }
            }
        } else {
            throw new IllegalStateException("Bạn không có quyền thực hiện thao tác này!");
        }
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return (session != null) ? (User) session.getAttribute("currentUser") : null;
    }
}