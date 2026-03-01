package com.lbms.model;

import java.util.Date;

public class LibrarianActivityLog {

    private int logId;
    private String action;
    private Date timestamp;

    private User user;

    public LibrarianActivityLog() {
    }

    public LibrarianActivityLog(int logId, String action, Date timestamp, User user) {
        this.logId = logId;
        this.action = action;
        this.timestamp = timestamp;
        this.user = user;
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public Date getTimestamp() {
        return timestamp;
    }

    public void setTimestamp(Date timestamp) {
        this.timestamp = timestamp;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}