<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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
        </style>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
              rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    </head>

    <body class="panel-body bg-light">
        <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
        <c:set var="borrowBase"
               value="${not empty staffBorrowBase ? staffBorrowBase : '/staff/borrowlibrary'}" />

        <main class="panel-main">
            <div class="container py-4">

                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="d-flex align-items-center">
                        <a href="${pageContext.request.contextPath}${borrowBase}"
                           class="btn btn-sm btn-outline-secondary me-3">← Quay lại</a>
                        <h2 class="mb-0 fw-bold">Chi tiết phiếu mượn <span
                                class="text-primary">#${record.id}</span>
                            <span class="badge rounded-pill ms-2"
                                  style="background-color: #6366f1; font-size: 0.5em; vertical-align: middle;">
                                SL: ${record.quantity} cuốn
                            </span>
                        </h2>
                    </div>
                    <span class="badge bg-dark px-3 py-2 fs-6">${record.status}</span>
                </div>

                <div class="row g-4 mb-4">

                    <div class="col-md-6">
                        <div class="info-card p-4 border-start border-4 border-info">
                            <h5 class="fw-bold mb-4 text-dark d-flex align-items-center">
                                <span class="me-2">📍</span> Chi tiết bàn giao (${record.borrowMethod})
                            </h5>

                            <div class="row mb-3">
                                <div class="col-6 mb-2">
                                    <div class="label">Người nhận</div>
                                    <div class="value text-primary">${not empty record.shippingDetails.recipient
                                                                      ?
                                                                      record.shippingDetails.recipient : record.user.fullName}</div>
                                </div>
                                <div class="col-6 mb-2">
                                    <div class="label">Số điện thoại</div>
                                    <div class="value">${not empty record.shippingDetails.phone ?
                                                         record.shippingDetails.phone : record.user.phone}</div>
                                </div>
                            </div>

                            <c:choose>
                                <c:when test="${record.borrowMethod == 'ONLINE'}">
                                    <div class="p-3 bg-light rounded border border-dashed">
                                        <div class="mb-2">
                                            <span class="text-muted small">Địa chỉ giao hàng:</span><br>
                                            <strong
                                                class="text-dark">${record.shippingDetails.formattedAddress}</strong>
                                        </div>
                                        <div class="row mt-2">
                                            <div class="col-6 mb-2">
                                                <div class="label" style="font-size: 10px;">Phường/Xã</div>
                                                <div class="value" style="font-size: 13px;">
                                                    ${record.shippingDetails.ward}</div>
                                            </div>
                                            <div class="col-6">
                                                <div class="label" style="font-size: 10px;">Quận/Huyện</div>
                                                <div class="value" style="font-size: 13px;">
                                                    ${record.shippingDetails.district}</div>
                                            </div>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="p-3 bg-light rounded border border-dashed text-center">
                                        <span class="fs-2">🏛️</span>
                                        <p class="text-muted mb-0 mt-2">Nhận sách tại quầy thư viện</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                            <c:choose>
                                <c:when
                                    test="${record.borrowMethod == 'ONLINE' && record.status == 'APPROVED'}">
                                    <div class="mt-4 text-end">
                                        <button type="button"
                                                class="btn btn-warning fw-bold text-dark px-4 py-2"
                                                onclick="openGHTKModal('${record.groupCode}')">
                                            🚀 Giao toàn bộ đơn GHTK
                                        </button>
                                    </div>
                                </c:when>
                                <c:when
                                    test="${record.borrowMethod == 'ONLINE' && (record.status == 'SHIPPING' || not empty shipment)}">
                                    <div class="mt-4 p-3 bg-light border-start border-4 border-success rounded">
                                        <h6 class="fw-bold text-success mb-2">📦 Đã lên đơn Giao Hàng Tiết Kiệm
                                        </h6>
                                        <div style="font-size: 14px;">
                                            <span class="text-muted">Mã vận đơn:</span>
                                            <strong class="text-primary fs-5">${not empty shipment ?
                                                                                shipment.trackingCode : 'Đang đồng bộ...'}</strong><br />
                                            <span class="text-muted">Trạng thái vận chuyển:</span>
                                            <span class="badge bg-info text-dark">${not empty shipment ?
                                                                                    shipment.status : 'Đang giao'}</span>
                                        </div>
                                    </div>
                                </c:when>
                            </c:choose>
                        </div>
                    </div>

                    <div class="col-md-6">
                        <div class="info-card p-4">
                            <h5 class="fw-bold mb-4 text-primary d-flex align-items-center">
                                <span class="me-2">📚</span> Thông tin Sách
                            </h5>
                            <div class="d-flex gap-4">
                                <div style="width: 110px; flex-shrink: 0;">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(record.book.image, 'http')}">
                                            <img src="${record.book.image}" class="book-cover" alt="Cover">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/${record.book.image}"
                                                 class="book-cover" alt="Cover">
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="value mb-2 fs-5 text-dark">${record.book.title}</div>
                                    <div class="label">Tác giả: <span
                                            class="text-dark">${record.book.author}</span>
                                    </div>
                                    <div class="label">ISBN: <span class="text-dark">${record.book.isbn}</span>
                                    </div>

                                    <div class="mt-3 p-3 bg-light rounded border border-dashed">
                                        <div class="d-flex justify-content-between">
                                            <div>
                                                <div class="label">Mã vạch đã gán</div>
                                                <div class="fw-bold text-primary fs-5">
                                                    ${not empty record.bookCopy.barcode ?
                                                      record.bookCopy.barcode :
                                                      'Đang chờ duyệt'}
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
                    <h5 class="fw-bold mb-4 d-flex align-items-center"><span class="me-2">📊</span> Thống kê
                        hoạt
                        động của độc giả</h5>
                    <div class="row g-2 text-center">
                        <div class="col-md-4 border-end">
                            <div class="label">Sách đang mượn</div>
                            <div class="value fs-4">${stats.currentBorrowed} / 5</div>
                        </div>
                        <div class="col-md-4 border-end">
                            <div class="label">Lượt còn lại</div>
                            <div class="value fs-4 text-success">${remaining}</div>
                        </div>
                        <div class="col-md-4">
                            <div class="label">Tiền phạt chưa nộp</div>
                            <div class="value fs-4 text-danger">${stats.unpaidFines} đ</div>
                        </div>
                    </div>
                </div>

                <div class="info-card p-4">
                    <h5 class="fw-bold mb-4 text-dark">⚡ Quy trình & Thao tác</h5>
                    <div class="row g-4">
                        <div class="col-md-6 border-end">
                            <div class="timeline-2-col">
                                <div
                                    class="timeline-step ${record.status != 'REJECTED' ? 'completed' : ''} ${record.status == 'REQUESTED' ? 'active' : ''}">
                                    <div class="fw-bold">1. Tiếp nhận</div>
                                    <div class="text-muted small">Đã nhận yêu cầu mượn</div>
                                </div>
                                <div
                                    class="timeline-step ${record.status == 'APPROVED' || record.status == 'RECEIVED' || record.status == 'RETURNED' || record.status == 'SHIPPING' ? 'completed' : ''} ${record.status == 'APPROVED' ? 'active' : ''}">
                                    <div class="fw-bold">2. Phê duyệt</div>
                                    <div class="text-muted small">Thủ thư gán mã vạch sách</div>
                                </div>
                                <div
                                    class="timeline-step ${record.status == 'RECEIVED' || record.status == 'RETURNED' || record.status == 'SHIPPING' || record.status == 'RETURN_REQUESTED' ? 'completed' : ''} ${record.status == 'RECEIVED' || record.status == 'SHIPPING' ? 'active' : ''}">
                                    <div class="fw-bold">3. Đang mượn / Giao hàng</div>
                                    <div class="text-muted small">Đã bàn giao cho khách hoặc GHTK</div>
                                </div>
                                <div
                                    class="timeline-step ${record.status == 'RETURNED' ? 'completed active' : ''} ${record.status == 'RETURN_REQUESTED' ? 'active' : ''}">
                                    <div class="fw-bold">4. Kiểm tra & Nhập kho</div>
                                    <div class="text-muted small">${record.status == 'RETURN_REQUESTED' ? 'Chờ
                                                                    thủ
                                                                    thư xác nhận gói hàng' : 'Khách đã trả sách'}</div>
                                </div>
                                <div
                                    class="timeline-step ${record.status == 'RETURNED' ? 'completed active' : ''}">
                                    <div class="fw-bold">4. Hoàn tất</div>
                                    <div class="text-muted small">Khách đã trả sách</div>
                                </div>

                            </div>
                        </div>

                        <div class="col-md-6">
                            <div class="action-box">
                                <c:set var="isDetailOnline" value="${fn:toUpperCase(fn:trim(record.borrowMethod)) == 'ONLINE'}" />
                                <c:choose>
                                    <c:when test="${record.status == 'REQUESTED'}">
                                        <div class="text-center">
                                            <p class="small text-muted mb-3">Nhập Barcode để duyệt sách</p>
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

                                    <c:when test="${record.status == 'APPROVED'}">
                                        <div class="text-center">
                                            <div class="mb-3">Mã sách xuất kho: <span
                                                    class="badge bg-info fs-6">${record.bookCopy.barcode}</span>
                                            </div>
                                            <c:choose>
                                                <c:when test="${record.borrowMethod == 'ONLINE'}">
                                                    <div class="alert alert-warning text-dark fw-bold mb-0">👉
                                                        Vui
                                                        lòng nhấn nút "Giao toàn bộ đơn GHTK" ở bảng bên trái để
                                                        gọi
                                                        Shipper!</div>
                                                    </c:when>
                                                    <c:otherwise>
                                                    <button onclick="handleReceive()"
                                                            class="btn btn-primary w-100 py-2">Xác nhận khách đã lấy
                                                        sách</button>
                                                    </c:otherwise>
                                                </c:choose>
                                        </div>
                                    </c:when>

                                    <c:when test="${record.status == 'SHIPPING'}">
                                        <div class="text-center py-3">
                                            <div class="fs-1 mb-2">🚚</div>
                                            <h6 class="fw-bold text-primary">Đơn hàng đang nằm bên GHTK</h6>
                                            <p class="small text-muted mb-0">Chờ độc giả đọc xong và gửi trả
                                                lại.
                                            </p>
                                        </div>
                                    </c:when>

                                    <c:when
                                        test="${(record.status == 'RECEIVED' && !isDetailOnline) || record.status == 'BORROWED'}">
                                        <div class="text-center">
                                            <p class="small text-muted mb-3">Nhập mã vạch để nhận lại sách</p>
                                            
                                            <c:if test="${not empty record.depositAmount && record.depositAmount > 0 && !isDetailOnline}">
                                                <div class="alert alert-info py-2 mb-3">
                                                    <span class="text-dark small">Tiền cọc cần hoàn trả (50%): </span><br/>
                                                    <strong class="text-danger fs-5">
                                                        <fmt:formatNumber value="${record.depositAmount * 0.5}" type="number" pattern="#,##0"/> đ
                                                    </strong>
                                                </div>
                                            </c:if>

                                            <input type="text" id="bcReturn"
                                                   class="form-control mb-3 text-center fw-bold"
                                                   placeholder="LIB-XXXXXX">
                                            <button onclick="handleReturn()"
                                                    class="btn btn-warning w-100 fw-bold">Xác nhận trả sách</button>
                                        </div>
                                    </c:when>

                                    <c:when test="${record.status == 'REJECTED'}">
                                        <div class="text-center py-3">
                                            <div class="fs-1 mb-2">❌</div>
                                            <h6 class="fw-bold text-danger">Đã từ chối</h6>
                                        </div>
                                    </c:when>

                                    <c:when test="${record.status == 'RETURN_REQUESTED'}">
                                        <div class="alert alert-warning">
                                            <h6><i class="fas fa-truck-loading me-2"></i>Chờ nhập kho (Online)</h6>
                                            <p class="small">Vui lòng quét mã vạch trên sách trả để hoàn tất.</p>
                                            <div class="d-flex gap-2">
                                                <input type="text" id="detail-bc" class="form-control" placeholder="Mã vạch...">
                                                <button class="btn btn-success" onclick="processDetailReturn(${record.id})">Xác nhận</button>
                                            </div>
                                        </div>
                                    </c:when>

                                    <c:otherwise>
                                        <div class="text-center py-3">
                                            <div class="fs-1 mb-2">✅</div>
                                            <h6 class="fw-bold text-success">Đã hoàn tất</h6>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>

            </div>

            <div class="modal fade" id="ghtkModal" tabindex="-1">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header bg-warning text-dark">
                            <h5 class="modal-title fw-bold">Xác nhận đơn GHTK</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                        </div>
                        <div class="modal-body">
                            <p><strong>Người nhận:</strong> ${record.shippingDetails.recipient} -
                                ${record.shippingDetails.phone}</p>
                            <p><strong>Giao tới:</strong> ${record.shippingDetails.formattedAddress}</p>
                            <hr>
                            <div class="d-flex justify-content-between mb-2">
                                <span>Tổng trọng lượng:</span>
                                <strong id="ghtkWeight">Đang tải...</strong>
                            </div>
                            <div class="d-flex justify-content-between">
                                <span>Phí giao hàng:</span>
                                <strong id="ghtkFee" class="text-danger fs-5">Đang tính...</strong>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <form action="${pageContext.request.contextPath}${borrowBase}/ship_confirm"
                                  method="POST">
                                <input type="hidden" name="groupCode" id="modalGroupCode" value="">
                                <button type="button" class="btn btn-secondary"
                                        data-bs-dismiss="modal">Hủy</button>
                                <button type="submit" class="btn btn-warning fw-bold" id="btnConfirmShip"
                                        disabled>Xác nhận gọi Shipper</button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <script>
                                                    function handleApprove() {
                                                        const bc = document.getElementById('bcApprove').value;
                                                        if (!bc)
                                                            return Swal.fire('Lỗi', 'Vui lòng nhập mã vạch!', 'error');
                                                        submitPOST('/approve', bc);
                                                    }

                                                    function handleReturn() {
                                                        const bc = document.getElementById('bcReturn').value;
                                                        if (!bc)
                                                            return Swal.fire('Lỗi', 'Vui lòng nhập mã vạch!', 'error');
                                                        submitPOST('/return', bc);
                                                    }

                                                    function handleReject() {
                                                        Swal.fire({
                                                            title: 'Lý do từ chối',
                                                            input: 'text',
                                                            showCancelButton: true,
                                                            confirmButtonText: 'Từ chối',
                                                            cancelButtonText: 'Đóng'
                                                        }).then((result) => {
                                                            if (result.isConfirmed) {
                                                                const form = document.createElement('form');
                                                                form.method = 'POST';
                                                                form.action = '${pageContext.request.contextPath}${borrowBase}/reject';
                                                                form.innerHTML = '<input type="hidden" name="id" value="${record.id}"><input type="hidden" name="reason" value="' + result.value + '">';
                                                                document.body.appendChild(form);
                                                                form.submit();
                                                            }
                                                        });
                                                    }

                                                    function handleReceive() {
                                                        const form = document.createElement('form');
                                                        form.method = 'POST';
                                                        form.action = '${pageContext.request.contextPath}${borrowBase}/receive';
                                                        form.innerHTML = '<input type="hidden" name="id" value="${record.id}">';
                                                        document.body.appendChild(form);
                                                        form.submit();
                                                    }

                                                    function submitPOST(path, bc) {
                                                        const form = document.createElement('form');
                                                        form.method = 'POST';
                                                        form.action = '${pageContext.request.contextPath}${borrowBase}' + path;
                                                        form.innerHTML = '<input type="hidden" name="id" value="${record.id}"><input type="hidden" name="barcode" value="' + bc + '">';
                                                        document.body.appendChild(form);
                                                        form.submit();
                                                    }

                                                    function openGHTKModal(groupCode) {
                                                        if (!groupCode) {
                                                            Swal.fire('Lỗi', 'Phiếu mượn chưa có mã nhóm. Không thể tạo đơn!', 'error');
                                                            return;
                                                        }

                                                        document.getElementById('modalGroupCode').value = groupCode;
                                                        const modal = new bootstrap.Modal(document.getElementById('ghtkModal'));
                                                        modal.show();

                                                        const url = '${pageContext.request.contextPath}${borrowBase}/ship_fee?groupCode=' + groupCode;

                                                        fetch(url)
                                                                .then(response => response.json())
                                                                .then(data => {
                                                                    document.getElementById('ghtkWeight').innerText = data.weight + " gram (" + data.totalBooks + " cuốn)";
                                                                    const feeVND = new Intl.NumberFormat('vi-VN', {style: 'currency', currency: 'VND'}).format(data.fee);
                                                                    document.getElementById('ghtkFee').innerText = feeVND;
                                                                    document.getElementById('btnConfirmShip').disabled = false;
                                                                })
                                                                .catch(error => {
                                                                    document.getElementById('ghtkFee').innerText = "Không lấy được phí (Lỗi kết nối)";
                                                                });
                                                    }
                                                    function handleReturnOnline() {
                                                        const bc = document.getElementById('bcReturnOnline').value;
                                                        if (!bc) {
                                                            return Swal.fire('Thông báo', 'Vui lòng quét hoặc nhập mã vạch sách để xác nhận nhập kho!', 'warning');
                                                        }

                                                        Swal.fire({
                                                            title: 'Xác nhận nhập kho?',
                                                            text: "Bạn chắc chắn đã nhận được sách và mã vạch " + bc + " là chính xác?",
                                                            icon: 'question',
                                                            showCancelButton: true,
                                                            confirmButtonColor: '#3085d6',
                                                            confirmButtonText: 'Đúng, nhận sách',
                                                            cancelButtonText: 'Hủy'
                                                        }).then((result) => {
                                                            if (result.isConfirmed) {
                                                                // Tái sử dụng hàm submitPOST có sẵn ở dòng 147 
                                                                // để gửi yêu cầu về controller xử lý trả sách
                                                                submitPOST('/return', bc);
                                                            }
                                                        });
                                                    }
                                                    // Thay thế hàm processDetailReturn (dòng 1050) trong borrow_detail.jsp
                                                    function processDetailReturn(id) {
                                                        const bc = document.getElementById('detail-bc').value.trim();
                                                        if (!bc) {
                                                            Swal.fire('Lỗi', 'Chưa nhập mã vạch!', 'error');
                                                            return;
                                                        }

                                                        const form = document.createElement('form');
                                                        form.method = 'POST';
                                                        form.action = '${pageContext.request.contextPath}/staff/borrowlibrary/return';

                                                        // SỬA: Dùng nối chuỗi để đảm bảo 'id' và 'barcode' của JS được gửi đi đúng
                                                        form.innerHTML = '<input type="hidden" name="id" value="' + id + '">' +
                                                                '<input type="hidden" name="barcode" value="' + bc + '">' +
                                                                '<input type="hidden" name="action" value="return">';

                                                        document.body.appendChild(form);
                                                        form.submit();
                                                    }
        </script>
    </body>

</html>