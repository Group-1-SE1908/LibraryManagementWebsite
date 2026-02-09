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
                        <div class="user-profile">
                            <div class="user-avatar">${userInitial}</div>
                            <span class="user-name">${userName}</span>
                        </div>
                    </div>
                </div>
            </header>