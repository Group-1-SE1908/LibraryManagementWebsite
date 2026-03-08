package com.lbms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

final class BorrowSchemaSupport {

    private BorrowSchemaSupport() {
    }

    static BorrowSchemaInfo inspect(Connection connection) throws SQLException {
        return new BorrowSchemaInfo(
                columnExists(connection, "borrow_records", "copy_id"),
                columnExists(connection, "borrow_records", "quantity"),
                columnExists(connection, "borrow_records", "borrow_method"),
                columnExists(connection, "borrow_records", "deposit_amount"),
                columnExists(connection, "borrow_records", "is_paid"),
                columnExists(connection, "borrow_records", "group_code"),
                columnExists(connection, "borrow_records", "shipping_recipient"),
                columnExists(connection, "borrow_records", "shipping_phone"),
                columnExists(connection, "borrow_records", "shipping_street"),
                columnExists(connection, "borrow_records", "shipping_residence"),
                columnExists(connection, "borrow_records", "shipping_ward"),
                columnExists(connection, "borrow_records", "shipping_district"),
                columnExists(connection, "borrow_records", "shipping_city"),
                columnExists(connection, "borrow_records", "receiver_name"),
                columnExists(connection, "borrow_records", "receiver_phone"),
                columnExists(connection, "borrow_records", "receiver_address"));
    }

    static boolean columnExists(Connection connection, String tableName, String columnName) throws SQLException {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    static String copyIdExpression(BorrowSchemaInfo schema) {
        return schema.hasCopyId() ? "br.copy_id AS copy_id" : "CAST(NULL AS INT) AS copy_id";
    }

    static String quantityExpression(BorrowSchemaInfo schema, String alias) {
        return schema.hasQuantity() ? "br.quantity AS " + alias : "CAST(1 AS INT) AS " + alias;
    }

    static String borrowMethodExpression(BorrowSchemaInfo schema) {
        return schema.hasBorrowMethod()
                ? "br.borrow_method AS borrow_method"
                : "CAST('IN_PERSON' AS VARCHAR(20)) AS borrow_method";
    }

    static String depositAmountExpression(BorrowSchemaInfo schema) {
        return schema.hasDepositAmount()
                ? "br.deposit_amount AS deposit_amount"
                : "CAST(NULL AS DECIMAL(18,2)) AS deposit_amount";
    }

    static String isPaidExpression(BorrowSchemaInfo schema) {
        return schema.hasIsPaid() ? "br.is_paid AS is_paid" : "CAST(0 AS BIT) AS is_paid";
    }

    static String groupCodeExpression(BorrowSchemaInfo schema) {
        return schema.hasGroupCode()
                ? "br.group_code AS group_code"
                : "CAST(NULL AS VARCHAR(100)) AS group_code";
    }

    static String shippingRecipientExpression(BorrowSchemaInfo schema) {
        return preferredTextExpression(
                schema.hasShippingRecipient(),
                "br.shipping_recipient",
                schema.hasReceiverName(),
                "br.receiver_name",
                "shipping_recipient",
                "NVARCHAR(255)");
    }

    static String shippingPhoneExpression(BorrowSchemaInfo schema) {
        return preferredTextExpression(
                schema.hasShippingPhone(),
                "br.shipping_phone",
                schema.hasReceiverPhone(),
                "br.receiver_phone",
                "shipping_phone",
                "VARCHAR(30)");
    }

    static String shippingStreetExpression(BorrowSchemaInfo schema) {
        return preferredTextExpression(
                schema.hasShippingStreet(),
                "br.shipping_street",
                schema.hasReceiverAddress(),
                "br.receiver_address",
                "shipping_street",
                "NVARCHAR(500)");
    }

    static String shippingResidenceExpression(BorrowSchemaInfo schema) {
        return schema.hasShippingResidence()
                ? "br.shipping_residence AS shipping_residence"
                : "CAST(NULL AS NVARCHAR(255)) AS shipping_residence";
    }

    static String shippingWardExpression(BorrowSchemaInfo schema) {
        return schema.hasShippingWard()
                ? "br.shipping_ward AS shipping_ward"
                : "CAST(NULL AS NVARCHAR(255)) AS shipping_ward";
    }

    static String shippingDistrictExpression(BorrowSchemaInfo schema) {
        return schema.hasShippingDistrict()
                ? "br.shipping_district AS shipping_district"
                : "CAST(NULL AS NVARCHAR(255)) AS shipping_district";
    }

    static String shippingCityExpression(BorrowSchemaInfo schema) {
        return schema.hasShippingCity()
                ? "br.shipping_city AS shipping_city"
                : "CAST(NULL AS NVARCHAR(255)) AS shipping_city";
    }

    private static String preferredTextExpression(boolean hasPrimary, String primaryExpression, boolean hasFallback,
            String fallbackExpression, String alias, String sqlType) {
        if (hasPrimary && hasFallback) {
            return "COALESCE(" + primaryExpression + ", " + fallbackExpression + ") AS " + alias;
        }
        if (hasPrimary) {
            return primaryExpression + " AS " + alias;
        }
        if (hasFallback) {
            return fallbackExpression + " AS " + alias;
        }
        return "CAST(NULL AS " + sqlType + ") AS " + alias;
    }

    static final class BorrowSchemaInfo {
        private final boolean copyId;
        private final boolean quantity;
        private final boolean borrowMethod;
        private final boolean depositAmount;
        private final boolean isPaid;
        private final boolean groupCode;
        private final boolean shippingRecipient;
        private final boolean shippingPhone;
        private final boolean shippingStreet;
        private final boolean shippingResidence;
        private final boolean shippingWard;
        private final boolean shippingDistrict;
        private final boolean shippingCity;
        private final boolean receiverName;
        private final boolean receiverPhone;
        private final boolean receiverAddress;

        private BorrowSchemaInfo(boolean copyId, boolean quantity, boolean borrowMethod, boolean depositAmount,
                boolean isPaid, boolean groupCode, boolean shippingRecipient, boolean shippingPhone,
                boolean shippingStreet, boolean shippingResidence, boolean shippingWard, boolean shippingDistrict,
                boolean shippingCity, boolean receiverName, boolean receiverPhone, boolean receiverAddress) {
            this.copyId = copyId;
            this.quantity = quantity;
            this.borrowMethod = borrowMethod;
            this.depositAmount = depositAmount;
            this.isPaid = isPaid;
            this.groupCode = groupCode;
            this.shippingRecipient = shippingRecipient;
            this.shippingPhone = shippingPhone;
            this.shippingStreet = shippingStreet;
            this.shippingResidence = shippingResidence;
            this.shippingWard = shippingWard;
            this.shippingDistrict = shippingDistrict;
            this.shippingCity = shippingCity;
            this.receiverName = receiverName;
            this.receiverPhone = receiverPhone;
            this.receiverAddress = receiverAddress;
        }

        boolean hasCopyId() {
            return copyId;
        }

        boolean hasQuantity() {
            return quantity;
        }

        boolean hasBorrowMethod() {
            return borrowMethod;
        }

        boolean hasDepositAmount() {
            return depositAmount;
        }

        boolean hasIsPaid() {
            return isPaid;
        }

        boolean hasGroupCode() {
            return groupCode;
        }

        boolean hasShippingRecipient() {
            return shippingRecipient;
        }

        boolean hasShippingPhone() {
            return shippingPhone;
        }

        boolean hasShippingStreet() {
            return shippingStreet;
        }

        boolean hasShippingResidence() {
            return shippingResidence;
        }

        boolean hasShippingWard() {
            return shippingWard;
        }

        boolean hasShippingDistrict() {
            return shippingDistrict;
        }

        boolean hasShippingCity() {
            return shippingCity;
        }

        boolean hasReceiverName() {
            return receiverName;
        }

        boolean hasReceiverPhone() {
            return receiverPhone;
        }

        boolean hasReceiverAddress() {
            return receiverAddress;
        }
    }
}