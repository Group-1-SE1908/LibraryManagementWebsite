<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Chi tiết báo cáo bình luận - LBMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    <style>
        .container-page {
            max-width: 800px;
            margin: 0 auto;
            width: 100%;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
            color: var(--panel-text-sub);
            text-decoration: none;
            font-weight: 500;
            font-size: .9rem;
            transition: color var(--panel-transition);
        }

        .back-link:hover {
            color: var(--panel-accent);
        }

        /* ── Modern Card UI ── */
        .report-section {
            background: var(--panel-card);
            border: 1px solid var(--panel-border);
            border-radius: var(--panel-radius);
            box-shadow: var(--panel-shadow);
            margin-bottom: 24px;
            overflow: hidden;
        }

        .report-section-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--panel-border);
            background: rgba(248, 250, 252, 0.5);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .report-section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--panel-text);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .report-section-body {
            padding: 24px;
        }

        /* ── Info Grid ── */
        .info-grid {
            display: grid;
            gap: 20px;
            grid-template-columns: 1fr 1fr;
        }

        .info-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .info-label {
            font-size: .8rem;
            font-weight: 600;
            color: var(--panel-text-sub);
            text-transform: uppercase;
            letter-spacing: .05em;
        }

        .info-value {
            font-size: .95rem;
            color: var(--panel-text);
            font-weight: 500;
        }

        .info-value-block {
            background: #f8fafc;
            padding: 14px 18px;
            border-radius: 8px;
            border: 1px solid var(--panel-border);
            font-size: .95rem;
            line-height: 1.6;
            color: var(--panel-text);
        }

        /* ── Reason Tag ── */
        .reason-tag {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            background: #fef3c7;
            color: #92400e;
            padding: 6px 14px;
            border-radius: 8px;
            font-weight: 600;
            font-size: .9rem;
        }

        /* ── Comment Preview ── */
        .comment-preview {
            border-left: 3px solid var(--panel-accent);
            padding: 14px 20px;
            background: #f1f5f9;
            border-radius: 0 8px 8px 0;
            font-size: .95rem;
            line-height: 1.6;
            color: var(--panel-text);
            margin-top: 10px;
        }

        .comment-meta {
            display: flex;
            gap: 16px;
            margin-bottom: 12px;
            font-size: .85rem;
            color: var(--panel-text-sub);
        }

        /* ── Actions Row ── */
        .actions-row {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 8px;
        }

        .actions-row form {
            margin: 0;
        }

        .btn-modern {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: .9rem;
            font-weight: 500;
            cursor: pointer;
            border: none;
            transition: var(--panel-transition);
            min-width: 140px;
        }

        .btn-modern.primary {
            background: var(--panel-accent);
            color: white;
        }

        .btn-modern.primary:hover {
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
            transform: translateY(-1px);
        }

        .btn-modern.danger {
            background: #ef4444;
            color: white;
        }

        .btn-modern.danger:hover {
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
            transform: translateY(-1px);
        }

        .btn-modern.secondary {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #cbd5e1;
        }

        .btn-modern.secondary:hover {
            background: #e2e8f0;
            color: #1e293b;
        }

        .lock-form {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .lock-select {
            padding: 9px 12px;
            border: 1px solid var(--panel-border);
            border-radius: 8px;
            font-size: .9rem;
            outline: none;
            min-width: 140px;
        }

        /* ── Status Banner ── */
        .status-banner {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 20px;
            border-radius: 8px;
            font-weight: 500;
            font-size: .95rem;
        }

        .status-banner.resolved {
            background: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
        }

        .status-banner.ignored {
            background: #f1f5f9;
            color: #475569;
            border: 1px solid #e2e8f0;
        }

        .status-banner i {
            font-size: 1.2rem;
        }
    </style>
</head>

<body class="panel-body">

    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

    <main class="panel-main">
        <div class="container-page">
            <c:set var="defaultFeedbackBase"
                value="${fn:startsWith(pageContext.request.servletPath, '/admin/') ? '/admin/feedback' : '/staff/feedback'}" />
            <c:set var="feedbackBasePath"
                value="${not empty feedbackBasePath ? feedbackBasePath : defaultFeedbackBase}" />

            <a href="${pageContext.request.contextPath}${feedbackBasePath}?tab=reports" class="back-link">
                <i class="fas fa-arrow-left"></i> Quay lại danh sách báo cáo
            </a>

            <div class="pm-page-header">
                <div>
                    <h1 class="pm-title">
                        Chi tiết báo cáo #${report.reportId}
                    </h1>
                </div>
                <c:if test="${not empty report}">
                    <span class="pm-badge ${report.status == 'PENDING' ? 'pm-badge-warning' : (report.status == 'RESOLVED' ? 'pm-badge-success' : 'pm-badge-neutral')}" style="font-size: .85rem; padding: 6px 16px;">
                        <c:choose>
                            <c:when test="${report.status == 'PENDING'}">Chờ xử lý</c:when>
                            <c:when test="${report.status == 'RESOLVED'}">Đã xử lý</c:when>
                            <c:when test="${report.status == 'IGNORED'}">Bỏ qua</c:when>
                            <c:otherwise>${report.status}</c:otherwise>
                        </c:choose>
                    </span>
                </c:if>
            </div>

            <c:choose>
                <c:when test="${not empty report}">

                    <!-- Section: Thông tin báo cáo -->
                    <div class="report-section">
                        <div class="report-section-header">
                            <h2 class="report-section-title">
                                <i class="fas fa-info-circle" style="color: var(--panel-text-sub);"></i> Thông tin báo cáo
                            </h2>
                        </div>
                        <div class="report-section-body">
                            <div class="info-grid" style="margin-bottom: 24px;">
                                <div class="info-group">
                                    <div class="info-label">Người báo cáo</div>
                                    <div class="info-value">
                                        <div class="pm-user">
                                            <div class="pm-user-avatar"><i class="fas fa-user"></i></div>
                                            <strong>${report.reporterFullName}</strong>
                                        </div>
                                    </div>
                                </div>
                                <div class="info-group">
                                    <div class="info-label">Thời gian báo cáo</div>
                                    <div class="info-value" style="display:flex; align-items:center; height:36px;">
                                        <i class="far fa-clock" style="margin-right:8px; color:var(--panel-text-sub);"></i>
                                        <fmt:formatDate value="${report.reportTime}" pattern="HH:mm - dd/MM/yyyy" />
                                    </div>
                                </div>
                            </div>

                            <div class="info-group" style="margin-bottom: 20px;">
                                <div class="info-label">Lý do báo cáo</div>
                                <div>
                                    <span class="reason-tag">
                                        <i class="fas fa-exclamation-triangle"></i>
                                        ${reportReasonVN} (${report.reason})
                                    </span>
                                </div>
                            </div>

                            <c:if test="${not empty report.description}">
                                <div class="info-group">
                                    <div class="info-label">Mô tả chi tiết</div>
                                    <div class="info-value-block">
                                        ${report.description}
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- Section: Bình luận vi phạm -->
                    <div class="report-section">
                        <div class="report-section-header">
                            <h2 class="report-section-title">
                                <i class="fas fa-comment-alt" style="color: var(--panel-text-sub);"></i> Bình luận bị báo cáo
                            </h2>
                        </div>
                        <div class="report-section-body">
                            <div class="comment-meta">
                                <span><strong>ID bình luận:</strong> #${report.commentId}</span>
                                <span><strong>Tác giả:</strong> ${report.commentUserFullName}</span>
                            </div>
                            <div class="comment-preview">
                                ${report.commentContent}
                            </div>
                        </div>
                    </div>

                    <!-- Section: Thao tác / Trạng thái -->
                    <div class="report-section">
                        <div class="report-section-header">
                            <h2 class="report-section-title">
                                <i class="fas fa-tasks" style="color: var(--panel-text-sub);"></i> Xử lý báo cáo
                            </h2>
                        </div>
                        <div class="report-section-body">
                            <c:choose>
                                <c:when test="${report.status == 'PENDING'}">
                                    <div class="actions-row">
                                        <!-- Xử lý (giữ lại + đánh dấu đã xem) -->
                                        <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post">
                                            <input type="hidden" name="action" value="resolve" />
                                            <input type="hidden" name="reportId" value="${report.reportId}" />
                                            <button type="submit" class="btn-modern primary">
                                                <i class="fas fa-check"></i> Đánh dấu đã xử lý
                                            </button>
                                        </form>

                                        <!-- Xóa bình luận -->
                                        <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post"
                                              onsubmit="return confirm('Bạn có chắc muốn xóa bình luận này không? Hành động này không thể hoàn tác.');">
                                            <input type="hidden" name="action" value="deleteComment" />
                                            <input type="hidden" name="reportId" value="${report.reportId}" />
                                            <button type="submit" class="btn-modern danger">
                                                <i class="fas fa-trash-alt"></i> Xóa bình luận
                                            </button>
                                        </form>

                                        <div style="flex-basis: 100%; height: 12px;"></div> <!-- Break line -->

                                        <!-- Khóa & Xóa -->
                                        <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post" class="lock-form">
                                            <input type="hidden" name="action" value="lockComment" />
                                            <input type="hidden" name="reportId" value="${report.reportId}" />
                                            <select name="lockDays" class="lock-select">
                                                <option value="1">Khóa user 1 ngày</option>
                                                <option value="3">Khóa user 3 ngày</option>
                                                <option value="7">Khóa user 7 ngày</option>
                                                <option value="30">Khóa user 30 ngày</option>
                                            </select>
                                            <button type="submit" class="btn-modern danger" style="background: #b91c1c;">
                                                <i class="fas fa-user-lock"></i> Khóa & Xóa BL
                                            </button>
                                        </form>

                                        <div style="flex-basis: 100%; height: 12px;"></div> <!-- Break line -->

                                        <!-- Bỏ qua -->
                                        <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post">
                                            <input type="hidden" name="action" value="ignore" />
                                            <input type="hidden" name="reportId" value="${report.reportId}" />
                                            <button type="submit" class="btn-modern secondary">
                                                <i class="fas fa-ban"></i> Bỏ qua
                                            </button>
                                        </form>
                                    </div>
                                </c:when>
                                <c:when test="${report.status == 'RESOLVED'}">
                                    <div class="status-banner resolved">
                                        <i class="fas fa-check-circle"></i>
                                        <span>Báo cáo này đã được xem xét và xử lý.</span>
                                    </div>
                                </c:when>
                                <c:when test="${report.status == 'IGNORED'}">
                                    <div class="status-banner ignored">
                                        <i class="fas fa-info-circle"></i>
                                        <span>Báo cáo này đã được người quản trị bỏ qua.</span>
                                    </div>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>

                </c:when>
                <c:otherwise>
                    <div class="pm-card" style="text-align: center; padding: 60px 20px;">
                        <i class="fas fa-search" style="font-size: 3rem; color: var(--panel-text-sub); margin-bottom: 16px; opacity: 0.5;"></i>
                        <h2>Không tìm thấy báo cáo</h2>
                        <p style="color: var(--panel-text-sub);">Báo cáo bình luận này không tồn tại hoặc đã bị xóa.</p>
                        <a href="${pageContext.request.contextPath}${feedbackBasePath}?tab=reports" class="btn-modern primary" style="margin-top: 20px;">
                            Quay lại danh sách
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

</body>

</html>
