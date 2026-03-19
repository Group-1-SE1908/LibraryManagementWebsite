<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Quản lý Đặt Trước Sách | LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* ================= BỘ LỌC (FILTER BAR) ================= */
        .filter-bar {
            background: white;
            padding: 20px;
            border-radius: 12px;
            margin-bottom: 25px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            display: flex;
            gap: 15px;
            align-items: flex-end;
            border: 1px solid #e2e8f0;
            flex-wrap: wrap;
        }

        .filter-group {
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .filter-group label {
            font-size: 12px;
            font-weight: 700;
            color: #64748b;
            text-transform: uppercase;
        }

        .filter-group input,
        .filter-group select {
            padding: 10px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            min-width: 200px;
            outline: none;
            transition: 0.2s;
        }

        .filter-group input:focus,
        .filter-group select:focus {
            border-color: #0ea5e9;
            box-shadow: 0 0 0 2px rgba(14, 165, 233, 0.2);
        }

        /* ================= BADGE TRẠNG THÁI ================= */
        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .status-WAITING {
            background: #fef3c7;
            color: #92400e;
        }

        .status-AVAILABLE {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .status-BORROWED {
            background: #dcfce7;
            color: #166534;
        }

        .status-CANCELLED {
            background: #fee2e2;
            color: #991b1b;
        }

        .status-EXPIRED {
            background: #f3f4f6;
            color: #374151;
        }

        /* ================= GROUPING BY DATE ================= */
        .date-group {
            margin-bottom: 30px;
        }

        .date-group-header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 16px 24px;
            border-radius: 10px 10px 0 0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            cursor: pointer;
            user-select: none;
            transition: all 0.3s ease;
        }

        .date-group-header:hover {
            box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
        }

        .date-group-header-left {
            display: flex;
            align-items: center;
            gap: 12px;
            flex: 1;
        }

        .date-group-toggle {
            font-size: 16px;
            transition: transform 0.3s ease;
        }

        .date-group-header.collapsed .date-group-toggle {
            transform: rotate(-90deg);
        }

        .date-group-title {
            font-size: 15px;
            font-weight: 700;
        }

        .date-group-stats {
            display: flex;
            gap: 15px;
            font-size: 12px;
            opacity: 0.9;
        }

        .stat-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 10px;
            background: rgba(255,255,255,0.2);
            border-radius: 12px;
        }

        .date-group-content {
            background: white;
            border: 1px solid #cbd5e1;
            border-top: none;
            border-radius: 0 0 10px 10px;
        }

        .date-group-content.hidden {
            display: none;
        }

        /* ================= GROUPING BY BOOK ================= */
        .book-group {
            border-bottom: 2px solid #f1f5f9;
            overflow: hidden;
        }

        .book-group:last-child {
            border-bottom: none;
        }

        .book-group-header {
            background: #f8fafc;
            padding: 12px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e2e8f0;
            font-size: 13px;
            font-weight: 600;
            color: #475569;
        }

        .book-group-left {
            display: flex;
            align-items: center;
            gap: 10px;
            flex: 1;
        }

        .book-count {
            background: #dbeafe;
            color: #1d4ed8;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 700;
        }

        /* ================= RESERVATION ITEM ================= */
        .reservation-item {
            padding: 12px 24px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 15px;
            transition: background 0.2s ease;
        }

        .reservation-item:hover {
            background: #f8fafc;
        }

        .reservation-item:last-child {
            border-bottom: none;
        }

        .reservation-item-content {
            flex: 1;
            min-width: 0;
        }

        .reservation-item-header {
            display: flex;
            align-items: center;
            gap: 12px;
            margin-bottom: 8px;
        }

        .reservation-item-id {
            font-weight: 700;
            color: #0f172a;
            font-size: 14px;
        }

        .reservation-item-user {
            font-size: 13px;
            color: #64748b;
        }

        .reservation-item-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px 20px;
            font-size: 12px;
            color: #64748b;
        }

        .reservation-item-actions {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .no-reservations {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }

        @media (max-width: 768px) {
            .reservation-item {
                flex-direction: column;
                align-items: flex-start;
            }

            .reservation-item-actions {
                justify-content: flex-start;
                width: 100%;
            }
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>

<body class="panel-body">
    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

    <main class="panel-main">
        <div class="pm-header">
            <h1 class="pm-title">Quản lý Đặt Trước Sách</h1>
            <p class="pm-subtitle">Theo dõi và xử lý các đặt trước sách trong hệ thống</p>
        </div>

        <!-- BỘ LỌC -->
        <div class="filter-bar">
            <div class="filter-group">
                <label>Lọc theo trạng thái</label>
                <select id="statusFilter" onchange="applyFilters()">
                    <option value="">-- Tất cả --</option>
                    <option value="WAITING">Đang chờ</option>
                    <option value="AVAILABLE">Sẵn sàng nhận</option>
                    <option value="BORROWED">Đã mượn</option>
                    <option value="CANCELLED">Đã hủy</option>
                    <option value="EXPIRED">Hết hạn</option>
                </select>
            </div>
            <div class="filter-group">
                <label>Tìm kiếm theo tên/email</label>
                <input type="text" id="searchFilter" placeholder="Nhập tên..." onkeyup="applyFilters()">
            </div>
            <div class="filter-group">
                <button type="button" onclick="resetFilters()" class="btn-modern btn-secondary">
                    ↻ Đặt lại
                </button>
            </div>
        </div>

        <!-- DANH SÁCH ĐẶT TRƯỚC -->
        <div id="reservationsList">
            <c:choose>
                <c:when test="${empty reservations}">
                    <div class="no-reservations">
                        <div style="font-size: 48px; margin-bottom: 15px; opacity: 0.6;">📚</div>
                        <h3>Không có đặt trước nào</h3>
                        <p>Hiện tại không có yêu cầu đặt trước sách trong hệ thống</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <%-- Tính toán grouped data bằng Java --%>
                    <%
                        java.util.LinkedHashMap<String, java.util.LinkedHashMap<String, java.util.List<com.lbms.model.Reservation>>> groups = 
                            new java.util.LinkedHashMap<>();
                        java.util.List<com.lbms.model.Reservation> reservations = 
                            (java.util.List<com.lbms.model.Reservation>) request.getAttribute("reservations");
                        
                        if (reservations != null && !reservations.isEmpty()) {
                            java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd/MM/yyyy");
                            
                            for (com.lbms.model.Reservation res : reservations) {
                                String dateStr = sdf.format(res.getCreatedAt());
                                String bookKey = res.getBookId() + "|" + res.getBookTitle() + "|" + res.getBookAuthor();
                                
                                groups.computeIfAbsent(dateStr, k -> new java.util.LinkedHashMap<>())
                                      .computeIfAbsent(bookKey, k -> new java.util.ArrayList<>())
                                      .add(res);
                            }
                        }
                        request.setAttribute("groups", groups);
                    %>

                    <c:forEach var="dateEntry" items="${groups}">
                        <c:set var="dateKey" value="${dateEntry.key}"/>
                        <c:set var="bookMap" value="${dateEntry.value}"/>
                        
                        <%-- Tính stats cho ngày --%>
                        <c:set var="dateTotal" value="0"/>
                        <c:set var="dateWaiting" value="0"/>
                        <c:set var="dateAvailable" value="0"/>
                        <c:forEach var="bookEntry" items="${bookMap}">
                            <c:forEach var="res" items="${bookEntry.value}">
                                <c:set var="dateTotal" value="${dateTotal + 1}"/>
                                <c:if test="${res.status == 'WAITING'}">
                                    <c:set var="dateWaiting" value="${dateWaiting + 1}"/>
                                </c:if>
                                <c:if test="${res.status == 'AVAILABLE'}">
                                    <c:set var="dateAvailable" value="${dateAvailable + 1}"/>
                                </c:if>
                            </c:forEach>
                        </c:forEach>

                        <div class="date-group" data-date="${dateKey}">
                            <div class="date-group-header" onclick="toggleDateGroup(this)">
                                <div class="date-group-header-left">
                                    <span class="date-group-toggle">▼</span>
                                    <span class="date-group-title">📅 ${dateKey}</span>
                                </div>
                                <div class="date-group-stats">
                                    <span class="stat-badge">Tổng: <strong>${dateTotal}</strong></span>
                                    <c:if test="${dateWaiting > 0}">
                                        <span class="stat-badge" style="color: #f59e0b;">⏳ Chờ: <strong>${dateWaiting}</strong></span>
                                    </c:if>
                                    <c:if test="${dateAvailable > 0}">
                                        <span class="stat-badge" style="color: #3b82f6;">✓ Sẵn sàng: <strong>${dateAvailable}</strong></span>
                                    </c:if>
                                </div>
                            </div>

                            <div class="date-group-content">
                                <%-- Nhóm theo sách --%>
                                <c:forEach var="bookEntry" items="${bookMap}">
                                    <%
                                        String bookKey = (String) pageContext.getAttribute("bookKey");
                                        Object bookEntryKey = pageContext.findAttribute("bookEntry").getClass()
                                            .getDeclaredMethods()[0].invoke(pageContext.findAttribute("bookEntry"));
                                    %>
                                    <c:set var="bookKeyStr" value="${bookEntry.key}"/>
                                    <c:set var="bookResList" value="${bookEntry.value}"/>
                                    <%
                                        String bookKeyStr = (String) pageContext.getAttribute("bookKeyStr");
                                        String[] bookParts = bookKeyStr.split("\\|", 3);
                                        pageContext.setAttribute("bookId", bookParts[0]);
                                        pageContext.setAttribute("bookTitle", bookParts.length > 1 ? bookParts[1] : "");
                                        pageContext.setAttribute("bookAuthor", bookParts.length > 2 ? bookParts[2] : "");
                                    %>

                                    <div class="book-group">
                                        <div class="book-group-header">
                                            <div class="book-group-left">
                                                <span>📖 <strong>${bookTitle}</strong></span>
                                            </div>
                                            <span class="book-count">${fn:length(bookResList)} đặt</span>
                                        </div>

                                        <c:forEach var="res" items="${bookResList}">
                                            <div class="reservation-item" data-status="${res.status}" data-search="${fn:toLowerCase(res.userName)} ${fn:toLowerCase(res.userEmail)}">
                                                <div class="reservation-item-content">
                                                    <div class="reservation-item-header">
                                                        <span class="reservation-item-id">#${res.id}</span>
                                                        <span class="status-badge status-${res.status}">${res.statusLabel}</span>
                                                    </div>
                                                    <div class="reservation-item-user">
                                                        <strong>${res.userName}</strong> &bull; ${res.userEmail}
                                                        <c:if test="${not empty res.userPhone}"> &bull; ${res.userPhone}</c:if>
                                                    </div>
                                                    <div class="reservation-item-meta">
                                                        <span>📖 ${res.bookAuthor}</span>
                                                        <c:if test="${not empty res.queuePosition}">
                                                            <span>🔢 Vị trí: #${res.queuePosition}</span>
                                                        </c:if>
                                                        <span>⏱️ Lúc <fmt:formatDate value="${res.createdAt}" pattern="HH:mm"/></span>
                                                        <c:if test="${res.status == 'AVAILABLE' && not empty res.expiredAt}">
                                                            <span>📅 Hạn: <fmt:formatDate value="${res.expiredAt}" pattern="dd/MM/yyyy"/></span>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <div class="reservation-item-actions">
                                                    <c:if test="${res.status == 'AVAILABLE' || res.status == 'WAITING'}">
                                                        <button type="button" onclick="viewQueue(${res.bookId})" 
                                                                class="btn-modern btn-primary" style="padding: 6px 12px; font-size: 11px;">
                                                            📋 Queue
                                                        </button>
                                                    </c:if>
                                                    <c:if test="${res.status == 'AVAILABLE'}">
                                                        <button type="button" onclick="markAsBorrowed(${res.id})" 
                                                                class="btn-modern btn-success" style="padding: 6px 12px; font-size: 11px;">
                                                            ✓ Mượn
                                                        </button>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <script>
        function toggleDateGroup(header) {
            const content = header.nextElementSibling;
            header.classList.toggle('collapsed');
            content.classList.toggle('hidden');
        }

        function applyFilters() {
            const statusFilter = document.getElementById('statusFilter').value;
            const searchFilter = document.getElementById('searchFilter').value.toLowerCase();
            
            document.querySelectorAll('.reservation-item').forEach(item => {
                const status = item.getAttribute('data-status');
                const search = item.getAttribute('data-search');
                
                const matchStatus = !statusFilter || status === statusFilter;
                const matchSearch = !searchFilter || search.includes(searchFilter);
                
                item.style.display = (matchStatus && matchSearch) ? 'flex' : 'none';
            });

            // Hide empty groups
            document.querySelectorAll('.book-group').forEach(group => {
                const visibleItems = group.querySelectorAll('.reservation-item[style*="flex"], .reservation-item:not([style])');
                const hasVisible = Array.from(visibleItems).some(item => item.style.display !== 'none');
                group.style.display = hasVisible ? 'block' : 'none';
            });

            document.querySelectorAll('.date-group').forEach(group => {
                const visibleBooks = group.querySelectorAll('.book-group[style*="block"], .book-group:not([style])');
                const hasVisible = Array.from(visibleBooks).some(book => book.style.display !== 'none');
                group.style.display = hasVisible ? 'block' : 'none';
            });
        }

        function resetFilters() {
            document.getElementById('statusFilter').value = '';
            document.getElementById('searchFilter').value = '';
            applyFilters();
        }

        function viewQueue(bookId) {
            window.location.href = '${pageContext.request.contextPath}/staff/reservation?action=queue&bookId=' + bookId;
        }

        function markAsBorrowed(reservationId) {
            Swal.fire('Thông báo', 'Tính năng này sẽ được cập nhật', 'info');
        }
    </script>
</body>

</html>
