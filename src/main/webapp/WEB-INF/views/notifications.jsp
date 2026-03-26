<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Thông báo – LBMS</title>
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
                <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css"
                    rel="stylesheet" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet" />
                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                <style>
                    *,
                    *::before,
                    *::after {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    :root {
                        --bg: #f0f4f8;
                        --surface: #fff;
                        --border: #e2e8f0;
                        --text: #1e293b;
                        --text-soft: #64748b;
                        --text-muted: #94a3b8;
                        --primary: #3b82f6;
                        --primary-light: #eff6ff;
                        --radius-sm: 6px;
                        --radius: 12px;
                        --shadow: 0 1px 3px rgba(0, 0, 0, .08);
                    }

                    body {
                        font-family: 'Inter', sans-serif;
                        background: var(--bg);
                        color: var(--text);
                        min-height: 100vh;
                        display: flex;
                        flex-direction: column;
                    }

                    .main-wrap {
                        flex: 1;
                    }

                    .page-header {
                        background: var(--surface);
                        border-bottom: 1px solid var(--border);
                        padding: 24px 40px;
                    }

                    .page-header__inner {
                        max-width: 760px;
                        margin: 0 auto;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        gap: 14px;
                    }

                    .page-header__left {
                        display: flex;
                        align-items: center;
                        gap: 14px;
                    }

                    .page-header__icon {
                        width: 40px;
                        height: 40px;
                        border-radius: var(--radius-sm);
                        background: var(--primary-light);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: var(--primary);
                        font-size: 1.2rem;
                    }

                    .page-header__title {
                        font-size: 1.2rem;
                        font-weight: 700;
                    }

                    .page-header__sub {
                        font-size: .8rem;
                        color: var(--text-soft);
                        margin-top: 2px;
                    }

                    /* Nút chức năng */
                    .btn-action-group {
                        display: flex;
                        gap: 8px;
                        align-items: center;
                    }

                    .btn-mark-all,
                    .btn-compose {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 7px 16px;
                        font-size: .82rem;
                        font-weight: 600;
                        border-radius: var(--radius-sm);
                        cursor: pointer;
                        transition: all .15s;
                        text-decoration: none;
                    }

                    .btn-mark-all {
                        border: 1.5px solid var(--border);
                        background: var(--surface);
                        color: var(--text-soft);
                    }

                    .btn-mark-all:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .btn-compose {
                        background: var(--primary);
                        color: white;
                        border: none;
                    }

                    .btn-compose:hover {
                        background: #2563eb;
                        color: white;
                    }

                    .content {
                        max-width: 760px;
                        margin: 0 auto;
                        padding: 24px 40px 60px;
                    }

                    .empty-state {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: var(--radius);
                        padding: 80px 20px;
                        text-align: center;
                    }

                    .empty-state__icon {
                        font-size: 3rem;
                        color: #cbd5e1;
                        margin-bottom: 12px;
                    }

                    .empty-state__title {
                        font-size: 1rem;
                        font-weight: 600;
                        color: var(--text-soft);
                        margin-bottom: 6px;
                    }

                    .notif-list {
                        display: flex;
                        flex-direction: column;
                        gap: 10px;
                    }

                    .notif-card {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: var(--radius);
                        padding: 16px 20px;
                        display: flex;
                        align-items: flex-start;
                        gap: 14px;
                        box-shadow: var(--shadow);
                        transition: background .1s;
                        position: relative;
                    }

                    .notif-card.unread {
                        background: #f0f7ff;
                        border-color: #bfdbfe;
                    }

                    .notif-card.unread::before {
                        content: '';
                        position: absolute;
                        left: 0;
                        top: 50%;
                        transform: translateY(-50%);
                        width: 4px;
                        height: 60%;
                        background: var(--primary);
                        border-radius: 0 4px 4px 0;
                    }

                    .notif-icon {
                        width: 40px;
                        height: 40px;
                        border-radius: 50%;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 1.1rem;
                        flex-shrink: 0;
                    }

                    .notif-icon--available {
                        background: #dcfce7;
                        color: #16a34a;
                    }

                    .notif-icon--expiring {
                        background: #fef9c3;
                        color: #ca8a04;
                    }

                    .notif-icon--expired {
                        background: #fee2e2;
                        color: #dc2626;
                    }

                    .notif-icon--info {
                        background: #e0f2fe;
                        color: #0ea5e9;
                    }

                    .notif-icon--cancelled {
                        background: #f1f5f9;
                        color: #64748b;
                    }

                    .notif-body {
                        flex: 1;
                        min-width: 0;
                    }

                    .notif-title {
                        font-size: .9rem;
                        font-weight: 600;
                        color: var(--text);
                        margin-bottom: 4px;
                    }

                    .notif-message {
                        font-size: .82rem;
                        color: var(--text-soft);
                        line-height: 1.5;
                    }

                    .notif-time {
                        font-size: .75rem;
                        color: var(--text-muted);
                        margin-top: 6px;
                    }

                    .btn-read {
                        padding: 4px 10px;
                        font-size: .75rem;
                        font-weight: 500;
                        border-radius: var(--radius-sm);
                        border: 1px solid var(--border);
                        background: transparent;
                        color: var(--text-soft);
                        cursor: pointer;
                        white-space: nowrap;
                        transition: all .15s;
                    }

                    .btn-read:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    /* Fix Select2 in Bootstrap Modal */
                    .select2-container {
                        z-index: 2050 !important;
                        width: 100% !important;
                    }

                    .alert-floating {
                        position: fixed;
                        top: 20px;
                        right: 20px;
                        z-index: 3000;
                        min-width: 300px;
                    }

                    /* Tinh chỉnh thông báo nổi */
                    .alert-floating {
                        position: fixed;
                        top: 24px;
                        right: 24px;
                        z-index: 3000;
                        min-width: 320px;
                        border: none;
                        border-radius: var(--radius);
                        padding: 16px 20px;
                        display: flex;
                        align-items: center;
                        background: rgba(255, 255, 255, 0.95);
                        /* Hiệu ứng kính */
                        backdrop-filter: blur(8px);
                        box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1);
                        border-left: 4px solid #10b981;
                        /* Màu xanh success */
                        animation: slideInRight 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
                    }

                    .alert-floating .bi {
                        font-size: 1.4rem;
                        color: #10b981;
                        margin-right: 12px;
                    }

                    .alert-floating .alert-content {
                        color: var(--text);
                        font-weight: 500;
                        font-size: 0.9rem;
                        margin-right: 20px;
                    }

                    .alert-floating .btn-close {
                        padding: 1rem;
                        font-size: 0.7rem;
                        box-shadow: none;
                    }

                    /* Hiệu ứng trượt từ phải sang */
                    @keyframes slideInRight {
                        from {
                            transform: translateX(100%);
                            opacity: 0;
                        }

                        to {
                            transform: translateX(0);
                            opacity: 1;
                        }
                    }
                </style>
            </head>

            <body>
                <c:set var="userRole" value="${sessionScope.currentUser.role.name}" />
                <c:set var="isStaff" value="${userRole == 'ADMIN' || userRole == 'LIBRARIAN'}" />

                <div class="app-container ${isStaff ? '' : 'no-sidebar'}">

                    <c:choose>

                        <%-- ADMIN --%>
                            <c:when test="${userRole == 'ADMIN'}">
                                <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />
                                <div class="main-content-wrapper" style="margin-left:250px;">
                            </c:when>

                            <%-- LIBRARIAN --%>
                                <c:when test="${userRole == 'LIBRARIAN'}">
                                    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
                                    <div class="main-content-wrapper" style="margin-left:250px;">
                                </c:when>

                                <%-- USER --%>
                                    <c:otherwise>
                                        <jsp:include page="/WEB-INF/views/header.jsp" />
                                        <div class="main-content-wrapper">
                                    </c:otherwise>

                    </c:choose>

                    <%-- Thông báo thành công --%>
                        <c:if test="${not empty sessionScope.successMessage}">
                            <script>
                                const msg = `<c:out value="${sessionScope.successMessage}"/>`.trim();

                                Swal.fire({
                                    icon: 'success',
                                    title: 'Thành công',
                                    text: msg,
                                    confirmButtonColor: '#3b82f6',
                                    timer: 4000,
                                    timerProgressBar: true
                                });
                            </script>
                            <c:remove var="successMessage" scope="session" />
                        </c:if>

                        <div class="main-wrap">
                            <header class="page-header">
                                <div class="page-header__inner">
                                    <div class="page-header__left">
                                        <div class="page-header__icon"><i class="bi bi-bell"></i></div>
                                        <div>
                                            <div class="page-header__title">Thông báo</div>
                                            <div class="page-header__sub">
                                                <c:choose>
                                                    <c:when test="${unreadCount > 0}">
                                                        Bạn có <strong>${unreadCount}</strong> thông báo chưa đọc
                                                    </c:when>
                                                    <c:otherwise>Tất cả đã đọc</c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="btn-action-group">
                                        <%-- Nút Soạn tin cho Admin/Librarian --%>
                                            <c:if
                                                test="${sessionScope.currentUser.role.name == 'ADMIN' || sessionScope.currentUser.role.name == 'LIBRARIAN'}">
                                                <button class="btn-compose" data-bs-toggle="modal"
                                                    data-bs-target="#sendNotifModal">
                                                    <i class="bi bi-plus-lg"></i> Soạn tin
                                                </button>
                                            </c:if>

                                            <c:if test="${unreadCount > 0}">
                                                <form method="post"
                                                    action="${pageContext.request.contextPath}/notifications">
                                                    <input type="hidden" name="action" value="markAllRead" />
                                                    <button type="submit" class="btn-mark-all">
                                                        <i class="bi bi-check2-all"></i> Đánh dấu tất cả đã đọc
                                                    </button>
                                                </form>
                                            </c:if>
                                    </div>
                                </div>
                            </header>

                            <main class="content">
                                <c:choose>
                                    <c:when test="${empty notifications}">
                                        <div class="empty-state">
                                            <div class="empty-state__icon"><i class="bi bi-bell-slash"></i></div>
                                            <div class="empty-state__title">Chưa có thông báo nào</div>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <div class="notif-list">
                                            <c:forEach var="n" items="${notifications}">
                                                <div class="notif-card ${n.isRead ? '' : 'unread'}">
                                                    <div class="notif-icon 
                                    <c:choose>
                                        <c:when test=" ${n.type=='RESERVATION_AVAILABLE' }">notif-icon--available
                                                        </c:when>
                                                        <c:when test="${n.type == 'RESERVATION_EXPIRING'}">
                                                            notif-icon--expiring</c:when>
                                                        <c:when test="${n.type == 'RESERVATION_EXPIRED'}">
                                                            notif-icon--expired</c:when>
                                                        <c:otherwise>notif-icon--info</c:otherwise>
                                </c:choose>">
                                <c:choose>
                                    <c:when test="${n.type == 'RESERVATION_AVAILABLE'}"><i
                                            class="bi bi-check-circle-fill"></i></c:when>
                                    <c:when test="${n.type == 'RESERVATION_EXPIRING'}"><i class="bi bi-alarm-fill"></i>
                                    </c:when>
                                    <c:when test="${n.type == 'RESERVATION_EXPIRED'}"><i
                                            class="bi bi-x-circle-fill"></i>
                                    </c:when>
                                    <c:otherwise><i class="bi bi-info-circle-fill"></i></c:otherwise>
                                </c:choose>
                        </div>

                        <div class="notif-body">
                            <div class="notif-title">${n.title}</div>
                            <div class="notif-message">${n.message}</div>
                            <div class="notif-time">
                                <i class="bi bi-clock" style="font-size:.7rem"></i>
                                <fmt:formatDate value="${n.createdAt}" pattern="HH:mm - dd/MM/yyyy" />
                            </div>
                        </div>

                        <c:if test="${!n.isRead}">
                            <div class="notif-actions">
                                <form method="post" action="${pageContext.request.contextPath}/notifications">
                                    <input type="hidden" name="action" value="markRead" />
                                    <input type="hidden" name="notifId" value="${n.id}" />
                                    <button type="submit" class="btn-read">Đã đọc</button>
                                </form>
                            </div>
                        </c:if>
                </div>
                </c:forEach>
                </div>
                </c:otherwise>
                </c:choose>
                </main>
                </div>
            </div>
        </div>

        <%-- Modal Soạn tin --%>
                    <div class="modal fade" id="sendNotifModal" tabindex="-1" aria-hidden="true">
                        <div class="modal-dialog modal-lg modal-dialog-centered">
                            <div class="modal-content border-0 shadow-lg" style="border-radius: var(--radius);">
                                <form action="${pageContext.request.contextPath}/notifications" method="post">
                                    <input type="hidden" name="action" value="create">
                                    <div class="modal-header bg-primary text-white"
                                        style="border-top-left-radius: var(--radius); border-top-right-radius: var(--radius);">
                                        <h5 class="modal-title fw-bold"><i class="bi bi-send-fill me-2"></i>Gửi
                                            thông báo mới</h5>
                                        <button type="button" class="btn-close btn-close-white"
                                            data-bs-dismiss="modal"></button>
                                    </div>
                                    <div class="modal-body p-4">
                                        <div class="row g-3">
                                            <div class="col-md-6">
                                                <label class="form-label fw-bold small text-uppercase">Phạm vi
                                                    gửi:</label>
                                                <select name="notification_mode" id="modeSelect"
                                                    class="form-select shadow-sm" onchange="toggleReceiverWrapper()">
                                                    <c:if test="${sessionScope.currentUser.role.name == 'ADMIN'}">
                                                        <option value="ALL_SYSTEM">Toàn bộ hệ thống</option>
                                                        <option value="ALL_LIBRARIANS">Tất cả Thủ thư</option>
                                                    </c:if>
                                                    <option value="ALL_USERS">Tất cả Thành viên</option>
                                                    <option value="SPECIFIC">Cá nhân cụ thể</option>
                                                </select>
                                            </div>
                                            <div class="col-md-6" id="receiverWrapper" style="display: none;">
                                                <label class="form-label fw-bold small text-uppercase">Người
                                                    nhận:</label>
                                                <select name="receiver_id" id="userSelect" class="form-select w-100">
                                                    <option value="">-- Chọn Email --</option>
                                                    <c:forEach items="${users}" var="u">
                                                        <option value="${u.id}">${u.email} (${u.fullName})
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label fw-bold small text-uppercase">Tiêu
                                                    đề:</label>
                                                <input type="text" name="title" class="form-control shadow-sm"
                                                    placeholder="Nhập tiêu đề thông báo..." required>
                                            </div>
                                            <div class="col-12">
                                                <label class="form-label fw-bold small text-uppercase">Nội dung
                                                    chi
                                                    tiết:</label>
                                                <textarea name="message" class="form-control shadow-sm" rows="4"
                                                    placeholder="Viết nội dung tại đây..." required></textarea>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="modal-footer bg-light border-0"
                                        style="border-bottom-left-radius: var(--radius); border-bottom-right-radius: var(--radius);">
                                        <button type="button"
                                            class="btn btn-link text-secondary text-decoration-none fw-semibold"
                                            data-bs-dismiss="modal">Hủy bỏ</button>
                                        <button type="submit" class="btn btn-primary px-4 fw-bold shadow-sm">Gửi
                                            ngay</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <c:if test="${not isStaff}">
                        <jsp:include page="/WEB-INF/views/footer.jsp" />
                    </c:if>

                    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                    <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>

                    <script>
                        $(document).ready(function () {
                            $(document).ready(function () {
                                toggleReceiverWrapper();
                            });
                            // Tự động ẩn Alert sau 4s
                            setTimeout(() => { $(".alert-floating").fadeOut('slow'); }, 4000);


                            $('#sendNotifModal').on('shown.bs.modal', function () {
                                $('#userSelect').select2({
                                    dropdownParent: $('#sendNotifModal'),
                                    placeholder: "Tìm kiếm bằng email...",
                                    allowClear: true
                                });
                            });
                        });

                        function toggleReceiverWrapper() {
                            const mode = $('#modeSelect').val();
                            const wrapper = $('#receiverWrapper');
                            if (mode === 'SPECIFIC') {
                                wrapper.fadeIn();
                                $('#userSelect').prop('required', true);
                            } else {
                                wrapper.fadeOut();
                                $('#userSelect').prop('required', false);
                            }
                        }
                        function markAsRead(id, btnElement) {
                            fetch(`${pageContext.request.contextPath}/notifications?action=markRead&notifId=${id}`, {
                                method: 'POST'
                            }).then(response => {
                                if (response.ok) {

                                    const badge = document.querySelector('.badge-notify');
                                    if (badge) {
                                        let count = parseInt(badge.innerText);
                                        if (count > 1) {
                                            badge.innerText = (count - 1) > 99 ? '99+' : (count - 1);
                                        } else {
                                            badge.remove();
                                        }
                                    }


                                    const card = btnElement.closest('.notif-card');
                                    card.classList.remove('unread');
                                    btnElement.parentElement.remove();


                                    const subTitle = document.querySelector('.page-header__sub strong');
                                    if (subTitle) {
                                        let countHead = parseInt(subTitle.innerText);
                                        if (countHead > 1) subTitle.innerText = countHead - 1;
                                        else document.querySelector('.page-header__sub').innerText = "Tất cả đã đọc";
                                    }
                                }
                            }).catch(err => console.error("Lỗi:", err));
                        }
                    </script>
            </body>

            </html>