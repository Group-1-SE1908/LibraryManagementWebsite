package com.lbms.dao;

import com.lbms.model.Book;
import com.lbms.model.CartItem;
import com.lbms.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CartDAO {

    public long ensureCart(long userId) throws SQLException {
        Long cartId = findCartId(userId);
        if (cartId != null) {
            return cartId;
        }
        return createCart(userId);
    }

    private Long findCartId(long userId) throws SQLException {
        String sql = "SELECT cart_id FROM Cart WHERE user_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong("cart_id");
                }
            }
        }
        return null;
    }

    private long createCart(long userId) throws SQLException {
        String sql = "INSERT INTO Cart(user_id) VALUES(?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, userId);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
                throw new SQLException("Không thể tạo giỏ hàng");
            }
        }
    }

    public List<CartItem> listItems(long cartId) throws SQLException {
        String sql = "SELECT ci.cart_item_id, ci.cart_id, ci.book_id, ci.quantity, " +
                "b.title AS book_title, b.author AS book_author, b.price AS book_price, " +
                "b.availability AS book_availability " +
                "FROM CartItem ci LEFT JOIN Book b ON ci.book_id = b.book_id " +
                "WHERE ci.cart_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            try (ResultSet rs = ps.executeQuery()) {
                List<CartItem> out = new ArrayList<>();
                while (rs.next()) {
                    out.add(mapCartItem(rs));
                }
                return out;
            }
        }
    }

    public void addItem(long cartId, long bookId, int quantity) throws SQLException {
        String updateSql = "UPDATE CartItem SET quantity = quantity + ? WHERE cart_id = ? AND book_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(updateSql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, cartId);
            ps.setLong(3, bookId);
            int updated = ps.executeUpdate();
            if (updated == 0) {
                insertItem(c, cartId, bookId, quantity);
            }
        }
    }

    public void setItemQuantity(long cartId, long bookId, int quantity) throws SQLException {
        if (quantity <= 0) {
            deleteItem(cartId, bookId);
            return;
        }
        String sql = "UPDATE CartItem SET quantity = ? WHERE cart_id = ? AND book_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setLong(2, cartId);
            ps.setLong(3, bookId);
            int updated = ps.executeUpdate();
            if (updated == 0) {
                insertItem(c, cartId, bookId, quantity);
            }
        }
    }

    public void deleteItem(long cartId, long bookId) throws SQLException {
        String sql = "DELETE FROM CartItem WHERE cart_id = ? AND book_id = ?";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, bookId);
            ps.executeUpdate();
        }
    }

    private void insertItem(Connection c, long cartId, long bookId, int quantity) throws SQLException {
        String insertSql = "INSERT INTO CartItem(cart_id, book_id, quantity) VALUES(?, ?, ?)";
        try (PreparedStatement ps = c.prepareStatement(insertSql)) {
            ps.setLong(1, cartId);
            ps.setLong(2, bookId);
            ps.setInt(3, quantity);
            ps.executeUpdate();
        }
    }

    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        CartItem item = new CartItem();
        item.setId(rs.getLong("cart_item_id"));
        item.setCartId(rs.getLong("cart_id"));
        item.setBookId(rs.getLong("book_id"));
        item.setQuantity(rs.getInt("quantity"));
        item.setBook(mapBookFromRow(rs));
        return item;
    }

    private Book mapBookFromRow(ResultSet rs) throws SQLException {
        Book book = new Book();
        book.setId(rs.getLong("book_id"));
        book.setTitle(rs.getString("book_title"));
        book.setAuthor(rs.getString("book_author"));
        book.setAvailability(rs.getBoolean("book_availability"));
        BigDecimal price = rs.getBigDecimal("book_price");
        if (price != null) {
            book.setPrice(price.doubleValue());
        }
        return book;
    }
}
