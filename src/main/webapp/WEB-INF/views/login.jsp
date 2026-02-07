<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Đăng nhập - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:720px;margin:40px auto;padding:0 16px;}
    .card{border:1px solid #ddd;border-radius:10px;padding:18px;}
    .row{margin:10px 0;}
    label{display:block;margin-bottom:6px;}
    input{width:100%;padding:10px;border:1px solid #ccc;border-radius:8px;}
    button{padding:10px 14px;border:0;border-radius:8px;cursor:pointer;}
    .err{color:#b00020;margin:10px 0;}
    a{color:#0b57d0;text-decoration:none;}
  </style>
</head>
<body>
  <h2>LBMS - Đăng nhập</h2>
  <div class="card">
    <c:if test="${not empty error}">
      <div class="err">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}/login">
      <div class="row">
        <label>Email</label>
        <input name="email" type="email" required />
      </div>
      <div class="row">
        <label>Mật khẩu</label>
        <input name="password" type="password" required />
      </div>
      <div class="row">
        <button type="submit">Đăng nhập</button>
      </div>
    </form>

    <div class="row">
      Chưa có tài khoản?
      <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
    </div>
  </div>
</body>
</html>
