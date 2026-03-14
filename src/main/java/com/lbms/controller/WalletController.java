package com.lbms.controller;

import com.lbms.config.VNPayConfig;
import com.lbms.model.User;
import com.lbms.service.WalletService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.TimeZone;

@WebServlet(urlPatterns = { "/wallet", "/wallet/top-up" })
public class WalletController extends HttpServlet {

    private static final String WALLET_PATH = "/wallet";
    private static final String WALLET_TOPUP_PATH = "/wallet/top-up";
    private static final BigDecimal MIN_TOPUP_AMOUNT = new BigDecimal("1000");

    private WalletService walletService;

    @Override
    public void init() {
        this.walletService = new WalletService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            User freshUser = walletService.refreshUser(currentUser.getId());
            if (freshUser == null) {
                resp.sendRedirect(req.getContextPath() + "/login");
                return;
            }
            req.getSession().setAttribute("currentUser", freshUser);
            BigDecimal balance = freshUser.getWalletBalance() != null ? freshUser.getWalletBalance()
                    : BigDecimal.ZERO;
            req.setAttribute("walletBalance", balance);

            Object flash = req.getSession().getAttribute("flash");
            Object flashType = req.getSession().getAttribute("flashType");
            if (flash != null) {
                req.setAttribute("flash", flash);
                req.setAttribute("flashType", flashType);
                req.getSession().removeAttribute("flash");
                req.getSession().removeAttribute("flashType");
            }

            req.getRequestDispatcher("/WEB-INF/views/wallet.jsp").forward(req, resp);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String path = req.getServletPath();
        try {
            if (WALLET_TOPUP_PATH.equals(path)) {
                handleTopUp(req, resp, currentUser);
            } else {
                resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (IllegalArgumentException ex) {
            pushFlash(req, ex.getMessage(), "error");
            resp.sendRedirect(req.getContextPath() + WALLET_PATH);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleTopUp(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        String amountInput = req.getParameter("amount");
        if (amountInput == null || amountInput.isBlank()) {
            throw new IllegalArgumentException("Vui lòng điền số tiền cần nạp.");
        }

        BigDecimal amount;
        try {
            amount = new BigDecimal(amountInput.trim());
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Số tiền không hợp lệ.");
        }

        amount = amount.setScale(0, RoundingMode.DOWN);
        if (amount.compareTo(MIN_TOPUP_AMOUNT) < 0) {
            throw new IllegalArgumentException("Số tiền nạp tối thiểu là 1.000 VND.");
        }

        long amountInCents = amount.multiply(BigDecimal.valueOf(100)).longValue();
        if (amountInCents <= 0) {
            throw new IllegalArgumentException("Số tiền phải lớn hơn 0.");
        }

        String txnRef = WalletService.TXN_REF_PREFIX + currentUser.getId() + "-" + System.currentTimeMillis();
        Map<String, Object> topUpSession = new HashMap<>();
        topUpSession.put("amount", amount);
        topUpSession.put("label", formatCurrency(amount));
        req.getSession().setAttribute(WalletService.SESSION_KEY_PREFIX + txnRef, topUpSession);

        resp.sendRedirect(buildVNPayUrl(req, txnRef, amountInCents, amount));
    }

    private String buildVNPayUrl(HttpServletRequest req, String txnRef, long amount, BigDecimal printableAmount)
            throws Exception {
        String vnp_TmnCode = VNPayConfig.vnp_TmnCode;
        String vnp_IpAddr = VNPayConfig.getIpAddress(req);
        String vnp_ReturnUrl = req.getScheme() + "://" + req.getServerName() + ":" + req.getServerPort()
                + req.getContextPath() + VNPayConfig.vnp_ReturnUrl;

        Map<String, String> vnp_Params = new HashMap<>();
        vnp_Params.put("vnp_Version", "2.1.0");
        vnp_Params.put("vnp_Command", "pay");
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", String.valueOf(amount));
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", txnRef);
        vnp_Params.put("vnp_OrderInfo", "Nạp ví LBMS: " + formatCurrency(printableAmount));
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
                    hashData.append('&');
                    query.append('&');
                }
            }
        }

        String secureHash = VNPayConfig.hmacSHA512(VNPayConfig.vnp_HashSecret, hashData.toString());
        return VNPayConfig.vnp_PayUrl + "?" + query + "&vnp_SecureHash=" + secureHash;
    }

    private void pushFlash(HttpServletRequest req, String message, String type) {
        HttpSession session = req.getSession();
        session.setAttribute("flash", message);
        session.setAttribute("flashType", type);
    }

    private String formatCurrency(BigDecimal amount) {
        NumberFormat formatter = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
        return formatter.format(amount);
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }
}
