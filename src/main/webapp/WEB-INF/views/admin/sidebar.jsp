<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

            <c:set var="activeUri" value="${requestScope['jakarta.servlet.forward.request_uri']}" />
            <c:if test="${empty activeUri}">
                <c:set var="activeUri" value="${pageContext.request.requestURI}" />
            </c:if>

            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />

            <aside class="panel-sidebar">
                <a href="${pageContext.request.contextPath}/admin" class="ps-brand">
                    <div class="ps-brand-icon"><i class="fas fa-book-open"></i></div>
                    <div>
                        <span class="ps-brand-text">LBMS</span>
                        <span class="ps-brand-badge">Admin</span>
                    </div>
                </a>

                <nav class="ps-nav">
                    <div class="ps-section-title">Quản lý</div>
                    <div class="ps-menu">
                        <a href="${pageContext.request.contextPath}/admin"
                            class="${activeUri.endsWith('/admin') || activeUri.endsWith('/admin/') ? 'active' : ''}">
                            <i class="fas fa-chart-line"></i> <span>Dashboard</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/users"
                            class="${fn:contains(activeUri, '/admin/users') ? 'active' : ''}">
                            <i class="fas fa-users"></i> <span>Quản lý người dùng</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/books"
                            class="${fn:contains(activeUri, '/admin/books') ? 'active' : ''}">
                            <i class="fas fa-book"></i> <span>Kho sách</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/categories"
                            class="${fn:contains(activeUri, '/admin/categories') ? 'active' : ''}">
                            <i class="fas fa-tags"></i> <span>Danh mục sách</span>
                        </a>
                    </div>

                    <div class="ps-section-title">Nghiệp vụ thư viện</div>
                    <div class="ps-menu">
                        <a href="${pageContext.request.contextPath}/admin/borrowlibrary"
                            class="${fn:contains(activeUri, '/admin/borrowlibrary') && !fn:contains(activeUri, '/inperson') ? 'active' : ''}">
                            <i class="fas fa-exchange-alt"></i> <span>Mượn trả sách</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/borrowlibrary/inperson"
                            class="${fn:contains(activeUri, '/admin/borrowlibrary/inperson') ? 'active' : ''}">
                            <i class="fas fa-hand-holding"></i> <span>Mượn tại quầy</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/reservation"
                            class="${fn:contains(activeUri, '/admin/reservation') ? 'active' : ''}">
                            <i class="fas fa-hourglass-end"></i> <span>Quản lý đặt trước</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/fines"
                            class="${fn:contains(activeUri, '/admin/fines') ? 'active' : ''}">
                            <i class="fas fa-coins"></i> <span>Tiền phạt</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/feedback"
                            class="${fn:contains(activeUri, '/admin/feedback') ? 'active' : ''}">
                            <i class="fas fa-comment-dots"></i> <span>Phản hồi sách</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/reports"
                            class="${fn:contains(activeUri, '/admin/reports') ? 'active' : ''}">
                            <i class="fas fa-flag"></i> <span>Báo cáo bình luận</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/contacts"
                            class="${fn:contains(activeUri, '/admin/contacts') ? 'active' : ''}">
                            <i class="fas fa-envelope-open-text"></i> <span>Phản hồi liên hệ</span>
                        </a>
                    </div>

                    <div class="ps-section-title">Phân tích</div>
                    <div class="ps-menu">
                        <a href="${pageContext.request.contextPath}/admin/librarianActivityLog"
                            class="${fn:contains(activeUri, '/admin/librarianActivityLog') ? 'active' : ''}">
                            <i class="fas fa-clipboard-list"></i> <span>Nhật ký thủ thư</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/statistics"
                            class="${fn:contains(activeUri, '/admin/statistics') ? 'active' : ''}">
                            <i class="fas fa-chart-pie"></i> <span>Thống kê mượn trả</span>
                        </a>
                    </div>
                </nav>



                <div class="ps-footer">
                    <div class="ps-profile">
                        <%-- Xử lý logic lấy ảnh đại diện đồng bộ với Header --%>
                            <c:choose>
                                <c:when test="${not empty currentUser.avatar && currentUser.avatar != 'null'}">
                                    <c:set var="isAbsolute" value="${fn:startsWith(currentUser.avatar, 'http')}" />
                                    <c:set var="finalAvatar"
                                        value="${isAbsolute ? currentUser.avatar : pageContext.request.contextPath.concat('/').concat(currentUser.avatar)}" />

                                    <img src="${finalAvatar}" class="ps-avatar"
                                        style="width: 40px; height: 40px; border-radius: 8px; object-fit: cover;"
                                        alt="Avatar"
                                        onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/images/default-avatar.png';">
                                </c:when>
                                <c:otherwise>
                                    <%-- Nếu không có ảnh, dùng chữ cái đầu của tên --%>
                                        <div class="ps-avatar"
                                            style="width: 40px; height: 40px; border-radius: 8px; background: #4f46e5; color: white; display: flex; align-items: center; justify-content: center; font-weight: bold;">
                                            ${fn:toUpperCase(fn:substring(userName, 0, 1))}
                                        </div>
                                </c:otherwise>
                            </c:choose>

                            <div>
                                <div class="ps-user-name">${userName}</div>
                                <div class="ps-user-role">Quản trị viên</div>
                            </div>

                            <%-- Phần Notification --%>
                                <a href="${pageContext.request.contextPath}/notifications" class="ps-notification-link"
                                    title="Thông báo">
                                    <div class="nav-notification"
                                        style="position: relative; display: flex; align-items: center;">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20"
                                            viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                                            stroke-linecap="round" stroke-linejoin="round">
                                            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                                            <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
                                        </svg>
                                        <c:if test="${globalUnreadCount > 0}">
                                            <span class="badge-notify">
                                                ${globalUnreadCount > 99 ? '99+' : globalUnreadCount}
                                            </span>
                                        </c:if>
                                    </div>
                                </a>

                    </div>
                    <div class="ps-footer-actions">
                        <a href="${pageContext.request.contextPath}/profile" class="ps-footer-btn ps-btn-profile">
                            <i class="fas fa-user-gear"></i> <span class="ps-btn-text">Hồ sơ</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/logout" class="ps-footer-btn ps-btn-logout">
                            <i class="fas fa-power-off"></i> <span class="ps-btn-text">Thoát</span>
                        </a>
                    </div>
                </div>
            </aside>