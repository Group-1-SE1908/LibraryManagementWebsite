package com.lbms.controller;

import com.lbms.service.ForgotPasswordService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet(urlPatterns = { "/forgot-password", "/reset-password" })
public class ForgotPasswordController extends HttpServlet {
    private ForgotPasswordService forgotPasswordService;

    @Override
    public void init() {
        this.forgotPasswordService = new ForgotPasswordService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/forgot-password":
                req.getRequestDispatcher("/WEB-INF/views/forgot_password.jsp").forward(req, resp);
                break;
            case "/reset-password":
                req.setAttribute("token", req.getParameter("token"));
                req.getRequestDispatcher("/WEB-INF/views/reset_password.jsp").forward(req, resp);
                break;
            default:
                resp.sendError(404);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        req.setCharacterEncoding("UTF-8");

        try {
            switch (path) {
                case "/forgot-password":
                    handleForgot(req, resp);
                    break;
                case "/reset-password":
                    handleReset(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            if ("/forgot-password".equals(path)) {
                req.getRequestDispatcher("/WEB-INF/views/forgot_password.jsp").forward(req, resp);
            } else {
                req.setAttribute("token", req.getParameter("token"));
                req.getRequestDispatcher("/WEB-INF/views/reset_password.jsp").forward(req, resp);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleForgot(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String email = req.getParameter("email");

        // luôn trả về thông báo chung để tránh lộ email có tồn tại hay không
        forgotPasswordService.requestReset(email);

        req.setAttribute("message", "Nếu email tồn tại trong hệ thống, link đặt lại mật khẩu đã được gửi.");
        req.getRequestDispatcher("/WEB-INF/views/forgot_password.jsp").forward(req, resp);
    }

    private void handleReset(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String token = req.getParameter("token");
        String newPassword = req.getParameter("password");
        String confirm = req.getParameter("confirm");

        if (newPassword == null || confirm == null || !newPassword.equals(confirm)) {
            throw new IllegalArgumentException("Xác nhận mật khẩu không khớp");
        }

        forgotPasswordService.resetPassword(token, newPassword);
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
