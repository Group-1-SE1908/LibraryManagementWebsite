<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

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
                    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

                    <style>
                        :root {
                            --sidebar-width: 280px;
                            --primary: #4f46e5;
                            --success: #10b981;
                            --danger: #ef4444;
                            --warning: #f59e0b;
                            --info: #0ea5e9;
                            --bg-body: #f3f4f6;
                            --text-main: #1f2937;
                            --text-sub: #6b7280;
                            --white: #ffffff;
                            --border: #e5e7eb;
                        }

                        * {
                            box-sizing: border-box;
                        }

                        body {
                            font-family: 'Inter', sans-serif;
                            background: var(--bg-body);
                            margin: 0;
                            color: var(--text-main);
                        }

                        #loader {
                            position: fixed;
                            top: 0;
                            left: 0;
                            width: 100%;
                            height: 100%;
                            background: rgba(255, 255, 255, 0.7);
                            display: none;
                            justify-content: center;
                            align-items: center;
                            z-index: 9999;
                        }

                        .spinner {
                            width: 40px;
                            height: 40px;
                            border: 4px solid #f3f3f3;
                            border-top: 4px solid var(--primary);
                            border-radius: 50%;
                            animation: spin 1s linear infinite;
                        }

                        @keyframes spin {
                            100% {
                                transform: rotate(360deg);
                            }
                        }

                        .wrapper {
                            display: flex;
                            width: 100%;
                        }

                        .main-content {
                            flex: 1;
                            margin-left: var(--sidebar-width);
                            padding: 2rem;
                            min-height: 100vh;
                        }

                        .dashboard-toolbar {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 2rem;
                            background: var(--white);
                            padding: 1rem 1.5rem;
                            border-radius: 12px;
                            border: 1px solid var(--border);
                            flex-wrap: wrap;
                            gap: 1rem;
                        }

                        .filter-form {
                            display: flex;
                            align-items: center;
                            gap: 0.75rem;
                        }

                        .input-group {
                            display: flex;
                            align-items: center;
                            gap: 0.5rem;
                            color: var(--text-sub);
                            font-size: 0.875rem;
                        }

                        .form-control {
                            padding: 8px 12px;
                            border: 1px solid var(--border);
                            border-radius: 6px;
                        }

                        .btn {
                            padding: 8px 16px;
                            border-radius: 6px;
                            font-weight: 500;
                            cursor: pointer;
                            display: inline-flex;
                            align-items: center;
                            gap: 8px;
                            border: none;
                            transition: 0.2s;
                        }

                        .btn-primary {
                            background: var(--primary);
                            color: white;
                        }

                        .btn-success {
                            background: #15803d;
                            color: white;
                        }

                        .btn-outline {
                            background: transparent;
                            border: 1px solid var(--border);
                            color: var(--text-sub);
                        }

                        .btn:hover {
                            opacity: 0.9;
                        }

                        .stats-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                            gap: 1.25rem;
                            margin-bottom: 2rem;
                        }

                        .stat-card {
                            background: var(--white);
                            padding: 1.25rem;
                            border-radius: 12px;
                            border: 1px solid var(--border);
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            transition: transform 0.2s;
                        }

                        .stat-card:hover {
                            transform: translateY(-3px);
                        }

                        .stat-value {
                            font-size: 1.35rem;
                            font-weight: 700;
                            margin-top: 0.5rem;
                        }

                        .stat-label {
                            color: var(--text-sub);
                            font-size: 0.875rem;
                            font-weight: 500;
                        }

                        .stat-icon {
                            width: 44px;
                            height: 44px;
                            border-radius: 10px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 1.1rem;
                        }

                        .charts-row {
                            display: grid;
                            grid-template-columns: 1.5fr 1fr;
                            gap: 1.5rem;
                            margin-bottom: 2rem;
                        }

                        .card {
                            background: var(--white);
                            border-radius: 12px;
                            border: 1px solid var(--border);
                            padding: 1.5rem;
                        }

                        .card-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 1.5rem;
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse;
                        }

                        th {
                            text-align: left;
                            padding: 12px;
                            color: var(--text-sub);
                            font-size: 0.75rem;
                            border-bottom: 2px solid var(--border);
                            text-transform: uppercase;
                        }

                        td {
                            padding: 12px;
                            border-bottom: 1px solid var(--border);
                            font-size: 0.9rem;
                        }

                        .avatar-box {
                            width: 36px;
                            height: 36px;
                            border-radius: 50%;
                            overflow: hidden;
                            background-color: #E5E7EB;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            border: 1px solid var(--border);
                            flex-shrink: 0;
                        }

                        .user-flex {
                            display: flex;
                            align-items: center;
                            gap: 12px;
                        }

                        .badge {
                            padding: 4px 10px;
                            border-radius: 20px;
                            font-size: 0.75rem;
                            font-weight: 600;
                        }

                        .bg-success {
                            background: #dcfce7;
                            color: #15803d;
                        }

                        .bg-danger {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        @media (max-width: 1400px) {
                            .stats-grid {
                                grid-template-columns: repeat(3, 1fr);
                            }
                        }

                        @media (max-width: 1100px) {
                            .charts-row {
                                grid-template-columns: 1fr;
                            }

                            .main-content {
                                margin-left: 0;
                            }

                            .stats-grid {
                                grid-template-columns: repeat(2, 1fr);
                            }
                        }
                    </style>
                </head>

                <body>
                    <div id="loader">
                        <div class="spinner"></div>
                    </div>

                    <div class="wrapper">
                        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                        <div class="main-content">
                            <header style="margin-bottom: 1.5rem;">
                                <h1 style="margin: 0; font-size: 1.75rem; font-weight: 700;">Báo cáo tổng quát</h1>
                                <small id="currentDateDisplay" style="color: var(--text-sub)"></small>
                            </header>

                            <div class="dashboard-toolbar">
                                <form id="statsForm" action="${pageContext.request.contextPath}/admin/dashboard"
                                    method="GET" class="filter-form">
                                    <div class="input-group">
                                        <span>Từ:</span>
                                        <input type="date" id="startDate" name="startDate" class="form-control"
                                            value="${param.startDate}">
                                    </div>
                                    <div class="input-group">
                                        <span>Đến:</span>
                                        <input type="date" id="endDate" name="endDate" class="form-control"
                                            value="${param.endDate}">
                                    </div>
                                    <button type="submit" class="btn btn-primary"><i class="fas fa-filter"></i>
                                        Lọc</button>
                                    <button type="button" onclick="resetFilter()" class="btn btn-outline"><i
                                            class="fas fa-undo"></i> Reset</button>
                                </form>

                                <button onclick="handleExportExcel('export')" class="btn btn-success">
                                    <i class="fas fa-file-excel"></i> Xuất File Excel
                                </button>
                            </div>

                            <div class="stats-grid">
                                <div class="stat-card">
                                    <div>
                                        <div class="stat-label">Tổng số sách</div>
                                        <div class="stat-value">${dashboardData.totalBooks}</div>
                                    </div>
                                    <div class="stat-icon" style="background: #e0e7ff; color: #4338ca;"><i
                                            class="fas fa-book"></i></div>
                                </div>

                                <div class="stat-card">
                                    <div>
                                        <div class="stat-label">Bạn đọc</div>
                                        <div class="stat-value">${dashboardData.activeUsers}</div>
                                    </div>
                                    <div class="stat-icon" style="background: #dcfce7; color: #15803d;"><i
                                            class="fas fa-users"></i></div>
                                </div>

                                <div class="stat-card">
                                    <div>
                                        <div class="stat-label">Đang mượn</div>
                                        <div class="stat-value" style="color: var(--info);">
                                            ${dashboardData.pendingReturns}</div>
                                    </div>
                                    <div class="stat-icon" style="background: #e0f2fe; color: #0369a1;"><i
                                            class="fas fa-book-reader"></i></div>
                                </div>

                                <div class="stat-card">
                                    <div>
                                        <div class="stat-label">Quá hạn</div>
                                        <div class="stat-value" style="color: var(--danger);">
                                            ${dashboardData.overdueBooks}</div>
                                    </div>
                                    <div class="stat-icon" style="background: #fee2e2; color: #ef4444;"><i
                                            class="fas fa-history"></i></div>
                                </div>

                                <div class="stat-card">
                                    <div>
                                        <div class="stat-label">Tiền phạt đã thu</div>
                                        <div class="stat-value" style="color: #15803d;">
                                            <fmt:formatNumber value="${dashboardData.finesCollected}" pattern="#,##0" />
                                            ₫
                                        </div>
                                    </div>
                                    <div class="stat-icon" style="background: #dcfce7; color: #15803d;">
                                        <i class="fas fa-hand-holding-usd"></i>
                                    </div>
                                </div>
                            </div>

                            <div class="charts-row">
                                <div class="card">
                                    <div class="card-header">
                                        <h3 style="margin:0; font-size:1rem;">Top 5 sách mượn nhiều nhất</h3>
                                    </div>
                                    <div style="height: 300px;"><canvas id="bookChart"></canvas></div>
                                </div>
                                <div class="card">
                                    <div class="card-header">
                                        <h3 style="margin:0; font-size:1rem;">Phân bổ tiền phạt</h3>
                                    </div>
                                    <div style="height: 250px;"><canvas id="fineChart"></canvas></div>
                                </div>
                            </div>

                            <div class="card">
                                <div class="card-header">
                                    <h3 style="margin:0; font-size:1rem;">Thành viên hoạt động tích cực</h3>
                                </div>
                                <div style="overflow-x: auto;">
                                    <table>
                                        <thead>
                                            <tr>
                                                <th>STT</th>
                                                <th>Thành viên</th>
                                                <th>Vai trò</th>
                                                <th>Trạng thái</th>
                                                <th style="text-align: center;">Tổng lượt mượn</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach items="${dashboardData.topUsers}" var="u" varStatus="loop">
                                                <tr>
                                                    <td>${loop.index + 1}</td>
                                                    <td>
                                                        <div class="user-flex">
                                                            <div class="avatar-box">
                                                                <c:choose>
                                                                    <c:when test="${not empty u.avatar}">
                                                                        <img src="${pageContext.request.contextPath}/${u.avatar}"
                                                                            style="width:100%; height:100%; object-fit:cover;">
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span
                                                                            style="font-weight:600;">${fn:substring(u.fullName,
                                                                            0, 1).toUpperCase()}</span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                            <div>
                                                                <strong>${u.fullName}</strong><br>
                                                                <small style="color:var(--text-sub)">${u.email}</small>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>${u.roleName}</td>
                                                    <td>
                                                        <span
                                                            class="badge ${u.status == 'ACTIVE' ? 'bg-success' : 'bg-danger'}">
                                                            ${u.status == 'ACTIVE' ? 'Hoạt động' : 'Khóa'}
                                                        </span>
                                                    </td>
                                                    <td style="text-align: center;"><strong>${u.totalBorrows}</strong>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

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
                                e.preventDefault(); return false;
                            }
                            document.getElementById('loader').style.display = 'flex';
                        };

                        document.addEventListener('DOMContentLoaded', function () {

                            const bookLabels = []; const bookValues = [];
                            <c:forEach items="${dashboardData.topBooks}" var="b">
                                bookLabels.push("${fn:escapeXml(b.title)}");
                                bookValues.push(${b.count});
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