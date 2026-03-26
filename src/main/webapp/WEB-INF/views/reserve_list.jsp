<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Danh sách đặt trước – LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
</head>

<body class="mp-body">
    <jsp:include page="/WEB-INF/views/header.jsp" />

    <%-- Count active (WAITING or AVAILABLE) reservations --%>
    <c:set var="activeCount" value="0" />
    <c:forEach var="r" items="${reservations}">
        <c:if test="${r.status == 'WAITING' || r.status == 'AVAILABLE'}">
            <c:set var="activeCount" value="${activeCount + 1}" />
        </c:if>
    </c:forEach>

    <!-- HERO -->
    <section class="mp-hero">
        <div class="mp-hero__inner">
            <div>
                <p class="mp-hero__eyebrow">Đặt trước</p>
                <h1 class="mp-hero__title">Danh sách đặt trước sách</h1>
                <p class="mp-hero__subtitle">Theo dõi trạng thái các sách bạn đã đặt trước</p>
            </div>
            <div class="mp-hero__card">
                <p class="mp-hero__card-label">Slot đang sử dụng</p>
                <p class="mp-hero__card-value">${activeCount}
                    <span style="font-size:1.2rem;opacity:.75">/ ${maxReservations}</span>
                </p>
                <p class="mp-hero__card-detail">đặt trước đang hoạt động</p>
                <span
                    class="mp-limit-pill ${activeCount >= maxReservations ? 'mp-limit-pill--full' : activeCount >= maxReservations - 1 ? 'mp-limit-pill--warn' : ''}">
                    <i class="bi bi-bookmark-check"></i>
                    <c:choose>
                        <c:when test="${activeCount >= maxReservations}">Đã đầy slot</c:when>
                        <c:when test="${activeCount >= maxReservations - 1}">Còn 1 slot</c:when>
                        <c:otherwise>Còn ${maxReservations - activeCount} slot trống</c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
    </section>

    <main>
        <div class="mp-content">

            <%-- Flash messages --%>
            <c:if test="${not empty sessionScope.successMsg}">
                <div class="mp-flash mp-flash--success">
                    <i class="bi bi-check-circle-fill"></i>
                    <span>${sessionScope.successMsg}</span>
                    <button class="mp-flash__close" onclick="this.parentElement.remove()">x</button>
                </div>
                <c:remove var="successMsg" scope="session" />
            </c:if>
            <c:if test="${not empty sessionScope.errorMsg}">
                <div class="mp-flash mp-flash--error">
                    <i class="bi bi-x-circle-fill"></i>
                    <span>${sessionScope.errorMsg}</span>
                    <button class="mp-flash__close" onclick="this.parentElement.remove()">x</button>
                </div>
                <c:remove var="errorMsg" scope="session" />
            </c:if>

            <%-- Notification banner --%>
            <c:if test="${unreadNotifCount > 0}">
                <div class="mp-notif-banner">
                    <span>
                        <i class="bi bi-bell-fill"></i>
                        Bạn có <strong>${unreadNotifCount}</strong> thông báo chưa đọc
                    </span>
                    <div class="mp-notif-banner__actions">
                        <a href="${pageContext.request.contextPath}/notifications" class="mp-btn-sm">
                            <i class="bi bi-eye"></i>Xem tất cả
                        </a>
                        <form method="post" action="${pageContext.request.contextPath}/reservation"
                            style="display:inline">
                            <input type="hidden" name="action" value="markAllRead" />
                            <button type="submit" class="mp-btn-sm">
                                <i class="bi bi-check2-all"></i>Đánh dấu đã đọc
                            </button>
                        </form>
                    </div>
                </div>
            </c:if>

            <div class="mp-toolbar">
                <div class="mp-tabs">
                    <button class="mp-tab active" data-filter="WAITING">
                        <i class="bi bi-hourglass-split"></i> Đang chờ
                        <span class="mp-count" id="count-waiting"></span>
                    </button>
                    <button class="mp-tab" data-filter="AVAILABLE">
                        <i class="bi bi-check-circle-fill"></i> Sẵn sàng
                        <span class="mp-count" id="count-available"></span>
                    </button>
                    <button class="mp-tab" data-filter="BORROWED">
                        <i class="bi bi-book"></i> Đã mượn
                        <span class="mp-count" id="count-borrowed"></span>
                    </button>
                    <button class="mp-tab" data-filter="HISTORY">
                        <i class="bi bi-clock-history"></i> Lịch sử
                        <span class="mp-count" id="count-history"></span>
                    </button>
                </div>
                <div class="mp-search">
                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                        stroke-width="2.2">
                        <circle cx="11" cy="11" r="8" />
                        <path d="m21 21-4.35-4.35" />
                    </svg>
                    <input type="text" id="searchInput" placeholder="Tìm theo tên sách, tác giả…" />
                </div>
                <a href="${pageContext.request.contextPath}/books" class="mp-btn-add">
                    <i class="bi bi-plus-lg"></i>Đặt thêm sách
                </a>
            </div>

            <!-- TABLE / EMPTY STATE -->
            <c:choose>
                <c:when test="${empty reservations}">
                    <div class="mp-empty">
                        <div class="mp-empty__icon">
                            <i class="bi bi-bookmark-x" style="font-size:2.5rem;color:#cbd5e1"></i>
                        </div>
                        <h2>Chưa có sách đặt trước nào</h2>
                        <p>Khi sách bạn muốn mượn hết hàng, hãy đặt trước để được thông báo ngay khi sách có sẵn.</p>
                        <a href="${pageContext.request.contextPath}/books" class="btn primary">
                            <i class="bi bi-search"></i> Tìm sách ngay
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="mp-table-wrap">
                        <table class="mp-table" id="resTable">
                            <thead>
                                <tr>
                                    <th>#</th>
                                    <th>Sách</th>
                                    <th>Trạng thái</th>
                                    <th>Vị trí hàng chờ</th>
                                    <th>Ngày đặt</th>
                                    <th>Hạn lấy</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="res" items="${reservations}" varStatus="loop">
                                    <c:set var="resGroup"
                                        value="${(res.status == 'WAITING' || res.status == 'AVAILABLE' || res.status == 'BORROWED') ? 'ACTIVE' : 'HISTORY'}" />
                                    <tr data-status="${res.status}" data-group="${resGroup}"
                                        data-search="${res.bookTitle} ${res.bookAuthor}"
                                        class="${res.status == 'CANCELLED' ? 'row-cancelled' : ''}">

                                        <td class="td-num" data-label="STT">${loop.index + 1}</td>

                                        <td data-label="Sách">
                                            <div class="mp-book-cell">
                                                <c:choose>
                                                    <c:when test="${not empty res.bookImage}">
                                                        <img src="${pageContext.request.contextPath}/${res.bookImage}"
                                                            alt="${res.bookTitle}" class="mp-book-thumb" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="mp-book-icon"><i class="bi bi-book"></i></div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <div class="mp-cell-title">${res.bookTitle}</div>
                                                    <div class="mp-cell-sub">${res.bookAuthor}</div>
                                                </div>
                                            </div>
                                        </td>

                                        <td data-label="Trạng thái">
                                            <c:choose>
                                                <c:when test="${res.status == 'WAITING'}">
                                                    <span class="mp-badge mp-badge--waiting">
                                                        <span class="mp-badge__dot"></span>Đang chờ
                                                    </span>
                                                </c:when>
                                                <c:when test="${res.status == 'AVAILABLE'}">
                                                    <span class="mp-badge mp-badge--available">
                                                        <span class="mp-badge__dot"></span>Sẵn sàng nhận
                                                    </span>
                                                </c:when>
                                                <c:when test="${res.status == 'BORROWED'}">
                                                    <span class="mp-badge mp-badge--borrowed">
                                                        <span class="mp-badge__dot"></span>Đã mượn
                                                    </span>
                                                </c:when>
                                                <c:when test="${res.status == 'CANCELLED'}">
                                                    <span class="mp-badge mp-badge--cancelled is-outline">
                                                        <span class="mp-badge__dot"></span>Đã hủy
                                                    </span>
                                                    <c:if test="${not empty res.rejectReason}">
                                                        <div style="font-size: 0.8rem; color: #ef4444; margin-top: 6px; display: flex; align-items: start; gap: 4px;">
                                                            <i class="bi bi-info-circle-fill" style="margin-top:2px;"></i>
                                                            <span>Lý do: ${res.rejectReason}</span>
                                                        </div>
                                                    </c:if>
                                                </c:when>
                                                <c:when test="${res.status == 'EXPIRED'}">
                                                    <span class="mp-badge mp-badge--expired">
                                                        <span class="mp-badge__dot"></span>Hết hạn
                                                    </span>
                                                </c:when>
                                            </c:choose>
                                        </td>

                                        <td data-label="Vị trí hàng chờ">
                                            <c:choose>
                                                <c:when test="${res.status == 'WAITING' && res.queuePosition != null}">
                                                    <div class="mp-queue-pos ${res.queuePosition == 1 ? 'mp-queue-pos--1' : 'mp-queue-pos--n'}"
                                                        title="Bạn đang ở vị trí ${res.queuePosition} trong hàng chờ">
                                                        ${res.queuePosition}
                                                    </div>
                                                </c:when>
                                                <c:when test="${res.status == 'AVAILABLE'}">
                                                    <span class="mp-queue-available">
                                                        <i class="bi bi-arrow-right-circle-fill"></i> Đến lấy
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:var(--mp-text-muted)">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td data-label="Ngày đặt">
                                            <span class="mp-date">
                                                <fmt:formatDate value="${res.createdAt}" pattern="dd/MM/yyyy" />
                                            </span>
                                            <div class="mp-cell-sub">
                                                <fmt:formatDate value="${res.createdAt}" pattern="HH:mm" />
                                            </div>
                                        </td>

                                        <td data-label="Hạn lấy">
                                            <c:choose>
                                                <c:when test="${not empty res.expiredAt}">
                                                    <div class="mp-date-deadline">
                                                        <i class="bi bi-alarm" style="font-size:.8rem"></i>
                                                        <fmt:formatDate value="${res.expiredAt}" pattern="dd/MM/yyyy" />
                                                    </div>
                                                    <c:if test="${res.daysUntilExpiry <= 1 && res.daysUntilExpiry >= 0}">
                                                        <div class="mp-date-warning">
                                                            <i class="bi bi-exclamation-triangle-fill"></i>
                                                            Còn ${res.daysUntilExpiry == 0 ? 'hôm nay' : '1 ngày'}!
                                                        </div>
                                                    </c:if>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color:var(--mp-text-muted)">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>

                                        <td data-label="Thao tác">
                                            <c:choose>
                                                <c:when test="${res.status == 'WAITING' || res.status == 'AVAILABLE'}">
                                                    <form method="post"
                                                        action="${pageContext.request.contextPath}/reservation"
                                                        onsubmit="return confirmCancel(this)"
                                                        class="mp-inline-form">
                                                        <input type="hidden" name="action" value="cancel" />
                                                        <input type="hidden" name="resId" value="${res.id}" />
                                                        <button type="submit" class="mp-btn-cancel">
                                                            <i class="bi bi-trash3"></i>Hủy
                                                        </button>
                                                    </form>
                                                </c:when>
                                                <c:when test="${res.status == 'CANCELLED'}">
                                                    <a href="${pageContext.request.contextPath}/books/detail?id=${res.bookId}"
                                                        class="mp-btn-reorder">
                                                        <i class="bi bi-arrow-repeat"></i> Đặt lại
                                                    </a>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-size:0.8rem;color:var(--mp-text-muted)">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <nav class="mp-pagination" id="pagination" aria-label="Phân trang"></nav>
                </c:otherwise>
            </c:choose>

        </div>
    </main>

    <jsp:include page="/WEB-INF/views/footer.jsp" />

    <script>
        (function () {
            const ROWS_PER_PAGE = 10;
            let currentFilter = 'WAITING';
            let currentPage = 1;

            const rows = Array.from(document.querySelectorAll('#resTable tbody tr'));
            const searchInput = document.getElementById('searchInput');
            const pagination = document.getElementById('pagination');

            const counts = {
                waiting: document.getElementById('count-waiting'),
                available: document.getElementById('count-available'),
                borrowed: document.getElementById('count-borrowed'),
                history: document.getElementById('count-history'),
            };

            function matchSearch(r) {
                const q = searchInput ? searchInput.value.toLowerCase() : '';
                return !q || (r.dataset.search || '').toLowerCase().includes(q);
            }

            function updateCounts() {
                counts.waiting.textContent = rows.filter(r => r.dataset.status === 'WAITING' && matchSearch(r)).length;
                counts.available.textContent = rows.filter(r => r.dataset.status === 'AVAILABLE' && matchSearch(r)).length;
                counts.borrowed.textContent = rows.filter(r => r.dataset.status === 'BORROWED' && matchSearch(r)).length;
                counts.history.textContent = rows.filter(r => r.dataset.group === 'HISTORY' && matchSearch(r)).length;
            }

            function getVisible() {
                return rows.filter(r => {
                    const statusOk = currentFilter === 'HISTORY' ? r.dataset.group === 'HISTORY' : r.dataset.status === currentFilter;
                    return statusOk && matchSearch(r);
                });
            }

            function render() {
                const visible = getVisible();
                const totalPages = Math.max(1, Math.ceil(visible.length / ROWS_PER_PAGE));
                if (currentPage > totalPages) currentPage = totalPages;

                rows.forEach(r => r.classList.add('hidden-row'));
                const start = (currentPage - 1) * ROWS_PER_PAGE;
                visible.slice(start, start + ROWS_PER_PAGE).forEach(r => r.classList.remove('hidden-row'));

                if (pagination) {
                    pagination.innerHTML = '';
                    if (totalPages <= 1) return;
                    const prev = mkBtn('‹', currentPage === 1);
                    prev.onclick = () => { if (currentPage > 1) { currentPage--; render(); } };
                    pagination.appendChild(prev);
                    for (let i = 1; i <= totalPages; i++) {
                        const b = mkBtn(i, false, i === currentPage);
                        b.onclick = () => { currentPage = i; render(); };
                        pagination.appendChild(b);
                    }
                    const next = mkBtn('›', currentPage === totalPages);
                    next.onclick = () => { if (currentPage < totalPages) { currentPage++; render(); } };
                    pagination.appendChild(next);
                }
            }

            function mkBtn(label, disabled, active) {
                const b = document.createElement('button');
                b.className = 'mp-page-btn' + (active ? ' active' : '');
                b.textContent = label;
                b.disabled = !!disabled;
                return b;
            }

            document.querySelectorAll('.mp-tab').forEach(tab => {
                tab.addEventListener('click', () => {
                    document.querySelectorAll('.mp-tab').forEach(t => t.classList.remove('active'));
                    tab.classList.add('active');
                    currentFilter = tab.dataset.filter;
                    currentPage = 1;
                    render();
                });
            });

            if (searchInput) {
                searchInput.addEventListener('input', () => { currentPage = 1; updateCounts(); render(); });
            }

            updateCounts();
            render();
        })();

        function confirmCancel(form) {
            if (!confirm('Bạn có chắc muốn hủy đặt trước này?\nSau khi hủy, vị trí của bạn trong hàng chờ sẽ bị mất.')) return false;
            const btn = form.querySelector('button[type="submit"]');
            btn.disabled = true;
            btn.innerHTML = '⏳ Đang hủy…';
            return true;
        }
    </script>
</body>

</html>
