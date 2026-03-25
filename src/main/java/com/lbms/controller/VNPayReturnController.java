package com.lbms.controller;

import com.lbms.dao.BookDAO;
import com.lbms.dao.BorrowDAO;
import com.lbms.dao.PaymentHistoryDAO;
import com.lbms.model.Book;
import com.lbms.model.BorrowRecord;
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

@WebServlet(urlPatterns = {"/vnpay-return"})
public class VNPayReturnController extends HttpServlet {

    private BorrowService borrowService;
    private static final String MODE_RETURN = "return";
    private static final String MODE_FINE = "fine";
    private WalletService walletService;
    private ProfileService profileService;
    private PaymentHistoryDAO paymentHistoryDAO;
    private BorrowDAO borrowDAO;

    @Override
    public void init() {
        this.borrowService = new BorrowService();
        this.walletService = new WalletService();
        this.profileService = new ProfileService();
        this.paymentHistoryDAO = new PaymentHistoryDAO();
        this.borrowDAO = new BorrowDAO();
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
            if (fields.containsKey("vnp_SecureHashType")) fields.remove("vnp_SecureHashType");
            if (fields.containsKey("vnp_SecureHash")) fields.remove("vnp_SecureHash");

            String signValue = hashAllFields(fields);
            String vnp_TxnRef = req.getParameter("vnp_TxnRef");
            
            long borrowId = -1;
            String mode = MODE_RETURN;
            if (vnp_TxnRef != null && !vnp_TxnRef.isEmpty()) {
                String[] parts = vnp_TxnRef.split("_");
                if (parts.length > 0) {
                    try { borrowId = Long.parseLong(parts[0]); } catch (Exception ignored) {}
                }
                if (parts.length > 1) mode = parts[1];
            }

            boolean isWalletTxn = vnp_TxnRef != null && vnp_TxnRef.startsWith(WalletService.TXN_REF_PREFIX);

            if (signValue.equals(vnp_SecureHash)) {
                if ("00".equals(req.getParameter("vnp_ResponseCode"))) {
                    if (isWalletTxn) {
                        handleWalletTopUpSuccess(req, resp, vnp_TxnRef, currentUser);
                        return;
                    }

                    if (vnp_TxnRef != null && vnp_TxnRef.startsWith("CART-")) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> checkoutData = (Map<String, Object>) req.getSession().getAttribute("cartCheckout-" + vnp_TxnRef);
                        
                        if (checkoutData != null) {
                            String method = (String) checkoutData.get("method");
                            String contactName = (String) checkoutData.get("contactName");
                            String contactPhone = (String) checkoutData.get("contactPhone");
                            String contactEmail = (String) checkoutData.get("contactEmail");
                            String formattedReturnDate = (String) checkoutData.get("formattedReturnDate");
                            ShippingDetails shippingDetails = (ShippingDetails) checkoutData.get("shippingDetails");
                            @SuppressWarnings("unchecked")
                            List<CartItem> items = (List<CartItem>) checkoutData.get("items");
                            @SuppressWarnings("unchecked")
                            List<BigDecimal> depositAmounts = (List<BigDecimal>) checkoutData.get("depositAmounts");

                            // --- CỐ ĐỊNH GROUP CODE TẠI ĐÂY ---
                            // Tạo MỘT lần duy nhất cho toàn bộ các cuốn sách trong đơn hàng
                            String finalGroupCode = "REQ-" + vnp_TxnRef;

                            for (int i = 0; i < items.size(); i++) {
                                CartItem item = items.get(i);
                                BigDecimal depositAmount = (depositAmounts != null && i < depositAmounts.size()) 
                                                           ? depositAmounts.get(i) : BigDecimal.ZERO;

                                // Gọi service lưu từng cuốn nhưng chung finalGroupCode
                                borrowService.requestBorrowCopies(
                                        currentUser.getId(),
                                        item.getBookId(),
                                        method,
                                        shippingDetails,
                                        item.getQuantity(),
                                        finalGroupCode, 
                                        depositAmount
                                );
                            }

                            // Dọn dẹp giỏ hàng
                            new CartService().clearCart(currentUser.getId());
                            notifyLibrarians(currentUser, items, method, contactName, contactPhone, contactEmail, formattedReturnDate, shippingDetails);
                            req.getSession().removeAttribute("cartCheckout-" + vnp_TxnRef);

                            // Lưu lịch sử thanh toán
                            recordOrderPayment(currentUser.getId(), items, vnp_TxnRef);

                            BigDecimal paidAmount = getVnpayAmount(req);
                            req.getSession().setAttribute("paymentResult_status", "success");
                            req.getSession().setAttribute("paymentResult_message", "Thanh toán cọc thành công! Đơn hàng đã được gửi.");
                            req.getSession().setAttribute("paymentResult_amount", paidAmount);
                            req.getSession().setAttribute("paymentResult_method", "VNPAY");
                            req.getSession().setAttribute("paymentResult_backUrl", "/history");
                            req.getSession().setAttribute("paymentResult_backLabel", "Xem lịch sử mượn");
                            resp.sendRedirect(req.getContextPath() + "/payment-result");
                        }
                    } else if (borrowId > 0) {
                        // Xử lý thanh toán phạt hoặc trả sách lẻ
                        handleSingleBorrowPayment(req, resp, currentUser, borrowId, mode, vnp_TxnRef);
                    }
                } else {
                    handlePaymentFailure(req, resp, vnp_TxnRef, isWalletTxn, borrowId, mode);
                }
            } else {
                req.getSession().setAttribute("flash", "Chữ ký thanh toán không hợp lệ!");
                resp.sendRedirect(req.getContextPath() + "/history");
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void notifyLibrarians(User user, List<CartItem> items, String method, String name, String phone, String email, String date, ShippingDetails sd) {
        try {
            UserDAO userDAO = new UserDAO();
            List<User> librarians = userDAO.findByRoleName("LIBRARIAN");
            String emails = librarians.stream().map(User::getEmail).filter(Objects::nonNull).collect(Collectors.joining(","));
            if (emails.isBlank()) return;

            String subject = "LBMS - Đơn mượn Online mới từ " + user.getFullName();
            StringBuilder body = new StringBuilder("<h3>Có đơn mượn mới</h3>");
            body.append("<p>Người mượn: ").append(user.getFullName()).append("</p>");
            body.append("<ul>");
            for (CartItem item : items) {
                body.append("<li>").append(item.getBook().getTitle()).append(" (SL: ").append(item.getQuantity()).append(")</li>");
            }
            body.append("</ul>");
            new EmailService().send(emails, subject, body.toString());
        } catch (Exception ignored) {}
    }

    private void recordOrderPayment(long userId, List<CartItem> items, String ref) {
        try {
            BigDecimal totalDeposit = items.stream()
                    .map(item -> BigDecimal.valueOf(item.getSubtotal()).multiply(new BigDecimal("0.5")))
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            PaymentHistory ph = new PaymentHistory();
            ph.setUserId(userId);
            ph.setPaymentMethod(PaymentHistory.METHOD_VNPAY);
            ph.setPaymentType(PaymentHistory.TYPE_BOOK_DEPOSIT);
            ph.setAmount(totalDeposit);
            ph.setDescription("Cọc đơn hàng Online: " + ref);
            ph.setReference(ref);
            ph.setStatus(PaymentHistory.STATUS_SUCCESS);
            paymentHistoryDAO.save(ph);
        } catch (Exception e) {
            System.err.println("Lỗi ghi lịch sử thanh toán: " + e.getMessage());
        }
    }

    private void handleSingleBorrowPayment(HttpServletRequest req, HttpServletResponse resp, User user, long borrowId, String mode, String vnp_TxnRef) throws Exception {
        if (MODE_FINE.equals(mode)) {
            borrowService.markFinePaid(borrowId);
            recordVnpayPayment(user.getId(), PaymentHistory.TYPE_FINE, getVnpayAmount(req), "Phí phạt #" + borrowId, vnp_TxnRef, borrowId);
            req.getSession().setAttribute("flash", "Thanh toán phí phạt thành công!");
            resp.sendRedirect(req.getContextPath() + "/fines");
        } else {
            BorrowRecord br = borrowDAO.findById(borrowId);
            borrowService.returnBook(borrowId);
            recordVnpayPayment(user.getId(), PaymentHistory.TYPE_BOOK_RETURN, getVnpayAmount(req), "Trả sách #" + borrowId, vnp_TxnRef, borrowId);
            req.getSession().setAttribute("flash", "Trả sách thành công!" + buildDepositRefundNote(br));
            resp.sendRedirect(req.getContextPath() + "/history");
        }
    }

    private void handlePaymentFailure(HttpServletRequest req, HttpServletResponse resp, String vnp_TxnRef, boolean isWallet, long borrowId, String mode) throws IOException {
        String redirect = req.getContextPath() + "/history";
        if (isWallet) redirect = req.getContextPath() + "/wallet";
        else if (vnp_TxnRef != null && vnp_TxnRef.startsWith("CART-")) {
            req.getSession().setAttribute("paymentResult_status", "failed");
            req.getSession().setAttribute("paymentResult_message", "Thanh toán thất bại.");
            resp.sendRedirect(req.getContextPath() + "/payment-result");
            return;
        }
        req.getSession().setAttribute("flash", "Thanh toán thất bại.");
        resp.sendRedirect(redirect);
    }

    private void recordVnpayPayment(long userId, String type, BigDecimal amount, String description, String reference, long borrowId) {
        try {
            PaymentHistory ph = new PaymentHistory();
            ph.setUserId(userId);
            ph.setPaymentMethod(PaymentHistory.METHOD_VNPAY);
            ph.setPaymentType(type);
            ph.setAmount(amount);
            ph.setDescription(description);
            ph.setReference(reference);
            ph.setStatus(PaymentHistory.STATUS_SUCCESS);
            if (borrowId > 0) ph.setBorrowId(borrowId);
            paymentHistoryDAO.save(ph);
        } catch (Exception ignored) {}
    }

    private BigDecimal getVnpayAmount(HttpServletRequest req) {
        try {
            String vnpAmount = req.getParameter("vnp_Amount");
            if (vnpAmount != null) return new BigDecimal(vnpAmount).divide(BigDecimal.valueOf(100));
        } catch (Exception ignored) {}
        return BigDecimal.ZERO;
    }

    private void handleWalletTopUpSuccess(HttpServletRequest req, HttpServletResponse resp, String txnRef, User currentUser) throws Exception {
        HttpSession session = req.getSession();
        @SuppressWarnings("unchecked")
        Map<String, Object> topUpData = (Map<String, Object>) session.getAttribute(WalletService.SESSION_KEY_PREFIX + txnRef);
        BigDecimal amount = getVnpayAmount(req);
        session.removeAttribute(WalletService.SESSION_KEY_PREFIX + txnRef);

        if (amount.compareTo(BigDecimal.ZERO) > 0) {
            walletService.creditWallet(currentUser.getId(), amount, "VNPay", "Nạp tiền ví", txnRef);
        }
        session.setAttribute("currentUser", profileService.refreshUser(currentUser.getId()));
        session.setAttribute("flash", "Nạp tiền vào ví thành công.");
        resp.sendRedirect(req.getContextPath() + "/wallet");
    }

    private String buildDepositRefundNote(BorrowRecord br) {
        if (br == null || br.getDepositAmount() == null) return "";
        BigDecimal refund = br.getDepositAmount().multiply(new BigDecimal("0.5"));
        return " Đã hoàn 50% tiền cọc (" + formatCurrency(refund) + ") vào ví.";
    }

    private String formatCurrency(BigDecimal amount) {
        return NumberFormat.getCurrencyInstance(Locale.forLanguageTag("vi-VN")).format(amount);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }

    private String hashAllFields(Map<String, String> fields) {
        List<String> fieldNames = new ArrayList<>(fields.keySet());
        Collections.sort(fieldNames);
        StringBuilder hashData = new StringBuilder();
        Iterator<String> itr = fieldNames.iterator();
        try {
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = fields.get(fieldName);
                if (fieldValue != null && !fieldValue.isEmpty()) {
                    hashData.append(fieldName).append('=').append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) hashData.append('&');
                }
            }
            return VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
        } catch (Exception ex) { return ""; }
    }
}