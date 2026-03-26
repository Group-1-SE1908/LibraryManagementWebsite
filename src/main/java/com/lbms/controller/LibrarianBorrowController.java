package com.lbms.controller;

import com.lbms.dao.LibrarianBorrowDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
import com.lbms.model.Reservation;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = {
    "/staff/borrowlibrary",
    "/staff/borrowlibrary/approve",
    "/staff/borrowlibrary/reject",
    "/staff/borrowlibrary/return",
    "/staff/borrowlibrary/detail",
    "/staff/borrowlibrary/inperson",
    "/staff/borrowlibrary/receive",
    "/staff/borrowlibrary/verifyData",
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
    "/admin/borrowlibrary/verifyData",
    "/admin/renewal",
    "/admin/renewal/approve",
    "/admin/renewal/reject",
    "/admin/renewal/view",
    "/admin/borrowlibrary/ship_fee",
    "/admin/borrowlibrary/ship_confirm"
})
public class LibrarianBorrowController extends HttpServlet {

    private static final String BORROW_SUFFIX = "/borrowlibrary";
    private static final String RENEWAL_SUFFIX = "/renewal";
    private static final Locale VIETNAM_LOCALE = Locale.forLanguageTag("vi-VN");

    private final LibrarianBorrowService libService = new LibrarianBorrowService();
    private final UserDAO userDAO = new UserDAO();
    private final LibrarianBorrowDAO libDAO = new LibrarianBorrowDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {

            requireOperationalAccess(req);

            HttpSession session = req.getSession();
            Object flash = session.getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash); // Đưa vào Request scope
                session.removeAttribute("flash"); // Xóa khỏi Session ngay lập tức
            }

            String path = req.getServletPath();
            String action = getAction(path);
            String basePrefix = resolveBasePrefix(path);
            String borrowBase = basePrefix + BORROW_SUFFIX;
            String renewalBase = basePrefix + RENEWAL_SUFFIX;
            req.setAttribute("staffBorrowBase", borrowBase);
            req.setAttribute("staffRenewalBase", renewalBase);

            // 2. Điều hướng giao diện
            if (path.contains("/renewal") && "view".equals(action)) {
                handleRenewalDetail(req, resp, borrowBase, renewalBase);
                return;
            } else if ("renewal".equals(action)) {
                List<RenewalRequest> renewalTickets = libService.listPendingRenewalRequests();
                Map<Long, List<Reservation>> reservationQueueMap = new HashMap<>();
                for (RenewalRequest ticket : renewalTickets) {
                    BorrowRecord record = ticket.getBorrowRecord();
                    if (record == null || record.getBook() == null) {
                        continue;
                    }
                    long bookId = record.getBook().getId();
                    reservationQueueMap.computeIfAbsent(bookId, id -> {
                        try {
                            return libService.listWaitingReservations(id);
                        } catch (Exception e) {
                            return java.util.Collections.emptyList();
                        }
                    });
                }
                req.setAttribute("renewalTickets", renewalTickets);
                req.setAttribute("reservationQueueMap", reservationQueueMap);
                req.setAttribute("renewalActionPrefix", renewalBase);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/renewal_requests.jsp").forward(req, resp);
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
                    // totalBooks += br.getQuantity();
                    if ("APPROVED".equalsIgnoreCase(br.getStatus())) {
                        totalBooks += br.getQuantity();
                    }
                }
                if (totalBooks == 0) {
                    resp.setStatus(400);
                    resp.getWriter().write("{\"error\": \"Không có sách nào được duyệt để giao!\"}");
                    return;
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
                req.setAttribute("staffBorrowBase", borrowBase);
                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_inperson.jsp").forward(req, resp);

            } else if ("import".equals(action)) {
                req.getRequestDispatcher("book_restock.jsp").forward(req, resp);
                return;

            } else if ("verifyData".equals(action)) {
                try {
                    // 1. Nhận tham số email và barcodes từ request
                    String email = req.getParameter("email");
                    String barcodesRaw = req.getParameter("barcodes");

                    // 2. Tìm kiếm thông tin User theo Email
                    com.lbms.model.User user = null;
                    if (email != null && !email.isBlank()) {
                        // Đảm bảo bạn đã có hàm findByEmail trong UserDAO
                        user = userDAO.findByEmail(email.trim());
                    }

                    // 3. Tìm kiếm danh sách sách theo mã vạch
                    java.util.List<com.lbms.model.BookCopy> copies = new java.util.ArrayList<>();
                    if (barcodesRaw != null && !barcodesRaw.isBlank()) {
                        String[] barcodes = barcodesRaw.split("\\r?\\n");
                        for (String bc : barcodes) {
                            if (!bc.trim().isEmpty()) {
                                // Gọi hàm getBookByBarcode đã thêm vào Service ở bước trước
                                com.lbms.model.BookCopy copy = libService.getBookByBarcode(bc.trim());
                                if (copy != null) {
                                    copies.add(copy);
                                }
                            }
                        }
                    }

                    // 4. Trả về kết quả JSON cho Frontend
                    resp.setContentType("application/json");
                    resp.setCharacterEncoding("UTF-8");
                    // Sử dụng lớp VerificationResult (đã hướng dẫn tạo ở cuối file)
                    String json = new com.google.gson.Gson().toJson(new VerificationResult(user, copies));
                    resp.getWriter().write(json);
                    return; // Dừng lại ở đây, không forward tới trang JSP
                } catch (Exception e) {
                    resp.setStatus(500);
                    resp.getWriter().write("{\"error\": \"" + e.getMessage() + "\"}");
                    return;
                }
//            } else {
//
//                String methodFilter = req.getParameter("filter");
//                String q = req.getParameter("q");
//                String status = req.getParameter("status");
//
//                List<BorrowRecord> list;
//                if ("OVERDUE".equals(methodFilter)) {
//                    list = libDAO.listOverdue();
//                } else {
//                    list = libService.searchBorrowings(q, status, methodFilter);
//                }
//
              
                ////                java.util.Map<String, List<BorrowRecord>> groupedRecords = new java.util.LinkedHashMap<>();
////                java.util.Map<Long, Integer> renewalCountMap = new java.util.HashMap<>();
////                for (BorrowRecord br : list) {
////                    // Nếu là dữ liệu cũ chưa có groupCode, tự cấp 1 mã giả dựa trên ID để không bị
////                    // lỗi gộp
////                    String gc = br.getGroupCode();
////                    if (gc == null || gc.isBlank()) {
////                        gc = "DON-LE-" + br.getId();
////                    }
////                    groupedRecords.computeIfAbsent(gc, k -> new java.util.ArrayList<>()).add(br);
////                    renewalCountMap.put(br.getId(), libService.countRenewalRequestsForBorrow(br.getId()));
////                }
//                Map<String, List<BorrowRecord>> groupedRecords = new LinkedHashMap<>();
//                Map<Long, Integer> renewalCountMap = new HashMap<>();
//
//                for (BorrowRecord br : list) {
//                    // Ưu tiên dùng groupCode thật từ DB
//                    String groupKey = (br.getGroupCode() != null && !br.getGroupCode().trim().isEmpty())
//                            ? br.getGroupCode()
//                            : "SINGLE-" + br.getId();   // đơn lẻ cũ không có groupCode
//
//                    groupedRecords.computeIfAbsent(groupKey, k -> new ArrayList<>()).add(br);
//
//                    renewalCountMap.put(br.getId(), libService.countRenewalRequestsForBorrow(br.getId()));
//                }
//
//                // Sắp xếp nhóm: đơn mới nhất lên trên
//                groupedRecords = groupedRecords.entrySet().stream()
//                        .sorted((e1, e2) -> {
//                            BorrowRecord r1 = e1.getValue().get(0);
//                            BorrowRecord r2 = e2.getValue().get(0);
//                            return Long.compare(r2.getId(), r1.getId()); // DESC by id
//                        })
//                        .collect(Collectors.toMap(
//                                Map.Entry::getKey,
//                                Map.Entry::getValue,
//                                (oldValue, newValue) -> oldValue,
//                                LinkedHashMap::new));
//
//                req.setAttribute("groupedRecords", groupedRecords);
//                req.setAttribute("renewalCountMap", renewalCountMap);
//                java.util.List<RenewalRequest> pendingRenewals = libService.listPendingRenewalRequests();
//                java.util.Map<Long, RenewalRequest> renewalLookup = new java.util.HashMap<>();
//                for (RenewalRequest pending : pendingRenewals) {
//                    renewalLookup.put(pending.getBorrowId(), pending);
//                }
//                req.setAttribute("pendingRenewalMap", renewalLookup);
//                req.setAttribute("staffBorrowBase", borrowBase);
//                req.getRequestDispatcher("/WEB-INF/views/admin/library/borrow_list.jsp").forward(req, resp);
//            }
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

                // ==================== GOM NHÓM THEO GROUP CODE (ĐÃ SỬA) ====================
                Map<String, List<BorrowRecord>> groupedRecords = new LinkedHashMap<>();
                Map<Long, Integer> renewalCountMap = new HashMap<>();

                for (BorrowRecord br : list) {
                    String groupKey = (br.getGroupCode() != null && !br.getGroupCode().trim().isEmpty())
                            ? br.getGroupCode()
                            : "SINGLE-" + br.getId();

                    groupedRecords.computeIfAbsent(groupKey, k -> new ArrayList<>()).add(br);
                    renewalCountMap.put(br.getId(), libService.countRenewalRequestsForBorrow(br.getId()));
                }

                // Sắp xếp nhóm: đơn mới nhất lên trên
                groupedRecords = groupedRecords.entrySet().stream()
                        .sorted((e1, e2) -> {
                            BorrowRecord r1 = e1.getValue().get(0);
                            BorrowRecord r2 = e2.getValue().get(0);
                            return Long.compare(r2.getId(), r1.getId());
                        })
                        .collect(Collectors.toMap(
                                Map.Entry::getKey,
                                Map.Entry::getValue,
                                (oldValue, newValue) -> oldValue,
                                LinkedHashMap::new));

                req.setAttribute("groupedRecords", groupedRecords);
                req.setAttribute("renewalCountMap", renewalCountMap);

                java.util.List<RenewalRequest> pendingRenewals = libService.listPendingRenewalRequests();
                java.util.Map<Long, RenewalRequest> renewalLookup = new java.util.HashMap<>();
                for (RenewalRequest pending : pendingRenewals) {
                    renewalLookup.put(pending.getBorrowId(), pending);
                }
                req.setAttribute("pendingRenewalMap", renewalLookup);
                req.setAttribute("staffBorrowBase", borrowBase);

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

        if (action == null || action.isEmpty() || action.equals("borrowlibrary")) {
            action = req.getParameter("action");
        }
        String redirectBase = resolveRedirectBase(path);

        try {

            requireOperationalAccess(req);

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
            } else if ("create-manual".equals(action)) {
                String groupCode = req.getParameter("groupCode");
                com.lbms.service.ShippingService shipService = new com.lbms.service.ShippingService();
                shipService.createManualGroupShipment(groupCode);
                req.getSession().setAttribute("flash", "Đã tạo mã vận đơn cho đơn hàng " + groupCode);
                resp.sendRedirect(req.getContextPath() + "/staff/borrowlibrary");
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
                String barcode = req.getParameter("barcode");
                if (idStr == null || barcode == null || barcode.trim().isEmpty()) {
                    throw new IllegalArgumentException("Dữ liệu trả sách (ID/Barcode) không được để trống.");
                }

                BigDecimal[] returnResult = libService.returnBook(Long.parseLong(idStr), barcode);
                BigDecimal fineAmount = returnResult[0];
                BigDecimal depositRefund = returnResult[1];
                StringBuilder flashMsg = new StringBuilder("Đã nhận trả sách thành công.");
                if (depositRefund != null && depositRefund.compareTo(BigDecimal.ZERO) > 0) {
                    flashMsg.append(" Đã hoàn 50% tiền cọc (")
                            .append(formatCurrency(depositRefund))
                            .append(" đ) vào ví người mượn.");
                }
                if (fineAmount != null && fineAmount.compareTo(BigDecimal.ZERO) > 0) {
                    flashMsg.append(" Phiếu này phát sinh tiền phạt ")
                            .append(formatCurrency(fineAmount))
                            .append(" đ, vui lòng xác nhận tại mục Tiền phạt nếu khách thanh toán tại quầy.");
                }
                req.getSession().setAttribute("flash", flashMsg.toString());
            } else if ("receive".equals(action)) {
                // long id = Long.parseLong(req.getParameter("id"));
                // libService.confirmReceive(id);
                // req.getSession().setAttribute("flash", "Xác nhận độc giả đã lấy sách thành
                // công.");
                handleReceive(req, resp);
            } else if ("reject".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                String reason = req.getParameter("reason"); // Lấy lý do từ form
                libService.rejectRequest(id, reason, staffId);
                req.getSession().setAttribute("flash", "Đã từ chối yêu cầu. Lý do: " + reason);

            } else if ("inperson".equals(action)) {
                // long userId = Long.parseLong(req.getParameter("userId"));
                String email = req.getParameter("email");
                String rawBarcodes = req.getParameter("barcodes");

                // 1. Tìm userId từ email
                User user = userDAO.findByEmail(email);
                if (user == null) {
                    throw new IllegalArgumentException("Không tìm thấy độc giả có email: " + email);
                }
                long userId = user.getId();

                // 2. Tách mã vạch và xử lý như cũ
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

                /// 3. Gọi Service xử lý mượn
                libService.borrowMultipleInPerson(userId, validBarcodes);
                req.getSession().setAttribute("flash", "Đã cho mượn thành công cho độc giả " + user.getFullName());

                resp.sendRedirect(req.getContextPath() + redirectBase);

                return;
            } else if ("ship_confirm".equals(action)) {
                String groupCode = req.getParameter("groupCode");

                com.lbms.service.ShippingService shippingService = new com.lbms.service.ShippingService();
                shippingService.createManualGroupShipment(groupCode);

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
                // resp.sendRedirect(req.getContextPath() + redirectBase + "/inperson");
                resp.sendRedirect(req.getContextPath() + redirectBase);
            } else {
                resp.sendRedirect(req.getContextPath() + redirectBase);
            }
        } catch (Exception ex) {
            req.getSession().setAttribute("flash", "Lỗi hệ thống: " + ex.getMessage());
            // resp.sendRedirect(req.getContextPath() + redirectBase + "/inperson");
            resp.sendRedirect(req.getContextPath() + redirectBase);
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
        if ("borrowlibrary".equals(action)) {
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
        String basePrefix = resolveBasePrefix(path);
        if (path != null && path.contains(RENEWAL_SUFFIX)) {
            return basePrefix + RENEWAL_SUFFIX;
        }
        return basePrefix + BORROW_SUFFIX;
    }

    private void handleRenewalDetail(HttpServletRequest req, HttpServletResponse resp,
            String borrowBase, String renewalBase) throws Exception {
        long renewalId = parseLongParameter(req, "id", "ID yêu cầu gia hạn không hợp lệ");
        RenewalRequest ticket = libService.getRenewalRequest(renewalId);
        if (ticket == null) {
            throw new IllegalArgumentException("Không tìm thấy yêu cầu gia hạn này.");
        }
        req.setAttribute("renewalTicket", ticket);
        req.setAttribute("renewalRequestCount", libService.countRenewalRequestsForBorrow(ticket.getBorrowId()));
        List<Reservation> reservationQueue = java.util.Collections.emptyList();
        BorrowRecord record = ticket.getBorrowRecord();
        if (record != null && record.getBook() != null) {
            reservationQueue = libService.listWaitingReservations(record.getBook().getId());
        }
        req.setAttribute("reservationQueue", reservationQueue);
        req.setAttribute("renewalActionPrefix", renewalBase);
        req.setAttribute("staffBorrowBase", borrowBase);
        req.setAttribute("staffRenewalBase", renewalBase);
        req.getRequestDispatcher("/WEB-INF/views/admin/library/renewal_request_detail.jsp").forward(req, resp);
    }

    private String resolveBasePrefix(String path) {
        if (path != null && path.startsWith("/admin/")) {
            return "/admin";
        }
        return "/staff";
    }

    private void requireOperationalAccess(HttpServletRequest req) {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null || currentUser.getRole() == null) {
            throw new IllegalArgumentException("Vui lòng đăng nhập để tiếp tục.");
        }
        String role = currentUser.getRole().getName();
        boolean isLibrarian = "LIBRARIAN".equalsIgnoreCase(role);
        boolean isAdmin = "ADMIN".equalsIgnoreCase(role);
        if (!isLibrarian && !isAdmin) {
            throw new IllegalArgumentException("Bạn không có quyền truy cập chức năng này.");
        }
    }

//    private void handleReceive(HttpServletRequest req, HttpServletResponse resp) throws Exception {
//        long id = Long.parseLong(req.getParameter("id"));
//        BorrowRecord record = libService.getDetail(id);
//
//        if (record != null) {
//            if ("ONLINE".equalsIgnoreCase(record.getBorrowMethod())) {
//                // Luồng Online: Cập nhật ngày mượn/trả thực tế
//                libService.confirmReceiveOnline(id);
//            } else {
//                // Luồng tại chỗ: Chỉ cập nhật trạng thái
//                libService.updateStatus(id, "RECEIVED");
//            }
//            req.getSession().setAttribute("flash", "Khách đã nhận thành công!.");
//        }
//        // resp.sendRedirect(req.getContextPath() + "/staff/borrowlibrary");
//    }
    private void handleReceive(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        long id = Long.parseLong(req.getParameter("id"));
        BorrowRecord record = libService.getDetail(id);

        if (record != null) {
            // Không phân biệt Online hay Tại chỗ, hễ khách nhận sách là phải điền ngày mượn
            libService.confirmReceiveOnline(id);

            req.getSession().setAttribute("flash", "Xác nhận khách đã nhận sách thành công!");
        }
    }

    private String formatCurrency(BigDecimal amount) {
        NumberFormat formatter = NumberFormat.getInstance(VIETNAM_LOCALE);
        formatter.setMaximumFractionDigits(0);
        formatter.setMinimumFractionDigits(0);
        return formatter.format(amount);
    }

    @SuppressWarnings("unused")
    private static class VerificationResult {

        User user;
        java.util.List<com.lbms.model.BookCopy> copies;

        VerificationResult(User user, java.util.List<com.lbms.model.BookCopy> copies) {
            this.user = user;
            this.copies = copies;
        }
    }
}
