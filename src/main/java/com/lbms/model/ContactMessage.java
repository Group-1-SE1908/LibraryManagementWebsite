package com.lbms.model;

import java.time.LocalDateTime;

public class ContactMessage {
    private int id;
    private String fullName;
    private String email;
    private String phone;
    private String feedbackType;
    private String message;
    private String status;
    private LocalDateTime createdAt;

    // Constructors
    public ContactMessage() {
    }

    public ContactMessage(String fullName, String email, String phone, String feedbackType, String message) {
        this.fullName = fullName;
        this.email = email;
        this.phone = phone;
        this.feedbackType = feedbackType;
        this.message = message;
        this.status = "PENDING";
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getFeedbackType() { return feedbackType; }
    public void setFeedbackType(String feedbackType) { this.feedbackType = feedbackType; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
        return createdAt.format(formatter);
    }
}
