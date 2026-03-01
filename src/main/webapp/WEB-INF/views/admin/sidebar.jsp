<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

            <style>
                /* Reset & Base Styles */
                .sidebar {
                    width: 280px;
                    background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
                    color: white;
                    padding: 24px 0;
                    position: fixed;
                    height: 100vh;
                    overflow-y: auto;
                    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
                    z-index: 1000;
                }

                .sidebar-header {
                    padding: 0 24px 32px;
                    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    margin-bottom: 24px;
                }

                .sidebar-header i {
                    font-size: 28px;
                }

                .sidebar-header h2 {
                    font-size: 18px;
                    font-weight: 600;
                }

                .sidebar-section-title {
                    padding: 12px 24px;
                    font-size: 11px;
                    text-transform: uppercase;
                    letter-spacing: 1px;
                    color: rgba(255, 255, 255, 0.6);
                    font-weight: 600;
                    margin-top: 16px;
                }

                .sidebar-nav {
                    padding: 8px 16px;
                }

                .sidebar-nav a {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    padding: 12px 16px;
                    color: rgba(255, 255, 255, 0.85);
                    text-decoration: none;
                    border-radius: 8px;
                    transition: all 0.3s ease;
                    margin-bottom: 4px;
                    white-space: nowrap;
                }

                .sidebar-nav a:hover,
                .sidebar-nav a.active {
                    background-color: rgba(255, 255, 255, 0.15);
                    color: white;
                }

                .sidebar-nav a.active {
                    background: rgba(255, 255, 255, 0.25);
                    border-left: 3px solid white;
                }

                .sidebar-nav i {
                    width: 20px;
                    text-align: center;
                }
            </style>

            <div class="sidebar">
                <c:set var="activeUri" value="${requestScope['jakarta.servlet.forward.request_uri']}" />
                <c:if test="${empty activeUri}">
                    <c:set var="activeUri" value="${pageContext.request.requestURI}" />
                </c:if>

                <div class="sidebar-header">
                    <i class="fas fa-book"></i>
                    <h2>LBMS Admin</h2>
                </div>

                <div class="sidebar-section">
                    <div class="sidebar-section-title">MANAGEMENT</div>
                    <div class="sidebar-nav">
                        <a href="${pageContext.request.contextPath}/admin"
                            class="${activeUri.endsWith('/admin') || activeUri.endsWith('/admin/') ? 'active' : ''}">
                            <i class="fas fa-chart-line"></i>
                            <span>Dashboard</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/users"
                            class="${fn:contains(activeUri, '/admin/users') ? 'active' : ''}">
                            <i class="fas fa-users"></i>
                            <span>User Management</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/books"
                            class="${fn:contains(activeUri, '/admin/books') ? 'active' : ''}">
                            <i class="fas fa-book-open"></i>
                            <span>Book Management</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/categories"
                            class="${fn:contains(activeUri, '/admin/categories') ? 'active' : ''}">
                            <i class="fas fa-list"></i>
                            <span>Categories</span>
                        </a>
                    </div>
                </div>

                <div class="sidebar-section">
                    <div class="sidebar-section-title">ANALYSIS</div>
                    <div class="sidebar-nav">
                        <%-- Mục Activity Log --%>
                            <a href="${pageContext.request.contextPath}/admin/librarianActivityLog"
                                class="${fn:contains(activeUri, '/admin/librarianActivityLog') ? 'active' : ''}">
                                <i class="fas fa-history"></i>
                                <span>Librarian Activity Log</span>
                            </a>

                            <a href="#"><i class="fas fa-chart-bar"></i> Reports</a>
                            <a href="#"><i class="fas fa-shipping-fast"></i> Shipments</a>
                    </div>
                </div>

                <div class="sidebar-section">
                    <div class="sidebar-section-title">OTHER</div>
                    <div class="sidebar-nav">
                        <a href="#"><i class="fas fa-cog"></i> Settings</a>
                        <a href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </div>
                </div>
            </div>