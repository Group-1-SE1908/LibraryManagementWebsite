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
                    <c:set var="routePrefix"
                        value="${not empty requestScope.staffRoutePrefix ? requestScope.staffRoutePrefix : '/staff'}" />
                    <c:set var="borrowBase" value="${routePrefix}/borrowlibrary" />
                    <c:set var="finesBase" value="${routePrefix}/fines" />
                    <c:set var="booksBase" value="${routePrefix}/books" />
                    <c:set var="renewalBase" value="${routePrefix}/renewal" />
                    <c:set var="defaultFeedbackBase" value="${routePrefix}/feedback" />
                    <c:set var="feedbackBase"
                        value="${not empty requestScope.feedbackBasePath ? requestScope.feedbackBasePath : defaultFeedbackBase}" />
                    <c:set var="currentFilter" value="${param.filter}" />

                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />

                    <aside class="panel-sidebar">
                        <a href="${pageContext.request.contextPath}${borrowBase}" class="ps-brand">
                            <div class="ps-brand-icon"><i class="fas fa-book-open"></i></div>
                            <div>
                                <span class="ps-brand-text">LBMS</span>
                                <span class="ps-brand-badge">Staff</span>
                            </div>
                        </a>

                        <nav class="ps-nav">
                            <div class="ps-section-title">Nghiệp vụ</div>
                            <div class="ps-menu">
                                <a href="${pageContext.request.contextPath}${borrowBase}"
                                    class="${activeUri.endsWith('/borrowlibrary') && empty currentFilter ? 'active' : ''}">
                                    <i class="fas fa-exchange-alt"></i> <span>Quản lý mượn trả</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${borrowBase}?filter=ONLINE"
                                    class="${currentFilter == 'ONLINE' ? 'active' : ''}">
                                    <i class="fas fa-globe"></i> <span>Yêu cầu trực tuyến</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${borrowBase}/inperson"
                                    class="${activeUri.contains('/inperson') ? 'active' : ''}">
                                    <i class="fas fa-hand-holding"></i> <span>Mượn tại quầy</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${borrowBase}?filter=OVERDUE"
                                    class="${currentFilter == 'OVERDUE' ? 'active' : ''}">
                                    <i class="fas fa-exclamation-triangle"></i>
                                    <span>Đơn quá hạn</span>
                                    <span class="ps-badge">!</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${renewalBase}"
                                    class="${fn:contains(activeUri, '/renewal') ? 'active' : ''}">
                                    <i class="fas fa-calendar-check"></i> <span>Gia hạn</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${finesBase}"
                                    class="${activeUri.contains('/fines') ? 'active' : ''}">
                                    <i class="fas fa-coins"></i> <span>Tiền phạt</span>
                                </a>
                            </div>

                            <div class="ps-section-title">Kho sách</div>
                            <div class="ps-menu">
                                <a href="${pageContext.request.contextPath}${booksBase}"
                                    class="${fn:contains(activeUri, booksBase) && !fn:contains(activeUri, '/new') && param.action != 'viewImportList' ? 'active' : ''}">
                                    <i class="fas fa-book"></i> <span>Kho sách</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${booksBase}/new"
                                    class="${fn:contains(activeUri, '/new') ? 'active' : ''}">
                                    <i class="fas fa-plus-circle"></i> <span>Thêm sách mới</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${booksBase}?action=viewImportList"
                                    class="${param.action == 'viewImportList' ? 'active' : ''}">
                                    <i class="fas fa-truck-loading"></i> <span>Nhập kho</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${routePrefix}/reservation"
                                    class="${activeUri.contains('/reservation') ? 'active' : ''}">
                                    <i class="fas fa-hourglass-end"></i> <span>Quản lý đặt trước</span>
                                </a>
                                <a href="${pageContext.request.contextPath}${feedbackBase}"
                                    class="${activeUri.contains('/feedback') ? 'active' : ''}">
                                    <i class="fas fa-comment-dots"></i> <span>Phản hồi về sách</span>
                                </a>
                            </div>
                        </nav>

                        <div class="ps-footer">
                            <div class="ps-profile">
                                <div class="ps-avatar">${userInitial.toUpperCase()}</div>
                                <div>
                                    <div class="ps-user-name">${userName}</div>
                                    <div class="ps-user-role">Thủ thư</div>
                                </div>
                            </div>
                            <div class="ps-footer-actions">
                                <a href="${pageContext.request.contextPath}/profile"
                                    class="ps-footer-btn ps-btn-profile">
                                    <i class="fas fa-user-gear"></i> <span class="ps-btn-text">Hồ sơ</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/logout" class="ps-footer-btn ps-btn-logout">
                                    <i class="fas fa-power-off"></i> <span class="ps-btn-text">Thoát</span>
                                </a>
                            </div>
                        </div>
                    </aside>
                </c:otherwise>
            </c:choose>