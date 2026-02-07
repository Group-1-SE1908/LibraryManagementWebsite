<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Đặt trước - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:1100px;margin:30px auto;padding:0 16px;}
    table{width:100%;border-collapse:collapse;}
    th,td{border-bottom:1px solid #eee;padding:10px;text-align:left;vertical-align:top;}
    a.btn, button{display:inline-block;padding:8px 10px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;cursor:pointer;}
    .danger{border-color:#ffcccc;color:#b00020;}
    .flash{margin:10px 0;padding:10px;border:1px solid #ddd;border-radius:8px;background:#fafafa;}
    .muted{color:#666;}
    form{margin:0;}
    .top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;}
    .tag{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ddd;font-size:12px;}
  </style>
</head>
<body>
  <div class="top">
    <div>
      <h2>LBMS - Đặt trước</h2>
      <div>
        <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
        <a class="btn" href="${pageContext.request.contextPath}/borrow">Mượn/Trả</a>
      </div>
    </div>
    <a class="btn" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
  </div>

  <c:if test="${not empty flash}">
    <div class="flash">${flash}</div>
  </c:if>

  <table>
    <thead>
    <tr>
      <th>ID</th>
      <th>User</th>
      <th>Sách</th>
      <th>Trạng thái</th>
      <th>Ngày tạo</th>
      <th>Thao tác</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach items="${reservations}" var="r">
      <tr>
        <td>${r.id}</td>
        <td>
          <div><strong>${r.user.email}</strong></div>
          <div class="muted">${r.user.fullName}</div>
        </td>
        <td>
          <div><strong>${r.book.title}</strong></div>
          <div class="muted">${r.book.author} | ${r.book.isbn}</div>
        </td>
        <td><span class="tag">${r.status}</span></td>
        <td>${r.createdAt}</td>
        <td>
          <c:if test="${not isStaff}">
            <c:if test="${r.status == 'WAITING' || r.status == 'NOTIFIED'}">
              <a class="btn danger" href="${pageContext.request.contextPath}/reservations/cancel?id=${r.id}" onclick="return confirm('Hủy đặt trước?');">Hủy</a>
            </c:if>
          </c:if>
          <c:if test="${isStaff}">
            <span class="muted">-</span>
          </c:if>
        </td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</body>
</html>
