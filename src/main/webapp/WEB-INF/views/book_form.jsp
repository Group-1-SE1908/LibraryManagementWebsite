<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Form sách - LBMS</title>
  <style>
    body{font-family:Arial,Helvetica,sans-serif;max-width:820px;margin:30px auto;padding:0 16px;}
    .card{border:1px solid #ddd;border-radius:10px;padding:18px;}
    .row{margin:10px 0;}
    label{display:block;margin-bottom:6px;}
    input,select{width:100%;padding:10px;border:1px solid #ccc;border-radius:8px;}
    button,a.btn{display:inline-block;padding:10px 12px;border-radius:8px;border:1px solid #ddd;text-decoration:none;color:#111;background:#fff;}
    .err{color:#b00020;margin:10px 0;}
  </style>
</head>
<body>
  <c:set var="isEdit" value="${mode == 'edit'}" />
  <h2><c:choose><c:when test="${isEdit}">Sửa sách</c:when><c:otherwise>Thêm sách</c:otherwise></c:choose></h2>

  <div class="card">
    <c:if test="${not empty error}">
      <div class="err">${error}</div>
    </c:if>

    <form method="post" action="${pageContext.request.contextPath}<c:choose><c:when test='${isEdit}'>/books/edit</c:when><c:otherwise>/books/new</c:otherwise></c:choose>">
      <c:if test="${isEdit}">
        <input type="hidden" name="id" value="${book.id}" />
      </c:if>

      <div class="row">
        <label>ISBN</label>
        <input name="isbn" value="${book.isbn}" required />
      </div>
      <div class="row">
        <label>Tên sách</label>
        <input name="title" value="${book.title}" required />
      </div>
      <div class="row">
        <label>Tác giả</label>
        <input name="author" value="${book.author}" required />
      </div>
      <div class="row">
        <label>Nhà xuất bản</label>
        <input name="publisher" value="${book.publisher}" />
      </div>
      <div class="row">
        <label>Năm xuất bản</label>
        <input name="publishYear" value="${book.publishYear}" type="number" min="0" />
      </div>
      <div class="row">
        <label>Số lượng</label>
        <input name="quantity" value="${book.quantity}" type="number" min="0" required />
      </div>
      <div class="row">
        <label>Trạng thái</label>
        <select name="status">
          <c:set var="st" value="${empty book.status ? 'AVAILABLE' : book.status}" />
          <option value="AVAILABLE" <c:if test="${st == 'AVAILABLE'}">selected</c:if>>AVAILABLE</option>
          <option value="OUT_OF_STOCK" <c:if test="${st == 'OUT_OF_STOCK'}">selected</c:if>>OUT_OF_STOCK</option>
          <option value="ARCHIVED" <c:if test="${st == 'ARCHIVED'}">selected</c:if>>ARCHIVED</option>
        </select>
      </div>

      <div class="row">
        <button type="submit">Lưu</button>
        <a class="btn" href="${pageContext.request.contextPath}/books">Quay lại</a>
      </div>
    </form>
  </div>
</body>
</html>
