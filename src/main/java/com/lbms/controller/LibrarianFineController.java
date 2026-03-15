package com.lbms.controller;

import com.lbms.dao.BorrowDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(urlPatterns = {
        "/staff/fines",
        "/staff/fines/confirm-paid",
        "/admin/fines",
        "/admin/fines/confirm-paid"
})
public class LibrarianFineController extends HttpServlet {

    private BorrowDAO borrowDAO;

    @Override
    public void init() {
        this.borrowDAO = new BorrowDAO();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String basePath = resolveBasePath(req);
        try {
            requireOperationalAccess(req);

            Object flash = req.getSession().getAttribute("flash");
            if (flash != null) {
                req.setAttribute("flash", flash);
                req.getSession().removeAttribute("flash");
            }

            String keyword = req.getParameter("q");
            String paymentStatus = req.getParameter("paymentStatus");
            List<BorrowRecord> fineRecords = borrowDAO.listFineRecordsForStaff(keyword, paymentStatus);

            BigDecimal pendingTotal = BigDecimal.ZERO;
            BigDecimal paidTotal = BigDecimal.ZERO;
            int overdueActiveCount = 0;
            int unpaidCount = 0;
            int paidCount = 0;

            for (BorrowRecord record : fineRecords) {
                BigDecimal amount = record.getOutstandingFineAmount();
                if (record.isPaid()) {
                    paidCount++;
                    paidTotal = paidTotal.add(amount);
                } else if (amount.compareTo(BigDecimal.ZERO) > 0) {
                    unpaidCount++;
                    pendingTotal = pendingTotal.add(amount);
                }
                if (record.isCurrentlyOverdue()) {
                    overdueActiveCount++;
                }
            }

            req.setAttribute("fineRecords", fineRecords);
            req.setAttribute("pendingTotal", pendingTotal);
            req.setAttribute("paidTotal", paidTotal);
            req.setAttribute("overdueActiveCount", overdueActiveCount);
            req.setAttribute("unpaidCount", unpaidCount);
            req.setAttribute("paidCount", paidCount);
            req.setAttribute("finesBasePath", basePath);
            req.getRequestDispatcher("/WEB-INF/views/admin/library/fines_list.jsp").forward(req, resp);
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(resolveErrorRedirect(req));
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String basePath = resolveBasePath(req);
        try {
            requireOperationalAccess(req);

            if (!req.getServletPath().endsWith("/confirm-paid")) {
                resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
                return;
            }

            String idValue = req.getParameter("id");
            if (idValue == null || idValue.isBlank()) {
                throw new IllegalArgumentException("Thiếu mã phiếu mượn cần xác nhận.");
            }

            long borrowId;
            try {
                borrowId = Long.parseLong(idValue);
            } catch (NumberFormatException ex) {
                throw new IllegalArgumentException("Mã phiếu mượn không hợp lệ.");
            }

            BorrowRecord record = borrowDAO.findById(borrowId);
            if (record == null) {
                throw new IllegalArgumentException("Không tìm thấy phiếu mượn cần xác nhận.");
            }
            if (record.getReturnDate() == null) {
                throw new IllegalArgumentException("Chỉ xác nhận tiền phạt sau khi đã nhận sách trả.");
            }

            BigDecimal fineAmount = record.getOutstandingFineAmount();
            if (fineAmount.compareTo(BigDecimal.ZERO) <= 0) {
                throw new IllegalArgumentException("Phiếu này không phát sinh tiền phạt.");
            }
            if (record.isPaid()) {
                req.getSession().setAttribute("flash", "Phiếu này đã được xác nhận thanh toán trước đó.");
                resp.sendRedirect(req.getContextPath() + basePath);
                return;
            }

            if (record.getFineAmount() == null || record.getFineAmount().compareTo(BigDecimal.ZERO) <= 0) {
                borrowDAO.updateFineAmount(record.getId(), fineAmount);
            }
            borrowDAO.markFinePaid(record.getId());

            req.getSession().setAttribute("flash",
                    "Đã xác nhận thu tiền phạt trực tiếp cho phiếu #" + record.getId() + ".");
            resp.sendRedirect(req.getContextPath() + basePath);
        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", ex.getMessage());
            resp.sendRedirect(resolveErrorRedirect(req));
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
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

    private String resolveBasePath(HttpServletRequest req) {
        String path = req.getServletPath();
        if (path != null && path.startsWith("/admin/")) {
            return "/admin/fines";
        }
        return "/staff/fines";
    }

    private String resolveErrorRedirect(HttpServletRequest req) {
        User currentUser = (User) req.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            return req.getContextPath() + "/login";
        }
        String role = currentUser.getRole() == null ? "" : currentUser.getRole().getName();
        if ("ADMIN".equalsIgnoreCase(role)) {
            return req.getContextPath() + "/admin/dashboard";
        }
        if ("LIBRARIAN".equalsIgnoreCase(role)) {
            return req.getContextPath() + "/staff/borrowlibrary";
        }
        return req.getContextPath() + "/";
    }
}