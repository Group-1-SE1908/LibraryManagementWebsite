<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8" />
        <meta content="width=device-width, initial-scale=1.0" name="viewport" />
        <title>LBMS - Quản lý người dùng</title>

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
              rel="stylesheet" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />

        <style>
            :root {
                --primary-color: #1E40AF;
                --primary-hover: #1e3a8a;
                --bg-light: #F3F4F6;
                --card-light: #FFFFFF;
                --text-main: #111827;
                --text-muted: #6B7280;
                --border-color: #E5E7EB;
            }

            * {
                box-sizing: border-box;
                font-family: 'Inter', sans-serif;
            }

            body {
                margin: 0;
                padding: 0;
                background-color: var(--bg-light);
                color: var(--text-main);
            }

            .app-container {
                display: flex;
                min-height: 100vh;
            }

            .main-wrapper {
                flex: 1;
                margin-left: 280px;
                background-color: var(--bg-light);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                transition: margin-left 0.3s;
            }

            .content-area {
                padding: 2rem;
                flex: 1;
            }

            .max-w-7xl {
                max-width: 80rem;
                margin: 0 auto;
            }

            /* Header & Buttons */
            .header-section {
                display: flex;
                flex-direction: row;
                align-items: center;
                justify-content: space-between;
                margin-bottom: 2rem;
                gap: 1rem;
            }

            .btn-add {
                display: inline-flex;
                align-items: center;
                padding: 0.625rem 1.25rem;
                background-color: var(--primary-color);
                color: white;
                font-weight: 600;
                border-radius: 0.5rem;
                text-decoration: none;
                gap: 0.5rem;
                box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
                transition: background-color 0.2s;
            }

            .btn-add:hover {
                background-color: var(--primary-hover);
            }

            /* Notifications */
            #toast-msg {
                margin-bottom: 1rem;
                padding: 1rem;
                border-left: 4px solid;
                border-radius: 0.25rem;
                display: flex;
                align-items: center;
                gap: 0.75rem;
                box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
                transition: opacity 0.5s ease-out;
            }

            .msg-error {
                background-color: #FEE2E2;
                border-color: #EF4444;
                color: #B91C1C;
            }

            .msg-success {
                background-color: #DCFCE7;
                border-color: #22C55E;
                color: #15803D;
            }

            /* Search Bar */
            .search-container {
                background: var(--card-light);
                padding: 1rem;
                border-radius: 0.75rem;
                margin-bottom: 1.5rem;
                border: 1px solid #F3F4F6;
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            }

            .search-form {
                display: flex;
                gap: 0.75rem;
            }

            .search-input-wrapper {
                position: relative;
                flex-grow: 1;
            }

            .search-icon {
                position: absolute;
                left: 0.75rem;
                top: 50%;
                transform: translateY(-50%);
                color: #9CA3AF;
                font-size: 1.25rem;
            }

            .input-text {
                width: 100%;
                padding: 0.625rem 0.625rem 0.625rem 2.5rem;
                border: 1px solid #D1D5DB;
                border-radius: 0.5rem;
                outline: none;
            }

            .input-text:focus {
                border-color: var(--primary-color);
                box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.2);
            }

            .btn-search {
                padding: 0.625rem 1.5rem;
                background-color: #DBEAFE;
                color: #1D4ED8;
                border: none;
                border-radius: 0.5rem;
                font-weight: 500;
                cursor: pointer;
                transition: background-color 0.2s;
            }

            .btn-search:hover {
                background-color: #BFDBFE;
            }

            /* Table Style */
            .table-card {
                background: var(--card-light);
                border-radius: 0.75rem;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                overflow: hidden;
                border: 1px solid #F3F4F6;
            }

            .overflow-x {
                overflow-x: auto;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                text-align: left;
            }

            thead tr {
                background-color: #F9FAFB;
                border-bottom: 1px solid #F3F4F6;
            }

            th {
                padding: 1rem 1.5rem;
                font-size: 0.75rem;
                text-transform: uppercase;
                letter-spacing: 0.05em;
                color: #4B5563;
                font-weight: 600;
            }

            td {
                padding: 1rem 1.5rem;
                font-size: 0.875rem;
                border-bottom: 1px solid #F3F4F6;
            }

            tr:hover {
                background-color: rgba(30, 64, 175, 0.02);
            }


            .user-info {
                display: flex;
                align-items: center;
                gap: 0.75rem;
            }

            .avatar {
                width: 2.5rem;
                height: 2.5rem;
                border-radius: 50%;
                background-color: #DBEAFE;
                color: var(--primary-color);
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: bold;
            }


            .badge {
                display: inline-flex;
                align-items: center;
                padding: 0.125rem 0.625rem;
                border-radius: 9999px;
                font-size: 0.75rem;
                font-weight: 500;
            }

            .badge-dot {
                width: 0.375rem;
                height: 0.375rem;
                border-radius: 50%;
                margin-right: 0.375rem;
            }

            .role-admin {
                background: #F3E8FF;
                color: #6B21A8;
            }

            .role-admin .badge-dot {
                background: #A855F7;
            }

            .role-lib {
                background: #DBEAFE;
                color: #1E40AF;
            }

            .role-lib .badge-dot {
                background: #3B82F6;
            }

            .status-active {
                background: #DCFCE7;
                color: #166534;
            }

            .status-active .badge-dot {
                background: #22C55E;
            }

            .status-blocked {
                background: #FEE2E2;
                color: #991B1B;
            }

            .status-blocked .badge-dot {
                background: #EF4444;
            }


            .action-group {
                display: flex;
                justify-content: flex-end;
                gap: 0.5rem;
            }

            .action-btn {
                padding: 0.5rem;
                border-radius: 0.5rem;
                text-decoration: none;
                display: flex;
                border: none;
                cursor: pointer;
                background: transparent;
            }

            .view-btn {
                color: #2563EB;
            }

            .view-btn:hover {
                background: #DBEAFE;
            }

            .edit-btn {
                color: #D97706;
            }

            .edit-btn:hover {
                background: #FEF3C7;
            }

            .block-btn {
                color: #DC2626;
            }

            .block-btn:hover {
                background: #FEE2E2;
            }

            .unblock-btn {
                color: #16A34A;
            }

            .unblock-btn:hover {
                background: #DCFCE7;
            }

            /* Pagination */
            .pagination-container {
                padding: 1rem 1.5rem;
                background: #F9FAFB;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-top: 1px solid #F3F4F6;
            }

            .pagination-nav {
                display: flex;
                align-items: center;
                gap: 0.25rem;
            }

            .page-link {
                padding: 0.375rem 0.875rem;
                border-radius: 0.5rem;
                text-decoration: none;
                font-size: 0.875rem;
                color: #6B7280;
                font-weight: 600;
            }

            .page-link:hover {
                background: #F3F4F6;
            }

            .page-active {
                background: var(--primary-color);
                color: white;
                box-shadow: 0 4px 6px rgba(30, 64, 175, 0.2);
            }

            /* Modal */
            .modal-overlay {
                position: fixed;
                inset: 0;
                background: rgba(0, 0, 0, 0.5);
                display: none;
                align-items: center;
                justify-content: center;
                z-index: 100;
            }

            .modal-content {
                background: white;
                padding: 1.5rem;
                border-radius: 0.75rem;
                width: 100%;
                max-width: 24rem;
            }

            .modal-footer {
                display: flex;
                justify-content: flex-end;
                gap: 0.75rem;
                margin-top: 1.5rem;
            }

            @media (max-width: 768px) {
                .main-wrapper {
                    margin-left: 0;
                }

                .header-section {
                    flex-direction: column;
                    align-items: flex-start;
                }

                .search-form {
                    flex-direction: column;
                }

                .pagination-container {
                    flex-direction: column;
                }
            }
        </style>
    </head>

    <body>

        <div class="app-container">
            <jsp:include page="sidebar.jsp" />

            <main class="main-wrapper">
                <div class="content-area">
                    <div class="max-w-7xl">

                        <%-- Header --%>
                        <div class="header-section">
                            <div>
                                <h1
                                    style="font-size: 1.875rem; font-weight: 700; margin: 0; display: flex; align-items: center; gap: 0.5rem;">
                                    <span class="material-icons"
                                          style="color: var(--primary-color); font-size: 2.25rem;">group</span>
                                    Quản lý người dùng
                                </h1>
                                <p style="color: var(--text-muted); margin-top: 0.25rem;">Quản lý thành viên
                                    thư
                                    viện, vai trò và trạng thái tài khoản.</p>
                            </div>

                            <a href="${pageContext.request.contextPath}/admin/users/create" class="btn-add">
                                <span class="material-icons" style="font-size: 1.125rem;">person_add</span>
                                Thêm người dùng mới
                            </a>
                        </div>

                        <%-- Notifications --%>
                        <div id="notification-container">
                            <c:if test="${not empty flash}">
                                <c:set var="isErr"
                                       value="${flash.contains('Error') || flash.contains('không thể') || flash.contains('Lỗi')}" />

                                <div id="toast-msg" class="${isErr ? 'msg-error' : 'msg-success'}">
                                    <span class="material-icons">
                                        ${isErr ? 'report_problem' : 'check_circle'}
                                    </span>
                                    <span style="font-weight: 500;">${flash}</span>
                                </div>
                                <c:remove var="flash" scope="session" />
                            </c:if>
                        </div>


                        <%-- Search Bar --%>
                        <div class="search-container">
                            <form method="get"
                                  action="${pageContext.request.contextPath}/admin/users"
                                  class="search-form">
                                <div class="search-input-wrapper">
                                    <span class="material-icons search-icon">search</span>
                                    <input type="text" name="keyword" value="${keyword}"
                                           class="input-text"
                                           placeholder="Tìm kiếm theo tên hoặc email...">
                                </div>
                                <button type="submit" class="btn-search">Tìm kiếm</button>
                            </form>
                        </div>

                        <%-- Main Table --%>
                        <div class="table-card">
                            <c:choose>
                                <c:when test="${not empty userList}">
                                    <div class="overflow-x">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>ID</th>
                                                    <th>Thông tin người dùng</th>
                                                    <th>Số điện thoại</th>
                                                    <th>Địa chỉ</th>
                                                    <th>Ngày tạo</th>
                                                    <th>Vai trò</th>
                                                    <th style="text-align: center;">Trạng thái
                                                    </th>
                                                    <th style="text-align: right;">Thao tác</th>

                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="user" items="${userList}">
                                                    <tr>
                                                        <!--ID -->
                                                        <td style="font-weight:600; color:#374151;">
                                                            ${user.id}
                                                        </td>

                                                        <!-- CỘT THÔNG TIN NGƯỜI DÙNG -->
                                                        <td>
                                                            <div class="user-info">
                                                                <div class="avatar"
                                                                     style="width:40px;height:40px;overflow:hidden;border-radius:50%;display:flex;
                                                                     align-items:center;justify-content:center;background:#E5E7EB;">
                                                                    <c:choose>
                                                                        <c:when test="${not empty user.avatar}">
                                                                            <img src="${pageContext.request.contextPath}/uploads/${user.avatar}"
                                                                                 style="width:100%;height:100%;object-fit:cover;">
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <span style="font-weight:600;color:#4B5563;">
                                                                                ${user.fullName.substring(0,1).toUpperCase()}
                                                                            </span>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>

                                                                <div>
                                                                    <div style="font-weight:600;color:#111827;">${user.fullName}</div>
                                                                    <div style="font-size:0.75rem;color:#6B7280;">${user.email}</div>
                                                                </div>
                                                            </div>
                                                        </td>

                                                        <!-- SỐ ĐIỆN THOẠI -->
                                                        <td>${not empty user.phone ? user.phone : '---'}</td>

                                                        <!-- ĐỊA CHỈ -->
                                                        <td style="max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                            ${not empty user.address ? user.address : '---'}
                                                        </td>

                                                        <!-- NGÀY TẠO -->
                                                        <td>
                                                            <fmt:parseDate value="${user.createdAt}"
                                                                           pattern="yyyy-MM-dd'T'HH:mm:ss"
                                                                           var="parsedDate" type="both" />
                                                            <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when
                                                                    test="${user.role.name == 'Admin' || user.role.name == 'ADMIN'}">
                                                                    <span
                                                                        class="badge role-admin"><span
                                                                            class="badge-dot"></span>Admin</span>
                                                                    </c:when>
                                                                    <c:when
                                                                        test="${user.role.name == 'Librarian' || user.role.name == 'LIBRARIAN'}">
                                                                    <span
                                                                        class="badge role-lib"><span
                                                                            class="badge-dot"></span>Librarian</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                    <span class="badge"
                                                                          style="background:#F3F4F6; color:#374151;"><span
                                                                            class="badge-dot"
                                                                            style="background:#9CA3AF;"></span>${user.role.name}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                        </td>
                                                        <td style="text-align: center;">
                                                            <c:choose>
                                                                <c:when
                                                                    test="${user.status == 'ACTIVE'}">
                                                                    <span
                                                                        class="badge status-active"><span
                                                                            class="badge-dot"></span>HOẠT
                                                                        ĐỘNG</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                    <span
                                                                        class="badge status-blocked"><span
                                                                            class="badge-dot"></span>BỊ
                                                                        KHÓA</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                        </td>
                                                        <td>
                                                            <div class="action-group">
                                                                <a href="${pageContext.request.contextPath}/admin/users/view?id=${user.id}&page=${currentPage}&keyword=${keyword}"
                                                                   class="action-btn view-btn">
                                                                    <span
                                                                        class="material-icons">visibility</span>
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}&page=${currentPage}&keyword=${keyword}"
                                                                   class="action-btn edit-btn">
                                                                    <span
                                                                        class="material-icons">edit</span>
                                                                </a>
                                                                <form
                                                                    action="${pageContext.request.contextPath}/admin/users/status"
                                                                    method="post"
                                                                    style="display:inline;">
                                                                    <input type="hidden"
                                                                           name="id"
                                                                           value="${user.id}">
                                                                    <input type="hidden"
                                                                           name="status"
                                                                           value="${user.status == 'ACTIVE' ? 'BLOCKED' : 'ACTIVE'}">
                                                                    <input type="hidden"
                                                                           name="page"
                                                                           value="${currentPage}">
                                                                    <input type="hidden"
                                                                           name="keyword"
                                                                           value="${keyword}">
                                                                    <button type="button"
                                                                            onclick="openConfirmModal(this.closest('form'))"
                                                                            class="action-btn ${user.status == 'ACTIVE' ? 'block-btn' : 'unblock-btn'}">
                                                                        <span
                                                                            class="material-icons">${user.status
                                                                                                 == 'ACTIVE' ?
                                                                                                 'block' :
                                                                                                 'lock_open'}</span>
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
                                    <div class="pagination-container">
                                        <div style="font-size: 0.875rem; color: #6B7280;">
                                            Hiển thị <b>${(currentPage - 1) * pageSize +
                                                          1}</b> đến <b>
                                                <c:set var="endRow"
                                                       value="${currentPage * pageSize}" />
                                                ${endRow > totalUsers ? totalUsers : endRow}
                                            </b> trong số <b>${totalUsers}</b> người dùng
                                        </div>

                                        <nav class="pagination-nav">
                                            <c:if test="${currentPage > 1}">
                                                <a href="?page=${currentPage - 1}&keyword=${keyword}"
                                                   class="page-link"><span
                                                        class="material-icons">chevron_left</span></a>
                                                </c:if>

                                            <c:set var="beginPage"
                                                   value="${currentPage - 1 > 0 ? currentPage - 1 : 1}" />
                                            <c:set var="endPage"
                                                   value="${beginPage + 2 > totalPages ? totalPages : beginPage + 2}" />
                                            <c:if
                                                test="${endPage == totalPages and endPage - 2 > 0}">
                                                <c:set var="beginPage"
                                                       value="${endPage - 2}" />
                                            </c:if>

                                            <c:forEach begin="${beginPage}" end="${endPage}"
                                                       var="i">
                                                <a href="?page=${i}&keyword=${keyword}"
                                                   class="page-link ${i == currentPage ? 'page-active' : ''}">${i}</a>
                                            </c:forEach>

                                            <c:if test="${currentPage < totalPages}">
                                                <a href="?page=${currentPage + 1}&keyword=${keyword}"
                                                   class="page-link"><span
                                                        class="material-icons">chevron_right</span></a>
                                                </c:if>
                                        </nav>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div
                                        style="padding: 3rem; text-align: center; color: #9CA3AF;">
                                        <span class="material-icons"
                                              style="font-size: 4rem; color: #E5E7EB; margin-bottom: 1rem;">search_off</span>
                                        <p style="font-size: 1.125rem; color: #6B7280;">Không
                                            tìm thấy người dùng phù hợp.</p>
                                        <a href="${pageContext.request.contextPath}/admin/users"
                                           style="color: var(--primary-color); text-decoration: underline; font-weight: 500;">Quay
                                            lại danh sách</a>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </div>
                </div>
            </main>
        </div>

        <%-- Confirm Modal --%>
        <div id="confirmModal" class="modal-overlay">
            <div class="modal-content">
                <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.75rem;">
                    <span class="material-icons" style="color: #DC2626; font-size: 2rem;">warning</span>
                    <h3 style="margin: 0; font-size: 1.125rem; font-weight: 600;">Xác nhận thay đổi</h3>
                </div>
                <p style="font-size: 0.875rem; color: #6B7280; margin-bottom: 1.5rem;">Bạn có chắc chắn muốn
                    thay đổi trạng thái của người dùng này không?</p>
                <div class="modal-footer">
                    <button onclick="closeConfirmModal()"
                            style="padding: 0.5rem 1rem; border-radius: 0.5rem; border: none; background: #F3F4F6; cursor: pointer;">Hủy</button>
                    <button id="confirmSubmitBtn"
                            style="padding: 0.5rem 1rem; border-radius: 0.5rem; border: none; background: #DC2626; color: white; font-weight: 600; cursor: pointer;">Xác
                        nhận</button>
                </div>
            </div>
        </div>

        <script>
            let pendingForm = null;

            function openConfirmModal(form) {
                pendingForm = form;
                const modal = document.getElementById("confirmModal");
                modal.style.display = "flex";
            }

            function closeConfirmModal() {
                const modal = document.getElementById("confirmModal");
                modal.style.display = "none";
            }

            document.getElementById("confirmSubmitBtn").addEventListener("click", function () {
                if (pendingForm)
                    pendingForm.submit();
            });

            document.addEventListener('DOMContentLoaded', function () {
                const toast = document.getElementById('toast-msg');
                if (toast) {
                    setTimeout(function () {
                        toast.style.opacity = '0';
                        setTimeout(() => toast.style.display = 'none', 500);
                    }, 3000);
                }
            });
        </script>
    </body>

</html>