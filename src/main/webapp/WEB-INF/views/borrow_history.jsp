<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Lịch sử mượn sách | LBMS Portal</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                <style>
                    :root {
                        --history-gradient: linear-gradient(135deg, #0c6cd0 0%, #2f49f5 60%, #7c3aed 100%);
                        --history-card-border: #dfe4ff;
                    }

                    body {
                        background: #f4f6fb;
                    }

                    .history-hero {
                        padding: 60px 0 40px;
                        background: var(--history-gradient);
                        color: white;
                        position: relative;
                        overflow: hidden;
                    }

                    .history-hero::after {
                        content: "";
                        position: absolute;
                        inset: 0;
                        background: radial-gradient(circle at top right, rgba(255, 255, 255, 0.35), transparent 55%);
                        pointer-events: none;
                    }

                    .history-hero .container {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
                        gap: 24px;
                        align-items: center;
                        position: relative;
                        z-index: 1;
                    }

                    .history-hero h1 {
                        font-size: 2.5rem;
                        margin-bottom: 12px;
                        line-height: 1.2;
                    }

                    .history-hero p.lead {
                        font-size: 1.05rem;
                        max-width: 480px;
                        color: rgba(255, 255, 255, 0.95);
                    }

                    .history-hero-card {
                        background: rgba(255, 255, 255, 0.15);
                        border-radius: 20px;
                        padding: 28px;
                        border: 1px solid rgba(255, 255, 255, 0.3);
                        box-shadow: 0 20px 35px rgba(12, 108, 208, 0.35);
                    }

                    .history-hero-card h3 {
                        margin-bottom: 4px;
                        font-size: 1rem;
                        letter-spacing: 0.1em;
                        text-transform: uppercase;
                    }

                    .history-hero-card .hero-stat {
                        margin-top: 16px;
                        font-size: 2.6rem;
                        font-weight: 700;
                        display: flex;
                        align-items: baseline;
                        gap: 8px;
                    }

                    .history-content {
                        padding: 36px 0 60px;
                    }

                    .history-notice {
                        padding: 16px 20px;
                        border-radius: 12px;
                        border: 1px solid var(--border-color);
                        background: #fff;
                        margin-bottom: 24px;
                        box-shadow: var(--shadow-sm);
                    }

                    .history-filter {
                        display: flex;
                        flex-wrap: wrap;
                        gap: 10px;
                        margin: 0 0 24px;
                        justify-content: flex-start;
                    }

                    .history-filter__pill {
                        border: 1px solid rgba(15, 23, 42, 0.15);
                        border-radius: 999px;
                        padding: 8px 18px;
                        font-size: 0.85rem;
                        font-weight: 600;
                        letter-spacing: 0.05em;
                        text-transform: uppercase;
                        color: #475569;
                        transition: all 0.2s ease;
                        text-decoration: none;
                        background: #fff;
                    }

                    .history-filter__pill.is-active {
                        background: linear-gradient(120deg, #0c6cd0, #2f49f5);
                        color: white;
                        border-color: transparent;
                        box-shadow: 0 15px 40px rgba(15, 23, 42, 0.2);
                    }

                    .history-stack {
                        display: grid;
                        grid-template-columns: repeat(3, minmax(0, 1fr));
                        gap: 20px;
                    }

                    @media (max-width: 1100px) {
                        .history-stack {
                            grid-template-columns: repeat(2, minmax(0, 1fr));
                        }
                    }

                    @media (max-width: 760px) {
                        .history-stack {
                            grid-template-columns: 1fr;
                        }
                    }

                    .history-card {
                        background: white;
                        border: 1px solid var(--history-card-border);
                        border-radius: 24px;
                        overflow: hidden;
                        box-shadow: var(--shadow-sm);
                        display: flex;
                        flex-direction: column;
                    }

                    .history-card__banner {
                        padding: 24px;
                        background: var(--history-gradient);
                        color: white;
                        display: flex;
                        justify-content: space-between;
                        align-items: flex-start;
                        gap: 20px;
                    }

                    .history-card__poster {
                        position: relative;
                        height: 220px;
                        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        overflow: hidden;
                        font-size: 48px;
                        color: white;
                    }

                    .history-card__poster img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                        display: block;
                    }

                    .history-card__poster-placeholder {
                        font-size: 48px;
                        font-weight: 600;
                        text-shadow: 0 6px 18px rgba(0, 0, 0, 0.3);
                    }

                    .history-card__banner h2 {
                        font-size: 1.35rem;
                        margin: 6px 0 4px;
                        line-height: 1.2;
                    }

                    .history-card__banner .muted {
                        color: rgba(255, 255, 255, 0.9);
                    }

                    .history-card__eyebrow {
                        font-size: 0.75rem;
                        letter-spacing: 0.25em;
                        text-transform: uppercase;
                        color: rgba(255, 255, 255, 0.8);
                    }

                    .status-pill {
                        font-size: 0.75rem;
                        padding: 6px 16px;
                        border-radius: 999px;
                        font-weight: 700;
                        text-transform: uppercase;
                        border: 1px solid rgba(255, 255, 255, 0.4);
                        background: rgba(255, 255, 255, 0.2);
                        color: white;
                        box-shadow: 0 8px 18px rgba(12, 108, 208, 0.3);
                        letter-spacing: 0.12em;
                    }

                    .status-borrowed {
                        border-color: rgba(16, 185, 129, 0.8);
                        background: rgba(16, 185, 129, 0.2);
                    }

                    .status-returned {
                        border-color: rgba(59, 130, 246, 0.8);
                        background: rgba(59, 130, 246, 0.2);
                    }

                    .status-pending {
                        border-color: rgba(249, 115, 22, 0.8);
                        background: rgba(249, 115, 22, 0.2);
                    }

                    .status-muted {
                        border-color: rgba(229, 231, 235, 0.8);
                        background: rgba(229, 231, 235, 0.3);
                    }

                    .history-card__body {
                        padding: 24px;
                        background: #f6f8ff;
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                        gap: 16px;
                    }

                    .history-card__field {
                        background: white;
                        border-radius: 16px;
                        padding: 14px 16px;
                        border: 1px solid var(--border-color);
                        min-height: 72px;
                        display: flex;
                        flex-direction: column;
                        gap: 6px;
                    }

                    .history-card__field span {
                        font-size: 0.8rem;
                        color: var(--text-muted);
                        letter-spacing: 0.05em;
                        text-transform: uppercase;
                    }

                    .history-card__field strong {
                        font-size: 1rem;
                        color: #0f172a;
                    }

                    .history-card__actions {
                        padding: 18px 24px;
                        border-top: 1px solid #e3e8f2;
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        gap: 12px;
                        flex-wrap: wrap;
                        background: white;
                    }

                    .history-card__actions .muted {
                        font-size: 0.85rem;
                        color: var(--text-muted);
                    }

                    .history-empty {
                        background: white;
                        border-radius: 18px;
                        padding: 40px;
                        border: 1px dashed var(--border-color);
                        text-align: center;
                        box-shadow: var(--shadow-sm);
                    }

                    .history-empty h2 {
                        margin-bottom: 12px;
                    }

                    .history-empty p {
                        color: var(--text-muted);
                        margin-bottom: 20px;
                    }

                    .history-empty a {
                        text-decoration: none;
                    }

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
                        background: rgba(15, 23, 42, 0.55);
                        backdrop-filter: blur(4px);
                        pointer-events: all;
                    }

                    .order-modal__panel {
                        position: relative;
                        background: #ffffff;
                        border-radius: 20px;
                        padding: 2rem;
                        width: min(520px, 100%);
                        box-shadow: 0 35px 80px rgba(15, 23, 42, 0.25);
                        pointer-events: all;
                        display: grid;
                        gap: 16px;
                    }

                    .order-modal__pill {
                        font-size: 0.65rem;
                        text-transform: uppercase;
                        letter-spacing: 0.5em;
                        color: #0d3b94;
                    }

                    .order-modal__title {
                        margin: 0;
                        font-size: 1.5rem;
                        color: #0f172a;
                    }

                    .order-modal__method {
                        margin: 0;
                        font-weight: 600;
                        letter-spacing: 0.05em;
                        color: #475569;
                    }

                    .order-modal__grid {
                        display: grid;
                        gap: 12px;
                    }

                    .order-modal__row {
                        border-radius: 12px;
                        border: 1px solid rgba(15, 23, 42, 0.08);
                        padding: 12px 14px;
                        background: #f7f9ff;
                    }

                    .order-modal__row span {
                        font-size: 0.7rem;
                        letter-spacing: 0.3em;
                        text-transform: uppercase;
                        color: #475569;
                    }

                    .order-modal__row strong {
                        display: block;
                        margin-top: 6px;
                        font-size: 1rem;
                        color: #0f172a;
                    }

                    .order-modal__row[hidden] {
                        display: none;
                    }

                    .order-modal__close {
                        position: absolute;
                        top: 12px;
                        right: 12px;
                        border: none;
                        background: rgba(15, 23, 42, 0.08);
                        border-radius: 50%;
                        width: 36px;
                        height: 36px;
                        font-size: 1.2rem;
                        line-height: 1;
                        cursor: pointer;
                        color: #0f172a;
                        transition: background 0.2s ease;
                    }

                    .order-modal__close:hover {
                        background: rgba(15, 23, 42, 0.15);
                    }

                    .history-card__actions .js-show-order {
                        min-width: 180px;
                    }
                </style>
            </head>

            <body>
                <jsp:include page="header.jsp" />

                <section class="history-hero" aria-label="Lịch sử mượn">
                    <div class="container">
                        <div>
                            <p class="eyebrow"
                                style="letter-spacing:0.3em; text-transform:uppercase; font-size:0.75rem; color:rgba(255,255,255,0.8);">
                                Lịch sử</p>
                            <h1>Ghi lại mọi hành trình đọc sách của bạn</h1>
                            <p class="lead">Theo dõi các lần mượn, tình trạng trả và quay lại cuốn sách yêu thích chỉ
                                với một cú nhấp.</p>
                        </div>
                        <div class="history-hero-card">
                            <h3>Giao dịch gần đây</h3>
                            <div class="hero-stat">
                                <c:set var="historyCount" value="${records != null ? records.size() : 0}" />
                                <span>${historyCount}</span>
                                <small style="font-size:0.9rem; color:rgba(255,255,255,0.85);">phiếu ghi lại</small>
                            </div>
                            <p style="margin-top:12px; color:rgba(255,255,255,0.8);">Bấm vào từng dòng để xem chi tiết
                                cuốn sách và trạng thái trả.</p>
                        </div>
                    </div>
                </section>

                <section class="history-content container">
                    <c:if test="${not empty flash}">
                        <div class="history-notice">${flash}</div>
                    </c:if>

                    <c:set var="historyStatusFilter" value="${historyStatusFilter != null ? historyStatusFilter : 'all'}" />
                    <div class="history-filter">
                        <a class="history-filter__pill ${historyStatusFilter == 'all' ? 'is-active' : ''}"
                            href="${pageContext.request.contextPath}/history">Tất cả</a>
                        <a class="history-filter__pill ${historyStatusFilter == 'borrowing' ? 'is-active' : ''}"
                            href="${pageContext.request.contextPath}/history?status=borrowing">Đang mượn</a>
                        <a class="history-filter__pill ${historyStatusFilter == 'pending' ? 'is-active' : ''}"
                            href="${pageContext.request.contextPath}/history?status=pending">Đang duyệt</a>
                        <a class="history-filter__pill ${historyStatusFilter == 'returned' ? 'is-active' : ''}"
                            href="${pageContext.request.contextPath}/history?status=returned">Đã trả</a>
                    </div>

                    <c:choose>
                        <c:when test="${historyCount > 0}">
                            <div class="history-stack">
                                <c:forEach items="${records}" var="r">
                                    <c:set var="statusClass">
                                        <c:choose>
                                            <c:when
                                                test="${fn:toUpperCase(r.status) == 'BORROWED' || fn:toUpperCase(r.status) == 'APPROVED'}">status-borrowed
                                            </c:when>
                                            <c:when test="${fn:toUpperCase(r.status) == 'RETURNED'}">status-returned
                                            </c:when>
                                            <c:when test="${fn:toUpperCase(r.status) == 'REQUESTED'}">status-pending</c:when>
                                            <c:otherwise>status-muted</c:otherwise>
                                        </c:choose>
                                    </c:set>
                                    <article class="history-card">
                                        <div class="history-card__banner">
                                            <div>
                                                <p class="history-card__eyebrow">Phiếu #${r.id}</p>
                                                <h2>${r.book.title}</h2>
                                                <p class="muted">${r.book.author}</p>
                                            </div>
                                            <span class="status-pill ${statusClass}">${r.status}</span>
                                        </div>

                                        <div class="history-card__poster">
                                            <c:choose>
                                                <c:when test="${not empty r.book.image}">
                                                    <img src="${pageContext.request.contextPath}/${r.book.image}"
                                                         alt="${r.book.title}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="history-card__poster-placeholder">📖</div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="history-card__body">
                                            <div class="history-card__field">
                                                <span>Ngày mượn</span>
                                                <strong>${r.borrowDate}</strong>
                                            </div>
                                            <div class="history-card__field">
                                                <span>Ngày trả</span>
                                                <strong>
                                                    <c:choose>
                                                        <c:when test="${not empty r.returnDate}">${r.returnDate}
                                                        </c:when>
                                                        <c:otherwise>Chưa trả</c:otherwise>
                                                    </c:choose>
                                                </strong>
                                            </div>
                                            <div class="history-card__field">
                                                <span>ISBN</span>
                                                <strong>
                                                    <c:choose>
                                                        <c:when test="${not empty r.book.isbn}">${r.book.isbn}</c:when>
                                                        <c:otherwise>Không có</c:otherwise>
                                                    </c:choose>
                                                </strong>
                                            </div>
                                            <div class="history-card__field">
                                                <span>Người mượn</span>
                                                <strong>${r.user.fullName}</strong>
                                            </div>
                                            <div class="history-card__field">
                                                <span>Trạng thái mượn</span>
                                                <strong>${r.status}</strong>
                                            </div>
                                            <div class="history-card__field">
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

                                        <c:set var="methodCode" value="${fn:toUpperCase(r.borrowMethod)}" />
                                        <c:set var="shipping" value="${r.shippingDetails}" />
                                        <div class="history-card__actions">
                                            <button class="btn primary js-show-order" type="button"
                                                data-method="${methodCode}"
                                                data-recipient="${shipping != null && not empty shipping.recipient ? shipping.recipient : ''}"
                                                data-shipping-phone="${shipping != null && not empty shipping.phone ? shipping.phone : ''}"
                                                data-address="${shipping != null && not empty shipping.formattedAddress ? shipping.formattedAddress : ''}"
                                                data-user-phone="${not empty r.user.phone ? r.user.phone : ''}"
                                                data-borrow-date="${not empty r.borrowDate ? r.borrowDate : ''}">Xem đơn hàng</button>
                                            <c:if test="${fn:toUpperCase(r.status) == 'BORROWED'}">
                                                <a class="btn success"
                                                    href="${pageContext.request.contextPath}/checkout?borrowId=${r.id}">Trả
                                                    sách & Thanh toán</a>
                                            </c:if>
                                            <c:if test="${fn:toUpperCase(r.status) == 'REQUESTED'}">
                                                <button class="btn danger" type="button" 
                                                    onclick="confirmCancel(${r.id})"
                                                    style="background: #ef4444; color: white; border: none; padding: 10px 20px; border-radius: 12px; font-weight: 600; cursor: pointer;">Hủy yêu cầu</button>
                                            </c:if>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="history-empty">
                                <h2>Bạn chưa mượn cuốn sách nào?</h2>
                                <p>Kéo đến thư viện số của chúng tôi để khám phá, chọn sách và bắt đầu hành trình học
                                    tập.</p>
                                <a class="btn primary" href="${pageContext.request.contextPath}/books">Khám phá
                                    Catalog</a>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </section>

                <div id="order-modal" class="order-modal" hidden aria-hidden="true">
                    <div class="order-modal__backdrop" data-dismiss="true"></div>
                    <div class="order-modal__panel" role="dialog" aria-modal="true" aria-labelledby="order-modal-title" tabindex="-1">
                        <button type="button" class="order-modal__close" aria-label="Đóng chi tiết đơn hàng">×</button>
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
                        var recipientValue = modal.querySelector('[data-value="recipient"]');
                        var shippingValue = modal.querySelector('[data-value="shippingPhone"]');
                        var addressValue = modal.querySelector('[data-value="address"]');
                        var contactValue = modal.querySelector('[data-value="contactPhone"]');
                        var borrowDateValue = modal.querySelector('[data-value="borrowDate"]');
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
                            } else {
                                recipientRow.hidden = true;
                                shippingRow.hidden = true;
                                addressRow.hidden = true;
                                contactRow.hidden = false;
                                borrowDateRow.hidden = false;
                            }
                            recipientValue.textContent = getValue(dataset.recipient, 'Chưa cung cấp');
                            var phoneFallback = getValue(dataset.userPhone, 'Chưa cung cấp');
                            shippingValue.textContent = getValue(dataset.shippingPhone, phoneFallback);
                            addressValue.textContent = getValue(dataset.address, 'Chưa cung cấp');
                            contactValue.textContent = getValue(dataset.userPhone, 'Chưa cung cấp');
                            borrowDateValue.textContent = getValue(dataset.borrowDate, 'Đang chờ');
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
                <jsp:include page="footer.jsp" />
            </body>

            </html>