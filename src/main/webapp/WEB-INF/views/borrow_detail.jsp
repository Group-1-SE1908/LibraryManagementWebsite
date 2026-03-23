<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Chi tiết đơn mượn #${record.id} - LBMS</title>
  <style>
    /* Dùng lại CSS của trang danh sách cho đồng bộ */
    :root { --primary: #0d6efd; --bg: #f8f9fa; --text: #212529; --border: #dee2e6; }
    body { font-family: 'Segoe UI', Arial, sans-serif; background: var(--bg); color: var(--text); max-width: 900px; margin: 40px auto; line-height: 1.6; }
    .container { background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); padding: 30px; }
    .card { border: 1px solid var(--border); border-radius: 8px; padding: 20px; margin-bottom: 20px; }
    h3 { margin-top: 0; color: #2c3e50; border-bottom: 2px solid var(--primary); display: inline-block; padding-bottom: 5px; }
    .row { display: flex; flex-wrap: wrap; margin-bottom: 10px; }
    .label { font-weight: 600; width: 150px; color: #495057; }
    .value { flex: 1; color: #212529; }
    .btn { display: inline-block; padding: 8px 16px; border-radius: 6px; text-decoration: none; font-weight: 600; background: #e9ecef; color: #495057; }
    .tag { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 13px; font-weight: 700; background: #cff4fc; color: #055160; }
  </style>
</head>
<body>
  <div class="container">
    <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom: 20px;">
        <h2>📄 Chi tiết đơn mượn #${record.id}</h2>
        <a class="btn" href="${pageContext.request.contextPath}/borrow/history">⬅ Quay lại danh sách</a>
    </div>

    <div class="card">
        <h3>👤 Thông tin cá nhân</h3>
        <div class="row"><div class="label">Người mượn:</div><div class="value">${record.user.fullName}</div></div>
        <div class="row"><div class="label">Email:</div><div class="value">${record.user.email}</div></div>
        <div class="row"><div class="label">Số điện thoại:</div><div class="value">${record.user.phone != null ? record.user.phone : '<i style="color:#999">Chưa cập nhật</i>'}</div></div>
        <div class="row"><div class="label">Địa chỉ:</div><div class="value">${record.user.address != null ? record.user.address : '<i style="color:#999">Chưa cập nhật</i>'}</div></div>
    </div>

    <div class="card">
        <h3>📚 Thông tin sách</h3>
        <div class="row"><div class="label">Tựa sách:</div><div class="value"><strong>${record.book.title}</strong></div></div>
        <div class="row"><div class="label">Tác giả:</div><div class="value">${record.book.author}</div></div>
        <div class="row"><div class="label">Mã ISBN:</div><div class="value">${record.book.isbn}</div></div>
        <div class="row"><div class="label">Mã vạch (Bản sao):</div><div class="value">${record.bookCopy != null && record.bookCopy.barcode != null ? record.bookCopy.barcode : '<i style="color:#999">Chưa gán sách vật lý</i>'}</div></div>
    </div>

    <div class="card">
        <h3>🕒 Trạng thái giao dịch</h3>
        <div class="row"><div class="label">Phương thức:</div><div class="value">
            ${record.borrowMethod == 'ONLINE' ? '🛒 Đặt Online (Giao hàng)' : '🏢 Trực tiếp tại thư viện'}
        </div></div>
        <div class="row"><div class="label">Trạng thái hiện tại:</div><div class="value"><span class="tag">${record.status}</span></div></div>
        <div class="row"><div class="label">Ngày đặt/mượn:</div><div class="value">${record.borrowDate != null ? record.borrowDate : 'Chưa duyệt'}</div></div>
        <div class="row"><div class="label">Hạn trả:</div><div class="value">${record.dueDate != null ? record.dueDate : '-'}</div></div>
        <div class="row"><div class="label">Ngày trả thực tế:</div><div class="value">${record.returnDate != null ? record.returnDate : 'Chưa trả'}</div></div>
        <div class="row"><div class="label">Tiền phạt:</div><div class="value" style="color:red; font-weight:bold;">${record.fineAmount} VNĐ</div></div>
    </div>
  </div>
</body>
</html>