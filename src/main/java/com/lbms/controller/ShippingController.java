package com.lbms.controller;

import com.lbms.dao.BorrowDAO;
import com.lbms.dao.ShipmentDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.Shipment;
import com.lbms.model.User;
import com.lbms.service.ShippingService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = { "/shipping", "/shipping/new", "/shipping/status" })
public class ShippingController extends HttpServlet {
    private ShippingService shippingService;
    private ShipmentDAO shipmentDAO;
    private BorrowDAO borrowDAO;

    @Override
    public void init() {
        this.shippingService = new ShippingService();
        this.shipmentDAO = new ShipmentDAO();
        this.borrowDAO = new BorrowDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/shipping":
                    handleList(req, resp);
                    break;
                case "/shipping/new":
                    requireStaff(req);
                    String borrowIdStr = req.getParameter("borrowId");
                    if (borrowIdStr == null) {
                        resp.sendRedirect(req.getContextPath() + "/borrow");
                        return;
                    }
                    BorrowRecord br = borrowDAO.findById(Long.parseLong(borrowIdStr));
                    if (br == null) {
                        resp.sendRedirect(req.getContextPath() + "/borrow");
                        return;
                    }
                    req.setAttribute("borrow", br);
                    req.getRequestDispatcher("/WEB-INF/views/shipping_form.jsp").forward(req, resp);
                    break;
                case "/shipping/status":
                    requireStaff(req);
                    long shipmentId = Long.parseLong(req.getParameter("id"));
                    Shipment s = shippingService.refreshStatus(shipmentId);
                    req.setAttribute("shipment", s);
                    req.getRequestDispatcher("/WEB-INF/views/shipping_status.jsp").forward(req, resp);
                    break;
                default:
                    resp.sendError(404);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/shipping");
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
                case "/shipping/new":
                    requireStaff(req);
                    long borrowId = Long.parseLong(req.getParameter("borrowId"));
                    String address = req.getParameter("address");
                    String phone = req.getParameter("phone");
                    shippingService.createShipment(borrowId, address, phone);
                    req.getSession().setAttribute("flash", "Tạo đơn giao hàng thành công");
                    resp.sendRedirect(req.getContextPath() + "/shipping");
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            try {
                BorrowRecord br = borrowDAO.findById(Long.parseLong(req.getParameter("borrowId")));
                req.setAttribute("borrow", br);
            } catch (Exception ignore) {
            }
            req.getRequestDispatcher("/WEB-INF/views/shipping_form.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        boolean isStaff = isStaff(currentUser);
        if (!isStaff) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        List<Shipment> shipments = shipmentDAO.listAll();
        req.setAttribute("shipments", shipments);

        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            req.getSession().removeAttribute("flash");
        }

        req.getRequestDispatcher("/WEB-INF/views/shipping_list.jsp").forward(req, resp);
    }

    private void requireStaff(HttpServletRequest req) {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (!isStaff(currentUser)) {
            throw new IllegalArgumentException("Bạn không có quyền thực hiện thao tác này");
        }
    }

    private boolean isStaff(User u) {
        if (u == null || u.getRole() == null || u.getRole().getName() == null)
            return false;
        String r = u.getRole().getName();
        return "ADMIN".equalsIgnoreCase(r) || "LIBRARIAN".equalsIgnoreCase(r);
    }
}
