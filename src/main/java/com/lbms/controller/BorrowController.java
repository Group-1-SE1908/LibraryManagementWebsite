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
    "/borrow/requests", 
    "/borrow/approve", 
    "/borrow/reject", 
    "/borrow/return",
    "/borrow/overdue",
    "/borrow/history"
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
        
        //Code để test không cần đăng nhập
        
        if (req.getSession().getAttribute("currentUser") == null) {
            com.lbms.model.User mockUser = new com.lbms.model.User();
            mockUser.setId(1L); // 1 là ID của Admin, đổi thành 3 nếu muốn test quyền Member
            mockUser.setEmail("admin@library.com");
            mockUser.setFullName("Quản Trị Viên (Test)");
            com.lbms.model.Role mockRole = new com.lbms.model.Role(1L, "ADMIN"); // Đổi thành "MEMBER" nếu test User thường
            mockUser.setRole(mockRole);
            req.getSession().setAttribute("currentUser", mockUser);
        }
        
        // hết code test
        
        
        

        try {
            switch (path) {
                case "/borrow/requests": // UC 30: View Borrow Request
                    requireStaff(req);
                    List<BorrowRecord> pendingRecords = borrowDAO.listPendingRequests();
                    req.setAttribute("records", pendingRecords);
                    req.setAttribute("pageTitle", "Yêu cầu mượn sách (Chờ duyệt)");
                    req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
                    break;
                    
                case "/borrow/approve": // UC 31: Confirm Borrow (Approve)
                    requireStaff(req);
                    long id = Long.parseLong(req.getParameter("id"));
                    String barcode = req.getParameter("barcode"); // Lấy barcode từ form duyệt
                    if (barcode == null || barcode.trim().isEmpty()) {
                        throw new IllegalArgumentException("Vui lòng nhập mã vạch (barcode) để duyệt!");
                    }
                    borrowService.approve(id, barcode.trim());
                    req.getSession().setAttribute("flash", "Duyệt thành công!");
                    resp.sendRedirect(req.getContextPath() + "/borrow/requests");
                    break;
                    
                case "/borrow/reject": // UC 31: Confirm Borrow (Reject)
                    requireStaff(req);
                    long rejectId = Long.parseLong(req.getParameter("id"));
                    borrowService.reject(rejectId);
                    req.getSession().setAttribute("flash", "Đã từ chối yêu cầu.");
                    resp.sendRedirect(req.getContextPath() + "/borrow/requests");
                    break;
                    
                case "/borrow/return": // UC 32: Confirm Return & UC 34: Generate Fine
                    requireStaff(req);
                    long returnId = Long.parseLong(req.getParameter("id"));
                    BigDecimal fine = borrowService.returnBook(returnId);
                    String msg = "Trả sách thành công.";
                    if (fine.compareTo(BigDecimal.ZERO) > 0) msg += " Phạt trễ hạn: " + fine + " VNĐ.";
                    req.getSession().setAttribute("flash", msg);
                    resp.sendRedirect(req.getContextPath() + "/borrow/history");
                    break;
                    
                case "/borrow/overdue": // UC 33: View Overdue List
                    requireStaff(req);
                    List<BorrowRecord> overdueRecords = borrowService.getOverdueList();
                    req.setAttribute("records", overdueRecords);
                    req.setAttribute("pageTitle", "Danh sách quá hạn");
                    req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
                    break;
                    
                case "/borrow/history": // UC 35: View Borrow History
                    User currentUser = (User) req.getSession().getAttribute("currentUser");
                    boolean isStaff = isStaff(currentUser);
                    List<BorrowRecord> records = isStaff ? borrowDAO.listAll() : borrowDAO.listByUser(currentUser.getId());
                    req.setAttribute("records", records);
                    req.setAttribute("isStaff", isStaff);
                    req.setAttribute("pageTitle", "Lịch sử mượn trả");
                    req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
                    break;
                    
                default:
                    resp.sendRedirect(req.getContextPath() + "/borrow/history");
            }
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrow/requests");
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