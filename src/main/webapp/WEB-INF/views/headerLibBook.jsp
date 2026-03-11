<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<header class="header-lib shadow-sm sticky-top border-bottom bg-white">
    <nav class="navbar navbar-expand-lg navbar-light container-fluid px-4">
        <a class="navbar-brand d-flex align-items-center" href="${pageContext.request.contextPath}/home">
            <img src="${pageContext.request.contextPath}/assets/images/logo/logo.png" alt="LBMS" width="40" class="mr-2">
            <span class="font-weight-bold text-primary" style="letter-spacing: 1px;">LBMS LIBRARIAN</span>
        </a>

        <button class="navbar-toggler border-0" type="button" data-toggle="collapse" data-target="#librarianNav">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="librarianNav">
            <ul class="navbar-nav mx-auto">
                <li class="nav-item mx-2">
                    <a class="nav-link ${param.active == 'books' ? 'active font-weight-bold text-primary' : ''}" 
                       href="${pageContext.request.contextPath}/staff/borrowlibrary">
                        <i class="fas fa-book mr-1"></i> Quản lý Sách
                    </a>
                </li>
                <li class="nav-item mx-2">
                    <a class="nav-link ${param.active == 'borrow' ? 'active font-weight-bold text-primary' : ''}" 
                       href="${pageContext.request.contextPath}/staff/borrowlibrary?filter=ONLINE">
                        <i class="fas fa-clipboard-list mr-1"></i> Yêu cầu mượn
                    </a>
                </li>
                
            </ul>

            <div class="navbar-nav ml-auto align-items-center">
                <div class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" id="userDropdown" data-toggle="dropdown">
                        <div class="avatar-sm mr-2 bg-primary text-white rounded-circle d-flex align-items-center justify-content-center" style="width: 32px; height: 32px;">
                            ${sessionScope.user.fullName.substring(0,1).toUpperCase()}
                        </div>
                        <span class="d-none d-md-inline text-dark">${sessionScope.user.fullName}</span>
                    </a>
                    <div class="dropdown-menu dropdown-menu-right border-0 shadow">
                        <a class="dropdown-item" href="${pageContext.request.contextPath}/profile">
                            <i class="fas fa-user-circle mr-2 text-muted"></i> Hồ sơ cá nhân
                        </a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout">
                            <i class="fas fa-sign-out-alt mr-2"></i> Đăng xuất
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </nav>
</header>

<style>
    .header-lib .nav-link {
        transition: all 0.3s ease;
        padding: 0.5rem 1rem;
    }
    .header-lib .nav-link:hover {
        color: #007bff !important;
        transform: translateY(-2px);
    }
    .header-lib .nav-link.active {
        border-bottom: 2px solid #007bff;
    }
    .avatar-sm { font-size: 0.8rem; font-weight: bold; }
</style>