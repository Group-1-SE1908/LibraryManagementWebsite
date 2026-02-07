<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html>
<head>
    <title>Giỏ sách</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ccc;
            padding: 8px;
            text-align: center;
        }
        th {
            background-color: #f3f3f3;
        }
        form {
            display: inline;
        }
        input[type=number] {
            width: 60px;
        }
    </style>
</head>
<body>

<h2>🛒 Giỏ sách</h2>

<c:choose>

    <!-- CART RỖNG -->
    <c:when test="${empty sessionScope.cart || sessionScope.cart.items.empty}">
        <p>Giỏ hàng đang trống.</p>
        <a href="${pageContext.request.contextPath}/books">← Quay lại danh sách sách</a>
    </c:when>

    <!-- CÓ SÁCH TRONG CART -->
    <c:otherwise>

        <table>
            <tr>
                <th>ID sách</th>
                <th>Tên sách</th>
                <th>Số lượng</th>
                <th>Thao tác</th>
            </tr>

            <c:forEach var="item" items="${sessionScope.cart.items}">
                <tr>
                    <td>${item.bookId}</td>
                    <td>${item.title}</td>
                    <td>
                        <form method="post" action="${pageContext.request.contextPath}/cart/update">
                            <input type="hidden" name="bookId" value="${item.bookId}" />
                            <input type="number" name="quantity"
                                   value="${item.quantity}" min="1" />
                            <button type="submit">Cập nhật</button>
                        </form>
                    </td>
                    <td>
                        <form method="post"
                              action="${pageContext.request.contextPath}/cart/remove"
                              onsubmit="return confirm('Xóa sách này khỏi giỏ?')">
                            <input type="hidden" name="bookId" value="${item.bookId}" />
                            <button type="submit">Xóa</button>
                        </form>
                    </td>
                </tr>
            </c:forEach>

        </table>

        <br>

        <a href="${pageContext.request.contextPath}/books">← Tiếp tục chọn sách</a>
        |
        <a href="${pageContext.request.contextPath}/borrow/request">
            📄 Gửi yêu cầu mượn
        </a>

    </c:otherwise>

</c:choose>

</body>
</html>
