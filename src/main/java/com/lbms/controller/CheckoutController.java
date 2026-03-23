package com.lbms.controller;

import com.lbms.dao.PaymentHistoryDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.PaymentHistory;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.service.WalletService;
import com.lbms.config.VNPayConfig;

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
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

@WebServlet(urlPatterns = { "/checkout", "/checkout/process", "/checkout/pay-wallet" })
public class CheckoutController extends HttpServlet {
    private BorrowService borrowService;
    private com.lbms.dao.BorrowDAO borrowDAO;
    private WalletService walletService;
    private PaymentHistoryDAO paymentHistoryDAO;
    private static final String MODE_RETURN = "return";
    private static final String MODE_FINE = "fine";

    @Override
    public void init() {
        this.borrowService = new BorrowService();
        this.borrowDAO = new com.lbms.dao.BorrowDAO();
        this.walletService = new WalletService();
        this.paymentHistoryDAO = new PaymentHistoryDAO();
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

        String mode = resolveMode(req.getParameter("mode"));
        boolean fineMode = MODE_FINE.equals(mode);

        try {
            long borrowId = Long.parseLong(borrowIdStr);
            BorrowRecord br = borrowDAO.findById(borrowId);
            if (br == null || br.getUser().getId() != currentUser.getId()) {
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            if (fineMode) {
                BigDecimal storedFine = br.getFineAmount();
                if (storedFine == null || storedFine.compareTo(BigDecimal.ZERO) <= 0 || br.isPaid()) {
                    req.getSession().setAttribute("flash", "Bạn không có khoản phí nào cần thanh toán.");
                    resp.sendRedirect(req.getContextPath() + "/fines");
                    return;
                }
            } else {
                if (!"BORROWED".equalsIgnoreCase(br.getStatus()) && !"APPROVED".equalsIgnoreCase(br.getStatus()) && !"RECEIVED".equalsIgnoreCase(br.getStatus())) {
                    req.getSession().setAttribute("flash", "Sách này không đang trong trạng thái mượn.");
                    resp.sendRedirect(req.getContextPath() + "/history");
                    return;
                }
            }

            BigDecimal fine;
            if (fineMode) {
                fine = br.getFineAmount() == null ? BigDecimal.ZERO : br.getFineAmount();
            } else {
                fine = borrowService.calculateFine(br.getDueDate(), java.time.LocalDate.now());
            }

            req.setAttribute("borrowRecord", br);
            req.setAttribute("fineAmount", fine);
            req.setAttribute("mode", mode);
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

        if (!"/checkout/process".equals(req.getServletPath()) && !"/checkout/pay-wallet".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }

        if ("/checkout/pay-wallet".equals(req.getServletPath())) {
            handleWalletPayment(req, resp, currentUser);
            return;
        }

        String borrowIdStr = req.getParameter("borrowId");
        if (borrowIdStr == null || borrowIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        String mode = resolveMode(req.getParameter("mode"));
        boolean fineMode = MODE_FINE.equals(mode);

        try {
            long borrowId = Long.parseLong(borrowIdStr);
            BorrowRecord br = borrowDAO.findById(borrowId);
            if (br == null || br.getUser().getId() != currentUser.getId()) {
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            if (!fineMode
                    && (!"BORROWED".equalsIgnoreCase(br.getStatus()) && !"APPROVED".equalsIgnoreCase(br.getStatus()) && !"RECEIVED".equalsIgnoreCase(br.getStatus()))) {
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            BigDecimal fine = BigDecimal.ZERO;
            if (fineMode) {
                fine = br.getFineAmount();
                if (fine == null) {
                    fine = BigDecimal.ZERO;
                }
                if (fine.compareTo(BigDecimal.ZERO) <= 0 || br.isPaid()) {
                    req.getSession().setAttribute("flash", "Bạn không có khoản phí nào cần thanh toán.");
                    resp.sendRedirect(req.getContextPath() + "/fines");
                    return;
                }
            } else {
                fine = borrowService.calculateFine(br.getDueDate(), java.time.LocalDate.now());
            }

            long amount = fine.multiply(BigDecimal.valueOf(100)).longValue();

            if (amount <= 0) {
                if (fineMode) {
                    borrowService.markFinePaid(borrowId);
                    req.getSession().setAttribute("flash", "Thanh toán phí phạt thành công!");
                    resp.sendRedirect(req.getContextPath() + "/fines");
                } else {
                    borrowService.returnBook(borrowId);
                    req.getSession().setAttribute("flash", "Trả sách thành công!");
                    resp.sendRedirect(req.getContextPath() + "/history");
                }
                return;
            }

            // Generate VNPay URL
            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String orderType = "other";
            String txnPurpose = fineMode ? MODE_FINE : MODE_RETURN;
            String vnp_TxnRef = borrowId + "_" + txnPurpose + "_" + VNPayConfig.getRandomNumber(8);
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
            String redirectUrl = req.getContextPath() + "/checkout?borrowId=" + req.getParameter("borrowId");
            if (fineMode) {
                redirectUrl += "&mode=fine";
            }
            resp.sendRedirect(redirectUrl);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleWalletPayment(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws IOException, ServletException {
        String borrowIdStr = req.getParameter("borrowId");
        String mode = resolveMode(req.getParameter("mode"));
        boolean fineMode = MODE_FINE.equals(mode);

        if (borrowIdStr == null || borrowIdStr.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/history");
            return;
        }

        long borrowId;
        try {
            borrowId = Long.parseLong(borrowIdStr);
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash", "ID phiếu mượn không hợp lệ.");
            req.getSession().setAttribute("flashType", "error");
            resp.sendRedirect(req.getContextPath() + (fineMode ? "/fines" : "/history"));
            return;
        }

        try {
            BorrowRecord br = borrowDAO.findById(borrowId);
            if (br == null || br.getUser().getId() != currentUser.getId()) {
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            BigDecimal fine;
            if (fineMode) {
                fine = br.getFineAmount() != null ? br.getFineAmount() : BigDecimal.ZERO;
                if (fine.compareTo(BigDecimal.ZERO) <= 0 || br.isPaid()) {
                    req.getSession().setAttribute("flash", "Bạn không có khoản phí nào cần thanh toán.");
                    req.getSession().setAttribute("flashType", "error");
                    resp.sendRedirect(req.getContextPath() + "/fines");
                    return;
                }
            } else {
                fine = borrowService.calculateFine(br.getDueDate(), java.time.LocalDate.now());
            }

            if (fine.compareTo(BigDecimal.ZERO) <= 0) {
                // no fee — just return the book
                borrowService.returnBook(borrowId);
                recordPayment(currentUser.getId(), PaymentHistory.METHOD_WALLET,
                        fineMode ? PaymentHistory.TYPE_FINE : PaymentHistory.TYPE_BOOK_RETURN,
                        BigDecimal.ZERO, fineMode ? "Thanh toán phí phạt (miễn phí)" : "Trả sách (miễn phí)",
                        null, borrowId);
                req.getSession().setAttribute("flash",
                        "Trả sách thành công!" + buildDepositRefundNote(br.getDepositAmount()));
                req.getSession().setAttribute("flashType", "success");
                resp.sendRedirect(req.getContextPath() + "/history");
                return;
            }

            // check wallet balance
            User freshUser = walletService.refreshUser(currentUser.getId());
            BigDecimal balance = freshUser.getWalletBalance() != null ? freshUser.getWalletBalance() : BigDecimal.ZERO;
            if (balance.compareTo(fine) < 0) {
                req.getSession().setAttribute("flash",
                        "Số dư ví không đủ (" + formatVnd(balance) + "). Cần " + formatVnd(fine)
                                + ". Vui lòng nạp thêm hoặc chọn thanh toán VNPay.");
                req.getSession().setAttribute("flashType", "error");
                String backUrl = req.getContextPath() + "/checkout?borrowId=" + borrowId;
                if (fineMode)
                    backUrl += "&mode=fine";
                resp.sendRedirect(backUrl);
                return;
            }

            String ref = "WALLET-PAY-" + borrowId + "-" + System.currentTimeMillis();
            walletService.debitWallet(currentUser.getId(), fine,
                    (fineMode ? "Thanh toán phí phạt phiếu #" : "Thanh toán trả sách phiếu #") + borrowId, ref);

            if (fineMode) {
                borrowService.markFinePaid(borrowId);
                recordPayment(currentUser.getId(), PaymentHistory.METHOD_WALLET, PaymentHistory.TYPE_FINE,
                        fine, "Thanh toán phí phạt phiếu #" + borrowId, ref, borrowId);
                req.getSession().setAttribute("flash", "Thanh toán phí phạt thành công bằng ví!");
            } else {
                borrowService.returnBook(borrowId);
                borrowService.markFinePaid(borrowId);
                recordPayment(currentUser.getId(), PaymentHistory.METHOD_WALLET, PaymentHistory.TYPE_BOOK_RETURN,
                        fine, "Trả sách & thanh toán phí phạt phiếu #" + borrowId, ref, borrowId);
                req.getSession().setAttribute("flash",
                        "Trả sách & thanh toán thành công bằng ví!" + buildDepositRefundNote(br.getDepositAmount()));
            }

            // refresh session balance
            User updated = walletService.refreshUser(currentUser.getId());
            req.getSession().setAttribute("currentUser", updated);
            req.getSession().setAttribute("flashType", "success");
            resp.sendRedirect(req.getContextPath() + (fineMode ? "/fines" : "/history"));

        } catch (IllegalStateException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            req.getSession().setAttribute("flashType", "error");
            String backUrl = req.getContextPath() + "/checkout?borrowId=" + borrowIdStr;
            if (fineMode)
                backUrl += "&mode=fine";
            resp.sendRedirect(backUrl);
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private String buildDepositRefundNote(BigDecimal depositAmount) {
        if (depositAmount == null || depositAmount.compareTo(BigDecimal.ZERO) <= 0)
            return "";
        BigDecimal refund = depositAmount.multiply(new BigDecimal("0.5"));
        return " Đã hoàn 50% tiền cọc (" + formatVnd(refund) + ") vào ví.";
    }

    private String formatVnd(BigDecimal amount) {
        java.text.NumberFormat fmt = java.text.NumberFormat.getInstance(java.util.Locale.of("vi", "VN"));
        fmt.setMaximumFractionDigits(0);
        return fmt.format(amount) + " ₫";
    }

    private void recordPayment(long userId, String method, String type, BigDecimal amount,
            String description, String reference, long borrowId) {
        try {
            PaymentHistory ph = new PaymentHistory();
            ph.setUserId(userId);
            ph.setPaymentMethod(method);
            ph.setPaymentType(type);
            ph.setAmount(amount);
            ph.setDescription(description);
            ph.setReference(reference);
            ph.setStatus(PaymentHistory.STATUS_SUCCESS);
            ph.setBorrowId(borrowId);
            paymentHistoryDAO.save(ph);
        } catch (Exception e) {
            System.err.println("[CheckoutController] recordPayment error: " + e.getMessage());
        }
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }

    private String resolveMode(String modeParam) {
        if (modeParam != null && MODE_FINE.equalsIgnoreCase(modeParam)) {
            return MODE_FINE;
        }
        return MODE_RETURN;
    }
}