package com.lbms.service;

import com.lbms.dao.BorrowDAO;
import com.lbms.dao.ShipmentDAO;
import com.lbms.model.BorrowRecord;
import com.lbms.model.Shipment;

import java.sql.SQLException;

public class ShippingService {
    private final ShipmentDAO shipmentDAO;
    private final BorrowDAO borrowDAO;
    private final GHTKService ghtkService;

    public ShippingService() {
        this.shipmentDAO = new ShipmentDAO();
        this.borrowDAO = new BorrowDAO();
        this.ghtkService = new GHTKService();
    }

    public long createShipment(long borrowRecordId, String address, String phone) throws SQLException {
        if (address == null || address.isBlank()) throw new IllegalArgumentException("Địa chỉ không hợp lệ");
        if (phone == null || phone.isBlank()) throw new IllegalArgumentException("SĐT không hợp lệ");

        BorrowRecord br = borrowDAO.findById(borrowRecordId);
        if (br == null) throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        if (!"BORROWED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ tạo giao hàng khi phiếu đang BORROWED");
        }

        Shipment existing = shipmentDAO.findByBorrowRecordId(borrowRecordId);
        if (existing != null) {
            throw new IllegalArgumentException("Phiếu mượn này đã có đơn giao hàng");
        }

        long shipmentId = shipmentDAO.create(borrowRecordId, address.trim(), phone.trim());

        // gọi GHTK (hoặc mock) để lấy mã vận đơn
        String tracking = ghtkService.createOrder(address.trim(), phone.trim(), "Giao sách LBMS");
        shipmentDAO.updateTracking(shipmentId, tracking, "CREATED");

        return shipmentId;
    }

    public Shipment refreshStatus(long shipmentId) throws SQLException {
        Shipment s = shipmentDAO.findById(shipmentId);
        if (s == null) throw new IllegalArgumentException("Shipment không tồn tại");

        String tracking = s.getTrackingCode();
        String st = ghtkService.getStatus(tracking);
        if (st != null && !st.isBlank()) {
            shipmentDAO.updateStatus(shipmentId, st);
            s.setStatus(st);
        }

        return s;
    }
}
