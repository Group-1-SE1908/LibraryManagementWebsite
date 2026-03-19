package com.lbms.dao;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.lbms.model.Book;
import com.lbms.model.BookCopy;
import com.lbms.model.BorrowRecord;
import com.lbms.model.ShippingDetails;
import com.lbms.model.User;
import com.lbms.util.DBConnection;

public class BorrowDAO {

    static {
        ensureRequiredColumns();
    }

    private static void ensureRequiredColumns() {
        try (Connection connection = DBConnection.getConnection()) {
            addColumnIfMissing(connection, "borrow_method",
                    "ALTER TABLE borrow_records ADD borrow_method VARCHAR(20) NULL;");
            addColumnIfMissing(connection, "copy_id", "ALTER TABLE borrow_records ADD copy_id INT NULL;");
            addColumnIfMissing(connection, "shipping_recipient",
                    "ALTER TABLE borrow_records ADD shipping_recipient NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "shipping_phone",
                    "ALTER TABLE borrow_records ADD shipping_phone VARCHAR(30) NULL;");
            addColumnIfMissing(connection, "shipping_street",
                    "ALTER TABLE borrow_records ADD shipping_street NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "shipping_residence",
                    "ALTER TABLE borrow_records ADD shipping_residence NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "shipping_ward",
                    "ALTER TABLE borrow_records ADD shipping_ward NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "shipping_district",
                    "ALTER TABLE borrow_records ADD shipping_district NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "shipping_city",
                    "ALTER TABLE borrow_records ADD shipping_city NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "is_paid", "ALTER TABLE borrow_records ADD is_paid BIT NOT NULL DEFAULT 0;");
            addColumnIfMissing(connection, "deposit_amount",
                    "ALTER TABLE borrow_records ADD deposit_amount DECIMAL(18,2) NULL;");
            addColumnIfMissing(connection, "group_code",
                    "ALTER TABLE borrow_records ADD group_code VARCHAR(100) NULL;");
            backfillLegacyShippingData(connection);
        } catch (SQLException e) {
            throw new RuntimeException("Không thể đồng bộ schema borrow_records", e);
        }
    }

    private static void addColumnIfMissing(Connection connection, String columnName, String ddl) throws SQLException {
        if (BorrowSchemaSupport.columnExists(connection, "borrow_records", columnName)) {
            return;
        }
        try (Statement stmt = connection.createStatement()) {
            stmt.executeUpdate(ddl);
        }
    }

    private static void backfillLegacyShippingData(Connection connection) throws SQLException {
        boolean hasReceiverName = BorrowSchemaSupport.columnExists(connection, "borrow_records", "receiver_name");
        boolean hasReceiverPhone = BorrowSchemaSupport.columnExists(connection, "borrow_records", "receiver_phone");
        boolean hasReceiverAddress = BorrowSchemaSupport.columnExists(connection, "borrow_records", "receiver_address");

        try (Statement stmt = connection.createStatement()) {
            if (hasReceiverName
                    && BorrowSchemaSupport.columnExists(connection, "borrow_records", "shipping_recipient")) {
                stmt.executeUpdate(
                        "UPDATE borrow_records SET shipping_recipient = receiver_name WHERE shipping_recipient IS NULL AND receiver_name IS NOT NULL;");
            }
            if (hasReceiverPhone && BorrowSchemaSupport.columnExists(connection, "borrow_records", "shipping_phone")) {
                stmt.executeUpdate(
                        "UPDATE borrow_records SET shipping_phone = receiver_phone WHERE shipping_phone IS NULL AND receiver_phone IS NOT NULL;");
            }
            if (hasReceiverAddress
                    && BorrowSchemaSupport.columnExists(connection, "borrow_records", "shipping_street")) {
                stmt.executeUpdate(
                        "UPDATE borrow_records SET shipping_street = receiver_address WHERE shipping_street IS NULL AND receiver_address IS NOT NULL;");
            }
        }
    }

    public long createRequest(long userId, long bookId, int quantity, String method, ShippingDetails shippingDetails)
            throws SQLException {
        BigDecimal depositAmount = BigDecimal.valueOf(quantity).multiply(BigDecimal.valueOf(50000L));
        return createRequestInternal(userId, bookId, quantity, method, shippingDetails, null, depositAmount);
    }

    public long createRequest(long userId, long bookId, int quantity, String method,
            ShippingDetails shippingDetails, String groupCode, BigDecimal depositAmount)
            throws SQLException {
        return createRequestInternal(userId, bookId, quantity, method, shippingDetails, groupCode, depositAmount);
    }

    public List<BorrowRecord> listAll() throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " ORDER BY br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public List<BorrowRecord> listByUser(long userId) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " WHERE br.user_id = ? ORDER BY br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }

    public int countActiveBorrows(long userId) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = schema.hasQuantity()
                    ? "SELECT SUM(CASE WHEN quantity IS NULL OR quantity <= 0 THEN 1 ELSE quantity END) AS c FROM borrow_records WHERE user_id = ? AND status IN ('REQUESTED','APPROVED','BORROWED')"
                    : "SELECT COUNT(*) AS c FROM borrow_records WHERE user_id = ? AND status IN ('REQUESTED','APPROVED','BORROWED','SHIPPING','RECEIVED')";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        int total = rs.getInt("c");
                        return rs.wasNull() ? 0 : total;
                    }
                }
            }
        }
        return 0;
    }

    public BorrowRecord findById(long id) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " WHERE br.id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        return null;
                    }
                    return mapOne(rs);
                }
            }
        }
    }

    public void updateStatus(long id, String status) throws SQLException {
        String sql = "UPDATE borrow_records SET status = ? WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, id);
            ps.executeUpdate();
        }
    }

    public void markReturned(long id, LocalDate returnDate, BigDecimal fineAmount) throws SQLException {
        String sql = "UPDATE borrow_records SET status='RETURNED', return_date=?, fine_amount=? WHERE id = ?";
        try (Connection connection = DBConnection.getConnection();
                PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setDate(1, Date.valueOf(returnDate));
            ps.setBigDecimal(2, fineAmount);
            ps.setLong(3, id);
            ps.executeUpdate();
        }
    }

    private String baseSelect(BorrowSchemaSupport.BorrowSchemaInfo schema) {
        return "SELECT br.id AS borrowing_id, br.user_id, br.book_id, "
                + BorrowSchemaSupport.quantityExpression(schema, "quantity") + ", "
                + BorrowSchemaSupport.copyIdExpression(schema) + ", "
                + "br.borrow_date, br.due_date, br.return_date, br.status, br.fine_amount, "
                + BorrowSchemaSupport.depositAmountExpression(schema) + ", "
                + BorrowSchemaSupport.isPaidExpression(schema) + ", "
                + BorrowSchemaSupport.borrowMethodExpression(schema) + ", "
                + "u.email AS user_email, u.full_name AS user_full_name, u.phone AS user_phone, "
                + "bk.title AS book_title, bk.author AS book_author, bk.isbn AS book_isbn, bk.image AS book_image, "
                + BorrowSchemaSupport.shippingRecipientExpression(schema) + ", "
                + BorrowSchemaSupport.shippingPhoneExpression(schema) + ", "
                + BorrowSchemaSupport.shippingStreetExpression(schema) + ", "
                + BorrowSchemaSupport.shippingResidenceExpression(schema) + ", "
                + BorrowSchemaSupport.shippingWardExpression(schema) + ", "
                + BorrowSchemaSupport.shippingDistrictExpression(schema) + ", "
                + BorrowSchemaSupport.shippingCityExpression(schema) + " "
                + "FROM borrow_records br "
                + "JOIN [User] u ON br.user_id = u.user_id "
                + "JOIN Book bk ON br.book_id = bk.book_id";
    }

    private List<BorrowRecord> mapList(ResultSet rs) throws SQLException {
        List<BorrowRecord> out = new ArrayList<>();
        while (rs.next()) {
            out.add(mapOne(rs));
        }
        return out;
    }

    public BorrowRecord mapOne(ResultSet rs) throws SQLException {
        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getLong("borrowing_id"));

        User user = new User();
        user.setId(rs.getLong("user_id"));
        user.setEmail(rs.getString("user_email"));
        user.setFullName(rs.getString("user_full_name"));
        br.setUser(user);

        Book book = new Book();
        book.setId(rs.getLong("book_id"));
        book.setTitle(rs.getString("book_title"));
        book.setAuthor(rs.getString("book_author"));
        book.setImage(rs.getString("book_image"));
        br.setBook(book);

        Date borrowDate = rs.getDate("borrow_date");
        br.setBorrowDate(borrowDate == null ? null : borrowDate.toLocalDate());

        Date returnDate = rs.getDate("return_date");
        br.setReturnDate(returnDate == null ? null : returnDate.toLocalDate());

        Date dueDate = rs.getDate("due_date");
        br.setDueDate(dueDate == null ? null : dueDate.toLocalDate());

        br.setStatus(rs.getString("status"));
        br.setQuantity(rs.getInt("quantity"));
        br.setFineAmount(rs.getBigDecimal("fine_amount"));
        br.setDepositAmount(rs.getBigDecimal("deposit_amount"));
        br.setPaid(rs.getBoolean("is_paid"));
        br.setBorrowMethod(rs.getString("borrow_method"));

        ShippingDetails shipping = new ShippingDetails();
        shipping.setRecipient(rs.getString("shipping_recipient"));
        shipping.setPhone(rs.getString("shipping_phone"));
        shipping.setStreet(rs.getString("shipping_street"));
        shipping.setResidence(rs.getString("shipping_residence"));
        shipping.setWard(rs.getString("shipping_ward"));
        shipping.setDistrict(rs.getString("shipping_district"));
        shipping.setCity(rs.getString("shipping_city"));
        if ((shipping.getRecipient() != null && !shipping.getRecipient().isBlank())
                || (shipping.getPhone() != null && !shipping.getPhone().isBlank())
                || (shipping.getStreet() != null && !shipping.getStreet().isBlank())
                || (shipping.getResidence() != null && !shipping.getResidence().isBlank())
                || (shipping.getWard() != null && !shipping.getWard().isBlank())
                || (shipping.getDistrict() != null && !shipping.getDistrict().isBlank())
                || (shipping.getCity() != null && !shipping.getCity().isBlank())) {
            br.setShippingDetails(shipping);
        }

        String userPhone = rs.getString("user_phone");
        if (userPhone != null && !userPhone.isBlank()) {
            br.getUser().setPhone(userPhone);
        }

        long copyId = rs.getLong("copy_id");
        if (copyId > 0) {
            BookCopy bookCopy = new BookCopy();
            bookCopy.setCopyId((int) copyId);
            br.setBookCopy(bookCopy);
        }

        return br;
    }

    public List<BorrowRecord> listOverdue() throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema)
                    + " WHERE br.status = 'BORROWED' AND br.due_date < GETDATE() ORDER BY br.due_date ASC";
            try (PreparedStatement ps = connection.prepareStatement(sql);
                    ResultSet rs = ps.executeQuery()) {
                return mapList(rs);
            }
        }
    }

    public List<BorrowRecord> listUnpaidFinesByUser(long userId) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema) + " WHERE br.user_id = ? AND br.fine_amount > 0"
                    + (schema.hasIsPaid() ? " AND (br.is_paid = 0 OR br.is_paid IS NULL)" : "")
                    + " ORDER BY br.due_date ASC";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }

    public List<BorrowRecord> listFineHistoryByUser(long userId) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = baseSelect(schema)
                    + " WHERE br.user_id = ? AND br.fine_amount > 0 ORDER BY br.return_date DESC, br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }

    public List<BorrowRecord> listFineRecordsForStaff(String keyword, String paymentStatus) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            StringBuilder sql = new StringBuilder(baseSelect(schema))
                    .append(" WHERE (")
                    .append("(br.fine_amount > 0)")
                    .append(" OR (br.status IN ('BORROWED','RECEIVED') AND br.due_date IS NOT NULL AND br.due_date < CAST(GETDATE() AS DATE))")
                    .append(" OR (br.status = 'RETURNED' AND br.due_date IS NOT NULL AND br.return_date IS NOT NULL AND br.return_date > br.due_date)")
                    .append(")");

            boolean hasKeyword = keyword != null && !keyword.isBlank();
            boolean paidOnly = "PAID".equalsIgnoreCase(paymentStatus);
            boolean unpaidOnly = "UNPAID".equalsIgnoreCase(paymentStatus);

            if (paidOnly && !schema.hasIsPaid()) {
                return new ArrayList<>();
            }

            if (hasKeyword) {
                sql.append(" AND (u.full_name LIKE ? OR bk.title LIKE ? OR CAST(br.id AS VARCHAR(20)) LIKE ?)");
            }
            if (paidOnly) {
                sql.append(" AND br.is_paid = 1 AND br.fine_amount > 0");
            } else if (unpaidOnly && schema.hasIsPaid()) {
                sql.append(" AND (br.is_paid = 0 OR br.is_paid IS NULL)");
            }

            sql.append(" ORDER BY ")
                    .append(schema.hasIsPaid() ? "CASE WHEN br.is_paid = 0 THEN 0 ELSE 1 END" : "0")
                    .append(", br.due_date ASC, br.return_date DESC, br.id DESC");

            try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
                int index = 1;
                if (hasKeyword) {
                    String like = "%" + keyword.trim() + "%";
                    ps.setString(index++, like);
                    ps.setString(index++, like);
                    ps.setString(index++, like);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    return mapList(rs);
                }
            }
        }
    }

    public void markFinePaid(long id) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            if (!schema.hasIsPaid()) {
                return;
            }
            String sql = "UPDATE borrow_records SET is_paid = 1 WHERE id = ? AND fine_amount > 0";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setLong(1, id);
                ps.executeUpdate();
            }
        }
    }

    public void updateFineAmount(long id, BigDecimal fineAmount) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            String sql = schema.hasIsPaid()
                    ? "UPDATE borrow_records SET fine_amount = ?, is_paid = 0 WHERE id = ?"
                    : "UPDATE borrow_records SET fine_amount = ? WHERE id = ?";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setBigDecimal(1, fineAmount);
                ps.setLong(2, id);
                ps.executeUpdate();
            }
        }
    }

    public List<BorrowRecord> listByMethod(String method) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            if (!schema.hasBorrowMethod()) {
                return new ArrayList<>();
            }
            String sql = baseSelect(schema) + " WHERE br.borrow_method = ? ORDER BY br.id DESC";
            try (PreparedStatement ps = connection.prepareStatement(sql)) {
                ps.setString(1, method);
                try (ResultSet rs = ps.executeQuery()) {
                    List<BorrowRecord> out = new ArrayList<>();
                    while (rs.next()) {
                        out.add(mapOne(rs));
                    }
                    return out;
                }
            }
        }
    }

    private long createRequestInternal(long userId, long bookId, int quantity, String method,
            ShippingDetails shippingDetails, String groupCode, BigDecimal depositAmount) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            BorrowSchemaSupport.BorrowSchemaInfo schema = BorrowSchemaSupport.inspect(connection);
            List<String> columns = new ArrayList<>();
            List<Object> values = new ArrayList<>();
            List<Integer> sqlTypes = new ArrayList<>();

            addInsertField(columns, values, sqlTypes, "user_id", userId, Types.BIGINT);
            addInsertField(columns, values, sqlTypes, "book_id", bookId, Types.BIGINT);
            if (schema.hasQuantity()) {
                addInsertField(columns, values, sqlTypes, "quantity", quantity, Types.INTEGER);
            }
            if (schema.hasBorrowMethod()) {
                addInsertField(columns, values, sqlTypes, "borrow_method", normalizeText(method), Types.VARCHAR);
            }
            addInsertField(columns, values, sqlTypes, "status", "REQUESTED", Types.VARCHAR);
            if (schema.hasGroupCode() && groupCode != null) {
                addInsertField(columns, values, sqlTypes, "group_code", normalizeText(groupCode), Types.VARCHAR);
            }
            if (schema.hasDepositAmount()) {
                addInsertField(columns, values, sqlTypes, "deposit_amount", depositAmount, Types.DECIMAL);
            }

            String recipient = shippingDetails != null ? normalizeText(shippingDetails.getRecipient()) : null;
            String phone = shippingDetails != null ? normalizeText(shippingDetails.getPhone()) : null;
            String street = shippingDetails != null ? normalizeText(shippingDetails.getStreet()) : null;
            String residence = shippingDetails != null ? normalizeText(shippingDetails.getResidence()) : null;
            String ward = shippingDetails != null ? normalizeText(shippingDetails.getWard()) : null;
            String district = shippingDetails != null ? normalizeText(shippingDetails.getDistrict()) : null;
            String city = shippingDetails != null ? normalizeText(shippingDetails.getCity()) : null;
            String receiverAddress = shippingDetails != null ? normalizeText(shippingDetails.getFormattedAddress())
                    : null;

            if (schema.hasShippingRecipient()) {
                addInsertField(columns, values, sqlTypes, "shipping_recipient", recipient, Types.NVARCHAR);
            }
            if (schema.hasReceiverName()) {
                addInsertField(columns, values, sqlTypes, "receiver_name", recipient, Types.NVARCHAR);
            }
            if (schema.hasShippingPhone()) {
                addInsertField(columns, values, sqlTypes, "shipping_phone", phone, Types.VARCHAR);
            }
            if (schema.hasReceiverPhone()) {
                addInsertField(columns, values, sqlTypes, "receiver_phone", phone, Types.VARCHAR);
            }
            if (schema.hasShippingStreet()) {
                addInsertField(columns, values, sqlTypes, "shipping_street", street, Types.NVARCHAR);
            }
            if (schema.hasReceiverAddress()) {
                addInsertField(columns, values, sqlTypes, "receiver_address", receiverAddress, Types.NVARCHAR);
            }
            if (schema.hasShippingResidence()) {
                addInsertField(columns, values, sqlTypes, "shipping_residence", residence, Types.NVARCHAR);
            }
            if (schema.hasShippingWard()) {
                addInsertField(columns, values, sqlTypes, "shipping_ward", ward, Types.NVARCHAR);
            }
            if (schema.hasShippingDistrict()) {
                addInsertField(columns, values, sqlTypes, "shipping_district", district, Types.NVARCHAR);
            }
            if (schema.hasShippingCity()) {
                addInsertField(columns, values, sqlTypes, "shipping_city", city, Types.NVARCHAR);
            }

            String placeholders = String.join(", ", Collections.nCopies(columns.size(), "?"));
            String sql = "INSERT INTO borrow_records (" + String.join(", ", columns) + ") VALUES (" + placeholders
                    + ")";

            try (PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                bindInsertParameters(ps, values, sqlTypes);
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    return rs.next() ? rs.getLong(1) : 0;
                }
            }
        }
    }

    private static String normalizeText(String value) {
        return value == null || value.isBlank() ? null : value;
    }

    private void addInsertField(List<String> columns, List<Object> values, List<Integer> sqlTypes, String column,
            Object value, int sqlType) {
        columns.add(column);
        values.add(value);
        sqlTypes.add(sqlType);
    }

    private void bindInsertParameters(PreparedStatement ps, List<Object> values, List<Integer> sqlTypes)
            throws SQLException {
        for (int i = 0; i < values.size(); i++) {
            int parameterIndex = i + 1;
            Object value = values.get(i);
            int sqlType = sqlTypes.get(i);

            if (value == null) {
                ps.setNull(parameterIndex, sqlType);
            } else if (value instanceof String) {
                ps.setString(parameterIndex, (String) value);
            } else if (value instanceof Integer) {
                ps.setInt(parameterIndex, (Integer) value);
            } else if (value instanceof Long) {
                ps.setLong(parameterIndex, (Long) value);
            } else if (value instanceof BigDecimal) {
                ps.setBigDecimal(parameterIndex, (BigDecimal) value);
            } else {
                ps.setObject(parameterIndex, value);
            }
        }
    }
}