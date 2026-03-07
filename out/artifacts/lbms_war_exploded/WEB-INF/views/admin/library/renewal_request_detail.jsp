<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8">
    <title>Chi tiết yêu cầu gia hạn | LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .renewal-detail {
            margin-left: 280px;
            min-height: 100vh;
            padding: 32px;
            background: #f4f7f6;
        }

        .renewal-card {
            background: white;
            border-radius: 16px;
            padding: 32px;
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.08);
            border: 1px solid #e2e8f0;
            max-width: 900px;
            margin: 0 auto;
            display: grid;
            gap: 20px;
        }

        .renewal-card__head,
        .renewal-card__footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .renewal-card__meta {
            display: grid;
            gap: 8px;
            color: #475569;
        }

        .renewal-card__reason {
            background: #f8fafc;
            border-radius: 12px;
            padding: 20px;
            color: #0f172a;
        }

        .renewal-actions {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }

        .renewal-actions .btn-modern {
            width: 100%;
        }

        @media (max-width: 980px) {
            .renewal-detail {
                margin-left: 0;
                padding: 16px;
            }

            .renewal-actions {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

    <main class="renewal-detail">
        <a href="${pageContext.request.contextPath}/admin/renewal" style="text-decoration:none;color:#4b5563;margin-bottom:16px;display:inline-flex;align-items:center;gap:8px;">
            ← Quay lại danh sách yêu cầu
        </a>
        <div class="renewal-card">
            <div class="renewal-card__head">
                <div>
                    <h2 style="margin:0;margin-bottom:6px;">Mã yêu cầu #<c:out value="${renewalTicket.id}"/></h2>
                    <span>Phiếu mượn #<c:out value="${renewalTicket.borrowId}"/></span>
                </div>
                <span style="font-size:12px;color:#64748b;">Gửi lúc: <c:out value="${fn:replace(renewalTicket.requestedAt, 'T', ' ')}"/></span>
            </div>
            <div class="renewal-card__meta">
                <span>📘 <strong><c:out value="${renewalTicket.borrowRecord.book.title}" default="Không rõ tựa đề"/></strong></span>
                <span>👤 <c:out value="${renewalTicket.borrowRecord.user.fullName}"/> · <c:out value="${renewalTicket.borrowRecord.user.email}"/></span>
                <span>⏰ Hạn trả hiện tại: <strong><c:out value="${renewalTicket.borrowRecord.dueDate}" default="Chưa cập nhật"/></strong></span>
                <span>📩 Liên hệ: <c:out value="${not empty renewalTicket.contactPhone ? renewalTicket.contactPhone : renewalTicket.borrowRecord.user.phone}" default="Không có số"/> · <c:out value="${not empty renewalTicket.contactEmail ? renewalTicket.contactEmail : renewalTicket.borrowRecord.user.email}" default="Không có email"/></span>
            </div>
            <div class="renewal-card__reason">
                <strong>Lý do gia hạn:</strong>
                <p style="margin-top:10px;">${fn:escapeXml(renewalTicket.reason)}</p>
            </div>
            <div class="renewal-actions">
                <form action="${pageContext.request.contextPath}${renewalActionPrefix}/approve" method="post">
                    <input type="hidden" name="renewalId" value="${renewalTicket.id}">
                    <button type="submit" class="btn-modern success">Phê duyệt gia hạn</button>
                </form>
                <form class="reject-form" action="${pageContext.request.contextPath}${renewalActionPrefix}/reject" method="post">
                    <input type="hidden" name="renewalId" value="${renewalTicket.id}">
                    <textarea name="reason" placeholder="Ghi chú từ chối (tùy ý)"></textarea>
                    <button type="submit" class="btn-modern danger">Từ chối yêu cầu</button>
                </form>
            </div>
        </div>
    </main>

    <script>
        document.querySelectorAll('.reject-form').forEach(form => {
            form.addEventListener('submit', event => {
                const confirmed = confirm('Bạn có chắc chắn muốn từ chối yêu cầu gia hạn này?');
                if (!confirmed) {
                    event.preventDefault();
                }
            });
        });
    </script>
</body>

</html>
