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
        <style>
            .filter-bar {
                background: white;
                padding: 20px;
                border-radius: 12px;
                margin-bottom: 25px;
                box-shadow: var(--shadow-sm);
                display: flex;
                gap: 15px;
                align-items: flex-end;
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
            .filter-group input, .filter-group select {
                padding: 10px;
                border: 1px solid #e2e8f0;
                border-radius: 8px;
                min-width: 200px;
            }
            .btn-reject {
                background: #fee2e2;
                color: #991b1b;
                border: 1px solid #fecaca;
                padding: 8px 12px;
                border-radius: 8px;
                cursor: pointer;
                transition: 0.2s;
            }
            .btn-reject:hover {
                background: #fecaca;
            }
            .status-badge {
                padding: 5px 10px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
            }
            .status-REQUESTED {
                background: #fef3c7;
                color: #92400e;
            }
            .status-BORROWED {
                background: #dcfce7;
                color: #166534;
            }
            .status-REJECTED {
                background: #f1f5f9;
                color: #475569;
            }
        </style>
    </head>
    <body>
        <jsp:include page="header_lib.jsp" />

        <div class="container py-4">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1>🛠️ Quản lý Mượn Trả</h1>
            </div>

            <form action="${pageContext.request.contextPath}/borrowlibrary" method="get" class="filter-bar">
                <div class="filter-group">
                    <label>Tìm kiếm</label>
                    <input type="text" name="q" placeholder="Tên user hoặc tên sách..." value="${param.q}">
                </div>
                <div class="filter-group">
                    <label>Trạng thái</label>
                    <select name="status">
                        <option value="">-- Tất cả --</option>
                        <option value="REQUESTED" ${param.status == 'REQUESTED' ? 'selected' : ''}>Chờ duyệt</option>
                        <option value="BORROWED" ${param.status == 'BORROWED' ? 'selected' : ''}>Đang mượn</option>
                        <option value="REJECTED" ${param.status == 'REJECTED' ? 'selected' : ''}>Từ chối</option>
                        <option value="RETURNED" ${param.status == 'RETURNED' ? 'selected' : ''}>Đã trả</option>
                    </select>
                </div>
                <button type="submit" class="btn primary">Áp dụng lọc</button>
                <a href="${pageContext.request.contextPath}/borrowlibrary" class="btn">Xóa lọc</a>
            </form>

            <c:if test="${not empty sessionScope.flash}">
                <script>
                    document.addEventListener("DOMContentLoaded", function () {
                        // Lấy nội dung thông báo từ server
                        const flashMessage = "${sessionScope.flash}";

                        // Tự động nhận diện lỗi: Nếu câu bắt đầu bằng chữ "Lỗi" hoặc "Truy cập" thì hiện icon đỏ (error)
                        const isError = flashMessage.toLowerCase().startsWith("lỗi") || flashMessage.toLowerCase().startsWith("truy cập");

                        Swal.fire({
                            icon: isError ? 'error' : 'success',
                            title: isError ? 'Opps! Có lỗi xảy ra' : 'Thành công!',
                            text: flashMessage,
                            confirmButtonColor: '#0b57d0',
                            confirmButtonText: 'Đóng'
                        });
                    });
                </script>
                <c:remove var="flash" scope="session" />
            </c:if>

            <div class="table-card" style="background:white; border-radius:12px; overflow:hidden; box-shadow: var(--shadow-sm);">
                <table style="width:100%; border-collapse: collapse;">
                    <thead style="background:#f8fafc; border-bottom:1px solid #e2e8f0;">
                        <tr>
                            <th style="padding:15px; text-align:left;">ID</th>
                            <th style="padding:15px; text-align:left;">Người mượn</th>
                            <th style="padding:15px; text-align:left;">Thông tin sách</th>
                            <th style="padding:15px; text-align:left;">Ngày mượn</th>
                            <th style="padding:15px; text-align:left;">Hẹn trả</th>
                            <th style="padding:15px; text-align:left;">Trạng thái</th>
                            <th style="padding:15px; text-align:center;">Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${records}" var="r">
                            <tr>
                                <td>#${r.id}</td>
                                <td>
                                    <div style="font-weight:600;">${r.user.fullName}</div>
                                    <div style="font-size:11px; color:gray;">${r.user.email}</div>
                                </td>
                                <td>${r.book.title}</td>

                                <td>${not empty r.borrowDate ? r.borrowDate : '---'}</td>
                                <td style="color: #ef4444; font-weight: bold;">${not empty r.dueDate ? r.dueDate : '---'}</td>

                                <td><span class="status-badge status-${r.status}">${r.status}</span></td>

                                <td style="text-align:center;">
                                    <div style="display:flex; flex-direction:column; gap:5px; align-items:center;">
                                        <a href="${pageContext.request.contextPath}/borrowlibrary/detail?id=${r.id}" class="btn" style="width:80px;">Chi tiết</a>

                                        <c:if test="${r.status == 'REQUESTED'}">
                                            <div id="box-${r.id}" style="display:none; margin: 10px 0; border: 1px solid #0b57d0; padding: 5px; border-radius: 5px;">
                                                <input type="text" id="bc-input-${r.id}" placeholder="Mã vạch..." style="width:100px;">
                                                <button onclick="confirmApprove(${r.id})" class="btn primary" style="padding: 2px 10px;">OK</button>
                                            </div>
                                            <button id="btn-show-${r.id}" onclick="showInput(${r.id})" class="btn primary" style="width:80px;">Duyệt</button>

                                            <form action="${pageContext.request.contextPath}/borrowlibrary/reject" method="post" style="display:inline; margin:0;">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <button type="submit" class="btn-reject" onclick="return confirm('Từ chối yêu cầu này?')">Từ chối</button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/borrowlibrary/reject" method="post" style="display:inline; margin:0;" onsubmit="confirmReject(event, this)">
                                                <input type="hidden" name="id" value="${r.id}">
                                                <button type="submit" class="btn-reject" style="width:80px;">Từ chối</button>
                                            </form>    
                                        </c:if>

                                        <c:if test="${r.status == 'BORROWED'}">
                                            <div id="return-box-${r.id}" style="display:none; margin: 10px 0; border: 1px solid #10b981; padding: 5px; border-radius: 5px;">
                                                <input type="text" id="ret-bc-${r.id}" placeholder="Quét mã trả..." style="width:100px;">
                                                <button onclick="submitReturn(${r.id})" class="btn success" style="padding: 2px 10px; background:#10b981; color:white; border:none;">Xác nhận trả</button>
                                            </div>
                                            <button id="btn-ret-show-${r.id}" onclick="showReturn(${r.id})" class="btn success" style="background:#10b981; color:white; border:none; width:80px;">Trả sách</button>
                                        </c:if>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <script>
            // 1. Hàm hiển thị ô nhập liệu (Giữ nguyên)
            function showInput(id) {
                document.getElementById('box-' + id).style.display = 'block';
                document.getElementById('btn-show-' + id).style.display = 'none';
            }
            function showReturn(id) {
                document.getElementById('return-box-' + id).style.display = 'block';
                document.getElementById('btn-ret-show-' + id).style.display = 'none';
            }

            // 2. Hàm Xác nhận Duyệt sách
            function confirmApprove(id) {
                const val = document.getElementById('bc-input-' + id).value;
                if (!val) {
                    Swal.fire({icon: 'warning', title: 'Thiếu thông tin', text: 'Vui lòng nhập Barcode trước khi duyệt!'});
                    return;
                }
                window.location.href = "${pageContext.request.contextPath}/borrowlibrary/approve?id=" + id + "&barcode=" + encodeURIComponent(val);
            }

            // 3. Hàm Xác nhận Trả sách (Dùng POST form ẩn)
            function submitReturn(id) {
                const bc = document.getElementById('ret-bc-' + id).value;
                if (!bc) {
                    Swal.fire({icon: 'warning', title: 'Thiếu thông tin', text: 'Vui lòng quét mã vạch trên sách để nhận trả!'});
                    return;
                }

                // Popup hỏi xác nhận trước khi trả
                Swal.fire({
                    title: 'Xác nhận nhận trả sách?',
                    text: "Hệ thống sẽ cập nhật lại số lượng trong kho!",
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
                        form.action = '${pageContext.request.contextPath}/borrowlibrary/return';
                        form.innerHTML = `<input type="hidden" name="id" value="${id}"><input type="hidden" name="barcode" value="${bc}">`;
                        document.body.appendChild(form);
                        form.submit();
                    }
                });
            }

            // 4. Hàm Xác nhận Từ chối (Dùng cho nút form submit)
            function confirmReject(event, formElement) {
                event.preventDefault(); // Chặn form submit ngay lập tức
                Swal.fire({
                    title: 'Từ chối yêu cầu mượn?',
                    text: "Hành động này sẽ hủy yêu cầu của độc giả!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#ef4444',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Đồng ý từ chối',
                    cancelButtonText: 'Quay lại'
                }).then((result) => {
                    if (result.isConfirmed) {
                        formElement.submit(); // Chỉ submit nếu bấm Đồng ý
                    }
                });
            }
        </script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    </body>
</html>