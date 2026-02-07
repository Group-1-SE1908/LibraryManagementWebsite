package com.lbms.dao;

import com.lbms.model.BorrowRecord;
import com.lbms.model.Shipment;
import com.lbms.util.DBConnection;

import java.sql.*;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

public class ShipmentDAO {

    public Shipment findByBorrowRecordId(long borrowRecordId) throws SQLException {
        String sql = baseSelect() + " WHERE s.borrow_record_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, borrowRecordId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapOne(rs);
            }
        }
    }

    public Shipment findById(long id) throws SQLException {
        String sql = baseSelect() + " WHERE s.id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) return null;
                return mapOne(rs);
            }
        }
    }

    public long create(long borrowRecordId, String address, String phone) throws SQLException {
        String sql = "INSERT INTO shipments(borrow_record_id, tracking_code, status, address, phone) VALUES(?, NULL, 'CREATED', ?, ?)";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, borrowRecordId);
            ps.setString(2, address);
            ps.setString(3, phone);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getLong(1);
                return 0;
            }
        }
    }

    public void updateTracking(long shipmentId, String trackingCode, String status) throws SQLException {
        String sql = "UPDATE shipments SET tracking_code=?, status=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, trackingCode);
            ps.setString(2, status);
            ps.setLong(3, shipmentId);
            ps.executeUpdate();
        }
    }

    public void updateStatus(long shipmentId, String status) throws SQLException {
        String sql = "UPDATE shipments SET status=? WHERE id=?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setLong(2, shipmentId);
            ps.executeUpdate();
        }
    }

    public List<Shipment> listAll() throws SQLException {
        String sql = baseSelect() + " ORDER BY s.id DESC";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            List<Shipment> out = new ArrayList<>();
            while (rs.next()) out.add(mapOne(rs));
            return out;
        }
    }

    private String baseSelect() {
        return "SELECT s.id, s.borrow_record_id, s.tracking_code, s.status, s.address, s.phone, s.created_at, s.updated_at, " +
                "br.status AS br_status " +
                "FROM shipments s JOIN borrow_records br ON s.borrow_record_id = br.id";
    }

    private Shipment mapOne(ResultSet rs) throws SQLException {
        Shipment s = new Shipment();
        s.setId(rs.getLong("id"));
        s.setTrackingCode(rs.getString("tracking_code"));
        s.setStatus(rs.getString("status"));
        s.setAddress(rs.getString("address"));
        s.setPhone(rs.getString("phone"));

        Timestamp cts = rs.getTimestamp("created_at");
        Timestamp uts = rs.getTimestamp("updated_at");
        s.setCreatedAt(cts == null ? null : cts.toInstant());
        s.setUpdatedAt(uts == null ? null : uts.toInstant());

        BorrowRecord br = new BorrowRecord();
        br.setId(rs.getLong("borrow_record_id"));
        br.setStatus(rs.getString("br_status"));
        s.setBorrowRecord(br);

        return s;
    }
}
