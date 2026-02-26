<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết mượn sách #${record.id}</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="container py-5">
        <a href="${pageContext.request.contextPath}/borrowlibrary" class="btn">← Quay lại</a>
        <div style="display:grid; grid-template-columns: 1fr 1fr; gap:30px; margin-top:20px;">
            <div class="card p-4">
                <h3 style="color:var(--primary-color)">👤 Thông tin Người mượn</h3>
                <p><strong>Họ tên:</strong> ${record.user.fullName}</p>
                <p><strong>Email:</strong> ${record.user.email}</p>
                <p><strong>SĐT:</strong> ${record.user.phone}</p>
                <p><strong>Địa chỉ:</strong> ${record.user.address}</p>
                <p><strong>Vai trò:</strong> ${record.user.role.name}</p>
                <p><strong>Trạng thái:</strong> ${record.user.status}</p>
            </div>
            <div class="card p-4">
                <h3 style="color:var(--primary-color)">📚 Thông tin Phiếu mượn</h3>
                <p><strong>Sách:</strong> ${record.book.title}</p>
                <p><strong>ISBN:</strong> ${record.book.isbn}</p>
                <p><strong>Phương thức:</strong> ${record.borrowMethod}</p>
                <p><strong>Trạng thái phiếu:</strong> <span class="status-badge status-${record.status}">${record.status}</span></p>
                <p><strong>Ngày hẹn trả:</strong> ${record.dueDate}</p>
                <p><strong>Tiền phạt:</strong> ${record.fineAmount} VND</p>
            </div>
        </div>
    </div>
</body>
</html>