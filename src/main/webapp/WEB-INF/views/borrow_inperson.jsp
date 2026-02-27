<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Cho mượn tại quầy | LBMS Staff</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
        <link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/css/select2.min.css" rel="stylesheet" />
    </head>
    <body>
        <jsp:include page="header_lib.jsp" />
        <div class="container py-5" style="max-width: 600px;">
            <div class="card p-4" style="background:white; border-radius:12px; box-shadow: var(--shadow-sm);">
                <h2 class="mb-4">📋 Cho mượn tại quầy</h2>

                <form action="${pageContext.request.contextPath}/borrowlibrary/inperson" method="post">
                    <div class="mb-4">
                        <label class="form-label">1. ID Người mượn</label>
                        <input type="number" name="userId" class="form-control" required placeholder="Nhập mã số độc giả...">
                    </div>

                    <div class="mb-4">
                        <label class="form-label">2. Quét các mã vạch (Barcode)</label>
                        <textarea name="barcodes" class="form-control" rows="5" required 
                                  placeholder="Quét mã vạch vào đây...&#10;LIB-0001&#10;LIB-0002&#10;LIB-0003"></textarea>
                        <small class="text-muted">Dùng súng quét mã vạch quét liên tục, hoặc nhập tay mỗi mã vạch trên 1 dòng.</small>
                    </div>

                    <div style="margin-top: 35px; display: flex; gap: 15px;">
                        <button type="submit" class="btn primary" style="flex: 2; padding: 15px;">Xác nhận mượn tất cả</button>
                        <a href="${pageContext.request.contextPath}/borrowlibrary" class="btn" style="flex: 1; text-align: center; padding: 15px;">Hủy bỏ</a>
                    </div>
                </form>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/select2@4.1.0-rc.0/dist/js/select2.min.js"></script>
        <script>
            $(document).ready(function () {
                // Biến thẻ select thường thành ô tìm kiếm thông minh
                $('#bookSelector').select2({
                    placeholder: "Tìm sách nhanh...",
                    allowClear: true,
                    width: '100%'
                });
            });
        </script>
    </body>
</html>