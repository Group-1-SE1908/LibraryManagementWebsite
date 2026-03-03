package com.lbms.model;

import java.math.BigDecimal;

public class UserBorrowingSummary {

    private int currentBorrowed;     // Số sách đang mượn
    private int borrowLimit = 5;      // Giới hạn (mặc định là 5)
    private boolean hasOverdue;      // Có sách quá hạn không
    private BigDecimal unpaidFines;  // Tiền phạt chưa thanh toán
    private int totalHistory;        // Tổng số sách đã từng mượn
    private int overdueCount;        // Tổng số lần quá hạn

    // Tính toán lượt mượn còn lại
    public int getRemaining() {
        return borrowLimit - currentBorrowed;
    }

    // Getters và Setters
    public int getCurrentBorrowed() {
        return currentBorrowed;
    }

    public void setCurrentBorrowed(int currentBorrowed) {
        this.currentBorrowed = currentBorrowed;
    }

    public int getBorrowLimit() {
        return borrowLimit;
    }

    public void setBorrowLimit(int borrowLimit) {
        this.borrowLimit = borrowLimit;
    }

    public boolean isHasOverdue() {
        return hasOverdue;
    }

    public void setHasOverdue(boolean hasOverdue) {
        this.hasOverdue = hasOverdue;
    }

    public BigDecimal getUnpaidFines() {
        return unpaidFines;
    }

    public void setUnpaidFines(BigDecimal unpaidFines) {
        this.unpaidFines = unpaidFines;
    }

    public int getTotalHistory() {
        return totalHistory;
    }

    public void setTotalHistory(int totalHistory) {
        this.totalHistory = totalHistory;
    }

    public int getOverdueCount() {
        return overdueCount;
    }

    public void setOverdueCount(int overdueCount) {
        this.overdueCount = overdueCount;
    }
}
