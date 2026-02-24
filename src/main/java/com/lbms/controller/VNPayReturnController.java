package com.lbms.controller;

import com.lbms.config.VNPayConfig;
import com.lbms.model.Cart;
import com.lbms.model.CartItem;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.service.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

@WebServlet(urlPatterns = { "/vnpay-return" })
public class VNPayReturnController extends HttpServlet {

    private CartService cartService;
    private BorrowService borrowService;

    @Override
    public void init() {
        this.cartService = new CartService();
        this.borrowService = new BorrowService();
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

            if (signValue.equals(vnp_SecureHash)) {
                if ("00".equals(req.getParameter("vnp_ResponseCode"))) {
                    // Payment success
                    Cart cart = cartService.getCart(currentUser.getId());
                    if (cart != null && cart.getItems() != null && !cart.getItems().isEmpty()) {
                        int successCount = 0;
                        for (CartItem item : cart.getItems()) {
                            for (int i = 0; i < item.getQuantity(); i++) {
                                borrowService.requestBorrow(currentUser.getId(), item.getBook().getId());
                                successCount++;
                            }
                        }
                        cartService.clearCart(currentUser.getId());
                        req.getSession().setAttribute("flash", "Thanh toán thành công / Payment successful! Đã gửi "
                                + successCount + " yêu cầu mượn sách.");
                    } else {
                        req.getSession().setAttribute("flash",
                                "Thanh toán thành công nhưng không tìm thấy sách trong giỏ / Payment successful but cart is empty.");
                    }
                    resp.sendRedirect(req.getContextPath() + "/borrow");
                } else {
                    // Payment failed
                    req.getSession().setAttribute("flash", "Thanh toán thất bại / Payment failed! (Mã lỗi/Error code: "
                            + req.getParameter("vnp_ResponseCode") + "). Vui lòng thử lại / Please try again.");
                    resp.sendRedirect(req.getContextPath() + "/checkout");
                }
            } else {
                // Invalid signature
                req.getSession().setAttribute("flash",
                        "Chữ ký không hợp lệ / Invalid signature! Vui lòng không thực hiện hành vi giả mạo / Stop fake request.");
                resp.sendRedirect(req.getContextPath() + "/checkout");
            }

        } catch (Exception ex) {
            throw new ServletException(ex);
        }
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
