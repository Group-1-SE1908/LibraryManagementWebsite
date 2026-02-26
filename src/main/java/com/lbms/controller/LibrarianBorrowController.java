package com.lbms.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

import com.lbms.dao.BorrowDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.service.BorrowService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = { 
    "/borrowlibrary", 
    "/borrowlibrary/approve", 
    "/borrowlibrary/reject", 
    "/borrowlibrary/return",
    "/borrowlibrary/overdue" 
})
public class LibrarianBorrowController extends HttpServlet {
    private BorrowService borrowService;
    private BorrowDAO borrowDAO;

    @Override
    public void init() {
        this.borrowService = new BorrowService();
        this.borrowDAO = new BorrowDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            requireStaff(req);

            switch (path) {
                case "/borrowlibrary":
                    handleLibrarianList(req, resp);
                    break;
                case "/borrowlibrary/approve":
                    handleApprove(req, resp);
                    break;
                case "/borrowlibrary/reject":
                    handleReject(req, resp);
                    break;
                case "/borrowlibrary/return":
                    handleReturn(req, resp);
                    break;
                case "/borrowlibrary/overdue":
                    handleOverdueList(req, resp);
                    break;
                default:
                    resp.sendError(404);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleLibrarianList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<BorrowRecord> records = borrowDAO.listAll(); 
        req.setAttribute("records", records);
        req.setAttribute("pageTitle", "Quản lý mượn trả hệ thống");
        req.setAttribute("isStaff", true);
        req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
    }

    private void handleApprove(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        long id = Long.parseLong(req.getParameter("id"));
        String barcode = req.getParameter("barcode");

        if (barcode == null || barcode.trim().isEmpty()) {
            req.getSession().setAttribute("flash", "Vui lòng nhập Barcode để duyệt sách");
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
            return;
        }

        borrowService.approve(id, barcode);
        resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
    }

    private void handleReject(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        long rejectId = Long.parseLong(req.getParameter("id"));
        borrowService.reject(rejectId);
        resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
    }

    private void handleReturn(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        long returnId = Long.parseLong(req.getParameter("id"));
        BigDecimal fine = borrowService.returnBook(returnId);
        req.getSession().setAttribute("flash", "Trả sách thành công. Phạt: " + fine + " VND");
        resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
    }

    private void handleOverdueList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<BorrowRecord> overdueRecords = borrowDAO.listOverdue();
        req.setAttribute("records", overdueRecords);
        req.setAttribute("pageTitle", "Danh sách sách quá hạn");
        req.setAttribute("isStaff", true);
        req.setAttribute("filter", "OVERDUE");
        req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
    }

    private void requireStaff(HttpServletRequest req) {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null || !isStaff(currentUser)) {
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