package com.lbms.controller;

import com.lbms.config.VNPayConfig;
import com.lbms.model.User;
import com.lbms.service.BorrowService;

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

    private BorrowService borrowService;

    @Override
    public void init() {
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
                    String vnp_TxnRef = req.getParameter("vnp_TxnRef");
                    if (vnp_TxnRef != null && vnp_TxnRef.contains("_")) {
                        long borrowId = Long.parseLong(vnp_TxnRef.split("_")[0]);
                        borrowService.returnBook(borrowId);
                        req.getSession().setAttribute("flash", "Thanh toán thành công & Trả sách thành công!");
                    } else {
                        req.getSession().setAttribute("flash",
                                "Thanh toán thành công nhưng không tìm thấy thông tin phiếu mượn.");
                    }
                    resp.sendRedirect(req.getContextPath() + "/history");
                } else {
                    // Payment failed
                    String vnp_TxnRef = req.getParameter("vnp_TxnRef");
                    String borrowIdPart = "";
                    if (vnp_TxnRef != null && vnp_TxnRef.contains("_")) {
                        borrowIdPart = "?borrowId=" + vnp_TxnRef.split("_")[0];
                    }
                    req.getSession().setAttribute("flash", "Thanh toán thất bại! (Mã lỗi: "
                            + req.getParameter("vnp_ResponseCode") + "). Vui lòng thử lại.");
                    resp.sendRedirect(req.getContextPath() + "/checkout" + borrowIdPart);
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
