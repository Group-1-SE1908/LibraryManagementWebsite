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
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 20px;
        }

        .history-card {
            background: white;
            border: 1px solid var(--history-card-border);
            border-radius: 18px;
            padding: 20px;
            box-shadow: var(--shadow-sm);
            display: flex;
            flex-direction: column;
            gap: 18px;
        }

        .history-card__header {
            display: flex;
            justify-content: space-between;
            gap: 12px;
            align-items: flex-start;
        }

        .history-card__header h2 {
            font-size: 1.25rem;
            margin-bottom: 6px;
        }

        .history-card__eyebrow {
            font-size: 0.8rem;
            letter-spacing: 0.2em;
            text-transform: uppercase;
            color: var(--text-muted);
        }

        .status-pill {
            font-size: 0.8rem;
            padding: 6px 12px;
            border-radius: 999px;
            border: 1px solid transparent;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-borrowed {
            color: #0f766e;
            border-color: #86efac;
            background: rgba(16, 185, 129, 0.12);
        }

        .status-returned {
            color: #1d4ed8;
            border-color: #bfdbfe;
            background: rgba(59, 130, 246, 0.12);
        }

        .status-pending {
            color: #d97706;
            border-color: #fde68a;
            background: rgba(249, 115, 22, 0.12);
        }

        .status-muted {
            color: #4b5563;
            border-color: #e5e7eb;
            background: rgba(15, 23, 42, 0.05);
        }

        .history-card__metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
            gap: 12px;
        }

        .history-card__metrics div {
            background: var(--light-bg);
            border-radius: 12px;
            padding: 12px 14px;
            border: 1px solid var(--border-color);
        }

        .history-card__metrics span {
            display: block;
            font-size: 0.8rem;
            color: var(--text-muted);
        }

        .history-card__metrics strong {
            display: block;
            font-size: 1rem;
            margin-top: 6px;
        }

        .history-card__actions {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
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
                <p class="eyebrow" style="letter-spacing:0.3em; text-transform:uppercase; font-size:0.75rem; color:rgba(255,255,255,0.8);">Lịch sử</p>
                <h1>Ghi lại mọi hành trình đọc sách của bạn</h1>
                <p class="lead">Theo dõi các lần mượn, tình trạng trả và quay lại cuốn sách yêu thích chỉ với một cú nhấp.</p>
            </div>
            <div class="history-hero-card">
                <h3>Giao dịch gần đây</h3>
                <div class="hero-stat">
                    <c:set var="historyCount" value="${records != null ? records.size() : 0}" />
                    <span>${historyCount}</span>
                    <small style="font-size:0.9rem; color:rgba(255,255,255,0.85);">phiếu ghi lại</small>
                </div>
                <p style="margin-top:12px; color:rgba(255,255,255,0.8);">Bấm vào từng dòng để xem chi tiết cuốn sách và trạng thái trả.</p>
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
                                <c:when test="${fn:toUpperCase(r.status) == 'BORROWED'}">status-borrowed</c:when>
                                <c:when test="${fn:toUpperCase(r.status) == 'RETURNED'}">status-returned</c:when>
                                <c:when test="${fn:toUpperCase(r.status) == 'REQUESTED' || fn:toUpperCase(r.status) == 'APPROVED'}">status-pending</c:when>
                                <c:otherwise>status-muted</c:otherwise>
                            </c:choose>
                        </c:set>
                        <article class="history-card">
                            <header class="history-card__header">
                                <div>
                                    <p class="history-card__eyebrow">Phiếu #${r.id}</p>
                                    <h2>${r.book.title}</h2>
                                    <p class="muted">${r.book.author}</p>
                                </div>
                                <span class="status-pill ${statusClass}">${r.status}</span>
                            </header>

                            <div class="history-card__metrics">
                                <div>
                                    <span>Ngày mượn</span>
                                    <strong>${r.borrowDate}</strong>
                                </div>
                                <div>
                                    <span>Ngày trả</span>
                                    <strong>
                                        <c:choose>
                                            <c:when test="${not empty r.returnDate}">${r.returnDate}</c:when>
                                            <c:otherwise>Chưa trả</c:otherwise>
                                        </c:choose>
                                    </strong>
                                </div>
                                <div>
                                    <span>ISBN</span>
                                    <strong>
                                        <c:choose>
                                            <c:when test="${not empty r.book.isbn}">${r.book.isbn}</c:when>
                                            <c:otherwise>Không có</c:otherwise>
                                        </c:choose>
                                    </strong>
                                </div>
                            </div>

                            <div class="history-card__metrics">
                                <div>
                                    <span>Người mượn</span>
                                    <strong>${r.user.fullName}</strong>
                                </div>
                                <div>
                                    <span>Trạng thái mượn</span>
                                    <strong>${r.status}</strong>
                                </div>
                                <div>
                                    <span>Phạt</span>
                                    <strong>
                                        <c:choose>
                                            <c:when test="${not empty r.fineAmount}">${r.fineAmount} VND</c:when>
                                            <c:otherwise>0 VND</c:otherwise>
                                        </c:choose>
                                    </strong>
                                </div>
                            </div>

                            <div class="history-card__actions">
                                <a class="btn primary" href="${pageContext.request.contextPath}/books/detail?id=${r.book.id}">Chi tiết sách</a>
                                <span class="muted">ID sách ${r.book.id}</span>
                            </div>
                        </article>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="history-empty">
                    <h2>Bạn chưa mượn cuốn sách nào?</h2>
                    <p>Kéo đến thư viện số của chúng tôi để khám phá, chọn sách và bắt đầu hành trình học tập.</p>
                    <a class="btn primary" href="${pageContext.request.contextPath}/books">Khám phá Catalog</a>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <jsp:include page="footer.jsp" />
</body>

</html>
