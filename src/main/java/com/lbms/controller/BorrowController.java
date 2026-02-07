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

@WebServlet(urlPatterns = {"/borrow", "/borrow/request", "/borrow/approve", "/borrow/reject", "/borrow/return"})
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
                case "/borrow" -> handleList(req, resp);
                case "/borrow/request" -> handleRequestForm(req, resp);
                case "/borrow/approve" -> {
                    requireStaff(req);
                    long id = Long.parseLong(req.getParameter("id"));
                    borrowService.approve(id);
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                }
                case "/borrow/reject" -> {
                    requireStaff(req);
                    long id = Long.parseLong(req.getParameter("id"));
                    borrowService.reject(id);
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                }
                case "/borrow/return" -> {
                    requireStaff(req);
                    long id = Long.parseLong(req.getParameter("id"));
                    BigDecimal fine = borrowService.returnBook(id);
                    req.getSession().setAttribute("flash", "Trả sách thành công. Phạt: " + fine + " VND");
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                }
                default -> resp.sendError(404);
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
                case "/borrow/request" -> handleRequestSubmit(req, resp);
                default -> resp.sendError(405);
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

        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            req.getSession().removeAttribute("flash");
        }

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
        if (bookIdStr == null || bookIdStr.isBlank()) throw new IllegalArgumentException("Vui lòng chọn sách");

        long bookId = Long.parseLong(bookIdStr);
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
        if (u == null || u.getRole() == null || u.getRole().getName() == null) return false;
        String r = u.getRole().getName();
        return "ADMIN".equalsIgnoreCase(r) || "LIBRARIAN".equalsIgnoreCase(r);
    }
}
