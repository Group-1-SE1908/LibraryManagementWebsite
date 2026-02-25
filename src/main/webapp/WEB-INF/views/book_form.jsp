<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %> <%-- Sửa lại URI JSTL --%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>${mode == 'create' ? 'Thêm Sách Mới' : 'Cập Nhật Sách'} | LBMS Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        :root { --primary-color: #0b57d0; }
        body { background-color: #f8fafc; font-family: 'Segoe UI', sans-serif; }
        .card { border: none; border-radius: 15px; box-shadow: 0 10px 25px rgba(0,0,0,0.05); }
        .card-header { background-color: var(--primary-color) !important; color: white; border-radius: 15px 15px 0 0 !important; padding: 20px; }
        .img-preview-container { margin-top: 15px; text-align: center; background: #f1f5f9; padding: 15px; border-radius: 12px; border: 2px dashed #cbd5e1; }
        #imgPreview { max-height: 300px; border-radius: 8px; display: none; object-fit: contain; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-lg-9">
                <div class="card">
                    <div class="card-header text-center">
                        <h3 class="mb-0">${mode == 'create' ? '✨ THÊM SÁCH MỚI' : '📝 CẬP NHẬT THÔNG TIN SÁCH'}</h3>
                    </div>
                    <div class="card-body p-4 p-md-5">
                        
                        <c:if test="${not empty error}">
                            <div class="alert alert-danger">${error}</div>
                        </c:if>

                        <form action="${pageContext.request.contextPath}/books/${mode == 'create' ? 'new' : 'edit'}" 
                              method="post" enctype="multipart/form-data">
                            
                            <%-- SỬA TẠI ĐÂY: book.bookId -> book.id --%>
                            <c:if test="${mode == 'edit'}">
                                <input type="hidden" name="id" value="${book.id}">
                                <input type="hidden" name="currentImage" value="${book.image}">
                            </c:if>

                            <div class="row g-4">
                                <div class="col-md-6">
                                    <label class="form-label font-weight-bold">Mã ISBN *</label>
                                    <input type="text" name="isbn" class="form-control" value="${book.isbn}" 
                                           ${mode=='edit' ? 'readonly' : ''} required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label font-weight-bold">Tiêu đề sách *</label>
                                    <input type="text" name="title" class="form-control" value="${book.title}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Tác giả *</label>
                                    <input type="text" name="author" class="form-control" value="${book.author}" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Thể loại *</label>
                                    <select name="categoryId" class="form-select" required>
                                        <option value="">-- Chọn thể loại --</option>
                                        <c:forEach var="cat" items="${categories}">
                                            <option value="${cat.id}" ${book.categoryId == cat.id ? 'selected' : ''}>
                                                ${cat.name}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Giá tiền (VND)</label>
                                    <input type="number" name="price" class="form-control" value="${book.price}">
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label">Số lượng *</label>
                                    <input type="number" name="quantity" class="form-control" value="${book.quantity != null ? book.quantity : 0}" required>
                                </div>
                                <div class="col-12">
                                    <label class="form-label">Ảnh bìa</label>
                                    <input type="file" name="imageFile" class="form-control" accept="image/*" onchange="previewImage(this)">
                                    <div class="img-preview-container">
                                        <c:if test="${not empty book.image}">
                                            <img id="currentImg" src="${pageContext.request.contextPath}/${book.image}" style="max-height: 150px; margin-bottom:10px;">
                                            <p class="small text-muted">Ảnh hiện tại</p>
                                        </c:if>
                                        <img id="imgPreview" src="#" alt="Xem trước">
                                    </div>
                                </div>
                            </div>

                            <div class="mt-5 d-flex justify-content-between">
                                <a href="${pageContext.request.contextPath}/books" class="btn btn-outline-secondary">Hủy bỏ</a>
                                <button type="submit" class="btn btn-primary px-5">Lưu thông tin</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function previewImage(input) {
            const preview = document.getElementById('imgPreview');
            const currentImg = document.getElementById('currentImg');
            if (input.files && input.files[0]) {
                const reader = new FileReader();
                reader.onload = e => {
                    preview.src = e.target.result;
                    preview.style.display = 'inline-block';
                    if (currentImg) currentImg.style.opacity = '0.3';
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</body>
</html>