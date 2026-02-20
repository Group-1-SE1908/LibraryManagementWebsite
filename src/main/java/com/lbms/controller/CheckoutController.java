package com.lbms.controller;

import com.lbms.model.Cart;
import com.lbms.model.CartItem;
import com.lbms.model.User;
import com.lbms.service.BorrowService;
import com.lbms.service.CartService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet(urlPatterns = { "/checkout", "/checkout/process" })
public class CheckoutController extends HttpServlet {
    private CartService cartService;
    private BorrowService borrowService;

    @Override
    public void init() {
        this.cartService = new CartService();
        this.borrowService = new BorrowService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User currentUser = getCurrentUser(req);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Cart cart = cartService.getCart(currentUser.getId());
            if (cart.getItems() == null || cart.getItems().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/cart");
                return;
            }
            req.setAttribute("cart", cart);
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

        try {
            Cart cart = cartService.getCart(currentUser.getId());
            if (cart.getItems() == null || cart.getItems().isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/cart");
                return;
            }

            int successCount = 0;
            for (CartItem item : cart.getItems()) {
                for (int i = 0; i < item.getQuantity(); i++) {
                    borrowService.requestBorrow(currentUser.getId(), item.getBook().getId());
                    successCount++;
                }
            }

            cartService.clearCart(currentUser.getId());
            req.getSession().setAttribute("flash",
                    "Thanh toán thành công! Đã gửi " + successCount + " yêu cầu mượn sách.");
            resp.sendRedirect(req.getContextPath() + "/borrow");

        } catch (IllegalArgumentException ex) {
            req.getSession().setAttribute("flash", "Lỗi thanh toán: " + ex.getMessage());
            resp.sendRedirect(req.getContextPath() + "/checkout");
        } catch (Exception ex) {
            throw new ServletException(ex);
        }
    }

    private User getCurrentUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        return session == null ? null : (User) session.getAttribute("currentUser");
    }
}
