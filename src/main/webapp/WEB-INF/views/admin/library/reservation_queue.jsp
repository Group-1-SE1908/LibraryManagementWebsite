<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Hàng Chờ Đặt Trước | LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <style>
        /* ================= STANDING TABLE ================= */
        .queue-table-container {
            background: #ffffff;
            border-radius: 10px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
            border: 1px solid #cbd5e1;
            overflow-x: auto;
            margin-bottom: 25px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table thead {
            background: #f8fafc;
            border-bottom: 2px solid #e2e8f0;
        }

        table th {
            padding: 15px 20px;
            text-align: left;
            font-weight: 700;
            font-size: 13px;
            color: #64748b;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        table tbody tr {
            border-bottom: 1px solid #f1f5f9;
            transition: background 0.2s ease;
        }

        table tbody tr:hover {
            background-color: #f8fafc;
        }

        table tbody tr:last-child {
            border-bottom: none;
        }

        table td {
            padding: 15px 20px;
            font-size: 14px;
            color: #334155;
        }

        .position-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #dbeafe;
            color: #1d4ed8;
            font-weight: 700;
            font-size: 14px;
        }

        .position-badge.first {
            background: #fbbf24;
            color: #78350f;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            white-space: nowrap;
        }

        .status-WAITING {
            background: #fef3c7;
            color: #92400e;
        }

        .status-AVAILABLE {
            background: #dbeafe;
            color: #1d4ed8;
        }

        .no-queue {
            text-align: center;
            padding: 60px 20px;
            color: #94a3b8;
        }

        .no-queue-icon {
            font-size: 48px;
            margin-bottom: 15px;
            opacity: 0.6;
        }

        .back-button {
            margin-bottom: 20px;
        }

        .back-button a {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            padding: 10px 16px;
            color: #0ea5e9;
            text-decoration: none;
            font-weight: 600;
            border-radius: 8px;
            transition: all 0.2s;
        }

        .back-button a:hover {
            background: #f0f9ff;
        }
    </style>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
</head>

<body class="panel-body">
    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

    <main class="panel-main">
        <div class="back-button">
            <a href="${pageContext.request.contextPath}/staff/reservation">← Quay lại danh sách đặt trước</a>
        </div>

        <div class="pm-header">
            <h1 class="pm-title">Hàng Chờ Đặt Trước</h1>
            <p class="pm-subtitle">Danh sách những người đang chờ và sẵn sàng nhận sách này</p>
        </div>

        <!-- DANH SÁCH HÀNG CHỜ -->
        <c:choose>
            <c:when test="${empty queue}">
                <div class="queue-table-container">
                    <div class="no-queue">
                        <div class="no-queue-icon">📭</div>
                        <h3>Không có người chờ</h3>
                        <p>Hiện tại không có ai trong hàng chờ cho cuốn sách này</p>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="queue-table-container">
                    <table>
                        <thead>
                            <tr>
                                <th style="width: 8%;">Vị trí</th>
                                <th style="width: 15%;">Trạng thái</th>
                                <th style="width: 20%;">Người dùng</th>
                                <th style="width: 20%;">Email</th>
                                <th style="width: 15%;">Điện thoại</th>
                                <th style="width: 15%;">Ngày đặt</th>
                                <th style="width: 15%;">Hạn nhận</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${queue}" varStatus="status">
                                <tr>
                                    <td>
                                        <span class="position-badge ${item.queuePosition == 1 ? 'first' : ''}">
                                            ${item.queuePosition}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="status-badge status-${item.status}">
                                            ${item.statusLabel}
                                        </span>
                                    </td>
                                    <td>
                                        <strong>${item.userName}</strong>
                                    </td>
                                    <td>
                                        ${item.userEmail}
                                    </td>
                                    <td>
                                        ${item.userPhone}
                                    </td>
                                    <td>
                                        <fmt:formatDate value="${item.createdAt}" pattern="dd/MM/yyyy"/>
                                    </td>
                                    <td>
                                        <c:if test="${item.status == 'AVAILABLE' && not empty item.expiredAt}">
                                            <fmt:formatDate value="${item.expiredAt}" pattern="dd/MM/yyyy"/>
                                        </c:if>
                                        <c:if test="${item.status != 'AVAILABLE' || empty item.expiredAt}">
                                            -
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>

                <!-- THÔNG TIN TÓMLẠI -->
                <div style="background: white; padding: 20px; border-radius: 10px; border: 1px solid #cbd5e1;">
                    <h3 style="margin-top: 0; color: #0f172a;">Thông tin hàng chờ</h3>
                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 15px;">
                        <div>
                            <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 700;">Tổng số đang chờ</span>
                            <p style="margin: 8px 0; font-size: 24px; color: #0f172a; font-weight: 700;">
                                ${fn:length(queue)}
                            </p>
                        </div>
                        <div>
                            <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 700;">Người sắp nhận</span>
                            <p style="margin: 8px 0; font-size: 18px; color: #0f172a; font-weight: 600;">
                                <c:set var="firstAvailable" value="false" />
                                <c:forEach var="item" items="${queue}" varStatus="status">
                                    <c:if test="${item.status == 'AVAILABLE' && !firstAvailable}">
                                        ${item.userName}
                                        <c:set var="firstAvailable" value="true" />
                                    </c:if>
                                </c:forEach>
                                <c:if test="${!firstAvailable}">
                                    Chưa có
                                </c:if>
                            </p>
                        </div>
                        <div>
                            <span style="font-size: 12px; color: #64748b; text-transform: uppercase; font-weight: 700;">Đang chờ sách</span>
                            <p style="margin: 8px 0; font-size: 18px; color: #0f172a; font-weight: 600;">
                                <c:set var="waitingCount" value="0" />
                                <c:forEach var="item" items="${queue}" varStatus="status">
                                    <c:if test="${item.status == 'WAITING'}">
                                        <c:set var="waitingCount" value="${waitingCount + 1}" />
                                    </c:if>
                                </c:forEach>
                                ${waitingCount}
                            </p>
                        </div>
                    </div>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <script>
        // Placeholder cho các hành động tương lai
    </script>
</body>

</html>
