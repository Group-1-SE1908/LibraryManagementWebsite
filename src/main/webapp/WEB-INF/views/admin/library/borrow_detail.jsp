<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">

    <head>
        <meta charset="UTF-8">
        <title>Chi tiết #${record.id} | LBMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            .info-card {
                border: none;
                border-radius: 15px;
                background: white;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.06);
                height: 100%;
            }

            .label {
                font-size: 11px;
                font-weight: 800;
                color: #94a3b8;
                text-transform: uppercase;
                margin-bottom: 2px;
            }

            .value {
                font-weight: 600;
                color: #1e293b;
                font-size: 15px;
            }

            .book-cover {
                width: 100%;
                border-radius: 12px;
                box-shadow: 0 8px 15px rgba(0, 0, 0, 0.1);
            }

            .action-zone {
                background: #f8fafc;
                border: 2px dashed #e2e8f0;
                border-radius: 12px;
                padding: 25px;
            }

            /* Tối ưu Timeline cho bố cục 2 cột */
            .timeline-2-col {
                display: flex;
                flex-direction: column;
                gap: 15px;
                position: relative;
                padding-left: 25px;
            }

            .timeline-2-col::before {
                content: "";
                position: absolute;
                left: 7px;
                top: 5px;
                bottom: 5px;
                width: 2px;
                background: #e2e8f0;
            }

            .timeline-step {
                position: relative;
                font-size: 13px;
            }

            .timeline-step::after {
                content: "";
                position: absolute;
                left: -23px;
                top: 4px;
                width: 10px;
                height: 10px;
                border-radius: 50%;
                background: #cbd5e1;
                border: 2px solid white;
            }

            .timeline-step.active::after {
                background: #0b57d0;
                box-shadow: 0 0 0 3px rgba(11, 87, 208, 0.2);
            }

            .timeline-step.completed::after {
                background: #10b981;
            }

            /* Khu vực hành động */
            .action-box {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 20px;
                height: 100%;
                display: flex;
                flex-direction: column;
                justify-content: center;
            }

            .admin-main-content {
                margin-left: 280px;
                min-height: 100vh;
                padding: 24px 32px;
                box-sizing: border-box;
            }

            @media (max-width: 1024px) {
                .admin-main-content {
                    margin-left: 0;
                    padding: 16px;
                }
            }
        </style>
    </head>

    <body class="bg-light">
        <jsp:include page="/WEB-INF/views/admin//library/librarian_sidebar.jsp" />

        <main class="admin-main-content">

            <div class="container py-5">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="d-flex align-items-center">
                        <a href="${pageContext.request.contextPath}/admin/borrowlibrary"
                           class="btn btn-sm btn-outline-secondary me-3">← Quay lại</a>
                        <h2 class="mb-0 fw-bold">Chi tiết phiếu mượn <span class="text-primary">${record.id}</span>
                            <span class="badge rounded-pill ms-2" style="background-color: #6366f1; font-size: 0.5em; vertical-align: middle;">
                                SL: ${record.quantity} cuốn
                            </span>
                        </h2>

                    </div>
                    <span class="status-badge status-${record.status} px-3 py-2 fs-6">${record.status}</span>
                </div>

                <div class="row g-4 mb-4">
                    <div class="col-md-6">
                        <div class="info-card p-4 mb-4 border-start border-4 border-info">
                            <h5 class="fw-bold mb-4 text-dark d-flex align-items-center">
                                <span class="me-2">📍</span> Chi tiết địa chỉ & Bàn giao (${record.borrowMethod})
                            </h5>
                            <div class="row">
                                <div class="col-md-4 border-end">
                                    <div class="mb-3">
                                        <div class="label">Người nhận thực tế</div>
                                        <div class="value text-primary">
                                            ${not empty record.shippingDetails.recipient ? record.shippingDetails.recipient : record.user.fullName}
                                        </div>
                                    </div>
                                    <div class="mb-3">
                                        <div class="label">Số điện thoại nhận hàng</div>
                                        <div class="value">
                                            ${not empty record.shippingDetails.phone ? record.shippingDetails.phone : record.user.phone}
                                        </div>
                                    </div>
                                    <div>
                                        <div class="label">Phương thức nhận</div>
                                        <span class="badge ${record.borrowMethod == 'ONLINE' ? 'bg-primary' : 'bg-secondary'}">
                                            ${record.borrowMethod == 'ONLINE' ? 'Giao hàng tận nơi' : 'Nhận tại thư viện'}
                                        </span>
                                    </div>
                                </div>

                                <div class="col-md-8">
                                    <div class="label">Địa chỉ bàn giao chi tiết</div>
                                    <c:choose>
                                        <c:when test="${record.borrowMethod == 'ONLINE'}">
                                            <div class="row mt-2">
                                                <div class="col-sm-12 mb-2">
                                                    <div class="p-2 bg-light rounded border border-dashed">
                                                        <span class="text-muted small">Địa chỉ đầy đủ:</span><br>
                                                        <strong class="text-dark">${record.shippingDetails.formattedAddress}</strong>
                                                    </div>
                                                </div>
                                                <div class="col-sm-6 mb-2">
                                                    <div class="label" style="font-size: 10px;">Số nhà / Đường</div>
                                                    <div class="value" style="font-size: 13px;">${record.shippingDetails.street}</div>
                                                </div>
                                                <div class="col-sm-6 mb-2">
                                                    <div class="label" style="font-size: 10px;">Phường / Xã</div>
                                                    <div class="value" style="font-size: 13px;">${record.shippingDetails.ward}</div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="label" style="font-size: 10px;">Quận / Huyện</div>
                                                    <div class="value" style="font-size: 13px;">${record.shippingDetails.district}</div>
                                                </div>
                                                <div class="col-sm-6">
                                                    <div class="label" style="font-size: 10px;">Tỉnh / Thành phố</div>
                                                    <div class="value" style="font-size: 13px;">${record.shippingDetails.city}</div>
                                                </div>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="h-100 d-flex align-items-center justify-content-center bg-light rounded border border-dashed p-4">
                                                <div class="text-center">
                                                    <span class="fs-2">🏛️</span>
                                                    <p class="text-muted mb-0 mt-2">Độc giả sẽ đến nhận trực tiếp tại quầy thư viện</p>
                                                </div>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                    <c:if test="${record.borrowMethod == 'ONLINE' && record.status == 'APPROVED'}">
                                        <div class="mt-3 text-end">
                                            <button type="button" class="btn btn-warning fw-bold text-dark" onclick="openGHTKModal('${record.groupCode}')">
                                                🚀 Giao hàng qua GHTK
                                            </button>
                                        </div>
                                    </c:if>

                                    <div class="modal fade" id="ghtkModal" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <div class="modal-header bg-warning text-dark">
                                                    <h5 class="modal-title fw-bold">Xác nhận tạo đơn GHTK</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body">
                                                    <p><strong>Người nhận:</strong> ${record.shippingDetails.recipient} - ${record.shippingDetails.phone}</p>
                                                    <p><strong>Giao tới:</strong> ${record.shippingDetails.formattedAddress}</p>
                                                    <hr>
                                                    <div class="d-flex justify-content-between">
                                                        <span>Trọng lượng dự kiến:</span>
                                                        <strong id="ghtkWeight">Đang tính...</strong>
                                                    </div>
                                                    <div class="d-flex justify-content-between mt-2">
                                                        <span>Phí giao hàng (GHTK):</span>
                                                        <strong id="ghtkFee" class="text-danger">Đang tính phí ship...</strong>
                                                    </div>
                                                </div>
                                                <div class="modal-footer">
                                                    <c:set var="userRolePath" value="${sessionScope.currentUser.role.name == 'ADMIN' ? '/admin' : '/staff'}" />
                                                    <form action="${pageContext.request.contextPath}${userRolePath}/borrowlibrary/ship_confirm" method="POST">
                                                        <input type="hidden" name="groupCode" id="modalGroupCode" value="">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                                                        <button type="submit" class="btn btn-warning fw-bold" id="btnConfirmShip" disabled>Chốt đẩy đơn</button>
                                                    </form>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="info-card p-4">
                            <h5 class="fw-bold mb-4 text-primary d-flex align-items-center">
                                <span class="me-2">📚</span> Thông tin Sách
                            </h5>
                            <div class="d-flex gap-4">
                                <div style="width: 110px; flex-shrink: 0;">
                                    <img src="${pageContext.request.contextPath}/${record.book.image}"
                                         class="book-cover" alt="Book cover">
                                </div>
                                <div class="flex-grow-1">
                                    <div class="value mb-2 fs-5 text-dark">${record.book.title}</div>
                                    <div class="label">Tác giả: <span class="text-dark">${record.book.author}</span>
                                    </div>
                                    <div class="label">ISBN: <span class="text-dark">${record.book.isbn}</span>
                                    </div>

                                    <div class="mt-3 p-2 bg-light rounded border border-dashed">
                                        <div class="d-flex justify-content-between">
                                            <div>
                                                <div class="label">Mã vạch bản sao</div>
                                                <div class="fw-bold text-primary fs-5">${not empty
                                                                                         record.bookCopy.barcode ? record.bookCopy.barcode : 'Đang chờ
                                                                                         gán'}
                                                </div>
                                            </div>
                                            <div class="text-end">
                                                <div class="label">Tồn kho khả dụng</div>
                                                <div
                                                    class="fw-bold ${record.book.quantity > 0 ? 'text-success' : 'text-danger'} fs-5">
                                                    ${record.book.quantity} cuốn
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="info-card p-4 mb-4" style="border-top: 4px solid #0b57d0;">
                    <h5 class="fw-bold mb-4 d-flex align-items-center">
                        <span class="me-2">📊</span> Thống kê hoạt động của độc giả
                    </h5>
                    <div class="row g-2 text-center">
                        <div class="col-md-3 border-end">
                            <div class="label">Sách đang mượn</div>
                            <div class="value fs-4">${stats.currentBorrowed} / 5</div>
                            <small class="text-muted">Giới hạn tối đa 5</small>
                        </div>
                        <div class="col-md-3 border-end">
                            <div class="label">Lượt còn lại</div>
                            <div class="value fs-4 text-success">${remaining}</div>
                            <small class="text-muted">Có thể mượn thêm</small>
                        </div>
                        <div class="col-md-3 border-end">
                            <div class="label">Sách quá hạn?</div>
                            <div class="value fs-4 ${stats.hasOverdue ? 'text-danger' : 'text-success'}">
                                ${stats.hasOverdue ? 'CÓ' : 'Không'}
                            </div>
                            <small class="text-muted">Tình trạng hiện tại</small>
                        </div>
                        <div class="col-md-3">
                            <div class="label">Tiền phạt chưa nộp</div>
                            <div class="value fs-4 text-danger">${stats.unpaidFines} đ</div>
                            <small class="text-muted">Tổng nợ tích lũy</small>
                        </div>
                    </div>
                    <div class="row mt-3 pt-3 border-top g-2 text-center">
                        <div class="col-md-6 border-end">
                            <span class="label">Tổng số sách đã từng mượn:</span>
                            <span class="value ms-2">${stats.totalHistory} cuốn</span>
                        </div>
                        <div class="col-md-6">
                            <span class="label">Tổng số lần quá hạn trong lịch sử:</span>
                            <span class="value ms-2 text-warning">${stats.overdueCount} lần</span>
                        </div>
                    </div>
                </div>
                <div class="info-card p-4 mb-4 border-start border-4 border-warning">
                    <h5 class="fw-bold mb-4 text-dark d-flex align-items-center">
                        <span class="me-2">📍</span> Chi tiết bàn giao sách (${record.borrowMethod})
                    </h5>
                    <div class="row">
                        <div class="col-md-4 mb-3">
                            <div class="label">Người nhận thực tế</div>
                            <div class="value">${not empty record.shippingDetails.recipient ?
                                                 record.shippingDetails.recipient : record.user.fullName}</div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <div class="label">Số điện thoại nhận</div>
                            <div class="value">${not empty record.shippingDetails.phone ?
                                                 record.shippingDetails.phone :
                                                 record.user.phone}</div>
                        </div>
                        <div class="col-md-4 mb-3">
                            <div class="label">Phương thức lấy sách</div>
                            <div class="value"><span class="badge bg-secondary">${record.borrowMethod}</span></div>
                        </div>
                        <div class="col-sm-12">
                            <div class="label">Địa chỉ nhận sách</div>
                            <div class="value text-primary fs-5">
                                <c:choose>
                                    <c:when test="${not empty record.shippingDetails.street}">
                                        ${record.shippingDetails.formattedAddress}
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-muted italic">Nhận trực tiếp tại quầy thư viện</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>


            </div>
        </div>
        <div class="container py-5">
            <div class="info-card p-4">
                <h5 class="fw-bold mb-4 text-dark">⚡ Quản lý Quy trình & Thao tác xử lý</h5>

                <div class="row g-4">
                    <div class="col-md-6 border-end">
                        <p class="label mb-3">Trạng thái hệ thống</p>
                        <div class="timeline-2-col">
                            <div
                                class="timeline-step ${record.status != 'REJECTED' ? 'completed' : ''} ${record.status == 'REQUESTED' ? 'active' : ''}">
                                <div class="fw-bold">1. Tiếp nhận yêu cầu</div>
                                <div class="text-muted small">Độc giả đã gửi yêu cầu mượn ${record.borrowMethod}
                                </div>
                            </div>

                            <div
                                class="timeline-step ${record.status == 'APPROVED' || record.status == 'RECEIVED' || record.status == 'RETURNED' ? 'completed' : ''} ${record.status == 'APPROVED' ? 'active' : ''}">
                                <div class="fw-bold">2. Phê duyệt & Chuẩn bị</div>
                                <div class="text-muted small">Thủ thư kiểm tra và gán mã vạch sách</div>
                            </div>

                            <div
                                class="timeline-step ${record.status == 'RECEIVED' || record.status == 'RETURNED' ? 'completed' : ''} ${record.status == 'RECEIVED' ? 'active' : ''}">
                                <div class="fw-bold">3. Đang mượn</div>
                                <div class="text-muted small">Sách đã được bàn giao cho độc giả</div>
                            </div>

                            <div class="timeline-step ${record.status == 'RETURNED' ? 'completed active' : ''}">
                                <div class="fw-bold">4. Hoàn tất</div>
                                <div class="text-muted small">Giao dịch kết thúc, sách đã về kho</div>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <p class="label mb-3">Hành động cần thực hiện</p>
                        <div class="action-box">
                            <c:choose>
                                <%-- CHỜ DUYỆT --%>
                                <c:when test="${record.status == 'REQUESTED'}">
                                    <div class="text-center">
                                        <p class="small text-muted mb-3">Vui lòng nhập Barcode để duyệt mượn
                                        </p>
                                        <input type="text" id="bcApprove"
                                               class="form-control mb-3 text-center fw-bold"
                                               placeholder="LIB-XXXXXX">
                                        <div class="d-flex gap-2">
                                            <button onclick="handleApprove()"
                                                    class="btn btn-success flex-grow-1">Duyệt mượn</button>
                                            <button onclick="handleReject()"
                                                    class="btn btn-outline-danger">Từ
                                                chối</button>
                                        </div>
                                    </div>
                                </c:when>

                                <%-- ĐÃ DUYỆT --%>
                                <c:when test="${record.status == 'APPROVED'}">
                                    <div class="text-center">
                                        <div class="mb-3">Sách: <span
                                                class="badge bg-info">${record.bookCopy.barcode}</span>
                                        </div>
                                        <button onclick="handleReceive()"
                                                class="btn btn-primary w-100 py-2">Xác nhận độc giả đã lấy
                                            sách</button>
                                        <p class="small text-muted mt-2">Chuyển trạng thái sang RECEIVED
                                        </p>
                                    </div>
                                </c:when>

                                <%-- ĐANG MƯỢN --%>
                                <c:when
                                    test="${record.status == 'RECEIVED' || record.status == 'BORROWED'}">
                                    <div class="text-center">
                                        <p class="small text-muted mb-3">Quét mã để nhận lại sách
                                        </p>
                                        <input type="text" id="bcReturn"
                                               class="form-control mb-3 text-center fw-bold"
                                               placeholder="Quét mã trả sách...">
                                        <button onclick="handleReturn()"
                                                class="btn btn-warning w-100">Xác nhận trả sách</button>
                                    </div>
                                </c:when>

                                <%-- BỊ TỪ CHỐI --%>
                                <c:when test="${record.status == 'REJECTED'}">
                                    <div class="text-center py-3">
                                        <div class="fs-1 mb-2">❌</div>
                                        <h6 class="fw-bold text-danger">Yêu cầu bị từ chối</h6>

                                    </div>
                                </c:when>

                                <%-- HOÀN TẤT --%>
                                <c:otherwise>
                                    <div class="text-center py-3">
                                        <div class="fs-1 mb-2">✅</div>
                                        <h6 class="fw-bold text-success">Giao dịch hoàn tất
                                        </h6>
                                        <p class="small text-muted">Sách đã được trả vào kho
                                        </p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                            function handleApprove() {
                                                const bc = document.getElementById('bcApprove').value;
                                                if (!bc)
                                                    return Swal.fire('Lỗi', 'Chưa có mã vạch!', 'error');
                                                submitPOST('/admin/borrowlibrary/approve', bc);
                                            }

                                            function handleReturn() {
                                                const bc = document.getElementById('bcReturn').value;
                                                if (!bc)
                                                    return Swal.fire('Lỗi', 'Chưa có mã vạch!', 'error');
                                                submitPOST('/admin/borrowlibrary/return', bc);
                                            }

                                            function submitPOST(path, bc) {
                                                const form = document.createElement('form');
                                                form.method = 'POST';
                                                form.action = '${pageContext.request.contextPath}' + path;
                                                form.innerHTML = '<input type="hidden" name="id" value="${record.id}"><input type="hidden" name="barcode" value="' + bc + '">';
                                                document.body.appendChild(form);
                                                form.submit();
                                            }

                                            function quickCopyBarcode(barcode) {
                                                const input = document.getElementById('bcReturn') || document.getElementById('bcApprove');
                                                if (input) {
                                                    input.value = barcode;
                                                    input.focus();
                                                    Swal.fire({
                                                        toast: true, position: 'top-end', icon: 'success',
                                                        title: 'Đã copy mã vạch: ' + barcode, showConfirmButton: false, timer: 1500
                                                    });
                                                }
                                            }

                                            function openGHTKModal(groupCode) {
                                                if (!groupCode) {
                                                    Swal.fire('Lỗi', 'Phiếu mượn chưa có mã nhóm. Không thể gom đơn!', 'error');
                                                    return;
                                                }

                                                // Gắn giá trị groupCode vào form ẩn để lúc submit đẩy lên doPost
                                                document.getElementById('modalGroupCode').value = groupCode;

                                                const modal = new bootstrap.Modal(document.getElementById('ghtkModal'));
                                                modal.show();

                                                // Dùng dấu nháy kép bọc ngoặc EL để không bị lỗi JS
                                                const rolePath = "${sessionScope.currentUser.role.name == 'ADMIN' ? '/admin' : '/staff'}";
                                                const url = '${pageContext.request.contextPath}' + rolePath + '/borrowlibrary/ship_fee?groupCode=' + groupCode;

                                                fetch(url)
                                                        .then(response => response.json())
                                                        .then(data => {
                                                            // data.totalBooks được tính từ Controller
                                                            document.getElementById('ghtkWeight').innerText = data.weight + " gram (" + data.totalBooks + " cuốn)";
                                                            const feeVND = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(data.fee);
                                                            document.getElementById('ghtkFee').innerText = feeVND;

                                                            document.getElementById('btnConfirmShip').disabled = false;
                                                        })
                                                        .catch(error => {
                                                            document.getElementById('ghtkFee').innerText = "Lỗi kết nối API GHTK";
                                                            console.error("GHTK Error: ", error);
                                                        });
                                            }


        </script>
    </main>
</body>

</html>