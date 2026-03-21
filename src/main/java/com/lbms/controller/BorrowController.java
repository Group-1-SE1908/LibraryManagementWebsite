package com.lbms.controller;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowHistoryEntry;
import com.lbms.model.BorrowRecord;
import com.lbms.model.RenewalRequest;
import com.lbms.model.User;
import com.lbms.service.BorrowService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(urlPatterns = {"/borrow", "/borrow/request", "/borrow/approve", "/borrow/reject", "/borrow/cancel",
    "/borrow/return",
    "/borrow/renew",
    "/borrow/renew/cancel",
    "/history", "/renew-history","/borrow/returnOnline"})
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
                    String barcode = req.getParameter("barcode"); // Láº¥y barcode tá»« form

                    if (barcode == null || barcode.trim().isEmpty()) {
                        req.getSession().setAttribute("flash", "Vui lÃ²ng nháº­p Barcode Ä‘á»ƒ duyá»‡t sÃ¡ch");
                        resp.sendRedirect(req.getContextPath() + "/borrow");
                        return;
                    }

                    borrowService.approve(id, barcode);
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                    break;
                case "/borrow/reject":
                    requireStaff(req);
                    long rejectId = Long.parseLong(req.getParameter("id"));
                    borrowService.reject(rejectId);
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                    break;
                case "/borrow/cancel":
                    User user = (User) req.getSession().getAttribute("currentUser");
                    if (user == null) {
                        resp.sendRedirect(req.getContextPath() + "/login");
                        return;
                    }
                    long cancelId = Long.parseLong(req.getParameter("id"));
                    borrowService.cancelRequest(cancelId, user.getId());
                    req.getSession().setAttribute("flash", "Đã hủy yêu cầu thành công");
                    resp.sendRedirect(req.getContextPath() + "/history");
                    break;
                case "/borrow/return":
                    requireStaff(req);
                    long returnId = Long.parseLong(req.getParameter("id"));
                    BigDecimal fine = borrowService.returnBook(returnId);
                    req.getSession().setAttribute("flash", "Tráº£ sÃ¡ch thÃ nh cÃ´ng. Pháº¡t: " + fine + " VND");
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                    break;
                case "/history":
                    handleHistory(req, resp);
                    break;
                case "/renew-history":
                    handleRenewHistory(req, resp);
                    break;
                case "/borrow/overdue":
                    requireStaff(req);
                    List<BorrowRecord> overdueRecords = borrowDAO.listOverdue();
                    req.setAttribute("records", overdueRecords);
                    req.setAttribute("isOverduePage", true); // Äá»ƒ Ä‘Ã¡nh dáº¥u trÃªn giao diá»‡n
                    req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
                    break;
                case "/borrow/returnOnline":
                    handleReturnOnlineRequest(req, resp);
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
                case "/borrow/renew":
                    handleRenewalSubmit(req, resp);
                    break;
                case "/borrow/renew/cancel":
                    handleRenewalCancel(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    // Cáº­p nháº­t hÃ m handleList trong BorrowController.java
    private void handleList(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        boolean isStaff = isStaff(currentUser);

        List<BorrowRecord> records;
        String filter = req.getParameter("filter"); // Láº¥y tham sá»‘ tá»« URL

        if (isStaff) {
            if ("OVERDUE".equals(filter)) {
                records = borrowDAO.listOverdue();
                req.setAttribute("pageTitle", "â° Danh sÃ¡ch sÃ¡ch quÃ¡ háº¡n");
            } else if ("ONLINE".equals(filter)) {
                // Gá»ŒI HÃ€M Má»šI Táº O Äá»‚ Lá»ŒC RIÃŠNG ONLINE
                records = borrowDAO.listByMethod("ONLINE");
                req.setAttribute("pageTitle", "ðŸŒ Danh sÃ¡ch yÃªu cáº§u Online");
            } else {
                records = borrowDAO.listAll();
                req.setAttribute("pageTitle", "ðŸ› ï¸ Quáº£n lÃ½ mÆ°á»£n tráº£ toÃ n há»‡ thá»‘ng");
            }
        } else {
            records = borrowDAO.listByUser(currentUser.getId());
            req.setAttribute("pageTitle", "ðŸ“– Lá»‹ch sá»­ mÆ°á»£n sÃ¡ch cá»§a tÃ´i");
        }

        req.setAttribute("records", records);
        req.setAttribute("isStaff", isStaff);
        req.getRequestDispatcher("/WEB-INF/views/borrow_list.jsp").forward(req, resp);
    }

    private void handleRequestForm(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<Book> books = bookDAO.search(req.getParameter("q"));
        req.setAttribute("books", books);
        req.setAttribute("q", req.getParameter("q"));
        req.getRequestDispatcher("/WEB-INF/views/borrow_request.jsp").forward(req, resp);
    }

    // private void handleRequestSubmit(HttpServletRequest req, HttpServletResponse
    // resp) throws Exception {
    // User currentUser = (User) req.getSession().getAttribute("currentUser");
    // String bookIdStr = req.getParameter("bookId");
    // if (bookIdStr == null || bookIdStr.isBlank()) {
    // throw new IllegalArgumentException("Vui lÃ²ng chá»n sÃ¡ch");
    // }
    //
    // long bookId = Long.parseLong(bookIdStr);
    //
    //
    // borrowService.requestBorrow(currentUser.getId(), bookId, "ONLINE", null);
    //
    // req.getSession().setAttribute("flash", "Gá»­i yÃªu cáº§u mÆ°á»£n thÃ nh cÃ´ng
    // (chá» thá»§ thÆ° duyá»‡t)");
    // resp.sendRedirect(req.getContextPath() + "/borrow");
    // }
    private void handleRequestSubmit(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // 1. Lấy thông tin từ request
            long bookId = Long.parseLong(req.getParameter("bookId"));

            // Lấy số lượng: mặc định là 1 nếu không có tham số truyền lên
            String qtyStr = req.getParameter("quantity");
            int quantity = (qtyStr != null && !qtyStr.isBlank()) ? Integer.parseInt(qtyStr) : 1;

            int currentActiveBorrows = borrowService.countActiveBorrows(currentUser.getId());
            int remainingSlots = BorrowService.MAX_ACTIVE_BORROWS - currentActiveBorrows;
            if (remainingSlots <= 0) {
                req.getSession().setAttribute("flash",
                        "Bạn đang có " + currentActiveBorrows
                        + " cuốn đang mượn/đang chờ duyệt (giới hạn " + BorrowService.MAX_ACTIVE_BORROWS
                        + " cuốn). Vui lòng trả sách hoặc hủy yêu cầu trước khi mượn thêm.");
                resp.sendRedirect(req.getContextPath() + "/borrow/request");
                return;
            }
            if (quantity > remainingSlots) {
                req.getSession().setAttribute("flash",
                        "Bạn vừa yêu cầu mượn " + quantity
                        + " cuốn nhưng chỉ có thể mượn thêm tối đa " + remainingSlots
                        + " cuốn nữa (giới hạn " + BorrowService.MAX_ACTIVE_BORROWS + " cuốn).");
                resp.sendRedirect(req.getContextPath() + "/borrow/request");
                return;
            }

            // Lấy phương thức mượn: mặc định là IN_PERSON
            String method = req.getParameter("method");
            if (method == null || method.isBlank()) {
                method = "IN_PERSON";
            }

            // 2. Xử lý ShippingDetails nếu mượn Online (Nếu form có gửi lên)
            com.lbms.model.ShippingDetails sd = null;
            if ("ONLINE".equalsIgnoreCase(method)) {
                sd = new com.lbms.model.ShippingDetails();
                sd.setRecipient(req.getParameter("recipient") != null ? req.getParameter("recipient")
                        : currentUser.getFullName());
                sd.setPhone(req.getParameter("phone") != null ? req.getParameter("phone") : currentUser.getPhone());
                sd.setStreet(req.getParameter("address"));
                // Các trường city/district/ward có thể lấy từ form nếu có
            }

            // 3. Gọi Service với đầy đủ thông tin (Bao gồm quantity mới thêm)
            // Lưu ý: Đảm bảo BorrowService.requestBorrow đã được cập nhật signature nhận
            // 'int quantity'
            borrowService.requestBorrow(currentUser.getId(), bookId, quantity, method, sd);

            req.getSession().setAttribute("flash",
                    "Gửi yêu cầu mượn " + quantity + " cuốn thành công! Vui lòng chờ thủ thư duyệt.");
            resp.sendRedirect(req.getContextPath() + "/history");

        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash", "Lỗi: Dữ liệu không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/borrow/request");
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/borrow/request");
        }
    }

    private void handleHistory(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<BorrowRecord> records = borrowDAO.listByUser(currentUser.getId());
        String statusFilter = optionalFilter(req.getParameter("status"));
        List<String> filterStatuses = statusesForFilter(statusFilter);
        if (!filterStatuses.isEmpty()) {
            records = records.stream()
                    .filter(r -> {
                        String status = r.getStatus();
                        return status != null && filterStatuses.contains(status.toUpperCase());
                    })
                    .collect(Collectors.toList());
        } else {
            statusFilter = "all";
        }

        int historyTotalCopies = records.stream()
                .mapToInt(r -> Math.max(1, r.getQuantity()))
                .sum();

        List<BorrowHistoryEntry> historyEntries = new ArrayList<>();
        for (BorrowRecord record : records) {
            int copies = Math.max(1, record.getQuantity());
            for (int copyIndex = 1; copyIndex <= copies; copyIndex++) {
                historyEntries.add(new BorrowHistoryEntry(record, copyIndex, copies));
            }
        }

        Map<Long, List<RenewalRequest>> renewalHistory = new HashMap<>();
        for (BorrowRecord record : records) {
            List<RenewalRequest> requests = borrowService.getRenewalRequestsForBorrow(record.getId());
            if (requests != null && !requests.isEmpty()) {
                renewalHistory.put(record.getId(), requests);
            }
        }

        req.setAttribute("records", records);
        req.setAttribute("historyStatusFilter", statusFilter);
        req.setAttribute("historyTotalCopies", historyTotalCopies);
        req.setAttribute("historyEntries", historyEntries);
        req.setAttribute("renewalHistory", renewalHistory);

        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            req.getSession().removeAttribute("flash");
        }

        req.getRequestDispatcher("/WEB-INF/views/borrow_history.jsp").forward(req, resp);
    }

    private void handleRenewHistory(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        List<BorrowRecord> records = borrowDAO.listByUser(currentUser.getId());

        // Gom tất cả RenewalRequest thành 1 list phẳng
        List<RenewalRequest> renewalList = new ArrayList<>();
        Map<Long, String> borrowBookMap = new HashMap<>();
        for (BorrowRecord record : records) {
            if (record.getBook() != null) {
                borrowBookMap.put(record.getId(), record.getBook().getTitle());
            }
            List<RenewalRequest> requests = borrowService.getRenewalRequestsForBorrow(record.getId());
            if (requests != null) {
                renewalList.addAll(requests);
            }
        }
        req.setAttribute("renewalList", renewalList);
        req.setAttribute("borrowBookMap", borrowBookMap);

        Object flash = req.getSession().getAttribute("flash");
        if (flash != null) {
            req.setAttribute("flash", flash);
            req.getSession().removeAttribute("flash");
        }

        req.getRequestDispatcher("/WEB-INF/views/renew_history.jsp").forward(req, resp);
    }

    private void handleRenewalSubmit(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String borrowIdParam = req.getParameter("borrowId");
        if (borrowIdParam == null || borrowIdParam.isBlank()) {
            req.getSession().setAttribute("flash", "Không có hồ sơ gia hạn hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        long borrowId;
        try {
            borrowId = Long.parseLong(borrowIdParam);
        } catch (NumberFormatException ex) {
            req.getSession().setAttribute("flash", "ID hồ sơ không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        String reason = req.getParameter("reason");
        String contactName = req.getParameter("contactName");
        String contactPhone = req.getParameter("contactPhone");
        String contactEmail = req.getParameter("contactEmail");

        try {
            borrowService.requestRenewal(currentUser.getId(), borrowId, reason, contactName, contactPhone,
                    contactEmail);
            req.getSession().setAttribute("flash", "Yêu cầu gia hạn đã gửi thủ thư. Hãy chờ phê duyệt.");
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/history");
    }

    private void handleRenewalCancel(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String borrowIdParam = req.getParameter("borrowId");
        if (borrowIdParam == null || borrowIdParam.isBlank()) {
            req.getSession().setAttribute("flash", "Không có hồ sơ gia hạn hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        long borrowId;
        try {
            borrowId = Long.parseLong(borrowIdParam);
        } catch (NumberFormatException ex) {
            req.getSession().setAttribute("flash", "ID hồ sơ không hợp lệ");
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        try {
            borrowService.cancelRenewalRequest(currentUser.getId(), borrowId);
            req.getSession().setAttribute("flash", "Yêu cầu gia hạn đã bị hủy");
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
        }

        resp.sendRedirect(req.getContextPath() + "/history");
    }

    private String optionalFilter(String value) {
        if (value == null || value.isBlank()) {
            return "all";
        }
        return value.trim().toLowerCase();
    }

    private List<String> statusesForFilter(String normalized) {
        switch (normalized) {
            case "borrowing":
                return List.of("BORROWED", "RECEIVED", "SHIPPING", "RETURN_REQUESTED");
            case "pending":
                return List.of("REQUESTED", "RENEWAL_REQUESTED");
            case "returned":
                return List.of("RETURNED");
            default:
                return List.of();
        }
    }

    private void requireStaff(HttpServletRequest req) {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (!isStaff(currentUser)) {
            throw new IllegalArgumentException("Báº¡n khÃ´ng cÃ³ quyá»n thá»±c hiá»‡n thao tÃ¡c nÃ y");
        }
    }

    private boolean isStaff(User u) {
        if (u == null || u.getRole() == null || u.getRole().getName() == null) {
            return false;
        }
        String r = u.getRole().getName();
        return "ADMIN".equalsIgnoreCase(r) || "LIBRARIAN".equalsIgnoreCase(r);
    }

    private void handleReturnOnlineRequest(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            long id = Long.parseLong(req.getParameter("id"));
            // Cập nhật trạng thái sang RETURN_REQUESTED
            // Bạn có thể dùng hàm updateStatus có sẵn trong borrowDAO
            borrowDAO.updateStatus(id, "RETURN_REQUESTED");

            req.getSession().setAttribute("flash", "Yêu cầu trả sách đã được gửi. Vui lòng chờ thư viện xác nhận.");
        } catch (Exception e) {
            req.getSession().setAttribute("flash", "Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/history");
    }
}
