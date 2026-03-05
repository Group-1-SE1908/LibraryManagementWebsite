<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                <c:set var="currentUser" value="${sessionScope.currentUser}" />
                <c:set var="userName"
                    value="${not empty currentUser && not empty currentUser.fullName ? currentUser.fullName : 'Guest'}" />
                <c:set var="userInitial" value="${fn:substring(userName, 0, 1)}" />

                <style>
                    /* ===== HEADER ===== */
                    .site-header {
                        background: #ffffff;
                        border-bottom: 1px solid #e5e7eb;
                        position: sticky;
                        top: 0;
                        z-index: 1100;
                        box-shadow: 0 1px 4px rgba(0, 0, 0, 0.06);
                    }

                    .site-header .header-inner {
                        max-width: 1280px;
                        margin: 0 auto;
                        padding: 0 24px;
                        height: 64px;
                        display: flex;
                        align-items: center;
                        gap: 32px;
                    }

                    /* Logo */
                    .header-logo {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        text-decoration: none;
                        flex-shrink: 0;
                    }

                    .header-logo .logo-icon {
                        width: 36px;
                        height: 36px;
                        border-radius: 10px;
                        display: block;
                        flex-shrink: 0;
                        object-fit: contain;
                    }

                    .header-logo .logo-text {
                        font-size: 17px;
                        font-weight: 700;
                        color: #111827;
                        letter-spacing: -0.3px;
                    }

                    .header-logo .logo-text span {
                        color: #2563eb;
                    }

                    /* Nav */
                    .header-nav {
                        flex: 1;
                        display: flex;
                        align-items: center;
                        gap: 4px;
                        list-style: none;
                        margin: 0;
                        padding: 0;
                    }

                    .header-nav li a {
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        padding: 6px 14px;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 500;
                        color: #4b5563;
                        text-decoration: none;
                        transition: background 0.15s, color 0.15s;
                        white-space: nowrap;
                    }

                    .header-nav li a:hover {
                        background: #f3f4f6;
                        color: #111827;
                    }

                    .header-nav li a.active {
                        background: #eff6ff;
                        color: #2563eb;
                    }

                    .header-nav li a svg {
                        width: 15px;
                        height: 15px;
                        opacity: 0.7;
                        flex-shrink: 0;
                    }

                    /* Right section */
                    .header-actions {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        flex-shrink: 0;
                        margin-left: auto;
                    }

                    /* Login button */
                    .btn-login {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 8px 18px;
                        background: #2563eb;
                        color: #ffffff;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 600;
                        text-decoration: none;
                        transition: background 0.15s;
                    }

                    .btn-login:hover {
                        background: #1d4ed8;
                        color: #ffffff;
                    }

                    /* User profile trigger */
                    .header-user {
                        position: relative;
                    }

                    .header-user-btn {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        padding: 5px 10px 5px 5px;
                        border-radius: 999px;
                        cursor: pointer;
                        border: 1.5px solid transparent;
                        transition: background 0.15s, border-color 0.15s;
                        user-select: none;
                        background: transparent;
                    }

                    .header-user-btn:hover {
                        background: #f3f4f6;
                        border-color: #e5e7eb;
                    }

                    .header-user-btn.open {
                        background: #eff6ff;
                        border-color: #bfdbfe;
                    }

                    .u-avatar {
                        width: 34px;
                        height: 34px;
                        border-radius: 50%;
                        background: linear-gradient(135deg, #2563eb, #60a5fa);
                        color: #fff;
                        font-weight: 700;
                        font-size: 14px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        flex-shrink: 0;
                        overflow: hidden;
                    }

                    .u-avatar img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                        border-radius: 50%;
                    }

                    .u-name {
                        font-size: 14px;
                        font-weight: 600;
                        color: #111827;
                        max-width: 140px;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                    }

                    .u-chevron {
                        display: flex;
                        align-items: center;
                        color: #9ca3af;
                        transition: transform 0.2s;
                        flex-shrink: 0;
                    }

                    .header-user-btn.open .u-chevron {
                        transform: rotate(180deg);
                    }

                    /* Dropdown */
                    .header-dropdown {
                        display: none;
                        position: absolute;
                        top: calc(100% + 8px);
                        right: 0;
                        background: #ffffff;
                        border: 1px solid #e5e7eb;
                        border-radius: 12px;
                        min-width: 200px;
                        box-shadow: 0 8px 24px rgba(0, 0, 0, 0.1);
                        overflow: hidden;
                        z-index: 2000;
                        animation: hDropSlide 0.15s ease-out;
                    }

                    .header-dropdown.open {
                        display: block;
                    }

                    @keyframes hDropSlide {
                        from {
                            opacity: 0;
                            transform: translateY(-6px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .hd-user-info {
                        padding: 14px 16px 12px;
                        border-bottom: 1px solid #f3f4f6;
                    }

                    .hd-user-info .hd-full-name {
                        font-size: 14px;
                        font-weight: 600;
                        color: #111827;
                        overflow: hidden;
                        text-overflow: ellipsis;
                        white-space: nowrap;
                    }

                    .hd-user-info .hd-role {
                        font-size: 12px;
                        color: #6b7280;
                        margin-top: 2px;
                    }

                    .hd-menu {
                        padding: 6px 0;
                    }

                    .hd-menu a {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 10px 16px;
                        font-size: 14px;
                        color: #374151;
                        text-decoration: none;
                        transition: background 0.12s;
                    }

                    .hd-menu a svg {
                        width: 16px;
                        height: 16px;
                        color: #9ca3af;
                        flex-shrink: 0;
                    }

                    .hd-menu a:hover {
                        background: #f9fafb;
                        color: #111827;
                    }

                    .hd-menu a:hover svg {
                        color: #2563eb;
                    }

                    .hd-menu .hd-divider {
                        height: 1px;
                        background: #f3f4f6;
                        margin: 4px 0;
                    }

                    .hd-menu a.hd-logout {
                        color: #dc2626;
                    }

                    .hd-menu a.hd-logout svg {
                        color: #dc2626;
                    }

                    .hd-menu a.hd-logout:hover {
                        background: #fef2f2;
                    }

                    /* Cart button */
                    .btn-cart {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 8px 14px;
                        background: transparent;
                        border: 1.5px solid #e5e7eb;
                        border-radius: 8px;
                        color: #4b5563;
                        font-size: 14px;
                        font-weight: 500;
                        text-decoration: none;
                        cursor: pointer;
                        transition: all 0.15s;
                    }

                    .btn-cart:hover {
                        background: #f3f4f6;
                        color: #2563eb;
                        border-color: #2563eb;
                    }

                    .btn-cart svg {
                        width: 18px;
                        height: 18px;
                        flex-shrink: 0;
                    }
                </style>

                <header class="site-header">
                    <div class="header-inner">

                        <%-- Logo --%>
                            <a href="${pageContext.request.contextPath}/" class="header-logo">
                                <img src="${pageContext.request.contextPath}/assets/images/logo/logo.png"
                                    alt="LBMS Logo" class="logo-icon" />
                                <span class="logo-text">LBMS</span>
                            </a>

                            <%-- Navigation --%>
                                <ul class="header-nav">
                                    <li>
                                        <a href="${pageContext.request.contextPath}/">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" />
                                                <polyline points="9 22 9 12 15 12 15 22" />
                                            </svg>
                                            <fmt:message key="nav.home" />
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${pageContext.request.contextPath}/history">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <circle cx="12" cy="12" r="10" />
                                                <polyline points="12 6 12 12 16 14" />
                                            </svg>
                                            <fmt:message key="nav.history" />
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${pageContext.request.contextPath}/fines">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6" />
                                            </svg>
                                            <fmt:message key="nav.fines" />
                                        </a>
                                    </li>
                                    <li>
                                        <a href="${pageContext.request.contextPath}/books">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z" />
                                                <path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z" />
                                            </svg>
                                            <fmt:message key="nav.catalog" />
                                        </a>
                                    </li>
                                </ul>

                                <%-- Actions --%>
                                    <div class="header-actions">
                                        <a href="${pageContext.request.contextPath}/cart" class="btn-cart">
                                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <circle cx="9" cy="21" r="1" />
                                                <circle cx="20" cy="21" r="1" />
                                                <path
                                                    d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6" />
                                            </svg>
                                            <fmt:message key="nav.cart" />
                                        </a>
                                        <c:choose>
                                            <c:when test="${not empty currentUser}">
                                                <%-- User dropdown --%>
                                                    <div class="header-user" id="headerUserWidget">
                                                        <div class="header-user-btn" id="headerUserBtn"
                                                            onclick="toggleHeaderDropdown()">
                                                            <%-- Avatar --%>
                                                                <div class="u-avatar">
                                                                    <c:choose>
                                                                        <c:when
                                                                            test="${not empty currentUser.avatar && currentUser.avatar != 'null'}">
                                                                            <img src="${pageContext.request.contextPath}/${currentUser.avatar}"
                                                                                alt="Avatar"
                                                                                onerror="this.style.display='none'; this.parentElement.innerHTML='${userInitial}';">
                                                                        </c:when>
                                                                        <c:otherwise>${userInitial}</c:otherwise>
                                                                    </c:choose>
                                                                </div>

                                                                <span class="u-name">${userName}</span>

                                                                <span class="u-chevron">
                                                                    <svg width="16" height="16" viewBox="0 0 24 24"
                                                                        fill="none" stroke="currentColor"
                                                                        stroke-width="2.5">
                                                                        <polyline points="6 9 12 15 18 9" />
                                                                    </svg>
                                                                </span>
                                                        </div>

                                                        <div class="header-dropdown" id="headerDropdown">
                                                            <div class="hd-user-info">
                                                                <div class="hd-full-name">${userName}</div>
                                                                <div class="hd-role">${currentUser.email}</div>
                                                            </div>
                                                            <div class="hd-menu">
                                                                <a href="${pageContext.request.contextPath}/profile">
                                                                    <svg viewBox="0 0 24 24" fill="none"
                                                                        stroke="currentColor" stroke-width="2">
                                                                        <path
                                                                            d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                                                                        <circle cx="12" cy="7" r="4" />
                                                                    </svg>
                                                                    <fmt:message key="nav.profile" />
                                                                </a>
                                                                <div class="hd-divider"></div>
                                                                <a href="${pageContext.request.contextPath}/logout"
                                                                    class="hd-logout">
                                                                    <svg viewBox="0 0 24 24" fill="none"
                                                                        stroke="currentColor" stroke-width="2">
                                                                        <path
                                                                            d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" />
                                                                        <polyline points="16 17 21 12 16 7" />
                                                                        <line x1="21" y1="12" x2="9" y2="12" />
                                                                    </svg>
                                                                    <fmt:message key="nav.logout" />
                                                                </a>
                                                            </div>
                                                        </div>
                                                    </div>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="${pageContext.request.contextPath}/login" class="btn-login">
                                                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none"
                                                        stroke="currentColor" stroke-width="2">
                                                        <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" />
                                                        <polyline points="10 17 15 12 10 7" />
                                                        <line x1="15" y1="12" x2="3" y2="12" />
                                                    </svg>
                                                    <fmt:message key="nav.login" />
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                    </div>
                </header>

                <script>
                    function toggleHeaderDropdown() {
                        const btn = document.getElementById('headerUserBtn');
                        const drop = document.getElementById('headerDropdown');
                        const isOpen = drop.classList.contains('open');
                        drop.classList.toggle('open', !isOpen);
                        btn.classList.toggle('open', !isOpen);
                    }

                    document.addEventListener('click', function (e) {
                        const widget = document.getElementById('headerUserWidget');
                        if (widget && !widget.contains(e.target)) {
                            document.getElementById('headerDropdown')?.classList.remove('open');
                            document.getElementById('headerUserBtn')?.classList.remove('open');
                        }
                    });
                </script>