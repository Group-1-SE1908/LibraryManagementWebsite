package com.lbms.controller;

import com.lbms.config.VNPayConfig;
import com.lbms.dao.BookDAO;
import com.lbms.dao.PaymentHistoryDAO;
import com.lbms.dao.UserDAO;
import com.lbms.model.Book;
import com.lbms.model.Cart;
import com.lbms.model.CartItem;
import com.lbms.model.PaymentHistory;
import com.lbms.model.ShippingDetails;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.service.CartService;
import com.lbms.service.EmailService;
import com.lbms.service.WalletService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.TimeZone;
import java.util.stream.Collectors;

@WebServlet(urlPatterns = { "/cart", "/cart/add", "/cart/update", "/cart/remove", "/cart/checkout",
        "/cart/checkout/process", "/cart/checkout/pay-wallet" })
public class CartController extends HttpServlet {

    private CartService cartService;
    private BorrowService borrowService;
    private UserDAO userDAO;
    private EmailService emailService;
    private WalletService walletService;
    private PaymentHistoryDAO paymentHistoryDAO;
    private static final String METHOD_ONLINE = "ONLINE";
    private static final String METHOD_IN_PERSON = "IN_PERSON";
    private static final String ROLE_LIBRARIAN = "LIBRARIAN";
    private static final DateTimeFormatter DISPLAY_DATE_FORMAT = DateTimeFormatter.ofPattern("dd/MM/yyyy");

    @Override
    public void init() {
        this.cartService = new CartService();
        this.borrowService = new BorrowService();
        this.userDAO = new UserDAO();
        this.emailService = new EmailService();
        this.walletService = new WalletService();
        this.paymentHistoryDAO = new PaymentHistoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            if ("/cart".equals(path)) {
                Cart cart = cartService.getCart(currentUser.getId());
                req.setAttribute("cart", cart);
                req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/cart/add":
                    handleAdd(req, resp, currentUser);
                    break;
                case "/cart/update":
                    handleUpdate(req, resp, currentUser);
                    break;
                case "/cart/remove":
                    handleRemove(req, resp, currentUser);
                    break;
                case "/cart/checkout":
                    handleBorrowRequestFromCart(req, resp, currentUser);
                    break;
                case "/cart/checkout/process":
                    handleCheckoutProcess(req, resp, currentUser);
                    break;
                case "/cart/checkout/pay-wallet":
                    handleWalletCheckout(req, resp, currentUser);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (IllegalArgumentException ex) {
            handlePostError(req, resp, path, ex.getMessage());
        } catch (Exception ex) {
            ex.printStackTrace();
            throw new ServletException(ex);
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        int quantity = parseIntParam(req, "quantity", 1);
        cartService.addBook(currentUser.getId(), bookId, quantity);
        redirectWithParam(req, resp, "/books", "cartSuccess", "Đã thêm sách vào giỏ hàng");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        int quantity = parseIntParam(req, "quantity", null);
        cartService.updateQuantity(currentUser.getId(), bookId, quantity);
        String message = quantity <= 0 ? "Đã xóa sách khỏi giỏ hàng" : "Đã cập nhật số lượng trong giỏ hàng";
        redirectWithParam(req, resp, "/cart", "cartSuccess", message.toString());
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        cartService.removeBook(currentUser.getId(), bookId);
        redirectWithParam(req, resp, "/cart", "cartSuccess", "Đã xóa sách khỏi giỏ hàng");
    }

    private void handlePostError(HttpServletRequest req, HttpServletResponse resp, String path, String message)
            throws IOException {
        String target = "/books";
        if ("/cart/update".equals(path) || "/cart/remove".equals(path) || "/cart/checkout".equals(path)) {
            target = "/cart";
        }
        redirectWithParam(req, resp, target, "cartError", message);
    }

    private void handleBorrowRequestFromCart(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws Exception {
        String method = parseBorrowMethod(req.getParameter("borrowMethod"));

        String contactName = currentUser.getFullName();
        String contactPhone = currentUser.getPhone();
        String contactEmail = currentUser.getEmail();

        String formName = req.getParameter("contactName");
        String formPhone = req.getParameter("contactPhone");
        String formEmail = req.getParameter("contactEmail");

        if (formName != null && !formName.isBlank())
            contactName = formName;
        if (formPhone != null && !formPhone.isBlank())
            contactPhone = formPhone;
        if (formEmail != null && !formEmail.isBlank())
            contactEmail = formEmail;

        int borrowDays = parseIntParam(req, "borrowDuration", 7);
        LocalDate pickupDate = null;
        String formattedPickupDate = null;
        LocalDate returnDate = null;
        String formattedReturnDate;
        ShippingDetails shippingDetails = null;

        String deliveryAddress = req.getParameter("deliveryAddress");
        if (deliveryAddress != null && !deliveryAddress.isBlank()) {
            userDAO.updateProfile(currentUser.getId(), currentUser.getFullName(), currentUser.getPhone(),
                    deliveryAddress);
            currentUser.setAddress(deliveryAddress);
            req.getSession().setAttribute("currentUser", currentUser);
        }

        if (METHOD_IN_PERSON.equals(method)) {
            pickupDate = parsePickupDateParam(req, "pickupDate");
            formattedPickupDate = pickupDate.format(DISPLAY_DATE_FORMAT);
            returnDate = pickupDate.plusDays(borrowDays);
        } else if (METHOD_ONLINE.equals(method)) {
            String shippingRecipient = req.getParameter("shippingRecipient");
            String shippingRecipientPhone = req.getParameter("shippingPhone");
            String shippingStreet = req.getParameter("shippingStreet");
            String shippingCity = req.getParameter("shippingCity");
            String shippingDistrict = req.getParameter("shippingDistrict");
            String shippingWard = req.getParameter("shippingWard");
            String shippingResidence = req.getParameter("shippingResidence");

            if (shippingRecipient != null && !shippingRecipient.isBlank()
                    && shippingRecipientPhone != null && !shippingRecipientPhone.isBlank()
                    && shippingStreet != null && !shippingStreet.isBlank()
                    && shippingCity != null && !shippingCity.isBlank()
                    && shippingDistrict != null && !shippingDistrict.isBlank()
                    && shippingWard != null && !shippingWard.isBlank()) {
                shippingDetails = new ShippingDetails(
                        shippingRecipient, normalizePhoneDigits(shippingRecipientPhone),
                        shippingStreet, shippingResidence, shippingWard, shippingDistrict, shippingCity);
            }
            returnDate = LocalDate.now().plusDays(borrowDays);
        }

        if (returnDate == null)
            returnDate = LocalDate.now().plusDays(borrowDays);
        formattedReturnDate = returnDate.format(DISPLAY_DATE_FORMAT);

        Cart cart = cartService.getCart(currentUser.getId());
        if (cart == null || cart.getItems().isEmpty()) {
            redirectWithParam(req, resp, "/cart", "cartError", "Giỏ hàng trống");
            return;
        }

        List<CartItem> items = new ArrayList<>(cart.getItems());
        int currentActiveBorrows = borrowService.countActiveBorrows(currentUser.getId());
        int requestedBooks = items.stream().mapToInt(CartItem::getQuantity).sum();
        if (currentActiveBorrows + requestedBooks > BorrowService.MAX_ACTIVE_BORROWS) {
            redirectWithParam(req, resp, "/cart", "cartError",
                    "Bạn đang có " + currentActiveBorrows + " cuốn đang mượn/đang chờ duyệt, tối đa "
                            + BorrowService.MAX_ACTIVE_BORROWS + " cuốn cùng lúc. Vui lòng giảm số sách trong giỏ.");
            return;
        }

        if (METHOD_ONLINE.equals(method)) {
            // ── Tính tổng cọc (BigDecimal để giữ chính xác khi lưu DB) ──────────
            BigDecimal totalDeposit = items.stream()
                    .map(item -> {
                        BigDecimal sub = BigDecimal.valueOf(item.getSubtotal());
                        return sub.multiply(BigDecimal.valueOf(0.5));
                    })
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            double totalValue = items.stream().mapToDouble(CartItem::getSubtotal).sum();

            // ── Tạo txnRef và lưu TOÀN BỘ dữ liệu vào session ─────────────────
            String txnRef = "CART-" + currentUser.getId() + "-" + System.currentTimeMillis();

            Map<String, Object> checkoutData = new HashMap<>();
            checkoutData.put("method", method);
            checkoutData.put("contactName", contactName);
            checkoutData.put("contactPhone", contactPhone);
            checkoutData.put("contactEmail", contactEmail);
            checkoutData.put("borrowDays", borrowDays);
            checkoutData.put("formattedReturnDate", formattedReturnDate);
            checkoutData.put("formattedPickupDate", formattedPickupDate);
            checkoutData.put("shippingDetails", shippingDetails); // ← lưu đúng chỗ
            checkoutData.put("items", items);
            checkoutData.put("totalDeposit", totalDeposit);
            // Tính và lưu depositAmount cho từng item ngay lúc này (khi book còn đủ data)
            List<BigDecimal> depositAmounts = items.stream()
                    .map(item -> BigDecimal.valueOf(item.getSubtotal()).multiply(BigDecimal.valueOf(0.5)))
                    .collect(java.util.stream.Collectors.toList());
            checkoutData.put("depositAmounts", depositAmounts);
            req.getSession().setAttribute("cartCheckout-" + txnRef, checkoutData);

            // ── Forward sang checkout_cart.jsp kèm txnRef để form POST lại ─────
            req.setAttribute("cart", cart);
            req.setAttribute("totalDeposit", totalDeposit.doubleValue());
            req.setAttribute("totalValue", totalValue);
            req.setAttribute("borrowMethod", method);
            req.setAttribute("contactName", contactName);
            req.setAttribute("contactPhone", contactPhone);
            req.setAttribute("contactEmail", contactEmail);
            req.setAttribute("borrowDuration", borrowDays);
            req.setAttribute("pickupDate", formattedPickupDate);
            req.setAttribute("returnDate", formattedReturnDate);
            req.setAttribute("shippingDetails", shippingDetails);
            req.setAttribute("txnRef", txnRef); // ← truyền txnRef xuống JSP
            req.getRequestDispatcher("/WEB-INF/views/checkout_cart.jsp").forward(req, resp);
            return;
        }

        // ── IN_PERSON: tạo borrow records ngay, không qua VNPay ─────────────
        for (CartItem item : items) {
            String groupCode = "REQ-" + System.currentTimeMillis() + "-" + currentUser.getId();
            borrowService.requestBorrowCopies(currentUser.getId(), item.getBookId(), method, shippingDetails,
                    item.getQuantity(), groupCode);
        }

        cartService.clearCart(currentUser.getId());
        notifyLibrarians(currentUser, items, method, contactName, contactPhone, contactEmail,
                formattedReturnDate, formattedPickupDate, shippingDetails);

        StringBuilder message = new StringBuilder();
        message.append("Gửi yêu cầu mượn ").append(toMethodLabel(method)).append(" thành công. ");
        message.append("Ngày trả dự kiến ").append(formattedReturnDate).append(". ");
        if (formattedPickupDate != null)
            message.append("Ngày đến lấy: ").append(formattedPickupDate).append(". ");
        if (shippingDetails != null) {
            message.append("Người nhận: ").append(shippingDetails.getRecipient()).append(". ");
            message.append("Điện thoại người nhận: ").append(shippingDetails.getPhone()).append(". ");
            message.append("Địa chỉ giao: ").append(shippingDetails.getFormattedAddress()).append(". ");
        }
        message.append("Thủ thư sẽ phản hồi sớm.");
        redirectWithParam(req, resp, "/cart", "cartSuccess", message.toString());
    }

    private void handleCheckoutProcess(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws Exception {
        // ── Lấy txnRef đã tạo ở bước trước (truyền qua hidden input) ────────
        String txnRef = req.getParameter("txnRef");
        if (txnRef == null || txnRef.isBlank()) {
            redirectWithParam(req, resp, "/cart", "cartError", "Phiên thanh toán không hợp lệ, vui lòng thử lại.");
            return;
        }

        // ── Đọc lại checkoutData từ session (đã lưu đầy đủ ở bước trên) ─────
        @SuppressWarnings("unchecked")
        Map<String, Object> checkoutData = (Map<String, Object>) req.getSession()
                .getAttribute("cartCheckout-" + txnRef);
        if (checkoutData == null) {
            redirectWithParam(req, resp, "/cart", "cartError", "Phiên thanh toán đã hết hạn, vui lòng đặt lại.");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> items = (List<CartItem>) checkoutData.get("items");
        if (items == null || items.isEmpty()) {
            redirectWithParam(req, resp, "/cart", "cartError", "Giỏ hàng trống");
            return;
        }

        // ── Tính deposit từ items trong session (chắc chắn có subtotal) ─────
        BigDecimal totalDeposit = items.stream()
                .map(item -> {
                    BigDecimal sub = BigDecimal.valueOf(item.getSubtotal());
                    return sub.multiply(BigDecimal.valueOf(0.5));
                })
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // VNPay yêu cầu đơn vị là VND * 100
        long amount = totalDeposit.multiply(BigDecimal.valueOf(100)).longValue();

        // ── Tạo VNPay URL ────────────────────────────────────────────────────
        String vnp_TmnCode = VNPayConfig.vnp_TmnCode;
        String vnp_IpAddr = VNPayConfig.getIpAddress(req);
        String vnp_ReturnUrl = req.getScheme() + "://" + req.getServerName() + ":"
                + req.getServerPort() + req.getContextPath() + VNPayConfig.vnp_ReturnUrl;

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", "2.1.0");
        vnp_Params.put("vnp_Command", "pay");
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", txnRef); // ← dùng txnRef đã có
        vnp_Params.put("vnp_OrderInfo", "Thanh toan coc dat sach online");
        vnp_Params.put("vnp_OrderType", "other");
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", vnp_ReturnUrl);
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

        Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
        vnp_Params.put("vnp_CreateDate", formatter.format(cld.getTime()));
        cld.add(Calendar.MINUTE, 15);
        vnp_Params.put("vnp_ExpireDate", formatter.format(cld.getTime()));

        List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        StringBuilder query = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        while (itr.hasNext()) {
            String fieldName = itr.next();
            String fieldValue = vnp_Params.get(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                hashData.append(fieldName).append('=')
                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()))
                        .append('=')
                        .append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                if (itr.hasNext()) {
                    query.append('&');
                    hashData.append('&');
                }
            }
        }

        String secureHash = VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
        String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + query + "&vnp_SecureHash=" + secureHash;
        resp.sendRedirect(paymentUrl);
    }

    private String parseBorrowMethod(String raw) {
        if (raw != null && raw.equalsIgnoreCase(METHOD_IN_PERSON)) {
            return METHOD_IN_PERSON;
        }
        return METHOD_ONLINE;
    }

    private String toMethodLabel(String method) {
        if (METHOD_IN_PERSON.equals(method)) {
            return "tại chỗ";
        }
        return "online";
    }

    private void notifyLibrarians(User currentUser, List<CartItem> items, String method,
            String contactName, String contactPhone, String contactEmail, String returnDateLabel,
            String pickupDateLabel, ShippingDetails shippingDetails) {
        if (items == null || items.isEmpty()) {
            return;
        }
        try {
            List<User> librarians = userDAO.findByRoleName(ROLE_LIBRARIAN);
            if (librarians.isEmpty()) {
                return;
            }
            String emails = librarians.stream()
                    .map(User::getEmail)
                    .filter(Objects::nonNull)
                    .map(String::trim)
                    .filter(email -> !email.isBlank())
                    .distinct()
                    .collect(Collectors.joining(","));
            if (emails.isBlank()) {
                return;
            }
            String displayName = getDisplayName(currentUser);
            String userEmail = currentUser != null && currentUser.getEmail() != null ? currentUser.getEmail()
                    : "chưa cung cấp email";
            String subject = "LBMS - Yêu cầu mượn sách mới từ " + displayName;
            StringBuilder body = new StringBuilder();
            body.append("<h3>Yêu cầu mượn sách mới</h3>");
            body.append("<p>Người dùng ").append(displayName)
                    .append(" (").append(userEmail).append(") vừa gửi yêu cầu mượn sách.</p>");
            body.append("<p>Phương thức: <strong>").append(toMethodLabel(method)).append("</strong></p>");
            body.append("<h4>Thông tin liên hệ</h4>");
            body.append("<ul style=\"padding-left:16px; line-height:1.6;\">");
            body.append("<li><strong>Tên:</strong> ").append(contactName).append("</li>");
            body.append("<li><strong>Điện thoại:</strong> ").append(contactPhone).append("</li>");
            body.append("<li><strong>Email:</strong> ").append(contactEmail).append("</li>");
            body.append("<li><strong>Ngày trả dự kiến:</strong> ").append(returnDateLabel).append("</li>");
            if (pickupDateLabel != null && !pickupDateLabel.isBlank()) {
                body.append("<li><strong>Ngày đến lấy:</strong> ").append(pickupDateLabel).append("</li>");
            }
            if (shippingDetails != null) {
                body.append("<li><strong>Người nhận:</strong> ").append(shippingDetails.getRecipient()).append("</li>");
                body.append("<li><strong>ĐT nhận hàng:</strong> ").append(shippingDetails.getPhone()).append("</li>");
                body.append("<li><strong>Địa chỉ giao:</strong> ").append(shippingDetails.getFormattedAddress())
                        .append("</li>");
            }
            body.append("</ul>");
            body.append("<ul>");
            for (CartItem item : items) {
                body.append("<li>").append(getItemLabel(item)).append("</li>");
            }
            body.append("</ul>");
            body.append("<p>Hệ thống đang chờ thủ thư xử lý yêu cầu.</p>");
            emailService.send(emails, subject, body.toString());
        } catch (Exception ex) {
            System.err.println("Không gửi được thông báo tới thủ thư: " + ex.getMessage());
        }
    }

    private String requireTextParam(HttpServletRequest req, String name, String label) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng cung cấp " + label);
        }
        return value.trim();
    }

    private LocalDate parsePickupDateParam(HttpServletRequest req, String name) {
        String raw = requireTextParam(req, name, "ngày đến lấy sách");
        try {
            LocalDate date = LocalDate.parse(raw);
            if (date.isBefore(LocalDate.now())) {
                throw new IllegalArgumentException("Ngày đến lấy sách phải là hôm nay hoặc sau đó");
            }
            return date;
        } catch (DateTimeParseException ex) {
            throw new IllegalArgumentException("Ngày đến lấy sách không hợp lệ");
        }
    }

    private String getItemLabel(CartItem item) {
        if (item == null) {
            return "Sách chưa xác định";
        }
        String title = item.getBook() != null && item.getBook().getTitle() != null
                ? item.getBook().getTitle()
                : "Sách #" + item.getBookId();
        return title + " (" + item.getQuantity() + " cuốn)";
    }

    private String getDisplayName(User user) {
        if (user == null) {
            return "Người dùng";
        }
        if (user.getFullName() != null && !user.getFullName().isBlank()) {
            return user.getFullName();
        }
        if (user.getEmail() != null && !user.getEmail().isBlank()) {
            return user.getEmail();
        }
        return "Người dùng";
    }

    private long parseLongParam(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Thiếu tham số " + name);
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + name + " không hợp lệ");
        }
    }

    private int parseIntParam(HttpServletRequest req, String name, Integer defaultValue) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            if (defaultValue == null) {
                throw new IllegalArgumentException("Thiếu tham số " + name);
            }
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + name + " không hợp lệ");
        }
    }

    private String normalizePhoneDigits(String raw) {
        if (raw == null) {
            throw new IllegalArgumentException("Số điện thoại người nhận là bắt buộc");
        }
        String digits = raw.replaceAll("[^0-9]", "");
        if (digits.length() < 10 || digits.length() > 11) {
            throw new IllegalArgumentException("Số điện thoại người nhận phải là 10 hoặc 11 chữ số");
        }
        return digits;
    }

    private void redirectWithParam(HttpServletRequest req, HttpServletResponse resp, String path, String paramName,
            String message) throws IOException {
        StringBuilder target = new StringBuilder(req.getContextPath()).append(path);
        if (message != null && !message.isBlank()) {
            target.append("?").append(paramName).append("=")
                    .append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        }
        resp.sendRedirect(target.toString());
    }

    private void handleWalletCheckout(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws Exception {
        String txnRef = req.getParameter("txnRef");
        if (txnRef == null || txnRef.isBlank()) {
            redirectWithParam(req, resp, "/cart", "cartError", "Phiên thanh toán không hợp lệ, vui lòng thử lại.");
            return;
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> checkoutData = (Map<String, Object>) req.getSession()
                .getAttribute("cartCheckout-" + txnRef);
        if (checkoutData == null) {
            redirectWithParam(req, resp, "/cart", "cartError", "Phiên thanh toán đã hết hạn, vui lòng đặt lại.");
            return;
        }

        @SuppressWarnings("unchecked")
        List<CartItem> items = (List<CartItem>) checkoutData.get("items");
        if (items == null || items.isEmpty()) {
            redirectWithParam(req, resp, "/cart", "cartError", "Giỏ hàng trống");
            return;
        }

        // calculate deposit
        BigDecimal totalDeposit = items.stream()
                .map(item -> BigDecimal.valueOf(item.getSubtotal()).multiply(BigDecimal.valueOf(0.5)))
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        // check wallet balance
        User freshUser = walletService.refreshUser(currentUser.getId());
        BigDecimal balance = freshUser.getWalletBalance() != null ? freshUser.getWalletBalance() : BigDecimal.ZERO;
        if (balance.compareTo(totalDeposit) < 0) {
            String msg = "Số dư ví không đủ (" + formatVnd(balance) + "). Cần đặt cọc " + formatVnd(totalDeposit)
                    + ". Vui lòng nạp thêm vào ví hoặc chọn thanh toán VNPay.";
            req.getSession().setAttribute("checkoutError", msg);
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        String method = (String) checkoutData.get("method");
        String contactName = (String) checkoutData.get("contactName");
        String contactPhone = (String) checkoutData.get("contactPhone");
        String contactEmail = (String) checkoutData.get("contactEmail");
        String formattedReturnDate = (String) checkoutData.get("formattedReturnDate");
        String formattedPickupDate = (String) checkoutData.get("formattedPickupDate");
        ShippingDetails shippingDetails = (ShippingDetails) checkoutData.get("shippingDetails");
        @SuppressWarnings("unchecked")
        List<BigDecimal> depositAmounts = (List<BigDecimal>) checkoutData.get("depositAmounts");

        // recalculate per-item deposits if missing
        if (depositAmounts == null
                || depositAmounts.stream().allMatch(d -> d == null || d.compareTo(BigDecimal.ZERO) == 0)) {
            BookDAO bookDAO = new BookDAO();
            depositAmounts = new ArrayList<>();
            for (CartItem item : items) {
                Book book = bookDAO.findById(item.getBookId());
                BigDecimal price = (book != null && book.getPrice() != null)
                        ? BigDecimal.valueOf(book.getPrice())
                        : BigDecimal.ZERO;
                depositAmounts.add(price.multiply(BigDecimal.valueOf(item.getQuantity()))
                        .multiply(BigDecimal.valueOf(0.5)));
            }
        }

        // debit wallet
        String ref = "WALLET-CART-" + currentUser.getId() + "-" + System.currentTimeMillis();
        walletService.debitWallet(currentUser.getId(), totalDeposit, "Coc dat sach online", ref);

        // create borrow requests
        for (int i = 0; i < items.size(); i++) {
            CartItem item = items.get(i);
            String groupCode = "REQ-" + System.currentTimeMillis() + "-" + currentUser.getId();
            BigDecimal deposit = (i < depositAmounts.size() && depositAmounts.get(i) != null)
                    ? depositAmounts.get(i)
                    : BigDecimal.ZERO;
            borrowService.requestBorrowCopies(currentUser.getId(), item.getBookId(), method,
                    shippingDetails, item.getQuantity(), groupCode, deposit);
        }

        cartService.clearCart(currentUser.getId());
        notifyLibrarians(currentUser, items, method, contactName, contactPhone, contactEmail,
                formattedReturnDate, formattedPickupDate, shippingDetails);

        // record payment history
        try {
            PaymentHistory ph = new PaymentHistory();
            ph.setUserId(currentUser.getId());
            ph.setPaymentMethod(PaymentHistory.METHOD_WALLET);
            ph.setPaymentType(PaymentHistory.TYPE_BOOK_DEPOSIT);
            ph.setAmount(totalDeposit);
            ph.setDescription("CọC ĐẶT SÁCH ONLINE - Ví");
            ph.setReference(ref);
            ph.setStatus(PaymentHistory.STATUS_SUCCESS);
            paymentHistoryDAO.save(ph);
        } catch (Exception e) {
            System.err.println("[CartController] recordPayment error: " + e.getMessage());
        }

        req.getSession().removeAttribute("cartCheckout-" + txnRef);
        User updated = walletService.refreshUser(currentUser.getId());
        req.getSession().setAttribute("currentUser", updated);

        req.getSession().setAttribute("paymentResult_status", "success");
        req.getSession().setAttribute("paymentResult_message",
                "Thanh toán cọc " + formatVnd(totalDeposit)
                        + " bằng ví thành công! Yêu cầu đặt sách đã được gửi đến thủ thư.");
        req.getSession().setAttribute("paymentResult_amount", totalDeposit);
        req.getSession().setAttribute("paymentResult_method", "WALLET");
        req.getSession().setAttribute("paymentResult_backUrl", "/cart");
        req.getSession().setAttribute("paymentResult_backLabel", "Quay lại giỏ hàng");
        resp.sendRedirect(req.getContextPath() + "/payment-result");
    }

    private String formatVnd(BigDecimal amount) {
        java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(java.util.Locale.of("vi", "VN"));
        fmt.setMaximumFractionDigits(0);
        return fmt.format(amount) + " ₫";
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }
}
