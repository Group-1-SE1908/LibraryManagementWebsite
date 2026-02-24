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
            --text-muted: #64748b;
        }

        body { background-color: var(--bg); font-family: 'Inter', system-ui, sans-serif; color: var(--text-main); }
        .dashboard-container { max-width: 1200px; margin: 0 auto; padding: 30px 15px; }

        /* Header & Tabs */
        .page-title { margin-bottom: 25px; }
        .page-title h1 { font-size: 28px; font-weight: 800; margin: 0; }
        
        .nav-tabs { display: flex; gap: 12px; margin-bottom: 25px; border-bottom: 1px solid #e2e8f0; padding-bottom: 15px; }
        .tab-link { padding: 10px 20px; border-radius: 8px; text-decoration: none; color: var(--text-muted); font-weight: 600; transition: 0.2s; background: white; border: 1px solid #e2e8f0; }
        .tab-link.active { background: var(--primary); color: white; border-color: var(--primary); }
        .tab-link-danger { color: var(--danger); border-color: #fecaca; }
        .tab-link-danger.active { background: var(--danger); color: white; }

        /* Table Design */
        .table-card { background: white; border-radius: 16px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); overflow: hidden; }
        table { width: 100%; border-collapse: collapse; }
        th { background: #f8fafc; padding: 18px; text-align: left; font-size: 12px; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; border-bottom: 1px solid #e2e8f0; }
        td { padding: 18px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; }

        /* Badges */
        .badge { padding: 6px 12px; border-radius: 999px; font-size: 11px; font-weight: 700; text-transform: uppercase; display: inline-block; }
        .tag-requested { background: #fff7ed; color: #c2410c; }
        .tag-borrowed { background: #f0fdf4; color: #15803d; }
        .tag-returned { background: #f0f9ff; color: #0369a1; }
        .tag-rejected { background: #fef2f2; color: #b91c1c; }

        /* Action UI */
        .barcode-input { width: 130px; padding: 8px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 13px; margin-right: 5px; }
        .btn-action { padding: 8px 16px; border-radius: 8px; font-size: 13px; font-weight: 600; text-decoration: none; border: none; cursor: pointer; transition: 0.2s; display: inline-block; }
        .btn-approve { background: var(--success); color: white; }
        .btn-return { background: var(--primary); color: white; }
        .btn-reject { color: var(--danger); background: transparent; }

        .fine-amount { color: var(--danger); font-weight: 800; }
        .flash-msg { padding: 15px; background: #dcfce7; color: #166534; border-radius: 10px; margin-bottom: 20px; border: 1px solid #bbf7d0; }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <c:set var="isStaff" value="${sessionScope.currentUser.role.name == 'ADMIN' || sessionScope.currentUser.role.name == 'LIBRARIAN'}" />

    <div class="dashboard-container">
        <div class="page-title">
            <h1>${isStaff ? '🛠️ Quản lý Mượn Trả' : '📖 Sách của tôi'}</h1>
        </div>

        <c:if test="${isStaff}">
            <div class="nav-tabs">
                <a href="${pageContext.request.contextPath}/borrow" class="tab-link ${empty param.filter ? 'active' : ''}">📥 Tất cả yêu cầu (30/35)</a>
                <a href="${pageContext.request.contextPath}/borrow?filter=OVERDUE" class="tab-link tab-link-danger ${param.filter == 'OVERDUE' ? 'active' : ''}">⏰ Quá hạn (33)</a>
            </div>
        </c:if>

        <c:if test="${not empty flash}">
            <div class="flash-msg">${flash}</div>
        </c:if>

        <div class="table-card">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <c:if test="${isStaff}"><th>Người mượn (30)</th></c:if>
                        <th>Thông tin sách</th>
                        <th>Thời hạn</th>
                        <th>Trạng thái</th>
                        <th>Phạt (34)</th>
                        <c:if test="${isStaff}"><th>Thao tác (31/32)</th></c:if>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${records}" var="r">
                        <c:set var="status" value="${fn:toUpperCase(r.status)}" />
                        <tr>
                            <td><strong>#${r.id}</strong></td>
                            
                            <c:if test="${isStaff}">
                                <td>
                                    <div style="font-weight: 600;">${r.user.fullName}</div>
                                    <div style="font-size: 12px; color: var(--text-muted);">${r.user.email}</div>
                                </td>
                            </c:if>

                            <td>
                                <div style="font-weight: 600;">${r.book.title}</div>
                                <div style="font-size: 12px; color: var(--text-muted);">ISBN: ${r.book.isbn}</div>
                            </td>

                            <td>
                                <div style="font-size: 13px;">Mượn: ${r.borrowDate != null ? r.borrowDate : '-'}</div>
                                <div style="font-size: 13px; font-weight: 600; color: ${status == 'BORROWED' ? 'var(--danger)' : 'inherit'}">
                                    Hạn: ${r.dueDate != null ? r.dueDate : '-'}
                                </div>
                            </td>

                            <td>
                                <span class="badge tag-${fn:toLowerCase(status)}">${status}</span>
                            </td>

                            <td>
                                <c:choose>
                                    <c:when test="${r.fineAmount > 0}">
                                        <span class="fine-amount">
                                            <fmt:formatNumber value="${r.fineAmount}" pattern="#,###" /> VND
                                        </span>
                                    </c:when>
                                    <c:otherwise><span style="color: #cbd5e1;">-</span></c:otherwise>
                                </c:choose>
                            </td>

                            <c:if test="${isStaff}">
                                <td>
                                    <c:choose>
                                        <c:when test="${status == 'REQUESTED'}">
                                            <div style="display: flex; align-items: center;">
                                                <input type="text" id="bc_${r.id}" class="barcode-input" placeholder="Nhập Barcode...">
                                                <button onclick="handleApprove(${r.id})" class="btn-action btn-approve">Duyệt</button>
                                                <a href="borrow/reject?id=${r.id}" class="btn-action btn-reject" onclick="return confirm('Từ chối yêu cầu này?')">✖</a>
                                            </div>
                                        </c:when>
                                        <c:when test="${status == 'BORROWED'}">
                                            <a href="borrow/return?id=${r.id}" class="btn-action btn-return" onclick="return confirm('Xác nhận khách đã trả sách?')">Xác nhận trả</a>
                                        </c:when>
                                        <c:otherwise><span style="color: #94a3b8; font-size: 12px;">N/A</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </c:if>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
        
        <c:if test="${empty records}">
            <div style="text-align: center; padding: 40px; color: var(--text-muted);">
                <h3>Hiện tại không có dữ liệu nào.</h3>
            </div>
        </c:if>
    </div>

    <script>
        function handleApprove(id) {
            const barcode = document.getElementById('bc_' + id).value;
            if (!barcode || barcode.trim() === "") {
                alert("Bạn phải nhập Barcode của cuốn sách vật lý để duyệt cho mượn!");
                document.getElementById('bc_' + id).focus();
                return;
            }
            if (confirm('Xác nhận duyệt cho mượn cuốn sách có mã: ' + barcode + '?')) {
                window.location.href = "${pageContext.request.contextPath}/borrow/approve?id=" + id + "&barcode=" + encodeURIComponent(barcode);
            }
        }
    </script>

    <jsp:include page="footer.jsp" />
</body>
</html>