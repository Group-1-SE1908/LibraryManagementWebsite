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
                                <c:choose>
                                    <c:when test="${not empty reports}">
                                        <c:forEach var="report" items="${reports}">
                                            <div class="feedback-row">
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
                                                        <span class="report-reason-label">Báo cáo: ${report.reason}</span>
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

                    </main>

                </body>

                </html>