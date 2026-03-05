package com.lbms.controller;

import com.lbms.model.Reservation;
import com.lbms.model.User;
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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Reservation> reservations =
                    reservationService.listByUser(currentUser.getId());
            req.setAttribute("reservations", reservations);
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
        if (action == null) action = "";

        try {
            switch (action) {

                case "add" -> {
                    long bookId = Long.parseLong(req.getParameter("bookId"));
                    // Logic validate nằm hết trong Service
                    reservationService.createReservation(currentUser.getId(), bookId);
                    setFlash(req, "success",
                            "Đặt trước sách thành công! Chúng tôi sẽ thông báo khi sách có sẵn.");
                    resp.sendRedirect(req.getContextPath() + "/reservation");
                }

                case "cancel" -> {
                    long resId = Long.parseLong(req.getParameter("resId"));
                    reservationService.cancelReservation(resId, currentUser.getId());
                    setFlash(req, "success", "Hủy đặt trước thành công.");
                    resp.sendRedirect(req.getContextPath() + "/reservation");
                }

                default -> resp.sendRedirect(req.getContextPath() + "/reservation");
            }

        } catch (IllegalArgumentException | IllegalStateException e) {
            // Lỗi nghiệp vụ từ Service → hiển thị lại form với thông báo
            setFlash(req, "error", e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/reservation");

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────
    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) return null;
        return (User) session.getAttribute("currentUser");
    }

    private void setFlash(HttpServletRequest req, String type, String msg) {
        String key = type.equals("success") ? "successMsg" : "errorMsg";
        req.getSession().setAttribute(key, msg);
    }
}