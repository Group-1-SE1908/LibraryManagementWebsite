<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8" />
    <title>Giỏ hàng</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
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

<main class="cart-page">
    <c:if test="${itemCount > 0}">
        <section class="cart-hero">
        <div class="hero-content">
            <p class="eyebrow">Giỏ hàng</p>
            <h1>Những cuốn sách bạn đang giữ</h1>
            <p class="hero-subtitle">Gửi yêu cầu mượn ngay khi bạn sẵn sàng. Chúng tôi sẽ giữ kho sách và hỗ trợ gia hạn nếu cần.</p>
            <div class="hero-actions">
                <a href="${pageContext.request.contextPath}/books" class="btn secondary">Tiếp tục khám phá</a>
                <a href="${pageContext.request.contextPath}/borrow" class="btn primary">Tạo yêu cầu mượn</a>
            </div>
        </div>
        <div class="hero-summary">
            <div class="hero-card">
                <p class="label">Loại sách trong giỏ</p>
                <p class="value">${itemCount}</p>
                <small>nhóm sách đang chờ duyệt</small>
            </div>
            <div class="hero-card">
                <p class="label">Tổng số lượng</p>
                <p class="value">${totalQuantity}</p>
                <small>cuốn bạn vừa thêm</small>
            </div>
            <div class="hero-card">
                <p class="label">Tạm tính</p>
                <p class="value">
                    <fmt:formatNumber value="${cart.totalAmount != null ? cart.totalAmount : 0}" pattern="#,##0" />
                    <span class="currency">₫</span>
                </p>
                <small>chưa bao gồm bất kỳ phí nào.</small>
            </div>
        </div>
        </section>
    </c:if>

    <c:if test="${not empty param.cartSuccess}">
        <div class="alert success">${param.cartSuccess}</div>
    </c:if>
    <c:if test="${not empty param.cartError}">
        <div class="alert error">${param.cartError}</div>
    </c:if>

    <c:if test="${itemCount == 0}">
        <section class="cart-empty">
            <div class="empty-card">
                <h2>Giỏ hàng trống</h2>
                <p>Bạn chưa thêm cuốn sách nào vào giỏ. Hãy khám phá thư viện và chọn vài cuốn bạn muốn mượn.</p>
                <a href="${pageContext.request.contextPath}/books" class="btn primary">Bắt đầu chọn sách</a>
            </div>
        </section>
    </c:if>

    <c:if test="${itemCount > 0}">
        <section class="cart-grid-section">
            <div class="cart-items-grid">
                <c:forEach items="${cart.items}" var="item">
                    <article class="cart-item-card">
                        <div class="cart-item-cover">
                            <span>${fn:substring(item.book.title, 0, 1)}</span>
                        </div>
                        <div class="cart-item-body">
                            <div class="cart-item-head">
                                <h3>${item.book.title}</h3>
                                <p class="cart-item-author">Tác giả ${item.book.author}</p>
                            </div>
                            <div class="cart-item-meta">
                                <div class="cart-price">
                                    <fmt:formatNumber value="${item.book.price}" pattern="#,##0" />
                                    <small>₫ / cuốn</small>
                                </div>
                                <span class="availability ${item.book.availability ? 'in-stock' : 'out-of-stock'}">
                                    ${item.book.availability ? 'Còn hàng' : 'Hết hàng'}
                                </span>
                            </div>
                            <div class="cart-item-actions">
                                <form action="${pageContext.request.contextPath}/cart/update" method="post" class="quantity-form">
                                    <input type="hidden" name="bookId" value="${item.bookId}" />
                                    <input type="number" name="quantity" min="1" value="${item.quantity}" class="quantity-input" />
                                    <button type="submit" class="btn secondary">Cập nhật</button>
                                </form>
                                <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="remove-form">
                                    <input type="hidden" name="bookId" value="${item.bookId}" />
                                    <button type="submit" class="btn danger">Xóa</button>
                                </form>
                            </div>
                            <div class="cart-item-subtotal">
                                <span>Tạm tính</span>
                                <strong><fmt:formatNumber value="${item.subtotal}" pattern="#,##0" /> ₫</strong>
                            </div>
                        </div>
                    </article>
                </c:forEach>
            </div>
            <aside class="cart-summary-panel">
                <h3>Đơn hàng</h3>
                <div class="summary-row">
                    <span>Số loại sách</span>
                    <strong>${itemCount}</strong>
                </div>
                <div class="summary-row">
                    <span>Tổng số lượng</span>
                    <strong>${totalQuantity}</strong>
                </div>
                <div class="summary-row total-row">
                    <span>Tổng tiền</span>
                    <strong><fmt:formatNumber value="${cart.totalAmount != null ? cart.totalAmount : 0}" pattern="#,##0" /> ₫</strong>
                </div>
                <button type="button" class="btn primary" onclick="window.location='${pageContext.request.contextPath}/borrow'">Tạo yêu cầu mượn</button>
                <a href="${pageContext.request.contextPath}/books" class="btn secondary">Tiếp tục xem sách</a>
            </aside>
        </section>
    </c:if>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp" />

</body>
</html>
