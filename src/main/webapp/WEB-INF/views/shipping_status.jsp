<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Trạng thái giao hàng - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:900px;margin:30px auto;padding:0 16px;}
    .card{border:1px solid #ddd;border-radius:10px;padding:18px;}
    .row{margin:10px 0;}
    a.btn, button{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;cursor:pointer;}
    .tag{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ddd;font-size:12px;}
    .muted{color:#666;}
  </style>
</head>
<body>
  <h2>LBMS - Trạng thái giao hàng</h2>

  <div class="card">
    <div class="row">Shipment ID: <strong>${shipment.id}</strong></div>
    <div class="row">Borrow ID: <strong>${shipment.borrowRecord.id}</strong></div>
    <div class="row">Tracking: <span class="tag">${shipment.trackingCode}</span></div>
    <div class="row">Status: <span class="tag">${shipment.status}</span></div>
    <div class="row">Địa chỉ: <span class="muted">${shipment.address}</span></div>
    <div class="row">SĐT: <span class="muted">${shipment.phone}</span></div>

    <div class="row">
      <a class="btn" href="${pageContext.request.contextPath}/shipping/status?id=${shipment.id}">Refresh</a>
      <a class="btn" href="${pageContext.request.contextPath}/shipping">Danh sách shipment</a>
      <a class="btn" href="${pageContext.request.contextPath}/borrow">Quay lại mượn/trả</a>
    </div>

    <div class="row muted">
      Nếu bạn chưa cấu hình GHTK Token, trạng thái sẽ ở dạng giả lập.
    </div>
  </div>
</body>
</html>
