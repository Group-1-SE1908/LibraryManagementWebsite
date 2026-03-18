<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Mượn sách tại quầy | LBMS</title>

            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
            <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css" rel="stylesheet">

            <style>
                body {
                    background-color: #f4f7f6;
                }

                .main-content {
                    padding: 20px;
                }

                .card {
                    border: none;
                    border-radius: 10px;
                    box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
                }

                .preview-card {
                    border-left: 5px solid #0d6efd;
                    background: #fff;
                }

                .preview-card.error {
                    border-left-color: #dc3545;
                }

                .badge-status {
                    font-size: 0.85rem;
                    padding: 5px 10px;
                }

                #barcodes {
                    font-family: 'Courier New', Courier, monospace;
                    font-size: 14px;
                }

                .table-preview th {
                    background-color: #f8f9fa;
                }
            </style>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                rel="stylesheet">
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
        </head>

        <body class="panel-body">
            <jsp:include page="librarian_sidebar.jsp" />

            <main class="panel-main">
                <div
                    class="d-flex justify-content-between flex-wrap flex-md-nowrap align-items-center pb-2 mb-4 border-bottom">
                    <h2 class="h3"><i class="fas fa-cash-register me-2"></i> Nghiệp vụ mượn sách tại quầy</h2>
                </div>

                <c:if test="${not empty flash}">
                    <div class="alert alert-warning alert-dismissible fade show border-0 shadow-sm" role="alert">
                        <i class="fas fa-exclamation-circle me-2"></i> ${flash}
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                </c:if>

                <div class="row g-4">
                    <div class="col-lg-5">
                        <div class="card p-4">
                            <form action="${pageContext.request.contextPath}${staffBorrowBase}/inperson" method="post"
                                id="mainBorrowForm">

                                <div class="mb-3">
                                    <label for="email" class="form-label fw-bold">Email Độc giả</label>
                                    <div class="input-group">
                                        <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                                        <input type="email" name="email" id="email" class="form-control"
                                            placeholder="Nhập địa chỉ email của độc giả..." required>
                                    </div>
                                    <div id="userPreview" class="mt-2" style="display:none;">
                                        <div class="alert alert-info py-1 small">
                                            <i class="fas fa-check-circle text-success"></i>
                                            Đang chọn: <strong id="previewName"></strong>
                                        </div>
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label for="barcodes" class="form-label fw-bold">Danh sách Mã vạch</label>
                                    <textarea name="barcodes" id="barcodes" class="form-control" rows="5"
                                        placeholder="Quét mã vạch tại đây..." required></textarea>
                                </div>

                                <div class="d-grid">
                                    <button type="submit" class="btn btn-success btn-lg">
                                        <i class="fas fa-save"></i> Hoàn tất cho mượn
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div class="col-lg-7">
                        <div class="card p-4" id="previewArea">
                            <h5 class="card-title border-bottom pb-2 mb-3 text-secondary">
                                <i class="fas fa-search me-2"></i> Kiểm tra thông tin nhanh
                            </h5>

                            <div id="emptyState" class="text-center py-5 opacity-50">
                                <i class="fas fa-id-card-alt fa-4x mb-3"></i>
                                <p>Thông tin độc giả và sách sẽ hiển thị tại đây khi bạn nhập mã</p>
                            </div>

                            <div id="userResult" class="preview-card p-3 mb-4 shadow-sm" style="display:none;">
                                <div class="d-flex align-items-center">
                                    <div class="avatar-circle bg-light p-3 rounded-circle me-3">
                                        <i class="fas fa-user fa-2x text-primary"></i>
                                    </div>
                                    <div>
                                        <h4 class="mb-0" id="res-userName">...</h4>
                                        <p class="text-muted mb-0">ID: <span id="res-userId" class="fw-bold"></span></p>
                                        <span id="res-userStatus" class="badge rounded-pill mt-1">...</span>
                                    </div>
                                </div>
                            </div>

                            <div id="bookResult" style="display:none;">
                                <table class="table table-preview table-hover border">
                                    <thead>
                                        <tr>
                                            <th>Mã vạch</th>
                                            <th>Tên sách</th>
                                            <th class="text-center">Trạng thái</th>
                                        </tr>
                                    </thead>
                                    <tbody id="res-bookTable"></tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </main>

            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

            <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
            <script>
                $(document).ready(function () {
                    /**
                     * Hàm gọi AJAX để kiểm tra thông tin Email và Sách
                     */
                    function verifyBorrowData() {
                        const emailInput = $('#email').val(); // Lấy giá trị từ ô Email
                        const barcodesInput = $('#barcodes').val(); // Lấy danh sách mã vạch

                        // Chỉ gọi AJAX nếu có ít nhất một thông tin được nhập
                        if (!emailInput && !barcodesInput) {
                            $('#emptyState').show();
                            $('#userResult, #bookResult').hide();
                            return;
                        }

                        $.ajax({
                            // Sửa lỗi 404 bằng cách gộp contextPath và staffBorrowBase
                            url: '${pageContext.request.contextPath}${staffBorrowBase}/verifyData',
                            method: 'GET',
                            data: {
                                email: emailInput,
                                barcodes: barcodesInput
                            },
                            success: function (data) {
                                $('#emptyState').hide();

                                // 1. Cập nhật giao diện Độc giả
                                if (data.user) {
                                    $('#userResult').fadeIn();
                                    $('#res-userName').text(data.user.fullName);
                                    $('#res-userIdDisplay').text(data.user.id); // Vẫn hiện ID để thủ thư biết

                                    const statusTag = $('#res-userStatus');
                                    statusTag.text(data.user.status);
                                    if (data.user.status === 'ACTIVE') {
                                        statusTag.attr('class', 'badge bg-success rounded-pill');
                                        $('#userResult').removeClass('error-border');
                                    } else {
                                        statusTag.attr('class', 'badge bg-danger rounded-pill');
                                        $('#userResult').addClass('error-border');
                                    }
                                } else {
                                    $('#userResult').hide();
                                }

                                // 2. Cập nhật danh sách Sách xem trước
                                if (data.copies && data.copies.length > 0) {
                                    $('#bookResult').fadeIn();
                                    let rows = '';
                                    data.copies.forEach(function (item) {
                                        const isAvailable = (item.status === 'AVAILABLE');
                                        const colorClass = isAvailable ? 'text-success' : 'text-danger fw-bold';

                                        rows += `<tr>
                                        <td><span class="badge bg-light text-dark border">${item.barcode}</span></td>
                                        <td>${item.bookTitle || 'N/A'}</td>
                                        <td class="text-center ${colorClass}">${item.status}</td>
                                    </tr>`;
                                    });
                                    $('#res-bookTable').html(rows);
                                } else {
                                    $('#bookResult').hide();
                                }
                            },
                            error: function (xhr) {
                                console.error("Lỗi xác thực dữ liệu: ", xhr.responseText);
                            }
                        });
                    }

                    // Lắng nghe sự kiện khi rời khỏi ô nhập Email hoặc Barcodes
                    $('#email, #barcodes').on('blur', function () {
                        verifyBorrowData();
                    });

                    // Hỗ trợ máy quét mã vạch (thường gửi phím Enter sau khi quét)
                    $('#barcodes').on('keyup', function (e) {
                        if (e.key === "Enter") {
                            verifyBorrowData();
                        }
                    });

                    // Kiểm tra lần cuối trước khi Submit form
                    $('#borrowForm').on('submit', function (e) {
                        const status = $('#res-userStatus').text();
                        if (status && status !== 'ACTIVE') {
                            if (!confirm('Tài khoản độc giả này đang bị khóa. Bạn có chắc chắn muốn tiếp tục cho mượn?')) {
                                e.preventDefault();
                            }
                        }
                    });
                });
            </script>
        </body>

        </html>