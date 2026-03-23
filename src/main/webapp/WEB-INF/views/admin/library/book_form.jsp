<%-- --%>
    <%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>${mode == 'create' ? 'Thêm Sách Mới' : 'Cập Nhật Sách'} | LBMS Admin</title>
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <%-- --%>
                        <style>
                            :root {
                                --primary-color: #0b57d0;
                                --bg-soft: #f8fafc;
                            }

                            body {
                                background-color: var(--bg-soft);
                                font-family: 'Inter', sans-serif;
                            }

                            .admin-main-content {
                                margin-left: 280px;
                                padding: 40px;
                                min-height: 100vh;
                            }

                            .form-card {
                                border: none;
                                border-radius: 16px;
                                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.05);
                                background: white;
                            }

                            .form-header {
                                background: #1e293b;
                                color: white;
                                padding: 25px;
                                border-radius: 16px 16px 0 0;
                            }

                            .form-label {
                                font-weight: 600;
                                color: #475569;
                                font-size: 0.9rem;
                                margin-bottom: 8px;
                            }

                            .form-control,
                            .form-select {
                                padding: 12px;
                                border-radius: 10px;
                                border: 1px solid #e2e8f0;
                            }

                            .form-control:focus {
                                border-color: var(--primary-color);
                                box-shadow: 0 0 0 3px rgba(11, 87, 208, 0.1);
                            }

                            .img-preview-box {
                                border: 2px dashed #e2e8f0;
                                border-radius: 12px;
                                padding: 20px;
                                text-align: center;
                                background: #f8fafc;
                                margin-top: 10px;
                            }

                            #imgPreview {
                                max-height: 250px;
                                border-radius: 8px;
                                margin-top: 10px;
                                display: none;
                            }

                            .btn-save {
                                background: var(--primary-color);
                                border: none;
                                padding: 12px 40px;
                                border-radius: 10px;
                                font-weight: 600;
                            }

                            @media (max-width: 1024px) {
                                .admin-main-content {
                                    margin-left: 0;
                                    padding: 20px;
                                }
                            }
                        </style>
                        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                            rel="stylesheet">
                        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                </head>

                <body class="panel-body">
                    <%-- --%>
                        <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

                        <main class="admin-main-content">
                            <div class="container-fluid">
                                <div class="row justify-content-center">
                                    <div class="col-xl-10">
                                        <div class="form-card">
                                            <div class="form-header">
                                                <h4 class="mb-0 text-center">${mode == 'create' ? '✨ THÊM SÁCH VÀO HỆ
                                                    THỐNG' : '📝 CẬP NHẬT THÔNG TIN SÁCH'}</h4>
                                            </div>

                                            <div class="card-body p-5">
                                                <c:if test="${not empty error}">
                                                    <div class="alert alert-danger border-0 shadow-sm mb-4">${error}
                                                    </div>
                                                </c:if>

                                                <form
                                                    action="${pageContext.request.contextPath}${booksBasePath}/${mode == 'create' ? 'new' : 'edit'}"
                                                    method="post" enctype="multipart/form-data">

                                                    <%-- --%>
                                                        <c:if test="${mode == 'edit'}">
                                                            <input type="hidden" name="id" value="${book.id}">
                                                            <input type="hidden" name="currentImage"
                                                                value="${book.image}">
                                                        </c:if>

                                                        <div class="row g-4">
                                                            <div class="col-md-6">
                                                                <label class="form-label">Mã ISBN *</label>
                                                                <input type="text" name="isbn" class="form-control"
                                                                    value="${book.isbn}" ${mode=='edit' ? 'readonly'
                                                                    : '' } required placeholder="Ví dụ: 978-604-...">
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label">Tiêu đề sách *</label>
                                                                <input type="text" name="title" class="form-control"
                                                                    value="${book.title}" required>
                                                            </div>

                                                            <div class="col-md-6">
                                                                <label class="form-label">Tác giả *</label>
                                                                <input type="text" name="author" class="form-control"
                                                                    value="${book.author}" required>
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label">Thể loại *</label>
                                                                <select name="categoryId" class="form-select" required>
                                                                    <option value="">-- Chọn thể loại --</option>
                                                                    <c:forEach var="cat" items="${categories}">
                                                                        <option value="${cat.id}"
                                                                            ${book.categoryId==cat.id ? 'selected' : ''
                                                                            }>${cat.name}</option>
                                                                    </c:forEach>
                                                                </select>
                                                            </div>

                                                            <div class="col-md-6">
                                                                <label class="form-label">Giá tiền (VND)</label>
                                                                <input type="number" name="price" class="form-control"
                                                                    value="${book.price}" placeholder="0">
                                                            </div>
                                                            <div class="col-md-6">
                                                                <label class="form-label">Mô tả sách</label>
                                                                <textarea name="description" class="form-control"
                                                                    rows="2"
                                                                    placeholder="Nhập giới thiệu ngắn về nội dung sách...">${book.description}</textarea>
                                                            </div>

                                                            <div class="col-12">
                                                                <label class="form-label">Ảnh bìa sách</label>
                                                                <input type="file" name="imageFile" class="form-control"
                                                                    accept="image/*" onchange="previewImage(this)">
                                                                <div class="img-preview-box">
                                                                    <c:if test="${not empty book.image}">
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${fn:startsWith(book.image, 'http')}">
                                                                                <img id="currentImg" src="${book.image}"
                                                                                    style="max-height: 120px;">
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <img id="currentImg"
                                                                                    src="${pageContext.request.contextPath}/${book.image}"
                                                                                    style="max-height: 120px;">
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                        <p class="small text-muted mt-2">Ảnh hiện tại
                                                                        </p>
                                                                    </c:if>
                                                                    <img id="imgPreview" src="#"
                                                                        alt="Xem trước ảnh mới">
                                                                    <p id="previewText" class="small text-muted d-none">
                                                                        Xem trước ảnh mới</p>
                                                                </div>
                                                            </div>
                                                        </div>

                                                        <div
                                                            class="mt-5 d-flex justify-content-between align-items-center">
                                                            <a href="${pageContext.request.contextPath}${booksBasePath}"
                                                                class="text-decoration-none text-muted">
                                                                <i class="fas fa-arrow-left me-1"></i> Quay lại danh
                                                                sách
                                                            </a>
                                                            <button type="submit" class="btn btn-primary btn-save">Lưu
                                                                thông tin</button>
                                                        </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </main>

                        <script>
                            function previewImage(input) {
                                const preview = document.getElementById('imgPreview');
                                const previewText = document.getElementById('previewText');
                                const currentImg = document.getElementById('currentImg');
                                if (input.files && input.files[0]) {
                                    const reader = new FileReader();
                                    reader.onload = e => {
                                        preview.src = e.target.result;
                                        preview.style.display = 'inline-block';
                                        previewText.classList.remove('d-none');
                                        if (currentImg)
                                            currentImg.style.opacity = '0.3';
                                    }
                                    reader.readAsDataURL(input.files[0]);
                                }
                            }
                        </script>
                </body>

                </html>