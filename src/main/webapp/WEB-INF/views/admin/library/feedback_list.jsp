<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>Quản lý phản hồi - LBMS</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

                    <style>
                        .feedback-row {
                            display: flex;
                            justify-content: space-between;
                            gap: 20px;
                            padding: 18px 0;
                            border-bottom: 1px solid #f1f5f9;
                        }

                        .feedback-row:last-child {
                            border-bottom: none;
                        }

                        .feedback-content {
                            flex: 1;
                        }

                        .feedback-title {
                            font-weight: 600;
                            font-size: 15px;
                            color: #0f172a;
                        }

                        .feedback-meta {
                            font-size: 12px;
                            color: #94a3b8;
                            margin-top: 6px;
                        }

                        .feedback-text {
                            margin-top: 10px;
                            color: #475569;
                            line-height: 1.6;
                        }

                        .star {
                            color: #fbbf24;
                            font-size: 13px;
                            letter-spacing: 2px;
                            margin-top: 6px;
                        }

                        .feedback-actions {
                            display: flex;
                            gap: 10px;
                            align-items: flex-start;
                            flex-shrink: 0;
                        }

                        .empty-state {
                            text-align: center;
                            color: #94a3b8;
                            padding: 50px 0;
                            font-size: 15px;
                        }

                        .tabs-container {
                            display: flex;
                            gap: 8px;
                            border-bottom: 2px solid #e5e7eb;
                            margin-bottom: 20px;
                        }

                        .tab-button {
                            padding: 12px 20px;
                            border: none;
                            background: none;
                            cursor: pointer;
                            font-size: 14px;
                            color: #64748b;
                            border-bottom: 3px solid transparent;
                            margin-bottom: -2px;
                            transition: all 0.3s ease;
                            font-weight: 500;
                            text-decoration: none;
                            display: inline-block;
                        }

                        .tab-button:hover {
                            color: #0f172a;
                        }

                        .tab-button.active {
                            color: #0f172a;
                            border-bottom-color: #3b82f6;
                        }

                        .tab-content {
                            display: none;
                        }

                        .tab-content.active {
                            display: block;
                        }

                        .report-badge {
                            display: inline-block;
                            background: #ef4444;
                            color: white;
                            padding: 2px 8px;
                            border-radius: 12px;
                            font-size: 12px;
                            margin-left: 6px;
                        }

                        .report-reason-label {
                            display: inline-block;
                            background: #fef3c7;
                            color: #92400e;
                            padding: 4px 10px;
                            border-radius: 4px;
                            font-size: 12px;
                            margin-right: 8px;
                        }

                        .report-status {
                            display: inline-block;
                            padding: 4px 10px;
                            border-radius: 4px;
                            font-size: 12px;
                            font-weight: 500;
                        }

                        .report-status.pending {
                            background: #dbeafe;
                            color: #1e40af;
                        }

                        .report-status.resolved {
                            background: #dcfce7;
                            color: #166534;
                        }

                        .report-status.ignored {
                            background: #f3f4f6;
                            color: #374151;
                        }

                        /* ── Filter chip bar ── */
                        .report-filter-bar {
                            display: flex;
                            align-items: center;
                            gap: 8px;
                            margin-bottom: 20px;
                            flex-wrap: wrap;
                        }
                
                        .filter-chip {
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
                            transition: all 0.2s ease;
                        }
                
                        .filter-chip:hover {
                            background: #e2e8f0;
                            color: #1e293b;
                        }
                
                        .filter-chip.active {
                            background: #0b57d0;
                            color: #fff;
                            border-color: #0b57d0;
                        }
                
                        .filter-chip .chip-count {
                            background: #cbd5e1;
                            color: #475569;
                            padding: 1px 7px;
                            border-radius: 10px;
                            font-size: 11px;
                        }
                
                        .filter-chip.active .chip-count {
                            background: rgba(255, 255, 255, .25);
                            color: #fff;
                        }
                        
                        .feedback-row[data-hidden="true"] {
                            display: none !important;
                        }
                    </style>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                </head>

                <body class="panel-body">

                    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
                    <c:set var="defaultFeedbackBase"
                        value="${fn:startsWith(pageContext.request.servletPath, '/admin/') ? '/admin/feedback' : '/staff/feedback'}" />
                    <c:set var="feedbackBasePath"
                        value="${not empty feedbackBasePath ? feedbackBasePath : defaultFeedbackBase}" />

                    <main class="panel-main">
                        <div class="pm-header">
                            <h1 class="pm-title">Phản hồi sách</h1>
                            <p class="pm-subtitle">Danh sách bình luận và đánh giá từ độc giả. Xét duyệt, trả lời hoặc
                                xóa nội dung không phù hợp.</p>
                        </div>

                        <div class="pm-card">
                            <!-- Tab Navigation -->
                            <div class="tabs-container">
                                <a href="${pageContext.request.contextPath}${feedbackBasePath}?tab=feedback" 
                                   class="tab-button ${empty activeTab || activeTab == 'feedback' ? 'active' : ''}">
                                    Phản hồi sách
                                </a>
                                <a href="${pageContext.request.contextPath}${feedbackBasePath}?tab=reports" 
                                   class="tab-button ${activeTab == 'reports' ? 'active' : ''}">
                                    Bình luận bị báo cáo
                                    <c:if test="${not empty reports}">
                                        <span class="report-badge">${reports.size()}</span>
                                    </c:if>
                                </a>
                            </div>

                            <!-- Tab: Feedback (Comments) -->
                            <div class="tab-content ${empty activeTab || activeTab == 'feedback' ? 'active' : ''}">
                                <div class="pm-toolbar">
                                    <div style="display:flex;gap:8px;flex-wrap:wrap;">
                                        <a href="${pageContext.request.contextPath}${feedbackBasePath}?action=list&filter=all"
                                            class="btn-modern ${filter == 'all' || empty filter ? 'primary' : 'secondary'}"
                                            style="padding:8px 18px;border-radius:20px;font-size:13px;">
                                            Tất cả
                                        </a>
                                        <a href="${pageContext.request.contextPath}${feedbackBasePath}?action=list&filter=unreplied"
                                            class="btn-modern ${filter == 'unreplied' ? 'primary' : 'secondary'}"
                                            style="padding:8px 18px;border-radius:20px;font-size:13px;">
                                            Chưa phản hồi
                                        </a>
                                        <a href="${pageContext.request.contextPath}${feedbackBasePath}?action=list&filter=replied"
                                            class="btn-modern ${filter == 'replied' ? 'primary' : 'secondary'}"
                                            style="padding:8px 18px;border-radius:20px;font-size:13px;">
                                            Đã phản hồi
                                        </a>
                                    </div>
                                </div>

                                <c:choose>
                                    <c:when test="${not empty comments}">
                                        <c:forEach var="cmt" items="${comments}">
                                            <div class="feedback-row">
                                                <div class="feedback-content">
                                                    <div class="feedback-title">#${cmt.commentId} — ${cmt.fullName}</div>
                                                    <div class="star">
                                                        <c:forEach begin="1" end="${cmt.rating}">★</c:forEach>
                                                        <c:forEach begin="${cmt.rating + 1}" end="5">
                                                            <span style="color:#e5e7eb;">★</span>
                                                        </c:forEach>
                                                    </div>
                                                    <div class="feedback-text">${cmt.content}</div>
                                                    <div class="feedback-meta">
                                                        Sách ID: ${cmt.bookId} •
                                                        <fmt:formatDate value="${cmt.createdAt}" type="both"
                                                            dateStyle="medium" timeStyle="short" />
                                                    </div>
                                                </div>
                                                <div class="feedback-actions">
                                                    <a href="${pageContext.request.contextPath}${feedbackBasePath}?action=view&id=${cmt.commentId}"
                                                        class="btn-modern primary" style="padding:8px 14px;font-size:13px;">
                                                        Xem &amp; Trả lời
                                                    </a>
                                                    <form action="${pageContext.request.contextPath}${feedbackBasePath}"
                                                        method="post" onsubmit="return confirm('Xóa phản hồi này?');"
                                                        style="margin:0;">
                                                        <input type="hidden" name="action" value="delete" />
                                                        <input type="hidden" name="id" value="${cmt.commentId}" />
                                                        <button type="submit" class="btn-modern danger"
                                                            style="padding:8px 14px;font-size:13px;">Xóa</button>
                                                    </form>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="empty-state">Không có phản hồi nào.</div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <!-- Tab: Reported Comments -->
                            <div class="tab-content ${activeTab == 'reports' ? 'active' : ''}">
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

                                <%-- Filter tabs --%>
                                <div class="report-filter-bar" id="filterBarReports" style="margin-top: 10px;">
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

                                <div id="reportCardList">
                                <c:choose>
                                    <c:when test="${not empty reports}">
                                        <c:forEach var="report" items="${reports}">
                                            <div class="feedback-row report-card-row" data-status="${report.status}">
                                                <div class="feedback-content">
                                                    <div class="feedback-title">
                                                        #${report.commentId} — ${report.commentUserFullName}
                                                        <span class="report-status ${fn:toLowerCase(report.status)}">
                                                            <c:choose>
                                                                <c:when test="${report.status == 'PENDING'}">Chờ xử lý</c:when>
                                                                <c:when test="${report.status == 'RESOLVED'}">Đã xử lý</c:when>
                                                                <c:when test="${report.status == 'IGNORED'}">Bỏ qua</c:when>
                                                                <c:otherwise>${report.status}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </div>
                                                    <div style="margin-top: 8px;">
                                            <span class="report-reason-label">
                                                Báo cáo: 
                                                <c:choose>
                                                    <c:when test="${fn:toLowerCase(report.reason) == 'spam'}">Spam</c:when>
                                                    <c:when test="${fn:toLowerCase(report.reason) == 'offensive language'}">Ngôn ngữ thô tục</c:when>
                                                    <c:when test="${fn:toLowerCase(report.reason) == 'harassment'}">Quấy rối</c:when>
                                                    <c:when test="${fn:toLowerCase(report.reason) == 'false information'}">Thông tin sai lệch</c:when>
                                                    <c:otherwise>Khác</c:otherwise>
                                                </c:choose>
                                            </span>
                                        </div>
                                                    <div class="feedback-text" style="margin-top: 6px;">
                                                        <strong>Bình luận:</strong> ${report.commentContent}
                                                    </div>
                                                    <div class="feedback-meta">
                                                        Báo cáo bởi: ${report.reporterFullName} •
                                                        <fmt:formatDate value="${report.reportTime}" type="both"
                                                            dateStyle="medium" timeStyle="short" />
                                                    </div>
                                                </div>
                                                <div class="feedback-actions">
                                                    <a href="${pageContext.request.contextPath}${feedbackBasePath}?action=viewReport&id=${report.reportId}"
                                                        class="btn-modern primary" style="padding:8px 14px;font-size:13px;">
                                                        Xem chi tiết
                                                    </a>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="empty-state">Không có bình luận bị báo cáo nào.</div>
                                    </c:otherwise>
                                </c:choose>
                                </div>
                            </div>
                        </div>

                    </main>

                    <script>
                        (function () {
                            const filterBar = document.getElementById('filterBarReports');
                            const reportList = document.getElementById('reportCardList');
                            if (!filterBar || !reportList) return;

                            const chips = filterBar.querySelectorAll('.filter-chip');
                            const cards = reportList.querySelectorAll('.report-card-row');

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