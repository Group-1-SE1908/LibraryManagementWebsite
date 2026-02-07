package com.lbms.controller;

import com.lbms.model.User;
import com.lbms.service.AuthService;

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

    @Override
    public void init() {
        this.authService = new AuthService();
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
                HttpSession session = req.getSession(false);
                if (session != null)
                    session.invalidate();
                resp.sendRedirect(req.getContextPath() + "/login");
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
}
