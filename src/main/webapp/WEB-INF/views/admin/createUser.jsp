<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>LBMS – Thêm người dùng mới</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet" />
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
        </head>

        <body class="panel-body">

            <jsp:include page="sidebar.jsp" />

            <main class="panel-main">
                <a href="${pageContext.request.contextPath}/admin/users" class="pm-back-link">
                    <i class="fas fa-arrow-left"></i> Quay lại danh sách
                </a>

                <div class="pm-form-card">
                    <%-- Decorative side (Giữ nguyên phần trang trí của bạn) --%>
                        <div class="pm-form-card-side">
                            <div>
                                <div style="display:flex;align-items:center;gap:10px;margin-bottom:10px;">
                                    <i class="fas fa-book-open" style="font-size:1.75rem;"></i>
                                    <span style="font-size:1.25rem;font-weight:700;">LBMS Admin</span>
                                </div>
                                <p style="opacity:.8;font-size:.875rem;margin:0;">Hệ thống quản lý người dùng</p>
                            </div>
                            <div>
                                <p class="pm-form-card-side-title">Thêm thành viên mới cho thư viện.</p>
                                <p class="pm-form-card-side-sub">Vui lòng đảm bảo thông tin chính xác. Tài khoản mới sẽ
                                    mặc định ở trạng thái HOẠT ĐỘNG.</p>
                                <div class="pm-form-card-side-note">
                                    <i class="fas fa-circle-info"></i>
                                    Mật khẩu sẽ được hệ thống tạo ngẫu nhiên và gửi qua email người dùng.
                                </div>
                            </div>
                            <div style="font-size:.75rem;opacity:.6;">© 2026 LBMS</div>
                        </div>

                        <%-- Form body với Class mới --%>
                            <div class="pm-form-card-body">
                                <h2
                                    style="font-size:1.375rem;font-weight:700;margin:0 0 .5rem;color:var(--panel-text);">
                                    Đăng ký người dùng</h2>
                                <p style="color:var(--panel-text-sub);font-size:.875rem;margin:0 0 1.5rem;">Điền đầy đủ
                                    thông tin bên dưới để tạo tài khoản.</p>

                                <c:if test="${not empty errors}">
                                    <div id="error-box" class="pm-toast pm-toast-danger" style="margin-bottom:1.25rem;">
                                        <div style="font-weight:700;margin-bottom:4px;"><i
                                                class="fas fa-circle-exclamation"></i> Có lỗi xảy ra:</div>
                                        <ul style="margin:0;padding-left:1.2rem;font-size:.8125rem;">
                                            <c:forEach items="${errors}" var="err">
                                                <li>${err}</li>
                                            </c:forEach>
                                        </ul>
                                    </div>
                                </c:if>

                                <form action="${pageContext.request.contextPath}/admin/users/create" method="POST">

                                    <div class="lbm-group">
                                        <label class="pm-label">Họ và tên</label>
                                        <div class="lbm-input-wrapper">
                                            <i class="fas fa-user lbm-icon"></i>
                                            <input type="text" name="name" value="${param.name}" class="lbm-input"
                                                placeholder="Nhập tên đầy đủ" required />
                                        </div>
                                    </div>

                                    <div class="lbm-group">
                                        <label class="pm-label">Email</label>
                                        <div class="lbm-input-wrapper">
                                            <i class="fas fa-envelope lbm-icon"></i>
                                            <input type="email" name="email" value="${param.email}" class="lbm-input"
                                                placeholder="email@example.com" required />
                                        </div>
                                    </div>

                                    <div class="lbm-row">
                                        <div class="lbm-col">
                                            <label class="pm-label">Số điện thoại</label>
                                            <div class="lbm-input-wrapper">
                                                <i class="fas fa-phone lbm-icon"></i>
                                                <input type="text" name="phone" value="${param.phone}" class="lbm-input"
                                                    placeholder="09xx xxx xxx" />
                                            </div>
                                        </div>
                                        <div class="lbm-col">
                                            <label class="pm-label">Địa chỉ</label>
                                            <div class="lbm-input-wrapper">
                                                <i class="fas fa-location-dot lbm-icon"></i>
                                                <input type="text" name="address" value="${param.address}"
                                                    class="lbm-input" placeholder="Số nhà, tên đường..." />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="lbm-group">
                                        <label class="pm-label">Mật khẩu</label>
                                        <div class="lbm-info-box">
                                            <i class="fas fa-circle-info"></i>
                                            <span>Mật khẩu sẽ được <strong>hệ thống tạo ngẫu nhiên</strong> và gửi đến
                                                email.</span>
                                        </div>
                                    </div>

                                    <div class="lbm-group">
                                        <label class="pm-label">Vai trò</label>
                                        <div class="lbm-input-wrapper">
                                            <i class="fas fa-id-badge lbm-icon"></i>
                                            <select name="roleId" required class="lbm-select">
                                                <c:forEach items="${roleList}" var="r">
                                                    <option value="${r.id}" ${param.roleId==r.id ? 'selected' : '' }>
                                                        ${r.name}</option>
                                                </c:forEach>
                                            </select>
                                        </div>
                                    </div>

                                    <div class="lbm-actions">
                                        <button type="submit" class="pm-btn pm-btn-primary lbm-btn-wide">
                                            <i class="fas fa-floppy-disk"></i> Lưu người dùng
                                        </button>
                                        <a href="${pageContext.request.contextPath}/admin/users"
                                            class="pm-btn pm-btn-outline lbm-btn-wide">Hủy</a>
                                    </div>
                                </form>
                            </div>
                </div>
            </main>

            <script>
                document.addEventListener('DOMContentLoaded', () => {
                    const errorBox = document.getElementById('error-box');
                    if (errorBox) {
                        setTimeout(() => {
                            errorBox.style.transition = 'opacity .5s';
                            errorBox.style.opacity = '0';
                            setTimeout(() => errorBox.remove(), 500);
                        }, 5000);
                    }
                });
            </script>
        </body>

        </html>