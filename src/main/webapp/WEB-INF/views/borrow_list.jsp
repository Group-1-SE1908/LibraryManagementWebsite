<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý Mượn Trả | LBMS Dashboard</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
        <style>
            :root {
                --primary: #0b57d0;
                --success: #10b981;
                --danger: #ef4444;
                --warning: #f59e0b;
                --bg: #f1f5f9;
                --text-main: #1e293b;
            }

            body {
                background-color: var(--bg);
                font-family: 'Inter', sans-serif;
                color: var(--text-main);
            }
            .dashboard-container {
                max-width: 1240px;
                margin: 0 auto;
                padding: 30px 15px;
            }

            .nav-tabs {
                display: flex;
                gap: 12px;
                margin-bottom: 25px;
                border-bottom: 1px solid #e2e8f0;
                padding-bottom: 15px;
            }
            .tab-link {
                padding: 10px 20px;
                border-radius: 8px;
                text-decoration: none;
                color: #64748b;
                font-weight: 600;
                background: white;
                border: 1px solid #e2e8f0;
            }
            .tab-link.active {
                background: var(--primary);
                color: white;
                border-color: var(--primary);
            }

            .table-card {
                background: white;
                border-radius: 16px;
                box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);
                overflow: hidden;
            }
            table {
                width: 100%;
                border-collapse: collapse;
            }
            th {
                background: #f8fafc;
                padding: 18px;
                text-align: left;
                font-size: 12px;
                color: #64748b;
                text-transform: uppercase;
                border-bottom: 1px solid #e2e8f0;
            }
            td {
                padding: 18px;
                border-bottom: 1px solid #f1f5f9;
                vertical-align: middle;
            }

            .badge {
                padding: 6px 12px;
                border-radius: 999px;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                display: inline-block;
                border: 1px solid transparent;
            }
            .tag-requested {
                background: #fff7ed;
                color: #c2410c;
            }
            .tag-borrowed {
                background: #f0fdf4;
                color: #15803d;
            }

            /* Style cho Borrow Method */
            .method-online {
                background: #e0f2fe;
                color: #0369a1;
                border-color: #bae6fd;
            }
            .method-person {
                background: #f1f5f9;
                color: #475569;
                border-color: #e2e8f0;
            }

            .barcode-input {
                width: 140px;
                padding: 8px;
                border: 1px solid #cbd5e1;
                border-radius: 6px;
                font-size: 13px;
            }
            .btn-action {
                padding: 8px 16px;
                border-radius: 8px;
                font-size: 13px;
                font-weight: 600;
                cursor: pointer;
                border: none;
            }
            .btn-approve {
                background: var(--success);
                color: white;
            }
        </style>
    </head>
    <body>
        <jsp:include page="header.jsp" />

        <c:set var="isStaff" value="${sessionScope.currentUser.role.name == 'ADMIN' || sessionScope.currentUser.role.name == 'LIBRARIAN'}" />

        <div class="dashboard-container">
            <div class="page-title" style="margin-bottom: 20px;">
                <h1>${isStaff ? '🛠️ Quản lý Mượn Trả Toàn Hệ Thống' : '📖 Sách của tôi'}</h1>
            </div>

            <div class="nav-tabs">
                <a href="borrow" 
                   class="tab-link ${empty param.filter ? 'active' : ''}">
                    📥 Tất cả
                </a>

                <a href="borrow?filter=ONLINE" 
                   class="tab-link ${param.filter == 'ONLINE' ? 'active' : ''}">
                    🌐 Yêu cầu Online
                </a>

                <a href="borrow?filter=OVERDUE" 
                   class="tab-link tab-link-danger ${param.filter == 'OVERDUE' ? 'active' : ''}">
                    ⏰ Quá hạn
                </a>
            </div>

            <div class="page-title">
                <h1>${pageTitle}</h1>
            </div>

            <c:if test="${not empty flash}">
                <div style="padding:15px; background:#dcfce7; color:#166534; border-radius:10px; margin-bottom:20px;">${flash}</div>
            </c:if>

            <div class="table-card">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <c:if test="${isStaff}"><th>Người mượn</th></c:if>
                                <th>Thông tin sách</th>
                                <th>Hình thức</th>
                                <th>Thời hạn</th>
                                <th>Trạng thái</th>
                            <c:if test="${isStaff}"><th>Thao tác</th></c:if>
                            </tr>
                        </thead>
                        <tbody>
                        <c:forEach items="${records}" var="r">
                            <tr>
                                <td><strong>#${r.id}</strong></td>
                                <c:if test="${isStaff}">
                                    <td>
                                        <div style="font-weight:600">${r.user.fullName}</div>
                                        <div style="font-size:11px; color:#64748b">${r.user.email}</div>
                                    </td>
                                </c:if>
                                <td>
                                    <div style="font-weight:600">${r.book.title}</div>
                                    <div style="font-size:11px; color:#64748b">ISBN: ${r.book.isbn}</div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.borrowMethod == 'ONLINE'}">
                                            <span class="badge method-online">🌐 Online</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge method-person">📍 Tại quầy</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div style="font-size:12px">Hạn: ${not empty r.dueDate ? r.dueDate : '-'}</div>
                                </td>
                                <td>
                                    <span class="badge tag-${fn:toLowerCase(r.status)}">${r.status}</span>
                                </td>
                                <c:if test="${isStaff}">
                                    <td>
                                        <c:if test="${r.status == 'REQUESTED'}">
                                            <div style="display:flex; gap:5px;">
                                                <input type="text" id="bc_${r.id}" class="barcode-input" placeholder="Quét mã vạch...">
                                                <button onclick="handleApprove(${r.id})" class="btn-action btn-approve">Duyệt</button>
                                            </div>
                                        </c:if>
                                    </td>
                                </c:if>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>

        <script>
            function handleApprove(id) {
                const barcode = document.getElementById('bc_' + id).value;
                if (!barcode || barcode.trim() === "") {
                    alert("Bạn phải nhập Barcode của cuốn sách vật lý để duyệt!");
                    return;
                }
                window.location.href = "${pageContext.request.contextPath}/borrow/approve?id=" + id + "&barcode=" + encodeURIComponent(barcode);
            }
        </script>
    </body>
</html>