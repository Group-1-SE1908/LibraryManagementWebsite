<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">

    <head>
        <meta charset="utf-8" />
        <meta content="width=device-width, initial-scale=1.0" name="viewport" />
        <title>LBMS - Chỉnh sửa tài khoản người dùng</title>

        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
              rel="stylesheet" />
        <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet" />

        <style>
            /* Variables & Base Styles */
            :root {
                --primary: #1E40AF;
                --primary-hover: #1e3a8a;
                --background-light: #F3F4F6;
                --card-light: #FFFFFF;
                --text-gray-900: #111827;
                --text-gray-700: #374151;
                --text-gray-500: #6B7280;
                --text-gray-400: #9CA3AF;
                --blue-100: #DBEAFE;
                --blue-200: #BFDBFE;
                --red-50: #FEF2F2;
                --red-500: #EF4444;
                --red-700: #B91C1C;
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
                transition: margin-left 0.3s ease;
            }

            .content-area {
                padding: 2rem;
                flex: 1;
            }

            .max-w-6xl {
                max-width: 72rem;
                margin: 0 auto;
            }


            .card-container {
                width: 100%;
                display: flex;
                flex-direction: column;
                overflow: hidden;
                border-radius: 1rem;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                background-color: var(--card-light);
                min-height: 600px;
            }


            .side-decorative {
                display: none;
                width: 50%;
                position: relative;
            }

            .overlay {
                position: absolute;
                inset: 0;
                background-color: var(--primary);
                opacity: 0.9;
                z-index: 10;
            }

            .bg-img {
                position: absolute;
                inset: 0;
                width: 100%;
                height: 100%;
                object-fit: cover;
                filter: grayscale(100%);
                mix-blend-mode: multiply;
            }

            .side-content {
                position: relative;
                z-index: 20;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                padding: 3rem;
                color: #FFFFFF;
                box-sizing: border-box;
            }


            .side-form {
                width: 100%;
                padding: 2rem;
                display: flex;
                flex-direction: column;
                justify-content: center;
                box-sizing: border-box;
            }


            .title-main {
                font-size: 1.875rem;
                font-weight: 700;
                color: var(--text-gray-900);
                margin-bottom: 0.5rem;
            }

            .subtitle {
                color: var(--text-gray-500);
                font-style: italic;
            }

            .text-primary {
                color: var(--primary);
                font-weight: 600;
            }


            .form-group {
                margin-bottom: 1.25rem;
            }

            .label {
                display: block;
                font-size: 0.875rem;
                font-weight: 500;
                color: var(--text-gray-700);
                margin-bottom: 0.25rem;
            }

            .input-wrapper {
                position: relative;
                border-radius: 0.5rem;
            }


            .icon-box {
                position: absolute;
                top: 0;
                bottom: 0;
                left: 0;
                width: 2.5rem;
                display: flex;
                align-items: center;
                justify-content: center;
                pointer-events: none;
                color: var(--text-gray-400);
            }

            .icon-box .material-icons {
                font-size: 1.25rem;
            }

            .input-field {
                display: block;
                width: 100%;
                padding: 0.625rem 0.75rem 0.625rem 2.5rem;
                border: 1px solid #D1D5DB;
                border-radius: 0.5rem;
                font-size: 0.875rem;
                line-height: 1.25rem;
                box-sizing: border-box;
                transition: all 0.2s;
                background-color: #fff;
            }

            .input-field:focus {
                outline: none;
                border-color: var(--primary);
                box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.2);
            }


            select.input-field {
                appearance: none;
                -webkit-appearance: none;
                background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='%239CA3AF'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E");
                background-repeat: no-repeat;
                background-position: right 0.75rem center;
                background-size: 1.25rem;
                padding-right: 2.5rem;
            }


            .btn-group {
                display: flex;
                flex-direction: column;
                gap: 1rem;
                margin-top: 1rem;
            }

            .btn-submit {
                flex: 1;
                padding: 0.75rem 1rem;
                background-color: var(--primary);
                color: white;
                border: none;
                border-radius: 0.5rem;
                font-weight: 600;
                font-size: 0.875rem;
                cursor: pointer;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                transition: all 0.15s;
            }

            .btn-submit:hover {
                background-color: var(--primary-hover);
                transform: translateY(-2px);
            }

            .btn-cancel {
                flex: 1;
                padding: 0.75rem 1rem;
                background-color: white;
                color: var(--text-gray-700);
                border: 1px solid #D1D5DB;
                border-radius: 0.5rem;
                font-weight: 600;
                font-size: 0.875rem;
                text-align: center;
                text-decoration: none;
                transition: background-color 0.15s;
            }

            .btn-cancel:hover {
                background-color: #F9FAFB;
            }


            .grid-passwords {
                display: grid;
                grid-template-columns: 1fr;
                gap: 1.25rem;
            }


            .error-alert {
                margin-bottom: 1.5rem;
                padding: 1rem;
                background-color: var(--red-50);
                border-left: 4px solid var(--red-500);
                color: var(--red-700);
                border-radius: 0.25rem;
                font-size: 0.875rem;
            }

            .error-alert ul {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .error-alert li {
                display: flex;
                align-items: center;
                gap: 0.5rem;
            }


            .footer {
                margin-top: 2rem;
                display: flex;
                justify-content: space-between;
                align-items: center;
                border-top: 1px solid #E5E7EB;
                padding-top: 1rem;
                color: var(--text-gray-500);
                font-size: 0.875rem;
            }


            @media (min-width: 1024px) {
                .card-container {
                    flex-direction: row;
                }

                .side-decorative {
                    display: block;
                }

                .side-form {
                    width: 50%;
                    padding: 3rem;
                }

                .grid-passwords {
                    grid-template-columns: repeat(2, 1fr);
                }

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
                    <div class="max-w-6xl">

                        <div class="card-container">

                            <%-- Left Side: Decorative --%>
                            <div class="side-decorative">
                                <div class="overlay"></div>
                                <img alt="Library interior" class="bg-img"
                                     src="https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&q=80&w=1000" />
                                <div class="side-content">
                                    <div>
                                        <div
                                            style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.5rem;">
                                            <span class="material-icons"
                                                  style="font-size: 1.875rem;">edit_note</span>
                                            <h1 style="font-size: 1.5rem; font-weight: 700; margin: 0;">LBMS
                                                ADMIN</h1>
                                        </div>
                                        <p style="color: var(--blue-100); font-weight: 500; margin: 0;">Cập nhật
                                            thông tin tài khoản</p>
                                    </div>
                                    <div>
                                        <h2
                                            style="font-size: 1.875rem; font-weight: 700; margin-bottom: 1rem; line-height: 1.2;">
                                            Chỉnh sửa tài khoản người dùng.</h2>
                                        <p
                                            style="color: var(--blue-100); line-height: 1.6; font-style: italic;">
                                            "Việc cập nhật thông tin đảm bảo hệ thống thư viện luôn chính xác và
                                            bảo mật."</p>
                                        <div
                                            style="margin-top: 1.5rem; padding: 1rem; background: rgba(255,255,255,0.1); border-radius: 0.5rem; border: 1px solid rgba(255,255,255,0.2);">
                                            <p style="font-size: 0.75rem; color: var(--blue-100); margin: 0;">
                                                <strong>Note:</strong> Để trống các ô mật khẩu nếu bạn không
                                                muốn thay đổi mật khẩu hiện tại.</p>
                                        </div>
                                    </div>
                                    <div style="font-size: 0.75rem; color: var(--blue-200);">© 2026 LBMS </div>
                                </div>
                            </div>

                            <%-- Right Side: Edit Form --%>
                            <div class="side-form">
                                <div style="margin-bottom: 2rem;">
                                    <h2 class="title-main">Chỉnh sửa tài khoản</h2>
                                    <p class="subtitle">Đang chỉnh sửa cho: <span
                                            class="text-primary">${user.fullName}</span></p>
                                </div>

                                <%-- Validation Errors --%>
                                <c:if test="${not empty errors}">
                                    <div id="error-box" class="error-alert">
                                        <ul>
                                            <c:forEach items="${errors}" var="err">
                                                <li><span class="material-icons"
                                                          style="font-size: 0.875rem;">error</span> ${err}
                                                </li>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </c:if>

                                <%-- Form --%>
                                <form action="${pageContext.request.contextPath}/admin/users/edit"
                                      method="POST">
                                    <input type="hidden" name="id" value="${user.id}">
                                    <input type="hidden" name="page" value="${param.page}">
                                    <input type="hidden" name="keyword" value="${param.keyword}">

                                    <div class="form-group">
                                        <label class="label">Họ và Tên</label>
                                        <div class="input-wrapper">
                                            <div class="icon-box">
                                                <span class="material-icons">person</span>
                                            </div>
                                            <input type="text" name="name" value="${user.fullName}"
                                                   required class="input-field">
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="label">Địa chỉ Email</label>
                                        <div class="input-wrapper">
                                            <div class="icon-box">
                                                <span class="material-icons">email</span>
                                            </div>
                                            <input type="email" name="email" value="${user.email}"
                                                   required class="input-field">
                                        </div>
                                    </div>
                                                   <div class="grid-passwords">
                                    <%-- Số điện thoại --%>
                                    <div class="form-group">
                                        <label class="label">Số điện thoại</label>
                                        <div class="input-wrapper">
                                            <div class="icon-box">
                                                <span class="material-icons">phone</span>
                                            </div>
                                            <input type="text" name="phone" value="${user.phone}" 
                                                   placeholder="Nhập số điện thoại" class="input-field">
                                        </div>
                                    </div>

                                    <%-- Địa chỉ --%>
                                    <div class="form-group">
                                        <label class="label">Địa chỉ</label>
                                        <div class="input-wrapper">
                                            <div class="icon-box">
                                                <span class="material-icons">location_on</span>
                                            </div>
                                            <input type="text" name="address" value="${user.address}" 
                                                   placeholder="Nhập địa chỉ thường trú" class="input-field">
                                        </div>
                                    </div>
                                                   </div>
                                    <div class="grid-passwords">
                                        <div class="form-group">
                                            <label class="label">Mật khẩu mới</label>
                                            <div class="input-wrapper">
                                                <div class="icon-box">
                                                    <span class="material-icons">lock</span>
                                                </div>
                                                <input type="password" name="password"
                                                       placeholder="Bỏ trống nếu không đổi"
                                                       class="input-field">
                                            </div>
                                        </div>
                                        <div class="form-group">
                                            <label class="label">Xác nhận</label>
                                            <div class="input-wrapper">
                                                <div class="icon-box">
                                                    <span class="material-icons">lock_reset</span>
                                                </div>
                                                <input type="password" name="confirmPassword"
                                                       placeholder="Nhập lại mật khẩu"
                                                       class="input-field">
                                            </div>
                                        </div>
                                    </div>

                                    <div class="form-group">
                                        <label class="label">Vai trò</label>
                                        <div class="input-wrapper">
                                            <div class="icon-box">
                                                <span class="material-icons">badge</span>
                                            </div>
                                            <select name="roleId" class="input-field">
                                                <c:forEach items="${roleList}" var="r">
                                                    <option value="${r.id}" ${user.role.id==r.id
                                                                     ? 'selected' : '' }>
                                                                ${r.name}
                                                            </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                        </div>

                                        <div class="btn-group">
                                            <button type="submit" class="btn-submit">Cập nhật tài
                                                khoản</button>
                                            <a href="${pageContext.request.contextPath}/admin/users?page=${param.page}&keyword=${param.keyword}"
                                               class="btn-cancel">
                                                Hủy
                                            </a>
                                        </div>
                                    </form>
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

            <script>
                setTimeout(() => {
                    const errorBox = document.getElementById('error-box');
                    if (errorBox) {
                        errorBox.style.transition = 'opacity 0.5s ease';
                        errorBox.style.opacity = '0';
                        setTimeout(() => errorBox.remove(), 500);
                    }
                }, 4000);
            </script>
        </body>

    </html>