<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>Dashboard - LBMS Admin</title>
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                    <style>
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }

                        body {
                            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                            background-color: #f5f5f5;
                            color: #333;
                        }

                        .container {
                            display: flex;
                            height: 100vh;
                        }

                        /* Main Content */
                        .main {
                            flex: 1;
                            margin-left: 280px;
                            display: flex;
                            flex-direction: column;
                            height: 100vh;
                        }

                        /* Content Area */
                        .content {
                            flex: 1;
                            overflow-y: auto;
                            padding: 32px;
                        }

                        .content-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 32px;
                        }

                        .content-title {
                            font-size: 28px;
                            font-weight: 600;
                            color: #1f1f1f;
                        }

                        .content-subtitle {
                            font-size: 14px;
                            color: #999;
                            margin-top: 4px;
                        }

                        .action-buttons {
                            display: flex;
                            gap: 12px;
                        }

                        .btn {
                            padding: 10px 20px;
                            border: none;
                            border-radius: 8px;
                            font-size: 14px;
                            font-weight: 500;
                            cursor: pointer;
                            transition: all 0.3s ease;
                            display: inline-flex;
                            align-items: center;
                            gap: 8px;
                            text-decoration: none;
                        }

                        .btn-primary {
                            background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
                            color: white;
                            box-shadow: 0 2px 8px rgba(31, 58, 147, 0.3);
                        }

                        .btn-primary:hover {
                            transform: translateY(-2px);
                            box-shadow: 0 4px 12px rgba(31, 58, 147, 0.4);
                        }

                        .btn-secondary {
                            background: white;
                            color: #1f3a93;
                            border: 1.5px solid #1f3a93;
                        }

                        .btn-secondary:hover {
                            background: #f5f5f5;
                        }

                        /* Stats Cards */
                        .stats-container {
                            display: grid;
                            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
                            gap: 20px;
                            margin-bottom: 32px;
                        }

                        .stat-card {
                            background: white;
                            padding: 24px;
                            border-radius: 12px;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                            transition: all 0.3s ease;
                        }

                        .stat-card:hover {
                            transform: translateY(-4px);
                            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.12);
                        }

                        .stat-card-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: flex-start;
                            margin-bottom: 12px;
                        }

                        .stat-icon {
                            width: 48px;
                            height: 48px;
                            border-radius: 10px;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 24px;
                        }

                        .stat-icon.books {
                            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                            color: white;
                        }

                        .stat-icon.users {
                            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
                            color: white;
                        }

                        .stat-icon.returns {
                            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
                            color: white;
                        }

                        .stat-icon.shipments {
                            background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%);
                            color: white;
                        }


                        .stat-title {
                            font-size: 13px;
                            color: #999;
                            font-weight: 500;
                            text-transform: uppercase;
                            letter-spacing: 0.5px;
                            margin-bottom: 8px;
                        }

                        .stat-value {
                            font-size: 28px;
                            font-weight: 700;
                            color: #1f1f1f;
                        }

                        /* Section */
                        .section {
                            background: white;
                            border-radius: 12px;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                            padding: 24px;
                            margin-bottom: 24px;
                        }

                        .section-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 20px;
                            padding-bottom: 16px;
                            border-bottom: 1px solid #eee;
                        }

                        .section-title {
                            font-size: 18px;
                            font-weight: 600;
                            color: #1f1f1f;
                        }

                        .section-subtitle {
                            font-size: 13px;
                            color: #999;
                            margin-top: 2px;
                        }

                        /* Table */
                        .table-wrapper {
                            overflow-x: auto;
                        }

                        table {
                            width: 100%;
                            border-collapse: collapse;
                        }

                        th {
                            background-color: #f9f9f9;
                            padding: 12px 16px;
                            text-align: left;
                            font-size: 12px;
                            font-weight: 600;
                            color: #666;
                            text-transform: uppercase;
                            letter-spacing: 0.5px;
                            border-bottom: 1px solid #eee;
                        }

                        td {
                            padding: 14px 16px;
                            border-bottom: 1px solid #eee;
                            font-size: 14px;
                            color: #333;
                        }

                        tr:last-child td {
                            border-bottom: none;
                        }

                        tr:hover {
                            background-color: #f9f9f9;
                        }

                        .user-cell {
                            display: flex;
                            align-items: center;
                            gap: 12px;
                        }

                        .user-avatar-sm {
                            width: 36px;
                            height: 36px;
                            border-radius: 50%;
                            background: linear-gradient(135deg, #1f3a93, #2c5aa0);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            color: white;
                            font-weight: 600;
                            font-size: 12px;
                            flex-shrink: 0;
                        }

                        .user-cell-info {
                            display: flex;
                            flex-direction: column;
                            gap: 2px;
                        }

                        .user-cell-name {
                            font-weight: 500;
                            color: #1f1f1f;
                        }

                        .user-cell-email {
                            font-size: 12px;
                            color: #999;
                        }



                        .badge-success {
                            background: #d4f8d4;
                            color: #0b6b0b;
                        }

                        .badge-warning {
                            background: #fff3cd;
                            color: #856404;
                        }

                        .badge-danger {
                            background: #f8d7da;
                            color: #721c24;
                        }

                        /* Scrollbar */
                        ::-webkit-scrollbar {
                            width: 8px;
                            height: 8px;
                        }

                        ::-webkit-scrollbar-track {
                            background: #f1f1f1;
                        }

                        ::-webkit-scrollbar-thumb {
                            background: #888;
                            border-radius: 4px;
                        }

                        ::-webkit-scrollbar-thumb:hover {
                            background: #555;
                        }


                        /* ===== ROLE & STATUS BADGES (Dashboard) ===== */
                        .badge {
                            display: inline-flex;
                            align-items: center;
                            padding: 0.125rem 0.625rem;
                            border-radius: 9999px;
                            font-size: 0.75rem;
                            font-weight: 500;
                            gap: 6px;
                        }

                        .badge-dot {
                            width: 0.375rem;
                            height: 0.375rem;
                            border-radius: 50%;
                        }

                        /* ROLE COLORS */
                        .role-admin {
                            background: #F3E8FF;
                            color: #6B21A8;
                        }

                        .role-admin .badge-dot {
                            background: #A855F7;
                        }

                        .role-lib {
                            background: #DBEAFE;
                            color: #1E40AF;
                        }

                        .role-lib .badge-dot {
                            background: #3B82F6;
                        }

                        .role-member {
                            background: #F3F4F6;
                            color: #374151;
                        }

                        .role-member .badge-dot {
                            background: #9CA3AF;
                        }

                        /* STATUS COLORS */
                        .status-active {
                            background: #DCFCE7;
                            color: #166534;
                        }

                        .status-active .badge-dot {
                            background: #22C55E;
                        }

                        .status-blocked {
                            background: #FEE2E2;
                            color: #991B1B;
                        }

                        .status-blocked .badge-dot {
                            background: #EF4444;
                        }
                    </style>
                </head>

                <body>
                    <div class="container">
                        <!-- Sidebar -->

                        <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />
                        <!-- Main Content -->
                        <div class="main">


                            <!-- Content -->
                            <div class="content">
                                <div class="content-header">
                                    <div>
                                        <h1 class="content-title">Dashboard Overview</h1>
                                        <p class="content-subtitle">Welcome back, here is what's happening in your
                                            library
                                            today.</p>
                                    </div>
                                    <div class="action-buttons">
                                        <button class="btn btn-secondary">
                                            <i class="fas fa-download"></i>
                                            Export Report
                                        </button>

                                    </div>
                                </div>

                                <!-- Stats Cards -->
                                <!-- Update Stats Cards với dữ liệu thực -->
                                <div class="stats-container">
                                    <div class="stat-card">
                                        <div class="stat-card-header">
                                            <div>
                                                <div class="stat-title">Total Books</div>
                                                <div class="stat-value">
                                                    <fmt:formatNumber value="${totalBooks}" pattern="#,###" />
                                                </div>
                                            </div>
                                            <div class="stat-icon books">
                                                <i class="fas fa-book"></i>
                                            </div>
                                        </div>

                                    </div>

                                    <div class="stat-card">
                                        <div class="stat-card-header">
                                            <div>
                                                <div class="stat-title">Active Users</div>
                                                <div class="stat-value">
                                                    <fmt:formatNumber value="${activeUsers}" pattern="#,###" />
                                                </div>
                                            </div>
                                            <div class="stat-icon users">
                                                <i class="fas fa-users"></i>
                                            </div>
                                        </div>

                                    </div>

                                    <div class="stat-card">
                                        <div class="stat-card-header">
                                            <div>
                                                <div class="stat-title">Pending Returns</div>
                                                <div class="stat-value">${pendingReturns}</div>
                                            </div>
                                            <div class="stat-icon returns">
                                                <i class="fas fa-undo"></i>
                                            </div>
                                        </div>

                                    </div>

                                    <div class="stat-card">
                                        <div class="stat-card-header">
                                            <div>
                                                <div class="stat-title">Total Shipments</div>
                                                <div class="stat-value">${totalShipments}</div>
                                            </div>
                                            <div class="stat-icon shipments">
                                                <i class="fas fa-shipping-fast"></i>
                                            </div>
                                        </div>
                                        <div>
                                            <span style="color: #999; font-size: 12px;">This month</span>
                                        </div>
                                    </div>
                                </div>
                                =
                                <div class="section">
                                    <div class="section-header">
                                        <div>
                                            <h2 class="section-title">Top Borrowers</h2>
                                            <p class="section-subtitle">Top 5 members with most book borrows</p>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/admin/users"
                                            class="btn btn-secondary">
                                            View All Users
                                        </a>
                                    </div>

                                    <div class="table-wrapper">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>USER INFO</th>
                                                    <th>PHONE</th>
                                                    <th>ADDRESS</th>
                                                    <th>ROLE</th>
                                                    <th>STATUS</th>
                                                    <th>TOTAL BORROWS</th>
                                                    <th>LAST ACTIVE</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${topBorrowers}" var="user">
                                                    <tr>
                                                        <td>
                                                            <div class="user-cell">
                                                                <div class="user-avatar-sm">
                                                                    <c:choose>
                                                                        <c:when test="${not empty user.fullName}">
                                                                            ${user.fullName.substring(0,1).toUpperCase()}
                                                                        </c:when>
                                                                        <c:otherwise>U</c:otherwise>
                                                                    </c:choose>
                                                                </div>
                                                                <div class="user-cell-info">
                                                                    <div class="user-cell-name">${user.fullName}</div>
                                                                    <div class="user-cell-email">${user.email}</div>
                                                                </div>
                                                            </div>
                                                        </td>
                                                        <td>${not empty user.phone ? user.phone : 'N/A'}</td>
                                                        <td>
                                                            <div style="max-width: 150px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;"
                                                                title="${user.address}">
                                                                ${not empty user.address ? user.address : 'N/A'}
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when
                                                                    test="${user.roleName eq 'Admin' or user.roleName eq 'ADMIN'}">
                                                                    <span class="badge role-admin">
                                                                        <span class="badge-dot"></span>Admin
                                                                    </span>
                                                                </c:when>

                                                                <c:when
                                                                    test="${user.roleName eq 'Librarian' or user.roleName eq 'LIBRARIAN'}">
                                                                    <span class="badge role-lib">
                                                                        <span class="badge-dot"></span>Librarian
                                                                    </span>
                                                                </c:when>

                                                                <c:otherwise>
                                                                    <span class="badge"
                                                                        style="background:#F3F4F6; color:#374151;">
                                                                        <span class="badge-dot"
                                                                            style="background:#9CA3AF;"></span>
                                                                        ${user.roleName}
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${user.status == 'ACTIVE'}">
                                                                    <span class="badge badge-success">Active</span>
                                                                </c:when>
                                                                <c:when test="${user.status == 'LOCKED'}">
                                                                    <span class="badge badge-danger">Locked</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="badge badge-warning">Pending</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <strong>${user.totalBorrows}</strong> books
                                                        </td>
                                                        <td>${user.lastActive}</td>
                                                    </tr>
                                                </c:forEach>

                                                <c:if test="${empty topBorrowers}">
                                                    <tr>
                                                        <td colspan="7"
                                                            style="text-align: center; color: #999; padding: 40px;">
                                                            No borrowing data available
                                                        </td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>




                            </div>
                </body>

                </html>