<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8" />
            <meta content="width=device-width, initial-scale=1.0" name="viewport" />
            <title>LBMS - Chi tiết người dùng</title>

            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet" />
            <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />

            <style>
                :root {
                    --primary: #1E40AF;
                    --primary-hover: #1e3a8a;
                    --background-light: #F3F4F6;
                    --card-light: #FFFFFF;
                    --text-gray-900: #111827;
                    --text-gray-700: #374151;
                    --text-gray-500: #6B7280;
                    --text-gray-400: #9CA3AF;
                    --amber-500: #F59E0B;
                    --amber-600: #D97706;
                    --green-100: #DCFCE7;
                    --green-500: #22C55E;
                    --green-700: #15803D;
                    --red-100: #FEE2E2;
                    --red-500: #EF4444;
                    --red-700: #B91C1C;
                    --blue-50: #EFF6FF;
                }

                body {
                    margin: 0;
                    padding: 0;
                    font-family: 'Inter', sans-serif;
                    background-color: var(--background-light);
                }


                .app-container {
                    display: flex;
                    min-height: 100vh;
                }

                .main-wrapper {
                    flex: 1;
                    margin-left: 280px;
                    min-height: 100vh;
                    display: flex;
                    flex-direction: column;
                    background-color: var(--background-light);
                    transition: margin-left 0.3s ease;
                }

                .content-area {
                    padding: 2rem;
                    flex: 1;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                .max-w-2xl {
                    width: 100%;
                    max-width: 42rem;
                }


                .profile-card {
                    background-color: var(--card-light);
                    border-radius: 1rem;
                    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                    overflow: hidden;
                }

                .card-header {
                    height: 8rem;
                    background-color: var(--primary);
                    position: relative;
                }

                .avatar-container {
                    position: absolute;
                    bottom: -3rem;
                    left: 2rem;
                }

                .avatar-box {
                    height: 6rem;
                    width: 6rem;
                    border-radius: 1rem;
                    background-color: white;
                    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    border: 4px solid white;
                    color: var(--primary);
                }

                .card-content {
                    padding-top: 4rem;
                    padding-bottom: 2rem;
                    padding-left: 2rem;
                    padding-right: 2rem;
                }


                .header-flex {
                    display: flex;
                    justify-content: space-between;
                    align-items: flex-start;
                    margin-bottom: 1.5rem;
                }

                .title-name {
                    font-size: 1.5rem;
                    font-weight: 700;
                    color: var(--text-gray-900);
                    margin: 0;
                }

                .user-id {
                    font-size: 0.875rem;
                    color: var(--text-gray-500);
                    font-weight: 500;
                    margin: 0;
                }


                .badge {
                    padding: 0.25rem 0.75rem;
                    border-radius: 9999px;
                    font-size: 0.75rem;
                    font-weight: 700;
                    display: flex;
                    align-items: center;
                    gap: 0.25rem;
                }

                .badge-dot {
                    width: 0.5rem;
                    height: 0.5rem;
                    border-radius: 50%;
                }

                .status-active {
                    background-color: var(--green-100);
                    color: var(--green-700);
                }

                .dot-active {
                    background-color: var(--green-500);
                }

                .status-locked {
                    background-color: var(--red-100);
                    color: var(--red-700);
                }

                .dot-locked {
                    background-color: var(--red-500);
                }

                hr {
                    border: 0;
                    border-top: 1px solid #F3F4F6;
                    margin-bottom: 1.5rem;
                }


                .info-grid {
                    display: grid;
                    grid-template-columns: 1fr;
                    gap: 1.5rem;
                }

                @media (min-width: 768px) {
                    .info-grid {
                        grid-template-columns: repeat(2, 1fr);
                    }
                }

                .info-item {
                    display: flex;
                    align-items: flex-start;
                    gap: 0.75rem;
                }

                .info-icon-box {
                    padding: 0.5rem;
                    background-color: var(--blue-50);
                    border-radius: 0.5rem;
                    color: var(--primary);
                    display: flex;
                }

                .info-label {
                    font-size: 0.75rem;
                    color: var(--text-gray-400);
                    text-transform: uppercase;
                    font-weight: 700;
                    letter-spacing: 0.05em;
                    margin: 0;
                }

                .info-value {
                    color: var(--text-gray-700);
                    font-weight: 500;
                    margin: 0;
                }


                .btn-group {
                    margin-top: 2.5rem;
                    display: flex;
                    flex-direction: column;
                    gap: 0.75rem;
                }

                @media (min-width: 640px) {
                    .btn-group {
                        flex-direction: row;
                    }
                }

                .btn {
                    flex: 1;
                    display: flex;
                    justify-content: center;
                    align-items: center;
                    gap: 0.5rem;
                    padding: 0.75rem 1rem;
                    font-weight: 600;
                    border-radius: 0.75rem;
                    text-decoration: none;
                    transition: all 0.2s;
                    font-size: 0.875rem;
                }

                .btn-edit {
                    background-color: var(--amber-500);
                    color: white;
                    box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
                }

                .btn-edit:hover {
                    background-color: var(--amber-600);
                    transform: translateY(-2px);
                }

                .btn-back {
                    background-color: #F3F4F6;
                    color: var(--text-gray-700);
                }

                .btn-back:hover {
                    background-color: #E5E7EB;
                }


                .footer {
                    margin-top: 2rem;
                    padding-top: 1rem;
                    border-top: 1px solid #E5E7EB;
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    font-size: 0.875rem;
                    color: var(--text-gray-500);
                }

                @media (max-width: 768px) {
                    .main-wrapper {
                        margin-left: 0;
                    }
                }
            </style>
        </head>

        <body>

            <div class="app-container">

                <jsp:include page="sidebar.jsp" />

                <main class="main-wrapper">
                    <div class="content-area">
                        <div class="max-w-2xl">

                            <div class="profile-card">
                                <%-- Header --%>
                                    <div class="card-header">
                                        <div class="avatar-container">
                                            <div class="avatar-box">
                                                <span class="material-icons"
                                                    style="font-size: 3rem;">account_circle</span>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Content Section --%>
                                        <div class="card-content">
                                            <div class="header-flex">
                                                <div>
                                                    <h2 class="title-name">${user.fullName}</h2>
                                                    <p class="user-id">User ID: #${user.id}</p>
                                                </div>
                                                <c:choose>
                                                    <c:when test="${user.status == 'ACTIVE'}">
                                                        <span class="badge status-active">
                                                            <span class="badge-dot dot-active"></span> HOẠT ĐỘNG
                                                        </span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="badge status-locked">
                                                            <span class="badge-dot dot-locked"></span> BỊ KHÓA
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                                            <hr>

                                            <div class="info-grid">
                                                <div class="info-item">
                                                    <div class="info-icon-box">
                                                        <span class="material-icons">person</span>
                                                    </div>
                                                    <div>
                                                        <p class="info-label">Họ và Tên</p>
                                                        <p class="info-value">${user.fullName}</p>
                                                    </div>
                                                </div>

                                                <div class="info-item">
                                                    <div class="info-icon-box">
                                                        <span class="material-icons">email</span>
                                                    </div>
                                                    <div>
                                                        <p class="info-label">Địa chỉ Email</p>
                                                        <p class="info-value">${user.email}</p>
                                                    </div>
                                                </div>

                                                <div class="info-item">
                                                    <div class="info-icon-box">
                                                        <span class="material-icons">badge</span>
                                                    </div>
                                                    <div>
                                                        <p class="info-label">Vai trò</p>
                                                        <p class="info-value">${user.role.name}</p>
                                                    </div>
                                                </div>
                                            </div>

                                            <%-- Action Buttons --%>
                                                <div class="btn-group">
                                                    <a href="${pageContext.request.contextPath}/admin/users/edit?id=${user.id}&page=${param.page}&keyword=${param.keyword}"
                                                        class="btn btn-edit">
                                                        <span class="material-icons"
                                                            style="font-size: 1rem;">edit</span>
                                                        Chỉnh sửa tài khoản
                                                    </a>

                                                    <a href="${pageContext.request.contextPath}/admin/users?page=${not empty param.page ? param.page : 1}&keyword=${param.keyword}"
                                                        class="btn btn-back">
                                                        <span class="material-icons"
                                                            style="font-size: 1rem;">arrow_back</span>
                                                        Quay lại danh sách
                                                    </a>
                                                </div>
                                        </div>
                            </div>

                            <%-- Footer --%>
                                <div class="footer">
                                    <p>© 2026 Library Management System (LBMS)</p>
                                    <p>Version 1.0.0</p>
                                </div>

                        </div>
                    </div>
                </main>
            </div>

        </body>

        </html>