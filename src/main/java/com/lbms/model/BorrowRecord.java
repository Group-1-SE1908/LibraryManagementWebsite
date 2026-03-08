package com.lbms.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

public class BorrowRecord {

    private static final BigDecimal FINE_PER_DAY = new BigDecimal("5000");

    private long id;
    private User user;
    private Book book;
    private LocalDate borrowDate;
    private LocalDate dueDate;
    private LocalDate returnDate;
    private String status;
    private BigDecimal fineAmount;
    private BigDecimal depositAmount;
    private BookCopy bookCopy;
    private String borrowMethod;
    private ShippingDetails shippingDetails;
    private String rejectReason;
    private boolean isPaid;
    private int quantity;
    private String groupCode;

    public BorrowRecord() {
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Book getBook() {
        return book;
    }

    public void setBook(Book book) {
        this.book = book;
    }

    public LocalDate getBorrowDate() {
        return borrowDate;
    }

    public void setBorrowDate(LocalDate borrowDate) {
        this.borrowDate = borrowDate;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public long getOverdueDays() {
        if (dueDate == null) {
            return 0L;
        }
        LocalDate reference = returnDate != null ? returnDate : LocalDate.now();
        long delta = ChronoUnit.DAYS.between(dueDate, reference);
        return Math.max(delta, 0L);
    }

    public String getRejectReason() {
        return rejectReason;
    }

    public void setRejectReason(String rejectReason) {
        this.rejectReason = rejectReason;
    }

    public boolean isIsPaid() {
        return isPaid;
    }

    public String getGroupCode() {
        return groupCode;
    }

    public void setGroupCode(String groupCode) {
        this.groupCode = groupCode;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public void setIsPaid(boolean isPaid) {
        this.isPaid = isPaid;
    }

    public boolean isPaid() {
        return isPaid;
    }

    public void setPaid(boolean paid) {
        this.isPaid = paid;
    }

    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }

    public LocalDate getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(LocalDate returnDate) {
        this.returnDate = returnDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getFineAmount() {
        return fineAmount;
    }

    public void setFineAmount(BigDecimal fineAmount) {
        this.fineAmount = fineAmount;
    }

    public BigDecimal getOutstandingFineAmount() {
        if (fineAmount != null && fineAmount.compareTo(BigDecimal.ZERO) > 0) {
            return fineAmount;
        }
        long overdueDays = getOverdueDays();
        if (overdueDays <= 0) {
            return BigDecimal.ZERO;
        }
        return FINE_PER_DAY.multiply(BigDecimal.valueOf(overdueDays));
    }

    public boolean hasOutstandingFine() {
        return getOutstandingFineAmount().compareTo(BigDecimal.ZERO) > 0;
    }

    public boolean isCurrentlyOverdue() {
        if (dueDate == null || returnDate != null) {
            return false;
        }
        if (status == null) {
            return dueDate.isBefore(LocalDate.now());
        }
        return dueDate.isBefore(LocalDate.now())
                && ("BORROWED".equalsIgnoreCase(status) || "RECEIVED".equalsIgnoreCase(status));
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public BookCopy getBookCopy() {
        return bookCopy;
    }

    public void setBookCopy(BookCopy bookCopy) {
        this.bookCopy = bookCopy;
    }

    public String getBorrowMethod() {
        return borrowMethod;
    }

    public void setBorrowMethod(String borrowMethod) {
        this.borrowMethod = borrowMethod;
    }

    public ShippingDetails getShippingDetails() {
        return shippingDetails;
    }

    public void setShippingDetails(ShippingDetails shippingDetails) {
        this.shippingDetails = shippingDetails;
    }

    public String getFormattedBorrowDate() {
        return borrowDate != null ? borrowDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy"))
                : "---";
    }

    public String getFormattedDueDate() {
        return dueDate != null ? dueDate.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy")) : "---";
    }
}
