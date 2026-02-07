<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Giao hàng - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:1100px;margin:30px auto;padding:0 16px;}
    table{width:100%;border-collapse:collapse;}
    th,td{border-bottom:1px solid #eee;padding:10px;text-align:left;vertical-align:top;}
    a.btn, button{display:inline-block;padding:8px 10px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;cursor:pointer;}
    .flash{margin:10px 0;padding:10px;border:1px solid #ddd;border-radius:8px;background:#fafafa;}
    .muted{color:#666;}
    .tag{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ddd;font-size:12px;}
    .top{display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;}
  </style>
</head>
<body>
  <div class="top">
    <div>
      <h2>LBMS - Giao hàng (GHTK)</h2>
      <div>
        <a class="btn" href="${pageContext.request.contextPath}/borrow">Mượn/Trả</a>
        <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
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
      <th>Borrow ID</th>
      <th>Tracking</th>
      <th>Trạng thái</th>
      <th>Địa chỉ</th>
      <th>SĐT</th>
      <th>Thao tác</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach items="${shipments}" var="s">
      <tr>
        <td>${s.id}</td>
        <td>${s.borrowRecord.id}</td>
        <td><span class="tag">${s.trackingCode}</span></td>
        <td><span class="tag">${s.status}</span></td>
        <td>${s.address}</td>
        <td>${s.phone}</td>
        <td>
          <a class="btn" href="${pageContext.request.contextPath}/shipping/status?id=${s.id}">Xem/Refresh</a>
        </td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</body>
</html>
