<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Hồ Sơ - LBMS</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

                    <style>
                        *,
                        *::before,
                        *::after {
                            box-sizing: border-box;
                        }

                        body {
                            background: linear-gradient(135deg, #eef2ff 0%, #f8faff 100%);
                            min-height: 100vh;
                            margin: 0;
                            font-family: 'Segoe UI', system-ui, sans-serif;
                        }

                        /* ── Layout ── */
                        .prof-page {
                            max-width: 1140px;
                            margin: 0 auto;
                            padding: 36px 20px 64px;
                            display: grid;
                            grid-template-columns: 260px 1fr;
                            gap: 28px;
                            align-items: start;
                        }

                        @media (max-width: 768px) {
                            .prof-page {
                                grid-template-columns: 1fr;
                                padding: 16px;
                            }
                        }

                        /* ── Sidebar ── */
                        .prof-sidebar {
                            background: #ffffff;
                            border-radius: 20px;
                            box-shadow: 0 4px 30px rgba(37, 99, 235, 0.08);
                            overflow: hidden;
                            position: sticky;
                            top: 84px;
                        }

                        .prof-avatar-section {
                            padding: 32px 24px 24px;
                            background: linear-gradient(160deg, #2563eb 0%, #818cf8 100%);
                            display: flex;
                            flex-direction: column;
                            align-items: center;
                            gap: 12px;
                            text-align: center;
                        }

                        .prof-avatar-wrap {
                            position: relative;
                            width: 96px;
                            height: 96px;
                            cursor: pointer;
                        }

                        .prof-avatar-wrap img,
                        .prof-avatar-initial {
                            width: 96px;
                            height: 96px;
                            border-radius: 50%;
                            border: 3px solid rgba(255, 255, 255, 0.6);
                            object-fit: cover;
                            transition: 0.3s;
                        }

                        .prof-avatar-initial {
                            background: rgba(255, 255, 255, 0.25);
                            color: #fff;
                            font-weight: 700;
                            font-size: 36px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                        }

                        .prof-avatar-overlay {
                            position: absolute;
                            inset: 0;
                            border-radius: 50%;
                            background: rgba(0, 0, 0, 0.35);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            opacity: 0;
                            transition: 0.25s;
                            color: #fff;
                            font-size: 20px;
                        }

                        .prof-avatar-wrap:hover .prof-avatar-overlay {
                            opacity: 1;
                        }

                        .prof-user-name {
                            color: #fff;
                            font-size: 1rem;
                            font-weight: 700;
                            line-height: 1.3;
                            word-break: break-word;
                        }

                        .prof-user-email {
                            color: rgba(255, 255, 255, 0.75);
                            font-size: 12px;
                        }

                        .prof-badges {
                            display: flex;
                            gap: 6px;
                            flex-wrap: wrap;
                            justify-content: center;
                            margin-top: 4px;
                        }

                        .prof-badge {
                            display: inline-block;
                            padding: 3px 11px;
                            border-radius: 999px;
                            font-size: 11px;
                            font-weight: 600;
                            letter-spacing: .03em;
                        }

                        .badge-member {
                            background: rgba(59, 130, 246, 0.35);
                            color: #dbeafe;
                        }

                        .badge-librarian {
                            background: rgba(34, 197, 94, 0.35);
                            color: #dcfce7;
                        }

                        .badge-admin {
                            background: rgba(139, 92, 246, 0.35);
                            color: #ede9fe;
                        }

                        .badge-active {
                            background: rgba(22, 163, 74, 0.35);
                            color: #dcfce7;
                        }

                        .badge-inactive {
                            background: rgba(156, 163, 175, 0.35);
                            color: #e5e7eb;
                        }

                        /* ── Sidebar Nav ── */
                        .prof-nav {
                            padding: 12px 0 16px;
                        }

                        .prof-nav-item {
                            display: flex;
                            align-items: center;
                            gap: 12px;
                            padding: 13px 24px;
                            cursor: pointer;
                            color: #64748b;
                            font-size: 14px;
                            font-weight: 500;
                            border-left: 3px solid transparent;
                            transition: 0.2s;
                            text-decoration: none;
                        }

                        .prof-nav-item i {
                            font-size: 16px;
                        }

                        .prof-nav-item:hover {
                            background: #f0f4ff;
                            color: #2563eb;
                        }

                        .prof-nav-item.active {
                            background: #eef2ff;
                            color: #2563eb;
                            border-left-color: #2563eb;
                            font-weight: 600;
                        }

                        /* ── Content Card ── */
                        .prof-content {
                            background: #ffffff;
                            border-radius: 20px;
                            box-shadow: 0 4px 30px rgba(37, 99, 235, 0.08);
                            overflow: hidden;
                        }

                        .prof-panel {
                            display: none;
                        }

                        .prof-panel.active {
                            display: block;
                        }

                        .prof-panel-header {
                            padding: 28px 32px 0;
                        }

                        .prof-panel-title {
                            font-size: 1.2rem;
                            font-weight: 700;
                            color: #1e293b;
                            margin-bottom: 4px;
                        }

                        .prof-panel-subtitle {
                            font-size: 13px;
                            color: #94a3b8;
                            margin-bottom: 24px;
                        }

                        .prof-divider {
                            height: 1px;
                            background: #eef1ff;
                            margin: 0 32px 28px;
                        }

                        .prof-panel-body {
                            padding: 0 32px 36px;
                        }

                        @media (max-width: 768px) {
                            .prof-panel-header {
                                padding: 20px 20px 0;
                            }

                            .prof-panel-body {
                                padding: 0 20px 28px;
                            }

                            .prof-divider {
                                margin-left: 20px;
                                margin-right: 20px;
                            }
                        }

                        /* ── Flash ── */
                        .prof-flash {
                            margin: 0 32px 20px;
                            padding: 12px 16px;
                            border-radius: 10px;
                            font-size: 14px;
                            font-weight: 500;
                        }

                        .prof-flash.success {
                            background: #e6f4ea;
                            color: #1e7e34;
                        }

                        .prof-flash.error {
                            background: #fdecea;
                            color: #b02a37;
                        }

                        /* ── Form ── */
                        .prof-field-grid {
                            display: grid;
                            grid-template-columns: 1fr 1fr;
                            gap: 0 20px;
                        }

                        @media (max-width: 560px) {
                            .prof-field-grid {
                                grid-template-columns: 1fr;
                            }
                        }

                        .prof-field-full {
                            grid-column: 1 / -1;
                        }

                        .prof-field {
                            display: flex;
                            flex-direction: column;
                            margin-bottom: 20px;
                        }

                        .prof-field label {
                            font-size: 12px;
                            font-weight: 600;
                            color: #64748b;
                            letter-spacing: .04em;
                            text-transform: uppercase;
                            margin-bottom: 7px;
                        }

                        .prof-field input,
                        .prof-field select {
                            padding: 11px 14px;
                            border-radius: 10px;
                            border: 1.5px solid #e2e8f0;
                            font-size: 14px;
                            color: #1e293b;
                            background: #fff;
                            transition: 0.2s;
                            outline: none;
                        }

                        .prof-field input:focus,
                        .prof-field select:focus {
                            border-color: #2563eb;
                            box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.12);
                        }

                        .prof-field input:read-only {
                            background: #f8faff;
                            color: #94a3b8;
                            cursor: not-allowed;
                        }

                        .prof-field input.field-error {
                            border-color: #dc3545;
                            background: #fff5f5;
                        }

                        .prof-field-hint {
                            font-size: 12px;
                            color: #ef4444;
                            margin-top: 5px;
                        }

                        .prof-info-row {
                            display: flex;
                            gap: 10px;
                            margin-bottom: 24px;
                            flex-wrap: wrap;
                        }

                        .prof-info-chip {
                            display: inline-flex;
                            align-items: center;
                            gap: 6px;
                            padding: 5px 13px;
                            border-radius: 999px;
                            font-size: 12.5px;
                            font-weight: 600;
                        }

                        .chip-member {
                            background: #dbeafe;
                            color: #1d4ed8;
                        }

                        .chip-librarian {
                            background: #dcfce7;
                            color: #15803d;
                        }

                        .chip-admin {
                            background: #ede9fe;
                            color: #7c3aed;
                        }

                        .chip-active {
                            background: #dcfce7;
                            color: #15803d;
                        }

                        .chip-inactive {
                            background: #f1f5f9;
                            color: #64748b;
                        }

                        .prof-save-btn {
                            display: inline-flex;
                            align-items: center;
                            gap: 8px;
                            padding: 11px 28px;
                            background: linear-gradient(135deg, #2563eb, #818cf8);
                            color: #fff;
                            border: none;
                            border-radius: 10px;
                            font-size: 14px;
                            font-weight: 600;
                            cursor: pointer;
                            transition: 0.25s;
                        }

                        .prof-save-btn:hover {
                            opacity: 0.9;
                            transform: translateY(-1px);
                            box-shadow: 0 6px 20px rgba(37, 99, 235, 0.3);
                        }

                        /* ── History sub-tabs ── */
                        .hist-tabs {
                            display: flex;
                            gap: 0;
                            border-bottom: 2px solid #eef1ff;
                            margin-bottom: 24px;
                        }

                        .hist-tab {
                            padding: 10px 20px;
                            font-size: 13.5px;
                            font-weight: 500;
                            color: #64748b;
                            cursor: pointer;
                            border-bottom: 2px solid transparent;
                            margin-bottom: -2px;
                            transition: 0.2s;
                            display: flex;
                            align-items: center;
                            gap: 7px;
                        }

                        .hist-tab:hover {
                            color: #2563eb;
                        }

                        .hist-tab.active {
                            color: #2563eb;
                            border-bottom-color: #2563eb;
                            font-weight: 600;
                        }

                        .hist-panel {
                            display: none;
                        }

                        .hist-panel.active {
                            display: block;
                        }

                        /* ── Wallet Transaction List ── */
                        .wtx-list {
                            list-style: none;
                            padding: 0;
                            margin: 0;
                        }

                        .wtx-item {
                            display: flex;
                            align-items: center;
                            gap: 14px;
                            padding: 14px 0;
                            border-bottom: 1px solid #f0f4ff;
                        }

                        .wtx-item:last-child {
                            border-bottom: none;
                        }

                        .wtx-icon {
                            width: 42px;
                            height: 42px;
                            border-radius: 12px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 18px;
                            flex-shrink: 0;
                        }

                        .wtx-icon-credit {
                            background: #dcfce7;
                        }

                        .wtx-icon-debit {
                            background: #fee2e2;
                        }

                        .wtx-body {
                            flex: 1;
                            min-width: 0;
                        }

                        .wtx-title {
                            font-size: 14px;
                            font-weight: 600;
                            color: #1e293b;
                        }

                        .wtx-desc {
                            font-size: 12px;
                            color: #94a3b8;
                            margin-top: 2px;
                            white-space: nowrap;
                            overflow: hidden;
                            text-overflow: ellipsis;
                        }

                        .wtx-meta {
                            text-align: right;
                            flex-shrink: 0;
                        }

                        .wtx-amount {
                            font-size: 14px;
                            font-weight: 700;
                        }

                        .wtx-amount-credit {
                            color: #16a34a;
                        }

                        .wtx-amount-debit {
                            color: #dc2626;
                        }

                        .wtx-date {
                            font-size: 11px;
                            color: #94a3b8;
                            margin-top: 2px;
                        }

                        /* ── Payment History Table ── */
                        .ph-table {
                            width: 100%;
                            border-collapse: collapse;
                            font-size: 13.5px;
                        }

                        .ph-table th {
                            background: #f8faff;
                            padding: 10px 14px;
                            text-align: left;
                            font-size: 11px;
                            font-weight: 700;
                            color: #94a3b8;
                            border-bottom: 2px solid #eef1ff;
                            text-transform: uppercase;
                            letter-spacing: .06em;
                        }

                        .ph-table td {
                            padding: 12px 14px;
                            border-bottom: 1px solid #f0f4ff;
                            vertical-align: middle;
                            color: #374151;
                        }

                        .ph-table tr:last-child td {
                            border-bottom: none;
                        }

                        .ph-table tr:hover td {
                            background: #fafbff;
                        }

                        .ph-badge {
                            display: inline-block;
                            padding: 3px 10px;
                            border-radius: 999px;
                            font-size: 11.5px;
                            font-weight: 600;
                        }

                        .ph-badge-success {
                            background: #d1fae5;
                            color: #065f46;
                        }

                        .ph-badge-failed {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        .ph-method-wallet {
                            color: #16a34a;
                            font-weight: 700;
                        }

                        .ph-method-vnpay {
                            color: #1d4ed8;
                            font-weight: 700;
                        }

                        .ph-amount {
                            font-weight: 700;
                            color: #dc2626;
                            white-space: nowrap;
                        }

                        .ph-empty,
                        .wtx-empty {
                            text-align: center;
                            padding: 48px 0;
                            color: #94a3b8;
                            font-size: 14px;
                        }

                        .ph-empty i,
                        .wtx-empty i {
                            font-size: 40px;
                            display: block;
                            margin-bottom: 12px;
                            opacity: 0.4;
                        }
                    </style>
                </head>

                <body>
                    <c:set var="userInitial" value="${fn:substring(user.fullName, 0, 1)}" />

                    <jsp:include page="header.jsp" />

                    <div class="prof-page">

                        <%--=====================SIDEBAR=====================--%>
                            <aside class="prof-sidebar">
                                <div class="prof-avatar-section">
                                    <form id="avatarForm" method="post"
                                        action="${pageContext.request.contextPath}/upload-avatar"
                                        enctype="multipart/form-data">
                                        <div class="prof-avatar-wrap"
                                            onclick="document.getElementById('avatarUpload').click();"
                                            title="Bấm để đổi ảnh đại diện">
                                            <c:choose>
                                                <c:when test="${not empty user.avatar && user.avatar != 'null'}">
                                                    <img src="${pageContext.request.contextPath}/${user.avatar}?v=${timestamp}"
                                                        id="previewAvatar"
                                                        onerror="this.style.display='none'; document.getElementById('sidebarInitial').style.display='flex';">
                                                    <div class="prof-avatar-initial" id="sidebarInitial"
                                                        style="display:none;">${userInitial}</div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="prof-avatar-initial" id="sidebarInitial">${userInitial}
                                                    </div>
                                                </c:otherwise>
                                            </c:choose>
                                            <div class="prof-avatar-overlay"><i class="bi bi-camera-fill"></i></div>
                                        </div>
                                        <input type="file" id="avatarUpload" name="avatar" accept="image/*" hidden
                                            onchange="previewSidebarAvatar(event); document.getElementById('avatarForm').submit();">
                                    </form>
                                    <div class="prof-user-name">${user.fullName}</div>
                                    <div class="prof-user-email">${user.email}</div>
                                    <div class="prof-badges">
                                        <span class="prof-badge
                    <c:choose>
                        <c:when test=" ${user.role.name eq 'MEMBER' }">badge-member</c:when>
                                            <c:when test="${user.role.name eq 'LIBRARIAN'}">badge-librarian</c:when>
                                            <c:when test="${user.role.name eq 'ADMIN'}">badge-admin</c:when>
                                            </c:choose>">
                                            <c:choose>
                                                <c:when test="${user.role.name eq 'MEMBER'}">Thành viên</c:when>
                                                <c:when test="${user.role.name eq 'LIBRARIAN'}">Thủ thư</c:when>
                                                <c:when test="${user.role.name eq 'ADMIN'}">Quản trị viên</c:when>
                                                <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </span>
                                        <span
                                            class="prof-badge ${user.status eq 'ACTIVE' ? 'badge-active' : 'badge-inactive'}">
                                            ${user.status eq 'ACTIVE' ? 'Hoạt động' : 'Không hoạt động'}
                                        </span>
                                    </div>
                                </div>

                                <nav class="prof-nav">
                                    <a class="prof-nav-item active" data-tab="info" href="#info">
                                        <i class="bi bi-person-fill"></i> Thông Tin Cá Nhân
                                    </a>
                                    <a class="prof-nav-item" data-tab="password" href="#password">
                                        <i class="bi bi-shield-lock-fill"></i> Đổi Mật Khẩu
                                    </a>
                                    <a class="prof-nav-item" data-tab="history" href="#history">
                                        <i class="bi bi-clock-history"></i> Lịch Sử Thanh Toán
                                    </a>
                                </nav>
                            </aside>

                            <%--=====================CONTENT=====================--%>
                                <main class="prof-content">

                                    <%-- Flash --%>
                                        <c:if test="${not empty flash}">
                                            <div class="prof-flash ${flashType}" id="flashMessage"
                                                style="margin-top: 28px;">
                                                <i
                                                    class="bi ${flashType eq 'success' ? 'bi-check-circle-fill' : 'bi-exclamation-triangle-fill'}"></i>
                                                ${flash}
                                            </div>
                                        </c:if>

                                        <%--======PANEL: Thông Tin Cá Nhân======--%>
                                            <div class="prof-panel active" id="tab-info">
                                                <div class="prof-panel-header">
                                                    <div class="prof-panel-title">Thông Tin Cá Nhân</div>
                                                    <div class="prof-panel-subtitle">Cập nhật thông tin hồ sơ của bạn
                                                    </div>
                                                </div>
                                                <div class="prof-divider"></div>
                                                <div class="prof-panel-body">
                                                    <form method="post"
                                                        action="${pageContext.request.contextPath}/profile"
                                                        id="profileForm">
                                                        <div class="prof-field-grid">
                                                            <div class="prof-field">
                                                                <label>Họ và tên</label>
                                                                <input type="text" name="fullName"
                                                                    value="${user.fullName}" maxlength="100" required>
                                                            </div>
                                                            <div class="prof-field">
                                                                <label>Số điện thoại</label>
                                                                <input type="text" name="phone" id="phoneInput"
                                                                    value="${user.phone}" pattern="[0-9]{10}"
                                                                    placeholder="Nhập 10 chữ số" required>
                                                                <span class="prof-field-hint" id="phoneError"
                                                                    style="display:none;"></span>
                                                            </div>
                                                            <div class="prof-field prof-field-full">
                                                                <label>Email</label>
                                                                <input type="email" value="${user.email}" readonly>
                                                            </div>
                                                            <div class="prof-field prof-field-full">
                                                                <label>Địa chỉ (Số nhà / Đường)</label>
                                                                <input type="text" name="address"
                                                                    value="${user.address}" maxlength="200"
                                                                    placeholder="Ví dụ: 118/2/14 Lê Văn Thọ">
                                                            </div>
                                                            <div class="prof-field">
                                                                <label>Tỉnh / Thành phố</label>
                                                                <select id="profileCity">
                                                                    <option value="">Chọn tỉnh/thành</option>
                                                                </select>
                                                                <input type="hidden" name="city" id="hiddenCity"
                                                                    value="${user.city}">
                                                            </div>
                                                            <div class="prof-field">
                                                                <label>Quận / Huyện</label>
                                                                <select id="profileDistrict">
                                                                    <option value="">Chọn quận/huyện</option>
                                                                </select>
                                                                <input type="hidden" name="district" id="hiddenDistrict"
                                                                    value="${user.district}">
                                                            </div>
                                                            <div class="prof-field">
                                                                <label>Phường / Xã</label>
                                                                <select id="profileWard">
                                                                    <option value="">Chọn phường/xã</option>
                                                                </select>
                                                                <input type="hidden" name="ward" id="hiddenWard"
                                                                    value="${user.ward}">
                                                            </div>
                                                        </div>

                                                        <div class="prof-info-row">
                                                            <span class="prof-info-chip
                            <c:choose>
                                <c:when test=" ${user.role.name eq 'MEMBER' }">chip-member</c:when>
                                                                <c:when test="${user.role.name eq 'LIBRARIAN'}">
                                                                    chip-librarian</c:when>
                                                                <c:when test="${user.role.name eq 'ADMIN'}">chip-admin
                                                                </c:when>
                                                                </c:choose>">
                                                                <i class="bi bi-person-badge-fill"></i>
                                                                <c:choose>
                                                                    <c:when test="${user.role.name eq 'MEMBER'}">Thành
                                                                        viên</c:when>
                                                                    <c:when test="${user.role.name eq 'LIBRARIAN'}">Thủ
                                                                        thư</c:when>
                                                                    <c:when test="${user.role.name eq 'ADMIN'}">Quản trị
                                                                        viên</c:when>
                                                                    <c:otherwise>Không xác định</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                            <span
                                                                class="prof-info-chip ${user.status eq 'ACTIVE' ? 'chip-active' : 'chip-inactive'}">
                                                                <i
                                                                    class="bi ${user.status eq 'ACTIVE' ? 'bi-circle-fill' : 'bi-circle'}"></i>
                                                                ${user.status eq 'ACTIVE' ? 'Đang hoạt động' : 'Không
                                                                hoạt động'}
                                                            </span>
                                                        </div>

                                                        <button type="submit" class="prof-save-btn">
                                                            <i class="bi bi-check2"></i> Lưu thay đổi
                                                        </button>
                                                    </form>
                                                </div>
                                            </div>

                                            <%--======PANEL: Đổi Mật Khẩu======--%>
                                                <div class="prof-panel" id="tab-password">
                                                    <div class="prof-panel-header">
                                                        <div class="prof-panel-title">Đổi Mật Khẩu</div>
                                                        <div class="prof-panel-subtitle">Đảm bảo tài khoản của bạn được
                                                            bảo mật</div>
                                                    </div>
                                                    <div class="prof-divider"></div>
                                                    <div class="prof-panel-body">
                                                        <form method="post"
                                                            action="${pageContext.request.contextPath}/change-password"
                                                            style="max-width: 420px;">
                                                            <div class="prof-field">
                                                                <label>Mật khẩu hiện tại</label>
                                                                <input type="password" name="oldPassword" required>
                                                            </div>
                                                            <div class="prof-field">
                                                                <label>Mật khẩu mới</label>
                                                                <input type="password" name="newPassword" minlength="6"
                                                                    required>
                                                            </div>
                                                            <div class="prof-field">
                                                                <label>Xác nhận mật khẩu mới</label>
                                                                <input type="password" name="confirm" minlength="6"
                                                                    required>
                                                            </div>
                                                            <button type="submit" class="prof-save-btn"
                                                                style="margin-top: 8px;">
                                                                <i class="bi bi-lock-fill"></i> Thay đổi mật khẩu
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>

                                                <%--======PANEL: Lịch Sử Thanh Toán======--%>
                                                    <div class="prof-panel" id="tab-history">
                                                        <div class="prof-panel-header">
                                                            <div class="prof-panel-title">Lịch Sử Thanh Toán</div>
                                                            <div class="prof-panel-subtitle">Tổng hợp các giao dịch và
                                                                thanh toán của bạn</div>
                                                        </div>
                                                        <div class="prof-divider"></div>
                                                        <div class="prof-panel-body">
                                                            <%-- SUB TABS --%>
                                                                <div class="hist-tabs">
                                                                    <div class="hist-tab active" data-hist="wallet">
                                                                        <i class="bi bi-wallet2"></i> Giao dịch ví
                                                                    </div>
                                                                    <div class="hist-tab" data-hist="payment">
                                                                        <i class="bi bi-receipt"></i> Thanh toán đơn
                                                                        hàng
                                                                    </div>
                                                                </div>

                                                                <%-- WALLET HISTORY --%>
                                                                    <div class="hist-panel active" id="hist-wallet">
                                                                        <c:choose>
                                                                            <c:when test="${not empty walletHistory}">
                                                                                <ul class="wtx-list">
                                                                                    <c:forEach var="entry"
                                                                                        items="${walletHistory}">
                                                                                        <li class="wtx-item">
                                                                                            <div
                                                                                                class="wtx-icon ${entry.credit ? 'wtx-icon-credit' : 'wtx-icon-debit'}">
                                                                                                <c:choose>
                                                                                                    <c:when
                                                                                                        test="${entry.credit}">
                                                                                                        💰</c:when>
                                                                                                    <c:otherwise>💳
                                                                                                    </c:otherwise>
                                                                                                </c:choose>
                                                                                            </div>
                                                                                            <div class="wtx-body">
                                                                                                <div class="wtx-title">
                                                                                                    <c:choose>
                                                                                                        <c:when
                                                                                                            test="${entry.type == 'TOPUP'}">
                                                                                                            Nạp tiền vào
                                                                                                            ví
                                                                                                            <c:if
                                                                                                                test="${not empty entry.source}">
                                                                                                                (${entry.source})
                                                                                                            </c:if>
                                                                                                        </c:when>
                                                                                                        <c:otherwise>
                                                                                                            Giao dịch ví
                                                                                                        </c:otherwise>
                                                                                                    </c:choose>
                                                                                                </div>
                                                                                                <div class="wtx-desc">
                                                                                                    <c:choose>
                                                                                                        <c:when
                                                                                                            test="${not empty entry.description}">
                                                                                                            ${entry.description}
                                                                                                        </c:when>
                                                                                                        <c:otherwise>
                                                                                                            <c:if
                                                                                                                test="${not empty entry.reference}">
                                                                                                                Mã GD:
                                                                                                                ${entry.reference}
                                                                                                            </c:if>
                                                                                                        </c:otherwise>
                                                                                                    </c:choose>
                                                                                                </div>
                                                                                            </div>
                                                                                            <div class="wtx-meta">
                                                                                                <div
                                                                                                    class="wtx-amount ${entry.credit ? 'wtx-amount-credit' : 'wtx-amount-debit'}">
                                                                                                    ${entry.credit ? '+'
                                                                                                    : '-'}
                                                                                                    <fmt:formatNumber
                                                                                                        value="${entry.amount}"
                                                                                                        pattern="#,##0" />
                                                                                                    ₫
                                                                                                </div>
                                                                                                <div class="wtx-date">
                                                                                                    <fmt:formatDate
                                                                                                        value="${entry.createdAt}"
                                                                                                        pattern="dd/MM/yyyy HH:mm" />
                                                                                                </div>
                                                                                            </div>
                                                                                        </li>
                                                                                    </c:forEach>
                                                                                </ul>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <div class="wtx-empty">
                                                                                    <i class="bi bi-wallet2"></i>
                                                                                    <p>Chưa có giao dịch ví nào.</p>
                                                                                </div>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>

                                                                    <%-- PAYMENT HISTORY --%>
                                                                        <div class="hist-panel" id="hist-payment">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${not empty paymentHistory}">
                                                                                    <div style="overflow-x:auto;">
                                                                                        <table class="ph-table">
                                                                                            <thead>
                                                                                                <tr>
                                                                                                    <th>Thời gian</th>
                                                                                                    <th>Loại</th>
                                                                                                    <th>Phương thức</th>
                                                                                                    <th>Mô tả</th>
                                                                                                    <th>Số tiền</th>
                                                                                                    <th>Trạng thái</th>
                                                                                                </tr>
                                                                                            </thead>
                                                                                            <tbody>
                                                                                                <c:forEach var="ph"
                                                                                                    items="${paymentHistory}">
                                                                                                    <tr>
                                                                                                        <td
                                                                                                            style="white-space:nowrap;color:#94a3b8;font-size:12px;">
                                                                                                            <fmt:formatDate
                                                                                                                value="${ph.createdAt}"
                                                                                                                pattern="dd/MM/yyyy HH:mm" />
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <c:choose>
                                                                                                                <c:when
                                                                                                                    test="${ph.paymentType == 'BOOK_DEPOSIT'}">
                                                                                                                    🛒
                                                                                                                    Đặt
                                                                                                                    cọc
                                                                                                                    sách
                                                                                                                </c:when>
                                                                                                                <c:when
                                                                                                                    test="${ph.paymentType == 'FINE'}">
                                                                                                                    ⚠️
                                                                                                                    Phí
                                                                                                                    phạt
                                                                                                                </c:when>
                                                                                                                <c:when
                                                                                                                    test="${ph.paymentType == 'BOOK_RETURN'}">
                                                                                                                    📚
                                                                                                                    Trả
                                                                                                                    sách
                                                                                                                </c:when>
                                                                                                                <c:otherwise>
                                                                                                                    ${ph.paymentType}
                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <c:choose>
                                                                                                                <c:when
                                                                                                                    test="${ph.paymentMethod == 'WALLET'}">
                                                                                                                    <span
                                                                                                                        class="ph-method-wallet">💰
                                                                                                                        Ví</span>
                                                                                                                </c:when>
                                                                                                                <c:otherwise>
                                                                                                                    <span
                                                                                                                        class="ph-method-vnpay">💳
                                                                                                                        VNPay</span>
                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </td>
                                                                                                        <td
                                                                                                            style="max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                                                                                                            <c:choose>
                                                                                                                <c:when
                                                                                                                    test="${not empty ph.description}">
                                                                                                                    ${ph.description}
                                                                                                                </c:when>
                                                                                                                <c:otherwise>
                                                                                                                    —
                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </td>
                                                                                                        <td
                                                                                                            class="ph-amount">
                                                                                                            <fmt:formatNumber
                                                                                                                value="${ph.amount}"
                                                                                                                pattern="#,##0" />
                                                                                                            ₫
                                                                                                        </td>
                                                                                                        <td>
                                                                                                            <c:choose>
                                                                                                                <c:when
                                                                                                                    test="${ph.status == 'SUCCESS'}">
                                                                                                                    <span
                                                                                                                        class="ph-badge ph-badge-success">Thành
                                                                                                                        công</span>
                                                                                                                </c:when>
                                                                                                                <c:otherwise>
                                                                                                                    <span
                                                                                                                        class="ph-badge ph-badge-failed">Thất
                                                                                                                        bại</span>
                                                                                                                </c:otherwise>
                                                                                                            </c:choose>
                                                                                                        </td>
                                                                                                    </tr>
                                                                                                </c:forEach>
                                                                                            </tbody>
                                                                                        </table>
                                                                                    </div>
                                                                                </c:when>
                                                                                <c:otherwise>
                                                                                    <div class="ph-empty">
                                                                                        <i class="bi bi-receipt"></i>
                                                                                        <p>Bạn chưa có lịch sử thanh
                                                                                            toán nào.</p>
                                                                                    </div>
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </div>

                                                        </div><%-- /prof-panel-body --%>
                                                    </div><%-- /tab-history --%>

                                </main>
                    </div><%-- /prof-page --%>

                        <jsp:include page="footer.jsp" />

                        <script
                            src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

                        <script>
                            /* ─── Sidebar navigation ─── */
                            document.querySelectorAll('.prof-nav-item').forEach(function (item) {
                                item.addEventListener('click', function (e) {
                                    e.preventDefault();
                                    const tab = this.dataset.tab;
                                    document.querySelectorAll('.prof-nav-item').forEach(i => i.classList.remove('active'));
                                    document.querySelectorAll('.prof-panel').forEach(p => p.classList.remove('active'));
                                    this.classList.add('active');
                                    document.getElementById('tab-' + tab).classList.add('active');
                                    // show flash only on first panel
                                    const flash = document.getElementById('flashMessage');
                                    if (flash) flash.style.display = (tab === 'info') ? '' : 'none';
                                });
                            });

                            /* ─── History sub-tabs ─── */
                            document.querySelectorAll('.hist-tab').forEach(function (tab) {
                                tab.addEventListener('click', function () {
                                    const hist = this.dataset.hist;
                                    document.querySelectorAll('.hist-tab').forEach(t => t.classList.remove('active'));
                                    document.querySelectorAll('.hist-panel').forEach(p => p.classList.remove('active'));
                                    this.classList.add('active');
                                    document.getElementById('hist-' + hist).classList.add('active');
                                });
                            });

                            /* ─── Avatar preview ─── */
                            function previewSidebarAvatar(event) {
                                const file = event.target.files[0];
                                if (!file) return;
                                const reader = new FileReader();
                                reader.onload = function (e) {
                                    let img = document.getElementById('previewAvatar');
                                    if (!img) {
                                        img = document.createElement('img');
                                        img.id = 'previewAvatar';
                                        img.style.cssText = 'width:96px;height:96px;border-radius:50%;object-fit:cover;border:3px solid rgba(255,255,255,0.6);';
                                        const wrap = document.querySelector('.prof-avatar-wrap');
                                        const overlay = wrap.querySelector('.prof-avatar-overlay');
                                        wrap.insertBefore(img, overlay);
                                    }
                                    img.src = e.target.result;
                                    img.style.display = '';
                                    const initial = document.getElementById('sidebarInitial');
                                    if (initial) initial.style.display = 'none';
                                };
                                reader.readAsDataURL(file);
                            }

                            /* ─── Phone validation ─── */
                            document.addEventListener('DOMContentLoaded', function () {
                                const phoneInput = document.getElementById('phoneInput');
                                const phoneError = document.getElementById('phoneError');
                                const profileForm = document.getElementById('profileForm');
                                if (!phoneInput) return;

                                phoneInput.addEventListener('input', function () {
                                    const phone = this.value.trim();
                                    phoneError.style.display = 'none';
                                    phoneInput.classList.remove('field-error');
                                    if (phone && !/^\d{10}$/.test(phone)) {
                                        phoneError.textContent = 'Số điện thoại phải đúng 10 chữ số';
                                        phoneError.style.display = 'block';
                                        phoneInput.classList.add('field-error');
                                    }
                                });

                                profileForm.addEventListener('submit', function (e) {
                                    const phone = phoneInput.value.trim();
                                    if (!phone || !/^\d{10}$/.test(phone)) {
                                        e.preventDefault();
                                        phoneError.textContent = 'Số điện thoại phải đúng 10 chữ số';
                                        phoneError.style.display = 'block';
                                        phoneInput.classList.add('field-error');
                                        phoneInput.focus();
                                        phoneInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                    }
                                });

                                /* Flash: show on info tab */
                                const flash = document.getElementById('flashMessage');
                                if (flash && flash.classList.contains('error')) {
                                    flash.scrollIntoView({ behavior: 'smooth', block: 'start' });
                                }

                                /* Auto-open correct tab if flash related to password */
                                <c:if test="${not empty flash and flashType == 'success' and flash eq 'Đổi mật khẩu thành công.'}">
        document.querySelectorAll('.prof-nav-item').forEach(i => i.classList.remove('active'));
        document.querySelectorAll('.prof-panel').forEach(p => p.classList.remove('active'));
                                    document.querySelector('[data-tab="password"]').classList.add('active');
                                    document.getElementById('tab-password').classList.add('active');
                                </c:if>
                            });

                            /* ─── Province/District/Ward API ─── */
                            document.addEventListener('DOMContentLoaded', function () {
                                const PROVINCE_API_URL = 'https://provinces.open-api.vn/api/?depth=3';
                                const citySelect = document.getElementById('profileCity');
                                const districtSelect = document.getElementById('profileDistrict');
                                const wardSelect = document.getElementById('profileWard');
                                const hiddenCity = document.getElementById('hiddenCity');
                                const hiddenDistrict = document.getElementById('hiddenDistrict');
                                const hiddenWard = document.getElementById('hiddenWard');
                                if (!citySelect) return;

                                const savedCity = (hiddenCity?.value || '').trim();
                                const savedDistrict = (hiddenDistrict?.value || '').trim();
                                const savedWard = (hiddenWard?.value || '').trim();
                                const locationCatalog = new Map();

                                const resetSelect = (sel, ph) => { sel.innerHTML = '<option value="">' + ph + '</option>'; };

                                const buildCatalog = (provinces) => {
                                    locationCatalog.clear();
                                    if (!Array.isArray(provinces)) return;
                                    provinces.forEach(p => {
                                        if (!p?.name) return;
                                        const districts = new Map();
                                        (p.districts || []).forEach(d => {
                                            if (!d?.name) return;
                                            districts.set(d.name, Array.isArray(d.wards) ? d.wards.map(w => w.name).filter(Boolean) : []);
                                        });
                                        locationCatalog.set(p.name, { districts });
                                    });
                                };

                                const populateCities = () => {
                                    resetSelect(citySelect, 'Chọn tỉnh/thành');
                                    locationCatalog.forEach((_, name) => {
                                        const opt = document.createElement('option');
                                        opt.value = opt.textContent = name;
                                        citySelect.appendChild(opt);
                                    });
                                };

                                const renderDistricts = (city) => {
                                    resetSelect(districtSelect, 'Chọn quận/huyện');
                                    resetSelect(wardSelect, 'Chọn phường/xã');
                                    if (!city) return;
                                    const province = locationCatalog.get(city);
                                    if (!province) return;
                                    province.districts.forEach((_, name) => {
                                        const opt = document.createElement('option');
                                        opt.value = opt.textContent = name;
                                        districtSelect.appendChild(opt);
                                    });
                                };

                                const renderWards = (city, district) => {
                                    resetSelect(wardSelect, 'Chọn phường/xã');
                                    if (!city || !district) return;
                                    const wards = locationCatalog.get(city)?.districts.get(district);
                                    if (!Array.isArray(wards)) return;
                                    wards.forEach(w => {
                                        const opt = document.createElement('option');
                                        opt.value = opt.textContent = w;
                                        wardSelect.appendChild(opt);
                                    });
                                };

                                const syncHidden = () => {
                                    hiddenCity.value = citySelect.value;
                                    hiddenDistrict.value = districtSelect.value;
                                    hiddenWard.value = wardSelect.value;
                                };

                                citySelect.addEventListener('change', () => { renderDistricts(citySelect.value); syncHidden(); });
                                districtSelect.addEventListener('change', () => { renderWards(citySelect.value, districtSelect.value); syncHidden(); });
                                wardSelect.addEventListener('change', syncHidden);

                                fetch(PROVINCE_API_URL)
                                    .then(r => { if (!r.ok) throw new Error('API error'); return r.json(); })
                                    .then(data => {
                                        buildCatalog(data);
                                        populateCities();
                                        if (savedCity) {
                                            citySelect.value = savedCity;
                                            renderDistricts(savedCity);
                                            if (savedDistrict) {
                                                districtSelect.value = savedDistrict;
                                                renderWards(savedCity, savedDistrict);
                                                if (savedWard) wardSelect.value = savedWard;
                                            }
                                        }
                                    })
                                    .catch(err => console.error('Không tải được tỉnh/thành:', err));
                            });
                        </script>

                        <%-- ── Success modal for password change ── --%>
                            <c:if
                                test="${not empty flash and flashType == 'success' and flash eq 'Đổi mật khẩu thành công.'}">
                                <div class="modal fade" id="successModal" tabindex="-1">
                                    <div class="modal-dialog modal-dialog-centered">
                                        <div class="modal-content shadow-lg border-0 rounded-4">
                                            <div class="modal-body text-center p-4">
                                                <div style="font-size:56px;color:#28a745;">✔</div>
                                                <h5 class="fw-bold mt-3">Thành công</h5>
                                                <p class="text-muted">${flash}</p>
                                                <button class="btn btn-success rounded-pill px-4"
                                                    data-bs-dismiss="modal">OK</button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <script>
                                    document.addEventListener('DOMContentLoaded', function () {
                                        new bootstrap.Modal(document.getElementById('successModal')).show();
                                    });
                                </script>
                            </c:if>

                </body>

                </html>
                }

                .profile-wrapper {
                display: flex;
                justify-content: center;
                padding: 40px;
                }

                .profile-container {
                width: 750px;
                background: white;
                padding: 35px;
                border-radius: 18px;
                box-shadow: 0 12px 35px rgba(0, 0, 0, 0.08);
                }

                .tabs {
                display: flex;
                border-bottom: 2px solid #eef1ff;
                margin-bottom: 30px;
                }

                .tab {
                padding: 12px 22px;
                cursor: pointer;
                font-weight: 500;
                color: #666;
                transition: 0.3s;
                }

                .tab:hover {
                color: #2b63d9;
                }

                .tab.active {
                color: #2b63d9;
                border-bottom: 3px solid #2b63d9;
                font-weight: 600;
                }

                .section {
                display: none;
                }

                .section.active {
                display: block;
                }

                .avatar-wrapper {
                text-align: center;
                margin-bottom: 25px;
                }

                .avatar-wrapper img {
                width: 140px;
                height: 140px;
                border-radius: 50%;
                object-fit: cover;
                cursor: pointer;
                border: 5px solid #eef1ff;
                transition: 0.3s;
                }

                .avatar-wrapper img:hover {
                transform: scale(1.05);
                }

                .avatar-text {
                font-size: 13px;
                color: #777;
                margin-top: 10px;
                }

                .profile-container input {
                width: 100%;
                padding: 11px 14px;
                margin-bottom: 18px;
                border-radius: 10px;
                border: 1px solid #ddd;
                transition: 0.2s;
                font-size: 14px;
                }

                .profile-container input:focus {
                border-color: #2b63d9;
                outline: none;
                box-shadow: 0 0 0 3px rgba(43, 99, 217, 0.15);
                }

                input:invalid {
                border-color: #dc3545;
                }

                .profile-container button {
                padding: 10px 20px;
                border: none;
                border-radius: 10px;
                background: linear-gradient(135deg, #2b63d9, #5f5bd7);
                color: white;
                cursor: pointer;
                font-weight: 500;
                transition: 0.3s;
                }

                .profile-container button:hover {
                opacity: 0.9;
                transform: translateY(-1px);
                }

                .tag {
                display: inline-block;
                padding: 5px 12px;
                border-radius: 999px;
                color: white;
                font-size: 13px;
                font-weight: 500;
                background-color: green;
                }

                .role-member {
                background: #3b82f6;
                }

                .role-librarian {
                background: #22c55e;
                }

                .role-admin {
                background: #8b5cf6;
                }

                .status-active {
                background: #16a34a;
                }

                .status-inactive {
                background: #9ca3af;
                }

                .form-group {
                display: flex;
                align-items: center;
                margin-bottom: 18px;
                }

                .form-group label {
                width: 140px;
                font-weight: 600;
                }

                .form-group input,
                .form-group select {
                flex: 1;
                }

                .profile-container select {
                width: 100%;
                padding: 11px 14px;
                margin-bottom: 18px;
                border-radius: 10px;
                border: 1px solid #ddd;
                transition: 0.2s;
                font-size: 14px;
                background: #fff;
                cursor: pointer;
                appearance: auto;
                }

                .profile-container select:focus {
                border-color: #2b63d9;
                outline: none;
                box-shadow: 0 0 0 3px rgba(43, 99, 217, 0.15);
                }

                .message {
                margin: 15px 0 25px 0;
                padding: 12px 16px;
                border-radius: 8px;
                font-weight: 500;
                }

                .message.success {
                background: #e6f4ea;
                color: #1e7e34;
                }

                .message.error {
                background: #fdecea;
                color: #b02a37;
                }

                #phoneError {
                display: block;
                margin-top: 5px;
                font-size: 13px;
                color: #dc3545;
                font-weight: 500;
                }

                input#phoneInput.phone-error {
                border-color: #dc3545 !important;
                background-color: #fff5f5;
                }

                .ph-badge {
                display: inline-block;
                padding: 2px 10px;
                border-radius: 999px;
                font-size: 12px;
                font-weight: 600;
                }

                .ph-badge-success {
                background: #d1fae5;
                color: #065f46;
                }

                .ph-badge-failed {
                background: #fee2e2;
                color: #991b1b;
                }

                .ph-method-wallet {
                color: #16a34a;
                font-weight: 700;
                }

                .ph-method-vnpay {
                color: #1d4ed8;
                font-weight: 700;
                }

                .ph-table {
                width: 100%;
                border-collapse: collapse;
                font-size: 14px;
                }

                .ph-table th {
                background: #f8faff;
                padding: 10px 14px;
                text-align: left;
                font-size: 12px;
                font-weight: 600;
                color: #666;
                border-bottom: 2px solid #eef1ff;
                text-transform: uppercase;
                letter-spacing: .04em;
                }

                .ph-table td {
                padding: 10px 14px;
                border-bottom: 1px solid #f0f0f0;
                vertical-align: middle;
                }

                .ph-table tr:last-child td {
                border-bottom: none;
                }

                .ph-empty {
                text-align: center;
                padding: 32px 0;
                color: #999;
                font-size: 14px;
                }

                .ph-amount {
                font-weight: 700;
                color: #dc2626;
                white-space: nowrap;
                }
                </style>
                </head>

                <body>

                    <jsp:include page="header.jsp" />

                    <div class="profile-wrapper">
                        <div class="profile-container">

                            <h2>THÔNG TIN TÀI KHOẢN</h2>


                            <c:if test="${not empty flash}">
                                <div class="message ${flashType}" id="flashMessage">
                                    ${flash}
                                </div>
                                <script>
                                    document.addEventListener("DOMContentLoaded", function () {
                                        const flashMsg = document.getElementById('flashMessage');
                                        if (flashMsg && flashMsg.classList.contains('error')) {
                                            flashMsg.scrollIntoView({ behavior: 'smooth', block: 'start' });
                                        }
                                    });
                                </script>
                            </c:if>

                            <div class="tabs">
                                <div class="tab active" onclick="showTab(event, 'profile')">Thông Tin Cá Nhân</div>
                                <div class="tab" onclick="showTab(event, 'password')">Mật Khẩu</div>
                                <div class="tab" onclick="showTab(event, 'paymentHistory')">Lịch Sử Thanh Toán</div>
                            </div>

                            <!-- PROFILE -->
                            <div id="profile" class="section active">

                                <!-- AVATAR FORM -->
                                <div class="avatar-wrapper"
                                    style="display: flex; flex-direction: column; align-items: center; justify-content: center;">

                                    <form id="avatarForm" method="post" action="upload-avatar"
                                        enctype="multipart/form-data"
                                        style="display: flex; flex-direction: column; align-items: center;">

                                        <c:choose>
                                            <c:when test="${not empty user.avatar && user.avatar != 'null'}">
                                                <img src="${pageContext.request.contextPath}/${user.avatar}?v=${timestamp}"
                                                    id="previewAvatar"
                                                    onclick="document.getElementById('avatarUpload').click();"
                                                    onerror="this.style.display='none'; document.getElementById('previewAvatarContainer').style.display='flex';">
                                                <div id="previewAvatarContainer" class="default-avatar"
                                                    style="display:none; width: 140px; height: 140px; border-radius: 50%; background: linear-gradient(135deg, #2563eb, #60a5fa); color: #fff; font-weight: 700; font-size: 48px; align-items: center; justify-content: center; cursor: pointer; border: 5px solid #eef1ff;"
                                                    onclick="document.getElementById('avatarUpload').click();">
                                                    ${userInitial}</div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="default-avatar"
                                                    style="width: 140px; height: 140px; border-radius: 50%; background: linear-gradient(135deg, #2563eb, #60a5fa); color: #fff; font-weight: 700; font-size: 48px; display: flex; align-items: center; justify-content: center; cursor: pointer; border: 5px solid #eef1ff;"
                                                    onclick="document.getElementById('avatarUpload').click();"
                                                    id="previewAvatarContainer">${userInitial}</div>
                                            </c:otherwise>
                                        </c:choose>

                                        <div class="avatar-text">
                                            Bấm vào hình để thay đổi avatar
                                        </div>

                                        <input type="file" id="avatarUpload" name="avatar" accept="image/*" hidden
                                            onchange="previewImage(event); document.getElementById('avatarForm').submit();">
                                    </form>

                                </div>
                                <!-- UPDATE PROFILE FORM -->
                                <form method="post" action="${pageContext.request.contextPath}/profile"
                                    id="profileForm">

                                    <div class="form-group">
                                        <label>Họ tên</label>
                                        <input type="text" name="fullName" id="fullName" value="${user.fullName}"
                                            maxlength="100" required>
                                    </div>

                                    <div class="form-group">
                                        <label>Email</label>
                                        <input type="email" value="${user.email}" readonly>
                                    </div>

                                    <div class="form-group">
                                        <label>Số điện thoại</label>
                                        <input type="text" name="phone" id="phoneInput" value="${user.phone}"
                                            pattern="[0-9]{10}" title="Số điện thoại phải đúng 10 số"
                                            placeholder="Nhập 10 chữ số" required>
                                        <small id="phoneError" style="color: #dc3545; display: none;"></small>
                                    </div>

                                    <div class="form-group">
                                        <label>Địa chỉ (Số nhà / Đường)</label>
                                        <input type="text" name="address" value="${user.address}" maxlength="200"
                                            placeholder="Ví dụ: 118/2/14 Lê Văn Thọ">
                                    </div>

                                    <div class="form-group">
                                        <label>Tỉnh / Thành phố</label>
                                        <select id="profileCity">
                                            <option value="">Chọn tỉnh/thành</option>
                                        </select>
                                        <input type="hidden" name="city" id="hiddenCity" value="${user.city}">
                                    </div>

                                    <div class="form-group">
                                        <label>Quận / Huyện</label>
                                        <select id="profileDistrict">
                                            <option value="">Chọn quận/huyện</option>
                                        </select>
                                        <input type="hidden" name="district" id="hiddenDistrict"
                                            value="${user.district}">
                                    </div>

                                    <div class="form-group">
                                        <label>Phường / Xã</label>
                                        <select id="profileWard">
                                            <option value="">Chọn phường/xã</option>
                                        </select>
                                        <input type="hidden" name="ward" id="hiddenWard" value="${user.ward}">
                                    </div>

                                    <p>
                                        Vai trò:
                                        <span class="tag
      <c:choose>
          <c:when test=" ${user.role.name eq 'MEMBER' }">role-member</c:when>
                                            <c:when test="${user.role.name eq 'LIBRARIAN'}">role-librarian</c:when>
                                            <c:when test="${user.role.name eq 'ADMIN'}">role-admin</c:when>
                                            </c:choose>">

                                            <c:choose>
                                                <c:when test="${user.role.name eq 'MEMBER'}">Thành viên</c:when>
                                                <c:when test="${user.role.name eq 'LIBRARIAN'}">Thủ thư</c:when>
                                                <c:when test="${user.role.name eq 'ADMIN'}">Quản trị viên</c:when>
                                                <c:otherwise>Không xác định</c:otherwise>
                                            </c:choose>

                                        </span>
                                    </p>

                                    <p>
                                        Trạng thái:
                                        <span class="tag
                                  <c:choose>
                                      <c:when test=" ${user.status eq 'ACTIVE' }">status-active</c:when>
                                            <c:otherwise>status-inactive</c:otherwise>
                                            </c:choose>">
                                            <c:choose>
                                                <c:when test="${user.status eq 'ACTIVE'}">Hoạt động</c:when>
                                                <c:otherwise>Không hoạt động</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </p>

                                    <div style="text-align:center;">
                                        <button type="submit">LƯU THAY ĐỔI</button>
                                    </div>
                                </form>
                            </div>

                            <!-- PASSWORD -->
                            <div id="password" class="section">

                                <form method="post" action="${pageContext.request.contextPath}/change-password">

                                    <label>Mật khẩu hiện tại</label>
                                    <input type="password" name="oldPassword" required>

                                    <label>Mật khẩu mới</label>
                                    <input type="password" name="newPassword" minlength="6" required>

                                    <label>Xác nhận mật khẩu mới</label>
                                    <input type="password" name="confirm" minlength="6" required>

                                    <div style="text-align:center;">
                                        <button type="submit">Thay đổi mật khẩu</button>
                                    </div>

                                </form>
                            </div>

                            <!-- PAYMENT HISTORY -->
                            <div id="paymentHistory" class="section">
                                <h3 style="margin-bottom:16px;font-size:1.1rem;">Lịch Sử Thanh Toán</h3>
                                <c:choose>
                                    <c:when test="${not empty paymentHistory}">
                                        <div style="overflow-x:auto;">
                                            <table class="ph-table">
                                                <thead>
                                                    <tr>
                                                        <th>Thời gian</th>
                                                        <th>Loại</th>
                                                        <th>Phương thức</th>
                                                        <th>Mô tả</th>
                                                        <th>Số tiền</th>
                                                        <th>Trạng thái</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="ph" items="${paymentHistory}">
                                                        <tr>
                                                            <td style="white-space:nowrap;color:#666;font-size:12px;">
                                                                <fmt:formatDate value="${ph.createdAt}"
                                                                    pattern="dd/MM/yyyy HH:mm" />
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ph.paymentType == 'BOOK_DEPOSIT'}">
                                                                        🛒
                                                                        Đặt cọc sách</c:when>
                                                                    <c:when test="${ph.paymentType == 'FINE'}">⚠️ Phí
                                                                        phạt
                                                                    </c:when>
                                                                    <c:when test="${ph.paymentType == 'BOOK_RETURN'}">📚
                                                                        Trả
                                                                        sách</c:when>
                                                                    <c:otherwise>${ph.paymentType}</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ph.paymentMethod == 'WALLET'}">
                                                                        <span class="ph-method-wallet">💰 Ví</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="ph-method-vnpay">💳 VNPay</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td
                                                                style="max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                                                <c:choose>
                                                                    <c:when test="${not empty ph.description}">
                                                                        ${ph.description}</c:when>
                                                                    <c:otherwise>—</c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                            <td class="ph-amount">
                                                                <fmt:formatNumber value="${ph.amount}"
                                                                    pattern="#,##0" /> ₫
                                                            </td>
                                                            <td>
                                                                <c:choose>
                                                                    <c:when test="${ph.status == 'SUCCESS'}">
                                                                        <span class="ph-badge ph-badge-success">Thành
                                                                            công</span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="ph-badge ph-badge-failed">Thất
                                                                            bại</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="ph-empty">
                                            <p>Bạn chưa có lịch sử thanh toán nào.</p>
                                            <p style="margin-top:8px;">Các giao dịch sẽ xuất hiện tại đây sau khi bạn
                                                thanh
                                                toán.</p>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                        </div>
                    </div>

                    <script>
                        function showTab(e, tabId) {
                            document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
                            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));

                            document.getElementById(tabId).classList.add('active');
                            e.target.classList.add('active');
                        }

                        function previewImage(event) {
                            const reader = new FileReader();
                            reader.onload = function () {
                                document.getElementById('previewAvatar').src = reader.result;
                            }
                            reader.readAsDataURL(event.target.files[0]);
                        }

                        // Phone validation
                        document.addEventListener("DOMContentLoaded", function () {
                            const phoneInput = document.getElementById('phoneInput');
                            const phoneError = document.getElementById('phoneError');
                            const profileForm = document.getElementById('profileForm');

                            if (phoneInput) {
                                // Real-time validation - chỉ kiểm tra format
                                phoneInput.addEventListener('input', function () {
                                    const phone = this.value.trim();

                                    // Clear error message
                                    phoneError.textContent = '';
                                    phoneInput.classList.remove('phone-error');

                                    // Check format
                                    if (phone && phone.length > 0 && !/^\d{10}$/.test(phone)) {
                                        phoneError.textContent = 'Số điện thoại phải đúng 10 chữ số';
                                        phoneInput.classList.add('phone-error');
                                    }
                                });

                                // Form submit validation
                                profileForm.addEventListener('submit', function (e) {
                                    const phone = phoneInput.value.trim();

                                    // Validate format
                                    if (!phone || !/^\d{10}$/.test(phone)) {
                                        e.preventDefault();
                                        phoneError.textContent = 'Số điện thoại phải đúng 10 chữ số';
                                        phoneInput.classList.add('phone-error');
                                        phoneInput.focus();
                                        phoneInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                        return false;
                                    }

                                    // Format hợp lệ, cho phép submit form bình thường
                                    // Server sẽ check trùng phone và trả về flash message error nếu cần
                                    return true;
                                });
                            }
                        });
                    </script>

                    <!-- Province/District/Ward API Integration -->
                    <script>
                        document.addEventListener('DOMContentLoaded', function () {
                            const PROVINCE_API_URL = 'https://provinces.open-api.vn/api/?depth=3';
                            const citySelect = document.getElementById('profileCity');
                            const districtSelect = document.getElementById('profileDistrict');
                            const wardSelect = document.getElementById('profileWard');
                            const hiddenCity = document.getElementById('hiddenCity');
                            const hiddenDistrict = document.getElementById('hiddenDistrict');
                            const hiddenWard = document.getElementById('hiddenWard');

                            if (!citySelect || !districtSelect || !wardSelect) return;

                            const savedCity = (hiddenCity?.value || '').trim();
                            const savedDistrict = (hiddenDistrict?.value || '').trim();
                            const savedWard = (hiddenWard?.value || '').trim();

                            const locationCatalog = new Map();

                            const resetSelect = (select, placeholder) => {
                                select.innerHTML = '<option value="">' + placeholder + '</option>';
                            };

                            const buildCatalog = (provinces) => {
                                locationCatalog.clear();
                                if (!Array.isArray(provinces)) return;
                                provinces.forEach(p => {
                                    if (!p || !p.name) return;
                                    const districts = new Map();
                                    (p.districts || []).forEach(d => {
                                        if (!d || !d.name) return;
                                        const wards = Array.isArray(d.wards)
                                            ? d.wards.map(w => w.name).filter(Boolean) : [];
                                        districts.set(d.name, wards);
                                    });
                                    locationCatalog.set(p.name, { districts });
                                });
                            };

                            const populateCities = () => {
                                resetSelect(citySelect, 'Chọn tỉnh/thành');
                                locationCatalog.forEach((val, name) => {
                                    const opt = document.createElement('option');
                                    opt.value = name;
                                    opt.textContent = name;
                                    citySelect.appendChild(opt);
                                });
                            };

                            const renderDistricts = (city) => {
                                resetSelect(districtSelect, 'Chọn quận/huyện');
                                resetSelect(wardSelect, 'Chọn phường/xã');
                                if (!city) return;
                                const province = locationCatalog.get(city);
                                if (!province) return;
                                province.districts.forEach((wards, distName) => {
                                    const opt = document.createElement('option');
                                    opt.value = distName;
                                    opt.textContent = distName;
                                    districtSelect.appendChild(opt);
                                });
                            };

                            const renderWards = (city, district) => {
                                resetSelect(wardSelect, 'Chọn phường/xã');
                                if (!city || !district) return;
                                const province = locationCatalog.get(city);
                                const wardList = province?.districts.get(district);
                                if (!Array.isArray(wardList)) return;
                                wardList.forEach(w => {
                                    const opt = document.createElement('option');
                                    opt.value = w;
                                    opt.textContent = w;
                                    wardSelect.appendChild(opt);
                                });
                            };

                            const syncHidden = () => {
                                hiddenCity.value = citySelect.value;
                                hiddenDistrict.value = districtSelect.value;
                                hiddenWard.value = wardSelect.value;
                            };

                            citySelect.addEventListener('change', () => {
                                renderDistricts(citySelect.value);
                                syncHidden();
                            });
                            districtSelect.addEventListener('change', () => {
                                renderWards(citySelect.value, districtSelect.value);
                                syncHidden();
                            });
                            wardSelect.addEventListener('change', syncHidden);

                            fetch(PROVINCE_API_URL)
                                .then(r => { if (!r.ok) throw new Error('API error'); return r.json(); })
                                .then(data => {
                                    buildCatalog(data);
                                    populateCities();
                                    if (savedCity) {
                                        citySelect.value = savedCity;
                                        renderDistricts(savedCity);
                                        if (savedDistrict) {
                                            districtSelect.value = savedDistrict;
                                            renderWards(savedCity, savedDistrict);
                                            if (savedWard) {
                                                wardSelect.value = savedWard;
                                            }
                                        }
                                    }
                                })
                                .catch(err => console.error('Không tải được tỉnh/thành:', err));
                        });
                    </script>

                    <!-- POPUP ĐỔI MẬT KHẨU -->
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

                    <c:if test="${not empty flash
                      and flashType == 'success' 
                      and flash eq 'Đổi mật khẩu thành công.'}">

                        <div class="modal fade" id="successModal" tabindex="-1">
                            <div class="modal-dialog modal-dialog-centered">
                                <div class="modal-content shadow-lg border-0 rounded-4">
                                    <div class="modal-body text-center p-4">

                                        <div style="font-size:60px;color:#28a745;">✔</div>

                                        <h5 class="fw-bold mt-3">Thành công</h5>
                                        <p class="text-muted">${flash}</p>

                                        <button class="btn btn-success rounded-pill px-4" data-bs-dismiss="modal">
                                            OK
                                        </button>

                                    </div>
                                </div>
                            </div>
                        </div>

                        <script>
                            document.addEventListener("DOMContentLoaded", function () {
                                var myModal = new bootstrap.Modal(
                                    document.getElementById('successModal')
                                );
                                myModal.show();
                            });
                        </script>

                    </c:if>

                </body>

                </html>