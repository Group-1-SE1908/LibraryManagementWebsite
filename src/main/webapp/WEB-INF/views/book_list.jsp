<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Danh sách sách - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:1000px;margin:30px auto;padding:0 16px;}
    table{width:100%;border-collapse:collapse;}
    th,td{border-bottom:1px solid #eee;padding:10px;text-align:left;}
    .top{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-bottom:14px;}
    input{padding:10px;border:1px solid #ccc;border-radius:8px;min-width:260px;}
    a.btn, button{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;}
    .danger{border-color:#ffcccc;color:#b00020;}
    .cart-cell form{display:flex;gap:6px;align-items:center;}
    .cart-cell input{width:60px;padding:6px;border-radius:6px;border:1px solid #ccc;}
    .cart-cell button{padding:6px 10px;font-size:0.9rem;}
  </style>
</head>
<body>
  <c:set var="roleName" value="${sessionScope.currentUser.role.name}" />
  <c:set var="isAdmin" value="${roleName == 'ADMIN'}" />

  <div class="top">
    <div>
      <h2>LBMS - Danh sách sách</h2>
      <div>
        <c:if test="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}">
          <a class="btn" href="${pageContext.request.contextPath}/books/new">Thêm sách</a>
        </c:if>
        <a class="btn" href="${pageContext.request.contextPath}/borrow">Mượn/Trả</a>
        <a class="btn" href="${pageContext.request.contextPath}/reservations">Đặt trước</a>
        <a class="btn" href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
        <c:if test="${isAdmin}">
          <a class="btn" href="${pageContext.request.contextPath}/admin/users">Quản lý user</a>
        </c:if>
        <a class="btn" href="${pageContext.request.contextPath}/cart">Giỏ hàng</a>
        <c:if test="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}">
          <a class="btn" href="${pageContext.request.contextPath}/shipping">Giao hàng</a>
        </c:if>
        <a class="btn" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
      </div>
    </div>

    <form method="get" action="${pageContext.request.contextPath}/books">
      <input name="q" value="${q}" placeholder="Tìm theo tên/tác giả/ISBN..." />
      <button type="submit">Tìm</button>
    </form>
  </div>

  <table>
    <thead>
      <tr>
        <th>ID</th>
        <th>ISBN</th>
        <th>Tên sách</th>
        <th>Tác giả</th>
        <th>Số lượng</th>
        <th>Trạng thái</th>
        <th>Giỏ hàng</th>
        <c:if test="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}">
          <th>Thao tác</th>
        </c:if>
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
        <td class="cart-cell">
          <form method="post" action="${pageContext.request.contextPath}/cart/add">
            <input type="hidden" name="bookId" value="${b.id}" />
            <input type="number" name="quantity" min="1" value="1" />
            <button type="submit">Thêm</button>
          </form>
        </td>
        <c:if test="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}">
          <td>
            <a class="btn" href="${pageContext.request.contextPath}/books/edit?id=${b.id}">Sửa</a>
            <a class="btn danger" href="${pageContext.request.contextPath}/books/delete?id=${b.id}" onclick="return confirm('Xóa sách này?');">Xóa</a>
          </td>
        </c:if>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</body>
</html>
