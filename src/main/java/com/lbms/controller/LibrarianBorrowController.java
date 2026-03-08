package com.lbms.controller;

import com.lbms.dao.BorrowDAO;
import com.lbms.dao.LibrarianBorrowDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.RenewalRequest;
import com.lbms.model.User;
import com.lbms.model.UserBorrowingSummary;
import com.lbms.service.BookService;
import com.lbms.service.LibrarianBorrowService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.List;
import java.util.Locale;

@WebServlet(urlPatterns = {
        "/staff/borrowlibrary",
        "/staff/borrowlibrary/approve",
        "/staff/borrowlibrary/reject",
        "/staff/borrowlibrary/return",
        "/staff/borrowlibrary/detail",
        "/staff/borrowlibrary/inperson",
        "/staff/borrowlibrary/receive",
        "/staff/renewal",
        "/staff/renewal/approve",
        "/staff/renewal/reject",
        "/staff/renewal/view",
        "/staff/borrowlibrary/ship_fee",
        "/staff/borrowlibrary/ship_confirm",
        "/admin/borrowlibrary",
        "/admin/borrowlibrary/approve",
        "/admin/borrowlibrary/reject",
        "/admin/borrowlibrary/return",
        "/admin/borrowlibrary/detail",
        "/admin/borrowlibrary/inperson",
        "/admin/borrowlibrary/receive",
        "/admin/renewal",
        "/admin/renewal/approve",
        "/admin/renewal/reject",
        "/admin/renewal/view",
        "/admin/books",
        "/admin/books/approve",
        "/admin/books/reject",
        "/admin/books/return",
        "/admin/books/detail",
        "/admin/books/inperson",
        "/admin/books/receive",
        "/admin/borrowlibrary/ship_fee",
        "/admin/borrowlibrary/ship_confirm", })
public class LibrarianBorrowController extends HttpServlet {

    private static final String STAFF_BORROW_BASE = "/staff/borrowlibrary";
    private static final String ADMIN_BORROW_BASE = "/admin/borrowlibrary";
    private static final String STAFF_RENEWAL_BASE = "/staff/renewal";
    private static final String ADMIN_RENEWAL_BASE = "/admin/renewal";

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
            String action = getAction(path);

            // 2. Điều hướng giao diện
            if (path.contains("/renewal") && "view".equals(action)) {
                handleRenewalDetail(req, resp);
                return;
            } else if ("detail".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));

                BorrowRecord record = libDAO.findById(id);
                if (record != null) {
                    // record.setUser(userDAO.findById(record.getUser().getId()));
                    // UserBorrowingSummary stats = libDAO.getUserSummary(record.getUser().getId());
                    //// req.setAttribute("record", record);
                    // req.setAttribute("stats", stats);
                    User detailedUser = userDAO.findById(record.getUser().getId());
                    // record.setUser(detailedUser);
                    UserBorrowingSummary stats = libDAO.getUserSummary(detailedUser.getId());
                    int remaining = 5 - stats.getCurrentBorrowed();
                    req.setAttribute("remaining", remaining > 0 ? remaining : 0);
                    req.setAttribute("record", record);
                    req.setAttribute("stats", stats);
                    try {
                        com.lbms.model.Shipment shipment = new com.lbms.dao.ShipmentDAO().findByBorrowRecordId(id);
                        req.setAttribute("shipment", shipment);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                req.setAttribute("record", record);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_detail.jsp").forward(req, resp);

            } else if ("ship_fee".equals(action)) {
                String groupCode = req.getParameter("groupCode");
                if (groupCode == null || groupCode.isBlank()) {
                    resp.setStatus(400);
                    resp.getWriter().write("{\"error\": \"Thiếu mã nhóm\"}");
                    return;
                }

                // Lấy tất cả sách trong cùng 1 đơn (groupCode)
                List<BorrowRecord> groupRecords = libDAO.findByGroupCode(groupCode);
                if (groupRecords == null || groupRecords.isEmpty()) {
                    resp.setStatus(404);
                    resp.getWriter().write("{\"error\": \"Không tìm thấy đơn hàng\"}");
                    return;
                }

                // Tính tổng trọng lượng (Giả định mỗi cuốn sách nặng 500 gram)
                int totalBooks = 0;
                for (BorrowRecord br : groupRecords) {
                    totalBooks += br.getQuantity();
                }
                int totalWeight = totalBooks * 500;

                // Gọi GHTK tính phí
                BorrowRecord firstRecord = groupRecords.get(0);
                long fee = new com.lbms.service.GHTKService().calculateFee(firstRecord.getShippingDetails(),
                        totalWeight);

                // Trả về dữ liệu định dạng JSON cho AJAX hiển thị lên Modal
                resp.setContentType("application/json");
                resp.setCharacterEncoding("UTF-8");
                resp.getWriter().write(String.format("{\"weight\": %d, \"totalBooks\": %d, \"fee\": %d}",
                        totalWeight, totalBooks, fee));
                return;
            } else if ("inperson".equals(action)) {
                List<Book> allBooks = new BookService().search("");
                req.setAttribute("books", allBooks);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_inperson.jsp").forward(req, resp);

            } else if ("renewal".equals(action)) {
                handleRenewalQueue(req, resp);
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

                java.util.Map<String, List<BorrowRecord>> groupedRecords = new java.util.LinkedHashMap<>();
                for (BorrowRecord br : list) {
                    // Nếu là dữ liệu cũ chưa có groupCode, tự cấp 1 mã giả dựa trên ID để không bị
                    // lỗi gộp
                    String gc = br.getGroupCode();
                    if (gc == null || gc.isBlank()) {
                        gc = "DON-LE-" + br.getId();
                    }
                    groupedRecords.computeIfAbsent(gc, k -> new java.util.ArrayList<>()).add(br);
                }

                req.setAttribute("groupedRecords", groupedRecords);
                java.util.List<RenewalRequest> pendingRenewals = libService.listPendingRenewalRequests();
                java.util.Map<Long, RenewalRequest> renewalLookup = new java.util.HashMap<>();
                for (RenewalRequest pending : pendingRenewals) {
                    renewalLookup.put(pending.getBorrowId(), pending);
                }
                req.setAttribute("pendingRenewalMap", renewalLookup);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_list.jsp").forward(req, resp);
            }

        } catch (IllegalArgumentException ex) {
            // SỬA LỖI LẶP TRANG: Lỗi phân quyền thì đẩy về trang chủ (hoặc trang đăng nhập)
            req.getSession().setAttribute("flash", "Truy cập bị từ chối: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception ex) {

            // ex.printStackTrace();
            // req.getSession().setAttribute("flash", "Lỗi hệ thống: " + ex.getMessage());
            // resp.sendRedirect(req.getContextPath() + "/");
            resp.setContentType("text/html;charset=UTF-8");
            resp.getWriter().print("<h1 style='color:red;'>LỖI RỒI: " + ex.getMessage() + "</h1>");
            resp.getWriter().print("<p>Chi tiết lỗi (StackTrace):</p><pre>");
            ex.printStackTrace(resp.getWriter());
            resp.getWriter().print("</pre>");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        String action = getAction(path);
        String redirectBase = resolveRedirectBase(path);

        try {
            requireStaff(req);

            // Lấy thông tin người dùng hiện tại từ session để ghi log hoạt động
            HttpSession session = req.getSession();
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            long staffId = currentUser.getId();

            if (path.contains("/renewal") && "approve".equals(action)) {
                long renewalId = parseLongParameter(req, "renewalId", "ID yêu cầu gia hạn không hợp lệ");
                libService.approveRenewalRequest(renewalId, staffId);
                req.getSession().setAttribute("flash", "Đã phê duyệt yêu cầu gia hạn #" + renewalId);
                resp.sendRedirect(req.getContextPath() + redirectBase);
                return;
            } else if (path.contains("/renewal") && "reject".equals(action)) {
                long renewalId = parseLongParameter(req, "renewalId", "ID yêu cầu gia hạn không hợp lệ");
                String note = req.getParameter("reason");
                libService.rejectRenewalRequest(renewalId, note, staffId);
                req.getSession().setAttribute("flash", "Đã từ chối yêu cầu gia hạn #" + renewalId);
                resp.sendRedirect(req.getContextPath() + redirectBase);
                return;
            } else if ("approve".equals(action)) {
                String idStr = req.getParameter("id");
                String barcode = req.getParameter("barcode");

                if (idStr == null || idStr.isBlank() || barcode == null || barcode.isBlank()) {
                    throw new IllegalArgumentException("Thiếu ID phiếu mượn hoặc mã vạch sách.");
                }

                long id = Long.parseLong(idStr);

                libService.approveRequest(id, barcode, staffId);
                req.getSession().setAttribute("flash", "Duyệt thành công phiếu #" + id);

            } else if ("return".equals(action)) {
                String idStr = req.getParameter("id");
                String barcode = req.getParameter("barcode").trim();
                if (idStr == null || idStr.isBlank()) {
                    throw new IllegalArgumentException("Barcode không hợp lệ.");
                }

                BigDecimal fineAmount = libService.returnBook(Long.parseLong(idStr), barcode);
                if (fineAmount != null && fineAmount.compareTo(BigDecimal.ZERO) > 0) {
                    req.getSession().setAttribute("flash",
                            "Đã nhận trả sách thành công. Phiếu này phát sinh tiền phạt "
                                    + formatCurrency(fineAmount)
                                    + " đ, vui lòng xác nhận tại mục Tiền phạt nếu khách thanh toán tại quầy.");
                } else {
                    req.getSession().setAttribute("flash", "Đã nhận trả sách thành công.");
                }
            } else if ("receive".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                libService.confirmReceive(id);
                req.getSession().setAttribute("flash", "Xác nhận độc giả đã lấy sách thành công.");
            } else if ("reject".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                String reason = req.getParameter("reason"); // Lấy lý do từ form
                libService.rejectRequest(id, reason, staffId);
                req.getSession().setAttribute("flash", "Đã từ chối yêu cầu. Lý do: " + reason);

            } else if ("inperson".equals(action)) {
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
                req.getSession().setAttribute("flash",
                        "Đã cho mượn thành công " + validBarcodes.size() + " cuốn sách!");

                resp.sendRedirect(req.getContextPath() + redirectBase);
                return;
            } else if ("ship_confirm".equals(action)) {
                String groupCode = req.getParameter("groupCode");

                com.lbms.service.ShippingService shippingService = new com.lbms.service.ShippingService();
                shippingService.createGroupShipment(groupCode);

                req.getSession().setAttribute("flash", "Đã đẩy đơn hàng gồm nhiều sách sang GHTK thành công!");
                // Sau khi giao xong cả nhóm, quay thẳng về trang danh sách (borrow_list)
                resp.sendRedirect(req.getContextPath() + redirectBase);
                return;
            }

            resp.sendRedirect(req.getContextPath() + redirectBase);

        } catch (IllegalArgumentException ex) {
            // Bắt riêng lỗi nghiệp vụ (sai barcode, giới hạn mượn...)
            req.getSession().setAttribute("flash", "Lỗi: " + ex.getMessage());
            if ("inperson".equals(action)) {
                resp.sendRedirect(req.getContextPath() + redirectBase + "/inperson");
            } else {
                resp.sendRedirect(req.getContextPath() + redirectBase);
            }
        } catch (Exception ex) {
            req.getSession().setAttribute("flash", "Lỗi hệ thống: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + redirectBase + "/inperson");
        }
    }

    private String getAction(String path) {
        if (path == null || path.isBlank()) {
            return "";
        }

        int lastSlash = path.lastIndexOf('/');
        if (lastSlash < 0 || lastSlash == path.length() - 1) {
            return "";
        }

        String action = path.substring(lastSlash + 1);
        if ("borrowlibrary".equals(action) || "books".equals(action)) {
            return "";
        }
        return action;
    }

    private long parseLongParameter(HttpServletRequest req, String name, String message) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(message);
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException(message);
        }
    }

    private String resolveRedirectBase(String path) {
        if (path != null) {
            if (path.startsWith(ADMIN_RENEWAL_BASE)) {
                return ADMIN_RENEWAL_BASE;
            }
            if (path.startsWith(STAFF_RENEWAL_BASE)) {
                return STAFF_RENEWAL_BASE;
            }
            if (path.startsWith("/admin/")) {
                return ADMIN_BORROW_BASE;
            }
        }
        return STAFF_BORROW_BASE;
    }

    private void handleRenewalQueue(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        List<RenewalRequest> tickets = libService.listPendingRenewalRequests();
        String actionPrefix = req.getServletPath().startsWith("/admin/") ? ADMIN_RENEWAL_BASE : STAFF_RENEWAL_BASE;
        req.setAttribute("renewalTickets", tickets);
        req.setAttribute("renewalActionPrefix", actionPrefix);
        req.getRequestDispatcher("/WEB-INF/views/admin/library/renewal_requests.jsp").forward(req, resp);
    }

    private void handleRenewalDetail(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        long renewalId = parseLongParameter(req, "id", "ID yêu cầu gia hạn không hợp lệ");
        RenewalRequest ticket = libService.getRenewalRequest(renewalId);
        if (ticket == null) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu gia hạn này.");
        }
        String actionPrefix = req.getServletPath().startsWith("/admin/") ? ADMIN_RENEWAL_BASE : STAFF_RENEWAL_BASE;
        req.setAttribute("renewalTicket", ticket);
        req.setAttribute("renewalActionPrefix", actionPrefix);
        req.getRequestDispatcher("/WEB-INF/views/admin/library/renewal_request_detail.jsp").forward(req, resp);
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

    private String formatCurrency(BigDecimal amount) {
        NumberFormat formatter = NumberFormat.getInstance(new Locale("vi", "VN"));
        formatter.setMaximumFractionDigits(0);
        formatter.setMinimumFractionDigits(0);
        return formatter.format(amount);
    }
}
