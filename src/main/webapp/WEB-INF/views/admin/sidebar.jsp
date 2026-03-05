<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

            <style>
                /* Reset & Base Styles cho Sidebar */
                .sidebar {
                    width: 280px;
                    background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
                    color: white;
                    padding: 24px 0;
                    position: fixed;
                    /* Cố định sidebar bên trái */
                    left: 0;
                    top: 0;
                    height: 100vh;
                    overflow-y: auto;
                    box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
                    z-index: 1000;
                    transition: all 0.3s ease;
                }

                /* Đảm bảo thanh cuộn sidebar đẹp hơn */
                .sidebar::-webkit-scrollbar {
                    width: 4px;
                }

                .sidebar::-webkit-scrollbar-thumb {
                    background: rgba(255, 255, 255, 0.2);
                    border-radius: 10px;
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
                    margin: 0;
                    /* Loại bỏ margin mặc định của h2 */
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
                    text-decoration: none !important;
                    /* Bỏ gạch chân của thẻ a */
                    border-radius: 8px;
                    transition: all 0.3s ease;
                    margin-bottom: 4px;
                    white-space: nowrap;
                }

                .sidebar-nav a:hover {
                    background-color: rgba(255, 255, 255, 0.15);
                    color: white;
                    padding-left: 20px;
                    /* Hiệu ứng dịch chuyển nhẹ khi hover */
                }

                .sidebar-nav a.active {
                    background: rgba(255, 255, 255, 0.25);
                    color: white;
                    border-left: 4px solid white;
                    font-weight: 600;
                }

                .sidebar-nav i {
                    width: 20px;
                    text-align: center;
                }

                /* Responsive: Thu nhỏ sidebar trên màn hình Tablet */
                @media (max-width: 992px) {
                    .sidebar {
                        width: 80px;
                    }

                    .sidebar-header h2,
                    .sidebar-section-title,
                    .sidebar-nav span {
                        display: none;
                    }

                    .sidebar-header {
                        padding: 0;
                        justify-content: center;
                    }

                    .sidebar-nav a {
                        justify-content: center;
                        padding: 12px;
                    }
                }

                /* Ẩn sidebar trên Mobile (Tùy chọn) */
                @media (max-width: 768px) {
                    .sidebar {
                        left: -280px;
                        /* Ẩn sidebar đi */
                    }
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
                            <span>Quản lý người dùng</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/books"
                            class="${fn:contains(activeUri, '/admin/books') ? 'active' : ''}">
                            <i class="fas fa-book-open"></i>
                            <span>Quản lý sách</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/categories"
                            class="${fn:contains(activeUri, '/admin/categories') ? 'active' : ''}">
                            <i class="fas fa-list"></i>
                            <span>Danh mục sách</span>
                        </a>
                    </div>
                </div>

                <div class="sidebar-section">
                    <div class="sidebar-section-title">ANALYSIS</div>
                    <div class="sidebar-nav">
                        <a href="${pageContext.request.contextPath}/admin/librarianActivityLog"
                            class="${fn:contains(activeUri, '/admin/librarianActivityLog') ? 'active' : ''}">
                            <i class="fas fa-history"></i>
                            <span>Nhật ký thủ thư</span>
                        </a>

                        <a href="${pageContext.request.contextPath}/admin/statistics"
                            class="${fn:contains(activeUri, '/admin/statistics') ? 'active' : ''}">
                            <i class="fas fa-chart-pie"></i>
                            <span>Thống kê mượn trả sách</span>
                        </a>

                        <a href="#"><i class="fas fa-chart-bar"></i> <span>Reports</span></a>
                        <a href="#"><i class="fas fa-shipping-fast"></i> <span>Shipments</span></a>
                    </div>
                </div>

                <div class="sidebar-section">
                    <div class="sidebar-section-title">OTHER</div>
                    <div class="sidebar-nav">
                        <a href="#"><i class="fas fa-cog"></i> <span>Settings</span></a>
                        <a href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt"></i> <span>Logout</span>
                        </a>
                    </div>
                </div>
            </div>