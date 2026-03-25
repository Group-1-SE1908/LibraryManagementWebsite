<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý liên hệ - LBMS</title>
    <!-- Use the same styling as the sidebar -->
    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
    <style>
        .page-content {
            padding: 24px;
        }

        .header-title {
            font-size: 24px;
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 24px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .header-title i {
            color: #6366f1;
        }

        .contact-table-wrapper {
            background: #fff;
            border-radius: 12px;
            box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            border: 1px solid #e2e8f0;
        }

        .contact-table {
            width: 100%;
            border-collapse: collapse;
            text-align: left;
        }

        .contact-table th, .contact-table td {
            padding: 16px 20px;
            border-bottom: 1px solid #e2e8f0;
            font-size: 14px;
            color: #334155;
        }

        .contact-table th {
            background-color: #f8fafc;
            font-weight: 600;
            color: #64748b;
            text-transform: uppercase;
            font-size: 12px;
            letter-spacing: 0.5px;
        }

        .contact-table tbody tr:hover {
            background-color: #f1f5f9;
        }

        .status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
            display: inline-block;
        }
        .status-PENDING { background-color: #fef9c3; color: #ca8a04; }
        .status-RESOLVED { background-color: #dcfce7; color: #16a34a; }
        .status-IGNORED { background-color: #f1f5f9; color: #64748b; }
        .status-CLOSED { background-color: #fee2e2; color: #dc2626; }

        .btn-action {
            padding: 6px 12px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            background: #eff6ff;
            color: #2563eb;
            transition: 0.2s;
        }

        .btn-action:hover {
            background: #dbeafe;
        }

        /* Modal Styles */
        .modal-overlay {
            position: fixed;
            top: 0; left: 0; right: 0; bottom: 0;
            background: rgba(15, 23, 42, 0.5);
            display: none;
            justify-content: center;
            align-items: center;
            z-index: 9999;
            backdrop-filter: blur(4px);
        }

        .modal-overlay.active { display: flex; }

        .modal-content {
            background: #fff;
            width: 90%;
            max-width: 600px;
            border-radius: 12px;
            padding: 24px;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
        }

        .modal-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #e2e8f0;
            padding-bottom: 16px;
            margin-bottom: 20px;
        }

        .modal-header h3 {
            font-size: 18px;
            font-weight: 600;
            color: #0f172a;
            margin: 0;
        }

        .close-modal {
            background: none;
            border: none;
            font-size: 20px;
            color: #94a3b8;
            cursor: pointer;
        }

        .close-modal:hover { color: #0f172a; }

        .detail-row {
            margin-bottom: 16px;
        }

        .detail-label {
            font-size: 13px;
            color: #64748b;
            font-weight: 600;
            margin-bottom: 4px;
            display: block;
        }

        .detail-value {
            font-size: 15px;
            color: #1e293b;
            background: #f8fafc;
            padding: 12px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
        }

        .modal-actions {
            margin-top: 24px;
            display: flex;
            gap: 12px;
            justify-content: flex-end;
            padding-top: 16px;
            border-top: 1px solid #e2e8f0;
        }

        .btn-modal {
            padding: 8px 16px;
            border-radius: 6px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-resolve { background: #10b981; color: white; }
        .btn-resolve:hover { background: #059669; }
        
        .btn-ignore { background: #f1f5f9; color: #475569; border: 1px solid #cbd5e1; }
        .btn-ignore:hover { background: #e2e8f0; }

        .btn-close-status { background: #ef4444; color: white; }
        .btn-close-status:hover { background: #dc2626; }
        .tabs-container {
            display: flex;
            gap: 12px;
            margin-bottom: 20px;
            border-bottom: 2px solid #e2e8f0;
        }

        .tab-button {
            padding: 10px 16px;
            font-size: 14px;
            font-weight: 500;
            color: #64748b;
            text-decoration: none;
            border-bottom: 3px solid transparent;
            margin-bottom: -2px;
            transition: 0.2s;
        }

        .tab-button:hover {
            color: #1e293b;
            border-bottom-color: #cbd5e1;
        }

        .tab-button.active {
            color: #4f46e5;
            border-bottom-color: #4f46e5;
        }
        
    </style>
</head>
<body class="panel-body">
    <main class="panel-main">
        <div class="page-content">
            <h2 class="header-title"><i class="fas fa-envelope-open-text"></i> Danh Sách Phản Hồi Từ Liên Hệ</h2>
            
            <c:if test="${not empty sessionScope.toastMessage}">
                <div style="background: #10b981; color: white; padding: 12px 20px; border-radius: 8px; margin-bottom: 20px;">
                    <i class="fas fa-check-circle"></i> ${sessionScope.toastMessage}
                    <c:remove var="toastMessage" scope="session" />
                </div>
            </c:if>

            <div class="tabs-container">
                <a href="${pageContext.request.contextPath}/admin/contacts?filter=all" 
                   class="tab-button ${empty currentFilter || currentFilter == 'all' ? 'active' : ''}">Tất cả</a>
                <a href="${pageContext.request.contextPath}/admin/contacts?filter=pending" 
                   class="tab-button ${currentFilter == 'pending' ? 'active' : ''}">Chưa xử lý</a>
                <a href="${pageContext.request.contextPath}/admin/contacts?filter=resolved" 
                   class="tab-button ${currentFilter == 'resolved' ? 'active' : ''}">Đã xử lý</a>
            </div>

            <div class="contact-table-wrapper">
                <table class="contact-table">
                    <thead>
                        <tr>
                            <th>#ID</th>
                            <th>Họ tên</th>
                            <th>Email</th>
                            <th>Loại</th>
                            <th>Trạng thái</th>
                            <th>Ngày gửi</th>
                            <th>Thao tác</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="c" items="${contacts}">
                            <tr>
                                <td>${c.id}</td>
                                <td><strong>${c.fullName}</strong></td>
                                <td>${c.email}</td>
                                <td>${c.feedbackType}</td>
                                <td><span class="status-badge status-${c.status}">${c.status}</span></td>
                                <td>
                                    <fmt:parseDate value="${c.createdAt}" pattern="yyyy-MM-dd'T'HH:mm" var="parsedDate" type="both" />
                                    <fmt:formatDate value="${parsedDate}" pattern="dd/MM/yyyy HH:mm" />
                                </td>
                                <td>
                                    <button class="btn-action btn-view-detail" 
                                            data-id="${c.id}"
                                            data-name="${fn:escapeXml(c.fullName)}"
                                            data-email="${fn:escapeXml(c.email)}"
                                            data-phone="${fn:escapeXml(c.phone)}"
                                            data-type="${fn:escapeXml(c.feedbackType)}"
                                            data-message="${fn:escapeXml(c.message)}">
                                        Chi tiết
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty contacts}">
                            <tr>
                                <td colspan="7" style="text-align: center; padding: 40px; color: #64748b;">
                                    <i class="fas fa-inbox" style="font-size: 32px; margin-bottom: 12px; display: block;"></i>
                                    Chưa có tin nhắn liên hệ nào.
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Modal Detail -->
    <div class="modal-overlay" id="contactModal">
        <div class="modal-content">
            <div class="modal-header">
                <h3>Chi tiết liên hệ #<span id="modalId"></span></h3>
                <button class="close-modal" id="btnCloseModalTop"><i class="fas fa-times"></i></button>
            </div>
            
            <div class="detail-row">
                <span class="detail-label">Người gửi</span>
                <div class="detail-value" id="modalSender"></div>
            </div>
            <div class="detail-row">
                <span class="detail-label">Thông tin liên lạc</span>
                <div class="detail-value" id="modalContactInfo"></div>
            </div>
            <div class="detail-row">
                <span class="detail-label">Loại phản hồi</span>
                <div class="detail-value" id="modalType"></div>
            </div>
            <div class="detail-row">
                <span class="detail-label">Nội dung tin nhắn</span>
                <div class="detail-value" id="modalMessage" style="min-height: 80px; white-space: pre-wrap;"></div>
            </div>

            <form action="${pageContext.request.contextPath}/admin/contacts" method="POST" id="actionForm">
                <input type="hidden" name="id" id="formContactId">
                <div class="modal-actions">
                    <button type="submit" name="action" value="resolve" class="btn-modal btn-resolve">
                        <i class="fas fa-check"></i> Đã giải quyết
                    </button>
                    <button type="submit" name="action" value="ignore" class="btn-modal btn-ignore">
                        <i class="fas fa-ban"></i> Bỏ qua
                    </button>
                    <button type="submit" name="action" value="close" class="btn-modal btn-close-status">
                        <i class="fas fa-times-circle"></i> Đóng
                    </button>
                </div>
            </form>
        </div>
    </div>

    <script>
        document.querySelectorAll('.btn-view-detail').forEach(button => {
            button.addEventListener('click', function() {
                const id = this.getAttribute('data-id');
                const name = this.getAttribute('data-name');
                const email = this.getAttribute('data-email');
                const phone = this.getAttribute('data-phone');
                const type = this.getAttribute('data-type');
                const message = this.getAttribute('data-message');

                document.getElementById('modalId').innerText = id;
                document.getElementById('formContactId').value = id;
                document.getElementById('modalSender').innerText = name;
                document.getElementById('modalContactInfo').innerText = email + ' - ' + phone;
                document.getElementById('modalType').innerText = type;
                document.getElementById('modalMessage').innerText = message;
                
                document.getElementById('contactModal').classList.add('active');
            });
        });

        function closeContactModal() {
            document.getElementById('contactModal').classList.remove('active');
        }

        document.getElementById('btnCloseModalTop').addEventListener('click', closeContactModal);

        // Close on clicking outside
        document.getElementById('contactModal').addEventListener('click', function(e) {
            if (e.target === this) {
                closeContactModal();
            }
        });
    </script>
</body>
</html>
