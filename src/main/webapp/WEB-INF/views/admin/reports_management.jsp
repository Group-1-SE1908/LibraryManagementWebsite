<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Quản lý báo cáo bình luận | LBMS</title>

                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">

                    <style>
                        :root {
                            --sidebar-width: 280px;
                            --primary: #4f46e5;
                            --success: #10b981;
                            --danger: #ef4444;
                            --warning: #f59e0b;
                            --info: #0ea5e9;
                            --bg-body: #f3f4f6;
                            --text-main: #1f2937;
                            --text-sub: #6b7280;
                            --white: #ffffff;
                            --border: #e5e7eb;
                        }

                        * {
                            box-sizing: border-box;
                        }

                        body {
                            font-family: 'Inter', sans-serif;
                            background: var(--bg-body);
                            margin: 0;
                            color: var(--text-main);
                        }

                        .admin-layout {
                            display: flex;
                            min-height: 100vh;
                        }

                        .main-content {
                            flex: 1;
                            margin-left: var(--sidebar-width);
                            padding: 2rem;
                        }

                        .page-header {
                            background: var(--white);
                            padding: 1.5rem;
                            border-radius: 8px;
                            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                            margin-bottom: 2rem;
                        }

                        .page-title {
                            font-size: 1.875rem;
                            font-weight: 700;
                            margin: 0;
                            color: var(--text-main);
                        }

                        .reports-table {
                            background: var(--white);
                            border-radius: 8px;
                            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                            overflow: hidden;
                        }

                        .table {
                            width: 100%;
                            border-collapse: collapse;
                        }

                        .table th,
                        .table td {
                            padding: 1rem;
                            text-align: left;
                            border-bottom: 1px solid var(--border);
                        }

                        .table th {
                            background: #f9fafb;
                            font-weight: 600;
                            color: var(--text-main);
                        }

                        .status-badge {
                            padding: 0.25rem 0.75rem;
                            border-radius: 9999px;
                            font-size: 0.875rem;
                            font-weight: 500;
                        }

                        .status-pending {
                            background: #fef3c7;
                            color: #f59e0b;
                        }

                        .status-resolved {
                            background: #d1fae5;
                            color: #10b981;
                        }

                        .status-ignored {
                            background: #e5e7eb;
                            color: #6b7280;
                        }

                        .btn {
                            padding: 0.5rem 1rem;
                            border: none;
                            border-radius: 6px;
                            cursor: pointer;
                            font-size: 0.875rem;
                            font-weight: 500;
                            text-decoration: none;
                            display: inline-block;
                            transition: all 0.2s;
                        }

                        .btn-success {
                            background: var(--success);
                            color: white;
                        }

                        .btn-success:hover {
                            background: #059669;
                        }

                        .btn-secondary {
                            background: var(--text-sub);
                            color: white;
                        }

                        .btn-secondary:hover {
                            background: #4b5563;
                        }

                        .btn-danger {
                            background: var(--danger);
                            color: white;
                        }

                        .btn-danger:hover {
                            background: #dc2626;
                        }

                        .comment-preview {
                            max-width: 300px;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                        }

                        .action-buttons {
                            display: flex;
                            gap: 0.5rem;
                        }

                        .no-reports {
                            text-align: center;
                            padding: 3rem;
                            color: var(--text-sub);
                        }
                    </style>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
</head>

                <body class="panel-body">
                    <div class="admin-layout">
                        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                        <main class="main-content">
                            <div class="page-header">
                                <h1 class="page-title">Quản lý báo cáo bình luận</h1>
                            </div>

                            <div class="reports-table">
                                <c:choose>
                                    <c:when test="${not empty reports}">
                                        <table class="table">
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Người báo cáo</th>
                                                    <th>Bình luận</th>
                                                    <th>Lý do</th>
                                                    <th>Thời gian</th>
                                                    <th>Trạng thái</th>
                                                    <th>Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="report" items="${reports}">
                                                    <tr>
                                                        <td>${report.reportId}</td>
                                                        <td>${report.reporterFullName}</td>
                                                        <td>
                                                            <div class="comment-preview"
                                                                title="${fn:escapeXml(report.commentContent)}">
                                                                ${fn:escapeXml(fn:substring(report.commentContent, 0,
                                                                50))}${fn:length(report.commentContent) > 50 ? '...' :
                                                                ''}
                                                            </div>
                                                            <small style="color: var(--text-sub);">Bởi:
                                                                ${report.commentUserFullName}</small>
                                                        </td>
                                                        <td>${report.reason}</td>
                                                        <td>
                                                            <fmt:formatDate value="${report.reportTime}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                        <td>
                                                            <span
                                                                class="status-badge status-${fn:toLowerCase(report.status)}">
                                                                <c:choose>
                                                                    <c:when test="${report.status == 'PENDING'}">Chờ xử
                                                                        lý</c:when>
                                                                    <c:when test="${report.status == 'RESOLVED'}">Đã xử
                                                                        lý</c:when>
                                                                    <c:when test="${report.status == 'IGNORED'}">Bỏ qua
                                                                    </c:when>
                                                                </c:choose>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <c:if test="${report.status == 'PENDING'}">
                                                                <div class="action-buttons">
                                                                    <form method="post" style="display: inline;">
                                                                        <input type="hidden" name="action"
                                                                            value="resolve">
                                                                        <input type="hidden" name="reportId"
                                                                            value="${report.reportId}">
                                                                        <button type="submit"
                                                                            class="btn btn-success">Giải quyết</button>
                                                                    </form>
                                                                    <form method="post" style="display: inline;">
                                                                        <input type="hidden" name="action"
                                                                            value="ignore">
                                                                        <input type="hidden" name="reportId"
                                                                            value="${report.reportId}">
                                                                        <button type="submit"
                                                                            class="btn btn-secondary">Bỏ qua</button>
                                                                    </form>
                                                                    <form method="post" style="display: inline;"
                                                                        onsubmit="return confirm('Bạn có chắc muốn xóa bình luận này?')">
                                                                        <input type="hidden" name="action"
                                                                            value="delete">
                                                                        <input type="hidden" name="reportId"
                                                                            value="${report.reportId}">
                                                                        <button type="submit" class="btn btn-danger">Xóa
                                                                            bình luận</button>
                                                                    </form>
                                                                </div>
                                                            </c:if>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="no-reports">
                                            <i class="fas fa-inbox fa-3x"
                                                style="color: var(--text-sub); margin-bottom: 1rem;"></i>
                                            <p>Chưa có báo cáo nào</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </main>
                    </div>
                </body>

                </html>