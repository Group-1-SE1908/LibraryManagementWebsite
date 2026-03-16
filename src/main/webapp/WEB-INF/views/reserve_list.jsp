<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Danh sách đặt trước – LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        :root {
            --bg: #f0f4f8;
            --surface: #ffffff;
            --border: #e2e8f0;
            --text: #1e293b;
            --text-soft: #64748b;
            --text-muted: #94a3b8;
            --primary: #3b82f6;
            --primary-light: #eff6ff;
            --radius-sm: 6px;
            --radius: 12px;
            --shadow: 0 1px 3px rgba(0,0,0,.08), 0 1px 2px rgba(0,0,0,.04);
        }

        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; display: flex; flex-direction: column; }
        .main-wrap { flex: 1; }

        /* ── PAGE HEADER ── */
        .page-header { background: var(--surface); border-bottom: 1px solid var(--border); padding: 24px 40px; }
        .page-header__inner { max-width: 1100px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; gap: 14px; }
        .page-header__left { display: flex; align-items: center; gap: 14px; }
        .page-header__icon { width: 40px; height: 40px; border-radius: var(--radius-sm); background: var(--primary-light); display: flex; align-items: center; justify-content: center; flex-shrink: 0; color: var(--primary); font-size: 1.2rem; }
        .page-header__title { font-size: 1.2rem; font-weight: 700; color: var(--text); }
        .page-header__sub { font-size: .8rem; color: var(--text-soft); margin-top: 2px; }

        /* ── LIMIT INDICATOR ── */
        .limit-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 6px 14px; border-radius: 99px; font-size: .8rem; font-weight: 600;
            border: 1.5px solid var(--border); background: var(--surface); color: var(--text-soft);
        }
        .limit-pill.warn { border-color: #fbbf24; color: #92400e; background: #fffbeb; }
        .limit-pill.full { border-color: #ef4444; color: #991b1b; background: #fef2f2; }

        /* ── TOOLBAR ── */
        .toolbar { max-width: 1100px; margin: 0 auto; padding: 20px 40px 0; display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
        .filter-tabs { display: flex; gap: 4px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 3px; }
        .filter-tab { padding: 6px 14px; border-radius: 4px; font-size: .82rem; font-weight: 500; cursor: pointer; border: none; background: transparent; color: var(--text-soft); transition: all .15s; white-space: nowrap; display: flex; align-items: center; gap: 5px; text-decoration: none; }
        .filter-tab:hover { color: var(--text); background: var(--bg); }
        .filter-tab.active { background: var(--primary); color: #fff; }
        .count-badge { display: inline-flex; align-items: center; justify-content: center; background: rgba(255,255,255,.25); color: inherit; border-radius: 99px; padding: 0 6px; font-size: .7rem; min-width: 18px; font-weight: 600; }
        .filter-tab:not(.active) .count-badge { background: var(--bg); color: var(--text-muted); }
        .toolbar-right { margin-left: auto; display: flex; align-items: center; gap: 10px; }
        .search-box { display: flex; align-items: center; gap: 8px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius-sm); padding: 7px 12px; transition: border-color .15s; }
        .search-box:focus-within { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(59,130,246,.1); }
        .search-box svg { color: var(--text-muted); flex-shrink: 0; }
        .search-box input { border: none; outline: none; font-family: inherit; font-size: .85rem; color: var(--text); background: transparent; width: 200px; }
        .search-box input::placeholder { color: var(--text-muted); }
        .btn-add { display: inline-flex; align-items: center; gap: 6px; background: var(--primary); color: #fff; border: none; border-radius: var(--radius-sm); padding: 7px 16px; font-size: .85rem; font-weight: 600; cursor: pointer; text-decoration: none; white-space: nowrap; transition: background .15s; }
        .btn-add:hover { background: #2563eb; color: #fff; }

        /* ── CONTENT ── */
        .content { max-width: 1100px; margin: 0 auto; padding: 20px 40px 60px; }

        /* ── FLASH ── */
        .flash { display: flex; align-items: center; gap: 10px; padding: 12px 16px; border-radius: var(--radius-sm); margin-bottom: 16px; font-size: .875rem; }
        .flash--success { background: #f0fdf4; border: 1px solid #86efac; color: #166534; }
        .flash--error   { background: #fef2f2; border: 1px solid #fca5a5; color: #991b1b; }
        .flash__close { margin-left: auto; cursor: pointer; background: none; border: none; font-size: 1.1rem; color: inherit; opacity: .6; }
        .flash__close:hover { opacity: 1; }

        /* ── NOTIFICATION BANNER ── */
        .notif-banner { display: flex; align-items: center; justify-content: space-between; gap: 12px; padding: 12px 16px; border-radius: var(--radius-sm); margin-bottom: 16px; background: #eff6ff; border: 1px solid #93c5fd; font-size: .875rem; color: #1e40af; }
        .notif-banner__actions { display: flex; gap: 8px; }
        .btn-sm { padding: 4px 12px; font-size: .78rem; font-weight: 600; border-radius: var(--radius-sm); border: 1px solid currentColor; background: transparent; cursor: pointer; color: inherit; text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
        .btn-sm:hover { background: rgba(0,0,0,.05); }

        /* ── EMPTY STATE ── */
        .empty-state { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 80px 20px; text-align: center; }
        .empty-state__icon { font-size: 3rem; color: #cbd5e1; margin-bottom: 12px; }
        .empty-state__title { font-size: 1rem; font-weight: 600; color: var(--text-soft); margin-bottom: 6px; }
        .empty-state__sub { font-size: .85rem; color: var(--text-muted); margin-bottom: 20px; }

        /* ── TABLE ── */
        .table-wrap { background: var(--surface); border-radius: var(--radius); border: 1px solid var(--border); box-shadow: var(--shadow); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; font-size: .875rem; }
        thead th { background: #f8fafc; color: var(--text-soft); font-weight: 600; font-size: .72rem; letter-spacing: .06em; text-transform: uppercase; padding: 12px 18px; text-align: left; border-bottom: 1px solid var(--border); }
        tbody tr { border-bottom: 1px solid var(--border); transition: background .1s; }
        tbody tr:last-child { border-bottom: none; }
        tbody tr:hover { background: #f8fafc; }
        tbody tr.hidden-row { display: none; }
        td { padding: 14px 18px; vertical-align: middle; color: var(--text-soft); }
        td.td-num { color: var(--text-muted); font-size: .8rem; width: 40px; }

        /* ── BOOK CELL ── */
        .book-cell { display: flex; align-items: center; gap: 12px; }
        .book-thumb { width: 40px; height: 54px; object-fit: cover; border-radius: 5px; box-shadow: 0 2px 6px rgba(0,0,0,.12); flex-shrink: 0; }
        .book-thumb-ph { width: 40px; height: 54px; background: var(--primary-light); border-radius: 5px; display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 1.2rem; flex-shrink: 0; }
        .book-title { font-weight: 600; color: var(--text); font-size: .88rem; max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .book-author { font-size: .76rem; color: var(--text-muted); margin-top: 2px; }

        /* ── QUEUE POSITION ── */
        .queue-pos { display: inline-flex; align-items: center; justify-content: center; width: 28px; height: 28px; border-radius: 50%; font-size: .8rem; font-weight: 700; }
        .queue-pos--1 { background: #fef9c3; color: #854d0e; border: 2px solid #fbbf24; }  /* vàng - số 1 */
        .queue-pos--n { background: var(--bg); color: var(--text-soft); border: 1.5px solid var(--border); }

        /* ── BADGES ── */
        .badge { display: inline-flex; align-items: center; gap: 5px; padding: 3px 10px; border-radius: 99px; font-size: .75rem; font-weight: 600; white-space: nowrap; border: 1px solid transparent; }
        .badge__dot { width: 5px; height: 5px; border-radius: 50%; flex-shrink: 0; }
        .badge--waiting   { background: #fffbeb; color: #92400e; border-color: #fcd34d; }
        .badge--waiting   .badge__dot { background: #92400e; }
        .badge--available { background: #f0fdf4; color: #166534; border-color: #86efac; }
        .badge--available .badge__dot { background: #166534; }
        .badge--borrowed  { background: #eff6ff; color: #1e40af; border-color: #93c5fd; }
        .badge--borrowed  .badge__dot { background: #1e40af; }
        .badge--cancelled { background: #f8fafc; color: #475569; border-color: #cbd5e1; }
        .badge--cancelled .badge__dot { background: #475569; }
        .badge--expired   { background: #fef2f2; color: #991b1b; border-color: #fca5a5; }
        .badge--expired   .badge__dot { background: #991b1b; }

        /* ── DATE ── */
        .date-main { font-size: .85rem; color: var(--text-soft); }
        .date-time { font-size: .75rem; color: var(--text-muted); margin-top: 1px; }
        .date-deadline { font-size: .83rem; font-weight: 600; color: #ef4444; }
        .date-warning  { font-size: .75rem; color: #f59e0b; margin-top: 2px; font-weight: 500; }

        /* ── CANCEL BTN ── */
        .btn-cancel { display: inline-flex; align-items: center; gap: 5px; font-size: .8rem; font-weight: 500; padding: 5px 12px; border-radius: var(--radius-sm); border: 1.5px solid #ef4444; color: #ef4444; background: transparent; cursor: pointer; transition: all .15s; white-space: nowrap; }
        .btn-cancel:hover { background: #ef4444; color: #fff; }

        /* ── PAGINATION ── */
        .pagination { display: flex; justify-content: center; align-items: center; gap: 4px; margin-top: 20px; }
        .page-btn { width: 32px; height: 32px; border-radius: var(--radius-sm); border: 1px solid var(--border); background: var(--surface); color: var(--text-soft); font-size: .82rem; font-weight: 500; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all .12s; }
        .page-btn:hover { border-color: var(--primary); color: var(--primary); }
        .page-btn.active { background: var(--primary); color: #fff; border-color: var(--primary); }
        .page-btn:disabled { opacity: .35; cursor: default; }

        @media (max-width: 768px) {
            .page-header { padding: 16px 20px; }
            .toolbar { padding: 14px 20px 0; flex-direction: column; align-items: stretch; }
            .toolbar-right { margin-left: 0; flex-wrap: wrap; }
            .search-box input { width: 100%; }
            .content { padding: 14px 20px 40px; }
            thead { display: none; }
            tbody tr { display: block; padding: 12px 16px; }
            td { display: block; padding: 4px 0; border: none; }
            td::before { content: attr(data-label) ': '; font-weight: 600; font-size: .72rem; color: var(--text-muted); text-transform: uppercase; }
        }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="main-wrap">

    <!-- HEADER -->
    <header class="page-header">
        <div class="page-header__inner">
            <div class="page-header__left">
                <div class="page-header__icon"><i class="bi bi-bookmark-star"></i></div>
                <div>
                    <div class="page-header__title">Danh sách đặt trước</div>
                    <div class="page-header__sub">Theo dõi trạng thái các sách bạn đã đặt trước</div>
                </div>
            </div>
            <%-- Hiển thị số lượng reservation đang dùng / tối đa --%>
            <c:set var="activeCount" value="0"/>
            <c:forEach var="r" items="${reservations}">
                <c:if test="${r.status == 'WAITING' || r.status == 'AVAILABLE'}">
                    <c:set var="activeCount" value="${activeCount + 1}"/>
                </c:if>
            </c:forEach>
            <div class="limit-pill ${activeCount >= maxReservations ? 'full' : activeCount >= maxReservations - 1 ? 'warn' : ''}">
                <i class="bi bi-bookmark-check"></i>
                Đặt trước: ${activeCount} / ${maxReservations}
            </div>
        </div>
    </header>

    <!-- TOOLBAR -->
    <div class="toolbar">
        <div class="filter-tabs">
            <a href="#" class="filter-tab active" data-filter="ALL">
                Tất cả <span class="count-badge" id="count-all"></span>
            </a>
            <a href="#" class="filter-tab" data-filter="WAITING">
                <i class="bi bi-hourglass-split"></i>Đang chờ
                <span class="count-badge" id="count-waiting"></span>
            </a>
            <a href="#" class="filter-tab" data-filter="AVAILABLE">
                <i class="bi bi-check-circle"></i>Sẵn sàng
                <span class="count-badge" id="count-available"></span>
            </a>
            <a href="#" class="filter-tab" data-filter="BORROWED">
                <i class="bi bi-book"></i>Đã mượn
                <span class="count-badge" id="count-borrowed"></span>
            </a>
            <a href="#" class="filter-tab" data-filter="CANCELLED">
                <i class="bi bi-x-circle"></i>Đã hủy
                <span class="count-badge" id="count-cancelled"></span>
            </a>
        </div>
        <div class="toolbar-right">
            <div class="search-box">
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2">
                    <circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/>
                </svg>
                <input type="text" id="searchInput" placeholder="Tìm theo tên sách, tác giả…"/>
            </div>
            <a href="${pageContext.request.contextPath}/books" class="btn-add">
                <i class="bi bi-plus-lg"></i>Đặt thêm sách
            </a>
        </div>
    </div>

    <!-- CONTENT -->
    <main class="content">

        <!-- Flash messages -->
        <c:if test="${not empty sessionScope.successMsg}">
            <div class="flash flash--success">
                <i class="bi bi-check-circle-fill"></i>
                <span>${sessionScope.successMsg}</span>
                <button class="flash__close" onclick="this.parentElement.remove()">×</button>
            </div>
            <c:remove var="successMsg" scope="session"/>
        </c:if>
        <c:if test="${not empty sessionScope.errorMsg}">
            <div class="flash flash--error">
                <i class="bi bi-x-circle-fill"></i>
                <span>${sessionScope.errorMsg}</span>
                <button class="flash__close" onclick="this.parentElement.remove()">×</button>
            </div>
            <c:remove var="errorMsg" scope="session"/>
        </c:if>

        <!-- Notification banner (nếu có thông báo chưa đọc) -->
        <c:if test="${unreadNotifCount > 0}">
            <div class="notif-banner">
                <span>
                    <i class="bi bi-bell-fill"></i>
                    Bạn có <strong>${unreadNotifCount}</strong> thông báo chưa đọc
                </span>
                <div class="notif-banner__actions">
                    <a href="${pageContext.request.contextPath}/notifications" class="btn-sm">
                        <i class="bi bi-eye"></i>Xem tất cả
                    </a>
                    <form method="post" action="${pageContext.request.contextPath}/reservation" style="display:inline">
                        <input type="hidden" name="action" value="markAllRead"/>
                        <button type="submit" class="btn-sm">
                            <i class="bi bi-check2-all"></i>Đánh dấu đã đọc
                        </button>
                    </form>
                </div>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${empty reservations}">
                <div class="empty-state">
                    <div class="empty-state__icon"><i class="bi bi-bookmark-x"></i></div>
                    <div class="empty-state__title">Chưa có sách đặt trước nào</div>
                    <p class="empty-state__sub">
                        Khi sách bạn muốn mượn hết hàng, hãy đặt trước để được<br/>thông báo ngay khi sách có sẵn.
                    </p>
                    <a href="${pageContext.request.contextPath}/books" class="btn-add">
                        <i class="bi bi-search"></i>Tìm sách ngay
                    </a>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-wrap">
                    <table id="resTable">
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
                            <tr data-status="${res.status}"
                                data-search="${res.bookTitle} ${res.bookAuthor}">

                                <td class="td-num" data-label="STT">${loop.index + 1}</td>

                                <td data-label="Sách">
                                    <div class="book-cell">
                                        <c:choose>
                                            <c:when test="${not empty res.bookImage}">
                                                <img src="${pageContext.request.contextPath}/${res.bookImage}"
                                                     alt="${res.bookTitle}" class="book-thumb"/>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="book-thumb-ph"><i class="bi bi-book"></i></div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <div class="book-title" title="${res.bookTitle}">${res.bookTitle}</div>
                                            <div class="book-author">
                                                <i class="bi bi-person" style="font-size:.7rem"></i> ${res.bookAuthor}
                                            </div>
                                        </div>
                                    </div>
                                </td>

                                <td data-label="Trạng thái">
                                    <c:choose>
                                        <c:when test="${res.status == 'WAITING'}">
                                            <span class="badge badge--waiting"><span class="badge__dot"></span>Đang chờ</span>
                                        </c:when>
                                        <c:when test="${res.status == 'AVAILABLE'}">
                                            <span class="badge badge--available"><span class="badge__dot"></span>Sẵn sàng nhận</span>
                                        </c:when>
                                        <c:when test="${res.status == 'BORROWED'}">
                                            <span class="badge badge--borrowed"><span class="badge__dot"></span>Đã mượn</span>
                                        </c:when>
                                        <c:when test="${res.status == 'CANCELLED'}">
                                            <span class="badge badge--cancelled"><span class="badge__dot"></span>Đã hủy</span>
                                        </c:when>
                                        <c:when test="${res.status == 'EXPIRED'}">
                                            <span class="badge badge--expired"><span class="badge__dot"></span>Hết hạn</span>
                                        </c:when>
                                    </c:choose>
                                </td>

                                    <%-- Cột queue_position: chỉ hiện khi đang WAITING --%>
                                <td data-label="Vị trí hàng chờ">
                                    <c:choose>
                                        <c:when test="${res.status == 'WAITING' && res.queuePosition != null}">
                                            <div class="queue-pos ${res.queuePosition == 1 ? 'queue-pos--1' : 'queue-pos--n'}"
                                                 title="Bạn đang ở vị trí ${res.queuePosition} trong hàng chờ">
                                                    ${res.queuePosition}
                                            </div>
                                        </c:when>
                                        <c:when test="${res.status == 'AVAILABLE'}">
                                            <span style="color:#166534;font-size:.8rem;font-weight:600">
                                                <i class="bi bi-arrow-right-circle-fill"></i> Đến lấy
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:var(--text-muted)">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td data-label="Ngày đặt">
                                    <div class="date-main">
                                        <fmt:formatDate value="${res.createdAt}" pattern="dd/MM/yyyy"/>
                                    </div>
                                    <div class="date-time">
                                        <fmt:formatDate value="${res.createdAt}" pattern="HH:mm"/>
                                    </div>
                                </td>

                                <td data-label="Hạn lấy">
                                    <c:choose>
                                        <c:when test="${not empty res.expiredAt}">
                                            <div class="date-deadline">
                                                <i class="bi bi-alarm" style="font-size:.8rem"></i>
                                                <fmt:formatDate value="${res.expiredAt}" pattern="dd/MM/yyyy"/>
                                            </div>
                                            <%-- Cảnh báo nếu còn <= 1 ngày --%>
                                            <c:if test="${res.daysUntilExpiry <= 1 && res.daysUntilExpiry >= 0}">
                                                <div class="date-warning">
                                                    <i class="bi bi-exclamation-triangle-fill"></i>
                                                    Còn ${res.daysUntilExpiry == 0 ? 'hôm nay' : '1 ngày'}!
                                                </div>
                                            </c:if>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:var(--text-muted)">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                <td data-label="Thao tác">
                                    <c:choose>
                                        <c:when test="${res.status == 'WAITING' || res.status == 'AVAILABLE'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/reservation"
                                                  onsubmit="return confirmCancel(this)">
                                                <input type="hidden" name="action" value="cancel"/>
                                                <input type="hidden" name="resId" value="${res.id}"/>
                                                <button type="submit" class="btn-cancel">
                                                    <i class="bi bi-trash3"></i>Hủy
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color:var(--text-muted)">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
                <nav class="pagination" id="pagination" aria-label="Phân trang"></nav>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<jsp:include page="/WEB-INF/views/footer.jsp"/>

<script>
    (function () {
        const ROWS_PER_PAGE = 10;
        let currentFilter = 'ALL';
        let currentPage   = 1;

        const rows        = Array.from(document.querySelectorAll('#resTable tbody tr'));
        const searchInput = document.getElementById('searchInput');
        const pagination  = document.getElementById('pagination');

        const counts = {
            all:       document.getElementById('count-all'),
            waiting:   document.getElementById('count-waiting'),
            available: document.getElementById('count-available'),
            borrowed:  document.getElementById('count-borrowed'),
            cancelled: document.getElementById('count-cancelled'),
        };

        function matchSearch(r) {
            const q = searchInput ? searchInput.value.toLowerCase() : '';
            return !q || (r.dataset.search || '').toLowerCase().includes(q);
        }

        function updateCounts() {
            counts.all.textContent       = rows.filter(matchSearch).length;
            counts.waiting.textContent   = rows.filter(r => r.dataset.status === 'WAITING'   && matchSearch(r)).length;
            counts.available.textContent = rows.filter(r => r.dataset.status === 'AVAILABLE' && matchSearch(r)).length;
            counts.borrowed.textContent  = rows.filter(r => r.dataset.status === 'BORROWED'  && matchSearch(r)).length;
            counts.cancelled.textContent = rows.filter(r => r.dataset.status === 'CANCELLED' && matchSearch(r)).length;
        }

        function getVisible() {
            return rows.filter(r => {
                const statusOk = currentFilter === 'ALL' || r.dataset.status === currentFilter;
                return statusOk && matchSearch(r);
            });
        }

        function render() {
            const visible    = getVisible();
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
            b.className = 'page-btn' + (active ? ' active' : '');
            b.textContent = label;
            b.disabled = !!disabled;
            return b;
        }

        document.querySelectorAll('.filter-tab').forEach(tab => {
            tab.addEventListener('click', e => {
                e.preventDefault();
                document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
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
