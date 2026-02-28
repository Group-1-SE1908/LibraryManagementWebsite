<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="user" value="${sessionScope.currentUser}" />
<c:set var="userName" value="${not empty user.fullName ? user.fullName : 'Staff'}" />
<c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />

<style>
    :root {
        --admin-primary: #1e293b; /* Màu tối chuyên nghiệp cho Admin */
        --admin-accent: #0b57d0;
        --header-height: 70px;
    }

    .admin-header {
        background: var(--admin-primary);
        height: var(--header-height);
        color: white;
        display: flex;
        align-items: center;
        box-shadow: 0 2px 10px rgba(0,0,0,0.2);
        position: sticky;
        top: 0;
        z-index: 1100;
    }

    .admin-header .container {
        display: flex;
        align-items: center;
        justify-content: space-between;
        max-width: 1400px;
        margin: 0 auto;
        padding: 0 20px;
        width: 100%;
    }

    .admin-logo {
        font-weight: 800;
        font-size: 22px;
        color: white;
        text-decoration: none;
        display: flex;
        align-items: center;
        gap: 10px;
    }

    .admin-logo span {
        background: var(--admin-accent);
        padding: 4px 10px;
        border-radius: 6px;
        font-size: 12px;
        letter-spacing: 1px;
    }

    .admin-nav {
        display: flex;
        list-style: none;
        gap: 30px;
        margin: 0;
        padding: 0;
    }

    .admin-nav a {
        color: #cbd5e1;
        text-decoration: none;
        font-weight: 600;
        font-size: 14px;
        transition: 0.3s;
        display: flex;
        align-items: center;
        gap: 8px;
    }

    .admin-nav a:hover, .admin-nav a.active {
        color: white;
    }

    .admin-actions {
        display: flex;
        align-items: center;
        gap: 20px;
    }

    .btn-add-quick {
        background: var(--admin-accent);
        color: white;
        padding: 8px 16px;
        border-radius: 8px;
        text-decoration: none;
        font-size: 13px;
        font-weight: 600;
        transition: 0.2s;
    }

    .btn-add-quick:hover {
        filter: brightness(1.1);
    }

    /* User Profile tương tự bản cũ nhưng tối ưu cho Admin */
    .admin-profile {
        display: flex;
        align-items: center;
        gap: 12px;
        cursor: pointer;
        padding: 6px 12px;
        border-radius: 30px;
        background: rgba(255,255,255,0.1);
        position: relative;
    }

    .admin-avatar {
        width: 35px;
        height: 35px;
        background: var(--admin-accent);
        color: white;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
    }

    .admin-dropdown {
        display: none;
        position: absolute;
        top: 50px;
        right: 0;
        background: white;
        min-width: 200px;
        border-radius: 12px;
        box-shadow: 0 10px 25px rgba(0,0,0,0.2);
        z-index: 2000;
        border: 1px solid #e2e8f0;
    }

    .admin-dropdown.show {
        display: block;
    }

    .admin-dropdown a {
        display: block;
        padding: 12px 20px;
        color: #334155;
        text-decoration: none;
        font-size: 14px;
    }

    .admin-dropdown a:hover {
        background: #f1f5f9;
        color: var(--admin-accent);
    }

    .badge-count {
        background: #ef4444;
        font-size: 10px;
        padding: 2px 6px;
        border-radius: 10px;
    }
</style>

<header class="admin-header">
    <div class="container">
        <a href="${pageContext.request.contextPath}/borrowlibrary" class="admin-logo">
            LBMS <span>STAFF</span>
        </a>

        <ul class="admin-nav">
            <li>
                <a href="${pageContext.request.contextPath}/borrowlibrary">
                    📦 Quản lý mượn trả
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/borrowlibrary?filter=ONLINE">🌐 Yêu cầu trực tuyến</a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/borrowlibrary/inperson">➕ Mượn tại quầy</a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/borrowlibrary?filter=OVERDUE">
                    ⏰ Quá hạn <span class="badge-count">!</span>
                </a>
            </li>
            <li>
                <a href="${pageContext.request.contextPath}/books">
                    📚 Kho sách
                </a>
            </li>

        </ul>

        <div class="admin-actions">
            <a href="${pageContext.request.contextPath}/books/new" class="btn-add-quick">
                + Thêm sách mới
            </a>

            <div class="admin-profile" onclick="toggleAdminDropdown(event)">
                <div class="admin-avatar">${userInitial}</div>
                <div class="admin-dropdown" id="adminDropdown">
                    <a href="${pageContext.request.contextPath}/profile">Hồ sơ cá nhân</a>
                    <a href="${pageContext.request.contextPath}/">Trang chủ (Portal)</a>
                    <a href="${pageContext.request.contextPath}/logout" style="color: #ef4444; border-top: 1px solid #eee;">Đăng xuất</a>
                </div>
            </div>
        </div>
    </div>
</header>

<script>
    function toggleAdminDropdown(event) {
        event.stopPropagation();
        document.getElementById('adminDropdown').classList.toggle('show');
    }

    window.onclick = function (event) {
        if (!event.target.matches('.admin-profile') && !event.target.matches('.admin-avatar')) {
            var dropdown = document.getElementById('adminDropdown');
            if (dropdown && dropdown.classList.contains('show')) {
                dropdown.classList.remove('show');
            }
        }
    }
</script>