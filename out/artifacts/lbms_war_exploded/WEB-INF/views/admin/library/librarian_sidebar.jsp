<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<%-- Lấy thông tin user giống header_lib.jsp --%>
<c:set var="user" value="${sessionScope.currentUser}" />
<c:set var="userName" value="${not empty user.fullName ? user.fullName : 'Staff'}" />
<c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

<style>
    :root {
        --admin-primary: #1e293b; /* */
        --admin-accent: #0b57d0;  /* */
        --sidebar-width: 280px;
    }

    .lib-sidebar {
        width: var(--sidebar-width);
        background: var(--admin-primary);
        color: white;
        padding: 24px 0;
        position: fixed;
        height: 100vh;
        overflow-y: auto;
        z-index: 1000;
        display: flex;
        flex-direction: column;
        box-shadow: 2px 0 10px rgba(0, 0, 0, 0.2);
    }

    .sidebar-header {
        padding: 0 24px 32px;
        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        display: flex;
        align-items: center;
        gap: 12px;
        margin-bottom: 24px;
    }

    .admin-logo-text {
        font-weight: 800;
        font-size: 20px;
        text-decoration: none;
        color: white;
    }

    .admin-logo-text span {
        background: var(--admin-accent); /* */
        padding: 2px 8px;
        border-radius: 4px;
        font-size: 11px;
        margin-left: 5px;
    }

    .sidebar-section-title {
        padding: 12px 24px;
        font-size: 11px;
        text-transform: uppercase;
        letter-spacing: 1px;
        color: rgba(255, 255, 255, 0.4);
        font-weight: 600;
    }

    .sidebar-nav {
        padding: 8px 16px;
    }

    .sidebar-nav a {
        display: flex;
        align-items: center;
        gap: 12px;
        padding: 12px 16px;
        color: #cbd5e1;
        text-decoration: none;
        border-radius: 8px;
        transition: 0.3s;
        margin-bottom: 4px;
        font-size: 14px;
    }

    .sidebar-nav a:hover, .sidebar-nav a.active {
        background: rgba(255, 255, 255, 0.1);
        color: white;
    }

    .sidebar-nav a.active {
        background: rgba(11, 87, 208, 0.2);
        border-left: 4px solid var(--admin-accent);
    }

    .badge-count {
        background: #ef4444; /* */
        font-size: 10px;
        padding: 2px 6px;
        border-radius: 10px;
        margin-left: auto;
    }

    /* Button Thêm sách mới giống header_lib */
    .btn-add-sidebar {
        background: var(--admin-accent);
        color: white !important;
        margin: 10px 16px 20px;
        padding: 12px;
        border-radius: 8px;
        text-align: center;
        font-weight: 600;
        display: block;
        text-decoration: none;
        transition: 0.2s;
    }

    .btn-add-sidebar:hover {
        filter: brightness(1.1);
    }

    .sidebar-footer {
        margin-top: auto;
        padding: 20px 24px;
        border-top: 1px solid rgba(255, 255, 255, 0.1);
    }

    .profile-info {
        display: flex;
        align-items: center;
        gap: 10px;
        margin-bottom: 15px;
    }

    .avatar-small {
        width: 32px;
        height: 32px;
        background: var(--admin-accent);
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
    }
</style>

<div class="lib-sidebar">
    <c:set var="activeUri" value="${requestScope['jakarta.servlet.forward.request_uri']}" />
    <c:set var="currentFilter" value="${param.filter}" />

    <div class="sidebar-header">
        <a href="${pageContext.request.contextPath}/admin/borrowlibrary" class="admin-logo-text">
            LBMS <span>STAFF</span> </a>
    </div>

    <div class="sidebar-section">
        <div class="sidebar-section-title">NGHIỆP VỤ</div>
        <div class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/admin/borrowlibrary" 
               class="${activeUri.endsWith('/borrowlibrary') && empty currentFilter ? 'active' : ''}">
                <i class="fas fa-boxes"></i> <span>📦 Quản lý mượn trả</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/borrowlibrary?filter=ONLINE"
               class="${currentFilter == 'ONLINE' ? 'active' : ''}">
                <i class="fas fa-globe"></i> <span>🌐 Yêu cầu trực tuyến</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/borrowlibrary/inperson"
               class="${activeUri.contains('/inperson') ? 'active' : ''}">
                <i class="fas fa-plus"></i> <span>➕ Mượn tại quầy</span>
            </a>

            <a href="${pageContext.request.contextPath}/admin/borrowlibrary?filter=OVERDUE"
               class="${currentFilter == 'OVERDUE' ? 'active' : ''}">
                <i class="fas fa-exclamation-triangle"></i> 
                <span>⏰ Quá hạn</span>
                <span class="badge-count">!</span> </a>
        </div>
    </div>

    <div class="sidebar-section">
        <div class="sidebar-section-title">KHO SÁCH</div>
        <div class="sidebar-nav">
            <a href="${pageContext.request.contextPath}/books/new" class="btn-add-sidebar">
                + Thêm sách mới
            </a>

            <a href="${pageContext.request.contextPath}/books" 
               class="${activeUri.endsWith('/books') ? 'active' : ''}">
                <i class="fas fa-book"></i> <span>📚 Kho sách</span> </a>
            
            <a href="${pageContext.request.contextPath}/admin/feedback?action=list"
               class="${activeUri.contains('/feedback') ? 'active' : ''}">
                <i class="fas fa-comment"></i> <span>💬 Phản hồi về sách</span> </a>
        </div>
    </div>

    <div class="sidebar-footer">
        <div class="profile-info">
            <div class="avatar-small">${userInitial}</div> <div style="font-size: 13px; font-weight: 600;">${userName}</div>
        </div>
        <div class="sidebar-nav" style="padding: 0;">
            <a href="${pageContext.request.contextPath}/profile"><i class="fas fa-user"></i> Hồ sơ</a> <a href="${pageContext.request.contextPath}/"><i class="fas fa-home"></i> Trang chủ</a> <a href="${pageContext.request.contextPath}/logout" style="color: #ef4444;">
                <i class="fas fa-sign-out-alt"></i> Đăng xuất </a>
        </div>
    </div>
</div>