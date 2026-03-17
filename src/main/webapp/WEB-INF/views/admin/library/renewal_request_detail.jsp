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

        .renewal-queue {
            background: #ffffff;
            border-radius: 12px;
            border: 1px solid #e5e7eb;
            padding: 24px;
            box-shadow: inset 0 0 0 1px rgba(59, 130, 246, 0.08);
            display: grid;
            gap: 14px;
        }

        .renewal-queue__header {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            gap: 12px;
        }

        .renewal-queue__header span {
            font-size: 13px;
            color: #94a3b8;
        }

        .renewal-queue__rows {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .renewal-queue__row {
            display: grid;
            grid-template-columns: auto 1fr auto;
            gap: 16px;
            padding-bottom: 8px;
            border-bottom: 1px solid #e2e8f0;
            align-items: center;
        }

        .renewal-queue__row:last-child {
            border-bottom: none;
            padding-bottom: 0;
        }

        .renewal-queue__position {
            font-weight: 600;
            color: #1d4ed8;
        }

        .renewal-queue__name {
            font-weight: 600;
            color: #0f172a;
            margin: 0;
        }

        .renewal-queue__meta {
            font-size: 13px;
            color: #64748b;
            margin: 2px 0 0;
        }

        .renewal-queue__empty {
            color: #475569;
            font-size: 14px;
        }

        .renewal-queue__status {
            font-size: 11px;
            font-weight: 600;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: #0f172a;
            border: 1px solid #bae6fd;
            padding: 2px 10px;
            border-radius: 999px;
            background: #f0f9ff;
            white-space: nowrap;
        }

        .renewal-queue__badge {
            font-size: 12px;
            font-weight: 600;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: #0f172a;
            background: #ecfeff;
            padding: 4px 14px;
            border-radius: 999px;
            border: 1px solid #bae6fd;
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .renewal-actions {
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            gap: 12px;
        }

        .renewal-actions .btn-modern {
            flex: 1 1 220px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            font-weight: 600;
            border-radius: 999px;
            padding: 14px 0;
            color: #fff;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .renewal-actions .btn-approve {
            background: linear-gradient(120deg, #22c55e, #16a34a);
            box-shadow: 0 15px 30px rgba(34, 197, 94, 0.3);
        }

        .renewal-actions .btn-reject {
            background: linear-gradient(120deg, #f97316, #dc2626);
            box-shadow: 0 15px 30px rgba(249, 115, 22, 0.35);
        }

        @media (max-width: 980px) {
            .renewal-detail {
                margin-left: 0;
                padding: 16px;
            }

            .renewal-actions {
                flex-direction: column;
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
            <div class="renewal-queue">
                <div class="renewal-queue__header">
                    <div>
                        <strong>Hàng đợi đặt trước cuốn này</strong>
                        <span>(hiện có ${fn:length(reservationQueue)} người đang chờ)</span>
                    </div>
                    <span class="renewal-queue__badge">${fn:length(reservationQueue) > 0 ? 'Có người chờ' : 'Không có người chờ'}</span>
                </div>
                <c:choose>
                    <c:when test="${empty reservationQueue}">
                        <p class="renewal-queue__empty">Hiện chưa có ai chờ mượn cuốn sách này.</p>
                    </c:when>
                    <c:otherwise>
                        <div class="renewal-queue__rows">
                            <c:forEach var="res" items="${reservationQueue}">
                                <div class="renewal-queue__row">
                                    <div class="renewal-queue__position">
                                        <c:out value="${not empty res.queuePosition ? res.queuePosition : '—'}"/>
                                    </div>
                                    <div>
                                        <p class="renewal-queue__name">
                                            <c:out value="${not empty res.userName ? res.userName : 'Độc giả không xác định'}"/>
                                        </p>
                                        <p class="renewal-queue__meta">
                                            <c:out value="${not empty res.userEmail ? res.userEmail : 'Không có email'}"/> ·
                                            <c:out value="${not empty res.userPhone ? res.userPhone : 'Không có số điện thoại'}"/>
                                        </p>
                                    </div>
                                    <div class="renewal-queue__meta" style="text-align:right;">
                                        <span class="renewal-queue__status">${fn:escapeXml(res.statusLabel)}</span>
                                        <span style="display:block;font-size:12px;color:#94a3b8;">
                                            <fmt:formatDate value="${res.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                        </span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
            <div class="renewal-actions">
                <form action="${pageContext.request.contextPath}${renewalActionPrefix}/approve" method="post">
                    <input type="hidden" name="renewalId" value="${renewalTicket.id}">
                    <button type="submit" class="btn-modern btn-approve">
                        <span>✅</span>
                        <span>Phê duyệt gia hạn</span>
                    </button>
                </form>
                <form class="reject-form" action="${pageContext.request.contextPath}${renewalActionPrefix}/reject" method="post">
                    <input type="hidden" name="renewalId" value="${renewalTicket.id}">
                    <textarea name="reason" placeholder="Ghi chú từ chối (tùy ý)"></textarea>
                    <button type="submit" class="btn-modern btn-reject">
                        <span>✖️</span>
                        <span>Từ chối yêu cầu</span>
                    </button>
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
