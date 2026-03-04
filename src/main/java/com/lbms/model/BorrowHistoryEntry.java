package com.lbms.model;

public class BorrowHistoryEntry {

    private final BorrowRecord record;
    private final int copyIndex;
    private final int copyCount;

    public BorrowHistoryEntry(BorrowRecord record, int copyIndex, int copyCount) {
        if (record == null) {
            throw new IllegalArgumentException("record must not be null");
        }
        this.record = record;
        this.copyIndex = copyIndex;
        this.copyCount = copyCount;
    }

    public BorrowRecord getRecord() {
        return record;
    }

    public int getCopyIndex() {
        return copyIndex;
    }

    public int getCopyCount() {
        return copyCount;
    }

    public boolean isMultiCopy() {
        return copyCount > 1;
    }
}
