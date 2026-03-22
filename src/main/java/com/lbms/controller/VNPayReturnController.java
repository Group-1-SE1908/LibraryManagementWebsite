package com.lbms.controller;

import com.lbms.dao.BookDAO;
import com.lbms.dao.PaymentHistoryDAO;
import com.lbms.model.Book;
import java.util.ArrayList;
import com.lbms.config.VNPayConfig;
import com.lbms.dao.UserDAO;
import com.lbms.model.PaymentHistory;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.model.CartItem;
import com.lbms.model.ShippingDetails;

import com.lbms.service.CartService;
import com.lbms.service.EmailService;
import com.lbms.service.ProfileService;
import com.lbms.service.WalletService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;
import java.math.BigDecimal;
import java.text.NumberFormat;
import java.util.Locale;

@WebServlet(urlPatterns = { "/vnpay-return" })
public class VNPayReturnController extends HttpServlet {

    private BorrowService borrowService;
    private static final String MODE_RETURN = "return";
    private static final String MODE_FINE = "fine";
    private WalletService walletService;
    private ProfileService profileService;
    private PaymentHistoryDAO paymentHistoryDAO;

    @Override
    public void init() {
        this.borrowService = new BorrowService();
        this.walletService = new WalletService();
        this.profileService = new ProfileService();
        this.paymentHistoryDAO = new PaymentHistoryDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Map<String, String> fields = new HashMap<>();
            for (Enumeration<String> params = req.getParameterNames(); params.hasMoreElements();) {
                String fieldName = params.nextElement();
                String fieldValue = req.getParameter(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    fields.put(fieldName, fieldValue);
                }
            }

            String vnp_SecureHash = req.getParameter("vnp_SecureHash");
            if (fields.containsKey("vnp_SecureHashType")) {
                fields.remove("vnp_SecureHashType");
            }
            if (fields.containsKey("vnp_SecureHash")) {
                fields.remove("vnp_SecureHash");
            }

            // Check signature
            String signValue = hashAllFields(fields);
            String vnp_TxnRef = req.getParameter("vnp_TxnRef");
            long borrowId = -1;
            String mode = MODE_RETURN;
            if (vnp_TxnRef != null && !vnp_TxnRef.isEmpty()) {
                String[] parts = vnp_TxnRef.split("_");
                if (parts.length > 0 && parts[0] != null && !parts[0].isEmpty()) {
                    try {
                        borrowId = Long.parseLong(parts[0]);
                    } catch (NumberFormatException ignored) {
                        borrowId = -1;
                    }
                }
                if (parts.length > 1 && parts[1] != null && !parts[1].isEmpty()) {
                    mode = parts[1];
                }
            }

            boolean isWalletTxn = vnp_TxnRef != null && vnp_TxnRef.startsWith(WalletService.TXN_REF_PREFIX);

            if (signValue.equals(vnp_SecureHash)) {
                if ("00".equals(req.getParameter("vnp_ResponseCode"))) {
                    if (isWalletTxn) {
                        handleWalletTopUpSuccess(req, resp, vnp_TxnRef, currentUser);
                        return;
                    }
                    if (vnp_TxnRef.startsWith("CART-")) {
                        // Xử lý đặt sách online
                        @SuppressWarnings("unchecked")
                        Map<String, Object> checkoutData = (Map<String, Object>) req.getSession()
                                .getAttribute("cartCheckout-" + vnp_TxnRef);
                        if (checkoutData != null) {
                            // Thực hiện borrow như trong CartController
                            String method = (String) checkoutData.get("method");
                            String contactName = (String) checkoutData.get("contactName");
                            String contactPhone = (String) checkoutData.get("contactPhone");
                            String contactEmail = (String) checkoutData.get("contactEmail");
                            String formattedReturnDate = (String) checkoutData.get("formattedReturnDate");
                            ShippingDetails shippingDetails = (ShippingDetails) checkoutData.get("shippingDetails");
                            @SuppressWarnings("unchecked")
                            List<CartItem> items = (List<CartItem>) checkoutData.get("items");

                            // Gửi request
                            @SuppressWarnings("unchecked")
                            List<BigDecimal> depositAmounts = (List<BigDecimal>) checkoutData.get("depositAmounts");

                            // Nếu null hoặc toàn 0 → tính lại từ DB
                            if (depositAmounts == null || depositAmounts.stream()
                                    .allMatch(d -> d == null || d.compareTo(BigDecimal.ZERO) == 0)) {
                                BookDAO bookDAO = new BookDAO();
                                depositAmounts = new ArrayList<>();
                                for (CartItem item : items) {
                                    Book book = bookDAO.findById(item.getBookId());
                                    BigDecimal price = (book != null && book.getPrice() != null)
                                            ? BigDecimal.valueOf(book.getPrice())
                                            : BigDecimal.ZERO;
                                    BigDecimal deposit = price
                                            .multiply(BigDecimal.valueOf(item.getQuantity()))
                                            .multiply(BigDecimal.valueOf(0.5));
                                    depositAmounts.add(deposit);
                                }
                            }

                            for (int i = 0; i < items.size(); i++) {
                                CartItem item = items.get(i);
                                String groupCode = "REQ-" + System.currentTimeMillis() + "-" + currentUser.getId();
                                BigDecimal depositAmount = (i < depositAmounts.size() && depositAmounts.get(i) != null)
                                        ? depositAmounts.get(i)
                                        : BigDecimal.ZERO;
                                borrowService.requestBorrowCopies(
                                        currentUser.getId(),
                                        item.getBookId(),
                                        method,
                                        shippingDetails,
                                        item.getQuantity(),
                                        groupCode,
                                        depositAmount);
                            }
                            // Clear cart
                            new CartService().clearCart(currentUser.getId());

                            // Notify librarians
                            try {
                                UserDAO userDAO = new UserDAO();
                                List<User> librarians = userDAO.findByRoleName("LIBRARIAN");
                                if (!librarians.isEmpty()) {
                                    String emails = librarians.stream()
                                            .map(User::getEmail)
                                            .filter(Objects::nonNull)
                                            .map(String::trim)
                                            .filter(email -> !email.isBlank())
                                            .distinct()
                                            .collect(Collectors.joining(","));
                                    if (!emails.isBlank()) {
                                        String displayName = currentUser.getFullName() != null
                                                ? currentUser.getFullName()
                                                : "Người dùng";
                                        String userEmail = currentUser.getEmail() != null ? currentUser.getEmail()
                                                : "chưa cung cấp";
                                        String subject = "LBMS - Yêu cầu mượn sách mới từ " + displayName;
                                        StringBuilder body = new StringBuilder();
                                        body.append("<h3>Yêu cầu mượn sách mới</h3>");
                                        body.append("<p>Người dùng ").append(displayName)
                                                .append(" (").append(userEmail)
                                                .append(") vừa gửi yêu cầu mượn sách.</p>");
                                        body.append("<p>Phương thức: <strong>online</strong></p>");
                                        body.append("<h4>Thông tin liên hệ</h4>");
                                        body.append("<ul style=\"padding-left:16px; line-height:1.6;\">");
                                        body.append("<li><strong>Tên:</strong> ").append(contactName).append("</li>");
                                        body.append("<li><strong>Điện thoại:</strong> ").append(contactPhone)
                                                .append("</li>");
                                        body.append("<li><strong>Email:</strong> ").append(contactEmail)
                                                .append("</li>");
                                        body.append("</ul>");
                                        body.append("<h4>Chi tiết sách</h4>");
                                        body.append("<ul style=\"padding-left:16px; line-height:1.6;\">");
                                        for (CartItem item : items) {
                                            body.append("<li>").append(item.getBook().getTitle()).append(" (")
                                                    .append(item.getQuantity()).append(" cuốn)</li>");
                                        }
                                        body.append("</ul>");
                                        body.append("<p>Ngày trả dự kiến: ").append(formattedReturnDate).append("</p>");
                                        if (shippingDetails != null) {
                                            body.append("<p>Người nhận: ").append(shippingDetails.getRecipient())
                                                    .append("</p>");
                                            body.append("<p>Điện thoại người nhận: ").append(shippingDetails.getPhone())
                                                    .append("</p>");
                                            body.append("<p>Địa chỉ giao: ")
                                                    .append(shippingDetails.getFormattedAddress()).append("</p>");
                                        }
                                        body.append("<p>Vui lòng kiểm tra và xử lý yêu cầu.</p>");
                                        new EmailService().send(emails, subject, body.toString());
                                    }
                                }
                            } catch (Exception e) {
                                // Ignore email error
                            }

                            // Remove session data
                            req.getSession().removeAttribute("cartCheckout-" + vnp_TxnRef);

                            // record payment history
                            try {
                                BigDecimal totalDeposit = items.stream()
                                        .map(item -> BigDecimal.valueOf(item.getSubtotal())
                                                .multiply(BigDecimal.valueOf(0.5)))
                                        .reduce(BigDecimal.ZERO, BigDecimal::add);
                                PaymentHistory ph = new PaymentHistory();
                                ph.setUserId(currentUser.getId());
                                ph.setPaymentMethod(PaymentHistory.METHOD_VNPAY);
                                ph.setPaymentType(PaymentHistory.TYPE_BOOK_DEPOSIT);
                                ph.setAmount(totalDeposit);
                                ph.setDescription("CọC ĐẶT SÁCH ONLINE - VNPay");
                                ph.setReference(vnp_TxnRef);
                                ph.setStatus(PaymentHistory.STATUS_SUCCESS);
                                paymentHistoryDAO.save(ph);
                            } catch (Exception e) {
                                System.err.println("[VNPayReturn] recordPayment error: " + e.getMessage());
                            }

                            BigDecimal paidAmount = getVnpayAmount(req);
                            req.getSession().setAttribute("paymentResult_status", "success");
                            req.getSession().setAttribute("paymentResult_message",
                                    "Thanh toán cọc thành công! Yêu cầu đặt sách đã được gửi đến thủ thư.");
                            req.getSession().setAttribute("paymentResult_amount", paidAmount);
                            req.getSession().setAttribute("paymentResult_method", "VNPAY");
                            req.getSession().setAttribute("paymentResult_backUrl", "/cart");
                            req.getSession().setAttribute("paymentResult_backLabel", "Quay lại giỏ hàng");
                            resp.sendRedirect(req.getContextPath() + "/payment-result");
                        } else {
                            req.getSession().setAttribute("paymentResult_status", "success");
                            req.getSession().setAttribute("paymentResult_message",
                                    "Thanh toán thành công nhưng không tìm thấy thông tin đặt sách.");
                            req.getSession().setAttribute("paymentResult_method", "VNPAY");
                            req.getSession().setAttribute("paymentResult_backUrl", "/cart");
                            req.getSession().setAttribute("paymentResult_backLabel", "Quay lại giỏ hàng");
                            resp.sendRedirect(req.getContextPath() + "/payment-result");
                        }
                    } else if (borrowId > 0) {
                        if (MODE_FINE.equals(mode)) {
                            borrowService.markFinePaid(borrowId);
                            recordVnpayPayment(currentUser.getId(), PaymentHistory.TYPE_FINE,
                                    getVnpayAmount(req), "Thanh toán phí phạt phiếu #" + borrowId,
                                    vnp_TxnRef, borrowId);
                            req.getSession().setAttribute("flash", "Thanh toán phí phạt thành công!");
                            req.getSession().setAttribute("flashType", "success");
                            resp.sendRedirect(req.getContextPath() + "/fines");
                        } else {
                            borrowService.returnBook(borrowId);
                            borrowService.markFinePaid(borrowId);
                            recordVnpayPayment(currentUser.getId(), PaymentHistory.TYPE_BOOK_RETURN,
                                    getVnpayAmount(req), "Trả sách & thanh toán phiếu #" + borrowId,
                                    vnp_TxnRef, borrowId);
                            req.getSession().setAttribute("flash", "Thanh toán thành công & Trả sách thành công!");
                            req.getSession().setAttribute("flashType", "success");
                            resp.sendRedirect(req.getContextPath() + "/history");
                        }
                    } else {
                        req.getSession().setAttribute("flash",
                                "Thanh toán thành công nhưng không tìm thấy thông tin phiếu mượn.");
                        resp.sendRedirect(req.getContextPath() + "/history");
                    }
                } else {
                    // Payment failed
                    String redirect;
                    if (isWalletTxn) {
                        redirect = req.getContextPath() + "/wallet";
                        req.getSession().removeAttribute(WalletService.SESSION_KEY_PREFIX + vnp_TxnRef);
                    } else if (vnp_TxnRef != null && vnp_TxnRef.startsWith("CART-")) {
                        req.getSession().setAttribute("paymentResult_status", "failed");
                        req.getSession().setAttribute("paymentResult_message",
                                "Thanh toán thất bại! (Mã lỗi: " + req.getParameter("vnp_ResponseCode")
                                        + "). Vui lòng thử lại.");
                        req.getSession().setAttribute("paymentResult_method", "VNPAY");
                        req.getSession().setAttribute("paymentResult_backUrl", "/cart");
                        req.getSession().setAttribute("paymentResult_backLabel", "Thử lại");
                        resp.sendRedirect(req.getContextPath() + "/payment-result");
                        return;
                    } else {
                        redirect = req.getContextPath() + "/checkout";
                        if (borrowId > 0) {
                            redirect += "?borrowId=" + borrowId;
                            if (MODE_FINE.equals(mode)) {
                                redirect += "&mode=fine";
                            }
                        }
                    }
                    req.getSession().setAttribute("flash", "Thanh toán thất bại! (Mã lỗi: "
                            + req.getParameter("vnp_ResponseCode") + "). Vui lòng thử lại.");
                    req.getSession().setAttribute("flashType", "error");
                    resp.sendRedirect(redirect);
                }
            } else {
                // Invalid signature
                req.getSession().setAttribute("flash", "Chữ ký không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/history");
            }

        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void recordVnpayPayment(long userId, String type, BigDecimal amount, String description,
            String reference, long borrowId) {
        try {
            PaymentHistory ph = new PaymentHistory();
            ph.setUserId(userId);
            ph.setPaymentMethod(PaymentHistory.METHOD_VNPAY);
            ph.setPaymentType(type);
            ph.setAmount(amount != null ? amount : BigDecimal.ZERO);
            ph.setDescription(description);
            ph.setReference(reference);
            ph.setStatus(PaymentHistory.STATUS_SUCCESS);
            if (borrowId > 0)
                ph.setBorrowId(borrowId);
            paymentHistoryDAO.save(ph);
        } catch (Exception e) {
            System.err.println("[VNPayReturn] recordVnpayPayment error: " + e.getMessage());
        }
    }

    private BigDecimal getVnpayAmount(HttpServletRequest req) {
        try {
            String vnpAmount = req.getParameter("vnp_Amount");
            if (vnpAmount != null && !vnpAmount.isBlank()) {
                return new BigDecimal(vnpAmount).divide(BigDecimal.valueOf(100));
            }
        } catch (Exception ignored) {
        }
        return BigDecimal.ZERO;
    }

    private void handleWalletTopUpSuccess(HttpServletRequest req, HttpServletResponse resp, String txnRef,
            User currentUser) throws Exception {

        HttpSession session = req.getSession();
        @SuppressWarnings("unchecked")
        Map<String, Object> topUpData = (Map<String, Object>) session
                .getAttribute(WalletService.SESSION_KEY_PREFIX + txnRef);
        BigDecimal amount = null;
        if (topUpData != null) {
            Object storedAmount = topUpData.get("amount");
            if (storedAmount instanceof BigDecimal) {
                amount = (BigDecimal) storedAmount;
            } else if (storedAmount instanceof Number) {
                amount = BigDecimal.valueOf(((Number) storedAmount).doubleValue());
            }
        }
        session.removeAttribute(WalletService.SESSION_KEY_PREFIX + txnRef);

        if (amount == null) {
            String paramAmount = req.getParameter("vnp_Amount");
            if (paramAmount != null && !paramAmount.isBlank()) {
                amount = new BigDecimal(paramAmount).divide(BigDecimal.valueOf(100));
            }
        }

        if (amount == null) {
            amount = BigDecimal.ZERO;
        }

        if (amount.compareTo(BigDecimal.ZERO) > 0) {
            String source = "VNPay Sandbox";
            String storedLabel = null;
            if (topUpData != null) {
                Object labelValue = topUpData.get("label");
                if (labelValue instanceof String) {
                    storedLabel = (String) labelValue;
                }
            }
            String description = storedLabel != null ? storedLabel : formatCurrency(amount);
            walletService.creditWallet(currentUser.getId(), amount, source, description, txnRef);
        }
        User refreshed = profileService.refreshUser(currentUser.getId());
        session.setAttribute("currentUser", refreshed);
        String message = amount.compareTo(BigDecimal.ZERO) > 0
                ? "Nạp " + formatCurrency(amount) + " vào ví thành công."
                : "Nạp tiền vào ví thành công.";
        session.setAttribute("flash", message);
        session.setAttribute("flashType", "success");
        resp.sendRedirect(req.getContextPath() + "/wallet");
    }

    private String formatCurrency(BigDecimal amount) {
        NumberFormat formatter = NumberFormat.getCurrencyInstance(Locale.forLanguageTag("vi-VN"));
        return formatter.format(amount);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }

    private String hashAllFields(Map<String, String> fields) {
        // Build hash data
        java.util.List<String> fieldNames = new java.util.ArrayList<>(fields.keySet());
        java.util.Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        java.util.Iterator<String> itr = fieldNames.iterator();
        try {
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = fields.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        hashData.append('&');
                    }
                }
            }
            return VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
        } catch (Exception ex) {
            return "";
        }
    }
}
