<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Quản lý Sách - LBMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    </head>
    <body class="bg-light">

        <div class="container mt-4">
            <h2 class="text-center mb-4 text-primary fw-bold">QUẢN LÝ THƯ VIỆN SÁCH</h2>

            <div class="card shadow-sm mb-4">
                <div class="card-body">
                    <div class="row g-2 align-items-center">
                        <div class="col-md-8">
                            <form action="books/search" method="get" class="d-flex">
                                <input type="text" name="q" class="form-control me-2" placeholder="Tìm theo tên sách hoặc tác giả..." value="${param.q}">
                                <button type="submit" class="btn btn-primary"><i class="fas fa-search"></i> Tìm</button>
                                <c:if test="${not empty param.q}">
                                    <a href="books" class="btn btn-outline-secondary ms-2">Hủy</a>
                                </c:if>
                            </form>
                        </div>
                        <div class="col-md-4 text-end">
                            <a href="books/new" class="btn btn-success fw-bold">
                                <i class="fas fa-plus"></i> Thêm Sách Mới
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="card shadow-sm">
                <div class="card-body p-0">
                    <table class="table table-hover table-bordered align-middle mb-0">
                        <thead class="table-dark text-center">
                            <tr>
                                <th width="5%">ID</th>
                                <th width="10%">Ảnh</th>
                                <th width="25%">Tên sách</th>
                                <th width="15%">Tác giả</th>
                                <th width="12%">Thể loại</th>
                                <th width="10%">Giá</th>
                                <th width="10%">Trạng thái</th>
                                <th width="13%">Hành động</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="b" items="${books}">
                                <tr>
                                    <td class="text-center fw-bold">${b.bookId}</td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${not empty b.image}">
                                                <img src="${pageContext.request.contextPath}/${b.image}" 
                                                     alt="${b.title}" 
                                                     class="img-thumbnail" 
                                                     style="height: 80px; width: 60px; object-fit: cover;">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://via.placeholder.com/60x80?text=No+Image" class="img-thumbnail">
                                            </c:otherwise>
                                        </c:choose>
                                    </td>

                                    <td>
                                        <span class="fw-semibold">${b.title}</span>
                                    </td>
                                    <td>${b.author}</td>
                                    <td>
                                        <span class="badge bg-info text-dark">${b.categoryName}</span>
                                    </td>
                                    <td class="text-end text-danger fw-bold">
                                        <fmt:formatNumber value="${b.price}" type="currency" currencySymbol="₫" maxFractionDigits="0"/>
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${b.availability}">
                                                <a href="books/availability?id=${b.bookId}&status=true" class="badge bg-success text-decoration-none" title="Nhấn để báo hết hàng">
                                                    Sẵn có
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <a href="books/availability?id=${b.bookId}&status=false" class="badge bg-secondary text-decoration-none" title="Nhấn để báo có hàng">
                                                    Hết hàng
                                                </a>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-center">
                                        <a href="books/edit?id=${b.bookId}" class="btn btn-sm btn-primary" title="Sửa">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <a href="books/delete?id=${b.bookId}" class="btn btn-sm btn-danger" 
                                           onclick="return confirm('Bạn có chắc chắn muốn xóa cuốn sách này không?');" title="Xóa">
                                            <i class="fas fa-trash-alt"></i>
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty books}">
                                <tr>
                                    <td colspan="8" class="text-center py-4 text-muted">
                                        Không tìm thấy cuốn sách nào.
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>