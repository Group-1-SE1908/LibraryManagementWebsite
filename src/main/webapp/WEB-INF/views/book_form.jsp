<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>${mode == 'create' ? 'Thêm Sách Mới' : 'Cập Nhật Sách'}</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">

        <div class="container mt-5">
            <div class="row justify-content-center">
                <div class="col-md-8 col-lg-6">
                    <div class="card shadow">
                        <div class="card-header bg-primary text-white">
                            <h4 class="mb-0 text-center">
                                ${mode == 'create' ? 'THÊM SÁCH MỚI' : 'CẬP NHẬT THÔNG TIN SÁCH'}
                            </h4>
                        </div>
                        <div class="card-body p-4">

                            <c:if test="${not empty error}">
                                <div class="alert alert-danger" role="alert">
                                    ${error}
                                </div>
                            </c:if>

                            <form action="${pageContext.request.contextPath}/books/${mode == 'create' ? 'new' : 'edit'}" method="post">

                                <c:if test="${mode == 'edit'}">
                                    <input type="hidden" name="id" value="${book.bookId}">
                                </c:if>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Tên sách <span class="text-danger">*</span></label>
                                    <input type="text" name="title" class="form-control" value="${book.title}" required placeholder="Nhập tên sách...">
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold">Tác giả <span class="text-danger">*</span></label>
                                        <input type="text" name="author" class="form-control" value="${book.author}" required placeholder="Nhập tên tác giả">
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label class="form-label fw-bold">Giá tiền (VNĐ)</label>
                                        <input type="number" name="price" class="form-control" value="${book.price}" min="0" step="1000" placeholder="0">
                                    </div>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Thể loại</label>
                                    <select name="categoryId" class="form-select">
                                        <option value="0">-- Chọn thể loại --</option>
                                        <c:forEach var="c" items="${categories}">
                                            <option value="${c.categoryId}" ${book.categoryId == c.categoryId ? 'selected' : ''}>
                                                ${c.categoryName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>

                                <div class="mb-3">
                                    <label class="form-label fw-bold">Đường dẫn ảnh</label>
                                    <input type="text" name="image" class="form-control" value="${book.image}" 
                                           placeholder="Ví dụ: assets/images/books/ten-file.jpg">
                                    <div class="form-text">Copy ảnh vào thư mục dự án và nhập đường dẫn tương đối.</div>
                                </div>

                                <c:if test="${not empty book.image}">
                                    <div class="mb-3 text-center">
                                        <label>Ảnh hiện tại:</label><br>
                                        <img src="${pageContext.request.contextPath}/${book.image}" 
                                             alt="Preview" class="img-thumbnail shadow-sm" style="max-height: 150px;">
                                    </div>
                                </c:if>

                                <div class="d-grid gap-2 d-md-flex justify-content-md-end mt-4">
                                    <a href="${pageContext.request.contextPath}/books" class="btn btn-secondary me-md-2">Quay lại</a>
                                    <button type="submit" class="btn btn-primary fw-bold">
                                        ${mode == 'create' ? 'Lưu Sách Mới' : 'Cập Nhật'}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </body>
</html>