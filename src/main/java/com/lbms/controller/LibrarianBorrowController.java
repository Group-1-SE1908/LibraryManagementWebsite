package com.lbms.controller;

import com.lbms.dao.BorrowDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.service.LibrarianBorrowService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = {"/borrowlibrary", "/borrowlibrary/approve", "/borrowlibrary/reject", "/borrowlibrary/return", "/borrowlibrary/detail"})
public class LibrarianBorrowController extends HttpServlet {

    private final LibrarianBorrowService libService = new LibrarianBorrowService();
    private final BorrowDAO borrowDAO = new BorrowDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        try {
            requireStaff(req);
            String path = req.getServletPath();
            if ("/borrowlibrary/detail".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                BorrowRecord record = borrowDAO.findById(id);
                if (record != null) {
                    record.setUser(userDAO.findById(record.getUser().getId()));
                }
                req.setAttribute("record", record);
                req.getRequestDispatcher("/WEB-INF/views/borrow_detail.jsp").forward(req, resp);
            } else if ("/borrowlibrary/approve".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                String barcode = req.getParameter("barcode");
                libService.approveRequest(id, barcode);
                req.getSession().setAttribute("flash", "Duyệt thành công phiếu #" + id);
                resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
            } else if ("/borrowlibrary/return".equals(path)) {
                String idStr = req.getParameter("id");
                String barcode = req.getParameter("barcode");

                if (idStr == null || barcode == null || barcode.trim().isEmpty()) {
                    throw new IllegalArgumentException("Thiếu ID hoặc mã vạch sách.");
                }

                libService.returnBook(Long.parseLong(idStr), barcode);
                req.getSession().setAttribute("flash", "Đã nhận trả sách thành công.");
                resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
            } else { // Mặc định là trang danh sách + Lọc
                String q = req.getParameter("q");
                String status = req.getParameter("status");
                List<BorrowRecord> list = libService.searchBorrowings(q, status);
                req.setAttribute("records", list);
                req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
            }

        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", "Truy cập bị từ chối: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
        } catch (Exception ex) {
            req.getSession().setAttribute("flash", "Lỗi hệ thống: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            requireStaff(req);
            String path = req.getServletPath();

            if ("/borrowlibrary/approve".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                String barcode = req.getParameter("barcode");
                libService.approveRequest(id, barcode);
                req.getSession().setAttribute("flash", "Duyệt thành công phiếu #" + id);
            } else if ("/borrowlibrary/return".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                String barcode = req.getParameter("barcode");
                libService.returnBook(id, barcode);
                req.getSession().setAttribute("flash", "Đã nhận trả sách thành công.");
            } else if ("/borrowlibrary/reject".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                libService.rejectRequest(id);
                req.getSession().setAttribute("flash", "Đã từ chối yêu cầu #" + id);
            }
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
        } catch (Exception ex) {
            req.getSession().setAttribute("flash", "Lỗi: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
        }
    }

    private void requireStaff(HttpServletRequest req) {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null || currentUser.getRole() == null) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        String role = currentUser.getRole().getName();
        if (!"ADMIN".equalsIgnoreCase(role) && !"LIBRARIAN".equalsIgnoreCase(role)) {
            throw new IllegalArgumentException("Bạn không có quyền truy cập chức năng này.");
        }
    }
}
