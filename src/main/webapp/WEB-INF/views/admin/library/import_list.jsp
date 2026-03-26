<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html>

    <head>
        <title>Quản lý kho sách | LBMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            body {
                font-family: sans-serif;
                display: flex;
                margin: 0;
                background: #f4f7fe;
            }

            .main-content {
                margin-left: 280px;
                padding: 40px;
                width: 100%;
            }

            table {
                width: 100%;
                border-collapse: collapse;
                background: white;
                border-radius: 8px;
                overflow: hidden;
                box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            }

            th,
            td {
                padding: 15px;
                text-align: left;
                border-bottom: 1px solid #eee;
            }

            th {
                background: #1e293b;
                color: white;
            }

            .btn-import {
                background: #0b57d0;
                color: white;
                text-decoration: none;
                padding: 8px 16px;
                border-radius: 4px;
                font-size: 13px;
                display: inline-flex;
                align-items: center;
                gap: 5px;
                border: none;
                cursor: pointer;
            }

            .btn-import:hover {
                opacity: 0.9;
            }

            .img-preview {
                width: 40px;
                height: 60px;
                object-fit: cover;
                border-radius: 4px;
            }
            .btn-action-group {
                display: flex;
                gap: 8px;
                align-items: center;
            }

            .btn-mgmt {
                width: 120px; /* Cố định chiều rộng để 3 nút bằng nhau */
                height: 36px;  /* Cố định chiều cao */
                display: inline-flex;
                align-items: center;
                justify-content: center;
                gap: 6px;
                border-radius: 6px;
                font-size: 13px;
                font-weight: 600;
                text-decoration: none;
                border: none;
                cursor: pointer;
                color: white;
                transition: all 0.2s ease;
                white-space: nowrap;
            }
            .btn-mgmt:hover {
                opacity: 0.9;
                transform: translateY(-1px);
            }

            .btn-restock {
                background: #0b57d0;
            }
            .btn-edit {
                background: #16a34a;
            }
            .btn-delete {
                background: #dc2626;
            }
        </style>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    </head>

    <body class="panel-body">
        <c:set var="booksBasePath" value="${not empty booksBasePath ? booksBasePath : '/books'}" />
        <jsp:include page="librarian_sidebar.jsp" />

        <div class="main-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <h2>📦 Quản lý kho sách tổng hợp</h2>
                <p>Nhập kho, chỉnh sửa hoặc xóa thông tin sách</p>
            </div>

            <div class="search-container" style="margin-bottom: 20px;">
                <form action="${pageContext.request.contextPath}${booksBasePath}" method="get">
                    <input type="hidden" name="action" value="viewImportList">
                    <input type="text" name="searchImport" value="${lastSearch}"
                           placeholder="Tìm tên sách, ISBN..."
                           style="padding: 10px; width: 300px; border-radius: 4px; border: 1px solid #ddd;">
                    <button type="submit" class="btn-import"><i class="fas fa-search"></i> Tìm kiếm</button>
                </form>   
            </div>
                           <div class="d-flex justify-content-end">
                <a href="${pageContext.request.contextPath}${booksBasePath}/new?redirect=importList" 
                   class="btn-import" style="margin-left: 10px;">
                    <i class="fas fa-plus"></i> Thêm sách mới
                </a>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Ảnh</th>
                        <th>ISBN</th>
                        <th>Tên sách</th>
                        <th>Tồn kho</th>
                        <th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty bookList}">
                            <c:forEach items="${bookList}" var="book">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${fn:startsWith(book.image, 'http')}">
                                                <img src="${book.image}" class="img-preview"
                                                     onerror="this.src='${pageContext.request.contextPath}/assets/images/books/default.jpg'">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/${book.image}"
                                                     class="img-preview"
                                                     onerror="this.src='${pageContext.request.contextPath}/assets/images/books/default.jpg'">
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>${book.isbn}</td>
                                    <td><strong>${book.title}</strong><br><small>${book.author}</small></td>
                                    <td>
                                        <span style="font-weight: bold; color: ${book.quantity < 5 ? '#ef4444' : '#1e293b'}">
                                            ${book.quantity}
                                        </span>
                                    </td>
                                    <td style="white-space: nowrap;">
                                        <div class="btn-action-group">
                                            <!-- Nút Nhập thêm -->
                                            <a href="${pageContext.request.contextPath}${booksBasePath}/restock?id=${book.id}"
                                               class="btn-mgmt btn-restock">
                                                <i class="fas fa-plus"></i> Nhập thêm
                                            </a>

                                            <!-- Nút Sửa -->
                                            <a href="${pageContext.request.contextPath}${booksBasePath}/edit?id=${book.id}&redirect=importList"
                                               class="btn-mgmt btn-edit">
                                                <i class="fas fa-edit"></i> Sửa sách
                                            </a>

                                            <!-- Nút Xóa -->
                                            <button type="button" class="btn-mgmt btn-delete" 
                                                    onclick="confirmDeleteBook('${book.id}', '${fn:escapeXml(book.title)}')">
                                                <i class="fas fa-trash"></i> Xóa sách
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5" style="text-align: center; padding: 50px; color: #64748b;">
                                    <div style="font-size: 40px; margin-bottom: 10px;">🔍</div>
                                    <p style="font-size: 16px; margin: 0;">Không tìm thấy sách nào phù hợp với
                                        từ khóa "<strong>${lastSearch}</strong>".</p>
                                    <a href="${pageContext.request.contextPath}${booksBasePath}?action=viewImportList"
                                       style="display: inline-block; margin-top: 15px; color: #0b57d0; text-decoration: none; font-size: 14px;">
                                        <i class="fas fa-sync-alt"></i> Hiển thị tất cả sách
                                    </a>
                                </td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <script>
            function confirmDeleteBook(id, title) {
                Swal.fire({
                    title: 'Xác nhận xóa?',
                    text: "Bạn có chắc chắn muốn xóa cuốn sách '" + title + "'? Hành động này không thể hoàn tác!",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#dc2626',
                    cancelButtonColor: '#64748b',
                    confirmButtonText: 'Đồng ý xóa',
                    cancelButtonText: 'Hủy'
                }).then((result) => {
                    if (result.isConfirmed) {
                        // Redirect tới servlet xóa với tham số redirect để quay lại trang này
                        window.location.href = '${pageContext.request.contextPath}${booksBasePath}/delete?id=' + id + '&redirect=importList';
                    }
                });
            }

            // Hiển thị thông báo nếu có
            <c:if test="${not empty flash}">
            Swal.fire({
                icon: 'success',
                title: 'Thông báo',
                html: '${fn:escapeXml(flash)}',
                timer: 3000,
                showConfirmButton: false
            });
            </c:if>
        </script>
    </body>
</html>