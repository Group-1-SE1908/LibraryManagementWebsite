<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Chi tiết báo cáo bình luận - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background: #f5f6f8;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            color: #1f2937;
        }

        main {
            flex: 1;
        }

        .container-page {
            max-width: 900px;
            margin: 40px auto;
            padding: 0 20px;
            width: 100%;
        }

        .panel {
            background: #ffffff;
            padding: 28px;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
        }

        h2 {
            margin-bottom: 10px;
            font-size: 22px;
            font-weight: 600;
            color: #0f172a;
        }

        h3 {
            margin-top: 24px;
            margin-bottom: 12px;
            font-size: 14px;
            font-weight: 600;
            text-transform: uppercase;
            color: #64748b;
            letter-spacing: 0.5px;
            border-top: 1px solid #ececec;
            padding-top: 16px;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #3b82f6;
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .info-row {
            display: flex;
            gap: 20px;
            margin-bottom: 16px;
            padding: 12px;
            background: #f9fafb;
            border-radius: 8px;
            border-left: 3px solid #3b82f6;
        }

        .info-label {
            font-weight: 600;
            color: #374151;
            min-width: 180px;
        }

        .info-value {
            color: #4b5563;
            flex: 1;
            line-height: 1.6;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 6px;
            font-size: 13px;
            font-weight: 500;
        }

        .status-badge.pending {
            background: #dbeafe;
            color: #1e40af;
        }

        .status-badge.resolved {
            background: #dcfce7;
            color: #166534;
        }

        .status-badge.ignored {
            background: #f3f4f6;
            color: #374151;
        }

        .content-section {
            background: #f9fafb;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 16px;
            border-left: 3px solid #8b5cf6;
        }

        .content-section p {
            margin: 0;
            line-height: 1.7;
            color: #475569;
        }

        .reporter-info {
            background: #fef3c7;
            border-left-color: #f59e0b;
        }

        .comment-info {
            background: #e0e7ff;
            border-left-color: #6366f1;
        }

        .report-info {
            background: #fce7f3;
            border-left-color: #ec4899;
        }

        .description-box {
            background: #f3f4f6;
            padding: 14px;
            border-radius: 6px;
            border-left: 3px solid #6b7280;
            margin: 12px 0;
            color: #374151;
            font-style: italic;
            line-height: 1.6;
        }

        .actions-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
            gap: 10px;
            margin-top: 24px;
            padding-top: 24px;
            border-top: 1px solid #ececec;
        }

        .btn-modern {
            padding: 10px 16px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: all 0.2s ease;
            text-decoration: none;
            display: inline-block;
            text-align: center;
            font-family: inherit;
        }

        .btn-modern.primary {
            background: #3b82f6;
            color: white;
        }

        .btn-modern.primary:hover {
            background: #2563eb;
            box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
        }

        .btn-modern.danger {
            background: #ef4444;
            color: white;
        }

        .btn-modern.danger:hover {
            background: #dc2626;
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
        }

        .btn-modern.warning {
            background: #f59e0b;
            color: white;
        }

        .btn-modern.warning:hover {
            background: #d97706;
            box-shadow: 0 4px 12px rgba(245, 158, 11, 0.3);
        }

        .btn-modern.secondary {
            background: #6b7280;
            color: white;
        }

        .btn-modern.secondary:hover {
            background: #4b5563;
            box-shadow: 0 4px 12px rgba(107, 114, 128, 0.3);
        }

        .lock-days-wrapper {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
        }

        .lock-days-wrapper select {
            padding: 8px 10px;
            font-size: 13px;
            border: 1px solid #d1d5db;
            border-radius: 6px;
            background: white;
            cursor: pointer;
            font-family: inherit;
        }

        .empty-state {
            text-align: center;
            color: #9ca3af;
            padding: 40px 20px;
        }

        .reason-code {
            display: inline-block;
            background: #ecfdf5;
            color: #065f46;
            padding: 2px 8px;
            border-radius: 4px;
            font-family: monospace;
            font-size: 12px;
        }
    </style>
</head>

<body class="panel-body">

    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

    <main class="panel-main">
        <div class="container-page">
            <c:set var="defaultFeedbackBase"
                value="${fn:startsWith(pageContext.request.servletPath, '/admin/') ? '/admin/feedback' : '/staff/feedback'}" />
            <c:set var="feedbackBasePath"
                value="${not empty feedbackBasePath ? feedbackBasePath : defaultFeedbackBase}" />

            <a href="${pageContext.request.contextPath}${feedbackBasePath}?tab=reports" class="back-link">
                ← Quay lại danh sách báo cáo
            </a>

            <c:choose>
                <c:when test="${not empty report}">
                    <div class="panel">
                        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                            <h2>Chi tiết báo cáo #${report.reportId}</h2>
                            <span class="status-badge ${fn:toLowerCase(report.status)}">
                                <c:choose>
                                    <c:when test="${report.status == 'PENDING'}">Chờ xử lý</c:when>
                                    <c:when test="${report.status == 'RESOLVED'}">Đã xử lý</c:when>
                                    <c:when test="${report.status == 'IGNORED'}">Bỏ qua</c:when>
                                    <c:otherwise>${report.status}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <!-- Reporter Info -->
                        <h3>Thông tin báo cáo</h3>
                        <div class="info-row reporter-info">
                            <div class="info-label">Người báo cáo:</div>
                            <div class="info-value">${report.reporterFullName}</div>
                        </div>
                        <div class="info-row reporter-info">
                            <div class="info-label">Thời gian báo cáo:</div>
                            <div class="info-value">
                                <fmt:formatDate value="${report.reportTime}" type="both" dateStyle="medium" timeStyle="short" />
                            </div>
                        </div>

                        <!-- Report Reason -->
                        <h3>Lý do báo cáo</h3>
                        <div class="info-row report-info">
                            <div class="info-label">Lý do:</div>
                            <div class="info-value">
                                <strong>${reportReasonVN}</strong>
                                <span class="reason-code">${report.reason}</span>
                            </div>
                        </div>
                        <c:if test="${not empty report.description}">
                            <div class="info-row report-info">
                                <div class="info-label">Mô tả chi tiết:</div>
                                <div class="description-box">${report.description}</div>
                            </div>
                        </c:if>

                        <!-- Comment Info -->
                        <h3>Bình luận bị báo cáo</h3>
                        <div class="content-section comment-info">
                            <p>
                                <strong>ID:</strong> ${report.commentId}<br>
                                <strong>Tác giả:</strong> ${report.commentUserFullName}<br>
                                <strong>Nội dung:</strong>
                            </p>
                            <div style="margin-top: 10px; padding-top: 10px; border-top: 1px solid rgba(99, 102, 241, 0.3);">
                                ${report.commentContent}
                            </div>
                        </div>

                        <!-- Action Buttons -->
                        <c:if test="${report.status == 'PENDING'}">
                            <h3>Thao tác xử lý</h3>
                            <div class="actions-section">
                                <!-- Delete Comment -->
                                <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post"
                                    style="margin:0; grid-column: span 1;">
                                    <input type="hidden" name="action" value="deleteComment" />
                                    <input type="hidden" name="reportId" value="${report.reportId}" />
                                    <button type="submit" class="btn-modern danger" style="width:100%;"
                                        onclick="return confirm('Xóa bình luận này? Hành động này không thể hoàn tác.');">
                                        Xóa bình luận
                                    </button>
                                </form>

                                <!-- Lock Comment -->
                                <div style="grid-column: span 1;">
                                    <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post"
                                        style="display: flex; gap: 4px; flex-direction: column; height: 100%;">
                                        <input type="hidden" name="action" value="lockComment" />
                                        <input type="hidden" name="reportId" value="${report.reportId}" />
                                        <select name="lockDays" style="flex: 1; margin-bottom: 4px;">
                                            <option value="1">Khóa 1 ngày</option>
                                            <option value="3">Khóa 3 ngày</option>
                                            <option value="7">Khóa 7 ngày</option>
                                            <option value="30">Khóa 30 ngày</option>
                                        </select>
                                        <button type="submit" class="btn-modern warning" style="flex: 1;">
                                            Khóa &amp; Xóa
                                        </button>
                                    </form>
                                </div>

                                <!-- Mark as Resolved -->
                                <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post"
                                    style="margin:0; grid-column: span 1;">
                                    <input type="hidden" name="action" value="resolve" />
                                    <input type="hidden" name="reportId" value="${report.reportId}" />
                                    <button type="submit" class="btn-modern primary" style="width:100%;">
                                        Xử lý
                                    </button>
                                </form>

                                <!-- Ignore Report -->
                                <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post"
                                    style="margin:0; grid-column: span 1;">
                                    <input type="hidden" name="action" value="ignore" />
                                    <input type="hidden" name="reportId" value="${report.reportId}" />
                                    <button type="submit" class="btn-modern secondary" style="width:100%;">
                                        Bỏ qua
                                    </button>
                                </form>
                            </div>
                        </c:if>

                        <c:if test="${report.status != 'PENDING'}">
                            <h3>Trạng thái xử lý</h3>
                            <div class="info-row">
                                <div class="info-label">Hành động:</div>
                                <div class="info-value">
                                    Báo cáo này đã được xử lý.<br>
                                    <c:choose>
                                        <c:when test="${report.status == 'RESOLVED'}">
                                            <strong style="color: #16a34a;">✓ Đã xử lý</strong>
                                        </c:when>
                                        <c:when test="${report.status == 'IGNORED'}">
                                            <strong style="color: #6b7280;">✓ Được bỏ qua</strong>
                                        </c:when>
                                    </c:choose>
                                </div>
                            </div>
                        </c:if>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="panel empty-state">
                        <h2>Không tìm thấy báo cáo</h2>
                        <p>Báo cáo bình luận này không được tìm thấy hoặc đã được xóa.</p>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

</body>

</html>
