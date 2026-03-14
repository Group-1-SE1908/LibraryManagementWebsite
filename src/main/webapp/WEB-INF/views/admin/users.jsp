<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <!DOCTYPE html>
      <html lang="vi">

      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>User Management - LBMS Admin</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
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

          /* Sidebar Styles */
          .sidebar {
            width: 280px;
            background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
            color: white;
            padding: 24px 0;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
            box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
          }

          .sidebar-header {
            padding: 0 24px 32px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 24px;
          }

          .sidebar-header i {
            font-size: 28px;
          }

          .sidebar-header h2 {
            font-size: 18px;
            font-weight: 600;
          }

          .sidebar-section {
            margin-bottom: 8px;
          }

          .sidebar-section-title {
            padding: 12px 24px;
            font-size: 11px;
            text-transform: uppercase;
            letter-spacing: 1px;
            color: rgba(255, 255, 255, 0.6);
            font-weight: 600;
            margin-top: 16px;
          }

          .sidebar-nav {
            padding: 8px 16px;
          }

          .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px 16px;
            color: rgba(255, 255, 255, 0.85);
            text-decoration: none;
            border-radius: 8px;
            transition: all 0.3s ease;
            margin-bottom: 4px;
          }

          .sidebar-nav a:hover,
          .sidebar-nav a.active {
            background-color: rgba(255, 255, 255, 0.15);
            color: white;
          }

          .sidebar-nav a.active {
            background: rgba(255, 255, 255, 0.25);
            border-left: 3px solid white;
          }

          .sidebar-nav i {
            width: 20px;
            text-align: center;
          }

          /* Main Content */
          .main {
            flex: 1;
            margin-left: 280px;
            display: flex;
            flex-direction: column;
            height: 100vh;
          }

          .header {
            background: white;
            padding: 20px 32px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border-bottom: 1px solid #e5e5e5;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
          }

          .header-left {
            display: flex;
            align-items: center;
            gap: 24px;
            flex: 1;
          }

          .search-box {
            flex: 1;
            max-width: 400px;
          }

          .search-box input {
            width: 100%;
            padding: 10px 16px;
            border: 1px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            background-color: #f9f9f9;
            transition: all 0.3s ease;
          }

          .search-box input:focus {
            outline: none;
            background-color: white;
            border-color: #1f3a93;
            box-shadow: 0 0 0 3px rgba(31, 58, 147, 0.1);
          }

          .header-right {
            display: flex;
            align-items: center;
            gap: 20px;
          }

          .icon-btn {
            background: none;
            border: none;
            cursor: pointer;
            font-size: 20px;
            color: #666;
            transition: all 0.3s ease;
            padding: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
          }

          .icon-btn:hover {
            color: #1f3a93;
          }

          .user-profile {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 8px 16px;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
          }

          .user-profile:hover {
            background-color: #f5f5f5;
          }

          .user-avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            background: linear-gradient(135deg, #1f3a93, #2c5aa0);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 14px;
          }

          .user-info {
            display: flex;
            flex-direction: column;
            gap: 2px;
          }

          .user-name {
            font-weight: 600;
            font-size: 14px;
          }

          .user-role {
            font-size: 12px;
            color: #999;
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

          .badge {
            display: inline-flex;
            align-items: center;
            padding: 4px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
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

          .action-cell {
            display: flex;
            gap: 8px;
          }

          .action-cell button {
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            border: 1px solid;
            transition: all 0.3s ease;
            background: white;
          }

          .action-cell .edit {
            color: #1f3a93;
            border-color: #1f3a93;
          }

          .action-cell .edit:hover {
            background: #1f3a93;
            color: white;
          }

          .action-cell .lock {
            color: #b00020;
            border-color: #b00020;
          }

          .action-cell .lock:hover {
            background: #b00020;
            color: white;
          }

          .action-cell .unlock {
            color: #0b6b0b;
            border-color: #0b6b0b;
          }

          .action-cell .unlock:hover {
            background: #0b6b0b;
            color: white;
          }

          .pagination {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 4px;
            margin-top: 20px;
            padding-top: 16px;
            border-top: 1px solid #eee;
          }

          .pagination a,
          .pagination button {
            width: 32px;
            height: 32px;
            border: 1px solid #ddd;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            background: white;
            font-size: 12px;
            font-weight: 500;
            transition: all 0.3s ease;
          }

          .pagination a:hover,
          .pagination button:hover {
            border-color: #1f3a93;
            color: #1f3a93;
          }

          .pagination .active {
            background: #1f3a93;
            color: white;
            border-color: #1f3a93;
          }

          select {
            padding: 8px 12px;
            border: 1px solid #ddd;
            border-radius: 6px;
            font-size: 14px;
            background: white;
            cursor: pointer;
            transition: all 0.3s ease;
          }

          select:hover,
          select:focus {
            border-color: #1f3a93;
            outline: none;
            box-shadow: 0 0 0 3px rgba(31, 58, 147, 0.1);
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

          .filter-select {
            padding: 8px 16px;
            border: 1px solid #ddd;
            border-radius: 6px;
            background: white;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            color: #666;
          }

          .btn {
            padding: 6px 12px;
            border: none;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s ease;
            border: 1px solid;
          }

          .btn-text {
            background: white;
            border: 1px solid #ddd;
            color: #666;
          }

          .btn-text:hover {
            color: #1f3a93;
            border-color: #1f3a93;
          }

          form {
            display: inline;
            margin: 0;
          }
        </style>
      </head>

      <body>
        <div class="container">
          <!-- Sidebar -->
          <div class="sidebar">
            <div class="sidebar-header">
              <i class="fas fa-book"></i>
              <h2>LBMS Admin</h2>
            </div>

            <div class="sidebar-section">
              <div class="sidebar-section-title">MANAGEMENT</div>
              <div class="sidebar-nav">
                <a href="${pageContext.request.contextPath}/admin">
                  <i class="fas fa-chart-line"></i>
                  <span>Dashboard</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/users" class="active">
                  <i class="fas fa-users"></i>
                  <span>User Management</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/books">
                  <i class="fas fa-book-open"></i>
                  <span>Book Management</span>
                </a>
                <a href="${pageContext.request.contextPath}/admin/categories">
                  <i class="fas fa-list"></i>
                  <span>Categories</span>
                </a>
              </div>
            </div>

            <div class="sidebar-section">
              <div class="sidebar-section-title">ANALYSIS</div>
              <div class="sidebar-nav">
                <a href="javascript:void(0)">
                  <i class="fas fa-chart-bar"></i>
                  <span>Reports</span>
                </a>
                <a href="javascript:void(0)">
                  <i class="fas fa-shipping-fast"></i>
                  <span>Total Shipments</span>
                </a>
              </div>
            </div>

            <div class="sidebar-section">
              <div class="sidebar-section-title">OTHER</div>
              <div class="sidebar-nav">
                <a href="javascript:void(0)">
                  <i class="fas fa-cog"></i>
                  <span>Settings</span>
                </a>
                <a href="${pageContext.request.contextPath}/logout">
                  <i class="fas fa-sign-out-alt"></i>
                  <span>Logout</span>
                </a>
              </div>
            </div>
          </div>

          <!-- Main Content -->
          <div class="main">
            <!-- Header -->
            <div class="header">
              <div class="header-left">
                <div class="search-box">
                  <input type="text" placeholder="Search for books, members, or ISBN...">
                </div>
              </div>
              <div class="header-right">
                <button class="icon-btn">
                  <i class="fas fa-bell"></i>
                </button>
                <button class="icon-btn">
                  <i class="fas fa-moon"></i>
                </button>
                <div class="user-profile">
                  <div class="user-avatar">AD</div>
                  <div class="user-info">
                    <div class="user-name">Admin User</div>
                    <div class="user-role">System Admin</div>
                  </div>
                  <i class="fas fa-chevron-down" style="color: #999; font-size: 12px;"></i>
                </div>
              </div>
            </div>

            <!-- Content -->
            <div class="content">
              <div class="content-header">
                <div>
                  <h1 class="content-title">User Management</h1>
                  <p class="content-subtitle">Manage library members, statuses, and account actions.</p>
                </div>
              </div>

              <c:if test="${not empty flash}">
                <div class="section"
                  style="background: #d4f8d4; border-left: 4px solid #0b6b0b; color: #0b6b0b; margin-bottom: 20px;">
                  ${flash}
                </div>
              </c:if>

              <!-- User Management Section -->
              <div class="section">
                <div class="section-header">
                  <div>
                    <h2 class="section-title">All Users</h2>
                    <p class="section-subtitle">Showing ${users != null ? users.size() : 0} of total users</p>
                  </div>
                  <select class="filter-select">
                    <option>All Users</option>
                    <option>Active</option>
                    <option>Locked</option>
                    <option>Pending</option>
                  </select>
                </div>

                <div class="table-wrapper">
                  <table>
                    <thead>
                      <tr>
                        <th>USER INFO</th>
                        <th>ROLE</th>
                        <th>STATUS</th>
                        <th>ACTIONS</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach items="${users}" var="u">
                        <tr>
                          <td>
                            <div class="user-cell">
                              <div class="user-avatar-sm">
                                ${fn:substring(u.fullName, 0, 1)}${fn:substring(u.fullName, fn:indexOf(u.fullName, ' ')
                                + 1, fn:indexOf(u.fullName, ' ') + 2)}
                              </div>
                              <div class="user-cell-info">
                                <div class="user-cell-name">${u.fullName}</div>
                                <div class="user-cell-email">${u.email}</div>
                              </div>
                            </div>
                          </td>
                          <td>
                            <form method="post" action="${pageContext.request.contextPath}/admin/users/role">
                              <input type="hidden" name="userId" value="${u.id}" />
                              <select name="role" onchange="this.form.submit()">
                                <c:forEach items="${roles}" var="r">
                                  <option value="${r.name}" <c:if test="${u.role.name == r.name}">selected</c:if>
                                    >${r.name}</option>
                                </c:forEach>
                              </select>
                            </form>
                          </td>
                          <td>
                            <c:choose>
                              <c:when test="${u.status == 'ACTIVE'}">
                                <span class="badge badge-success">Active</span>
                              </c:when>
                              <c:when test="${u.status == 'LOCKED'}">
                                <span class="badge badge-danger">Locked</span>
                              </c:when>
                              <c:otherwise>
                                <span class="badge badge-warning">Pending</span>
                              </c:otherwise>
                            </c:choose>
                          </td>
                          <td>
                            <div class="action-cell">
                              <c:choose>
                                <c:when test="${u.status == 'ACTIVE'}">
                                  <form method="post" action="${pageContext.request.contextPath}/admin/users/status">
                                    <input type="hidden" name="userId" value="${u.id}" />
                                    <input type="hidden" name="status" value="LOCKED" />
                                    <button type="submit" class="lock">Lock</button>
                                  </form>
                                </c:when>
                                <c:otherwise>
                                  <form method="post" action="${pageContext.request.contextPath}/admin/users/status">
                                    <input type="hidden" name="userId" value="${u.id}" />
                                    <input type="hidden" name="status" value="ACTIVE" />
                                    <button type="submit" class="unlock">Unlock</button>
                                  </form>
                                </c:otherwise>
                              </c:choose>
                            </div>
                          </td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>

                <div class="pagination">
                  <button>←</button>
                  <button class="active">1</button>
                  <a href="javascript:void(0)">2</a>
                  <a href="javascript:void(0)">3</a>
                  <span>...</span>
                  <a href="javascript:void(0)">→</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </body>

      </html>