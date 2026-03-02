<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                <c:set var="currentUser" value="${sessionScope.currentUser}" />
                <c:set var="roleName"
                    value="${not empty currentUser && not empty currentUser.role ? currentUser.role.name : ''}" />
                <c:set var="isAdmin" value="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}" />
                <c:set var="userName"
                    value="${not empty currentUser && not empty currentUser.fullName ? currentUser.fullName : 'Guest'}" />
                <c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />

                <header class="site-header">
                    <div class="header-main">
                        <div class="container header-main__inner">
                            <div class="brand-block">
                                <a href="${pageContext.request.contextPath}/" class="logo">
                                    <span class="logo-icon">📚</span>
                                    <span class="logo-text">LBMS.Portal</span>
                                </a>
                                <p class="logo-subtitle">Connecting readers with stories faster.</p>
                            </div>

                            <nav class="primary-nav" aria-label="Primary navigation">
                                <ul class="nav-menu">
                                    <li>
                                        <a href="${pageContext.request.contextPath}/">
                                            <fmt:message key="nav.home" />
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${pageContext.request.contextPath}/borrow">
                                            <fmt:message key="nav.my_books" />
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${pageContext.request.contextPath}/history">
                                            <fmt:message key="nav.history" />
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${pageContext.request.contextPath}/books">
                                            <fmt:message key="nav.catalog" />
                                        </a>
                                    </li>
                                </ul>
                            </nav>

                            <div class="header-right">
                                <div class="notification-icon" aria-label="Notifications">
                                    🔔
                                    <span class="notification-badge">2</span>
                                </div>

                                <a href="${pageContext.request.contextPath}/cart" class="cart-btn">
                                    🛒
                                    <fmt:message key="nav.cart" />
                                </a>

                                <c:choose>
                                    <c:when test="${not empty currentUser}">
                                        <div class="user-profile" id="userProfileBtn"
                                            onclick="toggleUserDropdown(event)">
                                            <c:choose>
                                                <c:when
                                                    test="${not empty currentUser.avatar && currentUser.avatar != 'null'}">
                                                    <img class="user-avatar"
                                                        src="${pageContext.request.contextPath}/${currentUser.avatar}"
                                                        alt="Avatar"
                                                        onerror="this.style.display='none'; this.parentElement.querySelector('.user-avatar-initial').style.display='flex';" />
                                                    <div class="user-avatar user-avatar-initial" style="display:none;">
                                                        ${userInitial}
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="user-avatar user-avatar-initial">
                                                        ${userInitial}
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <span class="user-name">${userName}</span>

                                            <div class="user-dropdown" id="userDropdown">
                                                <a href="${pageContext.request.contextPath}/profile">👤
                                                    <fmt:message key="nav.profile" />
                                                </a>
                                                <c:if test="${isAdmin}">
                                                    <a href="${pageContext.request.contextPath}/borrow">🛠️
                                                        <fmt:message key="nav.management" />
                                                    </a>
                                                </c:if>
                                                <a href="${pageContext.request.contextPath}/logout" class="logout">🚪
                                                    <fmt:message key="nav.logout" />
                                                </a>
                                            </div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/login" class="auth-link">
                                            <fmt:message key="nav.login" />
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </header>

                <script>
                    function toggleUserDropdown(event) {
                        // prevent immediate close when clicking inside the profile area
                        event.stopPropagation();
                        const dropdown = document.getElementById('userDropdown');
                        dropdown.classList.toggle('show');
                    }

                    window.addEventListener('click', function (e) {
                        const dropdown = document.getElementById('userDropdown');
                        const profileBtn = document.getElementById('userProfileBtn');

                        if (dropdown && dropdown.classList.contains('show')) {
                            if (!profileBtn.contains(e.target)) {
                                dropdown.classList.remove('show');
                            }
                        }
                    });
                </script>