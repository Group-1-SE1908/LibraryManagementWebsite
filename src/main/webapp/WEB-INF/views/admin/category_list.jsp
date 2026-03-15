<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>Category Management - LBMS Admin</title>
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                <style>
                    * {
                        margin: 0;
                        padding: 0;
                        box-sizing: border-box;
                    }

                    body {
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                        background-color: #f5f5f5;
                        color: #333;
                    }

                    .container {
                        display: flex;
                        height: 100vh;
                    }

                    /* Sidebar Styles */
                    .sidebar {
                        width: 280px;
                        background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
                        color: white;
                        padding: 24px 0;
                        position: fixed;
                        height: 100vh;
                        overflow-y: auto;
                        box-shadow: 2px 0 10px rgba(0, 0, 0, 0.1);
                    }

                    .sidebar-header {
                        padding: 0 24px 32px;
                        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        margin-bottom: 24px;
                    }

                    .sidebar-header i {
                        font-size: 28px;
                    }

                    .sidebar-header h2 {
                        font-size: 18px;
                        font-weight: 600;
                    }

                    .sidebar-section {
                        margin-bottom: 8px;
                    }

                    .sidebar-section-title {
                        padding: 12px 24px;
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        color: rgba(255, 255, 255, 0.6);
                        font-weight: 600;
                        margin-top: 16px;
                    }

                    .sidebar-nav {
                        padding: 8px 16px;
                    }

                    .sidebar-nav a {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        padding: 12px 16px;
                        color: rgba(255, 255, 255, 0.85);
                        text-decoration: none;
                        border-radius: 8px;
                        transition: all 0.3s ease;
                        margin-bottom: 4px;
                    }

                    .sidebar-nav a:hover,
                    .sidebar-nav a.active {
                        background-color: rgba(255, 255, 255, 0.15);
                        color: white;
                    }

                    .sidebar-nav a.active {
                        background: rgba(255, 255, 255, 0.25);
                        border-left: 3px solid white;
                    }

                    .sidebar-nav i {
                        width: 20px;
                        text-align: center;
                    }

                    /* Main Content */
                    .main {
                        flex: 1;
                        margin-left: 280px;
                        display: flex;
                        flex-direction: column;
                        height: 100vh;
                    }

                    .header {
                        background: white;
                        padding: 20px 32px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        border-bottom: 1px solid #e5e5e5;
                        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
                    }

                    .header-left {
                        display: flex;
                        align-items: center;
                        gap: 24px;
                        flex: 1;
                    }

                    .search-box {
                        flex: 1;
                        max-width: 400px;
                    }

                    .search-box input {
                        width: 100%;
                        padding: 10px 16px;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                        background-color: #f9f9f9;
                        transition: all 0.3s ease;
                    }

                    .search-box input:focus {
                        outline: none;
                        background-color: white;
                        border-color: #1f3a93;
                        box-shadow: 0 0 0 3px rgba(31, 58, 147, 0.1);
                    }

                    .header-right {
                        display: flex;
                        align-items: center;
                        gap: 20px;
                    }

                    .icon-btn {
                        background: none;
                        border: none;
                        cursor: pointer;
                        font-size: 20px;
                        color: #666;
                        transition: all 0.3s ease;
                        padding: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .icon-btn:hover {
                        color: #1f3a93;
                    }

                    .user-profile {
                        display: flex;
                        align-items: center;
                        gap: 12px;
                        padding: 8px 16px;
                        border-radius: 8px;
                        cursor: pointer;
                        transition: all 0.3s ease;
                    }

                    .user-profile:hover {
                        background-color: #f5f5f5;
                    }

                    .user-avatar {
                        width: 36px;
                        height: 36px;
                        border-radius: 50%;
                        background: linear-gradient(135deg, #1f3a93, #2c5aa0);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        color: white;
                        font-weight: 600;
                        font-size: 14px;
                    }

                    .user-info {
                        display: flex;
                        flex-direction: column;
                        gap: 2px;
                    }

                    .user-name {
                        font-weight: 600;
                        font-size: 14px;
                    }

                    .user-role {
                        font-size: 12px;
                        color: #999;
                    }

                    /* Content Area */
                    .content {
                        flex: 1;
                        overflow-y: auto;
                        padding: 32px;
                    }

                    .content-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 32px;
                    }

                    .content-title {
                        font-size: 28px;
                        font-weight: 600;
                        color: #1f1f1f;
                    }

                    .content-subtitle {
                        font-size: 14px;
                        color: #999;
                        margin-top: 4px;
                    }

                    .action-buttons {
                        display: flex;
                        gap: 12px;
                    }

                    .btn {
                        padding: 10px 20px;
                        border: none;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 500;
                        cursor: pointer;
                        transition: all 0.3s ease;
                        display: inline-flex;
                        align-items: center;
                        gap: 8px;
                        text-decoration: none;
                    }

                    .btn-primary {
                        background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
                        color: white;
                        box-shadow: 0 2px 8px rgba(31, 58, 147, 0.3);
                    }

                    .btn-primary:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(31, 58, 147, 0.4);
                    }

                    /* Section */
                    .section {
                        background: white;
                        border-radius: 12px;
                        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
                        padding: 24px;
                        margin-bottom: 24px;
                    }

                    .section-header {
                        display: flex;
                        justify-content: space-between;
                        align-items: center;
                        margin-bottom: 20px;
                        padding-bottom: 16px;
                        border-bottom: 1px solid #eee;
                    }

                    .section-title {
                        font-size: 18px;
                        font-weight: 600;
                        color: #1f1f1f;
                    }

                    .section-subtitle {
                        font-size: 13px;
                        color: #999;
                        margin-top: 2px;
                    }

                    /* Table */
                    .table-wrapper {
                        overflow-x: auto;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    th {
                        background-color: #f9f9f9;
                        padding: 12px 16px;
                        text-align: left;
                        font-size: 12px;
                        font-weight: 600;
                        color: #666;
                        text-transform: uppercase;
                        letter-spacing: 0.5px;
                        border-bottom: 1px solid #eee;
                    }

                    td {
                        padding: 14px 16px;
                        border-bottom: 1px solid #eee;
                        font-size: 14px;
                        color: #333;
                    }

                    tr:last-child td {
                        border-bottom: none;
                    }

                    tr:hover {
                        background-color: #f9f9f9;
                    }

                    .action-cell {
                        display: flex;
                        gap: 8px;
                    }

                    .action-cell button {
                        padding: 6px 12px;
                        border-radius: 6px;
                        font-size: 12px;
                        font-weight: 500;
                        cursor: pointer;
                        border: 1px solid;
                        transition: all 0.3s ease;
                        background: white;
                    }

                    .action-cell .edit-btn {
                        color: #1f3a93;
                        border-color: #1f3a93;
                    }

                    .action-cell .edit-btn:hover {
                        background: #1f3a93;
                        color: white;
                    }

                    .action-cell .delete-btn {
                        color: #b00020;
                        border-color: #b00020;
                    }

                    .action-cell .delete-btn:hover {
                        background: #b00020;
                        color: white;
                    }

                    .empty-state {
                        text-align: center;
                        padding: 40px;
                        color: #999;
                    }

                    /* Modal Styles */
                    .modal {
                        display: none;
                        position: fixed;
                        z-index: 1000;
                        left: 0;
                        top: 0;
                        width: 100%;
                        height: 100%;
                        background-color: rgba(0, 0, 0, 0.5);
                        animation: fadeIn 0.3s ease;
                    }

                    .modal.show {
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }

                    @keyframes fadeIn {
                        from {
                            opacity: 0;
                        }

                        to {
                            opacity: 1;
                        }
                    }

                    .modal-content {
                        background-color: white;
                        padding: 32px;
                        border-radius: 12px;
                        width: 90%;
                        max-width: 450px;
                        box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
                        animation: slideUp 0.3s ease;
                    }

                    @keyframes slideUp {
                        from {
                            transform: translateY(20px);
                            opacity: 0;
                        }

                        to {
                            transform: translateY(0);
                            opacity: 1;
                        }
                    }

                    .modal-header {
                        margin-bottom: 24px;
                    }

                    .modal-header h2 {
                        font-size: 20px;
                        font-weight: 600;
                        color: #1f1f1f;
                        margin: 0;
                    }

                    .form-group {
                        margin-bottom: 20px;
                    }

                    .form-group label {
                        display: block;
                        margin-bottom: 8px;
                        font-weight: 500;
                        color: #333;
                    }

                    .form-group input {
                        width: 100%;
                        padding: 10px 12px;
                        border: 1px solid #ddd;
                        border-radius: 8px;
                        font-size: 14px;
                        font-family: inherit;
                        transition: all 0.3s ease;
                    }

                    .form-group input:focus {
                        outline: none;
                        border-color: #1f3a93;
                        box-shadow: 0 0 0 3px rgba(31, 58, 147, 0.1);
                    }

                    .modal-buttons {
                        display: flex;
                        gap: 12px;
                        justify-content: flex-end;
                        padding-top: 20px;
                        border-top: 1px solid #eee;
                    }

                    .modal-buttons button {
                        padding: 10px 20px;
                        border: none;
                        border-radius: 8px;
                        font-size: 14px;
                        font-weight: 500;
                        cursor: pointer;
                        transition: all 0.3s ease;
                    }

                    .btn-cancel {
                        background: white;
                        border: 1px solid #ddd;
                        color: #666;
                    }

                    .btn-cancel:hover {
                        background: #f5f5f5;
                    }

                    .btn-submit {
                        background: linear-gradient(135deg, #1f3a93 0%, #2c5aa0 100%);
                        color: white;
                        box-shadow: 0 2px 8px rgba(31, 58, 147, 0.3);
                    }

                    .btn-submit:hover {
                        transform: translateY(-2px);
                        box-shadow: 0 4px 12px rgba(31, 58, 147, 0.4);
                    }

                    ::-webkit-scrollbar {
                        width: 8px;
                        height: 8px;
                    }

                    ::-webkit-scrollbar-track {
                        background: #f1f1f1;
                    }

                    ::-webkit-scrollbar-thumb {
                        background: #888;
                        border-radius: 4px;
                    }

                    ::-webkit-scrollbar-thumb:hover {
                        background: #555;
                    }
                </style>
            </head>

            <body>
                <div class="container">
                    <!-- Sidebar -->
                    <div class="sidebar">
                        <div class="sidebar-header">
                            <i class="fas fa-book"></i>
                            <h2>LBMS Admin</h2>
                        </div>

                        <div class="sidebar-section">
                            <div class="sidebar-section-title">MANAGEMENT</div>
                            <div class="sidebar-nav">
                                <a href="${pageContext.request.contextPath}/admin">
                                    <i class="fas fa-chart-line"></i>
                                    <span>Dashboard</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/users">
                                    <i class="fas fa-users"></i>
                                    <span>User Management</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/books">
                                    <i class="fas fa-book-open"></i>
                                    <span>Book Management</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/admin/categories" class="active">
                                    <i class="fas fa-list"></i>
                                    <span>Categories</span>
                                </a>
                            </div>
                        </div>

                        <div class="sidebar-section">
                            <div class="sidebar-section-title">ANALYSIS</div>
                            <div class="sidebar-nav">
                                <a href="javascript:void(0)">
                                    <i class="fas fa-chart-bar"></i>
                                    <span>Reports</span>
                                </a>
                                <a href="javascript:void(0)">
                                    <i class="fas fa-shipping-fast"></i>
                                    <span>Total Shipments</span>
                                </a>
                            </div>
                        </div>

                        <div class="sidebar-section">
                            <div class="sidebar-section-title">OTHER</div>
                            <div class="sidebar-nav">
                                <a href="javascript:void(0)">
                                    <i class="fas fa-cog"></i>
                                    <span>Settings</span>
                                </a>
                                <a href="${pageContext.request.contextPath}/logout">
                                    <i class="fas fa-sign-out-alt"></i>
                                    <span>Logout</span>
                                </a>
                            </div>
                        </div>
                    </div>

                    <!-- Main Content -->
                    <div class="main">
                        <!-- Header -->
                        <div class="header">
                            <div class="header-left">
                                <div class="search-box">
                                    <input type="text" placeholder="Search for books, members, or ISBN...">
                                </div>
                            </div>
                            <div class="header-right">
                                <button class="icon-btn">
                                    <i class="fas fa-bell"></i>
                                </button>
                                <button class="icon-btn">
                                    <i class="fas fa-moon"></i>
                                </button>
                                <div class="user-profile">
                                    <div class="user-avatar">AD</div>
                                    <div class="user-info">
                                        <div class="user-name">Admin User</div>
                                        <div class="user-role">System Admin</div>
                                    </div>
                                    <i class="fas fa-chevron-down" style="color: #999; font-size: 12px;"></i>
                                </div>
                            </div>
                        </div>

                        <!-- Content -->
                        <div class="content">
                            <div class="content-header">
                                <div>
                                    <h1 class="content-title">Category Management</h1>
                                    <p class="content-subtitle">Manage book categories and organize your library.</p>
                                </div>
                                <div class="action-buttons">
                                    <button class="btn btn-primary" onclick="openCreateModal()">
                                        <i class="fas fa-plus"></i>
                                        Add New Category
                                    </button>
                                </div>
                            </div>

                            <c:if test="${not empty flash}">
                                <div class="section"
                                    style="background: #d4f8d4; border-left: 4px solid #0b6b0b; color: #0b6b0b; margin-bottom: 20px;">
                                    <i class="fas fa-check-circle"></i> ${flash}
                                </div>
                            </c:if>

                            <!-- Categories Section -->
                            <div class="section">
                                <div class="section-header">
                                    <div>
                                        <h2 class="section-title">All Categories</h2>
                                        <p class="section-subtitle">Total: ${categories != null ? categories.size() : 0}
                                            categories</p>
                                    </div>
                                </div>

                                <div class="table-wrapper">
                                    <c:choose>
                                        <c:when test="${empty categories}">
                                            <div class="empty-state">
                                                <i class="fas fa-inbox"
                                                    style="font-size: 48px; color: #ddd; margin-bottom: 16px; display: block;"></i>
                                                <p>No categories found. Create your first category to get started.</p>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <table>
                                                <thead>
                                                    <tr>
                                                        <th>ID</th>
                                                        <th>Category Name</th>
                                                        <th>Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach items="${categories}" var="cat">
                                                        <tr>
                                                            <td>${cat.id}</td>
                                                            <td>
                                                                <strong>${cat.name}</strong>
                                                            </td>
                                                            <td>
                                                                <div class="action-cell">
                                                                    <button class="edit-btn" data-id="${cat.id}"
                                                                        data-name="${cat.name}">
                                                                        Edit
                                                                    </button>
                                                                    <form method="post"
                                                                        action="${pageContext.request.contextPath}/admin/categories/delete"
                                                                        style="display: inline;">
                                                                        <input type="hidden" name="id"
                                                                            value="${cat.id}" />
                                                                        <button type="submit" class="delete-btn"
                                                                            onclick="return confirm('Are you sure you want to delete this category?')">
                                                                            Delete
                                                                        </button>
                                                                    </form>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Create Modal -->
                <div id="createModal" class="modal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h2><i class="fas fa-plus-circle"></i> Add New Category</h2>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/categories/create">
                            <div class="form-group">
                                <label for="createName">Category Name</label>
                                <input type="text" id="createName" name="name" placeholder="Enter category name"
                                    required />
                            </div>
                            <div class="modal-buttons">
                                <button type="button" class="btn-cancel" onclick="closeCreateModal()">Cancel</button>
                                <button type="submit" class="btn-submit">Create Category</button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- Edit Modal -->
                <div id="editModal" class="modal">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h2><i class="fas fa-edit"></i> Edit Category</h2>
                        </div>
                        <form method="post" action="${pageContext.request.contextPath}/admin/categories/update">
                            <input type="hidden" id="editId" name="id" />
                            <div class="form-group">
                                <label for="editName">Category Name</label>
                                <input type="text" id="editName" name="name" placeholder="Enter category name"
                                    required />
                            </div>
                            <div class="modal-buttons">
                                <button type="button" class="btn-cancel" onclick="closeEditModal()">Cancel</button>
                                <button type="submit" class="btn-submit">Update Category</button>
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

                    window.addEventListener('click', function (event) {
                        var createModal = document.getElementById('createModal');
                        var editModal = document.getElementById('editModal');
                        if (event.target == createModal) {
                            createModal.classList.remove('show');
                        }
                        if (event.target == editModal) {
                            editModal.classList.remove('show');
                        }
                    });

                    // Close modals with Escape key
                    document.addEventListener('keydown', function (event) {
                        if (event.key === 'Escape') {
                            closeCreateModal();
                            closeEditModal();
                        }
                    });
                </script>
            </body>

            </html>