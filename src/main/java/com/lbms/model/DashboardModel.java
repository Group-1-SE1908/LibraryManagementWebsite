package com.lbms.model;

import java.util.List;

public class DashboardModel {

    private int totalBooks;
    private int activeUsers;
    private int pendingReturns;
    private int overdueBooks;
    private int totalShipments;
    private double finesCollected;
    private double finesPending;

    private List<TopUser> topUsers;
    private List<TopBook> topBooks;

    public DashboardModel() {
    }

    public static class TopUser {
        private int userId;
        private String fullName;
        private String email;
        private String phone;
        private String address;
        private String status;
        private String avatar;
        private String roleName;
        private int totalBorrows;

        public TopUser(int userId, String fullName, String email, String phone,
                String address, String status, String avatar, String roleName, int totalBorrows) {
            this.userId = userId;
            this.fullName = fullName;
            this.email = email;
            this.phone = phone;
            this.address = address;
            this.status = status;
            this.avatar = avatar;
            this.roleName = roleName;
            this.totalBorrows = totalBorrows;
        }

        public int getUserId() {
            return userId;
        }

        public String getFullName() {
            return fullName;
        }

        public String getEmail() {
            return email;
        }

        public String getPhone() {
            return phone;
        }

        public String getAddress() {
            return address;
        }

        public String getStatus() {
            return status;
        }

        public String getAvatar() {
            return avatar;
        }

        public String getRoleName() {
            return roleName;
        }

        public int getTotalBorrows() {
            return totalBorrows;
        }
    }

    public static class TopBook {
        private String title;
        private String isbn;
        private int count;

        public TopBook(String title, String isbn, int count) {
            this.title = title;
            this.isbn = isbn;
            this.count = count;
        }

        public String getTitle() {
            return title;
        }

        public String getIsbn() {
            return isbn;
        }

        public int getCount() {
            return count;
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

    public int getPendingReturns() {
        return pendingReturns;
    }

    public void setPendingReturns(int pendingReturns) {
        this.pendingReturns = pendingReturns;
    }

    public int getOverdueBooks() {
        return overdueBooks;
    }

    public void setOverdueBooks(int overdueBooks) {
        this.overdueBooks = overdueBooks;
    }

    public int getTotalShipments() {
        return totalShipments;
    }

    public void setTotalShipments(int totalShipments) {
        this.totalShipments = totalShipments;
    }

    public double getFinesCollected() {
        return finesCollected;
    }

    public void setFinesCollected(double finesCollected) {
        this.finesCollected = finesCollected;
    }

    public double getFinesPending() {
        return finesPending;
    }

    public void setFinesPending(double finesPending) {
        this.finesPending = finesPending;
    }

    public List<TopUser> getTopUsers() {
        return topUsers;
    }

    public void setTopUsers(List<TopUser> topUsers) {
        this.topUsers = topUsers;
    }

    public List<TopBook> getTopBooks() {
        return topBooks;
    }

    public void setTopBooks(List<TopBook> topBooks) {
        this.topBooks = topBooks;
    }
}