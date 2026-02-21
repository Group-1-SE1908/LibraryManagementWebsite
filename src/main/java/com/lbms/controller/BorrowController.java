package com.lbms.controller;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.service.BorrowService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = { 
    "/borrow", 
    "/borrow/request", 
    "/borrow/approve", 
    "/borrow/reject", 
    "/borrow/return",
    "/borrow/overdue" // Thêm đường dẫn cho danh sách quá hạn
})
public class BorrowController extends HttpServlet {
    private BorrowService borrowService;
    private BorrowDAO borrowDAO;
    private BookDAO bookDAO;

    @Override
    public void init() {
        this.borrowService = new BorrowService();
        this.borrowDAO = new BorrowDAO();
        this.bookDAO = new BookDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();

        try {
            switch (path) {
                case "/borrow":
                    handleList(req, resp);
                    break;
                case "/borrow/request":
                    handleRequestForm(req, resp);
                    break;
                case "/borrow/approve":
                    requireStaff(req);
                    long id = Long.parseLong(req.getParameter("id"));
                    borrowService.approve(id);
                    req.getSession().setAttribute("flash", "Đã duyệt yêu cầu mượn sách thành công.");
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                    break;
                case "/borrow/reject":
                    requireStaff(req);
                    long rejectId = Long.parseLong(req.getParameter("id"));
                    borrowService.reject(rejectId);
                    req.getSession().setAttribute("flash", "Đã từ chối yêu cầu mượn sách.");
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                    break;
                case "/borrow/return":
                    requireStaff(req);
                    long returnId = Long.parseLong(req.getParameter("id"));
                    BigDecimal fine = borrowService.returnBook(returnId);
                    String msg = "Đánh dấu trả sách thành công.";
                    if (fine.compareTo(BigDecimal.ZERO) > 0) {
                        msg += " Khách hàng bị phạt trễ hạn: " + fine + " VNĐ.";
                    }
                    req.getSession().setAttribute("flash", msg);
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                    break;
                case "/borrow/overdue":
                    requireStaff(req);
                    handleOverdueList(req, resp);
                    break;
                default:
                    resp.sendError(404);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrow");
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
                case "/borrow/request":
                    handleRequestSubmit(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            try {
                handleRequestForm(req, resp);
            } catch (Exception e) {
                throw new ServletException(e);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        boolean isStaff = isStaff(currentUser);

        List<BorrowRecord> records = isStaff ? borrowDAO.listAll() : borrowDAO.listByUser(currentUser.getId());
        req.setAttribute("records", records);
        req.setAttribute("isStaff", isStaff);
        req.setAttribute("pageTitle", "Danh sách phiếu mượn");

        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            req.getSession().removeAttribute("flash");
        }

        req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
    }

    private void handleOverdueList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<BorrowRecord> records = borrowService.getOverdueList();
        
        req.setAttribute("records", records);
        req.setAttribute("isStaff", true);
        req.setAttribute("pageTitle", "Danh sách mượn sách QUÁ HẠN"); // Để phân biệt trên giao diện

        req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
    }

    private void handleRequestForm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Book> books = bookDAO.search(req.getParameter("q"));
        req.setAttribute("books", books);
        req.setAttribute("q", req.getParameter("q"));
        req.getRequestDispatcher("/WEB-INF/views/borrow_request.jsp").forward(req, resp);
    }

    private void handleRequestSubmit(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        String bookIdStr = req.getParameter("bookId");
        if (bookIdStr == null || bookIdStr.isBlank())
            throw new IllegalArgumentException("Vui lòng chọn sách");

        int bookId = Integer.parseInt(bookIdStr);
        borrowService.requestBorrow(currentUser.getId(), bookId);

        req.getSession().setAttribute("flash", "Gửi yêu cầu mượn thành công (chờ thủ thư duyệt)");
        resp.sendRedirect(req.getContextPath() + "/borrow");
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