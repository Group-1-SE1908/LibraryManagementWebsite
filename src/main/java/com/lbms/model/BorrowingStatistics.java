package com.lbms.model;

import java.util.List;
import java.util.Map;

public class BorrowingStatistics {
    private int totalBooks;
    private int activeUsers;
    private int totalBorrows;
    private int overdueBooks;
    private Map<String, Integer> statusCounts;
    private List<TopBook> topBooks;

    private List<BorrowingDetail> detailedRecords;

    public static class TopBook {
        private String title;
        private String category;
        private int borrowCount;

        public TopBook(String title, String category, int borrowCount) {
            this.title = title;
            this.category = category;
            this.borrowCount = borrowCount;
        }

        public String getTitle() {
            return title;
        }

        public String getCategory() {
            return category;
        }

        public int getBorrowCount() {
            return borrowCount;
        }
    }

    public static class BorrowingDetail {
        private int orderId;
        private String borrowerName;
        private String email;
        private String bookTitle;
        private String barcode;
        private String borrowDate;
        private String dueDate;
        private String returnDate;
        private String status;
        private double fineAmount;

        public BorrowingDetail(int orderId, String borrowerName, String email, String bookTitle,
                String barcode, String borrowDate, String dueDate,
                String returnDate, String status, double fineAmount) {
            this.orderId = orderId;
            this.borrowerName = borrowerName;
            this.email = email;
            this.bookTitle = bookTitle;
            this.barcode = barcode;
            this.borrowDate = borrowDate;
            this.dueDate = dueDate;
            this.returnDate = returnDate;
            this.status = status;
            this.fineAmount = fineAmount;
        }

        public int getOrderId() {
            return orderId;
        }

        public String getBorrowerName() {
            return borrowerName;
        }

        public String getEmail() {
            return email;
        }

        public String getBookTitle() {
            return bookTitle;
        }

        public String getBarcode() {
            return barcode;
        }

        public String getBorrowDate() {
            return borrowDate;
        }

        public String getDueDate() {
            return dueDate;
        }

        public String getReturnDate() {
            return returnDate;
        }

        public String getStatus() {
            return status;
        }

        public double getFineAmount() {
            return fineAmount;
        }
    }

    public int getTotalBooks() {
        return totalBooks;
    }

    public void setTotalBooks(int totalBooks) {
        this.totalBooks = totalBooks;
    }

    public int getActiveUsers() {
        return activeUsers;
    }

    public void setActiveUsers(int activeUsers) {
        this.activeUsers = activeUsers;
    }

    public int getTotalBorrows() {
        return totalBorrows;
    }

    public void setTotalBorrows(int totalBorrows) {
        this.totalBorrows = totalBorrows;
    }

    public int getOverdueBooks() {
        return overdueBooks;
    }

    public void setOverdueBooks(int overdueBooks) {
        this.overdueBooks = overdueBooks;
    }

    public Map<String, Integer> getStatusCounts() {
        return statusCounts;
    }

    public void setStatusCounts(Map<String, Integer> statusCounts) {
        this.statusCounts = statusCounts;
    }

    public List<TopBook> getTopBooks() {
        return topBooks;
    }

    public void setTopBooks(List<TopBook> topBooks) {
        this.topBooks = topBooks;
    }

    public List<BorrowingDetail> getDetailedRecords() {
        return detailedRecords;
    }

    public void setDetailedRecords(List<BorrowingDetail> detailedRecords) {
        this.detailedRecords = detailedRecords;
    }
}