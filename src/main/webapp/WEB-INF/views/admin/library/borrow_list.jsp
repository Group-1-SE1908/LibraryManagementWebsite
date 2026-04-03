<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Quản lý Mượn Trả Toàn Hệ Thống | LBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
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
                position: static !important;
                /* Ép badge không bị nhảy ra khỏi div */
                display: inline-flex !important;
                align-items: center;
                justify-content: center;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                white-space: nowrap;
                /* Chống rớt chữ trong badge */
            }

            .status-REQUESTED {
                background: #fef3c7;
                color: #92400e;
            }

            .status-APPROVED {
                background: #dbeafe;
                color: #1d4ed8;
            }

            .status-RECEIVED {
                background: #ccfbf1;
                color: #0f766e;
            }

            .status-BORROWED {
                background: #dcfce7;
                color: #166534;
            }

            .status-RETURNED {
                background: #e2e8f0;
                color: #334155;
            }

            .status-REJECTED {
                background: #f1f5f9;
                color: #475569;
            }

            /* ================= GIAO DIỆN CARD CHO ĐƠN MƯỢN ================= */
            .order-card {
                background: #ffffff;
                border-radius: 10px;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
                margin-bottom: 25px;
                border: 1px solid #cbd5e1;
                overflow: hidden;
            }

            .order-header {
                background: #f8fafc;
                padding: 15px 25px;
                border-bottom: 2px solid #e2e8f0;
                display: flex;
                justify-content: space-between;
                align-items: center;
                flex-wrap: wrap;
                gap: 15px;
            }

            .order-header-info {
                display: flex;
                flex-direction: column;
                gap: 6px;
            }

            .order-header-info .order-id {
                font-weight: 800;
                color: #0f172a;
                font-size: 16px;
            }

            .order-header-info .user-meta {
                font-size: 13px;
                color: #475569;
                font-weight: 500;
            }

            /* --- CẤU TRÚC HÀNG SÁCH (CHỐNG VỠ LAYOUT) --- */
            .book-item-row {
                display: flex;
                justify-content: space-between;
                align-items: center;
                padding: 18px 25px;
                border-bottom: 1px solid #f1f5f9;
                gap: 20px;
            }

            .book-item-row:hover {
                background-color: #f8fafc;
            }

            .book-item-row:last-child {
                border-bottom: none;
            }

            .book-info {
                flex: 1;
                /* Cho phép chiếm hết không gian trống */
                min-width: 0;
                /* Bắt buộc để chống tràn nội dung Flexbox */
            }

            .book-info .book-title {
                font-weight: 700;
                color: #1e293b;
                font-size: 15px;
                margin-bottom: 8px;
            }

            /* Nhóm thông tin meta sách thiết kế dạng các khối (block) inline */
            .book-meta {
                display: flex;
                flex-wrap: wrap;
                gap: 12px 20px;
                font-size: 13px;
                color: #64748b;
            }

            /* Khối chứa từng thông tin (Ngày, Hẹn trả, Trạng thái) */
            .meta-item {
                display: flex;
                align-items: center;
                gap: 6px;
                white-space: nowrap;
                /* BẮT BUỘC: Giữ các chữ dính liền, không bị vỡ vụn */
            }

            .book-actions {
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 10px;
                justify-content: flex-end;
                flex-shrink: 0;
                /* BẮT BUỘC: Cấm Flexbox ép nhỏ các nút bấm */
            }

            /* ================= NÚT BẤM ================= */
            /* btn-modern styles are defined in admin-panel.css */

            @media (max-width: 768px) {
                .book-item-row {
                    flex-direction: column;
                    align-items: flex-start;
                }

                .book-actions {
                    width: 100%;
                    justify-content: flex-start;
                    margin-top: 10px;
                }
            }

            .my-swal-input {
                width: 90% !important;
                margin: 10px auto !important;
                border-radius: 8px !important;
                border: 1px solid #cbd5e1 !important;
                padding: 12px !important;
                font-size: 14px !important;
            }
        </style>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
              rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    </head>

    <body class="panel-body">
        <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
        <c:set var="borrowBase"
               value="${not empty staffBorrowBase ? staffBorrowBase : '/staff/borrowlibrary'}" />
        <c:set var="renewalBase"
               value="${not empty staffRenewalBase ? staffRenewalBase : '/staff/renewal'}" />

        <main class="panel-main">
            <div class="pm-header">
                <h1 class="pm-title">Quản lý Mượn Trả</h1>
                <p class="pm-subtitle">Theo dõi, duyệt và xử lý tất cả các phiếu mượn sách trong hệ thống.
                </p>
            </div>

            <form action="${pageContext.request.contextPath}${borrowBase}" method="get" class="filter-bar">
                <div class="filter-group">
                    <label>Tìm kiếm</label>
                    <input type="text" name="q" placeholder="Tên user hoặc tên sách..." value="${param.q}">
                </div>
                <div class="filter-group">
                    <label>Trạng thái</label>
                    <select name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="REQUESTED" ${param.status=='REQUESTED' ? 'selected' : '' }>Chờ
                            duyệt</option>
                        <option value="APPROVED" ${param.status=='APPROVED' ? 'selected' : '' }>Đã duyệt
                        </option>
                        <option value="RECEIVED" ${param.status=='RECEIVED' ? 'selected' : '' }>Độc giả
                            đã lấy</option>
                        <option value="BORROWED" ${param.status=='BORROWED' ? 'selected' : '' }>Đang
                            mượn</option>
                        <option value="RETURNED" ${param.status=='RETURNED' ? 'selected' : '' }>Đã trả
                        </option>
                    </select>
                </div>
                <button type="submit" class="btn-modern primary" style="padding: 14px 20px;">Áp dụng
                    lọc</button>
                <a href="${pageContext.request.contextPath}${borrowBase}" class="btn-modern secondary"
                   style="padding: 10px 20px;">Xóa lọc</a>
            </form>

            <%-- Hiển thị thông báo Thành công --%>
            <c:if test="${not empty flash}">
                <script>
                    Swal.fire({
                        icon: 'success',
                        title: 'Thành công',
                        html: `${fn:escapeXml(flash)}`, // Dùng backtick để an toàn hơn
                        confirmButtonColor: '#0b57d0',
                        timer: 3000
                    });
                </script>
                <% session.removeAttribute("flash"); %>
            </c:if>

            <%-- Hiển thị thông báo Lỗi --%>
            <c:if test="${not empty flashError}">
                <script>
                    Swal.fire({
                        icon: 'error',
                        title: 'Lỗi nghiệp vụ',
                        html: `${fn:escapeXml(flashError)}`, // Dùng html thay vì text
                        confirmButtonColor: '#dc2626',
                        confirmButtonText: 'OK'
                    }).then(() => {
                        // Tự động focus lại ô input barcode nếu đang hiển thị
                        const visibleInputs = document.querySelectorAll('input[id^="bc-input-"], input[id^="ret-bc-"]');
                        for (let input of visibleInputs) {
                            if (input.offsetParent !== null) {
                                input.focus();
                                input.select();
                                break;
                            }
                        }
                    });
                </script>
                <% session.removeAttribute("flashError");%>
            </c:if>

            <script>
                window.onpageshow = function (event) {
                    if (event.persisted || (window.performance && window.performance.navigation.type === 2)) {
                        window.location.reload();
                    }
                };
            </script>

            <div class="order-list-container">
                <c:forEach items="${groupedRecords}" var="entry">
                    <c:set var="groupCode" value="${entry.key}" />
                    <c:set var="recordsInGroup" value="${entry.value}" />
                    <c:set var="firstRecord" value="${recordsInGroup[0]}" />

                    <div class="order-card">

                        <div class="order-header">
                            <div class="order-header-info">
                                <div class="order-id">Mã đơn: <span style="color: #0ea5e9;">${groupCode}</span></div>
                                <div class="user-meta">
                                    👤 ${firstRecord.user.fullName} &nbsp;|&nbsp; 📞 ${firstRecord.user.phone}
                                </div>
                            </div>

                            <div style="text-align: right;">
                                <c:set var="normalizedGroupStatus" value="${fn:toUpperCase(fn:trim(firstRecord.status))}" />




                                <span class="status-badge status-${normalizedGroupStatus}">
                                    <c:choose>
                                        <c:when test="${normalizedGroupStatus == 'SHIPPING'}">🚚 Đang giao (Nội bộ)</c:when>
                                        <c:otherwise>${normalizedGroupStatus}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </div>
                        <div class="order-body">
                            <c:forEach items="${recordsInGroup}" var="r">
                                <div class="book-item-row">

                                    <div class="book-info">
                                        <div class="book-title">📖 ${r.book.title}</div>

                                        <div class="book-meta">
                                            <div class="meta-item">
                                                <strong>Ngày mượn:</strong> ${r.formattedBorrowDate}
                                            </div>
                                            <div class="meta-item">
                                                <strong>Hẹn trả:</strong> <span
                                                    style="color:#ef4444;">${r.formattedDueDate}</span>
                                            </div>
                                            <div class="meta-item">
                                                <c:set var="itemStatus"
                                                       value="${fn:toUpperCase(fn:trim(r.status))}" />
                                                <strong>Trạng thái:</strong>
                                                <span class="status-badge status-${itemStatus}"
                                                      style="font-size: 11px; padding: 4px 8px; margin-bottom: 0;">
                                                    <c:choose>
                                                        <c:when test="${itemStatus == 'REQUESTED'}">⏳
                                                            Chờ duyệt</c:when>
                                                        <c:when test="${itemStatus == 'APPROVED'}">✅ Đã
                                                            duyệt</c:when>
                                                        <c:when test="${itemStatus == 'BORROWED'}">📖
                                                            Đang mượn</c:when>
                                                        <c:when test="${itemStatus == 'RECEIVED'}">🤝 Đã
                                                            nhận</c:when>
                                                        <c:when test="${itemStatus == 'SHIPPING'}">🚚
                                                            Đang giao (GHTK)</c:when>
                                                        <c:when test="${itemStatus == 'RETURN_REQUESTED'}">
                                                            <span class="badge bg-warning text-dark">🚚 Chờ nhận hàng</span>
                                                        </c:when>
                                                        <c:when test="${itemStatus == 'RETURNED'}">📥 Đã
                                                            trả</c:when>
                                                        <c:when test="${itemStatus == 'REJECTED'}">❌ Từ
                                                            chối</c:when>
                                                        <c:otherwise>${itemStatus}</c:otherwise>
                                                    </c:choose>
                                                </span>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="book-actions">
                                        <c:set var="itemStatus" value="${fn:toUpperCase(fn:trim(r.status))}" />
                                        <c:set var="isOnline" value="${fn:toUpperCase(fn:trim(r.borrowMethod)) == 'ONLINE'}" />

                                        <c:if test="${r.status == 'REQUESTED'}">
                                            <div id="box-${r.id}"
                                                 style="display:none; gap:5px; align-items:center;">
                                                <input type="text" id="bc-input-${r.id}"
                                                       placeholder="Quét mã..."
                                                       style="padding: 6px; border: 1px solid #cbd5e1; border-radius: 4px; width: 110px; outline:none;">
                                                <button type="button" onclick="suggestBarcode(${r.id}, ${r.book.id})" 
                                                        class="btn-modern secondary" style="padding: 6px; font-size: 10px;">Gợi ý</button>
                                                <button onclick="confirmApprove(${r.id})"
                                                        class="btn-modern primary">OK</button>
                                            </div>

                                            <button id="btn-show-${r.id}" onclick="showInput(${r.id})"
                                                    class="btn-modern primary">Duyệt sách</button>

                                            <form
                                                action="${pageContext.request.contextPath}${borrowBase}/reject"
                                                method="post" style="margin:0;"
                                                onsubmit="confirmReject(event, this)">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <button type="submit" class="btn-modern danger">Từ
                                                    chối</button>
                                            </form>

                                        </c:if>


                                        <c:if test="${itemStatus == 'BORROWED' || (itemStatus == 'RECEIVED' && !isOnline)}">

                                            <%-- BƯỚC A: Thêm logic tính toán ngày ngay tại đây --%>
                                            <jsp:useBean id="now" class="java.util.Date" />
                                            <fmt:parseDate value="${r.dueDate}" pattern="yyyy-MM-dd" var="dueDateObj" />
                                            <c:set var="diffInDays" value="${(now.time - dueDateObj.time) / (1000 * 60 * 60 * 24)}" />

                                            <c:choose>
                                                <%-- BƯỚC B: Nếu quá hạn > 10 ngày, hiện nút báo mất/đóng đơn --%>
                                                <c:when test="${diffInDays > 10}">
                                                    <form action="${pageContext.request.contextPath}${borrowBase}/mark-lost" method="POST" 
                                                          onsubmit="return confirm('Đơn hàng đã quá hạn 10 ngày. Bạn có chắc chắn muốn đóng đơn và báo mất tài sản?')">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="button" onclick="confirmMarkLost(${r.id})" class="btn-modern danger" style="background: #475569;">
                                                            Đóng đơn (Báo mất)
                                                        </button>
                                                    </form>
                                                </c:when>

                                                <%-- BƯỚC C: Nếu chưa quá 10 ngày, hiện nút Nhận trả cũ --%>
                                                <c:otherwise>
                                                    <div id="return-box-${r.id}" style="display:none; gap:5px; align-items:center;">
                                                        <input type="text" id="ret-bc-${r.id}" placeholder="Mã trả sách..."
                                                               style="padding: 6px; border: 1px solid #10b981; border-radius: 4px; width: 110px; outline:none;">
                                                        <button onclick="submitReturn(${r.id})" class="btn-modern success">Xác nhận</button>
                                                    </div>
                                                    <button id="btn-ret-show-${r.id}" onclick="showReturn(${r.id})" class="btn-modern success">Nhận trả</button>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>

                                        <%-- BƯỚC D: Thêm badge hiển thị cho trạng thái LOST (nếu có) --%>
                                        <c:if test="${itemStatus == 'LOST'}">
                                            <span class="status-badge" style="background: #1e293b; color: white;">❌ ĐÃ ĐÓNG (MẤT SÁCH)</span>
                                        </c:if>

                                        <c:if test="${r.status == 'APPROVED'}">
                                            <c:choose>
                                                <c:when
                                                    test="${fn:toUpperCase(fn:trim(r.borrowMethod)) eq 'ONLINE'}">
                                                    <span
                                                        style="font-size:12px; color:#d97706; font-weight: 600;">(Đơn
                                                        chờ gọi GHTK)</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                    <form
                                                        action="${pageContext.request.contextPath}${borrowBase}/receive"
                                                        method="post" style="margin:0;">
                                                        <input type="hidden" name="id" value="${r.id}">
                                                        <button type="submit" class="btn-modern primary">Độc
                                                            giả đã
                                                            nhận</button>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>

                                        </c:if>

                                        <c:if test="${itemStatus == 'SHIPPING'}">
                                            <form action="${pageContext.request.contextPath}${borrowBase}/receive" method="POST" style="display:inline;">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <button type="submit" class="btn-modern primary">Khách đã nhận</button>
                                            </form>
                                        </c:if>



                                        <c:if test="${fn:toUpperCase(r.status) == 'RETURN_REQUESTED'}">
                                            <div class="d-flex align-items-center">
                                                <input type="text" id="bc-input-${r.id}" class="form-control-sm me-2" placeholder="Quét barcode...">
                                                <button class="btn btn-modern btn-warning" onclick="submitReturnOnline(${r.id})">
                                                    Xác nhận nhập kho
                                                </button>

                                            </div>
                                        </c:if>
                                        <c:set var="pendingRenewal" value="${pendingRenewalMap[r.id]}" />
                                        <c:if test="${not empty pendingRenewal}">
                                            <span class="status-badge status-RENEWAL_REQUESTED"
                                                  style="background:#fef3c7;color:#92400e;font-size:11px;">Gia
                                                hạn chờ duyệt</span>
                                            <a href="${pageContext.request.contextPath}${renewalBase}/view?id=${pendingRenewal.id}"
                                               class="btn-modern secondary" style="padding: 8px 14px;">Xem
                                                yêu cầu gia hạn</a>
                                            </c:if>
                                            <c:set var="renewalCount" value="${renewalCountMap[r.id]}" />
                                            <c:if test="${not empty renewalCount && renewalCount > 0}">
                                            <span class="status-badge status-RENEWAL_REQUESTED"
                                                  style="background:#e0f2fe;color:#075985;font-size:11px;">
                                                Đã gửi gia hạn ${renewalCount} lần
                                            </span>
                                        </c:if>
                                        <a href="${pageContext.request.contextPath}${borrowBase}/detail?id=${r.id}"
                                           class="btn-modern secondary">Xem Chi tiết</a>
                                    </div>

                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:forEach>

                <c:if test="${empty groupedRecords}">
                    <div
                        style="text-align: center; padding: 40px; background: white; border-radius: 10px; border: 1px dashed #cbd5e1; color: #64748b;">
                        <h4>Không tìm thấy dữ liệu mượn trả nào.</h4>
                    </div>
                </c:if>
            </div>

            <script>
                // 1. Hàm hiển thị ô nhập liệu quét mã
                function showInput(id) {
                    document.getElementById('box-' + id).style.display = 'flex';
                    document.getElementById('btn-show-' + id).style.display = 'none';
                }

                function showReturn(id) {
                    document.getElementById('return-box-' + id).style.display = 'flex';
                    document.getElementById('btn-ret-show-' + id).style.display = 'none';
                }

                // 2. Hàm Xác nhận Duyệt sách
                function confirmApprove(id) {
                    const barcodeVal = document.getElementById('bc-input-' + id).value;
                    if (!barcodeVal) {
                        Swal.fire({icon: 'warning', title: 'Thiếu thông tin', text: 'Vui lòng nhập mã vạch vật lý của sách!'});
                        return;
                    }

                    Swal.fire({
                        title: 'Xác nhận duyệt sách?',
                        text: "Hệ thống sẽ gắn mã vạch này cho phiếu mượn.",
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#0b57d0',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Đồng ý duyệt',
                        cancelButtonText: 'Hủy'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            const form = document.createElement('form');
                            form.method = 'POST';
                            form.action = '${pageContext.request.contextPath}${borrowBase}/approve';
                            form.innerHTML = '<input type="hidden" name="id" value="' + id + '">' +
                                    '<input type="hidden" name="barcode" value="' + barcodeVal + '">';
                            document.body.appendChild(form);
                            form.submit();
                        }
                    });
                }

                // 3. Hàm Xác nhận Trả sách

                function submitReturn(id) {
                    // 1. Lấy giá trị từ đúng ô input của dòng đó
                    const bc = document.getElementById('ret-bc-' + id).value;
                    if (!bc) {
                        Swal.fire({icon: 'warning', title: 'Thiếu thông tin', text: 'Vui lòng quét lại mã vạch trên sách để xác nhận trả!'});
                        return;
                    }

                    Swal.fire({
                        title: 'Xác nhận nhận trả sách?',
                        text: "Sách sẽ được cộng lại vào kho thư viện.",
                        icon: 'info',
                        showCancelButton: true,
                        confirmButtonColor: '#10b981',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Đúng, trả sách!',
                        cancelButtonText: 'Hủy'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            const form = document.createElement('form');
                            form.method = 'POST';
                            form.action = '${pageContext.request.contextPath}${borrowBase}/return';

                            // 3. Truyền đúng biến 'bc' và dùng nối chuỗi an toàn
                            form.innerHTML = '<input type="hidden" name="id" value="' + id + '">' +
                                    '<input type="hidden" name="barcode" value="' + bc.trim() + '">';

                            document.body.appendChild(form);
                            form.submit();
                        }
                    });
                }

                // 4. Hàm Xác nhận Từ chối (Có bắt nhập lý do)
                function confirmReject(event, formElement) {
                    event.preventDefault();

                    Swal.fire({
                        title: 'Lý do từ chối?',
                        text: 'Vui lòng cho độc giả biết lý do bạn từ chối đơn mượn này:',
                        input: 'text',
                        inputPlaceholder: 'Ví dụ: Sách đã hỏng, Độc giả vi phạm nội quy...',
                        showCancelButton: true,
                        confirmButtonColor: '#ef4444',
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Xác nhận từ chối',
                        cancelButtonText: 'Quay lại',
                        customClass: {
                            input: 'my-swal-input'
                        },

                        inputValidator: (value) => {
                            if (!value) {
                                return 'Bạn phải nhập lý do từ chối!'
                            }
                        }
                    }).then((result) => {
                        if (result.isConfirmed) {
                            const input = document.createElement('input');
                            input.type = 'hidden';
                            input.name = 'reason';
                            input.value = result.value;
                            formElement.appendChild(input);
                            formElement.submit();
                        }
                    });
                }
                // Tìm hàm submitReturnOnline (dòng 356) và sửa lại phần action
                function submitReturnOnline(id) {
                    const barcode = document.getElementById('bc-input-' + id).value;
                    if (!barcode) {
                        alert('Vui lòng quét mã vạch!');
                        return;
                    }

                    const form = document.createElement('form');
                    form.method = 'POST';
                    // Đảm bảo gửi về đúng địa chỉ borrowBase (ví dụ /staff/borrowlibrary)
                    form.action = '${pageContext.request.contextPath}${borrowBase}';

                    const params = {
                        'action': 'return', // Để Controller nhận diện lệnh trả sách
                        'id': id,
                        'barcode': barcode.trim()
                    };

                    for (const key in params) {
                        const input = document.createElement('input');
                        input.type = 'hidden';
                        input.name = key;
                        input.value = params[key];
                        form.appendChild(input);
                    }
                    document.body.appendChild(form);
                    form.submit();
                }
                // Thêm vào phần script trong borrow_list.jsp
                function confirmCustomerReceived(id) {
                    Swal.fire({
                        title: 'Xác nhận khách đã nhận sách?',
                        text: "Trạng thái đơn hàng sẽ được chuyển sang 'Đã nhận'.",
                        icon: 'question',
                        showCancelButton: true,
                        confirmButtonColor: '#0b57d0',
                        confirmButtonText: 'Đúng, xác nhận',
                        cancelButtonText: 'Hủy'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            const form = document.createElement('form');
                            form.method = 'POST';
                            form.action = '${pageContext.request.contextPath}${borrowBase}/receive';
                            form.innerHTML = '<input type="hidden" name="id" value="' + id + '">';
                            document.body.appendChild(form);
                            form.submit();
                        }
                    });
                }
                function createManualShipment(groupCode) {
                    const form = document.createElement('form');
                    form.method = 'POST';
                    form.action = '${pageContext.request.contextPath}${borrowBase}';
                    form.innerHTML = `
        <input type="hidden" name="action" value="create-manual">
        <input type="hidden" name="groupCode" value="${groupCode}">
    `;
                    document.body.appendChild(form);
                    form.submit();
                }

                // Thay thế hàm submitReturnOnline (dòng 859) trong borrow_list.jsp
                function submitReturnOnline(id) {
                    const bcInput = document.getElementById('bc-input-' + id);
                    const bcValue = bcInput ? bcInput.value.trim() : "";

                    if (!bcValue) {
                        Swal.fire('Cảnh báo', 'Vui lòng nhập mã vạch sách trả!', 'warning');
                        return;
                    }

                    const form = document.createElement('form');
                    form.method = 'POST';
                    // Gửi về đúng địa chỉ base của Controller
                    form.action = '${pageContext.request.contextPath}${borrowBase}/return';

                    form.innerHTML = '<input type="hidden" name="id" value="' + id + '">' +
                            '<input type="hidden" name="barcode" value="' + bcValue + '">' +
                            '<input type="hidden" name="action" value="return">';

                    document.body.appendChild(form);
                    form.submit();
                }
                function confirmMarkLost(id) {
                    Swal.fire({
                        title: 'Cảnh báo mất sách!',
                        text: "Bạn có chắc chắn muốn đóng đơn #" + id + " không? Thao tác này sẽ đánh dấu sách là 'MẤT' và không thể hoàn tác.",
                        icon: 'warning',
                        showCancelButton: true,
                        confirmButtonColor: '#dc2626', // Màu đỏ đậm cho hành động nguy hiểm
                        cancelButtonColor: '#64748b',
                        confirmButtonText: 'Đồng ý, đóng đơn!',
                        cancelButtonText: 'Quay lại',
                        background: '#fff',
                        backdrop: `rgba(0,0,123,0.4)`
                    }).then((result) => {
                        if (result.isConfirmed) {
                            // Tạo form ẩn để gửi request POST lên server
                            const form = document.createElement('form');
                            form.method = 'POST';
                            form.action = '${pageContext.request.contextPath}${borrowBase}/mark-lost';
                            form.innerHTML = '<input type="hidden" name="id" value="' + id + '">';
                            document.body.appendChild(form);
                            form.submit();
                        }
                    });
                }
                function suggestBarcode(borrowId, bookId) {
                    // Gọi AJAX lấy danh sách mã vạch có sẵn
                    fetch('${pageContext.request.contextPath}${borrowBase}/available-copies?bookId=' + bookId)
                            .then(response => response.json())
                            .then(data => {
                                if (data && data.length > 0) {
                                    // Điền mã đầu tiên tìm thấy vào ô input
                                    document.getElementById('bc-input-' + borrowId).value = data[0];

                                    // Hiển thị thông báo nhỏ để Thủ thư biết
                                    const Toast = Swal.mixin({
                                        toast: true,
                                        position: 'top-end',
                                        showConfirmButton: false,
                                        timer: 2000
                                    });
                                    Toast.fire({
                                        icon: 'info',
                                        title: 'Đã chọn mã: ' + data[0]
                                    });
                                } else {
                                    Swal.fire('Hết sách!', 'Hiện không còn bản sao nào khả dụng trong kho.', 'error');
                                }
                            })
                            .catch(error => {
                                console.error('Error:', error);
                                Swal.fire('Lỗi', 'Không thể kết nối máy chủ', 'error');
                            });
                }
            </script>
        </main>
    </body>

</html>