package com.lbms.model;

import java.io.Serializable;

public class CartItem implements Serializable {
    private int bookId;
    private String title;
    private int quantity;

    public CartItem() {
    }

    public CartItem(int bookId, String title, int quantity) {
        this.bookId = bookId;
        this.title = title;
        this.quantity = quantity;
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
}
