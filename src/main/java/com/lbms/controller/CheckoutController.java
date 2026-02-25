package com.lbms.controller;

import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.config.VNPayConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

@WebServlet(urlPatterns = { "/checkout", "/checkout/process" })
public class CheckoutController extends HttpServlet {
    private BorrowService borrowService;
    private com.lbms.dao.BorrowDAO borrowDAO;

    @Override
    public void init() {
        this.borrowService = new BorrowService();
        this.borrowDAO = new com.lbms.dao.BorrowDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String borrowIdStr = req.getParameter("borrowId");
        if (borrowIdStr == null || borrowIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        try {
            long borrowId = Long.parseLong(borrowIdStr);
            BorrowRecord br = borrowDAO.findById(borrowId);
            if (br == null || br.getUser().getId() != currentUser.getId()) {
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            if (!"BORROWED".equalsIgnoreCase(br.getStatus())) {
                req.getSession().setAttribute("flash", "Sách này không đang trong trạng thái mượn.");
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            java.math.BigDecimal fine = borrowService.calculateFine(br.getDueDate(), java.time.LocalDate.now());
            req.setAttribute("borrowRecord", br);
            req.setAttribute("fineAmount", fine);
            req.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(req, resp);
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

        if (!"/checkout/process".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        String borrowIdStr = req.getParameter("borrowId");
        if (borrowIdStr == null || borrowIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        try {
            long borrowId = Long.parseLong(borrowIdStr);
            BorrowRecord br = borrowDAO.findById(borrowId);
            if (br == null || br.getUser().getId() != currentUser.getId()
                    || !"BORROWED".equalsIgnoreCase(br.getStatus())) {
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            java.math.BigDecimal fine = borrowService.calculateFine(br.getDueDate(), java.time.LocalDate.now());
            long amount = fine.multiply(new java.math.BigDecimal("100")).longValue();

            if (amount <= 0) {
                // If amount is zero or negative, return directly without VNPay
                borrowService.returnBook(borrowId);
                req.getSession().setAttribute("flash", "Trả sách thành công!");
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            // Generate VNPay URL
            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String orderType = "other";
            // Use borrowId as part of TxnRef to retrieve later
            String vnp_TxnRef = borrowId + "_" + VNPayConfig.getRandomNumber(8);
            String vnp_IpAddr = VNPayConfig.getIpAddress(req);
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;

            Map<String, String> vnp_Params = new HashMap<>();
            vnp_Params.put("vnp_Version", vnp_Version);
            vnp_Params.put("vnp_Command", vnp_Command);
            vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amount));
            vnp_Params.put("vnp_CurrCode", "VND");

            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", "Thanh toan phi phat tra sach phieu #" + borrowId);
            vnp_Params.put("vnp_OrderType", orderType);
            vnp_Params.put("vnp_Locale", "vn");

            String vnp_ReturnUrl = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort()
                    + req.getContextPath() + VNPayConfig.vnp_ReturnUrl;
            vnp_Params.put("vnp_ReturnUrl", vnp_ReturnUrl);
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnp_CreateDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

            cld.add(Calendar.MINUTE, 15);
            String vnp_ExpireDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

            // Build query
            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);
            StringBuilder hashData = new StringBuilder();
            StringBuilder query = new StringBuilder();
            Iterator<String> itr = fieldNames.iterator();
            while (itr.hasNext()) {
                String fieldName = itr.next();
                String fieldValue = vnp_Params.get(fieldName);
                if ((fieldValue != null) && (fieldValue.length() > 0)) {
                    hashData.append(fieldName);
                    hashData.append('=');
                    hashData.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    query.append(URLEncoder.encode(fieldName, StandardCharsets.US_ASCII.toString()));
                    query.append('=');
                    query.append(URLEncoder.encode(fieldValue, StandardCharsets.US_ASCII.toString()));
                    if (itr.hasNext()) {
                        query.append('&');
                        hashData.append('&');
                    }
                }
            }

            String queryUrl = query.toString();
            String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;

            // Redirect to VNPay
            resp.sendRedirect(paymentUrl);

        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", "Lỗi thanh toán: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/checkout?borrowId=" + req.getParameter("borrowId"));
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }
}
