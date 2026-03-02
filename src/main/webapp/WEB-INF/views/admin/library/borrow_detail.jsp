<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết #${record.id} | LBMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .info-card { border: none; border-radius: 15px; background: white; box-shadow: 0 4px 20px rgba(0,0,0,0.06); height: 100%; }
        .label { font-size: 11px; font-weight: 800; color: #94a3b8; text-transform: uppercase; margin-bottom: 2px; }
        .value { font-weight: 600; color: #1e293b; font-size: 15px; }
        .book-cover { width: 100%; border-radius: 12px; box-shadow: 0 8px 15px rgba(0,0,0,0.1); }
        .action-zone { background: #f8fafc; border: 2px dashed #e2e8f0; border-radius: 12px; padding: 25px; }
    </style>
</head>
<body class="bg-light">
    <jsp:include page="header_lib.jsp" />

    <div class="container py-5">
        <div class="d-flex align-items-center mb-4">
            <a href="${pageContext.request.contextPath}/borrowlibrary" class="btn btn-sm btn-outline-secondary me-3">← Quay lại</a>
            <h2 class="mb-0 fw-bold">Chi tiết phiếu mượn <span class="text-primary">#${record.id}</span></h2>
        </div>

        <div class="row g-4">
            <div class="col-lg-8">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="info-card p-4">
                            <h5 class="fw-bold mb-4 text-primary">👤 Thông tin Độc giả</h5>
                            <div class="mb-3"><div class="label">Họ tên</div><div class="value">${record.user.fullName}</div></div>
                            <div class="mb-3"><div class="label">Email & SĐT</div><div class="value">${record.user.email} <br> ${record.user.phone}</div></div>
                            <div><div class="label">Địa chỉ</div><div class="value text-muted small">${record.user.address}</div></div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="info-card p-4">
                            <h5 class="fw-bold mb-4 text-primary">📚 Thông tin Sách</h5>
                            <div class="d-flex gap-3">
                                <div style="width: 100px;"><img src="${pageContext.request.contextPath}/${record.book.image}" class="book-cover"></div>
                                <div>
                                    <div class="value mb-1">${record.book.title}</div>
                                    <div class="label">ISBN: ${record.book.isbn}</div>
                                    <div class="mt-2">
                                        <div class="label">Mã vạch bản sao</div>
                                        <div class="badge bg-light text-dark border fw-bold">${not empty record.bookCopy.barcode ? record.bookCopy.barcode : 'Chưa gán'}</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-12">
                        <div class="info-card p-4">
                            <h5 class="fw-bold mb-3 text-primary">⏳ Lịch trình</h5>
                            <div class="row g-3 text-center">
                                <div class="col-3 border-end"><div class="label">Ngày mượn</div><div class="value">${record.borrowDate}</div></div>
                                <div class="col-3 border-end"><div class="label">Hạn trả</div><div class="value text-danger">${record.dueDate}</div></div>
                                <div class="col-3 border-end"><div class="label">Ngày trả thực</div><div class="value">${not empty record.returnDate ? record.returnDate : '---'}</div></div>
                                <div class="col-3"><div class="label">Tiền phạt</div><div class="value text-danger fs-5">${record.fineAmount} đ</div></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="col-lg-4">
                <div class="info-card p-4">
                    <h5 class="fw-bold mb-4">⚡ Thao tác xử lý</h5>
                    
                    <c:choose>
                        <c:when test="${record.status == 'REQUESTED'}">
                            <div class="action-zone text-center">
                                <p class="small text-muted mb-3">Quét mã vạch cuốn sách để Duyệt mượn</p>
                                <input type="text" id="bcApprove" class="form-control mb-3 text-center fw-bold" placeholder="Nhập Barcode...">
                                <button onclick="handleApprove()" class="btn btn-success w-100 py-2">Xác nhận cho mượn</button>
                            </div>
                        </c:when>
                        <c:when test="${record.status == 'BORROWED'}">
                            <div class="action-zone text-center" style="background: #fffbeb;">
                                <p class="small text-muted mb-3">Nhận lại sách từ độc giả</p>
                                <input type="text" id="bcReturn" class="form-control mb-3 text-center fw-bold" placeholder="Quét mã trả sách...">
                                <button onclick="handleReturn()" class="btn btn-warning w-100 py-2">Xác nhận đã trả</button>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <div class="text-center py-5">
                                <div class="display-1 mb-2">✅</div>
                                <p class="fw-bold text-muted">Phiếu đã hoàn tất</p>
                            </div>
                        </c:otherwise>
                    </c:choose>

                    <hr class="my-4">
                    <button class="btn btn-outline-dark w-100" onclick="window.print()">🖨️ In phiếu mượn</button>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function handleApprove() {
            const bc = document.getElementById('bcApprove').value;
            if(!bc) return Swal.fire('Lỗi', 'Chưa có mã vạch!', 'error');
            submitPOST('/borrowlibrary/approve', bc);
        }

        function handleReturn() {
            const bc = document.getElementById('bcReturn').value;
            if(!bc) return Swal.fire('Lỗi', 'Chưa có mã vạch!', 'error');
            submitPOST('/borrowlibrary/return', bc);
        }

        function submitPOST(path, bc) {
            const form = document.createElement('form');
            form.method = 'POST';
            form.action = '${pageContext.request.contextPath}' + path;
            form.innerHTML = '<input type="hidden" name="id" value="${record.id}"><input type="hidden" name="barcode" value="'+bc+'">';
            document.body.appendChild(form);
            form.submit();
        }
    </script>
</body>
</html>