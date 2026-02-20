<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <title>Thanh toán (Checkout)</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <style>
                        .checkout-page {
                            max-width: 1200px;
                            margin: 40px auto;
                            padding: 0 20px;
                            display: grid;
                            grid-template-columns: 2fr 1fr;
                            gap: 40px;
                        }

                        .checkout-header {
                            grid-column: 1 / -1;
                            margin-bottom: 20px;
                        }

                        .checkout-header h1 {
                            font-size: 2rem;
                            margin-bottom: 10px;
                        }

                        .checkout-items {
                            background: #fff;
                            padding: 24px;
                            border-radius: 12px;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                        }

                        .item-row {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 16px 0;
                            border-bottom: 1px solid #eee;
                        }

                        .item-row:last-child {
                            border-bottom: none;
                        }

                        .item-info h3 {
                            margin: 0 0 5px 0;
                            font-size: 1.1rem;
                        }

                        .item-info .author {
                            color: #666;
                            margin: 0;
                        }

                        .item-price {
                            text-align: right;
                            font-weight: bold;
                        }

                        .checkout-summary {
                            background: #fff;
                            padding: 24px;
                            border-radius: 12px;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
                            align-self: start;
                        }

                        .summary-row {
                            display: flex;
                            justify-content: space-between;
                            margin-bottom: 15px;
                            color: #555;
                        }

                        .summary-total {
                            display: flex;
                            justify-content: space-between;
                            margin: 20px 0;
                            padding-top: 15px;
                            border-top: 2px solid #eee;
                            font-size: 1.25rem;
                            font-weight: bold;
                            color: #111;
                        }

                        .btn-confirm {
                            width: 100%;
                            padding: 14px;
                            font-size: 1.1rem;
                        }

                        .alert {
                            padding: 16px;
                            margin-bottom: 20px;
                            border-radius: 8px;
                            grid-column: 1 / -1;
                        }

                        .alert.error {
                            background: #ffebee;
                            color: #c62828;
                        }

                        @media (max-width: 768px) {
                            .checkout-page {
                                grid-template-columns: 1fr;
                            }
                        }
                    </style>
                </head>

                <body>

                    <jsp:include page="/WEB-INF/views/header.jsp" />

                    <c:set var="itemCount" value="${empty cart || empty cart.items ? 0 : fn:length(cart.items)}" />
                    <c:set var="totalQuantity" value="0" />
                    <c:if test="${not empty cart && not empty cart.items}">
                        <c:forEach var="cartItem" items="${cart.items}">
                            <c:set var="totalQuantity" value="${totalQuantity + cartItem.quantity}" />
                        </c:forEach>
                    </c:if>

                    <main class="checkout-page">
                        <div class="checkout-header">
                            <h1>Thanh toán / Checkout</h1>
                            <p>Kiểm tra lại danh sách sách bạn muốn mượn trước khi xác nhận.</p>
                        </div>

                        <c:if test="${not empty flash}">
                            <div class="alert error">${flash}</div>
                        </c:if>

                        <div class="checkout-items">
                            <h2>Sách trong đơn hàng</h2>
                            <c:forEach items="${cart.items}" var="item">
                                <div class="item-row">
                                    <div class="item-info">
                                        <h3>${item.book.title}</h3>
                                        <p class="author">Tác giả: ${item.book.author}</p>
                                        <p class="muted">Số lượng: ${item.quantity}</p>
                                    </div>
                                    <div class="item-price">
                                        <fmt:formatNumber value="${item.subtotal}" pattern="#,##0" /> ₫
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <aside class="checkout-summary">
                            <h2>Tóm tắt</h2>
                            <div class="summary-row">
                                <span>Số loại sách</span>
                                <strong>${itemCount}</strong>
                            </div>
                            <div class="summary-row">
                                <span>Tổng số lượng</span>
                                <strong>${totalQuantity}</strong>
                            </div>
                            <div class="summary-total">
                                <span>Tổng tiền</span>
                                <span>
                                    <fmt:formatNumber value="${cart.totalAmount != null ? cart.totalAmount : 0}"
                                        pattern="#,##0" /> ₫
                                </span>
                            </div>

                            <form action="${pageContext.request.contextPath}/checkout/process" method="post">
                                <button type="submit" class="btn primary btn-confirm">Xác nhận thanh toán
                                    (Confirm)</button>
                            </form>
                            <div style="margin-top: 15px; text-align: center;">
                                <a href="${pageContext.request.contextPath}/cart"
                                    style="color: #666; text-decoration: none;">Quay lại giỏ hàng</a>
                            </div>
                        </aside>
                    </main>

                    <jsp:include page="/WEB-INF/views/footer.jsp" />

                </body>

                </html>