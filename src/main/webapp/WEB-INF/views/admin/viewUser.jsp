<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>LBMS – Chi tiết người dùng</title>
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                    rel="stylesheet" />
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
            </head>

            <body class="panel-body">

                <jsp:include page="sidebar.jsp" />

                <main class="panel-main">

                    <a href="${pageContext.request.contextPath}/admin/users?page=${not empty param.page ? param.page : 1}&keyword=${param.keyword}"
                        class="pm-back-link">
                        <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>

                    <div class="pm-profile-card">
                        <div class="pm-profile-banner">
                            <div class="pm-profile-banner-avatar">
                                <c:choose>
                                    <c:when test="${not empty user.avatar}">
                                        <img src="${pageContext.request.contextPath}/${user.avatar}" alt="" />
                                    </c:when>
                                    <c:otherwise>${user.fullName.substring(0,1).toUpperCase()}</c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="pm-profile-body">
                            <div
                                style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:10px;">
                                <div style="padding-top:.25rem;">
                                    <h2
                                        style="font-size:1.375rem;font-weight:700;margin:0 0 4px;color:var(--panel-text);">
                                        ${user.fullName}</h2>
                                    <p style="font-size:.8125rem;color:var(--panel-text-sub);margin:0;">User ID:
                                        #${user.id}</p>
                                </div>
                                <c:choose>
                                    <c:when test="${user.status == 'ACTIVE'}">
                                        <span class="pm-badge pm-badge-success"><i class="fas fa-circle"
                                                style="font-size:.5rem;"></i> HOẠT ĐỘNG</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="pm-badge pm-badge-danger"><i class="fas fa-circle"
                                                style="font-size:.5rem;"></i> BỊ KHÓA</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <hr style="border:0;border-top:1px solid var(--panel-border);margin:1.5rem 0;" />

                            <div class="pm-info-grid">
                                <div class="pm-info-item">
                                    <div class="pm-info-icon"><i class="fas fa-user"></i></div>
                                    <div>
                                        <p class="pm-info-label">Họ và tên</p>
                                        <p class="pm-info-value">${user.fullName}</p>
                                    </div>
                                </div>
                                <div class="pm-info-item">
                                    <div class="pm-info-icon"><i class="fas fa-id-badge"></i></div>
                                    <div>
                                        <p class="pm-info-label">Vai trò</p>
                                        <p class="pm-info-value">${user.role.name}</p>
                                    </div>
                                </div>
                                <div class="pm-info-item">
                                    <div class="pm-info-icon"><i class="fas fa-envelope"></i></div>
                                    <div>
                                        <p class="pm-info-label">Địa chỉ Email</p>
                                        <p class="pm-info-value">${user.email}</p>
                                    </div>
                                </div>
                                <div class="pm-info-item">
                                    <div class="pm-info-icon"><i class="fas fa-phone"></i></div>
                                    <div>
                                        <p class="pm-info-label">Số điện thoại</p>
                                        <p class="pm-info-value">${not empty user.phone ? user.phone : 'Chưa cập nhật'}
                                        </p>
                                    </div>
                                </div>
                                <div class="pm-info-item">
                                    <div class="pm-info-icon"><i class="fas fa-calendar-days"></i></div>
                                    <div>
                                        <p class="pm-info-label">Ngày đăng ký</p>
                                        <p class="pm-info-value">
                                            <fmt:parseDate value="${user.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss"
                                                var="parsedDate" type="both" />
                                            <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy" />
                                        </p>
                                    </div>
                                </div>
                                <div class="pm-info-item">
                                    <div class="pm-info-icon"><i class="fas fa-location-dot"></i></div>
                                    <div>
                                        <p class="pm-info-label">Địa chỉ</p>
                                        <p class="pm-info-value">${not empty user.address ? user.address : 'Chưa cập
                                            nhật'}</p>
                                    </div>
                                </div>
                            </div>

                            <div style="display:flex;gap:10px;margin-top:1.5rem;flex-wrap:wrap;">
                                <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}&page=${param.page}&keyword=${param.keyword}"
                                    class="pm-btn pm-btn-warning" style="flex:1;justify-content:center;">
                                    <i class="fas fa-pen"></i> Chỉnh sửa tài khoản
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/users?page=${not empty param.page ? param.page : 1}&keyword=${param.keyword}"
                                    class="pm-btn pm-btn-outline" style="flex:1;justify-content:center;">
                                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                                </a>
                            </div>

                            <div
                                style="margin-top:2rem;padding-top:1rem;border-top:1px solid var(--panel-border);display:flex;justify-content:space-between;font-size:.8rem;color:var(--panel-text-sub);">
                                <span>© 2026 Library Management System (LBMS)</span>
                                <span>Version 1.0.0</span>
                            </div>
                        </div>
                    </div>

                </main>
            </body>

            </html>