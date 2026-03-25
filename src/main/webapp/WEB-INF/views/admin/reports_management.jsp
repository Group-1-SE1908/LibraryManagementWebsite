<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>LBMS – Quản lý báo cáo bình luận</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    <style>
        /* ── Filter chip bar ── */
        .report-filter-bar {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .report-filter-bar .filter-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 8px 18px;
            border-radius: 20px;
            font-size: 13px;
            font-weight: 600;
            border: 1px solid #cbd5e1;
            background: #f1f5f9;
            cursor: pointer;
            color: #475569;
            transition: var(--panel-transition);
        }

        .report-filter-bar .filter-chip:hover {
            background: #e2e8f0;
            color: #1e293b;
        }

        .report-filter-bar .filter-chip.active {
            background: #0b57d0;
            color: #fff;
            border-color: #0b57d0;
        }

        .report-filter-bar .filter-chip .chip-count {
            background: #cbd5e1;
            color: #475569;
            padding: 1px 7px;
            border-radius: 10px;
            font-size: 11px;
        }

        .report-filter-bar .filter-chip.active .chip-count {
            background: rgba(255, 255, 255, .25);
            color: #fff;
        }

        /* ── Report cards ── */
        .report-card-list {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .report-card {
            display: grid;
            grid-template-columns: 1fr auto;
            gap: 16px;
            padding: 18px 20px;
            background: var(--panel-card);
            border: 1px solid var(--panel-border);
            border-radius: var(--panel-radius);
            transition: box-shadow .2s, transform .15s;
            align-items: center;
        }

        .report-card:hover {
            box-shadow: var(--panel-shadow-md);
            transform: translateY(-1px);
        }

        .report-card-body {
            display: flex;
            flex-direction: column;
            gap: 6px;
            min-width: 0;
        }

        .report-card-header {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .report-card-id {
            font-size: .75rem;
            color: var(--panel-text-sub);
            font-weight: 600;
        }

        .report-card-reason {
            display: inline-block;
            background: #fef3c7;
            color: #92400e;
            padding: 2px 10px;
            border-radius: 6px;
            font-size: .72rem;
            font-weight: 600;
        }

        .report-card-time {
            font-size: .72rem;
            color: var(--panel-text-sub);
            margin-left: auto;
        }

        .report-card-comment {
            font-size: .85rem;
            color: var(--panel-text);
            line-height: 1.5;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .report-card-comment strong {
            color: var(--panel-text-sub);
            font-weight: 500;
        }

        .report-card-meta {
            display: flex;
            align-items: center;
            gap: 16px;
            font-size: .75rem;
            color: var(--panel-text-sub);
        }

        .report-card-meta i {
            width: 14px;
            text-align: center;
            margin-right: 3px;
        }

        .report-card-actions {
            display: flex;
            align-items: center;
            gap: 6px;
            flex-shrink: 0;
        }

        .report-card-actions form {
            margin: 0;
        }

        /* ── View detail link ── */
        .report-detail-link {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 6px 14px;
            border-radius: 8px;
            font-size: .78rem;
            font-weight: 500;
            color: var(--panel-accent);
            background: #ede9fe;
            text-decoration: none;
            transition: var(--panel-transition);
            white-space: nowrap;
        }

        .report-detail-link:hover {
            background: var(--panel-accent);
            color: #fff;
        }

        /* ── Stats summary ── */
        .report-stats {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 14px;
            margin-bottom: 24px;
        }

        .report-stat-card {
            padding: 16px 20px;
            background: var(--panel-card);
            border: 1px solid var(--panel-border);
            border-radius: var(--panel-radius);
            text-align: center;
        }

        .report-stat-value {
            font-size: 1.5rem;
            font-weight: 700;
        }

        .report-stat-label {
            font-size: .75rem;
            color: var(--panel-text-sub);
            margin-top: 2px;
        }

        .stat-pending .report-stat-value { color: #f59e0b; }
        .stat-resolved .report-stat-value { color: #10b981; }
        .stat-total .report-stat-value { color: var(--panel-accent); }

        /* Fade hidden rows */
        .report-card[data-hidden="true"] {
            display: none;
        }
    </style>
</head>

<body class="panel-body">

    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="panel-main">

        <div class="pm-page-header">
            <div>
                <h1 class="pm-title"><i class="fas fa-flag"
                        style="color:var(--panel-accent);margin-right:8px;"></i>Quản lý báo cáo bình luận</h1>
                <p class="pm-subtitle">Xem xét và xử lý các báo cáo từ người dùng về bình luận vi phạm.</p>
            </div>
        </div>

        <%-- Count stats --%>
        <c:set var="pendingCount" value="0" />
        <c:set var="resolvedCount" value="0" />
        <c:set var="totalCount" value="0" />
        <c:forEach var="r" items="${reports}">
            <c:set var="totalCount" value="${totalCount + 1}" />
            <c:if test="${r.status == 'PENDING'}">
                <c:set var="pendingCount" value="${pendingCount + 1}" />
            </c:if>
            <c:if test="${r.status == 'RESOLVED' || r.status == 'IGNORED'}">
                <c:set var="resolvedCount" value="${resolvedCount + 1}" />
            </c:if>
        </c:forEach>

        <%-- Stats row --%>
        <div class="report-stats">
            <div class="report-stat-card stat-total">
                <div class="report-stat-value">${totalCount}</div>
                <div class="report-stat-label">Tổng báo cáo</div>
            </div>
            <div class="report-stat-card stat-pending">
                <div class="report-stat-value">${pendingCount}</div>
                <div class="report-stat-label">Chờ xử lý</div>
            </div>
            <div class="report-stat-card stat-resolved">
                <div class="report-stat-value">${resolvedCount}</div>
                <div class="report-stat-label">Đã xử lý</div>
            </div>
        </div>

        <%-- Filter tabs --%>
        <div class="report-filter-bar" id="filterBar">
            <button type="button" class="filter-chip active" data-filter="ALL">
                Tất cả <span class="chip-count">${totalCount}</span>
            </button>
            <button type="button" class="filter-chip" data-filter="PENDING">
                <i class="fas fa-clock"></i> Chưa xử lý <span class="chip-count">${pendingCount}</span>
            </button>
            <button type="button" class="filter-chip" data-filter="DONE">
                <i class="fas fa-check-circle"></i> Đã xử lý <span class="chip-count">${resolvedCount}</span>
            </button>
        </div>

        <%-- Report list --%>
        <c:choose>
            <c:when test="${not empty reports}">
                <div class="report-card-list" id="reportList">
                    <c:forEach var="report" items="${reports}">
                        <div class="report-card" data-status="${report.status}">
                            <div class="report-card-body">
                                <div class="report-card-header">
                                    <span class="report-card-id">#${report.reportId}</span>
                                    <span class="pm-badge ${report.status == 'PENDING' ? 'pm-badge-warning' : (report.status == 'RESOLVED' ? 'pm-badge-success' : 'pm-badge-neutral')}">
                                        <c:choose>
                                            <c:when test="${report.status == 'PENDING'}">Chờ xử lý</c:when>
                                            <c:when test="${report.status == 'RESOLVED'}">Đã xử lý</c:when>
                                            <c:when test="${report.status == 'IGNORED'}">Bỏ qua</c:when>
                                            <c:otherwise>${report.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="report-card-reason">
                                        <c:choose>
                                            <c:when test="${fn:toLowerCase(report.reason) == 'spam'}">Spam</c:when>
                                            <c:when test="${fn:toLowerCase(report.reason) == 'offensive language'}">Ngôn ngữ thô tục</c:when>
                                            <c:when test="${fn:toLowerCase(report.reason) == 'harassment'}">Quấy rối</c:when>
                                            <c:when test="${fn:toLowerCase(report.reason) == 'false information'}">Thông tin sai lệch</c:when>
                                            <c:otherwise>Khác</c:otherwise>
                                        </c:choose>
                                    </span>
                                    <span class="report-card-time">
                                        <i class="far fa-clock"></i>
                                        <fmt:formatDate value="${report.reportTime}" pattern="dd/MM/yyyy HH:mm" />
                                    </span>
                                </div>

                                <div class="report-card-comment">
                                    <strong>Bình luận:</strong>
                                    "${fn:escapeXml(fn:substring(report.commentContent, 0, 120))}${fn:length(report.commentContent) > 120 ? '…' : ''}"
                                </div>

                                <div class="report-card-meta">
                                    <span><i class="fas fa-user"></i>Người báo cáo: <strong>${report.reporterFullName}</strong></span>
                                    <span><i class="fas fa-pen"></i>Tác giả BL: <strong>${report.commentUserFullName}</strong></span>
                                </div>
                            </div>

                            <div class="report-card-actions">
                                <c:if test="${report.status == 'PENDING'}">
                                    <form method="post" style="margin:0;">
                                        <input type="hidden" name="action" value="resolve" />
                                        <input type="hidden" name="reportId" value="${report.reportId}" />
                                        <button type="submit" class="pm-action-btn success" title="Giải quyết">
                                            <i class="fas fa-check"></i>
                                        </button>
                                    </form>
                                    <form method="post" style="margin:0;">
                                        <input type="hidden" name="action" value="ignore" />
                                        <input type="hidden" name="reportId" value="${report.reportId}" />
                                        <button type="submit" class="pm-action-btn" style="color:var(--panel-text-sub);" title="Bỏ qua">
                                            <i class="fas fa-ban"></i>
                                        </button>
                                    </form>
                                    <form method="post" style="margin:0;"
                                        onsubmit="return confirm('Bạn có chắc muốn xóa bình luận này?')">
                                        <input type="hidden" name="action" value="delete" />
                                        <input type="hidden" name="reportId" value="${report.reportId}" />
                                        <button type="submit" class="pm-action-btn danger" title="Xóa bình luận">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>
                                </c:if>
                                <a href="${pageContext.request.contextPath}${reportsBasePath}/detail?id=${report.reportId}"
                                   class="report-detail-link" title="Xem chi tiết">
                                    <i class="fas fa-eye"></i> Chi tiết
                                </a>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="pm-card">
                    <div class="pm-empty">
                        <i class="fas fa-inbox"></i>
                        <p>Chưa có báo cáo nào.</p>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>

    </main>

    <script>
        (function () {
            const filterBar = document.getElementById('filterBar');
            const reportList = document.getElementById('reportList');
            if (!filterBar || !reportList) return;

            const chips = filterBar.querySelectorAll('.filter-chip');
            const cards = reportList.querySelectorAll('.report-card');

            chips.forEach(chip => {
                chip.addEventListener('click', () => {
                    chips.forEach(c => c.classList.remove('active'));
                    chip.classList.add('active');

                    const filter = chip.dataset.filter;
                    cards.forEach(card => {
                        const status = card.dataset.status;
                        if (filter === 'ALL') {
                            card.dataset.hidden = 'false';
                        } else if (filter === 'PENDING') {
                            card.dataset.hidden = status !== 'PENDING' ? 'true' : 'false';
                        } else if (filter === 'DONE') {
                            card.dataset.hidden = (status === 'RESOLVED' || status === 'IGNORED') ? 'false' : 'true';
                        }
                    });
                });
            });
        })();
    </script>

</body>

</html>