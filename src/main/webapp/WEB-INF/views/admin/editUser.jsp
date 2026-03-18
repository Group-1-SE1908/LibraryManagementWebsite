<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>LBMS – Chỉnh sửa tài khoản</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
        </head>

        <body class="panel-body">

            <jsp:include page="sidebar.jsp" />

            <main class="panel-main">

                <a href="${pageContext.request.contextPath}/admin/users?page=${param.page}&keyword=${param.keyword}"
                    class="pm-back-link">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>

                <div class="pm-form-card">
                    <%-- Decorative side --%>
                        <div class="pm-form-card-side">
                            <div>
                                <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
                                    <i class="fas fa-pen-to-square" style="font-size:1.75rem;"></i>
                                    <span style="font-size:1.25rem;font-weight:700;">LBMS Admin</span>
                                </div>
                                <p style="opacity:.8;font-size:.875rem;margin:0;">Cập nhật thông tin tài khoản</p>
                            </div>
                            <div>
                                <p class="pm-form-card-side-title">Chỉnh sửa tài khoản người dùng.</p>
                                <p class="pm-form-card-side-sub">"Việc cập nhật thông tin đảm bảo hệ thống thư viện luôn
                                    chính xác và bảo mật."</p>
                                <div class="pm-form-card-side-note">
                                    <i class="fas fa-circle-info"></i>
                                    Để trống ô Reset mật khẩu nếu không muốn thay đổi mật khẩu hiện tại.
                                </div>
                            </div>
                            <div style="font-size:.75rem;opacity:.6;">© 2026 LBMS</div>
                        </div>

                        <%-- Form body --%>
                            <div class="pm-form-card-body">
                                <h2
                                    style="font-size:1.375rem;font-weight:700;margin:0 0 .25rem;color:var(--panel-text);">
                                    Chỉnh sửa tài khoản</h2>
                                <p style="color:var(--panel-text-sub);font-size:.875rem;margin:0 0 1.5rem;">
                                    Đang chỉnh sửa cho: <strong
                                        style="color:var(--panel-accent);">${user.fullName}</strong>
                                </p>

                                <c:if test="${not empty errors}">
                                    <div id="error-box" class="pm-toast pm-toast-danger" style="margin-bottom:1.25rem;">
                                        <div>
                                            <div style="font-weight:700;margin-bottom:4px;"><i
                                                    class="fas fa-circle-exclamation"></i> Có lỗi xảy ra:</div>
                                            <ul style="margin:0;padding-left:1.2rem;font-size:.8125rem;">
                                                <c:forEach items="${errors}" var="err">
                                                    <li>${err}</li>
                                                </c:forEach>
                                            </ul>
                                        </div>
                                    </div>
                                </c:if>

                                <form action="${pageContext.request.contextPath}/admin/users/edit" method="POST">
                                    <input type="hidden" name="id" value="${user.id}">
                                    <input type="hidden" name="page" value="${param.page}">
                                    <input type="hidden" name="keyword" value="${param.keyword}">

                                    <div class="pm-form-group">
                                        <label class="pm-label">Họ và tên</label>
                                        <div class="pm-input-group">
                                            <i class="fas fa-user pm-input-icon"></i>
                                            <input type="text" name="name" value="${user.fullName}" required
                                                class="pm-input" />
                                        </div>
                                    </div>

                                    <div class="pm-form-group">
                                        <label class="pm-label">Địa chỉ Email</label>
                                        <div class="pm-input-group">
                                            <i class="fas fa-envelope pm-input-icon"></i>
                                            <input type="email" name="email" value="${user.email}" required
                                                class="pm-input" />
                                        </div>
                                    </div>

                                    <div class="pm-form-row">
                                        <div class="pm-form-group">
                                            <label class="pm-label">Số điện thoại</label>
                                            <div class="pm-input-group">
                                                <i class="fas fa-phone pm-input-icon"></i>
                                                <input type="text" name="phone" value="${user.phone}" class="pm-input"
                                                    placeholder="Nhập số điện thoại" />
                                            </div>
                                        </div>
                                        <div class="pm-form-group">
                                            <label class="pm-label">Địa chỉ</label>
                                            <div class="pm-input-group">
                                                <i class="fas fa-location-dot pm-input-icon"></i>
                                                <input type="text" name="address" value="${user.address}"
                                                    class="pm-input" placeholder="Nhập địa chỉ thường trú" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="pm-form-group">
                                        <label class="pm-label">Mật khẩu</label>
                                        <label
                                            style="display:flex;align-items:center;gap:8px;font-size:.875rem;cursor:pointer;">
                                            <input type="checkbox" name="resetPassword" value="true">
                                            <span>Reset mật khẩu cho người dùng này</span>
                                        </label>
                                        <small style="color:var(--panel-text-sub);font-size:.78rem;">
                                            Nếu chọn, hệ thống sẽ tự tạo mật khẩu mới và gửi qua email.
                                        </small>
                                    </div>

                                    <div class="pm-form-group">
                                        <label class="pm-label">Vai trò</label>
                                        <div class="pm-input-group">
                                            <i class="fas fa-id-badge pm-input-icon"></i>
                                            <select name="roleId" class="pm-select"
                                                style="padding-left:38px;width:100%;">
                                                <c:forEach items="${roleList}" var="r">
                                                    <option value="${r.id}" ${user.role.id==r.id ? 'selected' : '' }>
                                                        ${r.name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div style="display:flex;gap:10px;margin-top:1.25rem;flex-wrap:wrap;">
                                        <button type="submit" class="pm-btn pm-btn-primary"
                                            style="flex:1;justify-content:center;">
                                            <i class="fas fa-floppy-disk"></i> Cập nhật tài khoản
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/users?page=${param.page}&keyword=${param.keyword}"
                                            class="pm-btn pm-btn-outline" style="flex:1;justify-content:center;">Hủy</a>
                                    </div>
                                </form>

                                <div
                                    style="margin-top:2rem;padding-top:1rem;border-top:1px solid var(--panel-border);display:flex;justify-content:space-between;font-size:.8rem;color:var(--panel-text-sub);">
                                    <span>© 2026 Library Management System (LBMS)</span>
                                    <span>Version 1.0.0</span>
                                </div>
                            </div>
                </div>

            </main>

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