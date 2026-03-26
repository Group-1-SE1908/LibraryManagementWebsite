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

@WebServlet(urlPatterns = {
        "/staff/reservation",
        "/staff/reservation/queue",
        "/admin/reservation",
        "/admin/reservation/queue"
})
public class LibrarianReservationController extends HttpServlet {

    private final ReservationService reservationService = new ReservationService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Kiểm tra quyền (chỉ LIBRARIAN và ADMIN) ──────────────────────
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        if (!isLibrarianOrAdmin(currentUser)) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập.");
            return;
        }

        try {
            String action = req.getParameter("action");
            if (action == null)
                action = "";

            if ("queue".equals(action)) {
                // Hiển thị hàng chờ của một cuốn sách
                handleQueueView(req, resp);
            } else {
                // Hiển thị toàn bộ danh sách đặt trước
                handleListView(req, resp);
            }

        } catch (SQLException e) {
            throw new ServletException("Database error", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Kiểm tra quyền ──────────────────────────────────────────────
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            sendJsonResponse(resp, HttpServletResponse.SC_UNAUTHORIZED,
                    "Bạn phải đăng nhập");
            return;
        }

        if (!isLibrarianOrAdmin(currentUser)) {
            sendJsonResponse(resp, HttpServletResponse.SC_FORBIDDEN,
                    "Bạn không có quyền truy cập");
            return;
        }

        try {
            String action = req.getParameter("action");
            if (action == null)
                action = "";

            switch (action) {
                case "approve":
                    handleApproveReservation(req, resp, currentUser);
                    break;
                case "reject":
                    handleRejectReservation(req, resp, currentUser);
                    break;
                case "scan":
                    handleBarcodeVerify(req, resp, currentUser);
                    break;
                default:
                    sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                            "Hành động không hợp lệ");
            }
        } catch (SQLException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }
    }

    /**
     * Xác nhận user đã lấy sách - chuyển reservation sang BORROWED
     */
    private void handleApproveReservation(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {

        try {
            long reservationId = Long.parseLong(req.getParameter("reservationId"));

            // Gọi service để confirm pickup (không có barcode cụ thể -> tự lấy cuốn available)
            reservationService.confirmReservationPickup(reservationId, null);

            sendJsonResponse(resp, HttpServletResponse.SC_OK,
                    "Đã xác nhận lấy sách thành công");
        } catch (NumberFormatException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    "ID không hợp lệ");
        }
    }

    /**
     * Từ chối đặt trước - cancel reservation
     */
    private void handleRejectReservation(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {

        try {
            long reservationId = Long.parseLong(req.getParameter("reservationId"));
            String reason = req.getParameter("reason");
            if (reason == null)
                reason = "Không có lý do";

            // Gọi service để reject reservation
            reservationService.rejectReservation(reservationId, reason);

            sendJsonResponse(resp, HttpServletResponse.SC_OK,
                    "Đã từ chối đặt trước");
        } catch (NumberFormatException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    "ID không hợp lệ");
        }
    }

    /**
     * Verify barcode - kiểm tra mã vạch
     */
    private void handleBarcodeVerify(HttpServletRequest req, HttpServletResponse resp, User user)
            throws SQLException, ServletException, IOException {

        try {
            long reservationId = Long.parseLong(req.getParameter("reservationId"));
            String barcode = req.getParameter("barcode");

            if (barcode == null || barcode.trim().isEmpty()) {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        "Mã barcode không hợp lệ");
                return;
            }

            // Verify barcode
            if (reservationService.verifyBookBarcode(reservationId, barcode)) {
                // Barcode valid - mark as borrowed with specific barcode
                reservationService.confirmReservationPickup(reservationId, barcode.trim());
                sendJsonResponse(resp, HttpServletResponse.SC_OK,
                        "Barcode hợp lệ - Xác nhận thành công");
            } else {
                sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                        "Barcode không khớp với sách trong đặt trước");
            }
        } catch (NumberFormatException e) {
            sendJsonResponse(resp, HttpServletResponse.SC_BAD_REQUEST,
                    "ID không hợp lệ");
        }
    }

    /**
     * Hiển thị toàn bộ danh sách đặt trước của hệ thống
     */
    private void handleListView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {

        List<Reservation> allReservations = reservationService.listAll();
        req.setAttribute("reservations", allReservations);
        req.setAttribute("pageTitle", "Quản lý đặt trước sách");

        req.getRequestDispatcher("/WEB-INF/views/admin/library/reservation_list.jsp")
                .forward(req, resp);
    }

    /**
     * Hiển thị hàng chờ của một cuốn sách cụ thể
     */
    private void handleQueueView(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException, SQLException {

        try {
            long bookId = Long.parseLong(req.getParameter("bookId"));
            List<Reservation> queue = reservationService.listWaitingQueue(bookId);

            req.setAttribute("queue", queue);
            req.setAttribute("bookId", bookId);
            req.setAttribute("pageTitle", "Hàng chờ - Sách ID: " + bookId);

            req.getRequestDispatcher("/WEB-INF/views/admin/library/reservation_queue.jsp")
                    .forward(req, resp);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Book ID không hợp lệ");
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────────

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return null;
        return (User) session.getAttribute("currentUser");
    }

    private boolean isLibrarianOrAdmin(User user) {
        if (user == null || user.getRole() == null)
            return false;
        String roleName = user.getRole().getName();
        return "LIBRARIAN".equals(roleName) || "ADMIN".equals(roleName);
    }

    /**
     * Gửi JSON response (cho AJAX requests)
     */
    private void sendJsonResponse(HttpServletResponse resp, int statusCode, String message)
            throws IOException {
        resp.setContentType("application/json; charset=UTF-8");
        resp.setStatus(statusCode);
        resp.getWriter().write("{\"status\": " + statusCode + ", \"message\": \"" +
                message.replace("\"", "\\\"") + "\"}");
    }
}
