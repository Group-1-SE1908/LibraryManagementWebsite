<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ page import="java.time.LocalDate" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>LBMS – Thống kê mượn trả</title>
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                    <style>
                        .chart-section {
                            display: grid;
                            grid-template-columns: 2fr 3fr;
                            gap: 20px;
                            margin-bottom: 24px;
                        }

                        .chart-wrap {
                            position: relative;
                            height: 280px;
                        }

                        @media (max-width: 900px) {
                            .chart-section {
                                grid-template-columns: 1fr;
                            }
                        }

                        .stat-icon-books {
                            background: rgba(79, 70, 229, .12);
                            color: #4f46e5;
                        }

                        .stat-icon-users {
                            background: rgba(16, 185, 129, .12);
                            color: #10b981;
                        }

                        .stat-icon-borrows {
                            background: rgba(245, 158, 11, .12);
                            color: #f59e0b;
                        }

                        .stat-icon-overdue {
                            background: rgba(239, 68, 68, .12);
                            color: #ef4444;
                        }

                        .stat-val-books {
                            color: #4f46e5;
                        }

                        .stat-val-users {
                            color: #10b981;
                        }

                        .stat-val-borrows {
                            color: #f59e0b;
                        }

                        .stat-val-overdue {
                            color: #ef4444;
                        }
                    </style>
                </head>

                <body class="panel-body">

                    <div class="panel-loader" id="loader">
                        <div class="panel-spinner"></div>
                    </div>

                    <jsp:include page="sidebar.jsp" />

                    <main class="panel-main">

                        <div class="pm-page-header">
                            <div>
                                <h1 class="pm-title"><i class="fas fa-chart-bar"
                                        style="color:var(--panel-accent);margin-right:8px;"></i>Thống kê mượn trả</h1>
                                <p class="pm-subtitle">Theo dõi hoạt động thư viện — <span
                                        id="currentDateDisplay"></span></p>
                            </div>
                        </div>

                        <%-- Filter --%>
                            <div class="pm-card" style="margin-bottom:20px;">
                                <form action="${pageContext.request.contextPath}/admin/statistics" method="GET"
                                    id="statsForm" class="pm-toolbar"
                                    style="flex-wrap:wrap;gap:12px;align-items:flex-end;">
                                    <c:set var="today" value="<%= LocalDate.now().toString() %>" />
                                    <div class="pm-filter-group">
                                        <label class="pm-label">Từ ngày</label>
                                        <input type="date" name="startDate" id="startDate" class="pm-input"
                                            max="${today}" value="${startDate}" />
                                    </div>
                                    <div class="pm-filter-group">
                                        <label class="pm-label">Đến ngày</label>
                                        <input type="date" name="endDate" id="endDate" class="pm-input" max="${today}"
                                            value="${endDate}" />
                                    </div>
                                    <div style="display:flex;gap:8px;align-items:center;">
                                        <button type="submit" class="pm-btn pm-btn-primary">
                                            <i class="fas fa-filter"></i> Lọc dữ liệu
                                        </button>
                                        <button type="button" onclick="resetFilter()" class="pm-btn"
                                            style="background:var(--panel-bg);border:1px solid var(--panel-border);">
                                            <i class="fas fa-undo"></i>
                                        </button>
                                        <button type="button" onclick="handleExportExcel('export')"
                                            class="pm-btn pm-btn-success">
                                            <i class="fas fa-file-excel"></i> Xuất Excel
                                        </button>
                                    </div>
                                </form>
                            </div>

                            <%-- Stat cards --%>
                                <div class="pm-stats">
                                    <div class="pm-stat">
                                        <div>
                                            <div class="pm-stat-label">Tổng sách</div>
                                            <div class="pm-stat-value stat-val-books">${stats.totalBooks}</div>
                                        </div>
                                        <div class="pm-stat-icon stat-icon-books"><i class="fas fa-book"></i></div>
                                    </div>
                                    <div class="pm-stat">
                                        <div>
                                            <div class="pm-stat-label">Bạn đọc</div>
                                            <div class="pm-stat-value stat-val-users">${stats.activeUsers}</div>
                                        </div>
                                        <div class="pm-stat-icon stat-icon-users"><i class="fas fa-users"></i></div>
                                    </div>
                                    <div class="pm-stat">
                                        <div>
                                            <div class="pm-stat-label">Lượt mượn</div>
                                            <div class="pm-stat-value stat-val-borrows">${stats.totalBorrows}</div>
                                        </div>
                                        <div class="pm-stat-icon stat-icon-borrows"><i class="fas fa-exchange-alt"></i>
                                        </div>
                                    </div>
                                    <div class="pm-stat">
                                        <div>
                                            <div class="pm-stat-label">Quá hạn</div>
                                            <div class="pm-stat-value stat-val-overdue">${stats.overdueBooks}</div>
                                        </div>
                                        <div class="pm-stat-icon stat-icon-overdue"><i class="fas fa-clock"></i></div>
                                    </div>
                                </div>

                                <%-- Chart + Top books --%>
                                    <div class="chart-section">
                                        <div class="pm-card">
                                            <h6
                                                style="font-size:.8rem;font-weight:700;text-transform:uppercase;color:var(--panel-accent);margin:0 0 16px;">
                                                Tỉ lệ trạng thái mượn
                                            </h6>
                                            <div class="chart-wrap">
                                                <canvas id="statusChart"></canvas>
                                            </div>
                                        </div>
                                        <div class="pm-card">
                                            <h6
                                                style="font-size:.8rem;font-weight:700;text-transform:uppercase;color:var(--panel-accent);margin:0 0 16px;">
                                                Top 5 sách mượn nhiều nhất
                                            </h6>
                                            <div class="pm-table-wrap">
                                                <table class="pm-table">
                                                    <thead>
                                                        <tr>
                                                            <th>Tên đầu sách</th>
                                                            <th>Thể loại</th>
                                                            <th style="text-align:right;">Lượt mượn</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach items="${stats.topBooks}" var="b">
                                                            <tr>
                                                                <td
                                                                    style="max-width:200px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-weight:600;">
                                                                    ${b.title}</td>
                                                                <td><span
                                                                        class="pm-badge pm-badge-neutral">${b.category}</span>
                                                                </td>
                                                                <td style="text-align:right;"><span
                                                                        class="pm-badge pm-badge-primary">${b.borrowCount}</span>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Detailed records --%>
                                        <div class="pm-card">
                                            <h6
                                                style="font-size:.8rem;font-weight:700;text-transform:uppercase;color:var(--panel-accent);margin:0 0 16px;">
                                                Nhật ký mượn trả chi tiết
                                            </h6>
                                            <div class="pm-table-wrap">
                                                <table class="pm-table">
                                                    <thead>
                                                        <tr>
                                                            <th style="width:70px;">Mã</th>
                                                            <th>Người mượn</th>
                                                            <th>Sách / Barcode</th>
                                                            <th>Ngày mượn</th>
                                                            <th>Hạn trả</th>
                                                            <th>Phạt</th>
                                                            <th>Trạng thái</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach items="${stats.detailedRecords}" var="d">
                                                            <tr>
                                                                <td><code
                                                                        style="color:var(--panel-text-sub);">#${d.orderId}</code>
                                                                </td>
                                                                <td>
                                                                    <div style="font-weight:600;font-size:.875rem;">
                                                                        ${d.borrowerName}</div>
                                                                    <div
                                                                        style="font-size:.75rem;color:var(--panel-text-sub);">
                                                                        ${d.email}</div>
                                                                </td>
                                                                <td>
                                                                    <div
                                                                        style="font-weight:600;font-size:.875rem;max-width:180px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
                                                                        ${d.bookTitle}</div>
                                                                    <div
                                                                        style="font-size:.75rem;color:var(--panel-accent);">
                                                                        ${d.barcode != null ? d.barcode : 'N/A'}</div>
                                                                </td>
                                                                <td
                                                                    style="font-size:.8rem;color:var(--panel-text-sub);">
                                                                    ${d.borrowDate}</td>
                                                                <td
                                                                    style="font-size:.8rem;color:var(--panel-text-sub);">
                                                                    ${d.returnDate != null ? d.returnDate : '—'}</td>
                                                                <td
                                                                    style="color:var(--panel-danger);font-weight:700;font-size:.875rem;">
                                                                    <fmt:formatNumber value="${d.fineAmount}"
                                                                        type="currency" currencySymbol="₫" />
                                                                </td>
                                                                <td>
                                                                    <span
                                                                        class="pm-badge ${d.status == 'RETURNED' ? 'pm-badge-success' : (d.status == 'OVERDUE' ? 'pm-badge-danger' : 'pm-badge-warning')}">
                                                                        <c:choose>
                                                                            <c:when test="${d.status == 'RETURNED'}">Đã
                                                                                trả</c:when>
                                                                            <c:when test="${d.status == 'OVERDUE'}">Quá
                                                                                hạn</c:when>
                                                                            <c:when test="${d.status == 'BORROWING'}">
                                                                                Đang mượn</c:when>
                                                                            <c:otherwise>${d.status}</c:otherwise>
                                                                        </c:choose>
                                                                    </span>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                        <c:if test="${empty stats.detailedRecords}">
                                                            <tr>
                                                                <td colspan="7">
                                                                    <div class="pm-empty"><i class="fas fa-inbox"></i>
                                                                        <p>Không có dữ liệu.</p>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:if>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>

                    </main>

                    <script>
                        document.getElementById('currentDateDisplay').innerText = new Date().toLocaleDateString('vi-VN', {
                            weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
                        });

                        function handleExportExcel(action) {
                            const start = document.getElementById('startDate').value;
                            const end = document.getElementById('endDate').value;
                            let url = "${pageContext.request.contextPath}/admin/statistics?action=" + action;
                            if (start) url += "&startDate=" + start;
                            if (end) url += "&endDate=" + end;
                            window.location.href = url;
                        }

                        function resetFilter() {
                            window.location.href = "${pageContext.request.contextPath}/admin/statistics";
                        }

                        document.getElementById('statsForm').onsubmit = function (e) {
                            const start = document.getElementById('startDate').value;
                            const end = document.getElementById('endDate').value;
                            if ((start && !end) || (!start && end)) {
                                alert("Vui lòng chọn đủ cả 'Từ ngày' và 'Đến ngày'!");
                                e.preventDefault(); return false;
                            }
                            if (start && end && start > end) {
                                alert("Lỗi: Ngày bắt đầu không thể sau ngày kết thúc!");
                                e.preventDefault(); return false;
                            }
                            document.getElementById('loader').style.display = 'flex';
                        };

                        const dataMap = {};
                        <c:forEach items="${stats.statusCounts}" var="e">
                            dataMap["${e.key}"] = ${e.value};
                        </c:forEach>

                        const ctx = document.getElementById('statusChart').getContext('2d');
                        const keys = Object.keys(dataMap);
                        const values = Object.values(dataMap);
                        const totalValue = values.reduce((a, b) => a + b, 0);

                        if (keys.length === 0 || totalValue === 0) {
                            new Chart(ctx, {
                                type: 'doughnut',
                                data: {
                                    labels: ['Không có dữ liệu'],
                                    datasets: [{ data: [1], backgroundColor: ['#f1f5f9'], borderWidth: 0 }]
                                },
                                options: { cutout: '80%', plugins: { legend: { display: false } } }
                            });
                        } else {
                            new Chart(ctx, {
                                type: 'doughnut',
                                data: {
                                    labels: keys,
                                    datasets: [{
                                        data: values,
                                        backgroundColor: ['#4f46e5', '#10b981', '#f59e0b', '#ef4444'],
                                        borderWidth: 2,
                                        borderColor: '#ffffff'
                                    }]
                                },
                                options: {
                                    responsive: true,
                                    maintainAspectRatio: false,
                                    cutout: '75%',
                                    plugins: {
                                        legend: {
                                            position: 'bottom',
                                            labels: { usePointStyle: true, padding: 20, font: { family: 'Inter', size: 12 } }
                                        }
                                    }
                                }
                            });
                        }
                    </script>
                </body>

                </html>