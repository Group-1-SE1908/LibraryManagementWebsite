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

                    <c:choose>
                        <c:when test="${historyCount > 0}">
                            <div class="history-stack">
                                <c:forEach items="${records}" var="r">
                                    <c:set var="statusClass">
                                        <c:choose>
                                            <c:when test="${fn:toUpperCase(r.status) == 'BORROWED'}">status-borrowed
                                            </c:when>
                                            <c:when test="${fn:toUpperCase(r.status) == 'RETURNED'}">status-returned
                                            </c:when>
                                            <c:when
                                                test="${fn:toUpperCase(r.status) == 'REQUESTED' || fn:toUpperCase(r.status) == 'APPROVED'}">
                                                status-pending</c:when>
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

                                        <div class="history-card__actions">
                                            <a class="btn primary"
                                                href="${pageContext.request.contextPath}/books/detail?id=${r.book.id}">Chi
                                                tiết sách</a>
                                            <c:if test="${fn:toUpperCase(r.status) == 'BORROWED'}">
                                                <a class="btn success"
                                                    href="${pageContext.request.contextPath}/checkout?borrowId=${r.id}">Trả
                                                    sách & Thanh toán</a>
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

                <jsp:include page="footer.jsp" />
            </body>

            </html>