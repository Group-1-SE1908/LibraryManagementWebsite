package com.lbms.model;

import java.sql.Timestamp;

public class Reservation {
    private long id;
    private int userId;
    private int bookId;
    private String status;          // WAITING | AVAILABLE | BORROWED | CANCELLED | EXPIRED
    private String note;
    private Timestamp notifiedAt;
    private Timestamp expiredAt;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    private Integer queuePosition;  // Vị trí trong hàng chờ (null nếu không còn active)

    // Join fields
    private String bookTitle;
    private String bookAuthor;
    private String bookImage;
    private String userName;
    private String userEmail;
    private String userPhone;

    public Reservation() {}

    public Reservation(int userId, int bookId) {
        this.userId = userId;
        this.bookId = bookId;
        this.status = "WAITING";
    }

    // ── Helpers ──────────────────────────────────────────────────────────

    /** Kiểm tra reservation còn hạn hay không */
    public boolean isExpired() {
        return expiredAt != null && expiredAt.before(new java.util.Date());
    }

    /** Số ngày còn lại đến hạn lấy sách (âm = đã quá hạn) */
    public long getDaysUntilExpiry() {
        if (expiredAt == null) return Long.MAX_VALUE;
        long diff = expiredAt.getTime() - System.currentTimeMillis();
        return diff / (1000 * 60 * 60 * 24);
    }

    /** Label tiếng Việt cho status */
    public String getStatusLabel() {
        if (status == null) return "";
        return switch (status) {
            case "WAITING"   -> "Đang chờ";
            case "AVAILABLE" -> "Sẵn sàng nhận";
            case "BORROWED"  -> "Đã mượn";
            case "CANCELLED" -> "Đã hủy";
            case "EXPIRED"   -> "Hết hạn";
            default          -> status;
        };
    }

    // ── Getters & Setters ─────────────────────────────────────────────────

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

    public Integer getQueuePosition() { return queuePosition; }
    public void setQueuePosition(Integer queuePosition) { this.queuePosition = queuePosition; }

    public String getBookTitle() { return bookTitle; }
    public void setBookTitle(String bookTitle) { this.bookTitle = bookTitle; }

    public String getBookAuthor() { return bookAuthor; }
    public void setBookAuthor(String bookAuthor) { this.bookAuthor = bookAuthor; }

    public String getBookImage() { return bookImage; }
    public void setBookImage(String bookImage) { this.bookImage = bookImage; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getUserPhone() { return userPhone; }
    public void setUserPhone(String userPhone) { this.userPhone = userPhone; }
}