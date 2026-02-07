<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <title>Quản lý danh mục - LBMS</title>
                <style>
                    body {
                        font-family: Arial, Helvetica, sans-serif;
                        max-width: 1100px;
                        margin: 30px auto;
                        padding: 0 16px;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                        margin-top: 20px;
                    }

                    th,
                    td {
                        border-bottom: 1px solid #eee;
                        padding: 10px;
                        text-align: left;
                        vertical-align: top;
                    }

                    a.btn,
                    button {
                        display: inline-block;
                        padding: 8px 10px;
                        border-radius: 8px;
                        border: 1px solid #ddd;
                        text-decoration: none;
                        color: #111;
                        background: #fff;
                        cursor: pointer;
                    }

                    input[type="text"],
                    textarea {
                        width: 100%;
                        padding: 8px;
                        border: 1px solid #ccc;
                        border-radius: 8px;
                        box-sizing: border-box;
                        font-family: Arial, sans-serif;
                    }

                    .danger {
                        border-color: #ffcccc;
                        color: #b00020;
                    }

                    .ok {
                        border-color: #ccffcc;
                        color: #0b6b0b;
                    }

                    .flash {
                        margin: 10px 0;
                        padding: 10px;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        background: #ffe6e6;
                        border-color: #ffb3b3;
                        color: #cc0000;
                    }

                    .flash.success {
                        background: #e6ffe6;
                        border-color: #b3ffb3;
                        color: #006600;
                    }

                    form {
                        margin: 0;
                        display: inline-block;
                    }

                    .top {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 12px;
                    }

                    .nav-buttons {
                        display: flex;
                        gap: 10px;
                    }

                    .modal {
                        display: none;
                        position: fixed;
                        z-index: 100;
                        left: 0;
                        top: 0;
                        width: 100%;
                        height: 100%;
                        background-color: rgba(0, 0, 0, 0.4);
                    }

                    .modal.show {
                        display: block;
                    }

                    .modal-content {
                        background-color: #f9f9f9;
                        margin: 10% auto;
                        padding: 20px;
                        border: 1px solid #888;
                        border-radius: 8px;
                        width: 400px;
                    }

                    .modal-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 15px;
                    }

                    .modal-header h2 {
                        margin: 0;
                    }

                    .close-modal {
                        background: none;
                        border: none;
                        font-size: 28px;
                        font-weight: bold;
                        cursor: pointer;
                        color: #aaa;
                    }

                    .close-modal:hover {
                        color: #000;
                    }

                    .form-group {
                        margin-bottom: 15px;
                    }

                    .form-group label {
                        display: block;
                        margin-bottom: 5px;
                        font-weight: bold;
                    }

                    .modal-buttons {
                        display: flex;
                        gap: 10px;
                        justify-content: flex-end;
                    }
                </style>
            </head>

            <body>
                <div class="top">
                    <div>
                        <h2>LBMS - Admin: Quản lý danh mục</h2>
                        <div class="nav-buttons">
                            <a class="btn" href="${pageContext.request.contextPath}/admin/users">User</a>
                            <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
                            <a class="btn" href="${pageContext.request.contextPath}/borrow">Mượn/Trả</a>
                        </div>
                    </div>
                    <a class="btn" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
                </div>

                <c:if test="${not empty flash}">
                    <div class="flash <c:if test=" ${flash.contains('thành công')}">success
                </c:if>">${flash}</div>
                </c:if>

                <div>
                    <button class="btn ok" onclick="openCreateModal()">+ Thêm danh mục</button>
                </div>

                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Tên danh mục</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${empty categories}">
                                <tr>
                                    <td colspan="3" style="text-align:center;color:#999;">Chưa có danh mục nào</td>
                                </tr>
                            </c:when>
                            <c:otherwise>
                                <c:forEach items="${categories}" var="cat">
                                    <tr>
                                        <td>${cat.id}</td>
                                        <td><strong>${cat.name}</strong></td>
                                        <td>
                                            <button class="btn edit-btn" data-id="${cat.id}"
                                                data-name="${cat.name}">Sửa</button>
                                            <form method="post"
                                                action="${pageContext.request.contextPath}/admin/categories/delete"
                                                style="display:inline-block;">
                                                <input type="hidden" name="id" value="${cat.id}" />
                                                <button class="btn danger" type="submit"
                                                    onclick="return confirm('Bạn chắc chắn muốn xóa danh mục này?')">Xóa</button>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>

                <!-- Create Modal -->
                <div id="createModal" class="modal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h2>Thêm danh mục mới</h2>
                            <button class="close-modal" onclick="closeCreateModal()">&times;</button>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/categories/create">
                            <div class="form-group">
                                <label for="createName">Tên danh mục:</label>
                                <input type="text" id="createName" name="name" required />
                            </div>
                            <div class="modal-buttons">
                                <button type="button" class="btn" onclick="closeCreateModal()">Hủy</button>
                                <button type="submit" class="btn ok">Lưu</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Edit Modal -->
                <div id="editModal" class="modal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h2>Sửa danh mục</h2>
                            <button class="close-modal" onclick="closeEditModal()">&times;</button>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/categories/update">
                            <input type="hidden" id="editId" name="id" />
                            <div class="form-group">
                                <label for="editName">Tên danh mục:</label>
                                <input type="text" id="editName" name="name" required />
                            </div>
                            <div class="modal-buttons">
                                <button type="button" class="btn" onclick="closeEditModal()">Hủy</button>
                                <button type="submit" class="btn ok">Cập nhật</button>
                            </div>
                        </form>
                    </div>
                </div>

                <script>
                    function openCreateModal() {
                        document.getElementById('createName').value = '';
                        document.getElementById('createModal').classList.add('show');
                    }

                    function closeCreateModal() {
                        document.getElementById('createModal').classList.remove('show');
                    }

                    function openEditModal(id, name) {
                        document.getElementById('editId').value = id;
                        document.getElementById('editName').value = name;
                        document.getElementById('editModal').classList.add('show');
                    }

                    function closeEditModal() {
                        document.getElementById('editModal').classList.remove('show');
                    }

                    document.querySelectorAll('.edit-btn').forEach(function (btn) {
                        btn.addEventListener('click', function () {
                            var id = this.getAttribute('data-id');
                            var name = this.getAttribute('data-name');
                            openEditModal(id, name);
                        });
                    });

                    window.onclick = function (event) {
                        var createModal = document.getElementById('createModal');
                        var editModal = document.getElementById('editModal');
                        if (event.target == createModal) {
                            createModal.classList.remove('show');
                        }
                        if (event.target == editModal) {
                            editModal.classList.remove('show');
                        }
                    }
                </script>
            </body>

            </html>