<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
                <%@ page import="java.time.LocalDate" %>
                    <!DOCTYPE html>
                    <html lang="vi">

                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>Admin Dashboard | LBMS</title>
                        <link rel="stylesheet"
                            href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
                        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                            rel="stylesheet">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
                        <style>
                            .filter-form {
                                display: flex;
                                align-items: center;
                                gap: 0.75rem;
                                flex-wrap: wrap;
                            }

                            .input-group {
                                display: flex;
                                align-items: center;
                                gap: 0.5rem;
                                font-size: .875rem;
                                color: var(--panel-text-sub);
                            }
                        </style>
                    </head>

                    <body class="panel-body">
                        <div class="panel-loader" id="loader">
                            <div class="panel-spinner"></div>
                        </div>

                        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                        <main class="panel-main">
                            <div class="pm-header">
                                <h1 class="pm-title">Báo cáo tổng quát</h1>
                                <p class="pm-subtitle" id="currentDateDisplay"></p>
                            </div>

                            <div class="pm-toolbar">
                                <form id="statsForm" action="${pageContext.request.contextPath}/admin/dashboard"
                                    method="GET" class="filter-form">
                                    <c:set var="today" value="<%= LocalDate.now().toString() %>" />
                                    <div class="input-group">
                                        <span>Từ:</span>
                                        <input type="date" name="startDate" id="startDate" class="pm-input"
                                            max="${today}" value="${startDate}">
                                    </div>
                                    <div class="input-group">
                                        <span>Đến:</span>
                                        <input type="date" name="endDate" id="endDate" class="pm-input" max="${today}"
                                            value="${endDate}">
                                    </div>
                                    <button type="submit" class="pm-btn pm-btn-primary"><i class="fas fa-filter"></i>
                                        Lọc</button>
                                    <button type="button" onclick="resetFilter()" class="pm-btn pm-btn-outline"><i
                                            class="fas fa-undo"></i> Reset</button>
                                </form>
                                <button onclick="handleExportExcel('export')" class="pm-btn pm-btn-success">
                                    <i class="fas fa-file-excel"></i> Xuất File Excel
                                </button>
                            </div>

                            <div class="pm-stats">
                                <div class="pm-stat">
                                    <div>
                                        <div class="pm-stat-label">Tổng số sách</div>
                                        <div class="pm-stat-value">${dashboardData.totalBooks}</div>
                                    </div>
                                    <div class="pm-stat-icon" style="background:#ede9fe;color:#6366f1;"><i
                                            class="fas fa-book"></i></div>
                                </div>
                                <div class="pm-stat">
                                    <div>
                                        <div class="pm-stat-label">Bạn đọc</div>
                                        <div class="pm-stat-value">${dashboardData.activeUsers}</div>
                                    </div>
                                    <div class="pm-stat-icon" style="background:#dcfce7;color:#15803d;"><i
                                            class="fas fa-users"></i></div>
                                </div>
                                <div class="pm-stat">
                                    <div>
                                        <div class="pm-stat-label">Đang mượn</div>
                                        <div class="pm-stat-value" style="color:var(--panel-info);">
                                            ${dashboardData.pendingReturns}</div>
                                    </div>
                                    <div class="pm-stat-icon" style="background:#e0f2fe;color:#0369a1;"><i
                                            class="fas fa-book-reader"></i></div>
                                </div>
                                <div class="pm-stat">
                                    <div>
                                        <div class="pm-stat-label">Quá hạn</div>
                                        <div class="pm-stat-value" style="color:var(--panel-danger);">
                                            ${dashboardData.overdueBooks}</div>
                                    </div>
                                    <div class="pm-stat-icon" style="background:#fee2e2;color:#ef4444;"><i
                                            class="fas fa-history"></i></div>
                                </div>
                                <div class="pm-stat">
                                    <div>
                                        <div class="pm-stat-label">Tiền phạt đã thu</div>
                                        <div class="pm-stat-value" style="color:#15803d;">
                                            <fmt:formatNumber value="${dashboardData.finesCollected}" pattern="#,##0" />
                                            ₫
                                        </div>
                                    </div>
                                    <div class="pm-stat-icon" style="background:#dcfce7;color:#15803d;"><i
                                            class="fas fa-hand-holding-usd"></i></div>
                                </div>
                                <div class="pm-stat">
                                    <div>
                                        <div class="pm-stat-label">Tiền phạt chưa thu</div>
                                        <div class="pm-stat-value" style="color:#f59e0b;">
                                            <fmt:formatNumber value="${dashboardData.finesPending}"
                                                pattern="#,##0 '₫'" />
                                        </div>
                                    </div>
                                    <div class="pm-stat-icon" style="background:#fef3c7;color:#b45309;"><i
                                            class="fas fa-clock"></i></div>
                                </div>
                            </div>

                            <div class="pm-charts">
                                <div class="pm-card">
                                    <div class="pm-card-header">
                                        <h3 class="pm-card-title">Top 5 sách mượn nhiều nhất</h3>
                                    </div>
                                    <div style="height:300px;"><canvas id="bookChart"></canvas></div>
                                </div>
                                <div class="pm-card">
                                    <div class="pm-card-header">
                                        <h3 class="pm-card-title">Phân bổ tiền phạt</h3>
                                    </div>
                                    <div style="height:250px;"><canvas id="fineChart"></canvas></div>
                                </div>
                            </div>

                            <div class="pm-card">
                                <div class="pm-card-header">
                                    <h3 class="pm-card-title">Thành viên hoạt động tích cực</h3>
                                </div>
                                <div class="pm-table-wrap">
                                    <table class="pm-table">
                                        <thead>
                                            <tr>
                                                <th>STT</th>
                                                <th>Thành viên</th>
                                                <th>Vai trò</th>
                                                <th>Trạng thái</th>
                                                <th style="text-align:center;">Tổng lượt mượn</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${dashboardData.topUsers}" var="u" varStatus="loop">
                                                <tr>
                                                    <td>${loop.index + 1}</td>
                                                    <td>
                                                        <div class="pm-user">
                                                            <div class="pm-user-avatar">
                                                                <c:choose>
                                                                    <c:when test="${not empty u.avatar}">
                                                                        <img src="${pageContext.request.contextPath}/${u.avatar}"
                                                                            alt="">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        ${fn:substring(u.fullName, 0, 1).toUpperCase()}
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div>
                                                                <strong>${u.fullName}</strong><br>
                                                                <small
                                                                    style="color:var(--panel-text-sub);">${u.email}</small>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>${u.roleName}</td>
                                                    <td>
                                                        <span
                                                            class="pm-badge ${u.status == 'ACTIVE' ? 'pm-badge-success' : 'pm-badge-danger'}">
                                                            ${u.status == 'ACTIVE' ? 'Hoạt động' : 'Khóa'}
                                                        </span>
                                                    </td>
                                                    <td style="text-align:center;"><strong>${u.totalBorrows}</strong>
                                                    </td>
                                                </tr>
                                            </c:forEach>
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
                                let url = "${pageContext.request.contextPath}/admin/dashboard?action=" + action;
                                if (start) url += "&startDate=" + start;
                                if (end) url += "&endDate=" + end;
                                window.location.href = url;
                            }

                            function resetFilter() {
                                window.location.href = "${pageContext.request.contextPath}/admin/dashboard";
                            }

                            document.getElementById('statsForm').onsubmit = function (e) {
                                const start = document.getElementById('startDate').value;
                                const end = document.getElementById('endDate').value;

                                if ((start && !end) || (!start && end)) {
                                    alert("Vui lòng chọn đầy đủ 'Từ ngày' và 'Đến ngày'!");
                                    e.preventDefault();
                                    return false;
                                }

                                if (start && end && start > end) {
                                    alert("Ngày bắt đầu không được lớn hơn ngày kết thúc!");
                                    e.preventDefault();
                                    return false;
                                }

                                document.getElementById('loader').style.display = 'flex';
                            };

                            document.addEventListener('DOMContentLoaded', function () {

                                const bookLabels = []; const bookValues = [];
                                <c:forEach items="${dashboardData.topBooks}" var="b">
                                    bookLabels.push("${fn:escapeXml(b.title)}");
                                    bookValues.push(${b.count != null ? b.count : 0});
                                </c:forEach>

                                new Chart(document.getElementById('bookChart'), {
                                    type: 'bar',
                                    data: {
                                        labels: bookLabels,
                                        datasets: [{
                                            label: 'Lượt mượn',
                                            data: bookValues,
                                            backgroundColor: '#4f46e5',
                                            borderRadius: 5
                                        }]
                                    },
                                    options: {
                                        indexAxis: 'y', responsive: true, maintainAspectRatio: false,
                                        plugins: { legend: { display: false } }
                                    }
                                });


                                const collected = ${ dashboardData.finesCollected };
                                const pending = ${ dashboardData.finesPending };
                                const hasData = (collected + pending) > 0;

                                new Chart(document.getElementById('fineChart'), {
                                    type: 'doughnut',
                                    data: {
                                        labels: ['Đã thu', 'Chờ xử lý'],
                                        datasets: [{
                                            data: hasData ? [collected, pending] : [1],
                                            backgroundColor: hasData ? ['#10b981', '#f59e0b'] : ['#e5e7eb'],
                                            borderWidth: 2
                                        }]
                                    },
                                    options: {
                                        cutout: '70%', responsive: true, maintainAspectRatio: false,
                                        plugins: { legend: { position: 'bottom', display: hasData } }
                                    }
                                });
                            });

                        </script>
                    </body>

                    </html>