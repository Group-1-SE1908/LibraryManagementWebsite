package com.lbms.model;

import java.sql.Timestamp;

public class Reservation {
    private long id;
    private int userId;
    private int bookId;
    private String status;      // WAITING | AVAILABLE | BORROWED | CANCELLED | EXPIRED
    private String note;
    private Timestamp notifiedAt;
    private Timestamp expiredAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;


    private String bookTitle;
    private String bookAuthor;
    private String bookImage;
    private String userName;

    public Reservation() {}

    public Reservation(int userId, int bookId) {
        this.userId = userId;
        this.bookId = bookId;
        this.status = "WAITING";
    }

    // ── Getters & Setters ──────────────────────────────────────────────

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }

    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public int getBookId() { return bookId; }
    public void setBookId(int bookId) { this.bookId = bookId; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }

    public Timestamp getNotifiedAt() { return notifiedAt; }
    public void setNotifiedAt(Timestamp notifiedAt) { this.notifiedAt = notifiedAt; }

    public Timestamp getExpiredAt() { return expiredAt; }
    public void setExpiredAt(Timestamp expiredAt) { this.expiredAt = expiredAt; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public String getBookAuthor() { return bookAuthor; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }

    public String getBookImage() { return bookImage; }
    public void setBookImage(String bookImage) { this.bookImage = bookImage; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
}