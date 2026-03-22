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
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>
                        <c:choose>
                            <c:when test="${fineMode}">Thanh toán phí phạt</c:when>
                            <c:otherwise>Trả sách &amp; Thanh toán</c:otherwise>
                        </c:choose> | LBMS Portal
                    </title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
                    <style>
                        /* ── Checkout layout ── */
                        .co-layout {
                            max-width: 1080px;
                            margin: 0 auto;
                            padding: 36px 24px 80px;
                            display: grid;
                            grid-template-columns: 1fr 360px;
                            gap: 28px;
                        }

                        @media (max-width: 840px) {
                            .co-layout {
                                grid-template-columns: 1fr;
                            }
                        }

                        /* ── Step breadcrumb ── */
                        .co-steps {
                            display: flex;
                            align-items: center;
                            gap: 0;
                            margin-bottom: 28px;
                            grid-column: 1 / -1;
                        }

                        .co-step {
                            display: flex;
                            align-items: center;
                            gap: 8px;
                            font-size: 0.78rem;
                            font-weight: 700;
                            letter-spacing: 0.06em;
                            text-transform: uppercase;
                            color: var(--mp-text-muted);
                        }

                        .co-step.is-active {
                            color: var(--mp-primary-mid);
                        }

                        .co-step.is-done {
                            color: #16a34a;
                        }

                        .co-step__num {
                            width: 26px;
                            height: 26px;
                            border-radius: 50%;
                            background: var(--mp-border);
                            color: var(--mp-text-muted);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 0.72rem;
                            font-weight: 800;
                            flex-shrink: 0;
                        }

                        .co-step.is-active .co-step__num {
                            background: var(--mp-primary-mid);
                            color: #fff;
                            box-shadow: 0 4px 12px rgba(37, 99, 235, .38);
                        }

                        .co-step.is-done .co-step__num {
                            background: #16a34a;
                            color: #fff;
                        }

                        .co-step__sep {
                            width: 36px;
                            height: 2px;
                            background: var(--mp-border);
                            margin: 0 6px;
                            border-radius: 2px;
                        }

                        /* ── Card shell ── */
                        .co-card {
                            background: var(--mp-surface);
                            border: 1.5px solid var(--mp-border);
                            border-radius: var(--mp-radius);
                            box-shadow: var(--mp-shadow-md);
                            overflow: hidden;
                        }

                        .co-card__head {
                            padding: 20px 24px 18px;
                            border-bottom: 1.5px solid var(--mp-border-light);
                            display: flex;
                            align-items: center;
                            gap: 12px;
                        }

                        .co-card__head-icon {
                            width: 40px;
                            height: 40px;
                            border-radius: 12px;
                            background: var(--mp-primary-light);
                            color: var(--mp-primary-mid);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 1.15rem;
                            flex-shrink: 0;
                        }

                        .co-card__head-title {
                            font-size: 1.05rem;
                            font-weight: 800;
                            color: var(--mp-text);
                            margin: 0;
                        }

                        .co-card__head-sub {
                            font-size: 0.78rem;
                            color: var(--mp-text-muted);
                            margin: 2px 0 0;
                        }

                        .co-card__body {
                            padding: 24px;
                        }

                        /* ── Book info block ── */
                        .co-book {
                            display: flex;
                            gap: 20px;
                            align-items: flex-start;
                        }

                        .co-book__cover {
                            width: 72px;
                            height: 96px;
                            border-radius: 10px;
                            background: var(--mp-gradient-rich);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 2.2rem;
                            flex-shrink: 0;
                            overflow: hidden;
                            border: 1.5px solid var(--mp-border);
                            box-shadow: var(--mp-shadow);
                        }

                        .co-book__cover img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                        }

                        .co-book__meta {
                            flex: 1;
                        }

                        .co-book__title {
                            font-size: 1.12rem;
                            font-weight: 800;
                            color: var(--mp-text);
                            margin: 0 0 4px;
                            line-height: 1.35;
                        }

                        .co-book__author {
                            font-size: 0.85rem;
                            color: var(--mp-text-secondary);
                            margin: 0 0 14px;
                        }

                        .co-book__fields {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
                            gap: 8px;
                        }

                        .co-field {
                            background: var(--mp-surface-2);
                            border: 1.5px solid var(--mp-border-light);
                            border-radius: var(--mp-radius-xs);
                            padding: 9px 12px;
                        }

                        .co-field__label {
                            font-size: 0.66rem;
                            font-weight: 700;
                            letter-spacing: 0.12em;
                            text-transform: uppercase;
                            color: var(--mp-text-muted);
                            margin: 0 0 3px;
                        }

                        .co-field__value {
                            font-size: 0.88rem;
                            font-weight: 700;
                            color: var(--mp-text);
                            margin: 0;
                        }

                        .co-field__value--danger {
                            color: #dc2626;
                        }

                        /* ── Fine notice banner ── */
                        .co-fine-notice {
                            margin-top: 20px;
                            padding: 14px 18px;
                            border-radius: var(--mp-radius-sm);
                            display: flex;
                            align-items: center;
                            gap: 12px;
                        }

                        .co-fine-notice--warning {
                            background: #fffbeb;
                            border: 1.5px solid #fcd34d;
                            color: #92400e;
                        }

                        .co-fine-notice--free {
                            background: #f0fdf4;
                            border: 1.5px solid #86efac;
                            color: #15803d;
                        }

                        .co-fine-notice__icon {
                            font-size: 1.3rem;
                            flex-shrink: 0;
                        }

                        .co-fine-notice__text {
                            font-size: 0.88rem;
                            font-weight: 600;
                            margin: 0;
                        }

                        .co-fine-notice__amount {
                            margin-left: auto;
                            font-size: 1.1rem;
                            font-weight: 800;
                            white-space: nowrap;
                        }

                        /* ── Summary sidebar ── */
                        .co-summary {
                            align-self: start;
                            position: sticky;
                            top: 24px;
                        }

                        .co-summary-rows {
                            display: flex;
                            flex-direction: column;
                            gap: 0;
                        }

                        .co-summary-row {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 13px 0;
                            border-bottom: 1px solid var(--mp-border-light);
                            font-size: 0.88rem;
                        }

                        .co-summary-row:last-child {
                            border-bottom: none;
                        }

                        .co-summary-row__label {
                            color: var(--mp-text-secondary);
                        }

                        .co-summary-row__value {
                            font-weight: 700;
                            color: var(--mp-text);
                        }

                        .co-summary-total {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            padding: 18px 0 14px;
                            border-top: 2px solid var(--mp-border);
                            margin-top: 4px;
                        }

                        .co-summary-total__label {
                            font-size: 0.95rem;
                            font-weight: 700;
                            color: var(--mp-text);
                        }

                        .co-summary-total__amount {
                            font-size: 1.5rem;
                            font-weight: 800;
                            background: var(--mp-gradient);
                            -webkit-background-clip: text;
                            -webkit-text-fill-color: transparent;
                            background-clip: text;
                        }

                        .co-summary-total__amount--zero {
                            font-size: 1.5rem;
                            font-weight: 800;
                            color: #16a34a;
                        }

                        /* ── Action button ── */
                        .co-btn-confirm {
                            display: flex;
                            width: 100%;
                            align-items: center;
                            justify-content: center;
                            gap: 8px;
                            padding: 15px 20px;
                            border-radius: var(--mp-radius-sm);
                            background: var(--mp-gradient);
                            color: #fff;
                            border: none;
                            font-size: 1rem;
                            font-weight: 800;
                            cursor: pointer;
                            letter-spacing: 0.02em;
                            box-shadow: 0 8px 24px rgba(30, 58, 138, .34);
                            transition: transform 0.18s ease, box-shadow 0.18s ease, filter 0.18s ease;
                            text-decoration: none;
                            margin-top: 20px;
                        }

                        .co-btn-confirm:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 14px 36px rgba(30, 58, 138, .42);
                            filter: brightness(1.06);
                            color: #fff;
                        }

                        .co-btn-confirm:active {
                            transform: translateY(0);
                            box-shadow: 0 4px 14px rgba(30, 58, 138, .28);
                        }

                        /* ── Cancel link ── */
                        .co-cancel {
                            display: block;
                            text-align: center;
                            margin-top: 14px;
                            font-size: 0.83rem;
                            color: var(--mp-text-muted);
                            text-decoration: none;
                            transition: color 0.15s;
                        }

                        .co-cancel:hover {
                            color: var(--mp-text-secondary);
                        }

                        /* ── Wallet hint ── */
                        .co-wallet-hint {
                            margin-top: 14px;
                            padding: 10px 14px;
                            border-radius: var(--mp-radius-xs);
                            background: var(--mp-primary-xlight);
                            border: 1px solid #bfdbfe;
                            font-size: 0.8rem;
                            color: #1e40af;
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }

                        /* ── Wallet payment button ── */
                        .co-btn-wallet {
                            display: flex;
                            width: 100%;
                            align-items: center;
                            justify-content: center;
                            gap: 8px;
                            padding: 13px 20px;
                            border-radius: var(--mp-radius-sm);
                            background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
                            color: #fff;
                            border: none;
                            font-size: 0.95rem;
                            font-weight: 700;
                            cursor: pointer;
                            letter-spacing: 0.02em;
                            box-shadow: 0 6px 18px rgba(22, 163, 74, .3);
                            transition: transform 0.18s ease, box-shadow 0.18s ease, filter 0.18s ease;
                            text-decoration: none;
                            margin-top: 10px;
                        }

                        .co-btn-wallet:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 12px 28px rgba(22, 163, 74, .38);
                            filter: brightness(1.05);
                            color: #fff;
                        }

                        .co-payment-divider {
                            display: flex;
                            align-items: center;
                            gap: 10px;
                            margin: 14px 0 4px;
                            color: var(--mp-text-muted);
                            font-size: 0.75rem;
                            text-transform: uppercase;
                            letter-spacing: 0.1em;
                        }

                        .co-payment-divider::before,
                        .co-payment-divider::after {
                            content: '';
                            flex: 1;
                            height: 1px;
                            background: var(--mp-border);
                        }

                        /* ── Fine-mode note ── */
                        .co-finemode-note {
                            padding: 10px 14px;
                            background: #fef9c3;
                            border: 1.5px solid #fde047;
                            border-radius: var(--mp-radius-xs);
                            font-size: 0.82rem;
                            color: #713f12;
                            font-weight: 600;
                            margin-bottom: 18px;
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }
                    </style>
                </head>

                <body class="mp-body">

                    <jsp:include page="/WEB-INF/views/header.jsp" />

                    <!-- ═══ HERO ═══ -->
                    <section class="mp-hero">
                        <div class="mp-hero__inner">
                            <div>
                                <p class="mp-hero__eyebrow">
                                    <c:choose>
                                        <c:when test="${fineMode}">Thanh toán phí phạt</c:when>
                                        <c:otherwise>Trả sách</c:otherwise>
                                    </c:choose>
                                </p>
                                <h1 class="mp-hero__title">
                                    <c:choose>
                                        <c:when test="${fineMode}">Thanh toán phí phạt</c:when>
                                        <c:otherwise>Xác nhận trả sách</c:otherwise>
                                    </c:choose>
                                </h1>
                                <p class="mp-hero__subtitle">
                                    <c:choose>
                                        <c:when test="${fineMode}">Phiếu mượn đã được trả về. Vui lòng hoàn tất khoản
                                            phí phạt còn lại.</c:when>
                                        <c:otherwise>Kiểm tra thông tin phiếu mượn và số tiền phạt (nếu có) trước khi
                                            xác nhận.</c:otherwise>
                                    </c:choose>
                                </p>
                            </div>
                            <div class="mp-hero__cards">
                                <div class="mp-hero__card">
                                    <p class="mp-hero__card-label">Phiếu mượn</p>
                                    <p class="mp-hero__card-value">#${borrowRecord.id}</p>
                                    <p class="mp-hero__card-detail">
                                        <c:choose>
                                            <c:when test="${fineMode}">Đang chờ thanh toán phạt</c:when>
                                            <c:otherwise>Sẵn sàng để trả</c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <!-- ═══ CONTENT ═══ -->
                    <div class="co-layout">

                        <!-- Step breadcrumb -->
                        <div class="co-steps">
                            <div class="co-step is-done">
                                <span class="co-step__num">✓</span>
                                <span>Chọn sách</span>
                            </div>
                            <div class="co-step__sep"></div>
                            <div class="co-step is-active">
                                <span class="co-step__num">2</span>
                                <span>Xác nhận</span>
                            </div>
                            <div class="co-step__sep"></div>
                            <div class="co-step">
                                <span class="co-step__num">3</span>
                                <span>Hoàn tất</span>
                            </div>
                        </div>

                        <!-- Flash message -->
                        <c:if test="${not empty flash}">
                            <div class="mp-flash mp-flash--error" style="grid-column: 1 / -1;">
                                ⚠ ${flash}
                                <button class="mp-flash__close" onclick="this.parentElement.remove()">×</button>
                            </div>
                        </c:if>

                        <!-- ── Left: Book details ── -->
                        <div>
                            <c:if test="${fineMode}">
                                <div class="co-finemode-note">
                                    ⚠️ Sách đã được trả vật lý. Chỉ còn khoản phí phạt cần thanh toán.
                                </div>
                            </c:if>

                            <div class="co-card">
                                <div class="co-card__head">
                                    <div class="co-card__head-icon">📖</div>
                                    <div>
                                        <p class="co-card__head-title">Thông tin phiếu mượn</p>
                                        <p class="co-card__head-sub">Chi tiết sách và thời hạn mượn</p>
                                    </div>
                                </div>
                                <div class="co-card__body">
                                    <div class="co-book">
                                        <div class="co-book__cover">
                                            <c:choose>
                                                <c:when test="${not empty borrowRecord.book.image}">
                                                    <c:choose>
                                                        <c:when
                                                            test="${fn:startsWith(borrowRecord.book.image, 'http')}">
                                                            <img src="${borrowRecord.book.image}"
                                                                alt="${borrowRecord.book.title}" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            <img src="${pageContext.request.contextPath}/${borrowRecord.book.image}"
                                                                alt="${borrowRecord.book.title}" />
                                                        </c:otherwise>
                                                    </c:choose>
                                                </c:when>
                                                <c:otherwise>📚</c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="co-book__meta">
                                            <h2 class="co-book__title">${borrowRecord.book.title}</h2>
                                            <p class="co-book__author">Tác giả: ${borrowRecord.book.author}</p>
                                            <div class="co-book__fields">
                                                <div class="co-field">
                                                    <p class="co-field__label">Ngày mượn</p>
                                                    <p class="co-field__value">${borrowRecord.borrowDate}</p>
                                                </div>
                                                <div class="co-field">
                                                    <p class="co-field__label">Hạn trả</p>
                                                    <p class="co-field__value co-field__value--danger">
                                                        ${borrowRecord.dueDate}</p>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Fine notice -->
                                    <c:choose>
                                        <c:when test="${fineAmount != null && fineAmount > 0}">
                                            <div class="co-fine-notice co-fine-notice--warning">
                                                <span class="co-fine-notice__icon">⚠️</span>
                                                <p class="co-fine-notice__text">Phí phạt trả trễ áp dụng cho phiếu mượn
                                                    này</p>
                                                <span class="co-fine-notice__amount">
                                                    <fmt:formatNumber value="${fineAmount}" pattern="#,##0" /> ₫
                                                </span>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="co-fine-notice co-fine-notice--free">
                                                <span class="co-fine-notice__icon">✅</span>
                                                <p class="co-fine-notice__text">Không có phí phạt — trả đúng hạn!</p>
                                                <span class="co-fine-notice__amount">0 ₫</span>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>

                        <!-- ── Right: Summary sidebar ── -->
                        <aside class="co-summary">
                            <div class="co-card">
                                <div class="co-card__head">
                                    <div class="co-card__head-icon">🧾</div>
                                    <div>
                                        <p class="co-card__head-title">Tóm tắt</p>
                                        <p class="co-card__head-sub">Chi tiết thanh toán</p>
                                    </div>
                                </div>
                                <div class="co-card__body">
                                    <div class="co-summary-rows">
                                        <div class="co-summary-row">
                                            <span class="co-summary-row__label">Mã phiếu mượn</span>
                                            <span class="co-summary-row__value">#${borrowRecord.id}</span>
                                        </div>
                                        <div class="co-summary-row">
                                            <span class="co-summary-row__label">Loại giao dịch</span>
                                            <span class="co-summary-row__value">
                                                <c:choose>
                                                    <c:when test="${fineMode}">Thanh toán phạt</c:when>
                                                    <c:otherwise>Trả sách</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                        <div class="co-summary-row">
                                            <span class="co-summary-row__label">Phí phạt</span>
                                            <span class="co-summary-row__value">
                                                <fmt:formatNumber value="${fineAmount != null ? fineAmount : 0}"
                                                    pattern="#,##0" /> ₫
                                            </span>
                                        </div>
                                    </div>

                                    <div class="co-summary-total">
                                        <span class="co-summary-total__label">Tổng cộng</span>
                                        <c:choose>
                                            <c:when test="${fineAmount != null && fineAmount > 0}">
                                                <span class="co-summary-total__amount">
                                                    <fmt:formatNumber value="${fineAmount}" pattern="#,##0" /> ₫
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="co-summary-total__amount--zero">Miễn phí</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/checkout/process" method="post">
                                        <input type="hidden" name="borrowId" value="${borrowRecord.id}" />
                                        <input type="hidden" name="mode" value="${mode}" />
                                        <button type="submit" class="co-btn-confirm">
                                            💳 Thanh toán qua VNPay
                                        </button>
                                    </form>

                                    <c:if test="${fineAmount != null && fineAmount > 0}">
                                        <div class="co-payment-divider">hoặc</div>
                                        <form action="${pageContext.request.contextPath}/checkout/pay-wallet"
                                            method="post">
                                            <input type="hidden" name="borrowId" value="${borrowRecord.id}" />
                                            <input type="hidden" name="mode" value="${mode}" />
                                            <button type="submit" class="co-btn-wallet">
                                                💰 Thanh toán bằng Ví
                                                <c:if test="${sessionScope.currentUser != null}">
                                                    (
                                                    <fmt:formatNumber
                                                        value="${sessionScope.currentUser.walletBalance != null ? sessionScope.currentUser.walletBalance : 0}"
                                                        pattern="#,##0" /> ₫)
                                                </c:if>
                                            </button>
                                        </form>
                                    </c:if>

                                    <a href="${pageContext.request.contextPath}/history" class="co-cancel">
                                        ← Hủy bỏ &amp; Quay lại
                                    </a>

                                    <div class="co-wallet-hint">
                                        💡 Chọn thanh toán qua VNPay hoặc dùng số dư ví LBMS.
                                    </div>
                                </div>
                            </div>
                        </aside>
                    </div>

                    <jsp:include page="/WEB-INF/views/footer.jsp" />

                </body>

                </html>