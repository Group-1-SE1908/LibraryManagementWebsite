<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Phiếu mượn - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:1100px;margin:30px auto;padding:0 16px;}
    table{width:100%;border-collapse:collapse;}
    th,td{border-bottom:1px solid #eee;padding:10px;text-align:left;vertical-align:top;}
    .top{display:flex;gap:10px;align-items:center;justify-content:space-between;margin-bottom:14px;}
    a.btn, button{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;}
    .danger{border-color:#ffcccc;color:#b00020;}
    .ok{border-color:#ccffcc;color:#0b6b0b;}
    .flash{margin:10px 0;padding:10px;border:1px solid #ddd;border-radius:8px;background:#fafafa;}
    .muted{color:#666;}
    .tag{display:inline-block;padding:2px 8px;border-radius:999px;border:1px solid #ddd;font-size:12px;}
  </style>
</head>
<body>
  <c:set var="roleName" value="${sessionScope.currentUser.role.name}" />
  <c:set var="isAdmin" value="${roleName == 'ADMIN'}" />
  <c:set var="isStaff" value="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}" />

  <div class="top">
    <div>
      <h2>LBMS - Quản lý mượn/trả</h2>
      <div>
        <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
        <a class="btn" href="${pageContext.request.contextPath}/reservations">Đặt trước</a>
        <a class="btn" href="${pageContext.request.contextPath}/profile">Hồ sơ</a>
        <c:if test="${isStaff}">
          <a class="btn" href="${pageContext.request.contextPath}/shipping">Giao hàng</a>
        </c:if>
        <c:if test="${isAdmin}">
          <a class="btn" href="${pageContext.request.contextPath}/admin/users">Quản lý user</a>
        </c:if>
        <a class="btn" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
      </div>
    </div>
    <div>
      <a class="btn" href="${pageContext.request.contextPath}/borrow/request">Yêu cầu mượn</a>
    </div>
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
      <th>Ngày mượn</th>
      <th>Hạn trả</th>
      <th>Ngày trả</th>
      <th>Trạng thái</th>
      <th>Phạt</th>
      <th>Thao tác</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach items="${records}" var="r">
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
        <td>${r.borrowDate}</td>
        <td>${r.dueDate}</td>
        <td>${r.returnDate}</td>
        <td><span class="tag">${r.status}</span></td>
        <td>${r.fineAmount}</td>
        <td>
          <c:if test="${isStaff}">
            <c:if test="${r.status == 'REQUESTED'}">
              <a class="btn ok" href="${pageContext.request.contextPath}/borrow/approve?id=${r.id}">Duyệt</a>
              <a class="btn danger" href="${pageContext.request.contextPath}/borrow/reject?id=${r.id}">Từ chối</a>
            </c:if>
            <c:if test="${r.status == 'BORROWED'}">
              <a class="btn" href="${pageContext.request.contextPath}/borrow/return?id=${r.id}">Đánh dấu trả</a>
              <a class="btn" href="${pageContext.request.contextPath}/shipping/new?borrowId=${r.id}">Tạo giao hàng</a>
            </c:if>
          </c:if>
          <c:if test="${not isStaff}">
            <span class="muted">-</span>
          </c:if>
        </td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</body>
</html>
