<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

    <!DOCTYPE html>
    <html lang="vi">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>${mode == 'create' ? 'Thêm Sách Mới' : 'Cập Nhật Sách'} | LBMS Admin</title>
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
      <style>
        :root {
          --primary-color: #0b57d0;
        }

        body {
          background-color: #f8fafc;
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }

        .card {
          border: none;
          border-radius: 15px;
        }

        .card-header {
          background-color: var(--primary-color) !important;
          border-radius: 15px 15px 0 0 !important;
          padding: 20px;
        }

        .form-label {
          font-weight: 600;
          color: #475569;
          margin-bottom: 8px;
        }

        .btn-primary {
          background-color: var(--primary-color);
          border: none;
          padding: 10px 25px;
          border-radius: 8px;
          font-weight: 600;
        }

        .img-preview-container {
          margin-top: 15px;
          text-align: center;
          background: #f1f5f9;
          padding: 15px;
          border-radius: 12px;
          border: 2px dashed #cbd5e1;
        }

        #imgPreview {
          max-height: 250px;
          border-radius: 8px;
          display: none;
        }

        .current-img-label {
          font-size: 0.85rem;
          color: #64748b;
          display: block;
          margin-top: 8px;
        }
      </style>
    </head>

    <body>
      <jsp:include page="header.jsp" />

      <div class="container py-5">
        <div class="row justify-content-center">
          <div class="col-lg-9">
            <div class="card shadow-lg">
              <div class="card-header text-white text-center">
                <h3 class="mb-0">${mode == 'create' ? '✨ THÊM SÁCH MỚI' : '📝 CẬP NHẬT THÔNG TIN SÁCH'}</h3>
              </div>
              <div class="card-body p-4 p-md-5">

                <c:if test="${not empty error}">
                  <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <strong>Lỗi!</strong> ${error}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                  </div>
                </c:if>

                <form action="${pageContext.request.contextPath}/books/${mode == 'create' ? 'new' : 'edit'}"
                  method="post" enctype="multipart/form-data">

                  <c:if test="${mode == 'edit'}">
                    <input type="hidden" name="id" value="${book.bookId}">
                    <input type="hidden" name="currentImage" value="${book.image}">
                  </c:if>

                  <div class="row g-4">
                    <div class="col-md-6">
                      <label class="form-label">Mã ISBN <span class="text-danger">*</span></label>
                      <input type="text" name="isbn" class="form-control form-control-lg" value="${book.isbn}"
                        ${mode=='edit' ? 'readonly' : '' } required placeholder="VD: 978-3-16-148410-0">
                      <c:if test="${mode == 'create'}">
                        <div class="form-text">Mã ISBN phải là duy nhất.</div>
                      </c:if>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label">Tiêu đề sách <span class="text-danger">*</span></label>
                      <input type="text" name="title" class="form-control form-control-lg" value="${book.title}"
                        required>
                    </div>

                    <div class="col-md-6">
                      <label class="form-label">Tác giả <span class="text-danger">*</span></label>
                      <input type="text" name="author" class="form-control" value="${book.author}" required>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label">Thể loại <span class="text-danger">*</span></label>
                      <select name="categoryId" class="form-select" required>
                        <option value="">-- Chọn một thể loại --</option>
                        <c:forEach var="cat" items="${categories}">
                          <option value="${cat.id}" ${book.categoryId==cat.id ? 'selected' : '' }>
                            ${cat.name}
                          </option>
                        </c:forEach>
                      </select>
                    </div>

                    <div class="col-md-6">
                      <label class="form-label">Giá tiền (VND)</label>
                      <div class="input-group">
                        <input type="number" name="price" class="form-control" value="${book.price}" min="0">
                        <span class="input-group-text">₫</span>
                      </div>
                    </div>
                    <div class="col-md-6">
                      <label class="form-label">Số lượng trong kho <span class="text-danger">*</span></label>
                      <input type="number" name="quantity" class="form-control"
                        value="${book.quantity != null ? book.quantity : 0}" min="0" required>
                    </div>

                    <div class="col-12">
                      <label class="form-label">Ảnh bìa sách</label>
                      <input type="file" name="imageFile" id="imageInput" class="form-control" accept="image/*"
                        onchange="previewImage(this)">

                      <div class="img-preview-container">
                        <c:if test="${not empty book.image}">
                          <img id="currentImg" src="${pageContext.request.contextPath}/${book.image}"
                            style="max-height: 150px; border-radius: 8px; margin-bottom: 10px; display: inline-block;">
                          <span class="current-img-label">Ảnh hiện tại trong hệ thống</span>
                          <hr>
                        </c:if>

                        <img id="imgPreview" src="#" alt="Xem trước ảnh mới">
                        <div id="noImageText" style="${not empty book.image ? 'display:none' : ''}">
                          <p class="text-muted mb-0">Chưa chọn ảnh mới từ máy tính</p>
                        </div>
                      </div>
                    </div>
                  </div>

                  <div class="mt-5 d-flex justify-content-between">
                    <a href="${pageContext.request.contextPath}/books" class="btn btn-outline-secondary px-4">
                      <i class="fas fa-arrow-left"></i> Quay lại danh sách
                    </a>
                    <button type="submit" class="btn btn-primary px-5 shadow-sm">
                      ${mode == 'create' ? 'Thêm Sách' : 'Lưu Thay Đổi'}
                    </button>
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
          const noImageText = document.getElementById('noImageText');
          const currentImg = document.getElementById('currentImg');

          if (input.files && input.files[0]) {
            const reader = new FileReader();

            reader.onload = function (e) {
              preview.src = e.target.result;
              preview.style.display = 'inline-block';
              noImageText.style.display = 'none';
              if (currentImg) currentImg.style.opacity = '0.4'; // Làm mờ ảnh cũ để báo hiệu đã chọn ảnh mới
            }

            reader.readAsDataURL(input.files[0]);
          } else {
            preview.style.display = 'none';
            noImageText.style.display = 'block';
            if (currentImg) currentImg.style.opacity = '1';
          }
        }
      </script>

      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>

    </html>