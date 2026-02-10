<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="en">

        <head>
            <meta charset="utf-8" />
            <meta content="width=device-width, initial-scale=1.0" name="viewport" />
            <title>LBMS - Thêm người dùng mới</title>

            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                rel="stylesheet" />
            <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />

            <style>
                :root {
                    --primary: #1E40AF;
                    --primary-hover: #1e3a8a;
                    --background-light: #F3F4F6;
                    --white: #FFFFFF;
                    --gray-100: #F3F4F6;
                    --gray-300: #D1D5DB;
                    --gray-400: #9CA3AF;
                    --gray-500: #6B7280;
                    --gray-600: #4B5563;
                    --gray-700: #374151;
                    --gray-900: #111827;
                    --blue-100: #DBEAFE;
                    --blue-200: #BFDBFE;
                    --red-50: #FEF2F2;
                    --red-500: #EF4444;
                    --red-700: #B91C1C;
                    --green-400: #4ADE80;
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
                    background-color: var(--background-light);
                    min-height: 100vh;
                    display: flex;
                    flex-direction: column;
                }

                .content-area {
                    padding: 2rem;
                    flex: 1;
                }

                .max-w-5xl {
                    max-width: 64rem;
                    margin: 0 auto;
                }

                .mx-auto {
                    margin-left: auto;
                    margin-right: auto;
                }

                .mb-6 {
                    margin-bottom: 1.5rem;
                }

                .mb-8 {
                    margin-bottom: 2rem;
                }

                .mb-2 {
                    margin-bottom: 0.5rem;
                }

                .back-link {
                    display: flex;
                    align-items: center;
                    color: var(--gray-600);
                    text-decoration: none;
                    transition: color 0.2s;
                }

                .back-link:hover {
                    color: var(--primary);
                }

                .mr-1 {
                    margin-right: 0.25rem;
                }


                .form-card {
                    background-color: var(--white);
                    border-radius: 1rem;
                    box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                    overflow: hidden;
                    display: flex;
                    flex-direction: column;
                    min-height: 600px;
                }


                .sidebar-decor {
                    display: none;
                    position: relative;
                }

                .sidebar-overlay {
                    position: absolute;
                    inset: 0;
                    background-color: rgba(30, 64, 175, 0.9);
                    z-index: 10;
                }

                .sidebar-img {
                    position: absolute;
                    inset: 0;
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                }

                .sidebar-content {
                    position: relative;
                    z-index: 20;
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                    justify-content: space-between;
                    padding: 2.5rem;
                    color: white;
                    box-sizing: border-box;
                }


                .form-body {
                    width: 100%;
                    padding: 2rem;
                    box-sizing: border-box;
                }


                .form-group {
                    margin-bottom: 1.25rem;
                }

                .label {
                    display: block;
                    font-size: 0.875rem;
                    font-weight: 600;
                    color: var(--gray-700);
                    margin-bottom: 0.25rem;
                }

                .relative {
                    position: relative;
                }

                .input-icon {
                    position: absolute;
                    left: 0.75rem;
                    top: 50%;
                    transform: translateY(-50%);
                    color: var(--gray-400);
                    font-size: 1.125rem !important;
                }

                .form-control {
                    width: 100%;
                    padding: 0.5rem 0.75rem 0.5rem 2.5rem;
                    border: 1px solid var(--gray-300);
                    border-radius: 0.5rem;
                    font-size: 0.875rem;
                    box-sizing: border-box;
                    transition: all 0.2s;
                }

                .form-control:focus {
                    outline: none;
                    border-color: var(--primary);
                    box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.2);
                }


                .select-wrapper::after {
                    content: 'expand_more';
                    font-family: 'Material Icons';
                    position: absolute;
                    right: 0.75rem;
                    top: 50%;
                    transform: translateY(-50%);
                    color: var(--gray-400);
                    pointer-events: none;
                    font-size: 1.25rem;
                }

                .grid-inputs {
                    display: grid;
                    grid-template-columns: 1fr;
                    gap: 1rem;
                }


                .btn-group {
                    display: flex;
                    flex-direction: column;
                    gap: 0.75rem;
                    margin-top: 1rem;
                }

                .btn-submit {
                    flex: 1;
                    padding: 0.625rem;
                    background-color: var(--primary);
                    color: white;
                    border: none;
                    border-radius: 0.5rem;
                    font-weight: 700;
                    cursor: pointer;
                    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                    transition: all 0.2s;
                }

                .btn-submit:hover {
                    background-color: var(--primary-hover);
                }

                .btn-submit:active {
                    transform: scale(0.95);
                }

                .btn-cancel {
                    flex: 1;
                    padding: 0.625rem;
                    border: 1px solid var(--gray-300);
                    background: transparent;
                    color: var(--gray-700);
                    text-align: center;
                    text-decoration: none;
                    border-radius: 0.5rem;
                    font-weight: 700;
                    transition: background 0.2s;
                }

                .btn-cancel:hover {
                    background-color: #F9FAFB;
                }


                .error-container {
                    margin-bottom: 1.5rem;
                    padding: 1rem;
                    background-color: var(--red-50);
                    border-left: 4px solid var(--red-500);
                    color: var(--red-700);
                    border-radius: 0 0.5rem 0.5rem 0;
                    transition: opacity 0.5s;
                }


                @media (min-width: 1024px) {
                    .form-card {
                        flex-direction: row;
                    }

                    .sidebar-decor {
                        display: block;
                        width: 41.666667%;
                    }

                    .form-body {
                        width: 58.333333%;
                        padding: 3rem;
                    }

                    .grid-inputs {
                        grid-template-columns: 1fr 1fr;
                    }
                }

                @media (min-width: 640px) {
                    .btn-group {
                        flex-direction: row;
                    }
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
                        <div class="max-w-5xl">

                            <div class="mb-6">
                                <a href="${pageContext.request.contextPath}/admin/users" class="back-link">
                                    <span class="material-icons mr-1">arrow_back</span>
                                    Quay lại danh sách
                                </a>
                            </div>

                            <div class="form-card">
                                <div class="sidebar-decor">
                                    <div class="sidebar-overlay"></div>
                                    <img alt="Admin Panel" class="sidebar-img"
                                        src="https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&q=80&w=1000" />
                                    <div class="sidebar-content">
                                        <div>
                                            <div
                                                style="display: flex; align-items: center; gap: 8px; margin-bottom: 8px;">
                                                <span class="material-icons"
                                                    style="font-size: 1.875rem;">admin_panel_settings</span>
                                                <h1
                                                    style="font-size: 1.5rem; font-weight: 700; margin: 0; letter-spacing: -0.025em;">
                                                    LBMS ADMIN</h1>
                                            </div>
                                            <p
                                                style="color: var(--blue-100); font-size: 0.875rem; font-weight: 500; margin: 0;">
                                                Hệ thống quản lý người dùng</p>
                                        </div>
                                        <div>
                                            <h2
                                                style="font-size: 1.875rem; font-weight: 700; margin-bottom: 1rem; line-height: 1.25;">
                                                Thêm thành viên mới cho thư viện.</h2>
                                            <p style="color: var(--blue-100); line-height: 1.625;">Vui lòng đảm bảo
                                                thông tin chính xác. Tài khoản mới sẽ mặc định ở trạng thái <span
                                                    style="font-weight: 700; color: var(--green-400);">HOẠT ĐỘNG</span>.
                                            </p>
                                        </div>
                                        <div style="font-size: 0.75rem; color: var(--blue-200);">© 2026 LBMS </div>
                                    </div>
                                </div>

                                <div class="form-body">
                                    <div class="mb-8">
                                        <h2
                                            style="font-size: 1.5rem; font-weight: 700; color: var(--gray-900); margin: 0 0 0.5rem 0;">
                                            Đăng ký người dùng</h2>
                                        <p style="color: var(--gray-500); font-size: 0.875rem; margin: 0;">Điền đầy đủ
                                            các thông tin dưới đây để tạo tài khoản.</p>
                                    </div>

                                    <c:if test="${not empty errors}">
                                        <div id="error-box" class="error-container">
                                            <div
                                                style="display: flex; align-items: center; margin-bottom: 0.5rem; font-weight: 700; font-size: 0.875rem;">
                                                <span class="material-icons"
                                                    style="font-size: 1rem; margin-right: 0.5rem;">error</span> Có lỗi
                                                xảy ra:
                                            </div>
                                            <ul
                                                style="list-style: disc; list-style-position: inside; font-size: 0.75rem; margin: 0; padding: 0;">
                                                <c:forEach items="${errors}" var="err">
                                                    <li style="margin-bottom: 4px;">${err}</li>
                                                </c:forEach>
                                            </ul>
                                        </div>
                                    </c:if>

                                    <form action="${pageContext.request.contextPath}/admin/users/create" method="POST"
                                        style="display: flex; flex-direction: column; gap: 1.25rem;">
                                        <div class="form-group">
                                            <label class="label">Họ và tên</label>
                                            <div class="relative">
                                                <span class="material-icons input-icon">person</span>
                                                <input type="text" name="name" value="${param.name}" required
                                                    class="form-control" placeholder="Nhập tên đầy đủ" />
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="label">Email</label>
                                            <div class="relative">
                                                <span class="material-icons input-icon">email</span>
                                                <input type="email" name="email" value="${param.email}" required
                                                    class="form-control" placeholder="email@example.com" />
                                            </div>
                                        </div>

                                        <div class="grid-inputs">
                                            <div class="form-group">
                                                <label class="label">Mật khẩu</label>
                                                <div class="relative">
                                                    <span class="material-icons input-icon">lock</span>
                                                    <input type="password" name="password" required class="form-control"
                                                        placeholder="Nhập mật khẩu" />
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="label">Xác nhận</label>
                                                <div class="relative">
                                                    <span class="material-icons input-icon">lock_reset</span>
                                                    <input type="password" name="confirmPassword" required
                                                        class="form-control" placeholder="Xác nhận mât khẩu" />
                                                </div>
                                            </div>
                                        </div>

                                        <div class="form-group">
                                            <label class="label">Vai trò</label>
                                            <div class="relative select-wrapper">
                                                <span class="material-icons input-icon">badge</span>
                                                <select name="roleId" required class="form-control"
                                                    style="appearance: none; -webkit-appearance: none; background-color: white; cursor: pointer;">
                                                    <c:forEach items="${roleList}" var="r">
                                                        <option value="${r.id}" ${param.roleId==r.id ? 'selected' : ''
                                                            }>${r.name}</option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="btn-group">
                                            <button type="submit" class="btn-submit">Lưu người dùng</button>
                                            <a href="${pageContext.request.contextPath}/admin/users"
                                                class="btn-cancel">Hủy</a>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    </div>
                </main>
            </div>

            <script>
                document.addEventListener('DOMContentLoaded', () => {
                    const errorBox = document.getElementById('error-box');
                    if (errorBox) {
                        setTimeout(() => {
                            errorBox.style.opacity = '0';
                            setTimeout(() => errorBox.remove(), 500);
                        }, 5000);
                    }
                });
            </script>
        </body>

        </html>