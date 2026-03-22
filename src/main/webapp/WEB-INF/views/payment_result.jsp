<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Kết quả thanh toán - LBMS</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                <style>
                    body {
                        font-family: Arial, sans-serif;
                        background: #f5f5f5;
                        margin: 0;
                    }

                    .pr-wrapper {
                        min-height: calc(100vh - 64px);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        padding: 40px 20px;
                    }

                    .pr-card {
                        background: #fff;
                        border-radius: 12px;
                        box-shadow: 0 4px 24px rgba(0, 0, 0, 0.10);
                        padding: 48px 40px;
                        max-width: 520px;
                        width: 100%;
                        text-align: center;
                    }

                    .pr-icon {
                        font-size: 72px;
                        line-height: 1;
                        margin-bottom: 20px;
                    }

                    .pr-title {
                        font-size: 1.8rem;
                        font-weight: 700;
                        margin-bottom: 12px;
                    }

                    .pr-title.success {
                        color: #1a7f37;
                    }

                    .pr-title.failed {
                        color: #d1242f;
                    }

                    .pr-message {
                        font-size: 1rem;
                        color: #555;
                        margin-bottom: 28px;
                        line-height: 1.5;
                    }

                    .pr-details {
                        background: #f8f9fa;
                        border-radius: 8px;
                        padding: 16px 20px;
                        margin-bottom: 32px;
                        text-align: left;
                    }

                    .pr-detail-row {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        padding: 6px 0;
                        border-bottom: 1px solid #eee;
                        font-size: 0.92rem;
                    }

                    .pr-detail-row:last-child {
                        border-bottom: none;
                    }

                    .pr-detail-label {
                        color: #777;
                    }

                    .pr-detail-value {
                        font-weight: 600;
                        color: #333;
                    }

                    .pr-amount {
                        font-size: 1.1rem;
                        color: #d1242f;
                    }

                    .pr-method-badge {
                        display: inline-block;
                        padding: 2px 10px;
                        border-radius: 20px;
                        font-size: 0.82rem;
                        font-weight: 600;
                    }

                    .pr-method-wallet {
                        background: #e8f5e9;
                        color: #2e7d32;
                    }

                    .pr-method-vnpay {
                        background: #e3f2fd;
                        color: #1565c0;
                    }

                    .pr-btn {
                        display: inline-block;
                        padding: 12px 32px;
                        border-radius: 8px;
                        text-decoration: none;
                        font-size: 1rem;
                        font-weight: 600;
                        cursor: pointer;
                        border: none;
                        transition: background 0.2s;
                    }

                    .pr-btn-success {
                        background: #1a7f37;
                        color: #fff;
                    }

                    .pr-btn-success:hover {
                        background: #155e2a;
                    }

                    .pr-btn-failed {
                        background: #d1242f;
                        color: #fff;
                    }

                    .pr-btn-failed:hover {
                        background: #a8101a;
                    }

                    .pr-link-secondary {
                        display: block;
                        margin-top: 14px;
                        font-size: 0.9rem;
                        color: #888;
                        text-decoration: none;
                    }

                    .pr-link-secondary:hover {
                        color: #333;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/views/header.jsp" />

                <div class="pr-wrapper">
                    <div class="pr-card">
                        <c:choose>
                            <c:when test="${paymentStatus == 'success'}">
                                <div class="pr-icon">✅</div>
                                <h1 class="pr-title success">Thanh toán thành công!</h1>
                            </c:when>
                            <c:otherwise>
                                <div class="pr-icon">❌</div>
                                <h1 class="pr-title failed">Thanh toán thất bại</h1>
                            </c:otherwise>
                        </c:choose>

                        <p class="pr-message">${paymentMessage}</p>

                        <div class="pr-details">
                            <c:if test="${paymentAmount != null && paymentAmount > 0}">
                                <div class="pr-detail-row">
                                    <span class="pr-detail-label">Số tiền</span>
                                    <span class="pr-detail-value pr-amount">
                                        <fmt:formatNumber value="${paymentAmount}" pattern="#,##0" />&#8363;
                                    </span>
                                </div>
                            </c:if>
                            <c:if test="${not empty paymentMethod}">
                                <div class="pr-detail-row">
                                    <span class="pr-detail-label">Phương thức</span>
                                    <span class="pr-detail-value">
                                        <c:choose>
                                            <c:when test="${paymentMethod == 'WALLET'}">
                                                <span class="pr-method-badge pr-method-wallet">💰 Ví LBMS</span>
                                            </c:when>
                                            <c:when test="${paymentMethod == 'VNPAY'}">
                                                <span class="pr-method-badge pr-method-vnpay">💳 VNPay Sandbox</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span>${paymentMethod}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                            </c:if>
                            <div class="pr-detail-row">
                                <span class="pr-detail-label">Trạng thái</span>
                                <c:choose>
                                    <c:when test="${paymentStatus == 'success'}">
                                        <span class="pr-detail-value" style="color:#1a7f37;">Thành công</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pr-detail-value" style="color:#d1242f;">Thất bại</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <a href="${pageContext.request.contextPath}${paymentBackUrl}"
                            class="pr-btn ${paymentStatus == 'success' ? 'pr-btn-success' : 'pr-btn-failed'}">
                            ${paymentBackLabel}
                        </a>

                        <c:if test="${paymentStatus == 'success'}">
                            <a href="${pageContext.request.contextPath}/profile" class="pr-link-secondary">
                                Xem lịch sử thanh toán
                            </a>
                        </c:if>
                        <c:if test="${paymentStatus == 'failed'}">
                            <a href="${pageContext.request.contextPath}/cart" class="pr-link-secondary">
                                Quay lại giỏ hàng
                            </a>
                        </c:if>
                    </div>
                </div>

                <jsp:include page="/WEB-INF/views/footer.jsp" />
            </body>

            </html>