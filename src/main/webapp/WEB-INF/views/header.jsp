<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="roleName" value="${sessionScope.currentUser.role.name}" />
<c:set var="isAdmin" value="${roleName == 'ADMIN'}" />
<c:set var="userName" value="${sessionScope.currentUser.fullName}" />
<c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />

<!-- Header -->
<header>
    <div class="container">
        <a href="${pageContext.request.contextPath}/" class="logo">
            📚 LBMS.Portal
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/" class="active">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/borrow">My Books</a></li>
            <li><a href="${pageContext.request.contextPath}/reservations">History</a></li>
            <li><a href="${pageContext.request.contextPath}/books">Catalog</a></li>
        </ul>
        <div class="header-right">
            <div class="notification-icon">
                🔔
                <span class="notification-badge">2</span>
            </div>
            <a href="${pageContext.request.contextPath}/cart" class="btn"
               style="text-decoration: none; color: white; background: rgba(255,255,255,0.2); padding: 8px 12px; font-size: 13px;">🛒
                Cart</a>
            <div class="user-profile" onclick="toggleUserDropdown(event)">
                <c:set var="now" value="<%= System.currentTimeMillis()%>" />

                <c:choose>
                    <c:when test="${not empty sessionScope.currentUser.avatar}">
                        <img class="user-avatar"
                             src="${pageContext.request.contextPath}/uploads/${sessionScope.currentUser.avatar}?v=${now}"
                             style="width:35px;height:35px;border-radius:50%;object-fit:cover;">
                    </c:when>
                    <c:otherwise>
                        <div class="user-avatar">
                            ${userInitial}
                        </div>
                    </c:otherwise>
                </c:choose>
                <span class="user-name">${userName}</span>
                <div class="user-dropdown" id="userDropdown">
                    <a href="${pageContext.request.contextPath}/profile">👤 Profile</a>
                    <a href="${pageContext.request.contextPath}/logout" class="logout">🚪 Logout</a>
                </div>
            </div>
        </div>
    </div>
</header>