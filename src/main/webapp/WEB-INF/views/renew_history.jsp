<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Danh sách yêu cầu gia hạn | LBMS Portal</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap"
                    rel="stylesheet" />
                <style>
                    *,
                    *::before,
                    *::after {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    :root {
                        --bg: #f4f6fb;
                        --surface: #ffffff;
                        --border: #dfe4ff;
                        --text: #1e293b;
                        --text-soft: #64748b;
                        --text-muted: #94a3b8;
                        --primary: #2f49f5;
                        --primary-light: #eff6ff;
                        --pending-bg: #fffbeb;
                        --pending-bd: #fcd34d;
                        --pending-tx: #92400e;
                        --approved-bg: #f0fdf4;
                        --approved-bd: #86efac;
                        --approved-tx: #166534;
                        --rejected-bg: #fef2f2;
                        --rejected-bd: #fca5a5;
                        --rejected-tx: #991b1b;
                        --radius-sm: 6px;
                        --radius: 14px;
                        --shadow: 0 1px 3px rgba(0, 0, 0, .08), 0 1px 2px rgba(0, 0, 0, .04);
                    }

                    body {
                        font-family: 'Inter', sans-serif;
                        background: var(--bg);
                        color: var(--text);
                        min-height: 100vh;
                    }

                    /* ── HERO ── */
                    .renew-hero {
                        padding: 60px 0 50px;
                        background: linear-gradient(135deg, #0c6cd0 0%, #2f49f5 65%, #7c3aed 100%);
                        color: white;
                        position: relative;
                        overflow: hidden;
                    }

                    .renew-hero::after {
                        content: '';
                        position: absolute;
                        inset: 0;
                        background: radial-gradient(circle at top right, rgba(255, 255, 255, 0.35), transparent 55%);
                        pointer-events: none;
                    }

                    .renew-hero__inner {
                        position: relative;
                        z-index: 1;
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 0 40px;
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
                        gap: 28px;
                        align-items: center;
                    }

                    .renew-hero__eyebrow {
                        font-size: 0.75rem;
                        letter-spacing: 0.3em;
                        text-transform: uppercase;
                        color: rgba(255, 255, 255, 0.8);
                        margin: 0 0 10px;
                    }

                    .renew-hero h1 {
                        font-size: clamp(24px, 3.5vw, 40px);
                        font-weight: 700;
                        line-height: 1.2;
                        margin: 0 0 10px;
                        color: white;
                    }

                    .renew-hero p.lead {
                        font-size: 1rem;
                        color: rgba(255, 255, 255, 0.9);
                        margin: 0;
                    }

                    .renew-hero__card {
                        background: rgba(255, 255, 255, 0.15);
                        border: 1px solid rgba(255, 255, 255, 0.3);
                        border-radius: 20px;
                        padding: 22px 26px;
                        box-shadow: 0 20px 35px rgba(12, 108, 208, 0.35);
                    }

                    .renew-hero__card h3 {
                        margin: 0 0 6px;
                        font-size: 0.82rem;
                        letter-spacing: 0.18em;
                        text-transform: uppercase;
                        color: rgba(255, 255, 255, 0.85);
                    }

                    .renew-hero__stat {
                        font-size: 2.8rem;
                        font-weight: 700;
                        line-height: 1;
                        margin-bottom: 6px;
                        color: white;
                    }

                    .renew-hero__card small {
                        font-size: 0.85rem;
                        color: rgba(255, 255, 255, 0.8);
                    }

                    /* ── TOOLBAR ── */
                    .toolbar {
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 28px 40px 0;
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        flex-wrap: wrap;
                    }

                    .filter-tabs {
                        display: flex;
                        gap: 4px;
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: var(--radius-sm);
                        padding: 3px;
                    }

                    .filter-tab {
                        padding: 6px 14px;
                        border-radius: 4px;
                        font-size: .82rem;
                        font-weight: 500;
                        cursor: pointer;
                        border: none;
                        background: transparent;
                        color: var(--text-soft);
                        transition: all .15s;
                        white-space: nowrap;
                        display: flex;
                        align-items: center;
                        gap: 0;
                    }

                    .filter-tab:hover {
                        color: var(--text);
                        background: var(--bg);
                    }

                    .filter-tab.active {
                        background: var(--primary);
                        color: #fff;
                    }

                    .count-badge {
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        background: rgba(255, 255, 255, .25);
                        color: inherit;
                        border-radius: 99px;
                        padding: 0 6px;
                        font-size: .7rem;
                        min-width: 18px;
                        margin-left: 5px;
                        font-weight: 600;
                    }

                    .filter-tab:not(.active) .count-badge {
                        background: var(--bg);
                        color: var(--text-muted);
                    }

                    .search-box {
                        margin-left: auto;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: var(--radius-sm);
                        padding: 7px 12px;
                        transition: border-color .15s;
                    }

                    .search-box:focus-within {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 3px rgba(47, 73, 245, .1);
                    }

                    .search-box svg {
                        color: var(--text-muted);
                        flex-shrink: 0;
                    }

                    .search-box input {
                        border: none;
                        outline: none;
                        font-family: inherit;
                        font-size: .85rem;
                        color: var(--text);
                        background: transparent;
                        width: 220px;
                    }

                    .search-box input::placeholder {
                        color: var(--text-muted);
                    }

                    /* ── CONTENT ── */
                    .content {
                        max-width: 1100px;
                        margin: 0 auto;
                        padding: 20px 40px 60px;
                    }

                    /* ── EMPTY STATE ── */
                    .empty-state {
                        background: var(--surface);
                        border: 1px solid var(--border);
                        border-radius: var(--radius);
                        padding: 80px 20px;
                        text-align: center;
                    }

                    .empty-state__icon {
                        font-size: 2.5rem;
                        margin-bottom: 12px;
                    }

                    .empty-state__text {
                        font-size: .9rem;
                        color: var(--text-soft);
                    }

                    /* ── TABLE ── */
                    .table-wrap {
                        background: var(--surface);
                        border-radius: var(--radius);
                        border: 1px solid var(--border);
                        box-shadow: 0 10px 40px rgba(15, 23, 42, 0.08);
                        overflow: hidden;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: .875rem;
                    }

                    thead th {
                        background: #f8fafc;
                        color: var(--text-soft);
                        font-weight: 600;
                        font-size: .72rem;
                        letter-spacing: .06em;
                        text-transform: uppercase;
                        padding: 14px 18px;
                        text-align: left;
                        border-bottom: 1px solid var(--border);
                    }

                    tbody tr {
                        border-bottom: 1px solid var(--border);
                        transition: background .1s;
                    }

                    tbody tr:last-child {
                        border-bottom: none;
                    }

                    tbody tr:hover {
                        background: #f8fafc;
                    }

                    tbody tr.hidden-row {
                        display: none;
                    }

                    td {
                        padding: 14px 18px;
                        vertical-align: middle;
                        color: var(--text-soft);
                    }

                    td.td-num {
                        color: var(--text-muted);
                        font-size: .8rem;
                        width: 40px;
                    }

                    .book-cell {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                    }

                    .book-icon {
                        width: 36px;
                        height: 36px;
                        border-radius: 8px;
                        background: var(--primary-light);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        flex-shrink: 0;
                        color: var(--primary);
                    }

                    .book-title {
                        font-weight: 600;
                        color: var(--text);
                        font-size: .88rem;
                    }

                    .book-meta {
                        font-size: .76rem;
                        color: var(--text-muted);
                        margin-top: 2px;
                    }

                    .contact-name {
                        font-weight: 500;
                        color: var(--text);
                        font-size: .88rem;
                    }

                    .contact-sub {
                        font-size: .77rem;
                        color: var(--text-muted);
                        margin-top: 1px;
                    }

                    .reason-text {
                        font-size: .83rem;
                        color: var(--text-soft);
                        max-width: 200px;
                        line-height: 1.45;
                        display: -webkit-box;
                        -webkit-line-clamp: 2;
                        -webkit-box-orient: vertical;
                        overflow: hidden;
                    }

                    .date-text {
                        font-size: .83rem;
                        color: var(--text-soft);
                        white-space: nowrap;
                    }

                    .rejection-note {
                        font-size: .78rem;
                        color: #991b1b;
                        border-radius: 10px;
                        border: 1px solid #fecaca;
                        background: #fff5f5;
                        padding: 8px 10px;
                        margin-top: 8px;
                        max-width: 220px;
                    }

                    .rejection-note strong {
                        display: block;
                        margin-bottom: 4px;
                        font-size: .7rem;
                        letter-spacing: .08em;
                        text-transform: uppercase;
                    }

                    .reason-empty {
                        font-size: .8rem;
                        color: var(--text-muted);
                        font-style: italic;
                    }

                    /* ── BADGE ── */
                    .badge {
                        display: inline-flex;
                        align-items: center;
                        gap: 5px;
                        padding: 3px 10px;
                        border-radius: 99px;
                        font-size: .75rem;
                        font-weight: 600;
                        white-space: nowrap;
                        border: 1px solid transparent;
                    }

                    .badge__dot {
                        width: 5px;
                        height: 5px;
                        border-radius: 50%;
                        flex-shrink: 0;
                    }

                    .badge--pending {
                        background: var(--pending-bg);
                        color: var(--pending-tx);
                        border-color: var(--pending-bd);
                    }

                    .badge--pending .badge__dot {
                        background: var(--pending-tx);
                    }

                    .badge--approved {
                        background: var(--approved-bg);
                        color: var(--approved-tx);
                        border-color: var(--approved-bd);
                    }

                    .badge--approved .badge__dot {
                        background: var(--approved-tx);
                    }

                    .badge--rejected {
                        background: var(--rejected-bg);
                        color: var(--rejected-tx);
                        border-color: var(--rejected-bd);
                    }

                    .badge--rejected .badge__dot {
                        background: var(--rejected-tx);
                    }

                    /* ── PAGINATION ── */
                    .pagination {
                        display: flex;
                        justify-content: center;
                        align-items: center;
                        gap: 4px;
                        margin-top: 20px;
                    }

                    .page-btn {
                        width: 32px;
                        height: 32px;
                        border-radius: var(--radius-sm);
                        border: 1px solid var(--border);
                        background: var(--surface);
                        color: var(--text-soft);
                        font-size: .82rem;
                        font-weight: 500;
                        cursor: pointer;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        transition: all .12s;
                    }

                    .page-btn:hover {
                        border-color: var(--primary);
                        color: var(--primary);
                    }

                    .page-btn.active {
                        background: var(--primary);
                        color: #fff;
                        border-color: var(--primary);
                    }

                    .page-btn:disabled {
                        opacity: .35;
                        cursor: default;
                    }

                    @media (max-width: 768px) {
                        .renew-hero__inner {
                            padding: 0 20px;
                        }

                        .toolbar {
                            padding: 16px 20px 0;
                        }

                        .content {
                            padding: 14px 20px 40px;
                        }

                        .search-box {
                            margin-left: 0;
                            width: 100%;
                        }

                        .search-box input {
                            width: 100%;
                        }

                        thead {
                            display: none;
                        }

                        tbody tr {
                            display: block;
                            padding: 12px 16px;
                        }

                        td {
                            display: block;
                            padding: 4px 0;
                            border: none;
                        }

                        td::before {
                            content: attr(data-label) ': ';
                            font-weight: 600;
                            font-size: .72rem;
                            color: var(--text-muted);
                            text-transform: uppercase;
                        }
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/views/header.jsp" />

                <c:set var="totalRenewals" value="${empty renewalList ? 0 : fn:length(renewalList)}" />

                <!-- HERO -->
                <section class="renew-hero">
                    <div class="renew-hero__inner">
                        <div>
                            <p class="renew-hero__eyebrow">Gia hạn</p>
                            <h1>Yêu cầu gia hạn sách</h1>
                            <p class="lead">Theo dõi trạng thái các yêu cầu gia hạn sách của bạn tại thư viện LBMS.</p>
                        </div>
                        <div class="renew-hero__card">
                            <h3>Tổng yêu cầu</h3>
                            <div class="renew-hero__stat">${totalRenewals}</div>
                            <small>yêu cầu đang theo dõi</small>
                        </div>
                    </div>
                </section>

                <!-- TOOLBAR -->
                <div class="toolbar">
                    <div class="filter-tabs">
                        <button class="filter-tab active" data-filter="ALL">
                            Tất cả <span class="count-badge" id="count-all"></span>
                        </button>
                        <button class="filter-tab" data-filter="PENDING">
                            Đang chờ <span class="count-badge" id="count-pending"></span>
                        </button>
                        <button class="filter-tab" data-filter="APPROVED">
                            Đã duyệt <span class="count-badge" id="count-approved"></span>
                        </button>
                        <button class="filter-tab" data-filter="REJECTED">
                            Từ chối <span class="count-badge" id="count-rejected"></span>
                        </button>
                    </div>
                    <div class="search-box">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2.2">
                            <circle cx="11" cy="11" r="8" />
                            <path d="m21 21-4.35-4.35" />
                        </svg>
                        <input type="text" id="searchInput" placeholder="Tìm theo tên sách, người liên hệ…" />
                    </div>
                </div>

                <!-- CONTENT -->
                <main class="content">
                    <c:choose>
                        <c:when test="${empty renewalList}">
                            <div class="empty-state">
                                <div class="empty-state__icon">📋</div>
                                <p class="empty-state__text">Chưa có yêu cầu gia hạn nào.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="table-wrap">
                                <table id="renewalTable">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Sách</th>
                                            <th>Người liên hệ</th>
                                            <th>Lý do</th>
                                            <th>Ngày gửi</th>
                                            <th>Lý do từ chối</th>
                                            <th>Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach var="r" items="${renewalList}" varStatus="loop">
                                            <tr data-status="${r.status}"
                                                data-search="${borrowBookMap[r.borrowId]} ${r.contactName} ${r.reason} ${r.rejectionReason}">

                                                <td class="td-num" data-label="STT">${loop.index + 1}</td>

                                                <td data-label="Sách">
                                                    <div class="book-cell">
                                                        <div class="book-icon">
                                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                                                stroke="currentColor" stroke-width="2">
                                                                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                                                <path
                                                                    d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
                                                            </svg>
                                                        </div>
                                                        <div>
                                                            <div class="book-title">${borrowBookMap[r.borrowId]}</div>
                                                            <div class="book-meta">Mã mượn: #${r.borrowId}</div>
                                                        </div>
                                                    </div>
                                                </td>

                                                <td data-label="Người liên hệ">
                                                    <div class="contact-name">${r.contactName}</div>
                                                    <div class="contact-sub">${r.contactPhone}</div>
                                                    <div class="contact-sub">${r.contactEmail}</div>
                                                </td>

                                                <td data-label="Lý do">
                                                    <div class="reason-text">
                                                        <c:out value="${r.reason}" />
                                                    </div>
                                                </td>

                                                <td data-label="Ngày gửi">
                                                    <div class="date-text">${r.requestedAt}</div>
                                                </td>

                                                <td data-label="Lý do từ chối">
                                                    <c:choose>
                                                        <c:when test="${not empty r.rejectionReason}">
                                                            <div class="rejection-note">
                                                                <strong>Lý do từ chối</strong>
                                                                <span>
                                                                    <c:out value="${r.rejectionReason}" />
                                                                </span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="reason-empty">Không có</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <td data-label="Trạng thái">
                                                    <c:choose>
                                                        <c:when test="${r.status eq 'PENDING'}">
                                                            <span class="badge badge--pending">
                                                                <span class="badge__dot"></span>Đang chờ
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'APPROVED'}">
                                                            <span class="badge badge--approved">
                                                                <span class="badge__dot"></span>Đã duyệt
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'REJECTED'}">
                                                            <span class="badge badge--rejected">
                                                                <span class="badge__dot"></span>Từ chối
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="badge badge--pending">
                                                                <span class="badge__dot"></span>${r.status}
                                                            </span>
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

                <script>
                    (function () {
                        const ROWS_PER_PAGE = 10;
                        let currentFilter = 'ALL';
                        let currentPage = 1;

                        const rows = Array.from(document.querySelectorAll('#renewalTable tbody tr'));
                        const searchInput = document.getElementById('searchInput');
                        const pagination = document.getElementById('pagination');
                        const countAll = document.getElementById('count-all');
                        const countPending = document.getElementById('count-pending');
                        const countApproved = document.getElementById('count-approved');
                        const countRejected = document.getElementById('count-rejected');

                        function matchSearch(r) {
                            const q = searchInput ? searchInput.value.toLowerCase() : '';
                            return !q || (r.dataset.search || '').toLowerCase().includes(q);
                        }

                        function updateCounts() {
                            countAll.textContent = rows.filter(matchSearch).length;
                            countPending.textContent = rows.filter(r => r.dataset.status === 'PENDING' && matchSearch(r)).length;
                            countApproved.textContent = rows.filter(r => r.dataset.status === 'APPROVED' && matchSearch(r)).length;
                            countRejected.textContent = rows.filter(r => r.dataset.status === 'REJECTED' && matchSearch(r)).length;
                        }

                        function getVisible() {
                            return rows.filter(r => {
                                const statusOk = currentFilter === 'ALL' || r.dataset.status === currentFilter;
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
                            b.className = 'page-btn' + (active ? ' active' : '');
                            b.textContent = label;
                            b.disabled = !!disabled;
                            return b;
                        }

                        document.querySelectorAll('.filter-tab').forEach(tab => {
                            tab.addEventListener('click', () => {
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
                </script>
                <jsp:include page="footer.jsp" />
            </body>

            </html>