package com.lbms.controller;

import com.lbms.model.Reservation;
import com.lbms.model.User;
import com.lbms.service.NotificationService;
import com.lbms.service.ReservationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/reservation")
public class ReservationServlet extends HttpServlet {

    private final ReservationService reservationService = new ReservationService();
    private final NotificationService notifService = new NotificationService();

    // ── GET: hiển thị danh sách reservation của user ─────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Reservation> reservations = reservationService.listByUser(currentUser.getId());
            req.setAttribute("reservations", reservations);
            req.setAttribute("maxReservations", reservationService.getMaxReservations());

            // Đếm unread notifications để hiển thị badge trên navbar
            int unreadCount = notifService.countUnread(currentUser.getId());
            req.setAttribute("unreadNotifCount", unreadCount);

            req.getRequestDispatcher("/WEB-INF/views/reserve_list.jsp")
                    .forward(req, resp);

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    // ── POST ──────────────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null)
            action = "";

        try {
            switch (action) {

                // ── Đặt trước sách ────────────────────────────────────────
                case "add" -> {
                    long bookId = Long.parseLong(req.getParameter("bookId"));
                    reservationService.createReservation(currentUser.getId(), bookId);
                    setFlash(req, "success",
                            "Đặt trước sách thành công! " +
                                    "Chúng tôi sẽ thông báo ngay khi sách có sẵn.");
                    resp.sendRedirect(req.getContextPath() + "/reservation");
                }

                // ── Hủy đặt trước ─────────────────────────────────────────
                case "cancel" -> {
                    long resId = Long.parseLong(req.getParameter("resId"));
                    reservationService.cancelReservation(resId, currentUser.getId());
                    setFlash(req, "success", "Hủy đặt trước thành công.");
                    resp.sendRedirect(req.getContextPath() + "/reservation");
                }

                // ── Đánh dấu đã đọc tất cả thông báo ─────────────────────
                case "markAllRead" -> {
                    notifService.markAllRead(currentUser.getId());
                    resp.sendRedirect(req.getContextPath() + "/reservation");
                }

                default -> resp.sendRedirect(req.getContextPath() + "/reservation");
            }

        } catch (NumberFormatException e) {
            setFlash(req, "error", "Dữ liệu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/reservation");

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Lỗi nghiệp vụ từ Service (A1, A2, A3) → flash error
            setFlash(req, "error", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/reservation");

        } catch (SQLException e) {
            // E1/E2 – lỗi database
            throw new ServletException("Database error", e);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return null;
        return (User) session.getAttribute("currentUser");
    }

    private void setFlash(HttpServletRequest req, String type, String msg) {
        String key = "success".equals(type) ? "successMsg" : "errorMsg";
        req.getSession().setAttribute(key, msg);
    }
}