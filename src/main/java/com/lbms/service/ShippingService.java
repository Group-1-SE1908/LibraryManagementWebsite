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

        // 1. Lấy thông tin phiếu mượn lên
        BorrowRecord br = borrowDAO.findById(borrowRecordId);
        if (br == null) throw new IllegalArgumentException("Phiếu mượn không tồn tại");
        
        // (Tùy chọn) Có thể sửa lại trạng thái check, ví dụ APPROVED hoặc BORROWED đều được giao
        if (!"APPROVED".equalsIgnoreCase(br.getStatus()) && !"BORROWED".equalsIgnoreCase(br.getStatus())) {
            throw new IllegalArgumentException("Chỉ tạo giao hàng khi phiếu đã được duyệt (APPROVED) hoặc đang mượn (BORROWED)");
        }

        Shipment existing = shipmentDAO.findByBorrowRecordId(borrowRecordId);
        if (existing != null) {
            throw new IllegalArgumentException("Phiếu mượn này đã có đơn giao hàng");
        }

        // 2. Tạo record Shipment trong Database trước
        long shipmentId = shipmentDAO.create(borrowRecordId, address.trim(), phone.trim());

        // 3. Tính tổng trọng lượng (giả định 1 cuốn 500g)
        int totalWeight = br.getQuantity() * 500;

        // 4. Gọi GHTK (Dùng hàm mới thiết kế truyền thẳng đối tượng BorrowRecord vào)
        String tracking = ghtkService.createOrder(br, totalWeight);
        
        // 5. Cập nhật mã Tracking vào DB
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
    public void createGroupShipment(String groupCode) throws SQLException {
        com.lbms.dao.LibrarianBorrowDAO libDAO = new com.lbms.dao.LibrarianBorrowDAO();
        java.util.List<BorrowRecord> groupRecords = libDAO.findByGroupCode(groupCode);

        if (groupRecords == null || groupRecords.isEmpty()) {
            throw new IllegalArgumentException("Không tìm thấy dữ liệu phiếu mượn.");
        }

        // Lấy địa chỉ giao hàng từ cuốn sách đầu tiên (do mượn chung 1 lần nên địa chỉ giống nhau)
        BorrowRecord firstRecord = groupRecords.get(0);

        // Tính tổng trọng lượng tất cả các sách (1 cuốn = 500g)
        int totalWeight = 0;
        for (BorrowRecord br : groupRecords) {
            totalWeight += (br.getQuantity() * 500); 
        }

        // 1. GỌI API GHTK DUY NHẤT 1 LẦN CHO CẢ NHÓM
        String trackingCode = ghtkService.createOrder(firstRecord, totalWeight);

        // 2. Lưu lại mã Tracking cho từng sách trong DB & Cập nhật trạng thái
        for (BorrowRecord br : groupRecords) {
            long shipmentId = shipmentDAO.create(br.getId(), firstRecord.getShippingDetails().getFormattedAddress(), firstRecord.getShippingDetails().getPhone());
            shipmentDAO.updateTracking(shipmentId, trackingCode, "CREATED");
            
            // Chuyển trạng thái phiếu mượn sang đang giao
            libDAO.updateStatus(br.getId(), "SHIPPING");
        }
    }
}