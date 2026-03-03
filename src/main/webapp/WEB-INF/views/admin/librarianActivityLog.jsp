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
                    <link
                        href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

                    <style>
                        :root {
                            --primary: #4F46E5;
                            --primary-light: #EEF2FF;
                            --bg-light: #F8FAFC;
                            --card: #FFFFFF;
                            --border: #E2E8F0;
                            --text-main: #1E293B;
                            --text-muted: #64748B;
                            --sidebar-width: 280px;
                            --action-add: #10B981;
                            --action-update: #F59E0B;
                            --action-delete: #EF4444;
                            --action-approve: #3B82F6;
                            --action-reject: #8B5CF6;
                        }

                        body {
                            margin: 0;
                            background: var(--bg-light);
                            font-family: 'Plus Jakarta Sans', sans-serif;
                            display: flex;
                            color: var(--text-main);
                        }

                        .main-content {
                            flex: 1;
                            margin-left: var(--sidebar-width);
                            min-height: 100vh;
                            display: flex;
                            flex-direction: column;
                        }

                        .content-container {
                            padding: 2.5rem;
                            max-width: 1400px;
                            margin: 0 auto;
                            width: 100%;
                            box-sizing: border-box;
                        }

                        .header-flex {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 2rem;
                        }

                        h1 {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                            font-size: 1.875rem;
                            font-weight: 700;
                            margin: 0;
                            color: var(--text-main);
                        }

                        .custom-select {
                            padding: 0.625rem 2.5rem 0.625rem 1rem;
                            border-radius: 10px;
                            border: 1px solid var(--border);
                            font-family: inherit;
                            font-size: 0.875rem;
                            color: var(--text-main);
                            background: var(--card) url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%2364748B'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E") no-repeat right 0.75rem center;
                            background-size: 1rem;
                            appearance: none;
                            cursor: pointer;
                            transition: all 0.2s;
                            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                        }

                        .custom-select:focus {
                            outline: none;
                            border-color: var(--primary);
                            box-shadow: 0 0 0 3px var(--primary-light);
                        }

                        /* --- PHẦN FIX LỖI LỆCH CỘT --- */
                        .card {
                            background: var(--card);
                            border-radius: 16px;
                            border: 1px solid var(--border);
                            box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.05);
                            overflow: hidden;
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse;
                            table-layout: fixed;
                            /* Cố định layout bảng */
                        }

                        /* Định nghĩa độ rộng cố định cho từng cột */
                        th:nth-child(1),
                        td:nth-child(1) {
                            width: 80px;
                            text-align: center;
                        }

                        /* ID */
                        th:nth-child(2),
                        td:nth-child(2) {
                            width: 25%;
                        }

                        /* Người thực hiện */
                        th:nth-child(3),
                        td:nth-child(3) {
                            width: 140px;
                        }

                        /* Vai trò */
                        th:nth-child(4),
                        td:nth-child(4) {
                            width: auto;
                        }

                        /* Thao tác - Cột co giãn */
                        th:nth-child(5),
                        td:nth-child(5) {
                            width: 220px;
                        }

                        /* Thời gian */

                        th {
                            background: #F8FAFC;
                            padding: 1rem 1.5rem;
                            font-size: 0.75rem;
                            font-weight: 700;
                            text-transform: uppercase;
                            color: var(--text-muted);
                            text-align: left;
                            border-bottom: 1px solid var(--border);
                        }

                        td {
                            padding: 1.25rem 1.5rem;
                            font-size: 0.875rem;
                            border-bottom: 1px solid var(--border);
                            vertical-align: middle;
                            word-wrap: break-word;
                        }

                        tr:hover {
                            background: #F1F5F9;
                        }

                        /* User Info */
                        .user-info {
                            display: flex;
                            align-items: center;
                            gap: 1rem;
                        }

                        .avatar {
                            width: 40px;
                            height: 40px;
                            border-radius: 10px;
                            background: var(--primary-light);
                            color: var(--primary);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-weight: 700;
                            flex-shrink: 0;
                            overflow: hidden;
                        }

                        /* Badge Styling */
                        .badge {
                            padding: 0.35rem 0.75rem;
                            border-radius: 8px;
                            font-size: 0.725rem;
                            font-weight: 600;
                            display: inline-flex;
                            align-items: center;
                            gap: 4px;
                        }

                        .badge-admin {
                            background: #F5F3FF;
                            color: #7C3AED;
                        }

                        .badge-lib {
                            background: #EFF6FF;
                            color: #2563EB;
                        }

                        .badge-member {
                            background: #F1F5F9;
                            color: #475569;
                        }

                        /* Fix cột Action */
                        .action-cell-content {
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            /* Đẩy text sang trái, nút sang phải */
                            width: 100%;
                            gap: 10px;
                        }

                        .action-text-label {
                            font-weight: 600;
                            flex: 1;
                            /* Chiếm tối đa không gian còn lại */
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

                        .text-approve {
                            color: var(--action-approve);
                        }

                        .text-reject {
                            color: var(--action-reject);
                        }

                        .btn-view-log {
                            flex-shrink: 0;
                            /* Không cho nút bị co lại */
                            display: inline-flex;
                            align-items: center;
                            padding: 0.45rem 0.85rem;
                            background: #F1F5F9;
                            color: var(--text-main);
                            text-decoration: none;
                            border-radius: 8px;
                            font-size: 0.75rem;
                            font-weight: 600;
                            transition: all 0.2s;
                            border: 1px solid var(--border);
                        }

                        .btn-view-log:hover {
                            background: var(--primary);
                            color: white;
                            border-color: var(--primary);
                            transform: translateY(-1px);
                        }

                        .time-cell {
                            color: var(--text-muted);
                            font-weight: 500;
                            white-space: nowrap;
                            display: flex;
                            align-items: center;
                            gap: 6px;
                        }

                        .back-link {
                            margin-top: 2rem;
                            display: inline-flex;
                            align-items: center;
                            gap: 0.5rem;
                            color: var(--text-muted);
                            text-decoration: none;
                            font-weight: 600;
                            transition: color 0.2s;
                        }

                        .back-link:hover {
                            color: var(--primary);
                        }

                        @media (max-width: 1024px) {
                            .main-content {
                                margin-left: 0;
                            }

                            .header-flex {
                                flex-direction: column;
                                align-items: flex-start;
                                gap: 1rem;
                            }
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                    <main class="main-content">
                        <div class="content-container">
                            <div class="header-flex">
                                <h1>
                                    <span class="material-icons">history_toggle_off</span>
                                    Librarian Activity Log
                                </h1>

                                <div class="filter-container">
                                    <form action="${pageContext.request.contextPath}/admin/librarianActivityLog"
                                        method="GET" id="filterForm">
                                        <select name="type" class="custom-select"
                                            onchange="document.getElementById('filterForm').submit()">
                                            <option value="">Tất cả nhật ký</option>
                                            <option value="BOOK" ${filterType=='BOOK' ? 'selected' : '' }>📦 Quản lý
                                                Sách</option>
                                            <option value="BORROW" ${filterType=='BORROW' ? 'selected' : '' }>📋
                                                Duyệt/Từ chối mượn</option>
                                        </select>
                                    </form>
                                </div>
                            </div>

                            <div class="card">
                                <div class="table-responsive">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>ID</th>
                                                <th>Người thực hiện</th>
                                                <th>Vai trò</th>
                                                <th>Thao tác chi tiết</th>
                                                <th>Thời gian</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="log" items="${activityLogs}">
                                                <tr>
                                                    <td
                                                        style="font-family: monospace; font-weight: 600; color: var(--text-muted);">
                                                        #${log.logId}</td>
                                                    <td>
                                                        <div class="user-info">
                                                            <div class="avatar">
                                                                <c:choose>
                                                                    <c:when test="${not empty log.user.avatar}">
                                                                        <img src="${pageContext.request.contextPath}/${log.user.avatar}"
                                                                            alt="Avatar"
                                                                            style="width:100%; height:100%; object-fit:cover;">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        ${fn:toUpperCase(fn:substring(log.user.fullName,
                                                                        0, 1))}
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div class="user-details">
                                                                <div class="user-name">
                                                                    <strong>${log.user.fullName}</strong>
                                                                </div>
                                                                <div
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
                                                            <i class="fa-solid fa-shield-halved"></i>
                                                            ${log.user.role.name}
                                                        </span>
                                                    </td>

                                                    <td>
                                                        <div class="action-cell-content">
                                                            <c:choose>
                                                                <c:when test="${fn:contains(log.action, '[ID:')}">
                                                                    <c:set var="displayText"
                                                                        value="${fn:substringBefore(log.action, ' [ID:')}" />
                                                                    <c:set var="targetId"
                                                                        value="${fn:substringBefore(fn:substringAfter(log.action, '[ID:'), ']')}" />

                                                                    <span
                                                                        class="action-text-label ${fn:containsIgnoreCase(log.action, 'Thêm') ? 'text-add' : 
                                                                  (fn:containsIgnoreCase(log.action, 'Xóa') ? 'text-delete' : 
                                                                  (fn:containsIgnoreCase(log.action, 'Duyệt') ? 'text-approve' : 
                                                                  (fn:containsIgnoreCase(log.action, 'Từ chối') ? 'text-reject' : 'text-update')))}">
                                                                        ${displayText}
                                                                    </span>

                                                                    <c:set var="detailUrl"
                                                                        value="${fn:containsIgnoreCase(log.action, 'sách') ? '/books/detail?id=' : '/borrowlibrary/detail?id='}${targetId}" />
                                                                    <a href="${pageContext.request.contextPath}${detailUrl}"
                                                                        class="btn-view-log">
                                                                        <i class="fa-solid fa-arrow-up-right-from-square"
                                                                            style="margin-right: 5px;"></i> View
                                                                    </a>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span
                                                                        class="action-text-label ${fn:containsIgnoreCase(log.action, 'Thêm') ? 'text-add' : 
                                                                  fn:containsIgnoreCase(log.action, 'Xóa') ? 'text-delete' : 'text-update'}">
                                                                        ${log.action}
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </td>

                                                    <td>
                                                        <div class="time-cell">
                                                            <i class="fa-regular fa-clock"></i>
                                                            <fmt:formatDate value="${log.timestamp}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>

                            <a class="back-link" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="fa-solid fa-chevron-left"></i> Quay lại Dashboard
                            </a>
                        </div>
                    </main>
                </body>

                </html>