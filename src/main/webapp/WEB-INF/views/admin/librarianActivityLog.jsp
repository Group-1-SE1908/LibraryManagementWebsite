<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>LBMS - Nhật ký hoạt động Thủ thư</title>
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

                        .modal {
                            display: none;
                            position: fixed;
                            z-index: 9999;
                            left: 0;
                            top: 0;
                            width: 100%;
                            height: 100%;
                            background: rgba(0, 0, 0, 0.5);
                        }

                        .modal-content {
                            background: white;
                            margin: 5% auto;
                            /* Giảm margin top xuống để thấy modal cao hơn */
                            padding: 24px;
                            /* Tăng padding một chút cho thoáng */

                            /* THAY ĐỔI Ở ĐÂY */
                            width: 90%;
                            /* Mặc định chiếm 90% chiều rộng trên màn hình nhỏ */
                            max-width: 600px;
                            /* Nhưng không bao giờ vượt quá 600px trên màn hình lớn */

                            border-radius: 12px;
                            position: relative;
                            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2);
                            transition: all 0.3s ease;
                            /* Thêm hiệu ứng mượt mà */
                        }

                        .close {
                            position: absolute;
                            right: 15px;
                            top: 10px;
                            font-size: 22px;
                            cursor: pointer;
                        }

                        body {
                            margin: 0;
                            background: var(--bg-light);
                            font-family: 'Plus Jakarta Sans', sans-serif;
                            display: flex;
                            color: var(--text-main);
                        }

                        .main-content {
                            margin-left: var(--sidebar-width);
                            min-height: 100vh;
                            width: calc(100% - var(--sidebar-width));
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
                            flex-wrap: wrap;

                            gap: 1rem;
                        }

                        h1 {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                            font-size: 1.875rem;
                            font-weight: 700;
                            margin: 0;
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


                        .card {
                            background: var(--card);
                            border-radius: 16px;
                            border: 1px solid var(--border);
                            box-shadow: 0 4px 20px -2px rgba(0, 0, 0, 0.05);
                            overflow: hidden;

                        }

                        .table-responsive {
                            width: 100%;
                            overflow-x: auto;

                            -webkit-overflow-scrolling: touch;
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse;
                            min-width: 900px;

                        }


                        th:nth-child(1),
                        td:nth-child(1) {
                            width: 80px;
                            text-align: center;
                        }

                        th:nth-child(2),
                        td:nth-child(2) {
                            width: 220px;
                        }

                        th:nth-child(3),
                        td:nth-child(3) {
                            width: 140px;
                        }

                        th:nth-child(4),
                        td:nth-child(4) {
                            width: auto;
                        }

                        th:nth-child(5),
                        td:nth-child(5) {
                            width: 180px;
                        }

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

                        /* User Info & Badges */
                        .user-info {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                        }

                        .avatar {
                            width: 36px;
                            height: 36px;
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

                        .badge {
                            padding: 0.35rem 0.75rem;
                            border-radius: 8px;
                            font-size: 0.725rem;
                            font-weight: 600;
                            display: inline-flex;
                            align-items: center;
                            gap: 4px;
                            white-space: nowrap;
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

                        /* Action Column */
                        .action-cell-content {
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            gap: 10px;
                        }

                        .action-text-label {
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

                        .text-approve {
                            color: var(--action-approve);
                        }

                        .text-reject {
                            color: var(--action-reject);
                        }

                        .btn-view-log {
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
                            white-space: nowrap;
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

                        @media (max-width:1100px) {

                            .main-content {
                                margin-left: 80px;
                                width: calc(100% - 80px);
                            }

                        }

                        @media (max-width: 1024px) {
                            .main-content {
                                margin-left: 0;
                                width: 100%;
                            }

                            .content-container {
                                padding: 1.5rem;
                            }

                            .header-flex {
                                flex-direction: column;
                                align-items: flex-start;
                            }
                        }

                        @media (max-width: 640px) {
                            h1 {
                                font-size: 1.5rem;
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
                            <div class="header-flex">
                                <h1>
                                    <span class="material-icons">history_toggle_off</span>
                                    Nhật ký hoạt động
                                </h1>

                                <div class="filter-container">
                                    <form action="${pageContext.request.contextPath}/admin/librarianActivityLog"
                                        method="GET" id="filterForm">
                                        <select name="filterType" class="custom-select" onchange="this.form.submit()">
                                            <option value="">Tất cả nhật ký</option>
                                            <option value="BOOK" ${filterType=='BOOK' ? 'selected' : '' }>📦 Quản lý
                                                Sách</option>
                                            <option value="BORROW" ${filterType=='BORROW' ? 'selected' : '' }>📋 Duyệt
                                                mượn</option>
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

                                            <c:choose>

                                                <c:when test="${empty activityLogs}">

                                                    <tr>
                                                        <td colspan="5" class="empty">
                                                            Không có nhật ký hoạt động
                                                        </td>
                                                    </tr>

                                                </c:when>
                                                <c:otherwise>
                                                    <c:forEach var="log" items="${activityLogs}">
                                                        <tr>
                                                            <td
                                                                style="font-family: monospace; font-weight: 600; color: var(--text-muted);">
                                                                #${log.logId}
                                                            </td>
                                                            <td>
                                                                <div class="user-info">
                                                                    <div class="avatar">
                                                                        <c:choose>
                                                                            <c:when test="${not empty log.user.avatar}">
                                                                                <img src="${pageContext.request.contextPath}/${log.user.avatar}"
                                                                                    alt="Avt"
                                                                                    style="width:100%; height:100%; object-fit:cover;">
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span>${fn:toUpperCase(fn:substring(log.user.fullName,
                                                                                    0, 1))}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <div class="user-details">
                                                                        <div
                                                                            style="font-weight: 700; line-height: 1.2;">
                                                                            ${log.user.fullName}</div>
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
                                                                    class="badge ${roleName == 'ADMIN' ? 'badge-admin' : (roleName == 'LIBRARIAN' ? 'badge-lib' : 'badge-member')}">
                                                                    <i class="fa-solid fa-shield-halved"></i>
                                                                    ${log.user.role.name}
                                                                </span>
                                                            </td>
                                                            <td>
                                                                <div class="action-cell-content">
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${fn:contains(log.action, '[ID:')}">
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
                                                                                value="${fn:containsIgnoreCase(log.action, 'sách') ? '/books/detail?id=' : '/admin/borrowlibrary/detail?id='}${targetId}" />
                                                                            <button class="btn-view-log view-detail-btn"
                                                                                data-id="${targetId}"
                                                                                data-type="${fn:containsIgnoreCase(log.action,'sách') ? 'BOOK' : 'BORROW'}">
                                                                                <i class="fa-solid fa-eye"></i>
                                                                            </button>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span
                                                                                class="action-text-label ${fn:containsIgnoreCase(log.action, 'Thêm') ? 'text-add' : 
                                                        (fn:containsIgnoreCase(log.action, 'Xóa') ? 'text-delete' : 'text-update')}">
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
                                                </c:otherwise>
                                            </c:choose>


                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <!-- MODAL -->
                            <div id="detailModal" class="modal">
                                <div class="modal-content">
                                    <span class="close">&times;</span>
                                    <h3>Chi tiết hoạt động</h3>
                                    <div id="modalBody">
                                        Đang tải dữ liệu...
                                    </div>
                                </div>
                            </div>
                            <script>
                                const modal = document.getElementById("detailModal");
                                const modalBody = document.getElementById("modalBody");
                                const closeBtn = document.querySelector(".close");

                                document.querySelectorAll(".view-detail-btn").forEach(btn => {

                                    btn.addEventListener("click", function () {

                                        const id = this.dataset.id;
                                        const type = this.dataset.type;

                                        modal.style.display = "block";
                                        modalBody.innerHTML = "Đang tải dữ liệu...";

                                        const url =
                                            "${pageContext.request.contextPath}/admin/librarianActivityLog?modal=true&detailType="
                                            + type +
                                            "&id=" +
                                            id;

                                        fetch(url)
                                            .then(res => res.text())
                                            .then(data => {

                                                modalBody.innerHTML = data;

                                            })
                                            .catch(() => {

                                                modalBody.innerHTML = "Không tải được dữ liệu.";

                                            });

                                    });

                                });

                                closeBtn.onclick = function () {
                                    modal.style.display = "none";
                                };

                                window.onclick = function (event) {
                                    if (event.target == modal) {
                                        modal.style.display = "none";
                                    }
                                };
                            </script>

                            <a class="back-link" href="${pageContext.request.contextPath}/admin/dashboard">
                                <i class="fa-solid fa-chevron-left"></i> Quay lại Dashboard
                            </a>
                        </div>
                    </main>
                </body>

                </html>