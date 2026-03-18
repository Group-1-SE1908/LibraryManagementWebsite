<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>LBMS – Quản lý người dùng</title>
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                    rel="stylesheet" />
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />

            </head>

            <body class="panel-body">

                <jsp:include page="sidebar.jsp" />

                <main class="panel-main">

                    <%-- Page Header --%>
                        <div class="pm-page-header">
                            <div>
                                <h1 class="pm-title"><i class="fas fa-users"
                                        style="color:var(--panel-accent);margin-right:8px;"></i>Quản lý người dùng</h1>
                                <p class="pm-subtitle">Quản lý thành viên thư viện, vai trò và trạng thái tài khoản.</p>
                            </div>
                            <a href="${pageContext.request.contextPath}/admin/users/create"
                                class="pm-btn pm-btn-primary">
                                <i class="fas fa-user-plus"></i> Thêm người dùng mới
                            </a>
                        </div>

                        <%-- Toast notification --%>
                            <c:if test="${not empty flash}">
                                <c:set var="isErr"
                                    value="${flash.contains('Error') || flash.contains('không thể') || flash.contains('Lỗi')}" />
                                <div id="toast-msg" class="pm-toast ${isErr ? 'pm-toast-danger' : 'pm-toast-success'}">
                                    <i class="fas ${isErr ? 'fa-circle-exclamation' : 'fa-circle-check'}"></i>
                                    <span>${flash}</span>
                                </div>
                                <c:remove var="flash" scope="session" />
                            </c:if>

                            <%-- Search toolbar --%>
                                <div class="pm-toolbar">
                                    <form method="get" action="${pageContext.request.contextPath}/admin/users"
                                        style="flex:1;display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
                                        <div style="position:relative;flex:1;min-width:220px;">
                                            <i class="fas fa-search"
                                                style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--panel-text-sub);font-size:.85rem;pointer-events:none;"></i>
                                            <input type="text" name="keyword" value="${keyword}" class="pm-input"
                                                style="width:100%;padding-left:36px;"
                                                placeholder="Tìm kiếm theo tên hoặc email...">
                                        </div>
                                        <button type="submit" class="pm-btn pm-btn-primary"><i
                                                class="fas fa-search"></i> Tìm kiếm</button>
                                        <c:if test="${not empty keyword}">
                                            <a href="${pageContext.request.contextPath}/admin/users"
                                                class="pm-btn pm-btn-outline">
                                                <i class="fas fa-xmark"></i> Xóa lọc
                                            </a>
                                        </c:if>
                                    </form>
                                </div>

                                <%-- Table card --%>
                                    <div class="pm-card" style="padding:0;overflow:hidden;">
                                        <c:choose>
                                            <c:when test="${not empty userList}">
                                                <div class="pm-table-wrap">
                                                    <table class="pm-table">
                                                        <thead>
                                                            <tr>
                                                                <th>ID</th>
                                                                <th>Thành viên</th>
                                                                <th>Số điện thoại</th>
                                                                <th>Địa chỉ</th>
                                                                <th>Vai trò</th>
                                                                <th style="text-align:center;">Trạng thái</th>
                                                                <th style="text-align:right;">Thao tác</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="user" items="${userList}">
                                                                <tr>
                                                                    <td
                                                                        style="font-weight:600;color:var(--panel-text-sub);font-size:.8rem;">
                                                                        #${user.id}</td>

                                                                    <td>
                                                                        <div class="pm-user">
                                                                            <div class="pm-user-avatar">
                                                                                <c:choose>
                                                                                    <c:when
                                                                                        test="${not empty user.avatar}">
                                                                                        <img src="${pageContext.request.contextPath}/${user.avatar}"
                                                                                            alt="">
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        ${user.fullName.substring(0,1).toUpperCase()}
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                            </div>
                                                                            <div>
                                                                                <div
                                                                                    style="font-weight:600;color:var(--panel-text);">
                                                                                    ${user.fullName}</div>
                                                                                <div
                                                                                    style="font-size:.75rem;color:var(--panel-text-sub);">
                                                                                    ${user.email}</div>
                                                                            </div>
                                                                        </div>
                                                                    </td>

                                                                    <td>${not empty user.phone ? user.phone : '—'}</td>

                                                                    <td
                                                                        style="max-width:180px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                                        ${not empty user.address ? user.address : '—'}
                                                                    </td>

                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${user.role.name == 'Admin' || user.role.name == 'ADMIN'}">
                                                                                <span
                                                                                    class="pm-badge pm-badge-primary"><i
                                                                                        class="fas fa-shield-halved"></i>
                                                                                    Admin</span>
                                                                            </c:when>
                                                                            <c:when
                                                                                test="${user.role.name == 'Librarian' || user.role.name == 'LIBRARIAN'}">
                                                                                <span class="pm-badge pm-badge-info"><i
                                                                                        class="fas fa-book"></i> Thủ
                                                                                    thư</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="pm-badge pm-badge-neutral"><i
                                                                                        class="fas fa-user"></i>
                                                                                    ${user.role.name}</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>

                                                                    <td style="text-align:center;">
                                                                        <c:choose>
                                                                            <c:when test="${user.status == 'ACTIVE'}">
                                                                                <span
                                                                                    class="pm-badge pm-badge-success">Hoạt
                                                                                    động</span>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    class="pm-badge pm-badge-danger">Bị
                                                                                    khóa</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>

                                                                    <td>
                                                                        <div class="pm-actions"
                                                                            style="justify-content:flex-end;">
                                                                            <a href="${pageContext.request.contextPath}/admin/users/view?id=${user.id}&page=${currentPage}&keyword=${keyword}"
                                                                                class="pm-action-btn view">
                                                                                <i class="fas fa-eye"></i> Xem
                                                                            </a>
                                                                            <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}&page=${currentPage}&keyword=${keyword}"
                                                                                class="pm-action-btn edit">
                                                                                <i class="fas fa-pen"></i> Sửa
                                                                            </a>
                                                                            <form
                                                                                action="${pageContext.request.contextPath}/admin/users/status"
                                                                                method="post" style="display:inline;">
                                                                                <input type="hidden" name="id"
                                                                                    value="${user.id}">
                                                                                <input type="hidden" name="status"
                                                                                    value="${user.status == 'ACTIVE' ? 'BLOCKED' : 'ACTIVE'}">
                                                                                <input type="hidden" name="page"
                                                                                    value="${currentPage}">
                                                                                <input type="hidden" name="keyword"
                                                                                    value="${keyword}">
                                                                                <button type="button"
                                                                                    onclick="openConfirmModal(this.closest('form'))"
                                                                                    class="pm-action-btn ${user.status == 'ACTIVE' ? 'danger' : 'success'}">
                                                                                    <i
                                                                                        class="fas ${user.status == 'ACTIVE' ? 'fa-lock' : 'fa-lock-open'}"></i>
                                                                                    ${user.status == 'ACTIVE' ? 'Khóa' :
                                                                                    'Mở khóa'}
                                                                                </button>
                                                                            </form>
                                                                        </div>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                    </table>
                                                </div>

                                                <%-- Pagination --%>
                                                    <div
                                                        style="display:flex;justify-content:space-between;align-items:center;padding:14px 20px;border-top:1px solid var(--panel-border);background:#f8fafc;font-size:.8rem;color:var(--panel-text-sub);flex-wrap:wrap;gap:10px;">
                                                        <span>Hiển thị
                                                            <b>${(currentPage - 1) * pageSize + 1}</b>–<b>
                                                                <c:set var="endRow" value="${currentPage * pageSize}" />
                                                                ${endRow > totalUsers ? totalUsers : endRow}
                                                            </b> trong <b>${totalUsers}</b> người dùng</span>
                                                        <nav class="pm-pagination" style="margin-top:0;">
                                                            <c:if test="${currentPage > 1}">
                                                                <a href="?page=${currentPage - 1}&keyword=${keyword}"><i
                                                                        class="fas fa-chevron-left"></i></a>
                                                            </c:if>
                                                            <c:set var="beginPage"
                                                                value="${currentPage - 1 > 0 ? currentPage - 1 : 1}" />
                                                            <c:set var="endPage"
                                                                value="${beginPage + 2 > totalPages ? totalPages : beginPage + 2}" />
                                                            <c:if test="${endPage == totalPages and endPage - 2 > 0}">
                                                                <c:set var="beginPage" value="${endPage - 2}" />
                                                            </c:if>
                                                            <c:forEach begin="${beginPage}" end="${endPage}" var="i">
                                                                <a href="?page=${i}&keyword=${keyword}"
                                                                    class="${i == currentPage ? 'active' : ''}">${i}</a>
                                                            </c:forEach>
                                                            <c:if test="${currentPage < totalPages}">
                                                                <a href="?page=${currentPage + 1}&keyword=${keyword}"><i
                                                                        class="fas fa-chevron-right"></i></a>
                                                            </c:if>
                                                        </nav>
                                                    </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="pm-empty">
                                                    <i class="fas fa-magnifying-glass"></i>
                                                    <p>Không tìm thấy người dùng phù hợp.</p>
                                                    <a href="${pageContext.request.contextPath}/admin/users"
                                                        class="pm-btn pm-btn-outline" style="margin-top:12px;">
                                                        Xem tất cả
                                                    </a>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                </main>

                <%-- Confirm Modal --%>
                    <div id="confirmModal" class="pm-modal-overlay">
                        <div class="pm-modal">
                            <div class="pm-modal-header">
                                <h3 class="pm-modal-title">
                                    <i class="fas fa-triangle-exclamation"
                                        style="color:var(--panel-warning);margin-right:6px;"></i>
                                    Xác nhận thay đổi
                                </h3>
                                <button class="pm-modal-close" onclick="closeConfirmModal()">&times;</button>
                            </div>
                            <div class="pm-modal-body">
                                <p style="font-size:.875rem;color:var(--panel-text-sub);margin:0;">
                                    Bạn có chắc chắn muốn thay đổi trạng thái của người dùng này không?
                                </p>
                            </div>
                            <div class="pm-modal-footer">
                                <button class="pm-btn pm-btn-outline" onclick="closeConfirmModal()">Hủy</button>
                                <button id="confirmSubmitBtn" class="pm-btn pm-btn-danger">Xác nhận</button>
                            </div>
                        </div>
                    </div>

                    <script>
                        let pendingForm = null;

                        function openConfirmModal(form) {
                            pendingForm = form;
                            document.getElementById('confirmModal').classList.add('active');
                        }

                        function closeConfirmModal() {
                            document.getElementById('confirmModal').classList.remove('active');
                        }

                        document.getElementById('confirmSubmitBtn').addEventListener('click', function () {
                            if (pendingForm) pendingForm.submit();
                        });

                        document.addEventListener('DOMContentLoaded', function () {
                            const toast = document.getElementById('toast-msg');
                            if (toast) {
                                setTimeout(() => {
                                    toast.style.opacity = '0';
                                    toast.style.transition = 'opacity .5s';
                                    setTimeout(() => toast.remove(), 500);
                                }, 3500);
                            }
                        });
                    </script>
            </body>

            </html>