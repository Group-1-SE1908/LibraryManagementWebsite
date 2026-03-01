<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8">
                    <title>LBMS - Librarian Activity Log</title>
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">

                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

                    <style>
                        :root {
                            --bg-light: #F3F4F6;
                            --card: #FFFFFF;
                            --border: #E5E7EB;
                            --text-main: #111827;
                            --text-muted: #6B7280;
                            --sidebar-width: 280px;

                            /* Màu hành động mới */
                            --action-add: #059669;
                            /* Xanh lá */
                            --action-update: #D97706;
                            /* Vàng đậm/Cam */
                            --action-delete: #DC2626;
                            /* Đỏ */
                        }

                        body {
                            margin: 0;
                            background: var(--bg-light);
                            font-family: 'Inter', sans-serif;
                            display: flex;
                        }

                        .main-content {
                            flex: 1;
                            margin-left: var(--sidebar-width);
                            min-height: 100vh;
                            display: flex;
                            flex-direction: column;
                            transition: all 0.3s ease;
                        }

                        .content-container {
                            padding: 2rem;
                            width: 100%;
                            max-width: 1400px;
                            margin: 0 auto;
                            box-sizing: border-box;
                        }

                        .card {
                            background: var(--card);
                            border-radius: 12px;
                            border: 1px solid var(--border);
                            overflow: hidden;
                            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                        }

                        h1 {
                            display: flex;
                            align-items: center;
                            gap: 0.5rem;
                            font-size: 1.75rem;
                            margin-bottom: 1.5rem;
                            color: var(--text-main);
                        }

                        .table-responsive {
                            overflow-x: auto;
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse;
                        }

                        thead {
                            background: #F9FAFB;
                        }

                        th {
                            padding: 1rem;
                            font-size: 0.75rem;
                            text-transform: uppercase;
                            color: #4B5563;
                            text-align: left;
                        }

                        td {
                            padding: 1rem;
                            font-size: 0.875rem;
                            border-top: 1px solid #F3F4F6;
                            vertical-align: middle;
                        }

                        tr:hover {
                            background: rgba(0, 0, 0, 0.02);
                        }

                        .user-info {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                        }

                        .avatar {
                            width: 35px;
                            height: 35px;
                            border-radius: 50%;
                            background: #E5E7EB;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-weight: 600;
                            overflow: hidden;
                            flex-shrink: 0;
                        }

                        .avatar img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                        }

                        .badge {
                            padding: 0.25rem 0.75rem;
                            border-radius: 9999px;
                            font-size: 0.75rem;
                            font-weight: 600;
                            display: inline-block;
                        }

                        .badge-admin {
                            background: #F3E8FF;
                            color: #6B21A8;
                        }

                        .badge-lib {
                            background: #DBEAFE;
                            color: #1E40AF;
                        }

                        .badge-member {
                            background: #E5E7EB;
                            color: #374151;
                        }

                        /* Style cho Action Text */
                        .action-text {
                            font-weight: 600;
                        }

                        .text-add {
                            color: var(--action-add);
                        }

                        .text-update {
                            color: var(--action-update);
                        }

                        .text-delete {
                            color: var(--action-delete);
                        }

                        .back-link {
                            margin-top: 1.5rem;
                            display: inline-block;
                            color: #2563EB;
                            text-decoration: none;
                            font-weight: 500;
                        }

                        .back-link:hover {
                            text-decoration: underline;
                        }

                        @media (max-width: 768px) {
                            .main-content {
                                margin-left: 0;
                            }

                            .content-container {
                                padding: 1rem;
                            }
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                    <main class="main-content">
                        <div class="content-container">
                            <h1>
                                <span class="material-icons">history</span>
                                Librarian Activity Log
                            </h1>

                            <div class="card">
                                <div class="table-responsive">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>THÔNG TIN NGƯỜI DÙNG</th>
                                                <th>VAI TRÒ</th>
                                                <th>THAO TÁC</th>
                                                <th>THỜI GIAN</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="log" items="${activityLogs}">
                                                <tr>
                                                    <td>#${log.logId}</td>
                                                    <td>
                                                        <div class="user-info">
                                                            <div class="avatar">
                                                                <c:choose>
                                                                    <c:when test="${not empty log.user.avatar}">
                                                                        <img src="${pageContext.request.contextPath}/${log.user.avatar}"
                                                                            alt="Avatar">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        ${fn:toUpperCase(fn:substring(log.user.fullName,
                                                                        0, 1))}
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div>
                                                                <div class="user-name">
                                                                    <strong>${log.user.fullName}</strong>
                                                                </div>
                                                                <div class="user-email"
                                                                    style="font-size: 0.75rem; color: var(--text-muted);">
                                                                    ${log.user.email}</div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <c:set var="roleName"
                                                            value="${fn:toUpperCase(log.user.role.name)}" />
                                                        <span
                                                            class="badge ${roleName == 'ADMIN' ? 'badge-admin' : roleName == 'LIBRARIAN' ? 'badge-lib' : 'badge-member'}">
                                                            ${log.user.role.name}
                                                        </span>
                                                    </td>

                                                    <td class="action-text">
                                                        <c:choose>
                                                            <c:when
                                                                test="${fn:containsIgnoreCase(log.action, 'Thêm') || fn:containsIgnoreCase(log.action, 'Add')}">
                                                                <span class="text-add">${log.action}</span>
                                                            </c:when>
                                                            <c:when
                                                                test="${fn:containsIgnoreCase(log.action, 'Cập nhật') || fn:containsIgnoreCase(log.action, 'Update') || fn:containsIgnoreCase(log.action, 'Sửa')}">
                                                                <span class="text-update">${log.action}</span>
                                                            </c:when>
                                                            <c:when
                                                                test="${fn:containsIgnoreCase(log.action, 'Xóa') || fn:containsIgnoreCase(log.action, 'Delete')}">
                                                                <span class="text-delete">${log.action}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span>${log.action}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <td>
                                                        <fmt:formatDate value="${log.timestamp}"
                                                            pattern="dd/MM/yyyy HH:mm" />
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <a class="back-link" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
                            </a>
                        </div>
                    </main>
                </body>

                </html>