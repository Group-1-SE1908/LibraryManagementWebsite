package com.lbms.service;

import com.lbms.model.Cart;
import jakarta.servlet.http.HttpSession;

public class CartService {
    public static final String SESSION_CART = "_CART_";

    public static Cart getCart(HttpSession session) {
        Object o = session.getAttribute(SESSION_CART);
        if (o instanceof Cart)
            return (Cart) o;
        Cart cart = new Cart();
        session.setAttribute(SESSION_CART, cart);
        return cart;
    }

    public static void clearCart(HttpSession session) {
        session.removeAttribute(SESSION_CART);
    }
}
