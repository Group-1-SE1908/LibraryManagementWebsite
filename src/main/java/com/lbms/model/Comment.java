package com.lbms.model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Comment {
    // Thuộc tính của các thành phần trong comment
    private long commentId;
    private int bookId;
    private int userId;
    private String content;
    private int rating;
    private String status;
    private Timestamp createdAt;
    private Timestamp deletedAt;
    private Timestamp updatedAt;
    //Thuộc tính của name và avatar để hiển thị thông tin;
    private String fullName;
    private String avatar;
    // Danh sách replies từ thủ thư
    private List<CommentReply>replies =new ArrayList<>();

    public long getCommentId() {
        return commentId;
    }

    public void setCommentId(long commentId) {
        this.commentId = commentId;
    }

    public String getAvatar() {
        return avatar;
    }

    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getBookId() {
        return bookId;
    }

    public void setBookId(int bookId) {
        this.bookId = bookId;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public Timestamp getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(Timestamp deletedAt) {
        this.deletedAt = deletedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public int getUserId() {
        return userId;
    }


    public void setUserId(int userId) {
        this.userId = userId;
    }

    public List<CommentReply> getReplies() {
        return replies;
    }

    public void setReplies(List<CommentReply> replies) {
        this.replies = replies;
    }

    public boolean getHasReply() {
        return replies != null && !replies.isEmpty();
    }

    public boolean isHasReply() {
        return replies != null && !replies.isEmpty();
    }
}