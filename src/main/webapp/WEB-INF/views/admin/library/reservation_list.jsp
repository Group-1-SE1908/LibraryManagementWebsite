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
        /* ================= FILTER TABS ================= */
        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 25px;
            flex-wrap: wrap;
            align-items: center;
        }

        .filter-tab {
            padding: 8px 16px;
            border: 2px solid #cbd5e1;
            border-radius: 8px;
            background: white;
            cursor: pointer;
            transition: all 0.2s ease;
            font-weight: 600;
            font-size: 13px;
            color: #64748b;
        }

        .filter-tab:hover {
            border-color: #667eea;
            color: #667eea;
        }

        .filter-tab.active {
            background: #667eea;
            color: white;
            border-color: #667eea;
        }

        .filter-tab-count {
            background: rgba(255,255,255,0.3);
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 700;
        }

        /* ================= SEARCH/ACTION BAR ================= */
        .action-bar {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            align-items: center;
            flex-wrap: wrap;
        }

        .action-bar input {
            flex: 1;
            min-width: 250px;
            padding: 10px 14px;
            border: 1px solid #cbd5e1;
            border-radius: 8px;
            outline: none;
            font-size: 13px;
        }

        .action-bar input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.2);
        }

        /* ================= BADGE ================= */
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

        .btn-warning {
            background: #f59e0b !important;
            border-color: #f59e0b !important;
            color: white !important;
        }

        .btn-warning:hover {
            background: #d97706 !important;
            border-color: #d97706 !important;
        }

        /* ================= RESERVATION CARD (TABLE-BASED) ================= */
        .order-card {
            background: white;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            margin-bottom: 20px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
        }

        .order-header {
            background: #f8fafc;
            padding: 16px 24px;
            border-bottom: 2px solid #e2e8f0;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 15px;
            min-height: 60px;
        }

        .order-header-left {
            flex: 1;
        }

        .order-id {
            font-weight: 700;
            color: #0f172a;
            font-size: 15px;
        }

        .order-user {
            font-size: 12px;
            color: #64748b;
            margin-top: 4px;
        }

        .order-body {
            padding: 0;
        }

        /* ================= BOOK ITEM ROW ================= */
        .book-item-row {
            padding: 16px 24px;
            border-bottom: 1px solid #f1f5f9;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 20px;
            transition: background 0.2s ease;
        }

        .book-item-row:hover {
            background: #f8fafc;
        }

        .book-item-row:last-child {
            border-bottom: none;
        }

        .book-info {
            flex: 1;
            min-width: 0;
        }

        .book-title {
            font-weight: 700;
            color: #1e293b;
            font-size: 14px;
            margin-bottom: 8px;
        }

        .book-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 12px 20px;
            font-size: 12px;
            color: #64748b;
        }

        .meta-item {
            display: flex;
            align-items: center;
            gap: 6px;
            white-space: nowrap;
        }

        .book-actions {
            display: flex;
            gap: 8px;
            align-items: center;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .barcode-scanner {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .barcode-scanner input {
            padding: 8px 12px;
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 12px;
            width: 150px;
            outline: none;
        }

        .barcode-scanner input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 2px rgba(102, 126, 234, 0.15);
        }

        .no-items {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }

        @media (max-width: 768px) {
            .order-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .book-item-row {
                flex-direction: column;
                align-items: flex-start;
            }

            .book-actions {
                justify-content: flex-start;
                width: 100%;
            }

            .barcode-scanner {
                width: 100%;
            }

            .barcode-scanner input {
                flex: 1;
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
            <p class="pm-subtitle">Xác nhận và xử lý yêu cầu đặt trước sách từ người dùng</p>
        </div>

        <!-- FILTER TABS -->
        <div class="filter-tabs">
            <button class="filter-tab active" onclick="filterByStatus('')">
                Tất cả <span class="filter-tab-count">${fn:length(reservations)}</span>
            </button>
            <c:set var="waitingCount" value="0"/>
            <c:set var="availableCount" value="0"/>
            <c:set var="borrowedCount" value="0"/>
            <c:forEach var="res" items="${reservations}">
                <c:if test="${res.status == 'WAITING'}">
                    <c:set var="waitingCount" value="${waitingCount + 1}"/>
                </c:if>
                <c:if test="${res.status == 'AVAILABLE'}">
                    <c:set var="availableCount" value="${availableCount + 1}"/>
                </c:if>
                <c:if test="${res.status == 'BORROWED'}">
                    <c:set var="borrowedCount" value="${borrowedCount + 1}"/>
                </c:if>
            </c:forEach>
            
            <button class="filter-tab" onclick="filterByStatus('WAITING')">
                ⏳ Đang chờ <span class="filter-tab-count">${waitingCount}</span>
            </button>
            <button class="filter-tab" onclick="filterByStatus('AVAILABLE')">
                ✓ Sẵn sàng nhận <span class="filter-tab-count">${availableCount}</span>
            </button>
            <button class="filter-tab" onclick="filterByStatus('BORROWED')">
                📖 Đã mượn <span class="filter-tab-count">${borrowedCount}</span>
            </button>
        </div>

        <!-- SEARCH BAR -->
        <div class="action-bar">
            <input type="text" id="searchInput" placeholder="🔍 Tìm theo tên user, email, tên sách..." 
                   onkeyup="applySearch()">
            <button type="button" onclick="resetSearch()" class="btn-modern btn-secondary">
                ↻ Xóa tìm kiếm
            </button>
        </div>

        <!-- DANH SÁCH ĐẶT TRƯỚC -->
        <div id="reservationsList">
            <c:choose>
                <c:when test="${empty reservations}">
                    <div class="no-items">
                        <div style="font-size: 48px; margin-bottom: 15px; opacity: 0.6;">📚</div>
                        <h3>Không có đặt trước nào</h3>
                        <p>Hiện tại không có yêu cầu đặt trước sách trong hệ thống</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <%-- Tính toán grouped data: ngày → sách → reservations --%>
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

                        <c:forEach var="bookEntry" items="${bookMap}">
                            <c:set var="bookKeyStr" value="${bookEntry.key}"/>
                            <c:set var="bookResList" value="${bookEntry.value}"/>
                            
                            <%-- Parse bookKey: bookId|bookTitle|bookAuthor --%>
                            <c:set var="bookParts" value="${fn:split(bookKeyStr, '|')}"/>
                            <c:set var="bookId" value="${bookParts[0]}"/>
                            <c:set var="bookTitle" value="${fn:length(bookParts) > 1 ? bookParts[1] : ''}"/>
                            <c:set var="bookAuthor" value="${fn:length(bookParts) > 2 ? bookParts[2] : ''}"/>

                            <div style="margin-bottom: 8px; padding: 12px 0; border-left: 3px solid #667eea; padding-left: 16px;">
                                <div style="font-weight: 600; color: #1e293b; font-size: 13px; margin-bottom: 4px;">
                                    📅 ${dateKey} · 📖 ${bookTitle} <span style="background: #dbeafe; color: #1d4ed8; padding: 2px 8px; border-radius: 12px; font-size: 11px; font-weight: 700;">${fn:length(bookResList)} đặt</span>
                                </div>
                            </div>

                            <c:forEach var="res" items="${bookResList}">
                                <div class="order-card" data-status="${res.status}" 
                                     data-search="${fn:toLowerCase(res.userName)} ${fn:toLowerCase(res.userEmail)} ${fn:toLowerCase(res.bookTitle)}">
                                    
                                    <div class="order-header">
                                        <div class="order-header-left">
                                            <div class="order-id">#${res.id} - ${res.bookTitle}</div>
                                            <div class="order-user">
                                                👤 ${res.userName} | 📞 ${res.userPhone} | ✉️ ${res.userEmail}
                                            </div>
                                        </div>
                                        <span class="status-badge status-${res.status}">
                                            ${res.statusLabel}
                                        </span>
                                    </div>

                                    <div class="order-body">
                                        <div class="book-item-row">
                                            <div class="book-info">
                                                <div class="book-title">📖 ${res.bookTitle}</div>
                                                <div class="book-meta">
                                                    <div class="meta-item">
                                                        <strong>Tác giả:</strong> ${res.bookAuthor}
                                                    </div>
                                                    <div class="meta-item">
                                                        <strong>Ngày đặt:</strong> 
                                                        <fmt:formatDate value="${res.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                    </div>
                                                    <c:if test="${not empty res.queuePosition}">
                                                        <div class="meta-item">
                                                            <strong>Vị trí hàng chờ:</strong> #${res.queuePosition}
                                                        </div>
                                                    </c:if>
                                                    <c:if test="${res.status == 'AVAILABLE'}">
                                                        <div class="meta-item" style="color: #dc2626;">
                                                            <strong>Hạn nhận:</strong> 
                                                            <fmt:formatDate value="${res.expiredAt}" pattern="dd/MM/yyyy"/>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <div class="book-actions">
                                                <c:if test="${res.status == 'AVAILABLE'}">
                                                    <div class="barcode-scanner">
                                                        <input type="text" placeholder="Scan barcode..." 
                                                               onkeypress="if(event.key=='Enter') {
                                                                   scanBarcode(${res.id}, this.value);
                                                                   this.value = '';
                                                               }">
                                                    </div>
                                                    <button type="button" onclick="confirmReceive(${res.id})" 
                                                            class="btn-modern btn-success" style="padding: 8px 12px; font-size: 12px; white-space: nowrap;">
                                                        ✓ Xác nhận lấy
                                                    </button>
                                                    <button type="button" onclick="rejectAvailable(${res.id})" 
                                                            class="btn-modern btn-warning" style="padding: 8px 12px; font-size: 12px; white-space: nowrap;">
                                                        ⏱️ User không tới
                                                    </button>
                                                </c:if>
                                                <c:if test="${res.status == 'WAITING'}">
                                                    <button type="button" onclick="rejectReservation(${res.id})" 
                                                            class="btn-modern btn-danger" style="padding: 8px 12px; font-size: 12px; white-space: nowrap;">
                                                        ❌ Từ chối
                                                    </button>
                                                </c:if>
                                                <button type="button" onclick="viewQueue(${res.bookId})" 
                                                        class="btn-modern btn-secondary" style="padding: 8px 12px; font-size: 12px; white-space: nowrap;">
                                                    📋 Xem Queue
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </c:forEach>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <script>
        function filterByStatus(status) {
            // Update active tab
            document.querySelectorAll('.filter-tab').forEach(tab => {
                tab.classList.remove('active');
            });
            event.target.closest('.filter-tab').classList.add('active');

            // Filter cards
            document.querySelectorAll('.order-card').forEach(card => {
                if (status === '' || card.getAttribute('data-status') === status) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
            applySearch();
        }

        function applySearch() {
            const searchTerm = document.getElementById('searchInput').value.toLowerCase();
            document.querySelectorAll('.order-card').forEach(card => {
                if (card.style.display === 'none') return; // Skip hidden cards
                
                const searchData = card.getAttribute('data-search');
                if (searchTerm === '' || searchData.includes(searchTerm)) {
                    card.style.display = 'block';
                } else {
                    card.style.display = 'none';
                }
            });
        }

        function resetSearch() {
            document.getElementById('searchInput').value = '';
            applySearch();
        }

        function scanBarcode(resId, barcode) {
            if (!barcode.trim()) {
                Swal.fire('Lỗi', 'Vui lòng nhập mã barcode', 'error');
                return;
            }

            // Gửi request lên server để verify barcode
            fetch('${pageContext.request.contextPath}/staff/reservation', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=scan&reservationId=' + resId + '&barcode=' + encodeURIComponent(barcode)
            })
            .then(response => response.json())
            .then(data => {
                if (data.status === 200) {
                    Swal.fire('Thành công', 'Đã quét barcode thành công', 'success').then(() => {
                        location.reload();
                    });
                } else {
                    Swal.fire('Lỗi', data.message || 'Lỗi không xác định', 'error');
                }
            })
            .catch(err => {
                console.error('Error:', err);
                Swal.fire('Lỗi', 'Có lỗi xảy ra khi gửi request', 'error');
            });
        }

        function confirmReceive(resId) {
            Swal.fire({
                title: 'Xác nhận lấy sách?',
                text: 'Xác nhận người dùng đã nhận sách này',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#3b82f6',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Xác nhận',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Gửi request lên server
                    fetch('${pageContext.request.contextPath}/staff/reservation', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'action=approve&reservationId=' + resId
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 200) {
                            Swal.fire('Thành công', 'Đã xác nhận lấy sách', 'success').then(() => {
                                location.reload();
                            });
                        } else {
                            Swal.fire('Lỗi', data.message || 'Lỗi không xác định', 'error');
                        }
                    })
                    .catch(err => {
                        console.error('Error:', err);
                        Swal.fire('Lỗi', 'Có lỗi xảy ra khi gửi request', 'error');
                    });
                }
            });
        }

        function rejectReservation(resId) {
            Swal.fire({
                title: 'Từ chối đặt trước?',
                input: 'textarea',
                inputLabel: 'Lý do từ chối:',
                inputPlaceholder: 'Nhập lý do...',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Từ chối',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    const reason = result.value || 'Không có lý do';
                    
                    // Gửi request lên server
                    fetch('${pageContext.request.contextPath}/staff/reservation', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'action=reject&reservationId=' + resId + '&reason=' + encodeURIComponent(reason)
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 200) {
                            Swal.fire('Thành công', 'Đã từ chối đặt trước', 'success').then(() => {
                                location.reload();
                            });
                        } else {
                            Swal.fire('Lỗi', data.message || 'Lỗi không xác định', 'error');
                        }
                    })
                    .catch(err => {
                        console.error('Error:', err);
                        Swal.fire('Lỗi', 'Có lỗi xảy ra khi gửi request', 'error');
                    });
                }
            });
        }

        function viewQueue(bookId) {
            window.location.href = '${pageContext.request.contextPath}/staff/reservation?action=queue&bookId=' + bookId;
        }

        function rejectAvailable(resId) {
            Swal.fire({
                title: 'User không tới nhận?',
                text: 'Hạn nhận sách đã hết. Bạn muốn cancel đặt trước này?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#ef4444',
                cancelButtonColor: '#6b7280',
                confirmButtonText: 'Có, cancel',
                cancelButtonText: 'Hủy'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Gửi request lên server
                    fetch('${pageContext.request.contextPath}/staff/reservation', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded',
                        },
                        body: 'action=reject&reservationId=' + resId + '&reason=' + encodeURIComponent('User không tới nhận trong hạn')
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.status === 200) {
                            Swal.fire('Thành công', 'Đã hủy đặt trước', 'success').then(() => {
                                location.reload();
                            });
                        } else {
                            Swal.fire('Lỗi', data.message || 'Lỗi không xác định', 'error');
                        }
                    })
                    .catch(err => {
                        console.error('Error:', err);
                        Swal.fire('Lỗi', 'Có lỗi xảy ra khi gửi request', 'error');
                    });
                }
            });
        }
    </script>
</body>

</html>
