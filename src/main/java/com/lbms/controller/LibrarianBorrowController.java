package com.lbms.controller;

import com.lbms.dao.BorrowDAO;
import com.lbms.dao.LibrarianBorrowDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.model.UserBorrowingSummary;
import com.lbms.service.BookService;
import com.lbms.service.LibrarianBorrowService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(urlPatterns = {"/borrowlibrary", "/borrowlibrary/approve", "/borrowlibrary/reject", "/borrowlibrary/return", "/borrowlibrary/detail", "/borrowlibrary/inperson","/borrowlibrary/receive"})
public class LibrarianBorrowController extends HttpServlet {

    private final LibrarianBorrowService libService = new LibrarianBorrowService();
    private final BorrowDAO borrowDAO = new BorrowDAO();
    private final UserDAO userDAO = new UserDAO();
    private final LibrarianBorrowDAO libDAO = new LibrarianBorrowDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {

            requireStaff(req);

            HttpSession session = req.getSession();
            Object flash = session.getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash); // Đưa vào Request scope
                session.removeAttribute("flash"); // Xóa khỏi Session ngay lập tức
            }

            String path = req.getServletPath();

            // 2. Điều hướng giao diện
            if ("/borrowlibrary/detail".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));

                BorrowRecord record = libDAO.findById(id);
                if (record != null) {
                    record.setUser(userDAO.findById(record.getUser().getId()));
                    UserBorrowingSummary stats = libDAO.getUserSummary(record.getUser().getId());
//                    req.setAttribute("record", record);
                    req.setAttribute("stats", stats);
                }
                req.setAttribute("record", record);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_detail.jsp").forward(req, resp);

            } else if ("/borrowlibrary/inperson".equals(path)) {
                List<Book> allBooks = new BookService().search("");
                req.setAttribute("books", allBooks);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_inperson.jsp").forward(req, resp);

            } else {

                String methodFilter = req.getParameter("filter");
                String q = req.getParameter("q");
                String status = req.getParameter("status");

                List<BorrowRecord> list;
                if ("OVERDUE".equals(methodFilter)) {
                    list = libDAO.listOverdue();
                } else {
                    list = libService.searchBorrowings(q, status, methodFilter);
                }

                req.setAttribute("records", list);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_list.jsp").forward(req, resp);
            }

        } catch (IllegalArgumentException ex) {
            // SỬA LỖI LẶP TRANG: Lỗi phân quyền thì đẩy về trang chủ (hoặc trang đăng nhập)
            req.getSession().setAttribute("flash", "Truy cập bị từ chối: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception ex) {
            // SỬA LỖI LẶP TRANG: Nếu lỗi DB, không thể load danh sách thì đẩy về trang chủ
            req.getSession().setAttribute("flash", "Lỗi hệ thống: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            requireStaff(req);
            String path = req.getServletPath();

            if ("/borrowlibrary/approve".equals(path)) {
                String idStr = req.getParameter("id");
                String barcode = req.getParameter("barcode");

               
                if (idStr == null || idStr.isBlank() || barcode == null || barcode.isBlank()) {
                    throw new IllegalArgumentException("Thiếu ID phiếu mượn hoặc mã vạch sách.");
                }

                long id = Long.parseLong(idStr);
                
                libService.approveRequest(id, barcode);
                req.getSession().setAttribute("flash", "Duyệt thành công phiếu #" + id);

            } else if ("/borrowlibrary/return".equals(path)) {
                String idStr = req.getParameter("id");
                String barcode = req.getParameter("barcode");
                if (idStr == null || idStr.isBlank()) {
                    throw new IllegalArgumentException("Barcode không hợp lệ.");
                }

                libService.returnBook(Long.parseLong(idStr), barcode);
                req.getSession().setAttribute("flash", "Đã nhận trả sách thành công.");
            } else if ("/borrowlibrary/receive".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                libService.confirmReceive(id);
                req.getSession().setAttribute("flash", "Xác nhận độc giả đã lấy sách thành công.");
            } else if ("/borrowlibrary/reject".equals(path)) {
                long id = Long.parseLong(req.getParameter("id"));
                String reason = req.getParameter("reason"); // Lấy lý do từ form
                libService.rejectRequest(id, reason);
                req.getSession().setAttribute("flash", "Đã từ chối yêu cầu. Lý do: " + reason);

            } else if ("/borrowlibrary/inperson".equals(path)) {
                long userId = Long.parseLong(req.getParameter("userId"));
                String rawBarcodes = req.getParameter("barcodes");

                // Tách chuỗi mã vạch dựa trên khoảng trắng hoặc dấu xuống dòng (Enter)
                String[] barcodeArray = rawBarcodes.split("\\r?\\n");
                List<String> validBarcodes = new java.util.ArrayList<>();
                for (String bc : barcodeArray) {
                    if (!bc.trim().isEmpty()) {
                        validBarcodes.add(bc.trim());
                    }
                }

                if (validBarcodes.isEmpty()) {
                    throw new IllegalArgumentException("Chưa có mã vạch nào được nhập.");
                }

                // Gọi hàm mượn nhiều cuốn
                libService.borrowMultipleInPerson(userId, validBarcodes);
                req.getSession().setAttribute("flash", "Đã cho mượn thành công " + validBarcodes.size() + " cuốn sách!");

                resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
                return;
            }

            resp.sendRedirect(req.getContextPath() + "/borrowlibrary");

        } catch (IllegalArgumentException ex) {
            // Bắt riêng lỗi nghiệp vụ (sai barcode, giới hạn mượn...)
            req.getSession().setAttribute("flash", "Lỗi: " + ex.getMessage());
            if ("/borrowlibrary/inperson".equals(req.getServletPath())) {
                resp.sendRedirect(req.getContextPath() + "/borrowlibrary/inperson");
            } else {
                resp.sendRedirect(req.getContextPath() + "/borrowlibrary");
            }
        } catch (Exception ex) {
            req.getSession().setAttribute("flash", "Lỗi hệ thống: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrowlibrary/inperson_form");
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
