package com.lbms.service;

import com.lbms.dao.BookDAO;
import com.lbms.dao.CartDAO;
import com.lbms.model.Book;
import com.lbms.model.Cart;

import java.sql.SQLException;

public class CartService {
    private final CartDAO cartDAO;
    private final BookDAO bookDAO;

    public CartService() {
        this.cartDAO = new CartDAO();
        this.bookDAO = new BookDAO();
    }

    public Cart getCart(long userId) throws SQLException {
        long cartId = cartDAO.ensureCart(userId);
        Cart cart = new Cart();
        cart.setId(cartId);
        cart.setUserId(userId);
        cart.setItems(cartDAO.listItems(cartId));
        return cart;
    }

    public void addBook(long userId, long bookId, int quantity) throws SQLException {
        validateBookExist(bookId);
        if (quantity < 1) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0");
        }
        long cartId = cartDAO.ensureCart(userId);
        cartDAO.addItem(cartId, bookId, quantity);
    }

    public void updateQuantity(long userId, long bookId, int quantity) throws SQLException {
        validateBookExist(bookId);
        long cartId = cartDAO.ensureCart(userId);
        cartDAO.setItemQuantity(cartId, bookId, quantity);
    }

    public void removeBook(long userId, long bookId) throws SQLException {
        validateBookExist(bookId);
        long cartId = cartDAO.ensureCart(userId);
        cartDAO.deleteItem(cartId, bookId);
    }

    private void validateBookExist(long bookId) throws SQLException {
        Book book = bookDAO.findById(bookId);
        if (book == null) {
            throw new IllegalArgumentException("Sách không tồn tại");
        }
    }
}
