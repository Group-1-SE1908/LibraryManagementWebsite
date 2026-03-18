<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
        <%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
            <%@ page import="java.time.LocalDate" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Thống Kê Thư Viện </title>

                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet"
                        href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

                    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

                    <style>
                        :root {
                            --sidebar-width: 260px;
                            --primary-color: #4f46e5;
                            --bg-light: #f8fafc;
                            --card-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                        }

                        body {
                            background: var(--bg-light);
                            font-family: 'Inter', sans-serif;
                            color: #1e293b;
                            margin: 0;
                            overflow-x: hidden;
                        }

                        /* Layout Structure */
                        .app-wrapper {
                            display: flex;
                            min-height: 100vh;
                        }

                        .sidebar-container {
                            width: var(--sidebar-width);
                            flex-shrink: 0;
                            background: #1e293b;
                            z-index: 1000;
                            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                        }

                        #content {
                            flex-grow: 1;
                            min-width: 0;

                            padding: 2rem 1.5rem;
                        }

                        /* Responsive Sidebar */
                        @media (max-width: 992px) {
                            .sidebar-container {
                                width: 70px;
                            }

                            .sidebar-text {
                                display: none;
                            }
                        }

                        @media (max-width: 768px) {
                            .sidebar-container {
                                display: none;
                            }

                            #content {
                                padding: 1rem;
                            }
                        }

                        .page-title {
                            font-weight: 700;
                            letter-spacing: -0.025em;
                            color: #0f172a;
                        }

                        /* Cards */
                        .stat-card {
                            border: none;
                            border-radius: 12px;
                            position: relative;
                            overflow: hidden;
                            box-shadow: var(--card-shadow);
                            transition: all 0.3s ease;
                            height: 100%;
                        }

                        .stat-card:hover {
                            transform: translateY(-4px);
                            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
                        }

                        .stat-card i {
                            position: absolute;
                            right: -5px;
                            bottom: -5px;
                            font-size: 3rem;
                            opacity: 0.2;
                            transform: rotate(-15deg);
                        }

                        .filter-box,
                        .main-card {
                            background: #fff;
                            padding: 1.5rem;
                            border-radius: 12px;
                            border: 1px solid #e2e8f0;
                            margin-bottom: 1.5rem;
                            box-shadow: var(--card-shadow);
                        }

                        /* Table Styling */
                        .table thead th {
                            background-color: #f1f5f9;
                            text-transform: uppercase;
                            font-size: 0.75rem;
                            font-weight: 600;
                            letter-spacing: 0.05em;
                            color: #64748b;
                            border: none;
                            padding: 12px 15px;
                        }

                        .table td {
                            vertical-align: middle;
                            padding: 12px 15px;
                            border-top: 1px solid #f1f5f9;
                        }

                        .text-truncate-custom {
                            display: inline-block;
                            max-width: 200px;
                            white-space: nowrap;
                            overflow: hidden;
                            text-overflow: ellipsis;
                        }

                        /* Status Badges */
                        .status-badge {
                            font-size: 0.7rem;
                            font-weight: 600;
                            padding: 0.35rem 0.75rem;
                            border-radius: 9999px;
                            text-transform: uppercase;
                        }

                        /* Chart */
                        .chart-wrapper {
                            position: relative;
                            height: 300px;
                            width: 100%;
                        }

                        /* Loading Overlay */
                        .loading-overlay {
                            display: none;
                            position: fixed;
                            inset: 0;
                            background: rgba(255, 255, 255, 0.7);
                            backdrop-filter: blur(4px);
                            z-index: 9999;
                            justify-content: center;
                            align-items: center;
                        }

                        .btn-export-full {
                            background: #10b981;
                            color: white;
                            border: none;
                            transition: 0.2s;
                        }

                        .btn-export-full:hover {
                            background: #059669;
                            color: white;
                            transform: translateY(-1px);
                        }

                        .form-control:focus {
                            border-color: var(--primary-color);
                            box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.1);
                        }
                    </style>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                </head>

                <body class="panel-body">
                    <div class="panel-loader" id="loader">
                        <div class="panel-spinner"></div>
                    </div>

                    <jsp:include page="sidebar.jsp" />

                    <div id="content">
                        <div class="container-fluid">
                            <div
                                class="d-flex flex-column flex-md-row justify-content-between align-items-md-center mb-4">
                                <div>
                                    <h2 class="page-title mb-1">Thống Kê Mượn Trả</h2>
                                    <p class="text-muted small mb-0">Theo dõi hoạt động thư viện trong thời gian
                                        thực</p>
                                </div>
                                <div class="mt-3 mt-md-0">
                                    <span
                                        class="text-muted small font-weight-600 bg-white px-3 py-2 rounded shadow-sm border">
                                        <i class="far fa-calendar-alt mr-2 text-primary"></i>
                                        <span id="currentDateDisplay"></span>
                                    </span>
                                </div>
                            </div>

                            <div class="filter-box">
                                <form action="${pageContext.request.contextPath}/admin/statistics" method="GET"
                                    id="statsForm" class="row align-items-end">
                                    <c:set var="today" value="<%= LocalDate.now().toString() %>" />
                                    <div class="col-sm-6 col-md-3">
                                        <label class="small font-weight-bold text-uppercase text-muted">Từ
                                            ngày</label>
                                        <input type="date" name="startDate" id="startDate" class="form-control"
                                            max="${today}" value="${startDate}">
                                    </div>
                                    <div class="col-sm-6 col-md-3">
                                        <label class="small font-weight-bold text-uppercase text-muted">Đến
                                            ngày</label>
                                        <input type="date" name="endDate" id="endDate" class="form-control"
                                            max="${today}" value="${endDate}">
                                    </div>
                                    <div class="col-md-6 d-flex flex-wrap justify-content-md-end mt-3 mt-md-0">
                                        <button type="submit" class="btn btn-primary font-weight-bold mr-2 px-4">
                                            <i class="fas fa-filter mr-2"></i> Lọc dữ liệu
                                        </button>
                                        <button type="button" onclick="resetFilter()"
                                            class="btn btn-light border font-weight-bold mr-2">
                                            <i class="fas fa-undo"></i>
                                        </button>
                                        <button type="button" onclick="handleExportExcel('export')"
                                            class="btn btn-export-full font-weight-bold px-4">
                                            <i class="fas fa-file-excel mr-2"></i> Xuất Excel
                                        </button>
                                    </div>
                                </form>
                            </div>

                            <div class="row">
                                <c:set var="colors" value="${['primary', 'success', 'warning', 'danger']}" />
                                <c:set var="labels" value="${['Tổng sách', 'Bạn đọc', 'Lượt mượn', 'Quá hạn']}" />
                                <c:set var="vals"
                                    value="${[stats.totalBooks, stats.activeUsers, stats.totalBorrows, stats.overdueBooks]}" />
                                <c:set var="icons" value="${['book', 'users', 'exchange-alt', 'clock']}" />

                                <c:forEach var="i" begin="0" end="3">
                                    <div class="col-6 col-md-6 col-xl-3 mb-4">
                                        <div class="card stat-card bg-${colors[i]} text-white">
                                            <div class="card-body p-4">
                                                <div class="small text-uppercase font-weight-bold mb-1"
                                                    style="opacity: 0.85; font-size: 0.75rem;">
                                                    ${labels[i]}
                                                </div>
                                                <h2 class="font-weight-bold mb-0">${vals[i]}</h2>
                                                <i class="fas fa-${icons[i]}"></i>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="row">
                                <div class="col-lg-5 col-xl-4 mb-4">
                                    <div class="main-card h-100">
                                        <h6 class="font-weight-bold text-uppercase small mb-4 text-primary">Tỉ lệ
                                            trạng thái mượn</h6>
                                        <div class="chart-wrapper">
                                            <canvas id="statusChart"></canvas>
                                        </div>
                                    </div>
                                </div>

                                <div class="col-lg-7 col-xl-8 mb-4">
                                    <div class="main-card h-100">
                                        <h6 class="font-weight-bold text-uppercase small mb-4 text-primary">Top 5
                                            sách mượn nhiều nhất</h6>
                                        <div class="table-responsive">
                                            <table class="table table-borderless">
                                                <thead>
                                                    <tr>
                                                        <th>Tên đầu sách</th>
                                                        <th class="d-none d-sm-table-cell">Thể loại</th>
                                                        <th class="text-right">Lượt mượn</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${stats.topBooks}" var="b">
                                                        <tr>
                                                            <td><span
                                                                    class="text-truncate-custom font-weight-600 text-dark">${b.title}</span>
                                                            </td>
                                                            <td class="d-none d-sm-table-cell"><span
                                                                    class="badge badge-light text-muted">${b.category}</span>
                                                            </td>
                                                            <td class="text-right">
                                                                <span
                                                                    class="badge badge-primary px-3 py-2">${b.borrowCount}</span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-12">
                                    <div class="main-card">
                                        <h6 class="font-weight-bold text-uppercase small mb-4 text-primary">Nhật ký
                                            mượn trả chi tiết</h6>
                                        <div class="table-responsive">
                                            <table class="table table-hover">
                                                <thead>
                                                    <tr>
                                                        <th>Mã</th>
                                                        <th>Người mượn</th>
                                                        <th>Sách / Barcode</th>
                                                        <th class="d-none d-md-table-cell">Ngày mượn</th>
                                                        <th>Hạn trả</th>
                                                        <th>Phạt</th>
                                                        <th>Trạng thái</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${stats.detailedRecords}" var="d">
                                                        <tr>
                                                            <td><code class="text-muted">#${d.orderId}</code></td>
                                                            <td>
                                                                <div class="font-weight-bold small">
                                                                    ${d.borrowerName}</div>
                                                                <div class="small text-muted d-none d-sm-block">
                                                                    ${d.email}</div>
                                                            </td>
                                                            <td>
                                                                <div class="text-truncate-custom small font-weight-600">
                                                                    ${d.bookTitle}</div>
                                                                <div><small class="text-primary">${d.barcode != null
                                                                        ? d.barcode : 'N/A'}</small></div>
                                                            </td>
                                                            <td class="d-none d-md-table-cell"><span
                                                                    class="small">${d.borrowDate}</span></td>
                                                            <td><span class="small">${d.returnDate != null ?
                                                                    d.returnDate : '-'}</span></td>
                                                            <td class="text-danger font-weight-bold small">
                                                                <fmt:formatNumber value="${d.fineAmount}"
                                                                    type="currency" currencySymbol="₫" />
                                                            </td>
                                                            <td>
                                                                <span class="status-badge"
                                                                    style="${d.status == 'RETURNED' ? 'background:#dcfce7;color:#166534' : 
                                                                  (d.status == 'OVERDUE' ? 'background:#fee2e2;color:#991b1b' : 'background:#fef3c7;color:#92400e')}">
                                                                    ${d.status}
                                                                </span>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </div>
                                    </div>
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
                                options: {
                                    cutout: '80%',
                                    plugins: { legend: { display: false } }
                                }
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