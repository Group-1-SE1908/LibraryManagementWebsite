package com.lbms.controller;

import com.lbms.model.Cart;
import com.lbms.model.User;
import com.lbms.service.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(urlPatterns = { "/cart", "/cart/add", "/cart/update", "/cart/remove" })
public class CartController extends HttpServlet {
    private CartService cartService;

    @Override
    public void init() {
        this.cartService = new CartService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!"/cart".equals(req.getServletPath())) {
            resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            return;
        }
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        try {
            Cart cart = cartService.getCart(currentUser.getId());
            req.setAttribute("cart", cart);
            req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
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
        String path = req.getServletPath();
        try {
            switch (path) {
                case "/cart/add":
                    handleAdd(req, resp, currentUser);
                    break;
                case "/cart/update":
                    handleUpdate(req, resp, currentUser);
                    break;
                case "/cart/remove":
                    handleRemove(req, resp, currentUser);
                    break;
                default:
                    resp.sendError(HttpServletResponse.SC_METHOD_NOT_ALLOWED);
            }
        } catch (IllegalArgumentException ex) {
            handlePostError(req, resp, path, ex.getMessage());
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private void handleAdd(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        int quantity = parseIntParam(req, "quantity", 1);
        cartService.addBook(currentUser.getId(), bookId, quantity);
        redirectWithParam(req, resp, "/books", "cartSuccess", "Đã thêm sách vào giỏ hàng");
    }

    private void handleUpdate(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        int quantity = parseIntParam(req, "quantity", null);
        cartService.updateQuantity(currentUser.getId(), bookId, quantity);
        String message = quantity <= 0 ? "Đã xóa sách khỏi giỏ hàng" : "Đã cập nhật số lượng trong giỏ hàng";
        redirectWithParam(req, resp, "/cart", "cartSuccess", message);
    }

    private void handleRemove(HttpServletRequest req, HttpServletResponse resp, User currentUser) throws Exception {
        long bookId = parseLongParam(req, "bookId");
        cartService.removeBook(currentUser.getId(), bookId);
        redirectWithParam(req, resp, "/cart", "cartSuccess", "Đã xóa sách khỏi giỏ hàng");
    }

    private void handlePostError(HttpServletRequest req, HttpServletResponse resp, String path, String message)
            throws IOException {
        String target = "/books";
        if ("/cart/update".equals(path) || "/cart/remove".equals(path)) {
            target = "/cart";
        }
        redirectWithParam(req, resp, target, "cartError", message);
    }

    private long parseLongParam(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Thiếu tham số " + name);
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + name + " không hợp lệ");
        }
    }

    private int parseIntParam(HttpServletRequest req, String name, Integer defaultValue) {
        String value = req.getParameter(name);
        if (value == null || value.isBlank()) {
            if (defaultValue == null) {
                throw new IllegalArgumentException("Thiếu tham số " + name);
            }
            return defaultValue;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            throw new IllegalArgumentException("Giá trị " + name + " không hợp lệ");
        }
    }

    private void redirectWithParam(HttpServletRequest req, HttpServletResponse resp, String path, String paramName,
            String message) throws IOException {
        StringBuilder target = new StringBuilder(req.getContextPath()).append(path);
        if (message != null && !message.isBlank()) {
            target.append("?").append(paramName).append("=")
                    .append(URLEncoder.encode(message, StandardCharsets.UTF_8));
        }
        resp.sendRedirect(target.toString());
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }
}
