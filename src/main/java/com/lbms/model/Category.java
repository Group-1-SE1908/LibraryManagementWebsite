package com.lbms.model;

public class Category {
    private long id;
    private String name;

    public Category() {
    }

    public Category(long id, String name) {
        this.id = id;
        this.name = name;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    /** @deprecated Use {@link #getId()} */
    @Deprecated
    public long getCategoryId() {
        return id;
    }

    /** @deprecated Use {@link #setId(long)} */
    @Deprecated
    public void setCategoryId(long categoryId) {
        this.id = categoryId;
    }

    /** @deprecated Use {@link #getName()} */
    @Deprecated
    public String getCategoryName() {
        return name;
    }

    /** @deprecated Use {@link #setName(String)} */
    @Deprecated
    public void setCategoryName(String categoryName) {
        this.name = categoryName;
    }
}