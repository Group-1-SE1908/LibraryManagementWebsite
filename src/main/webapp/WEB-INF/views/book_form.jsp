<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>${mode == 'create' ? 'Thêm Sách' : 'Sửa Sách'}</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    </head>
    <body class="bg-light">
        <div class="container mt-4">
            <div class="card shadow">
                <div class="card-header bg-primary text-white text-center">
                    <h4>${mode == 'create' ? 'THÊM SÁCH MỚI' : 'CẬP NHẬT SÁCH'}</h4>
                </div>
                <div class="card-body">
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger">${error}</div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/books/${mode == 'create' ? 'new' : 'edit'}" 
                          method="post" enctype="multipart/form-data">

                        <c:if test="${mode == 'edit'}">
                            <input type="hidden" name="id" value="${book.bookId}">
                            <input type="hidden" name="currentImage" value="${book.image}">
                        </c:if>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="fw-bold">ISBN (Mã sách) <span class="text-danger">*</span></label>
                                <input type="text" name="isbn" class="form-control" value="${book.isbn}" required 
                                       ${mode == 'edit' ? 'readonly' : ''} placeholder="Nhập mã ISBN duy nhất">
                                <c:if test="${mode == 'create'}"><div class="form-text">Không được trùng với sách đã có.</div></c:if>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label class="fw-bold">Tên sách <span class="text-danger">*</span></label>
                                    <input type="text" name="title" class="form-control" value="${book.title}" required>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="fw-bold">Tác giả</label>
                                <input type="text" name="author" class="form-control" value="${book.author}" required>
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="fw-bold">Thể loại <span class="text-danger">*</span></label>
                                <select name="categoryId" class="form-select" required>
                                    <option value="">-- Chọn thể loại --</option>
                                    <c:forEach var="c" items="${categories}">
                                        <option value="${c.categoryId}" ${book.categoryId == c.categoryId ? 'selected' : ''}>
                                            ${c.categoryName}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="fw-bold">Giá tiền (VNĐ)</label>
                                <input type="number" name="price" class="form-control" value="${book.price}" min="0" step="1000">
                            </div>
                            <div class="col-md-6 mb-3">
                                <label class="fw-bold">Số lượng (Quantity) <span class="text-danger">*</span></label>
                                <input type="number" name="quantity" class="form-control" value="${book.quantity != null ? book.quantity : 0}" min="0">
                                <c:if test="${mode == 'create'}"><div class="form-text">Nhập số lượng sách ban đầu.</div></c:if>
                                <c:if test="${mode == 'edit'}"><div class="form-text text-success">Bạn có thể sửa số lượng tại đây để nhập thêm hàng.</div></c:if>
                                </div>
                            </div>

                            <div class="mb-3">
                                <label class="fw-bold">Ảnh bìa</label>
                                <input type="file" name="imageFile" class="form-control" accept="image/*">

                            <c:if test="${not empty book.image}">
                                <div class="mt-2">
                                    <img src="${pageContext.request.contextPath}/${book.image}" width="100" class="img-thumbnail">
                                    <span class="text-muted">Ảnh hiện tại</span>
                                </div>
                            </c:if>
                        </div>

                        <div class="text-end">
                            <a href="${pageContext.request.contextPath}/books" class="btn btn-secondary">Hủy</a>
                            <button type="submit" class="btn btn-primary fw-bold">Lưu thông tin</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>