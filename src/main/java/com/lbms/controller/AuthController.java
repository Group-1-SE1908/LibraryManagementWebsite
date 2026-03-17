package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.AuthService;
import com.lbms.service.CartService;
import com.lbms.service.EmailVerificationService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = { "/login", "/register", "/logout", "/verify-email", "/adminlogin" })
public class AuthController extends HttpServlet {

    private AuthService authService;
    private CartService cartService;
    private EmailVerificationService emailVerificationService;

    @Override
    public void init() {
        this.authService = new AuthService();
        this.cartService = new CartService();
        this.emailVerificationService = new EmailVerificationService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/login":
                if (isAuthenticated(req)) {
                    redirectToHome(req, resp);
                    return;
                }
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                break;
            case "/register":
                if (isAuthenticated(req)) {
                    redirectToHome(req, resp);
                    return;
                }
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
                break;
            case "/adminlogin":
                if (isAuthenticated(req)) {
                    redirectToHome(req, resp);
                    return;
                }
                req.getRequestDispatcher("/WEB-INF/views/admin_login.jsp").forward(req, resp);
                break;
            case "/verify-email":
                handleVerifyGet(req, resp);
                break;
            case "/logout":
                handleLogout(req, resp);
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

        if (("/login".equals(path) || "/register".equals(path) || "/adminlogin".equals(path)) && isAuthenticated(req)) {
            redirectToHome(req, resp);
            return;
        }

        try {
            switch (path) {
                case "/login":
                case "/adminlogin":
                    handleLogin(req, resp, path);
                    break;
                case "/register":
                    handleRegister(req, resp);
                    break;
                case "/verify-email":
                    handleVerifyPost(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            if ("/login".equals(path)) {
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            } else if ("/adminlogin".equals(path)) {
                req.getRequestDispatcher("/WEB-INF/views/admin_login.jsp").forward(req, resp);
            } else if ("/verify-email".equals(path)) {
                req.setAttribute("email", req.getParameter("email"));
                req.getRequestDispatcher("/WEB-INF/views/verify_email.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp, String path) throws Exception {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập email và mật khẩu");
        }

        User user = authService.login(email.trim(), password);
        if (user == null) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không đúng, hoặc tài khoản đã bị khóa");
        }

        String role = user.getRole() == null ? null : user.getRole().getName();

        if ("/login".equals(path) && isOperationalRole(role)) {
            throw new IllegalArgumentException("Trang này chỉ dành cho bạn đọc. Vui lòng dùng trang đăng nhập nhân viên.");
        }
        if ("/adminlogin".equals(path) && !isOperationalRole(role)) {
            throw new IllegalArgumentException("Chỉ nhân viên hoặc quản trị viên được phép đăng nhập tại đây.");
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("currentUser", user);

        // THÊM DÒNG NÀY ĐỂ KIỂM TRA
        System.out.println(">>> LOGIN SUCCESS: " + email + " | Role: [" + role + "]");

        if ("ADMIN".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin");
        } else if ("LIBRARIAN".equalsIgnoreCase(role)) {

            resp.sendRedirect(req.getContextPath() + "/staff/borrowlibrary");
        } else {
            resp.sendRedirect(req.getContextPath() + "/books");
        }
    }

    private void handleRegister(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String fullName = req.getParameter("fullName");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            throw new IllegalArgumentException("Email và mật khẩu là bắt buộc");
        }

        if (password.length() < 6) {
            throw new IllegalArgumentException("Mật khẩu tối thiểu 6 ký tự");
        }

        long userId = authService.register(email.trim(), password, fullName);
        emailVerificationService.sendVerificationCode(userId, email.trim());
        String encodedEmail = URLEncoder.encode(email.trim(), StandardCharsets.UTF_8);
        resp.sendRedirect(req.getContextPath() + "/verify-email?email=" + encodedEmail);
    }

    private void handleVerifyGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setAttribute("email", req.getParameter("email"));
        req.getRequestDispatcher("/WEB-INF/views/verify_email.jsp").forward(req, resp);
    }

    private void handleVerifyPost(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String action = req.getParameter("action");
        String email = req.getParameter("email");
        if ("resend".equalsIgnoreCase(action)) {
            emailVerificationService.resendCode(email);
            req.setAttribute("message", "Mã xác thực đã được gửi lại. Vui lòng kiểm tra email.");
            req.setAttribute("email", email);
            req.getRequestDispatcher("/WEB-INF/views/verify_email.jsp").forward(req, resp);
            return;
        }

        String code = req.getParameter("code");
        emailVerificationService.verifyCode(email, code);
        req.setAttribute("success", "Email đã được xác thực. Bạn có thể đăng nhập ngay.");
        req.setAttribute("email", email);
        req.getRequestDispatcher("/WEB-INF/views/verify_email.jsp").forward(req, resp);
    }

    private void handleLogout(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null) {
                try {
                    cartService.clearCart(currentUser.getId());
                } catch (Exception ex) {
                    throw new ServletException(ex);
                }
            }
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    private boolean isAuthenticated(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session != null && session.getAttribute("currentUser") != null;
    }

    private void redirectToHome(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session != null) {
            User currentUser = (User) session.getAttribute("currentUser");
            if (currentUser != null && currentUser.getRole() != null) {
                String role = currentUser.getRole().getName();
                if ("ADMIN".equalsIgnoreCase(role)) {
                    resp.sendRedirect(req.getContextPath() + "/admin");
                    return;
                }
                if ("LIBRARIAN".equalsIgnoreCase(role)) {
                    resp.sendRedirect(req.getContextPath() + "/staff/borrowlibrary");
                    return;
                }
            }
        }
        resp.sendRedirect(req.getContextPath() + "/");
    }

    private boolean isOperationalRole(String roleName) {
        if (roleName == null) {
            return false;
        }
        return "ADMIN".equalsIgnoreCase(roleName) || "LIBRARIAN".equalsIgnoreCase(roleName);
    }
}
