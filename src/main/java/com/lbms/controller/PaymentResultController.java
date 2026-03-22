package com.lbms.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(urlPatterns = { "/payment-result" })
public class PaymentResultController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        // Read payment result from session (set by CartController or
        // VNPayReturnController)
        String status = (String) session.getAttribute("paymentResult_status");
        String message = (String) session.getAttribute("paymentResult_message");
        BigDecimal amount = (BigDecimal) session.getAttribute("paymentResult_amount");
        String method = (String) session.getAttribute("paymentResult_method");
        String backUrl = (String) session.getAttribute("paymentResult_backUrl");
        String backLabel = (String) session.getAttribute("paymentResult_backLabel");

        // Clear from session (one-time display)
        session.removeAttribute("paymentResult_status");
        session.removeAttribute("paymentResult_message");
        session.removeAttribute("paymentResult_amount");
        session.removeAttribute("paymentResult_method");
        session.removeAttribute("paymentResult_backUrl");
        session.removeAttribute("paymentResult_backLabel");

        if (status == null) {
            // No result data — just redirect to cart
            resp.sendRedirect(req.getContextPath() + "/cart");
            return;
        }

        req.setAttribute("paymentStatus", status);
        req.setAttribute("paymentMessage", message);
        req.setAttribute("paymentAmount", amount);
        req.setAttribute("paymentMethod", method);
        req.setAttribute("paymentBackUrl", backUrl != null ? backUrl : "/cart");
        req.setAttribute("paymentBackLabel", backLabel != null ? backLabel : "Quay lại giỏ hàng");

        req.getRequestDispatcher("/WEB-INF/views/payment_result.jsp").forward(req, resp);
    }
}
