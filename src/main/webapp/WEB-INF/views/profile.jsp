<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Hồ sơ - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:900px;margin:30px auto;padding:0 16px;}
    .top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;}
    .card{border:1px solid #ddd;border-radius:10px;padding:18px;margin-bottom:16px;}
    .row{margin:10px 0;}
    label{display:block;margin-bottom:6px;}
    input{width:100%;padding:10px;border:1px solid #ccc;border-radius:8px;}
    button,a.btn{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;cursor:pointer;}
    .flash{margin:10px 0;padding:10px;border:1px solid #ddd;border-radius:8px;background:#fafafa;}
    .muted{color:#666;}
    .tag{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ddd;font-size:12px;}
  </style>
</head>
<body>
  <div class="top">
    <div>
      <h2>LBMS - Hồ sơ</h2>
      <div>
        <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
        <a class="btn" href="${pageContext.request.contextPath}/borrow">Mượn/Trả</a>
        <a class="btn" href="${pageContext.request.contextPath}/reservations">Đặt trước</a>
      </div>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
  </div>

  <c:if test="${not empty flash}">
    <div class="flash">${flash}</div>
  </c:if>

  <div class="card">
    <h3>Thông tin tài khoản</h3>
    <div class="row">Email: <strong>${user.email}</strong></div>
    <div class="row">Role: <span class="tag">${user.role.name}</span></div>
    <div class="row">Status: <span class="tag">${user.status}</span></div>
  </div>

  <div class="card">
    <h3>Cập nhật hồ sơ</h3>
    <form method="post" action="${pageContext.request.contextPath}/profile">
      <div class="row">
        <label>Họ tên</label>
        <input name="fullName" value="${user.fullName}" />
      </div>
      <div class="row">
        <button type="submit">Lưu</button>
      </div>
    </form>
  </div>

  <div class="card">
    <h3>Đổi mật khẩu</h3>
    <form method="post" action="${pageContext.request.contextPath}/change-password">
      <div class="row">
        <label>Mật khẩu hiện tại</label>
        <input name="oldPassword" type="password" required />
      </div>
      <div class="row">
        <label>Mật khẩu mới</label>
        <input name="newPassword" type="password" required />
      </div>
      <div class="row">
        <label>Xác nhận mật khẩu mới</label>
        <input name="confirm" type="password" required />
      </div>
      <div class="row">
        <button type="submit">Đổi mật khẩu</button>
      </div>
      <div class="row muted">
        Sau khi đổi mật khẩu thành công, hệ thống sẽ đăng xuất và yêu cầu bạn đăng nhập lại.
      </div>
    </form>
  </div>
</body>
</html>
