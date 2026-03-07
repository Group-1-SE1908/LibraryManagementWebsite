<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Tạo đơn giao sách - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:900px;margin:30px auto;padding:0 16px;}
    .card{border:1px solid #ddd;border-radius:10px;padding:18px;}
    .row{margin:10px 0;}
    label{display:block;margin-bottom:6px;}
    input,textarea{width:100%;padding:10px;border:1px solid #ccc;border-radius:8px;}
    button,a.btn{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;cursor:pointer;}
    .err{color:#b00020;margin:10px 0;}
    .muted{color:#666;}
  </style>
</head>
<body>
  <h2>LBMS - Tạo đơn giao sách</h2>

  <div class="card">
    <div class="row muted">
      Borrow ID: <strong>${borrow.id}</strong> | Trạng thái: <strong>${borrow.status}</strong>
    </div>

    <c:if test="${not empty error}">
      <div class="err">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/shipping/new">
      <input type="hidden" name="borrowId" value="${borrow.id}" />

      <div class="row">
        <label>Địa chỉ giao</label>
        <textarea name="address" rows="3" required></textarea>
      </div>

      <div class="row">
        <label>Số điện thoại</label>
        <input name="phone" required />
      </div>

      <div class="row">
        <button type="submit">Tạo đơn</button>
        <a class="btn" href="${pageContext.request.contextPath}/borrow">Quay lại</a>
      </div>
    </form>

    <div class="row muted">
      Nếu chưa cấu hình GHTK token, hệ thống sẽ tạo mã tracking giả dạng <strong>MOCK-...</strong>.
    </div>
  </div>
</body>
</html>
