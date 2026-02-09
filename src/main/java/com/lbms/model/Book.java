package com.lbms.model;

import java.math.BigDecimal;

public class Book {
    private int bookId;
    private String title;
    private String author;
    private BigDecimal price;
    private boolean availability;
    private int categoryId;
    private String categoryName;
    private String image;
    private String isbn;
    private int quantity;

    public Book() {
    }

    public Book(int bookId, String title, String author, BigDecimal price, boolean availability, int categoryId, String categoryName,String image, String isbn, int quantity) {
        this.bookId = bookId;
        this.title = title;
        this.author = author;
        this.price = price;
        this.availability = availability;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.image = image;
        this.isbn = isbn;
        this.quantity = quantity;
        
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookID) {
        this.bookId = bookID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public boolean isAvailability() {
        return this.quantity > 0;
    }

    public void setAvailability(boolean availability) {
        this.availability = availability;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getCategoryName() {
        return categoryName;
    }

    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getIsbn() {
        return isbn;
    }

    public void setIsbn(String isbn) {
        this.isbn = isbn;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }
    
    
    
}
