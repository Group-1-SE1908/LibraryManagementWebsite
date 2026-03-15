package com.lbms.model;

import java.sql.Timestamp;

public class CommentReport {
    private long reportId;
    private long commentId;
    private int reporterUserId;
    private String reason;
    private String description;
    private Timestamp reportTime;
    private String status;

    // Additional fields for display
    private String reporterFullName;
    private String commentContent;
    private String commentUserFullName;

    public CommentReport() {}

    public CommentReport(long commentId, int reporterUserId, String reason, String description) {
        this.commentId = commentId;
        this.reporterUserId = reporterUserId;
        this.reason = reason;
        this.description = description;
        this.status = "PENDING";
    }

    // Getters and Setters
    public long getReportId() {
        return reportId;
    }

    public void setReportId(long reportId) {
        this.reportId = reportId;
    }

    public long getCommentId() {
        return commentId;
    }

    public void setCommentId(long commentId) {
        this.commentId = commentId;
    }

    public int getReporterUserId() {
        return reporterUserId;
    }

    public void setReporterUserId(int reporterUserId) {
        this.reporterUserId = reporterUserId;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Timestamp getReportTime() {
        return reportTime;
    }

    public void setReportTime(Timestamp reportTime) {
        this.reportTime = reportTime;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getReporterFullName() {
        return reporterFullName;
    }

    public void setReporterFullName(String reporterFullName) {
        this.reporterFullName = reporterFullName;
    }

    public String getCommentContent() {
        return commentContent;
    }

    public void setCommentContent(String commentContent) {
        this.commentContent = commentContent;
    }

    public String getCommentUserFullName() {
        return commentUserFullName;
    }

    public void setCommentUserFullName(String commentUserFullName) {
        this.commentUserFullName = commentUserFullName;
    }
}