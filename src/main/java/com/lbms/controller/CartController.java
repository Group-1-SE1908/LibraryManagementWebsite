package com.lbms.controller;

import com.lbms.model.Cart;
import com.lbms.model.CartItem;
import com.lbms.service.CartService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "CartController", urlPatterns = { "/cart/*" })
public class CartController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        if (path == null || "/".equals(path) || "/index".equals(path)) {
            req.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(req, resp);
            return;
        }
        resp.sendError(HttpServletResponse.SC_NOT_FOUND);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String path = req.getPathInfo();
        HttpSession session = req.getSession();
        Cart cart = CartService.getCart(session);

        if (path == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        switch (path) {
            case "/add": {
                try {
                    int bookId = Integer.parseInt(req.getParameter("bookId"));
                    String title = req.getParameter("title");
                    int qty = 1;
                    String q = req.getParameter("quantity");
                    if (q != null)
                        qty = Math.max(1, Integer.parseInt(q));
                    cart.add(bookId, title == null ? "" : title, qty);
                } catch (NumberFormatException e) {
                    // ignore invalid id
                }
                resp.sendRedirect(req.getContextPath() + "/cart");
                break;
            }
            case "/update": {
                try {
                    int bookId = Integer.parseInt(req.getParameter("bookId"));
                    int qty = Integer.parseInt(req.getParameter("quantity"));
                    cart.update(bookId, qty);
                } catch (NumberFormatException e) {
                }
                resp.sendRedirect(req.getContextPath() + "/cart");
                break;
            }
            case "/remove": {
                try {
                    int bookId = Integer.parseInt(req.getParameter("bookId"));
                    cart.remove(bookId);
                } catch (NumberFormatException e) {
                }
                resp.sendRedirect(req.getContextPath() + "/cart");
                break;
            }
            default:
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
}
