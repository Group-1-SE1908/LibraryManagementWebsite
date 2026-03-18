<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>LBMS – Danh mục sách</title>
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                    rel="stylesheet" />
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
            </head>

            <body class="panel-body">

                <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                <main class="panel-main">

                    <%-- Page header --%>
                        <div class="pm-page-header">
                            <div>
                                <h1 class="pm-title"><i class="fas fa-tags"
                                        style="color:var(--panel-accent);margin-right:8px;"></i>Danh mục sách</h1>
                                <p class="pm-subtitle">Quản lý danh mục và tổ chức kho sách thư viện.</p>
                            </div>
                            <button class="pm-btn pm-btn-primary" onclick="openCreateModal()">
                                <i class="fas fa-plus"></i> Thêm danh mục mới
                            </button>
                        </div>

                        <%-- Flash notification --%>
                            <c:if test="${not empty flash}">
                                <div id="flash-msg" class="pm-toast pm-toast-success">
                                    <i class="fas fa-circle-check"></i>
                                    <span>${flash}</span>
                                </div>
                            </c:if>

                            <%-- Table card --%>
                                <div class="pm-card" style="padding:0;overflow:hidden;">
                                    <div
                                        style="display:flex;justify-content:space-between;align-items:center;padding:20px 24px;border-bottom:1px solid var(--panel-border);">
                                        <h3 class="pm-card-title" style="margin:0;">Tất cả danh mục</h3>
                                        <span style="font-size:.8rem;color:var(--panel-text-sub);">
                                            Tổng: <strong>${categories != null ? categories.size() : 0}</strong> danh
                                            mục
                                        </span>
                                    </div>

                                    <c:choose>
                                        <c:when test="${empty categories}">
                                            <div class="pm-empty">
                                                <i class="fas fa-inbox"></i>
                                                <p>Chưa có danh mục nào. Hãy tạo danh mục đầu tiên.</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="pm-table-wrap">
                                                <table class="pm-table">
                                                    <thead>
                                                        <tr>
                                                            <th style="width:80px;">ID</th>
                                                            <th>Tên danh mục</th>
                                                            <th style="text-align:right;width:160px;">Thao tác</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <c:forEach items="${categories}" var="cat">
                                                            <tr>
                                                                <td
                                                                    style="font-weight:600;color:var(--panel-text-sub);">
                                                                    #${cat.id}</td>
                                                                <td>
                                                                    <div
                                                                        style="display:flex;align-items:center;gap:10px;">
                                                                        <div
                                                                            style="width:32px;height:32px;background:#ede9fe;border-radius:8px;display:flex;align-items:center;justify-content:center;color:var(--panel-accent);flex-shrink:0;">
                                                                            <i class="fas fa-tag"
                                                                                style="font-size:.8rem;"></i>
                                                                        </div>
                                                                        <strong>${cat.name}</strong>
                                                                    </div>
                                                                </td>
                                                                <td>
                                                                    <div class="pm-actions"
                                                                        style="justify-content:flex-end;">
                                                                        <button class="pm-action-btn edit pm-edit-btn"
                                                                            data-id="${cat.id}" data-name="${cat.name}">
                                                                            <i class="fas fa-pen"></i> Sửa
                                                                        </button>
                                                                        <form method="post"
                                                                            action="${pageContext.request.contextPath}/admin/categories/delete"
                                                                            style="display:inline;"
                                                                            onsubmit="return confirm('Bạn có chắc muốn xóa danh mục này?')">
                                                                            <input type="hidden" name="id"
                                                                                value="${cat.id}" />
                                                                            <button type="submit"
                                                                                class="pm-action-btn danger">
                                                                                <i class="fas fa-trash"></i> Xóa
                                                                            </button>
                                                                        </form>
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                        </c:forEach>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                </main>

                <%-- Create Modal --%>
                    <div id="createModal" class="pm-modal-overlay">
                        <div class="pm-modal">
                            <div class="pm-modal-header">
                                <h3 class="pm-modal-title"><i class="fas fa-plus-circle"
                                        style="margin-right:6px;color:var(--panel-accent);"></i>Thêm danh mục mới</h3>
                                <button class="pm-modal-close" onclick="closeCreateModal()">&times;</button>
                            </div>
                            <form method="post" action="${pageContext.request.contextPath}/admin/categories/create">
                                <div class="pm-modal-body">
                                    <div class="pm-form-group">
                                        <label class="pm-label">Tên danh mục</label>
                                        <input type="text" id="createName" name="name" class="pm-input"
                                            style="width:100%;" placeholder="Nhập tên danh mục..." required />
                                    </div>
                                </div>
                                <div class="pm-modal-footer">
                                    <button type="button" class="pm-btn pm-btn-outline"
                                        onclick="closeCreateModal()">Hủy</button>
                                    <button type="submit" class="pm-btn pm-btn-primary">Tạo danh mục</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <%-- Edit Modal --%>
                        <div id="editModal" class="pm-modal-overlay">
                            <div class="pm-modal">
                                <div class="pm-modal-header">
                                    <h3 class="pm-modal-title"><i class="fas fa-pen"
                                            style="margin-right:6px;color:var(--panel-warning);"></i>Chỉnh sửa danh mục
                                    </h3>
                                    <button class="pm-modal-close" onclick="closeEditModal()">&times;</button>
                                </div>
                                <form method="post" action="${pageContext.request.contextPath}/admin/categories/update">
                                    <input type="hidden" id="editId" name="id" />
                                    <div class="pm-modal-body">
                                        <div class="pm-form-group">
                                            <label class="pm-label">Tên danh mục</label>
                                            <input type="text" id="editName" name="name" class="pm-input"
                                                style="width:100%;" placeholder="Nhập tên danh mục..." required />
                                        </div>
                                    </div>
                                    <div class="pm-modal-footer">
                                        <button type="button" class="pm-btn pm-btn-outline"
                                            onclick="closeEditModal()">Hủy</button>
                                        <button type="submit" class="pm-btn pm-btn-primary">Cập nhật</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <script>
                            function openCreateModal() {
                                document.getElementById('createName').value = '';
                                document.getElementById('createModal').classList.add('active');
                            }
                            function closeCreateModal() {
                                document.getElementById('createModal').classList.remove('active');
                            }
                            function openEditModal(id, name) {
                                document.getElementById('editId').value = id;
                                document.getElementById('editName').value = name;
                                document.getElementById('editModal').classList.add('active');
                            }
                            function closeEditModal() {
                                document.getElementById('editModal').classList.remove('active');
                            }

                            document.querySelectorAll('.pm-edit-btn').forEach(btn => {
                                btn.addEventListener('click', function () {
                                    openEditModal(this.dataset.id, this.dataset.name);
                                });
                            });

                            window.addEventListener('click', function (e) {
                                if (e.target.id === 'createModal') closeCreateModal();
                                if (e.target.id === 'editModal') closeEditModal();
                            });

                            document.addEventListener('keydown', e => {
                                if (e.key === 'Escape') { closeCreateModal(); closeEditModal(); }
                            });

                            document.addEventListener('DOMContentLoaded', () => {
                                const flash = document.getElementById('flash-msg');
                                if (flash) {
                                    setTimeout(() => {
                                        flash.style.transition = 'opacity .5s';
                                        flash.style.opacity = '0';
                                        setTimeout(() => flash.remove(), 500);
                                    }, 3500);
                                }
                            });
                        </script>
            </body>

            </html>