<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
                <c:set var="mode" value="${mode != null ? mode : 'return'}" />
                <c:set var="fineMode" value="${mode == 'fine'}" />

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
                            <h1>
                                <c:choose>
                                    <c:when test="${fineMode}">Thanh toán phí phạt</c:when>
                                    <c:otherwise>Thanh toán phí phạt &amp; Trả sách</c:otherwise>
                                </c:choose>
                            </h1>
                            <p>
                                <c:choose>
                                    <c:when test="${fineMode}">Bạn đang xử lý khoản phí phạt cho phiếu mượn này.
                                    </c:when>
                                    <c:otherwise>Vui lòng kiểm tra thông tin phiếu mượn và số tiền phạt (nếu có) trước
                                        khi xác nhận trả
                                        sách.</c:otherwise>
                                </c:choose>
                            </p>
                        </div>

                        <c:if test="${not empty flash}">
                            <div class="alert error">${flash}</div>
                        </c:if>

                        <div class="checkout-items">
                            <h2>Thông tin phiếu mượn #${borrowRecord.id}</h2>
                            <div class="item-row">
                                <div class="item-info">
                                    <h3>${borrowRecord.book.title}</h3>
                                    <p class="author">Tác giả: ${borrowRecord.book.author}</p>
                                    <p class="muted">Ngày mượn: ${borrowRecord.borrowDate}</p>
                                    <p class="muted">Hạn trả: ${borrowRecord.dueDate}</p>
                                </div>
                                <div class="item-price">
                                    Phí phạt dự kiến:
                                    <fmt:formatNumber value="${fineAmount}" pattern="#,##0" /> ₫
                                </div>
                            </div>
                        </div>

                        <aside class="checkout-summary">
                            <h2>Tóm tắt thanh toán</h2>
                            <c:if test="${fineMode}">
                                <p class="muted" style="margin-top:6px; margin-bottom:18px; font-size:0.9rem;">
                                    Phiếu mượn đã trả, chỉ còn khoản phí phạt cần hoàn tất.
                                </p>
                            </c:if>
                            <div class="summary-row">
                                <span>Phiếu mượn</span>
                                <strong>#${borrowRecord.id}</strong>
                            </div>
                            <div class="summary-total">
                                <span>Tổng tiền phạt</span>
                                <span>
                                    <fmt:formatNumber value="${fineAmount != null ? fineAmount : 0}" pattern="#,##0" />
                                    ₫
                                </span>
                            </div>

                            <form action="${pageContext.request.contextPath}/checkout/process" method="post">
                                <input type="hidden" name="borrowId" value="${borrowRecord.id}" />
                                <input type="hidden" name="mode" value="${mode}" />
                                <button type="submit" class="btn primary btn-confirm">
                                    <c:choose>
                                        <c:when test="${fineMode}">Thanh toán phí phạt</c:when>
                                        <c:otherwise>Xác nhận trả sách &amp; Thanh toán</c:otherwise>
                                    </c:choose>
                                </button>
                            </form>
                            <div style="margin-top: 15px; text-align: center;">
                                <a href="${pageContext.request.contextPath}/history"
                                    style="color: #666; text-decoration: none;">Hủy bỏ & Quay lại</a>
                            </div>
                        </aside>
                    </main>

                    <jsp:include page="/WEB-INF/views/footer.jsp" />

                </body>

                </html>