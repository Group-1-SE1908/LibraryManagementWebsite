package com.lbms.controller;

import com.lbms.dao.ReservationDAO;
import com.lbms.model.Reservation;
import com.lbms.model.User;
import com.lbms.service.ReservationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/reservations", "/reservations/create", "/reservations/cancel"})
public class ReservationController extends HttpServlet {
    private ReservationService reservationService;
    private ReservationDAO reservationDAO;

    @Override
    public void init() {
        this.reservationService = new ReservationService();
        this.reservationDAO = new ReservationDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/reservations" -> handleList(req, resp);
                case "/reservations/cancel" -> {
                    long id = Long.parseLong(req.getParameter("id"));
                    User currentUser = (User) req.getSession().getAttribute("currentUser");
                    reservationService.cancelReservation(id, currentUser.getId());
                    req.getSession().setAttribute("flash", "Đã hủy đặt trước");
                    resp.sendRedirect(req.getContextPath() + "/reservations");
                }
                default -> resp.sendError(404);
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/reservations");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        req.setCharacterEncoding("UTF-8");

        try {
            switch (path) {
                case "/reservations/create" -> {
                    User currentUser = (User) req.getSession().getAttribute("currentUser");
                    long bookId = Long.parseLong(req.getParameter("bookId"));
                    reservationService.createReservation(currentUser.getId(), bookId);
                    req.getSession().setAttribute("flash", "Đặt trước thành công");
                    resp.sendRedirect(req.getContextPath() + "/reservations");
                }
                default -> resp.sendError(405);
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/reservations");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        boolean isStaff = isStaff(currentUser);

        List<Reservation> reservations = isStaff ? reservationDAO.listAll() : reservationDAO.listByUser(currentUser.getId());
        req.setAttribute("reservations", reservations);
        req.setAttribute("isStaff", isStaff);

        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            req.getSession().removeAttribute("flash");
        }

        req.getRequestDispatcher("/WEB-INF/views/reservation_list.jsp").forward(req, resp);
    }

    private boolean isStaff(User u) {
        if (u == null || u.getRole() == null || u.getRole().getName() == null) return false;
        String r = u.getRole().getName();
        return "ADMIN".equalsIgnoreCase(r) || "LIBRARIAN".equalsIgnoreCase(r);
    }
}
