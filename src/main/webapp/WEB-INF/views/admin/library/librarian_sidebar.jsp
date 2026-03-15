<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="activeUri" value="${requestScope['jakarta.servlet.forward.request_uri']}" />
<c:if test="${empty activeUri}">
    <c:set var="activeUri" value="${pageContext.request.requestURI}" />
</c:if>
<c:set var="isAdminRoute" value="${fn:contains(activeUri, '/admin/') || activeUri.endsWith('/admin')}" />

<c:choose>
    <c:when test="${isAdminRoute}">
        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />
    </c:when>
    <c:otherwise>
        <c:set var="user" value="${sessionScope.currentUser}" />
        <c:set var="userName" value="${not empty user.fullName ? user.fullName : 'Staff'}" />
        <c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />
        <c:set var="routePrefix" value="${not empty requestScope.staffRoutePrefix ? requestScope.staffRoutePrefix : '/staff'}" />
        <c:set var="borrowBase" value="${routePrefix}/borrowlibrary" />
        <c:set var="finesBase" value="${routePrefix}/fines" />
        <c:set var="booksBase" value="${routePrefix}/books" />
        <c:set var="defaultFeedbackBase" value="${routePrefix}/feedback" />
        <c:set var="feedbackBase"
            value="${not empty requestScope.feedbackBasePath ? requestScope.feedbackBasePath : defaultFeedbackBase}" />
        <c:set var="currentFilter" value="${param.filter}" />

        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

        <style>
            :root {
                --staff-primary: #1e293b;
                --staff-accent: #0b57d0;
                --sidebar-width: 280px;
            }

            .lib-sidebar {
                width: var(--sidebar-width);
                background: var(--staff-primary);
                color: #ffffff;
                padding: 24px 0;
                position: fixed;
                left: 0;
                top: 0;
                height: 100vh;
                overflow-y: auto;
                z-index: 1000;
                display: flex;
                flex-direction: column;
                box-shadow: 2px 0 10px rgba(0, 0, 0, 0.2);
            }

            .sidebar-header {
                padding: 0 24px 24px;
                border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                margin-bottom: 20px;
            }

            .sidebar-logo {
                text-decoration: none;
                color: #ffffff;
                font-weight: 800;
                font-size: 20px;
            }

            .sidebar-logo span {
                background: var(--staff-accent);
                padding: 2px 8px;
                border-radius: 4px;
                font-size: 11px;
                margin-left: 6px;
            }

            .sidebar-section-title {
                padding: 12px 24px;
                font-size: 11px;
                text-transform: uppercase;
                letter-spacing: 1px;
                color: rgba(255, 255, 255, 0.45);
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
                transition: 0.25s;
                margin-bottom: 4px;
                font-size: 14px;
            }

            .sidebar-nav a:hover,
            .sidebar-nav a.active {
                background: rgba(255, 255, 255, 0.1);
                color: #ffffff;
            }

            .sidebar-nav a.active {
                background: rgba(11, 87, 208, 0.2);
                border-left: 4px solid var(--staff-accent);
            }

            .badge-count {
                background: #ef4444;
                color: #ffffff;
                font-size: 10px;
                padding: 2px 6px;
                border-radius: 10px;
                margin-left: auto;
            }

            .btn-add-sidebar {
                background: var(--staff-accent);
                color: #ffffff;
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
                filter: brightness(1.08);
            }

            .sidebar-footer {
                margin-top: auto;
                padding: 20px 24px;
                border-top: 1px solid rgba(255, 255, 255, 0.1);
            }

            .profile-card {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 12px;
            }

            .avatar-small {
                width: 32px;
                height: 32px;
                background: var(--staff-accent);
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                font-weight: 700;
                color: #ffffff;
            }

            .user-name {
                color: #ffffff;
                font-size: 14px;
                font-weight: 600;
            }

            .footer-actions {
                display: flex;
                gap: 8px;
            }

            .btn-action {
                flex: 1;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                padding: 8px;
                border-radius: 8px;
                text-decoration: none;
                font-size: 12px;
                font-weight: 500;
                transition: 0.2s;
            }

            .btn-profile {
                background: rgba(255, 255, 255, 0.08);
                color: #ffffff;
            }

            .btn-profile:hover {
                background: rgba(255, 255, 255, 0.15);
            }

            .btn-logout {
                background: rgba(239, 68, 68, 0.15);
                color: #fca5a5;
            }

            .btn-logout:hover {
                background: #ef4444;
                color: #ffffff;
            }
        </style>

        <div class="lib-sidebar">
            <div class="sidebar-header">
                <a href="${pageContext.request.contextPath}${borrowBase}" class="sidebar-logo">
                    LBMS <span>STAFF</span>
                </a>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-section-title">Nghiep vu</div>
                <div class="sidebar-nav">
                    <a href="${pageContext.request.contextPath}${borrowBase}"
                        class="${activeUri.endsWith('/borrowlibrary') && empty currentFilter ? 'active' : ''}">
                        <i class="fas fa-boxes"></i> <span>Quan ly muon tra</span>
                    </a>

                    <a href="${pageContext.request.contextPath}${borrowBase}?filter=ONLINE"
                        class="${currentFilter == 'ONLINE' ? 'active' : ''}">
                        <i class="fas fa-globe"></i> <span>Yeu cau truc tuyen</span>
                    </a>

                    <a href="${pageContext.request.contextPath}${borrowBase}/inperson"
                        class="${activeUri.contains('/inperson') ? 'active' : ''}">
                        <i class="fas fa-plus"></i> <span>Muon tai quay</span>
                    </a>

                    <a href="${pageContext.request.contextPath}${borrowBase}?filter=OVERDUE"
                        class="${currentFilter == 'OVERDUE' ? 'active' : ''}">
                        <i class="fas fa-exclamation-triangle"></i>
                        <span>Don qua han</span>
                        <span class="badge-count">!</span>
                    </a>

                    <a href="${pageContext.request.contextPath}${finesBase}"
                        class="${activeUri.contains('/fines') ? 'active' : ''}">
                        <i class="fas fa-coins"></i>
                        <span>Tien phat</span>
                    </a>
                </div>
            </div>

            <div class="sidebar-section">
                <div class="sidebar-section-title">Kho sach</div>
                <div class="sidebar-nav">
                    <a href="${pageContext.request.contextPath}${booksBase}/new" class="btn-add-sidebar">
                        + Them sach moi
                    </a>

                    <a href="${pageContext.request.contextPath}${booksBase}?action=viewImportList"
                        class="${param.action == 'viewImportList' ? 'active' : ''}">
                        <i class="fas fa-plus-circle"></i> <span>Nhap kho</span>
                    </a>

                    <a href="${pageContext.request.contextPath}${booksBase}"
                        class="${fn:contains(activeUri, booksBase) ? 'active' : ''}">
                        <i class="fas fa-book"></i> <span>Kho sach</span>
                    </a>

                    <a href="${pageContext.request.contextPath}${feedbackBase}"
                        class="${activeUri.contains('/feedback') ? 'active' : ''}">
                        <i class="fas fa-comment"></i> <span>Phan hoi ve sach</span>
                    </a>
                </div>
            </div>

            <div class="sidebar-footer">
                <div class="profile-card">
                    <div class="avatar-small">${userInitial.toUpperCase()}</div>
                    <div class="user-info">
                        <span class="user-name">${userName}</span>
                    </div>
                </div>
                <div class="footer-actions">
                    <a href="${pageContext.request.contextPath}/profile" class="btn-action btn-profile">
                        <i class="fa-solid fa-user-gear"></i> Ho so
                    </a>
                    <a href="${pageContext.request.contextPath}/logout" class="btn-action btn-logout">
                        <i class="fa-solid fa-power-off"></i> Thoat
                    </a>
                </div>
            </div>
        </div>
    </c:otherwise>
</c:choose>
