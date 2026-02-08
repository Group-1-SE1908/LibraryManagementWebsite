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

    public Book() {
    }

    public Book(int bookId, String title, String author, BigDecimal price, boolean availability, int categoryId, String categoryName,String image) {
        this.bookId = bookId;
        this.title = title;
        this.author = author;
        this.price = price;
        this.availability = availability;
        this.categoryId = categoryId;
        this.categoryName = categoryName;
        this.image = image;
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
        return availability;
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
    
    
    
}
