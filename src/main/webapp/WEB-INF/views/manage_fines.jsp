<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>
                        <fmt:message key="fines.hero.title" />
                    </title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <style>
                        :root {
                            --fines-gradient: linear-gradient(135deg, #0c6cd0 0%, #2f49f5 65%, #7c3aed 100%);
                            --fines-panel-bg: #ffffff;
                            --fines-border: #e3e8f1;
                            --fines-shadow: 0 20px 40px rgba(13, 52, 117, 0.15);
                            --fines-text-muted: #4b5e7c;
                            --pill-paid: #22c55e;
                            --pill-pending: #f97316;
                        }

                        body {
                            background: #f4f6fb;
                            font-family: 'Inter', 'Segoe UI', system-ui, sans-serif;
                            margin: 0;
                        }

                        main {
                            padding-bottom: 80px;
                        }

                        .fines-hero {
                            padding: 60px 0 50px;
                            background: var(--fines-gradient);
                            color: white;
                            position: relative;
                            overflow: hidden;
                        }

                        .fines-hero::after {
                            content: '';
                            position: absolute;
                            inset: 0;
                            background: radial-gradient(circle at top right, rgba(255, 255, 255, 0.35), transparent 65%);
                        }

                        .fines-hero .hero-wrapper {
                            position: relative;
                            max-width: 1100px;
                            margin: 0 auto;
                            padding: 0 20px;
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
                            gap: 24px;
                        }

                        .fines-hero h1 {
                            font-size: clamp(28px, 4vw, 44px);
                            margin: 0 0 12px;
                            line-height: 1.2;
                        }

                        .fines-hero p {
                            font-size: 1.05rem;
                            color: rgba(255, 255, 255, 0.9);
                            margin-top: 0;
                        }

                        .hero-stats {
                            display: flex;
                            flex-direction: column;
                            gap: 14px;
                            margin-top: 16px;
                        }

                        .hero-stat {
                            background: rgba(255, 255, 255, 0.15);
                            border: 1px solid rgba(255, 255, 255, 0.3);
                            padding: 20px 24px;
                            border-radius: 20px;
                            display: flex;
                            flex-direction: column;
                            gap: 6px;
                            box-shadow: 0 20px 35px rgba(12, 108, 208, 0.35);
                        }

                        .hero-stat .label {
                            font-size: 0.85rem;
                            letter-spacing: 0.2em;
                            text-transform: uppercase;
                            opacity: 0.8;
                        }

                        .hero-stat .value {
                            font-size: 1.9rem;
                            font-weight: 600;
                        }

                        .hero-stat .detail {
                            font-size: 0.9rem;
                            color: rgba(255, 255, 255, 0.85);
                        }

                        .fines-content {
                            max-width: 1200px;
                            margin: 0 auto;
                            padding: 40px 20px 60px;
                            display: flex;
                            flex-direction: column;
                            gap: 30px;
                        }

                        .flash-notice {
                            background: #eef2ff;
                            border: 1px solid #c7d3ff;
                            border-radius: 12px;
                            padding: 14px 18px;
                            color: #1b1f3b;
                            font-weight: 600;
                            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.6);
                        }

                        .fines-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
                            gap: 24px;
                        }

                        .fines-panel {
                            background: var(--fines-panel-bg);
                            border-radius: 24px;
                            border: 1px solid var(--fines-border);
                            box-shadow: var(--fines-shadow);
                            padding: 24px;
                            display: flex;
                            flex-direction: column;
                            min-height: 420px;
                        }

                        .fines-panel header {
                            display: flex;
                            justify-content: space-between;
                            align-items: baseline;
                            margin-bottom: 18px;
                        }

                        .fines-panel header h2 {
                            margin: 0;
                            font-size: 1.4rem;
                        }

                        .badge-pill {
                            font-size: 0.75rem;
                            text-transform: uppercase;
                            letter-spacing: 0.2em;
                            padding: 6px 14px;
                            border-radius: 999px;
                            background: #eef0ff;
                            color: #3b3d60;
                        }

                        .fine-card {
                            border: 1px solid #f1f1f3;
                            border-radius: 18px;
                            padding: 18px;
                            margin-bottom: 14px;
                            background: #fff;
                            display: flex;
                            flex-direction: column;
                            gap: 12px;
                        }

                        .panel-body {
                            display: flex;
                            flex-direction: column;
                            gap: 14px;
                        }

                        .fine-card__top {
                            display: flex;
                            justify-content: space-between;
                            gap: 10px;
                        }

                        .fine-card__top h3 {
                            margin: 0;
                            font-size: 1.1rem;
                        }

                        .fine-card__top span {
                            font-size: 0.75rem;
                            letter-spacing: 0.18em;
                            text-transform: uppercase;
                            padding: 5px 12px;
                            border-radius: 999px;
                            border: 1px solid var(--pill-pending);
                            color: var(--pill-pending);
                        }

                        .fine-card__body {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
                            gap: 10px;
                        }

                        .fine-card__body div {
                            background: #f9f9ff;
                            border-radius: 14px;
                            padding: 10px 12px;
                        }

                        .fine-card__body strong {
                            display: block;
                            font-size: 1.1rem;
                            margin-top: 4px;
                        }

                        .fine-card__actions {
                            display: flex;
                            justify-content: flex-end;
                        }

                        .fine-card__actions .btn {
                            padding: 10px 18px;
                            border-radius: 14px;
                            background: #0b5ef7;
                            color: white;
                            text-decoration: none;
                            font-weight: 600;
                            box-shadow: 0 12px 20px rgba(11, 94, 247, 0.4);
                        }

                        .empty-state {
                            border: 2px dashed #d0d6ff;
                            border-radius: 18px;
                            padding: 30px;
                            text-align: center;
                            color: var(--fines-text-muted);
                        }

                        .history-table {
                            border-collapse: collapse;
                            width: 100%;
                            font-size: 0.95rem;
                        }

                        .history-table th,
                        .history-table td {
                            padding: 10px;
                            text-align: left;
                        }

                        .history-table th {
                            font-weight: 600;
                            color: #4c5b79;
                            font-size: 0.85rem;
                            letter-spacing: 0.1em;
                            text-transform: uppercase;
                        }

                        .history-table tbody tr {
                            border-top: 1px solid #eef2ff;
                        }

                        .status-pill {
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            padding: 4px 12px;
                            border-radius: 999px;
                            font-size: 0.75rem;
                            font-weight: 600;
                        }

                        .status-paid {
                            background: rgba(34, 197, 94, 0.15);
                            color: var(--pill-paid);
                        }

                        .status-pending {
                            background: rgba(249, 115, 22, 0.15);
                            color: var(--pill-pending);
                        }

                        @media (max-width: 768px) {
                            .fines-hero {
                                padding: 60px 0 40px;
                            }

                            .fines-panel {
                                min-height: auto;
                            }

                            .fine-card__top {
                                flex-direction: column;
                                align-items: flex-start;
                            }

                            .fine-card__actions {
                                justify-content: flex-start;
                            }
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="header.jsp" />

                    <main>
                        <c:set var="historyCount" value="${not empty historyRecords ? fn:length(historyRecords) : 0}" />
                        <section class="fines-hero">
                            <div class="hero-wrapper">
                                <div>
                                    <p class="badge-pill">Financial wellbeing</p>
                                    <h1>
                                        <fmt:message key="fines.hero.title" />
                                    </h1>
                                    <p>
                                        <fmt:message key="fines.hero.subtitle" />
                                    </p>
                                </div>
                                <div class="hero-stats">
                                    <div class="hero-stat">
                                        <span class="label">
                                            <fmt:message key="fines.outstanding.title" />
                                        </span>
                                        <span class="value">
                                            <fmt:formatNumber value="${totalOutstanding}" pattern="#,##0" /> ₫
                                        </span>
                                        <span class="detail">
                                            <fmt:message key="fines.hero.stripe" />
                                        </span>
                                    </div>
                                    <div class="hero-stat">
                                        <span class="label">
                                            <fmt:message key="fines.history.title" />
                                        </span>
                                        <span class="value">${historyCount}</span>
                                        <span class="detail">
                                            <fmt:message key="fines.hero.history_detail" />
                                        </span>
                                    </div>
                                </div>
                            </div>
                        </section>

                        <section class="fines-content">
                            <c:if test="${not empty flash}">
                                <div class="flash-notice">${flash}</div>
                            </c:if>

                            <div class="fines-grid">
                                <article class="fines-panel outstanding">
                                    <header>
                                        <h2>
                                            <fmt:message key="fines.outstanding.title" />
                                        </h2>
                                        <span class="badge-pill">
                                            <fmt:message key="fines.outstanding.subtitle" />
                                        </span>
                                    </header>

                                    <div class="panel-body">
                                        <c:choose>
                                            <c:when test="${not empty unpaidRecords}">
                                                <c:forEach items="${unpaidRecords}" var="record">
                                                    <article class="fine-card">
                                                        <div class="fine-card__top">
                                                            <div>
                                                                <p class="eyebrow">Phiếu #${record.id}</p>
                                                                <h3>${record.book.title}</h3>
                                                                <p style="margin: 0; color: var(--fines-text-muted);">
                                                                    ${record.book.author}</p>
                                                            </div>
                                                            <span>
                                                                <fmt:message key="fines.label.pending" />
                                                            </span>
                                                        </div>
                                                        <div class="fine-card__body">
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.overdue" />
                                                                </small>
                                                                <strong>${record.overdueDays} ngày</strong>
                                                            </div>
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.amount" />
                                                                </small>
                                                                <strong>
                                                                    <fmt:formatNumber value="${record.fineAmount}"
                                                                        pattern="#,##0" /> ₫
                                                                </strong>
                                                            </div>
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.due_date" />
                                                                </small>
                                                                <strong>
                                                                    <c:out value="${record.dueDate}" />
                                                                </strong>
                                                            </div>
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.return_date" />
                                                                </small>
                                                                <strong>
                                                                    <c:out value="${record.returnDate}" />
                                                                </strong>
                                                            </div>
                                                        </div>
                                                        <div class="fine-card__actions">
                                                            <a href="${pageContext.request.contextPath}/checkout?borrowId=${record.id}&mode=fine"
                                                                class="btn">
                                                                <fmt:message key="fines.action.pay" />
                                                            </a>
                                                        </div>
                                                    </article>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="empty-state">
                                                    <strong>
                                                        <fmt:message key="fines.empty" />
                                                    </strong>
                                                    <p>
                                                        <fmt:message key="fines.empty_hint" />
                                                    </p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </article>

                                <article class="fines-panel history-panel">
                                    <header>
                                        <h2>
                                            <fmt:message key="fines.history.title" />
                                        </h2>
                                        <span class="badge-pill">
                                            <fmt:message key="fines.history.subtitle" />
                                        </span>
                                    </header>
                                    <div class="table-wrapper">
                                        <table class="history-table">
                                            <thead>
                                                <tr>
                                                    <th>Phiếu</th>
                                                    <th>
                                                        <fmt:message key="fines.field.book" />
                                                    </th>
                                                    <th>
                                                        <fmt:message key="fines.field.amount" />
                                                    </th>
                                                    <th>
                                                        <fmt:message key="fines.field.status" />
                                                    </th>
                                                    <th>
                                                        <fmt:message key="fines.field.overdue" />
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${historyRecords}" var="record">
                                                    <tr>
                                                        <td>#${record.id}</td>
                                                        <td>${record.book.title}</td>
                                                        <td>
                                                            <fmt:formatNumber value="${record.fineAmount}"
                                                                pattern="#,##0" /> ₫
                                                        </td>
                                                        <td>
                                                            <span
                                                                class="status-pill ${record.paid ? 'status-paid' : 'status-pending'}">
                                                                <fmt:message
                                                                    key="${record.paid ? 'fines.label.paid' : 'fines.label.pending'}" />
                                                            </span>
                                                        </td>
                                                        <td>${record.overdueDays} ngày</td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty historyRecords}">
                                                    <tr>
                                                        <td colspan="5"
                                                            style="text-align:center; color:var(--fines-text-muted);">
                                                            <fmt:message key="fines.history.empty" />
                                                        </td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </article>
                            </div>
                        </section>
                    </main>

                    <jsp:include page="footer.jsp" />
                </body>

                </html>