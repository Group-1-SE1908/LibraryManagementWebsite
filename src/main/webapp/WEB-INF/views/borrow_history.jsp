<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Lịch sử mượn sách | LBMS Portal</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
                    <style>
                        /* ── Order detail modal ── */
                        .order-modal {
                            position: fixed;
                            inset: 0;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            padding: 1.5rem;
                            z-index: 60;
                            pointer-events: none;
                        }

                        .order-modal[hidden] {
                            display: none;
                        }

                        .order-modal__backdrop {
                            position: absolute;
                            inset: 0;
                            background: rgba(15, 23, 42, .6);
                            backdrop-filter: blur(6px);
                            pointer-events: all;
                        }

                        .order-modal__panel {
                            position: relative;
                            background: #fff;
                            border-radius: 24px;
                            padding: 2rem;
                            width: min(540px, 100%);
                            box-shadow: 0 40px 100px rgba(15, 23, 42, .28);
                            border: 1.5px solid rgba(37, 99, 235, .12);
                            pointer-events: all;
                            display: grid;
                            gap: 16px;
                            animation: orderModalIn .25s cubic-bezier(.34, 1.56, .64, 1);
                        }

                        @keyframes orderModalIn {
                            from {
                                opacity: 0;
                                transform: translateY(14px) scale(.97);
                            }

                            to {
                                opacity: 1;
                                transform: translateY(0) scale(1);
                            }
                        }

                        .order-modal__pill {
                            font-size: .63rem;
                            text-transform: uppercase;
                            letter-spacing: .45em;
                            color: var(--mp-primary);
                            font-weight: 700;
                        }

                        .order-modal__title {
                            margin: 0;
                            font-size: 1.4rem;
                            font-weight: 800;
                            color: var(--mp-text);
                        }

                        .order-modal__method {
                            margin: 0;
                            font-weight: 600;
                            letter-spacing: .04em;
                            color: var(--mp-text-secondary);
                            font-size: .9rem;
                        }

                        .order-modal__grid {
                            display: grid;
                            gap: 10px;
                        }

                        .order-modal__row {
                            border-radius: var(--mp-radius-sm);
                            border: 1.5px solid var(--mp-border-light);
                            padding: 12px 16px;
                            background: #fafbff;
                            transition: border-color .2s;
                        }

                        .order-modal__row:hover {
                            border-color: #bfdbfe;
                        }

                        .order-modal__row span {
                            font-size: .67rem;
                            letter-spacing: .18em;
                            text-transform: uppercase;
                            color: var(--mp-text-muted);
                            font-weight: 600;
                        }

                        .order-modal__row strong {
                            display: block;
                            margin-top: 5px;
                            font-size: .95rem;
                            color: var(--mp-text);
                            font-weight: 700;
                        }

                        .order-modal__row[hidden] {
                            display: none;
                        }

                        .order-modal__close {
                            position: absolute;
                            top: 14px;
                            right: 14px;
                            border: none;
                            background: rgba(15, 23, 42, .07);
                            border-radius: 50%;
                            width: 36px;
                            height: 36px;
                            font-size: 1.15rem;
                            line-height: 1;
                            cursor: pointer;
                            color: var(--mp-text);
                            transition: background .2s;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }

                        .order-modal__close:hover {
                            background: rgba(15, 23, 42, .14);
                        }

                        /* ── Renewal history modal ── */
                        .renewal-history-store {
                            display: none;
                        }

                        .renewal-history-modal {
                            position: fixed;
                            inset: 0;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            padding: 1.5rem;
                            z-index: 70;
                            pointer-events: none;
                        }

                        .renewal-history-modal[hidden] {
                            display: none;
                        }

                        .renewal-history-modal__backdrop {
                            position: absolute;
                            inset: 0;
                            background: rgba(15, 23, 42, .55);
                            backdrop-filter: blur(6px);
                            pointer-events: all;
                        }

                        .renewal-history-modal__panel {
                            position: relative;
                            background: #fff;
                            border-radius: 24px;
                            padding: 1.75rem;
                            width: min(580px, 100%);
                            box-shadow: 0 40px 100px rgba(15, 23, 42, .25);
                            border: 1.5px solid rgba(37, 99, 235, .1);
                            pointer-events: all;
                            display: grid;
                            gap: 16px;
                            max-height: 72vh;
                            overflow: auto;
                        }

                        .renewal-history-modal__list {
                            display: grid;
                            gap: 14px;
                            max-height: 50vh;
                            overflow-y: auto;
                            padding-right: 4px;
                        }

                        .renewal-history-record {
                            padding-bottom: 14px;
                            border-bottom: 1.5px solid var(--mp-border-light);
                        }

                        .renewal-history-record:last-child {
                            border-bottom: none;
                            padding-bottom: 0;
                        }

                        .renewal-history-record__meta,
                        .renewal-history-record__contact,
                        .renewal-history-record__shipping,
                        .renewal-history-record__date {
                            display: flex;
                            justify-content: space-between;
                            gap: 8px;
                            flex-wrap: wrap;
                            font-size: .85rem;
                            color: var(--mp-text);
                        }

                        .renewal-history-record__label {
                            font-size: .66rem;
                            letter-spacing: .18em;
                            text-transform: uppercase;
                            color: var(--mp-text-muted);
                            font-weight: 600;
                        }

                        .renewal-history-record__shipping {
                            margin-top: 6px;
                        }

                        .renewal-history-record__value {
                            font-weight: 700;
                            color: var(--mp-text);
                        }

                        .renewal-history-record__reason {
                            color: var(--mp-text-secondary);
                            font-size: .88rem;
                            margin-top: 8px;
                        }

                        /* ── Renew request modal ── */
                        .renew-modal {
                            position: fixed;
                            inset: 0;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            padding: 1.5rem;
                            z-index: 68;
                            pointer-events: none;
                        }

                        .renew-modal[hidden] {
                            display: none;
                        }

                        .renew-modal__backdrop {
                            position: absolute;
                            inset: 0;
                            background: rgba(15, 23, 42, .6);
                            backdrop-filter: blur(6px);
                            pointer-events: all;
                        }

                        .renew-modal__panel {
                            position: relative;
                            background: #fff;
                            border-radius: 24px;
                            padding: 2rem;
                            width: min(540px, 100%);
                            box-shadow: 0 40px 100px rgba(15, 23, 42, .26);
                            border: 1.5px solid rgba(37, 99, 235, .1);
                            pointer-events: all;
                            display: grid;
                            gap: 14px;
                            animation: orderModalIn .25s cubic-bezier(.34, 1.56, .64, 1);
                        }

                        .renew-form {
                            display: grid;
                            gap: 12px;
                        }

                        .renew-form textarea {
                            min-height: 120px;
                            resize: vertical;
                        }

                        .renew-form__actions {
                            display: flex;
                            justify-content: flex-end;
                            gap: 10px;
                        }

                        .mp-card__action .js-show-order {
                            min-width: 160px;
                        }

                        .renewal-cancel-form {
                            display: inline-block;
                        }
                    </style>
                </head>

                <body class="mp-body">
                    <jsp:include page="header.jsp" />
                    <c:set var="currentUser" value="${sessionScope.currentUser}" />

                    <section class="mp-hero" aria-label="Lịch sử mượn">
                        <div class="mp-hero__inner">
                            <div>
                                <p class="mp-hero__eyebrow">📚 Lịch sử mượn sách</p>
                                <h1 class="mp-hero__title">Mọi hành trình đọc sách của bạn</h1>
                                <p class="mp-hero__subtitle">Theo dõi trạng thái mượn, lịch sử gia hạn và quay lại
                                    những cuốn sách yêu thích — tất cả chỉ trong một nơi.</p>
                            </div>
                            <div class="mp-hero__cards">
                                <c:set var="historyTotalCopies"
                                    value="${historyTotalCopies != null ? historyTotalCopies : 0}" />
                                <div class="mp-hero__card">
                                    <p class="mp-hero__card-label">Tổng giao dịch</p>
                                    <p class="mp-hero__card-value">${historyTotalCopies}</p>
                                    <p class="mp-hero__card-detail">phiếu mượn</p>
                                </div>
                                <div class="mp-hero__card">
                                    <p class="mp-hero__card-label">Lần gia hạn</p>
                                    <p class="mp-hero__card-value">${renewCount != null ? renewCount : '—'}</p>
                                    <p class="mp-hero__card-detail">tổng yêu cầu</p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <section class="mp-content">
                        <c:if test="${not empty flash}">
                            <div class="mp-flash">${flash}</div>
                        </c:if>

                        <c:set var="historyStatusFilter"
                            value="${historyStatusFilter != null ? historyStatusFilter : 'all'}" />
                        <div class="mp-filters">
                            <a class="mp-pill ${historyStatusFilter == 'all' ? 'is-active' : ''}"
                                href="${pageContext.request.contextPath}/history">Tất cả</a>
                            <a class="mp-pill ${historyStatusFilter == 'borrowing' ? 'is-active' : ''}"
                                href="${pageContext.request.contextPath}/history?status=borrowing">Đang mượn</a>
                            <a class="mp-pill ${historyStatusFilter == 'pending' ? 'is-active' : ''}"
                                href="${pageContext.request.contextPath}/history?status=pending">Đang duyệt</a>
                            <a class="mp-pill ${historyStatusFilter == 'returned' ? 'is-active' : ''}"
                                href="${pageContext.request.contextPath}/history?status=returned">Đã trả</a>
                        </div>

                        <c:choose>
                            <c:when test="${historyTotalCopies > 0}">
                                <div class="mp-cards">
                                    <c:forEach items="${historyEntries}" var="entry">
                                        <c:set var="r" value="${entry.record}" />
                                        <c:set var="statusClass">
                                            <c:choose>
                                                <c:when
                                                    test="${fn:toUpperCase(r.status) == 'BORROWED' || fn:toUpperCase(r.status) == 'APPROVED' || fn:toUpperCase(r.status) == 'RECEIVED'}">
                                                    mp-status-pill--borrowed
                                                </c:when>
                                                <c:when test="${fn:toUpperCase(r.status) == 'SHIPPING'}">
                                                    mp-status-pill--shipping</c:when>
                                                <c:when test="${fn:toUpperCase(r.status) == 'RETURNED'}">
                                                    mp-status-pill--returned
                                                </c:when>
                                                <c:when test="${fn:toUpperCase(r.status) == 'REQUESTED'}">
                                                    mp-status-pill--pending</c:when>
                                                <c:when test="${fn:toUpperCase(r.status) == 'RENEWAL_REQUESTED'}">
                                                    mp-status-pill--pending</c:when>
                                                <c:otherwise>mp-status-pill--muted</c:otherwise>
                                            </c:choose>
                                        </c:set>
                                        <c:set var="methodCode" value="${fn:toUpperCase(r.borrowMethod)}" />
                                        <c:set var="shipping" value="${r.shippingDetails}" />
                                        <article class="mp-card" data-copy-index="${entry.copyIndex}"
                                            data-copy-count="${entry.copyCount}">
                                            <div class="mp-card__banner">
                                                <div>
                                                    <p class="mp-card__eyebrow">Phiếu #${r.id}</p>
                                                    <h2>${r.book.title}</h2>
                                                    <p class="mp-card__author">${r.book.author}</p>
                                                    <c:if test="${entry.copyCount > 1}">
                                                        <p class="mp-card__copy-badge">Bản sao
                                                            ${entry.copyIndex}/${entry.copyCount}</p>
                                                    </c:if>
                                                </div>
                                                <span class="mp-status-pill ${statusClass}">${r.status}</span>
                                            </div>

                                            <div class="mp-card__poster">
                                                <c:choose>
                                                    <c:when test="${not empty r.book.image}">
                                                        <img src="${pageContext.request.contextPath}/${r.book.image}"
                                                            alt="${r.book.title}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="mp-card__poster-ph">📖</div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <div class="mp-card__body">
                                                <div class="mp-card__field">
                                                    <span>Ngày mượn</span>
                                                    <strong>${r.borrowDate}</strong>
                                                </div>
                                                <div class="mp-card__field">
                                                    <span>Hạn trả</span>
                                                    <strong>${r.dueDate}</strong>
                                                </div>
                                                <div class="mp-card__field">
                                                    <span>Người mượn</span>
                                                    <strong>${r.user.fullName}</strong>
                                                </div>
                                                <div class="mp-card__field">
                                                    <span>Trạng thái mượn</span>
                                                    <strong>${r.status}</strong>
                                                </div>
                                                <div class="mp-card__field">
                                                    <span>Phạt</span>
                                                    <strong>
                                                        <c:choose>
                                                            <c:when test="${not empty r.fineAmount}">${r.fineAmount} VND
                                                            </c:when>
                                                            <c:otherwise>0 VND</c:otherwise>
                                                        </c:choose>
                                                    </strong>
                                                </div>
                                            </div>

                                            <div class="mp-card__actions">
                                                <div class="mp-card__action">
                                                    <button class="btn primary js-show-order" type="button"
                                                        data-method="${methodCode}"
                                                        data-recipient="${shipping != null && not empty shipping.recipient ? shipping.recipient : ''}"
                                                        data-shipping-phone="${shipping != null && not empty shipping.phone ? shipping.phone : ''}"
                                                        data-address="${shipping != null && not empty shipping.formattedAddress ? shipping.formattedAddress : ''}"
                                                        data-user-phone="${not empty r.user.phone ? r.user.phone : ''}"
                                                        data-borrow-date="${not empty r.borrowDate ? r.borrowDate : ''}"
                                                        data-deposit="<fmt:formatNumber value=" ${r.depositAmount !=null
                                                        ? r.depositAmount : 0}" pattern="#,##0" /> ₫"
                                                    data-copy-index="${entry.copyIndex}">Xem đơn hàng
                                                    </button>
                                                </div>
                                                <c:if test="${fn:toUpperCase(r.status) == 'RECEIVED'}">
                                                    <div class="mp-card__action">
                                                        <button class="btn btn-outline" type="button" data-open-renewal
                                                            data-borrow-id="${r.id}"
                                                            data-contact-name="${not empty currentUser.fullName ? fn:escapeXml(currentUser.fullName) : ''}"
                                                            data-contact-phone="${not empty currentUser.phone ? fn:escapeXml(currentUser.phone) : ''}"
                                                            data-contact-email="${not empty currentUser.email ? fn:escapeXml(currentUser.email) : ''}">
                                                            Gia hạn
                                                        </button>
                                                    </div>
                                                </c:if>

                                                <c:if test="${fn:toUpperCase(r.status) == 'RENEWAL_REQUESTED'}">
                                                    <div class="mp-card__action">
                                                        <form class="renewal-cancel-form" method="post"
                                                            action="${pageContext.request.contextPath}/borrow/renew/cancel"
                                                            onsubmit="return confirm('Bạn có chắc chắn muốn hủy yêu cầu gia hạn không?');">
                                                            <input type="hidden" name="borrowId" value="${r.id}" />
                                                            <button class="btn danger" type="submit">Hủy gia
                                                                hạn</button>
                                                        </form>
                                                    </div>
                                                </c:if>
                                                <c:if
                                                    test="${fn:toUpperCase(r.status) == 'BORROWED' || fn:toUpperCase(r.status) == 'RECEIVED'}">
                                                    <div class="mp-card__action">
                                                        <a class="btn success"
                                                            href="${pageContext.request.contextPath}/checkout?borrowId=${r.id}">Trả
                                                            sách & Thanh toán</a>
                                                    </div>
                                                </c:if>
                                                <c:if
                                                    test="${fn:toUpperCase(r.status) == 'REQUESTED' && fn:toUpperCase(r.borrowMethod) != 'ONLINE'}">
                                                    <div class="mp-card__action">
                                                        <button class="btn danger" type="button"
                                                            onclick="confirmCancel(${r.id})">Hủy yêu cầu
                                                        </button>
                                                    </div>
                                                </c:if>
                                            </div>
                                            <c:if test="${not empty renewalHistory[r.id]}">
                                                <div class="renewal-history-store" data-history-store
                                                    data-borrow-id="${r.id}" hidden>
                                                    <c:forEach items="${renewalHistory[r.id]}" var="renewal">
                                                        <article class="renewal-history-record">
                                                            <div class="renewal-history-record__meta">
                                                                <span class="renewal-history-record__label">Trạng
                                                                    thái</span>
                                                                <strong
                                                                    class="renewal-history-record__value">${renewal.status}</strong>
                                                            </div>
                                                            <p class="renewal-history-record__reason">
                                                                <c:out value="${renewal.reason}"
                                                                    default="Không có lý do" />
                                                            </p>
                                                            <div class="renewal-history-record__contact">
                                                                <span class="renewal-history-record__label">Liên
                                                                    hệ</span>
                                                                <strong class="renewal-history-record__value">
                                                                    <c:out
                                                                        value="${not empty renewal.contactName ? renewal.contactName : r.user.fullName}"
                                                                        default="Không có tên" /> ·
                                                                    <c:out
                                                                        value="${not empty renewal.contactPhone ? renewal.contactPhone : r.user.phone}"
                                                                        default="Không có số" />
                                                                    <c:if test="${not empty renewal.contactEmail}">
                                                                        ·
                                                                        <c:out value="${renewal.contactEmail}" />
                                                                    </c:if>
                                                                </strong>
                                                            </div>
                                                            <c:if
                                                                test="${shipping != null && (not empty shipping.formattedAddress || not empty shipping.phone)}">
                                                                <div class="renewal-history-record__shipping">
                                                                    <span class="renewal-history-record__label">Địa chỉ
                                                                        giao</span>
                                                                    <strong class="renewal-history-record__value">
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${not empty shipping.formattedAddress}">
                                                                                <c:out
                                                                                    value="${shipping.formattedAddress}" />
                                                                            </c:when>
                                                                            <c:otherwise>Chưa có địa chỉ</c:otherwise>
                                                                        </c:choose>
                                                                    </strong>
                                                                </div>
                                                                <c:if test="${not empty shipping.phone}">
                                                                    <div class="renewal-history-record__shipping">
                                                                        <span class="renewal-history-record__label">SĐT
                                                                            giao hàng</span>
                                                                        <strong class="renewal-history-record__value">
                                                                            <c:out value="${shipping.phone}" />
                                                                        </strong>
                                                                    </div>
                                                                </c:if>
                                                            </c:if>
                                                            <div class="renewal-history-record__date">
                                                                <span class="renewal-history-record__label">Gửi
                                                                    lúc</span>
                                                                <strong class="renewal-history-record__value">
                                                                    <c:choose>
                                                                        <c:when test="${not empty renewal.requestedAt}">
                                                                            <c:set var="submittedAt"
                                                                                value="${fn:replace(renewal.requestedAt, 'T', ' ')}" />
                                                                            ${submittedAt}
                                                                        </c:when>
                                                                        <c:otherwise>Chưa ghi</c:otherwise>
                                                                    </c:choose>
                                                                </strong>
                                                            </div>
                                                        </article>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                        </article>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="mp-empty mp-empty--dashed">
                                    <h2>Bạn chưa mượn cuốn sách nào?</h2>
                                    <p>Kéo đến thư viện số của chúng tôi để khám phá, chọn sách và bắt đầu hành trình
                                        học
                                        tập.</p>
                                    <a class="btn primary" href="${pageContext.request.contextPath}/books">Khám phá
                                        Catalog</a>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </section>

                    <div id="order-modal" class="order-modal" hidden aria-hidden="true">
                        <div class="order-modal__backdrop" data-dismiss="true"></div>
                        <div class="order-modal__panel" role="dialog" aria-modal="true"
                            aria-labelledby="order-modal-title" tabindex="-1">
                            <button type="button" class="order-modal__close"
                                aria-label="Đóng chi tiết đơn hàng">×</button>
                            <p class="order-modal__pill">Thông tin đơn hàng</p>
                            <h3 id="order-modal-title" class="order-modal__title">Đơn hàng</h3>
                            <p class="order-modal__method">Chưa chọn đơn hàng</p>
                            <div class="order-modal__grid">
                                <div class="order-modal__row" data-field="recipient">
                                    <span>Người nhận</span>
                                    <strong data-value="recipient">Chưa cung cấp</strong>
                                </div>
                                <div class="order-modal__row" data-field="shipping-phone">
                                    <span>Điện thoại nhận hàng</span>
                                    <strong data-value="shippingPhone">Chưa cung cấp</strong>
                                </div>
                                <div class="order-modal__row" data-field="address">
                                    <span>Địa chỉ giao</span>
                                    <strong data-value="address">Chưa cung cấp</strong>
                                </div>
                                <div class="order-modal__row" data-field="contact-phone">
                                    <span>Điện thoại liên hệ</span>
                                    <strong data-value="contactPhone">Chưa cung cấp</strong>
                                </div>
                                <div class="order-modal__row" data-field="borrow-date">
                                    <span>Ngày mượn</span>
                                    <strong data-value="borrowDate">Đang chờ</strong>
                                </div>
                                <div class="order-modal__row" data-field="deposit">
                                    <span>Tiền cọc</span>
                                    <strong data-value="deposit">0 ₫</strong>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="renew-modal" hidden data-renew-modal>
                        <div class="renew-modal__backdrop" data-renew-backdrop></div>
                        <div class="renew-modal__panel" role="dialog" aria-modal="true"
                            aria-labelledby="renew-modal-title" tabindex="-1">
                            <button type="button" class="order-modal__close renew-modal__close" data-dismiss-renewal
                                aria-label="Đóng form gia hạn">×
                            </button>
                            <p class="order-modal__pill">Gia hạn mượn</p>
                            <h3 id="renew-modal-title" class="order-modal__title">Gửi yêu cầu gia hạn sách</h3>
                            <p class="order-modal__method">Lý do và thông tin liên hệ sẽ được thủ thư xem xét trước khi
                                duyệt.</p>

                            <div class="renew-due-info">

                                <span class="renew-due-info__text">
                                    Lưu ý ngày trả mới sau khi gia hạn : <strong data-renew-new-date>—</strong>
                                    <em>Sẽ là thêm 14 ngày so với hạn trả</em>
                                </span>
                            </div>
                            <form class="renew-form" method="post"
                                action="${pageContext.request.contextPath}/borrow/renew" data-renew-form>
                                <input type="hidden" name="borrowId" />
                                <label class="form-group">
                                    <span>Họ và tên</span>
                                    <input type="text" name="contactName" readonly placeholder="Họ tên người nhận" />
                                </label>
                                <label class="form-group">
                                    <span>Số điện thoại</span>
                                    <input type="tel" name="contactPhone" readonly inputmode="tel"
                                        pattern="[0-9]{10,11}" placeholder="0912345678" />
                                </label>
                                <label class="form-group">
                                    <span>Email</span>
                                    <input type="email" name="contactEmail" readonly placeholder="mail@domain.com" />
                                </label>
                                <label class="form-group">
                                    <span>Lý do mượn lại</span>
                                    <textarea name="reason" required
                                        placeholder="Cho thủ thư biết vì sao bạn cần giữ thêm sách"></textarea>
                                </label>
                                <div class="renew-form__actions">
                                    <button type="button" class="btn ghost small" data-dismiss-renewal>Hủy</button>
                                    <button type="submit" class="btn primary">Gửi yêu cầu</button>
                                </div>
                            </form>
                        </div>
                    </div>
                    <div class="renewal-history-modal" hidden data-renewal-history-modal>
                        <div class="renewal-history-modal__backdrop" data-renewal-history-dismiss></div>
                        <div class="renewal-history-modal__panel" role="dialog" aria-modal="true"
                            aria-labelledby="renewal-history-title" tabindex="-1">
                            <button type="button" class="order-modal__close" aria-label="Đóng lịch sử yêu cầu"
                                data-renewal-history-close>
                                ×
                            </button>
                            <p class="order-modal__pill">Lịch sử gia hạn</p>
                            <h3 id="renewal-history-title" class="order-modal__title">Các yêu cầu đã gửi</h3>
                            <p class="order-modal__method">Thông tin dưới đây giúp bạn nhớ lại lý do và trạng thái đã
                                gửi trước đó.</p>
                            <div class="renewal-history-modal__list" data-history-list>
                                <p class="muted">Chưa có yêu cầu gia hạn nào.</p>
                            </div>
                        </div>
                    </div>
                    <script>
                        (function () {
                            var modal = document.getElementById('order-modal');
                            if (!modal) {
                                return;
                            }
                            var modalPanel = modal.querySelector('.order-modal__panel');
                            var methodLabel = modal.querySelector('.order-modal__method');
                            var recipientRow = modal.querySelector('[data-field="recipient"]');
                            var shippingRow = modal.querySelector('[data-field="shipping-phone"]');
                            var addressRow = modal.querySelector('[data-field="address"]');
                            var contactRow = modal.querySelector('[data-field="contact-phone"]');
                            var borrowDateRow = modal.querySelector('[data-field="borrow-date"]');
                            var depositRow = modal.querySelector('[data-field="deposit"]');
                            var recipientValue = modal.querySelector('[data-value="recipient"]');
                            var shippingValue = modal.querySelector('[data-value="shippingPhone"]');
                            var addressValue = modal.querySelector('[data-value="address"]');
                            var contactValue = modal.querySelector('[data-value="contactPhone"]');
                            var borrowDateValue = modal.querySelector('[data-value="borrowDate"]');
                            var depositValue = modal.querySelector('[data-value="deposit"]');
                            var closeButton = modal.querySelector('.order-modal__close');

                            function getValue(raw, fallback) {
                                if (!raw) {
                                    return fallback;
                                }
                                var trimmed = raw.trim();
                                return trimmed.length ? trimmed : fallback;
                            }

                            function closeModal() {
                                modal.hidden = true;
                                modal.setAttribute('aria-hidden', 'true');
                            }

                            function openModal(dataset) {
                                var method = (dataset.method || '').toUpperCase();
                                var isOnline = method === 'ONLINE';
                                methodLabel.textContent = isOnline ? 'Giao hàng' : 'Nhận tại thư viện';
                                if (isOnline) {
                                    recipientRow.hidden = false;
                                    shippingRow.hidden = false;
                                    addressRow.hidden = false;
                                    contactRow.hidden = true;
                                    borrowDateRow.hidden = true;
                                    depositRow.hidden = false;
                                } else {
                                    recipientRow.hidden = true;
                                    shippingRow.hidden = true;
                                    addressRow.hidden = true;
                                    contactRow.hidden = false;
                                    borrowDateRow.hidden = false;
                                    depositRow.hidden = true;
                                }
                                recipientValue.textContent = getValue(dataset.recipient, 'Chưa cung cấp');
                                var phoneFallback = getValue(dataset.userPhone, 'Chưa cung cấp');
                                shippingValue.textContent = getValue(dataset.shippingPhone, phoneFallback);
                                addressValue.textContent = getValue(dataset.address, 'Chưa cung cấp');
                                contactValue.textContent = getValue(dataset.userPhone, 'Chưa cung cấp');
                                borrowDateValue.textContent = getValue(dataset.borrowDate, 'Đang chờ');
                                depositValue.textContent = getValue(dataset.deposit, '0 ₫');
                                modal.hidden = false;
                                modal.setAttribute('aria-hidden', 'false');
                                if (modalPanel) {
                                    modalPanel.focus();
                                }
                            }

                            document.addEventListener('click', function (event) {
                                var trigger = event.target.closest('.js-show-order');
                                if (!trigger) {
                                    return;
                                }
                                event.preventDefault();
                                openModal(trigger.dataset);
                            });
                            if (closeButton) {
                                closeButton.addEventListener('click', closeModal);
                            }
                            modal.addEventListener('click', function (event) {
                                if (event.target.dataset.dismiss === 'true') {
                                    closeModal();
                                }
                            });
                            document.addEventListener('keydown', function (event) {
                                if (event.key === 'Escape' && !modal.hidden) {
                                    closeModal();
                                }
                            });
                        })();

                        function confirmCancel(id) {
                            if (confirm('Bạn có chắc chắn muốn hủy yêu cầu mượn này không?')) {
                                window.location.href = '${pageContext.request.contextPath}/borrow/cancel?id=' + id;
                            }
                        }
                    </script>
                    <script>
                        (function () {
                            const modal = document.querySelector('[data-renew-modal]');
                            if (!modal) {
                                return;
                            }
                            const form = modal.querySelector('[data-renew-form]');
                            const borrowInput = form.querySelector('[name="borrowId"]');
                            const contactNameInput = form.querySelector('[name="contactName"]');
                            const contactPhoneInput = form.querySelector('[name="contactPhone"]');
                            const contactEmailInput = form.querySelector('[name="contactEmail"]');
                            const reasonInput = form.querySelector('[name="reason"]');
                            const backdrop = modal.querySelector('[data-renew-backdrop]');
                            const closeControls = modal.querySelectorAll('[data-dismiss-renewal]');

                            const openModal = (trigger) => {
                                borrowInput.value = trigger.dataset.borrowId || '';
                                contactNameInput.value = trigger.dataset.contactName || '';
                                contactPhoneInput.value = trigger.dataset.contactPhone || '';
                                contactEmailInput.value = trigger.dataset.contactEmail || '';
                                reasonInput.value = '';
                                modal.hidden = false;
                                document.body.classList.add('modal-open');
                                reasonInput.focus();
                            };

                            const closeModal = () => {
                                if (modal.hidden) {
                                    return;
                                }
                                modal.hidden = true;
                                document.body.classList.remove('modal-open');
                            };

                            closeControls.forEach(control => control.addEventListener('click', closeModal));
                            backdrop?.addEventListener('click', closeModal);

                            document.addEventListener('click', (event) => {
                                const trigger = event.target.closest('[data-open-renewal]');
                                if (!trigger) {
                                    return;
                                }
                                event.preventDefault();
                                openModal(trigger);
                            });

                            form.addEventListener('submit', () => {
                                closeModal();
                            });

                            document.addEventListener('keydown', (event) => {
                                if (event.key === 'Escape') {
                                    closeModal();
                                }
                            });
                        })();
                    </script>
                    <script>
                        (function () {
                            const modal = document.querySelector('[data-renewal-history-modal]');
                            if (!modal) {
                                return;
                            }
                            const list = modal.querySelector('[data-history-list]');
                            const backdrop = modal.querySelector('[data-renewal-history-dismiss]');
                            const closeButton = modal.querySelector('[data-renewal-history-close]');
                            const storeSelector = '[data-history-store]';

                            const openModal = (borrowId) => {
                                if (!borrowId) {
                                    return;
                                }
                                const payload = document.querySelector(`${storeSelector}[data-borrow-id="${borrowId}"]`);
                                if (payload) {
                                    list.innerHTML = payload.innerHTML;
                                } else {
                                    list.innerHTML = '<p class="muted">Không tìm thấy lịch sử yêu cầu.</p>';
                                }
                                modal.hidden = false;
                                document.body.classList.add('modal-open');
                            };

                            const closeModal = () => {
                                if (modal.hidden) {
                                    return;
                                }
                                modal.hidden = true;
                                document.body.classList.remove('modal-open');
                            };

                            document.addEventListener('click', (event) => {
                                const trigger = event.target.closest('[data-show-renewal-history]');
                                if (!trigger) {
                                    return;
                                }
                                event.preventDefault();
                                openModal(trigger.dataset.borrowId);
                            });

                            const closeControls = [closeButton, backdrop];
                            closeControls.forEach((control) => {
                                if (control) {
                                    control.addEventListener('click', closeModal);
                                }
                            });

                            document.addEventListener('keydown', (event) => {
                                if (event.key === 'Escape' && !modal.hidden) {
                                    closeModal();
                                }
                            });
                        })();
                    </script>
                    <jsp:include page="footer.jsp" />
                </body>

                </html>