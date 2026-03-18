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
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                </head>

                <body class="panel-body">

                    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                    <main class="panel-main">

                        <div class="pm-page-header">
                            <div>
                                <h1 class="pm-title"><i class="fas fa-flag"
                                        style="color:var(--panel-accent);margin-right:8px;"></i>Quản lý báo cáo bình
                                    luận</h1>
                                <p class="pm-subtitle">Xem xét và xử lý các báo cáo từ người dùng về bình luận vi phạm.
                                </p>
                            </div>
                        </div>

                        <div class="pm-card">
                            <c:choose>
                                <c:when test="${not empty reports}">
                                    <div class="pm-table-wrap">
                                        <table class="pm-table">
                                            <thead>
                                                <tr>
                                                    <th style="width:60px;">ID</th>
                                                    <th>Người báo cáo</th>
                                                    <th>Bình luận bị báo cáo</th>
                                                    <th>Lý do</th>
                                                    <th>Thời gian</th>
                                                    <th>Trạng thái</th>
                                                    <th style="text-align:right;">Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="report" items="${reports}">
                                                    <tr>
                                                        <td style="color:var(--panel-text-sub);font-size:.8rem;">
                                                            #${report.reportId}</td>
                                                        <td><strong>${report.reporterFullName}</strong></td>
                                                        <td>
                                                            <div class="pm-comment-box"
                                                                title="${fn:escapeXml(report.commentContent)}">
                                                                ${fn:escapeXml(fn:substring(report.commentContent, 0,
                                                                80))}${fn:length(report.commentContent) > 80 ? '…' : ''}
                                                            </div>
                                                            <div class="pm-comment-author">Bởi:
                                                                ${report.commentUserFullName}</div>
                                                        </td>
                                                        <td><span class="pm-reason-tag">${report.reason}</span></td>
                                                        <td
                                                            style="white-space:nowrap;font-size:.8rem;color:var(--panel-text-sub);">
                                                            <fmt:formatDate value="${report.reportTime}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                        <td>
                                                            <span
                                                                class="pm-badge ${report.status == 'PENDING' ? 'pm-badge-warning' : (report.status == 'RESOLVED' ? 'pm-badge-success' : 'pm-badge-neutral')}">
                                                                <c:choose>
                                                                    <c:when test="${report.status == 'PENDING'}">Chờ xử
                                                                        lý</c:when>
                                                                    <c:when test="${report.status == 'RESOLVED'}">Đã xử
                                                                        lý</c:when>
                                                                    <c:when test="${report.status == 'IGNORED'}">Bỏ qua
                                                                    </c:when>
                                                                    <c:otherwise>${report.status}</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <c:if test="${report.status == 'PENDING'}">
                                                                <div class="pm-actions"
                                                                    style="justify-content:flex-end;flex-wrap:wrap;">
                                                                    <form method="post">
                                                                        <input type="hidden" name="action"
                                                                            value="resolve" />
                                                                        <input type="hidden" name="reportId"
                                                                            value="${report.reportId}" />
                                                                        <button type="submit"
                                                                            class="pm-action-btn success">
                                                                            <i class="fas fa-check"></i> Giải quyết
                                                                        </button>
                                                                    </form>
                                                                    <form method="post">
                                                                        <input type="hidden" name="action"
                                                                            value="ignore" />
                                                                        <input type="hidden" name="reportId"
                                                                            value="${report.reportId}" />
                                                                        <button type="submit" class="pm-action-btn"
                                                                            style="color:var(--panel-text-sub);">
                                                                            <i class="fas fa-ban"></i> Bỏ qua
                                                                        </button>
                                                                    </form>
                                                                    <form method="post"
                                                                        onsubmit="return confirm('Bạn có chắc muốn xóa bình luận này?')">
                                                                        <input type="hidden" name="action"
                                                                            value="delete" />
                                                                        <input type="hidden" name="reportId"
                                                                            value="${report.reportId}" />
                                                                        <button type="submit"
                                                                            class="pm-action-btn danger">
                                                                            <i class="fas fa-trash"></i> Xóa bình luận
                                                                        </button>
                                                                    </form>
                                                                </div>
                                                            </c:if>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </tbody>
                                        </table>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="pm-empty">
                                        <i class="fas fa-inbox"></i>
                                        <p>Chưa có báo cáo nào.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </main>
                </body>

                </html>