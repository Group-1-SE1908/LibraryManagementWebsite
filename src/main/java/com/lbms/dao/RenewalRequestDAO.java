package com.lbms.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.lbms.model.RenewalRequest;
import com.lbms.util.BorrowSchemaSupport;
import com.lbms.util.DBConnection;

public class RenewalRequestDAO {

    static {
        ensureSchema();
    }

    private static void ensureSchema() {
        try (Connection connection = DBConnection.getConnection()) {
            if (!tableExists(connection, "renewal_requests")) {
                try (Statement stmt = connection.createStatement()) {
                    stmt.executeUpdate("CREATE TABLE renewal_requests ("
                            + "id BIGINT IDENTITY(1,1) PRIMARY KEY, "
                            + "borrow_id BIGINT NOT NULL, "
                            + "user_id INT NOT NULL, "
                            + "reason NVARCHAR(1000) NOT NULL, "
                            + "contact_name NVARCHAR(255) NULL, "
                            + "contact_phone VARCHAR(30) NULL, "
                            + "contact_email VARCHAR(255) NULL, "
                            + "status VARCHAR(20) NOT NULL DEFAULT 'PENDING', "
                            + "rejection_reason NVARCHAR(1000) NULL, "
                            + "requested_at DATETIME NOT NULL DEFAULT GETDATE(), "
                            + "CONSTRAINT FK_RenewalRequest_Borrow FOREIGN KEY (borrow_id) REFERENCES borrow_records(id), "
                            + "CONSTRAINT FK_RenewalRequest_User FOREIGN KEY (user_id) REFERENCES [User](user_id)"
                            + ")");
                    stmt.executeUpdate("CREATE INDEX IX_RenewalRequest_BorrowId ON renewal_requests (borrow_id)");
                    stmt.executeUpdate("CREATE INDEX IX_RenewalRequest_Status ON renewal_requests (status)");
                }
                return;
            }

            addColumnIfMissing(connection, "borrow_id", "ALTER TABLE renewal_requests ADD borrow_id BIGINT NULL;");
            addColumnIfMissing(connection, "user_id", "ALTER TABLE renewal_requests ADD user_id INT NULL;");
            addColumnIfMissing(connection, "reason", "ALTER TABLE renewal_requests ADD reason NVARCHAR(1000) NULL;");
            addColumnIfMissing(connection, "contact_name",
                    "ALTER TABLE renewal_requests ADD contact_name NVARCHAR(255) NULL;");
            addColumnIfMissing(connection, "contact_phone",
                    "ALTER TABLE renewal_requests ADD contact_phone VARCHAR(30) NULL;");
            addColumnIfMissing(connection, "contact_email",
                    "ALTER TABLE renewal_requests ADD contact_email VARCHAR(255) NULL;");
            addColumnIfMissing(connection, "status",
                    "ALTER TABLE renewal_requests ADD status VARCHAR(20) NOT NULL DEFAULT 'PENDING';");
            addColumnIfMissing(connection, "rejection_reason",
                    "ALTER TABLE renewal_requests ADD rejection_reason NVARCHAR(1000) NULL;");
            addColumnIfMissing(connection, "requested_at",
                    "ALTER TABLE renewal_requests ADD requested_at DATETIME NOT NULL DEFAULT GETDATE();");
        } catch (SQLException e) {
            throw new RuntimeException("Không thể đồng bộ schema renewal_requests", e);
        }
    }

    private static boolean tableExists(Connection connection, String tableName) throws SQLException {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_NAME = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, tableName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private static void addColumnIfMissing(Connection connection, String columnName, String ddl) throws SQLException {
        if (BorrowSchemaSupport.columnExists(connection, "renewal_requests", columnName)) {
            return;
        }
        try (Statement stmt = connection.createStatement()) {
            stmt.executeUpdate(ddl);
        }
    }

    public long createRequest(long borrowId, long userId, String reason, String contactName, String contactPhone,
            String contactEmail) throws SQLException {
        String sql = "INSERT INTO renewal_requests (borrow_id, user_id, reason, contact_name, contact_phone, contact_email) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, borrowId);
            ps.setLong(2, userId);
            ps.setString(3, reason);
            ps.setString(4, contactName);
            ps.setString(5, contactPhone);
            ps.setString(6, contactEmail);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        }
        return 0;
    }

    public boolean existsPendingForBorrow(long borrowId) throws SQLException {
        String sql = "SELECT 1 FROM renewal_requests WHERE borrow_id = ? AND status = 'PENDING'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    public List<RenewalRequest> listByBorrowId(long borrowId) throws SQLException {
        List<RenewalRequest> out = new ArrayList<>();
        String sql = "SELECT * FROM renewal_requests WHERE borrow_id = ? ORDER BY requested_at DESC";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(mapRow(rs));
                }
            }
        }
        return out;
    }

    public List<RenewalRequest> listPending() throws SQLException {
        List<RenewalRequest> out = new ArrayList<>();
        String sql = "SELECT * FROM renewal_requests WHERE status = 'PENDING' ORDER BY requested_at DESC";
        try (Connection c = DBConnection.getConnection();
                PreparedStatement ps = c.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                out.add(mapRow(rs));
            }
        }
        return out;
    }

    public RenewalRequest findById(long id) throws SQLException {
        String sql = "SELECT * FROM renewal_requests WHERE id = ?";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public int cancelPendingForBorrow(long borrowId) throws SQLException {
        String sql = "UPDATE renewal_requests SET status = 'CANCELLED' WHERE borrow_id = ? AND status = 'PENDING'";
        try (Connection c = DBConnection.getConnection(); PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowId);
            return ps.executeUpdate();
        }
    }

    private RenewalRequest mapRow(ResultSet rs) throws SQLException {
        RenewalRequest request = new RenewalRequest();
        request.setId(rs.getLong("id"));
        request.setBorrowId(rs.getLong("borrow_id"));
        request.setUserId(rs.getLong("user_id"));
        request.setReason(rs.getString("reason"));
        request.setContactName(rs.getString("contact_name"));
        request.setContactPhone(rs.getString("contact_phone"));
        request.setContactEmail(rs.getString("contact_email"));
        request.setStatus(rs.getString("status"));
        java.sql.Timestamp ts = rs.getTimestamp("requested_at");
        if (ts != null) {
            request.setRequestedAt(ts.toLocalDateTime());
        }
        request.setRejectionReason(rs.getString("rejection_reason"));
        return request;
    }
}
