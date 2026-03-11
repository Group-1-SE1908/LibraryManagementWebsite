<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <title>Danh sách nhập kho | LBMS</title>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
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
                box-shadow: 0 4px 6px rgba(0,0,0,0.1);
            }
            th, td {
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
            }
            .btn-import:hover {
                background: #0842a0;
            }
            .img-preview {
                width: 40px;
                height: 60px;
                object-fit: cover;
                border-radius: 4px;
            }
        </style>
    </head>
    <body>
        <jsp:include page="librarian_sidebar.jsp" />

        <div class="main-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
                <h2>📥 Quản lý nhập kho sách</h2>
                <p>Chọn sách để cập nhật số lượng tồn kho</p>

            </div>
            <div class="search-container" style="margin-bottom: 20px;">
                <form action="${pageContext.request.contextPath}/books" method="get">
                    <input type="hidden" name="action" value="viewImportList">
                    <input type="text" name="searchImport" value="${lastSearch}" placeholder="Tìm tên sách, ISBN..." style="padding: 10px; width: 300px; border-radius: 4px; border: 1px solid #ddd;">
                    <button type="submit" class="btn-import"><i class="fas fa-search"></i> Tìm kiếm</button>
                </form>
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
                    <c:forEach items="${bookList}" var="book">
                        <tr>
                            <td>
                                <img src="${pageContext.request.contextPath}/${book.image}" class="img-preview" onerror="this.src='${pageContext.request.contextPath}/assets/images/books/default.jpg'">
                            </td>
                            <td>${book.isbn}</td>
                            <td><strong>${book.title}</strong><br><small>${book.author}</small></td>
                            <td>
                                <span style="font-weight: bold; color: ${book.quantity < 5 ? '#ef4444' : '#1e293b'}">
                                    ${book.quantity}
                                </span>
                            </td>
                            <td>
                                <a href="${pageContext.request.contextPath}/books/restock?id=${book.id}" class="btn-import">
                                    <i class="fas fa-plus"></i> Nhập thêm
                                </a>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </body>
</html>