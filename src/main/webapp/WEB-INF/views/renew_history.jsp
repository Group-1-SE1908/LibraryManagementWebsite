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
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
            </head>

            <body class="mp-body">
                <jsp:include page="/WEB-INF/views/header.jsp" />

                <c:set var="totalRenewals" value="${empty renewalList ? 0 : fn:length(renewalList)}" />

                <!-- HERO -->
                <section class="mp-hero">
                    <div class="mp-hero__inner">
                        <div>
                            <p class="mp-hero__eyebrow">🔄 Gia hạn sách</p>
                            <h1 class="mp-hero__title">Lịch sử gia hạn của bạn</h1>
                            <p class="mp-hero__subtitle">Xem và theo dõi tất cả yêu cầu gia hạn — từ đang chờ duyệt,
                                đã chấp thuận đến bị từ chối, tất cả trong một trang.</p>
                        </div>
                        <div class="mp-hero__cards">
                            <div class="mp-hero__card">
                                <p class="mp-hero__card-label">Tổng yêu cầu</p>
                                <p class="mp-hero__card-value">${totalRenewals}</p>
                                <p class="mp-hero__card-detail">yêu cầu đã gửi</p>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- TOOLBAR -->
                <div class="mp-toolbar">
                    <div class="mp-tabs">
                        <button class="mp-tab active" data-filter="ALL">
                            Tất cả <span class="mp-count" id="count-all"></span>
                        </button>
                        <button class="mp-tab" data-filter="PENDING">
                            Đang chờ <span class="mp-count" id="count-pending"></span>
                        </button>
                        <button class="mp-tab" data-filter="APPROVED">
                            Đã duyệt <span class="mp-count" id="count-approved"></span>
                        </button>
                        <button class="mp-tab" data-filter="REJECTED">
                            Từ chối <span class="mp-count" id="count-rejected"></span>
                        </button>
                    </div>
                    <div class="mp-search">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor"
                            stroke-width="2.2">
                            <circle cx="11" cy="11" r="8" />
                            <path d="m21 21-4.35-4.35" />
                        </svg>
                        <input type="text" id="searchInput" placeholder="Tìm theo tên sách, người liên hệ…" />
                    </div>
                </div>

                <!-- CONTENT -->
                <main class="mp-content">
                    <c:choose>
                        <c:when test="${empty renewalList}">
                            <div class="mp-empty">
                                <div class="mp-empty__icon">📋</div>
                                <p>Chưa có yêu cầu gia hạn nào.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="mp-table-wrap">
                                <table class="mp-table" id="renewalTable">
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
                                                    <div class="mp-book-cell">
                                                        <div class="mp-book-icon">
                                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none"
                                                                stroke="currentColor" stroke-width="2">
                                                                <path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20" />
                                                                <path
                                                                    d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z" />
                                                            </svg>
                                                        </div>
                                                        <div>
                                                            <div class="mp-cell-title">${borrowBookMap[r.borrowId]}
                                                            </div>
                                                            <div class="mp-cell-sub">Mã mượn: #${r.borrowId}</div>
                                                        </div>
                                                    </div>
                                                </td>

                                                <td data-label="Người liên hệ">
                                                    <div class="mp-cell-title">${r.contactName}</div>
                                                    <div class="mp-cell-sub">${r.contactPhone}</div>
                                                    <div class="mp-cell-sub">${r.contactEmail}</div>
                                                </td>

                                                <td data-label="Lý do">
                                                    <div class="mp-reason-text">
                                                        <c:out value="${r.reason}" />
                                                    </div>
                                                </td>

                                                <td data-label="Ngày gửi">
                                                    <div class="mp-date">${r.requestedAt}</div>
                                                </td>

                                                <td data-label="Lý do từ chối">
                                                    <c:choose>
                                                        <c:when test="${not empty r.rejectionReason}">
                                                            <div class="mp-rejection-note">
                                                                <strong>Lý do từ chối</strong>
                                                                <span>
                                                                    <c:out value="${r.rejectionReason}" />
                                                                </span>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="mp-reason-empty">Không có</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>

                                                <td data-label="Trạng thái">
                                                    <c:choose>
                                                        <c:when test="${r.status eq 'PENDING'}">
                                                            <span class="mp-badge mp-badge--pending">
                                                                <span class="mp-badge__dot"></span>Đang chờ
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'APPROVED'}">
                                                            <span class="mp-badge mp-badge--approved">
                                                                <span class="mp-badge__dot"></span>Đã duyệt
                                                            </span>
                                                        </c:when>
                                                        <c:when test="${r.status eq 'REJECTED'}">
                                                            <span class="mp-badge mp-badge--rejected">
                                                                <span class="mp-badge__dot"></span>Từ chối
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="mp-badge mp-badge--pending">
                                                                <span class="mp-badge__dot"></span>${r.status}
                                                            </span>
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
                </script>
                <jsp:include page="footer.jsp" />
            </body>

            </html>