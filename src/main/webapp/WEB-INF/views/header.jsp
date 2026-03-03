<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                <c:set var="currentUser" value="${sessionScope.currentUser}" />
                <c:set var="userName"
                    value="${not empty currentUser && not empty currentUser.fullName ? currentUser.fullName : 'Guest'}" />
                <c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />

                <style>
                    :root {
                        --primary-color: #0b57d0;
                        --header-bg: #0b57d0;
                    }

                    header {
                        background: var(--header-bg);
                        padding: 12px 0;
                        color: white;
                        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
                        position: relative;
                        z-index: 1100;
                    }

                    header .container {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        max-width: 1200px;
                        margin: 0 auto;
                        padding: 0 15px;
                    }

                    .logo {
                        font-size: 20px;
                        font-weight: 800;
                        color: white;
                        text-decoration: none;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .nav-menu {
                        display: flex;
                        list-style: none;
                        gap: 24px;
                        margin: 0;
                        padding: 0;
                    }

                    .nav-menu a {
                        color: rgba(255, 255, 255, 0.85);
                        text-decoration: none;
                        font-weight: 500;
                        font-size: 14px;
                        transition: 0.2s;
                    }

                    .nav-menu a:hover,
                    .nav-menu a.active {
                        color: white;
                    }

                    .header-right {
                        display: flex;
                        align-items: center;
                        gap: 20px;
                    }

                    .notification-icon {
                        position: relative;
                        cursor: pointer;
                        font-size: 18px;
                    }

                    .notification-badge {
                        position: absolute;
                        top: -5px;
                        right: -8px;
                        background: #ea4335;
                        color: white;
                        font-size: 10px;
                        padding: 2px 5px;
                        border-radius: 10px;
                        font-weight: bold;
                    }

                    /* User Profile & Dropdown Area */
                    .user-profile {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 5px 12px;
                        background: rgba(255, 255, 255, 0.15);
                        border-radius: 30px;
                        cursor: pointer;
                        position: relative;
                        transition: 0.2s;
                        user-select: none;
                    }

                    .user-profile:hover {
                        background: rgba(255, 255, 255, 0.25);
                    }

                    .user-avatar {
                        width: 32px;
                        height: 32px;
                        background: linear-gradient(135deg, var(--primary-color), #60a5fa);
                        color: white;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-weight: bold;
                        font-size: 14px;
                        object-fit: cover;
                        flex-shrink: 0;
                    }

                    .user-avatar img {
                        width: 100%;
                        height: 100%;
                        border-radius: 50%;
                        object-fit: cover;
                    }

                    .user-name {
                        font-size: 14px;
                        font-weight: 600;
                    }

                    .user-dropdown {
                        display: none;
                        position: absolute;
                        top: calc(100% + 10px);
                        right: 0;
                        background: white;
                        min-width: 180px;
                        border-radius: 12px;
                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
                        overflow: hidden;
                        z-index: 2000;
                        border: 1px solid #eee;
                    }

                    .user-dropdown.show {
                        display: block;
                        animation: slideDown 0.2s ease-out;
                    }

                    @keyframes slideDown {
                        from {
                            opacity: 0;
                            transform: translateY(-10px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .user-dropdown a {
                        display: block;
                        padding: 12px 16px;
                        color: #444;
                        text-decoration: none;
                        font-size: 14px;
                        transition: 0.2s;
                    }

                    .user-dropdown a:hover {
                        background: #f1f5f9;
                        color: var(--primary-color);
                    }

                    .user-dropdown .logout {
                        border-top: 1px solid #eee;
                        color: #dc3545;
                    }

                    .cart-btn {
                        text-decoration: none;
                        color: white;
                        background: rgba(255, 255, 255, 0.2);
                        padding: 8px 15px;
                        border-radius: 8px;
                        font-size: 13px;
                        display: flex;
                        align-items: center;
                        gap: 5px;
                        transition: 0.2s;
                    }

                    .cart-btn:hover {
                        background: rgba(255, 255, 255, 0.3);
                    }
                </style>

                <header>
                    <div class="container">
                        <%-- Logo dẫn về trang chủ Portal [cite: 38] --%>
                            <a href="${pageContext.request.contextPath}/" class="logo">
                                📚 LBMS.Portal
                            </a>

                            <%-- Menu điều hướng dành cho Độc giả [cite: 39-42] --%>
                                <ul class="nav-menu">
                                    <li><a href="${pageContext.request.contextPath}/">
                                            <fmt:message key="nav.home" />
                                        </a></li>
                                    <li><a href="${pageContext.request.contextPath}/borrow">
                                            <fmt:message key="nav.my_books" />
                                        </a></li>
                                    <li><a href="${pageContext.request.contextPath}/history">
                                            <fmt:message key="nav.history" />
                                        </a></li>
                                    <li><a href="${pageContext.request.contextPath}/fines">
                                            <fmt:message key="nav.fines" />
                                        </a></li>
                                    <li><a href="${pageContext.request.contextPath}/books">
                                            <fmt:message key="nav.catalog" />
                                        </a></li>
                                </ul>

                                <div class="header-right">
                                    <%-- Thông báo và Giỏ sách [cite: 43-45] --%>
                                        <div class="notification-icon">
                                            🔔 <span class="notification-badge">2</span>
                                        </div>

                                        <a href="${pageContext.request.contextPath}/cart" class="cart-btn">
                                            🛒
                                            <fmt:message key="nav.cart" />
                                        </a>

                                        <c:choose>
                                            <%-- Khi đã đăng nhập [cite: 46] --%>
                                                <c:when test="${not empty currentUser}">
                                                    <div class="user-profile" id="userProfileBtn"
                                                        onclick="toggleUserDropdown(event)">
                                                        <c:choose>
                                                            <%-- Xử lý hiển thị Avatar hoặc chữ cái đầu tên [cite:
                                                                47-53] --%>
                                                                <c:when
                                                                    test="${not empty currentUser.avatar && currentUser.avatar != 'null'}">
                                                                    <img class="user-avatar"
                                                                        src="${pageContext.request.contextPath}/${currentUser.avatar}"
                                                                        alt="Avatar"
                                                                        onerror="this.style.display='none'; this.parentElement.querySelector('.user-avatar-initial').style.display='flex';">
                                                                    <div class="user-avatar user-avatar-initial"
                                                                        style="display:none;">${userInitial}</div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <div class="user-avatar user-avatar-initial">
                                                                        ${userInitial}</div>
                                                                </c:otherwise>
                                                        </c:choose>

                                                        <span class="user-name">${userName}</span>

                                                        <%-- Dropdown Menu: Đã loại bỏ link Quản lý của thủ thư [cite:
                                                            54-59] --%>
                                                            <div class="user-dropdown" id="userDropdown">
                                                                <a href="${pageContext.request.contextPath}/profile">👤
                                                                    <fmt:message key="nav.profile" />
                                                                </a>
                                                                <a href="${pageContext.request.contextPath}/logout"
                                                                    class="logout">🚪
                                                                    <fmt:message key="nav.logout" />
                                                                </a>
                                                            </div>
                                                    </div>
                                                </c:when>

                                                <%-- Khi chưa đăng nhập [cite: 60-63] --%>
                                                    <c:otherwise>
                                                        <a href="${pageContext.request.contextPath}/login"
                                                            style="color: white; text-decoration: none; font-weight: 600;">
                                                            <fmt:message key="nav.login" />
                                                        </a>
                                                    </c:otherwise>
                                        </c:choose>
                                </div>
                    </div>
                </header>

                <script>
    
                        function toggleUserDropdown(event) {
                            event.stopPropagation();
                            const dropdown = document.getElementById('userDropdown');
                            dropdown.classList.toggle('show');
                        }

                        
                            window.addEventListener('click', function (e) {
                                const dropdown = document.getElementById('userDropdown');
                                const profileBtn = document.getElementById('userProfileBtn');
                                if (dropdown && dropdown.classList.contains('show')) {
                                    if (!profileBtn || !profileBtn.contains(e.target)) {
                                        dropdown.classList.remove('show');
                                    }
                                }
                            });
                </script>