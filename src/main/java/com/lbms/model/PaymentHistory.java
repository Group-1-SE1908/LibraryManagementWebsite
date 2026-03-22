package com.lbms.model;

import java.math.BigDecimal;
import java.util.Date;

public class PaymentHistory {

    public static final String METHOD_WALLET = "WALLET";
    public static final String METHOD_VNPAY = "VNPAY";

    public static final String TYPE_BOOK_DEPOSIT = "BOOK_DEPOSIT";
    public static final String TYPE_FINE = "FINE";
    public static final String TYPE_BOOK_RETURN = "BOOK_RETURN";

    public static final String STATUS_SUCCESS = "SUCCESS";
    public static final String STATUS_FAILED = "FAILED";

    private long id;
    private long userId;
    private String paymentMethod;
    private String paymentType;
    private BigDecimal amount;
    private String description;
    private String reference;
    private String status;
    private Long borrowId;
    private Date createdAt;

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getPaymentType() {
        return paymentType;
    }

    public void setPaymentType(String paymentType) {
        this.paymentType = paymentType;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getReference() {
        return reference;
    }

    public void setReference(String reference) {
        this.reference = reference;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Long getBorrowId() {
        return borrowId;
    }

    public void setBorrowId(Long borrowId) {
        this.borrowId = borrowId;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isSuccess() {
        return STATUS_SUCCESS.equals(this.status);
    }
}
