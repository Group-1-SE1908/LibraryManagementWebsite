package com.lbms.model;

import java.io.Serializable;
import java.util.Collection;
import java.util.LinkedHashMap;
import java.util.Map;

public class Cart implements Serializable {
    private Map<Integer, CartItem> items = new LinkedHashMap<>();

    public void add(int bookId, String title, int qty) {
        CartItem it = items.get(bookId);
        if (it == null) {
            items.put(bookId, new CartItem(bookId, title, qty));
        } else {
            it.setQuantity(it.getQuantity() + qty);
        }
    }

    public void update(int bookId, int qty) {
        CartItem it = items.get(bookId);
        if (it != null) {
            if (qty <= 0)
                items.remove(bookId);
            else
                it.setQuantity(qty);
        }
    }

    public void remove(int bookId) {
        items.remove(bookId);
    }

    public Collection<CartItem> getItems() {
        return items.values();
    }

    public int getTotalQuantity() {
        return items.values().stream().mapToInt(CartItem::getQuantity).sum();
    }

    public boolean isEmpty() {
        return items.isEmpty();
    }
}
