<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Giỏ hàng</title>
    <style>
        .actions{margin-bottom:16px;}
        .actions a{display:inline-block;padding:8px 12px;border-radius:8px;border:1px solid #333;background:#fff;color:#111;text-decoration:none;}
        .actions a:hover{background:#f0f0f0;}
    </style>
</head>
<body>

<h2>Giỏ hàng của bạn</h2>

<c:if test="${not empty param.cartSuccess}">
    <p style="color: green">${param.cartSuccess}</p>
</c:if>

<c:if test="${not empty param.cartError}">
    <p style="color: red">${param.cartError}</p>
</c:if>

<c:if test="${empty cart || empty cart.items}">
    <p>Giỏ hàng trống</p>
</c:if>

<c:if test="${not empty cart && not empty cart.items}">
    <table border="1" cellpadding="5">
        <tr>
            <th>Tên sách</th>
            <th>Giá</th>
            <th>Số lượng</th>
            <th>Tạm tính</th>
            <th>Cập Nhật</th>
        </tr>

        <c:forEach items="${cart.items}" var="item">
            <tr>
                <td>${item.book.title}</td>
                <td>${item.book.price}</td>
                <td>${item.quantity}</td>
                <td>${item.subtotal}</td>
                <td>
                    <form action="${pageContext.request.contextPath}/cart/update" method="post" style="display:inline-block;">
                        <input type="hidden" name="bookId" value="${item.bookId}">
                        <input type="number" name="quantity" min="1" value="${item.quantity}" style="width:56px;padding:4px;margin-right:4px;" />
                        <button type="submit">Cập nhật</button>
                    </form>
                    <form action="${pageContext.request.contextPath}/cart/remove" method="post" style="display:inline-block;margin-left:8px;">
                        <input type="hidden" name="bookId" value="${item.bookId}">
                        <button type="submit">Xóa</button>
                    </form>
                </td>
            </tr>
        </c:forEach>
    </table>

    <p><strong>Tổng tiền:</strong> ${cart.totalAmount}</p>
</c:if>
<div class="actions">
    <a href="${pageContext.request.contextPath}/books">Trở về trang chủ</a>
</div>

</body>
</html>
