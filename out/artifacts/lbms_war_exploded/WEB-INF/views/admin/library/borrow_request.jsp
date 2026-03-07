<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Yêu cầu mượn sách - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:1100px;margin:30px auto;padding:0 16px;}
    table{width:100%;border-collapse:collapse;}
    th,td{border-bottom:1px solid #eee;padding:10px;text-align:left;vertical-align:top;}
    .top{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-bottom:14px;}
    input{padding:10px;border:1px solid #ccc;border-radius:8px;min-width:260px;}
    a.btn, button{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;cursor:pointer;}
    .err{color:#b00020;margin:10px 0;}
    .muted{color:#666;}
  </style>
</head>
<body>
  <div class="top">
    <div>
      <h2>LBMS - Tạo yêu cầu mượn</h2>
      <div>
        <a class="btn" href="${pageContext.request.contextPath}/borrow">Danh sách phiếu mượn</a>
        <a class="btn" href="${pageContext.request.contextPath}/reservations">Đặt trước</a>
        <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
      </div>
    </div>

    <form method="get" action="${pageContext.request.contextPath}/borrow/request">
      <input name="q" value="${q}" placeholder="Tìm theo tên/tác giả/ISBN..." />
      <button type="submit">Tìm</button>
    </form>
  </div>

  <c:if test="${not empty error}">
    <div class="err">${error}</div>
  </c:if>

  <table>
    <thead>
    <tr>
      <th>ID</th>
      <th>ISBN</th>
      <th>Tên sách</th>
      <th>Tác giả</th>
      <th>Số lượng</th>
      <th>Trạng thái</th>
      <th>Thao tác</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach items="${books}" var="b">
      <tr>
        <td>${b.id}</td>
        <td>${b.isbn}</td>
        <td>${b.title}</td>
        <td>${b.author}</td>
        <td>${b.quantity}</td>
        <td>${b.status}</td>
        <td>
          <c:choose>
            <c:when test="${b.quantity > 0}">
              <form method="post" action="${pageContext.request.contextPath}/borrow/request" style="margin:0;">
                <input type="hidden" name="bookId" value="${b.id}" />
                <button type="submit">Gửi yêu cầu</button>
              </form>
            </c:when>
            <c:otherwise>
              <form method="post" action="${pageContext.request.contextPath}/reservations/create" style="margin:0;">
                <input type="hidden" name="bookId" value="${b.id}" />
                <button type="submit">Đặt trước</button>
              </form>
            </c:otherwise>
          </c:choose>
        </td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</body>
</html>
