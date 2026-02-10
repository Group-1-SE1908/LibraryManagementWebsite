package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.AuthService;
import com.lbms.service.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = { "/login", "/register", "/logout" })
public class AuthController extends HttpServlet {
    private AuthService authService;
    private CartService cartService;

    @Override
    public void init() {
        this.authService = new AuthService();
        this.cartService = new CartService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getServletPath();
        switch (path) {
            case "/login":
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
                break;
            case "/register":
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
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

        try {
            switch (path) {
                case "/login":
                    handleLogin(req, resp);
                    break;
                case "/register":
                    handleRegister(req, resp);
                    break;
                default:
                    resp.sendError(405);
                    break;
            }
        } catch (IllegalArgumentException ex) {
            req.setAttribute("error", ex.getMessage());
            if ("/login".equals(path)) {
                req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
            } else {
                req.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(req, resp);
            }
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleLogin(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        if (email == null || email.isBlank() || password == null || password.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập email và mật khẩu");
        }

        User user = authService.login(email.trim(), password);
        if (user == null) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không đúng, hoặc tài khoản đã bị khóa");
        }

        HttpSession session = req.getSession(true);
        session.setAttribute("currentUser", user);

        String role = user.getRole() == null ? null : user.getRole().getName();
        if ("ADMIN".equalsIgnoreCase(role)) {
            resp.sendRedirect(req.getContextPath() + "/admin/users");
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

        authService.register(email.trim(), password, fullName);
        resp.sendRedirect(req.getContextPath() + "/login");
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
}
