<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
            <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>LBMS – Nhật ký hoạt động thủ thư</title>
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
                                <h1 class="pm-title"><i class="fas fa-history"
                                        style="color:var(--panel-accent);margin-right:8px;"></i>Nhật ký hoạt động</h1>
                                <p class="pm-subtitle">Theo dõi các thao tác của thủ thư trên hệ thống.</p>
                            </div>
                            <div>
                                <form action="${pageContext.request.contextPath}/admin/librarianActivityLog"
                                    method="GET">
                                    <select name="filterType" class="pm-select" style="min-width:180px;"
                                        onchange="this.form.submit()">
                                        <option value="">Tất cả nhật ký</option>
                                        <option value="BOOK" ${filterType=='BOOK' ? 'selected' : '' }>📦 Quản lý Sách
                                        </option>
                                        <option value="BORROW" ${filterType=='BORROW' ? 'selected' : '' }>📋 Duyệt mượn
                                        </option>
                                    </select>
                                </form>
                            </div>
                        </div>

                        <div class="pm-card">
                            <div class="pm-table-wrap">
                                <table class="pm-table">
                                    <thead>
                                        <tr>
                                            <th style="width:70px;">ID</th>
                                            <th>Người thực hiện</th>
                                            <th style="width:130px;">Vai trò</th>
                                            <th>Thao tác chi tiết</th>
                                            <th style="width:160px;">Thời gian</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${empty activityLogs}">
                                                <tr>
                                                    <td colspan="5">
                                                        <div class="pm-empty"><i class="fas fa-history"></i>
                                                            <p>Không có nhật ký hoạt động.</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach var="log" items="${activityLogs}">
                                                    <tr>
                                                        <td
                                                            style="font-family:monospace;font-weight:600;color:var(--panel-text-sub);">
                                                            #${log.logId}</td>
                                                        <td>
                                                            <div class="pm-user">
                                                                <div class="pm-user-avatar">
                                                                    <c:choose>
                                                                        <c:when test="${not empty log.user.avatar}">
                                                                            <img src="${pageContext.request.contextPath}/${log.user.avatar}"
                                                                                alt="Avt"
                                                                                style="width:100%;height:100%;object-fit:cover;border-radius:8px;" />
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            ${fn:toUpperCase(fn:substring(log.user.fullName,
                                                                            0, 1))}
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <div>
                                                                    <div style="font-weight:700;line-height:1.2;">
                                                                        ${log.user.fullName}</div>
                                                                    <div
                                                                        style="font-size:.75rem;color:var(--panel-text-sub);">
                                                                        ${log.user.email}</div>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <c:set var="roleName"
                                                                value="${fn:toUpperCase(log.user.role.name)}" />
                                                            <span
                                                                class="pm-badge ${roleName == 'ADMIN' ? 'pm-badge-danger' : (roleName == 'LIBRARIAN' ? 'pm-badge-primary' : 'pm-badge-neutral')}">
                                                                <i class="fa-solid fa-shield-halved"></i>
                                                                ${log.user.role.name}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <div
                                                                style="display:flex;align-items:center;justify-content:space-between;gap:10px;">
                                                                <c:choose>
                                                                    <c:when test="${fn:contains(log.action, '[ID:')}">
                                                                        <c:set var="displayText"
                                                                            value="${fn:substringBefore(log.action, ' [ID:')}" />
                                                                        <c:set var="targetId"
                                                                            value="${fn:substringBefore(fn:substringAfter(log.action, '[ID:'), ']')}" />
                                                                        <span
                                                                            class="
                                                        ${fn:containsIgnoreCase(log.action, 'Thêm') ? 'pm-act-add' :
                                                         (fn:containsIgnoreCase(log.action, 'Xóa') ? 'pm-act-delete' :
                                                         (fn:containsIgnoreCase(log.action, 'Duyệt') ? 'pm-act-approve' :
                                                         (fn:containsIgnoreCase(log.action, 'Từ chối') ? 'pm-act-reject' : 'pm-act-update')))}">
                                                                            ${displayText}
                                                                        </span>
                                                                        <button class="pm-btn-view-log view-detail-btn"
                                                                            data-id="${targetId}"
                                                                            data-type="${fn:containsIgnoreCase(log.action,'sách') ? 'BOOK' : 'BORROW'}">
                                                                            <i class="fa-solid fa-eye"></i>
                                                                        </button>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span
                                                                            class="
                                                        ${fn:containsIgnoreCase(log.action, 'Thêm') ? 'pm-act-add' :
                                                         (fn:containsIgnoreCase(log.action, 'Xóa') ? 'pm-act-delete' : 'pm-act-update')}">
                                                                            ${log.action}
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </td>
                                                        <td style="white-space:nowrap;color:var(--panel-text-sub);">
                                                            <i class="fa-regular fa-clock"
                                                                style="margin-right:4px;"></i>
                                                            <fmt:formatDate value="${log.timestamp}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <a class="pm-back-link" href="${pageContext.request.contextPath}/admin/dashboard">
                            <i class="fa-solid fa-chevron-left"></i> Quay lại Dashboard
                        </a>

                    </main>

                    <%-- Detail modal (AJAX) --%>
                        <div id="detailModal" class="pm-modal-overlay">
                            <div class="pm-modal" style="max-width:600px;">
                                <div class="pm-modal-header">
                                    <span class="pm-modal-title"><i class="fas fa-info-circle"></i> Chi tiết hoạt
                                        động</span>
                                    <button type="button" class="pm-modal-close" id="closeDetailModal">&times;</button>
                                </div>
                                <div class="pm-modal-body" id="modalBody">Đang tải dữ liệu...</div>
                            </div>
                        </div>

                        <script>
                            const detailModal = document.getElementById('detailModal');
                            const modalBody = document.getElementById('modalBody');

                            document.querySelectorAll('.view-detail-btn').forEach(btn => {
                                btn.addEventListener('click', function () {
                                    const id = this.dataset.id;
                                    const type = this.dataset.type;
                                    detailModal.classList.add('active');
                                    modalBody.innerHTML = 'Đang tải dữ liệu...';
                                    const url = '${pageContext.request.contextPath}/admin/librarianActivityLog?modal=true&detailType=' + type + '&id=' + id;
                                    fetch(url)
                                        .then(res => res.text())
                                        .then(data => { modalBody.innerHTML = data; })
                                        .catch(() => { modalBody.innerHTML = 'Không tải được dữ liệu.'; });
                                });
                            });

                            document.getElementById('closeDetailModal').addEventListener('click', () => {
                                detailModal.classList.remove('active');
                            });

                            detailModal.addEventListener('click', e => {
                                if (e.target === detailModal) detailModal.classList.remove('active');
                            });
                        </script>
                </body>

                </html>