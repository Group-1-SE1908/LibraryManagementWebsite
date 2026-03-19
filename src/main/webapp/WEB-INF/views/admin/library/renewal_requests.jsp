<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>Yêu cầu gia hạn | LBMS</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
                    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                    <style>
                        .renewal-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 24px;
                        }

                        .renewal-cards {
                            display: grid;
                            grid-template-columns: 1fr;
                            gap: 20px;
                        }

                        .renewal-card {
                            background: white;
                            border-radius: 12px;
                            padding: 20px;
                            box-shadow: 0 8px 24px rgba(15, 23, 42, 0.08);
                            border: 1px solid #e2e8f0;
                            display: flex;
                            flex-direction: column;
                            gap: 18px;
                        }

                        .renewal-card__head {
                            display: flex;
                            justify-content: space-between;
                            align-items: baseline;
                        }

                        .renewal-card__head h3 {
                            margin: 0;
                            font-size: 18px;
                            color: #0f172a;
                        }

                        .renewal-card__head span {
                            font-size: 12px;
                            color: #64748b;
                            font-weight: 600;
                        }

                        .renewal-card__meta {
                            font-size: 13px;
                            color: #475569;
                            display: flex;
                            flex-direction: column;
                            gap: 6px;
                        }

                        .renewal-card__meta strong {
                            color: #0b57d0;
                        }

                        .renewal-card__reason {
                            background: #f8fafc;
                            padding: 12px;
                            border-radius: 8px;
                            font-size: 14px;
                            color: #1e293b;
                        }

                        .renewal-queue {
                            border: 1px solid #dbeafe;
                            background: linear-gradient(180deg, #eff6ff 0%, #ffffff 100%);
                            border-radius: 10px;
                            padding: 14px;
                            display: grid;
                            gap: 10px;
                        }

                        .renewal-queue__head {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            gap: 10px;
                            flex-wrap: wrap;
                        }

                        .renewal-queue__title {
                            margin: 0;
                            font-size: 13px;
                            font-weight: 700;
                            color: #1e3a8a;
                        }

                        .renewal-queue__summary {
                            font-size: 12px;
                            color: #64748b;
                        }

                        .renewal-queue__badge {
                            display: inline-flex;
                            align-items: center;
                            gap: 6px;
                            padding: 4px 10px;
                            border-radius: 999px;
                            font-size: 11px;
                            font-weight: 700;
                            letter-spacing: 0.03em;
                            text-transform: uppercase;
                            border: 1px solid transparent;
                        }

                        .renewal-queue__badge--waiting {
                            background: #fffbeb;
                            color: #92400e;
                            border-color: #fcd34d;
                        }

                        .renewal-queue__badge--clear {
                            background: #f0fdf4;
                            color: #166534;
                            border-color: #86efac;
                        }

                        .renewal-queue__list {
                            display: grid;
                            gap: 8px;
                        }

                        .renewal-queue__item {
                            display: grid;
                            grid-template-columns: auto 1fr auto;
                            gap: 12px;
                            align-items: center;
                            padding: 10px 12px;
                            border-radius: 8px;
                            background: rgba(255, 255, 255, 0.72);
                            border: 1px solid #e2e8f0;
                        }

                        .renewal-queue__pos {
                            min-width: 34px;
                            height: 34px;
                            border-radius: 999px;
                            background: #dbeafe;
                            color: #1d4ed8;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            font-weight: 700;
                            font-size: 13px;
                        }

                        .renewal-queue__name {
                            font-size: 13px;
                            font-weight: 600;
                            color: #0f172a;
                            margin: 0;
                        }

                        .renewal-queue__meta {
                            font-size: 12px;
                            color: #64748b;
                            margin-top: 2px;
                        }

                        .renewal-queue__empty {
                            font-size: 13px;
                            color: #475569;
                            margin: 0;
                        }

                        .renewal-actions {
                            display: flex;
                            gap: 10px;
                            flex-wrap: wrap;
                            align-items: flex-end;
                        }

                        .renewal-actions form {
                            display: flex;
                            flex-direction: column;
                            gap: 8px;
                            flex: 1;
                        }

                        .renewal-actions textarea {
                            resize: vertical;
                            min-height: 70px;
                            border-radius: 8px;
                            border: 1px solid #cbd5e1;
                            padding: 10px;
                            font-family: inherit;
                        }

                        .empty-state {
                            text-align: center;
                            padding: 40px;
                            border-radius: 12px;
                            border: 1px dashed #cbd5e1;
                            background: white;
                            color: #475569;
                            font-weight: 600;
                        }
                    </style>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                </head>

                <body class="panel-body">
                    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
                    <c:set var="borrowBase"
                        value="${not empty staffBorrowBase ? staffBorrowBase : '/staff/borrowlibrary'}" />

                    <main class="panel-main">
                        <div class="pm-header"
                            style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:12px;">
                            <div>
                                <h1 class="pm-title">Yêu cầu gia hạn</h1>
                                <p class="pm-subtitle">Xét duyệt các yêu cầu gia hạn đang chờ xử lý từ độc giả.</p>
                            </div>
                            <a class="btn-modern secondary" href="${pageContext.request.contextPath}${borrowBase}"
                                style="margin-top:4px;">
                                ← Quay lại mượn trả
                            </a>
                        </div>

                        <c:if test="${not empty flash}">
                            <script>
                                let iconType = 'info';
                                let titleText = 'Thông báo';
                                const flashMsg = '<c:out value="${flash}"/>';

                                if (flashMsg.includes('thành công')) {
                                    iconType = 'success';
                                    titleText = 'Thành công';
                                } else if (flashMsg.includes('Lỗi')) {
                                    iconType = 'error';
                                    titleText = 'Lỗi';
                                }

                                Swal.fire({
                                    icon: iconType,
                                    title: titleText,
                                    text: flashMsg,
                                    confirmButtonColor: '#0b57d0'
                                });
                            </script>
                        </c:if>

                        <c:set var="actionPrefix"
                            value="${renewalActionPrefix != null ? renewalActionPrefix : '/staff/renewal'}" />

                        <c:if test="${empty renewalTickets}">
                            <div class="empty-state">
                                Hiện không có yêu cầu gia hạn nào đang chờ xử lý.
                            </div>
                        </c:if>

                        <div class="renewal-cards">
                            <c:forEach items="${renewalTickets}" var="ticket">
                                <c:set var="record" value="${ticket.borrowRecord}" />
                                <div class="renewal-card">
                                    <div class="renewal-card__head">
                                        <h3>Mã yêu cầu #
                                            <c:out value="${ticket.id}" />
                                        </h3>
                                        <span>Phiếu mượn #
                                            <c:out value="${ticket.borrowId}" />
                                        </span>
                                    </div>
                                    <div class="renewal-card__meta">
                                        <span>📘 <strong>
                                                <c:out value="${record.book.title}" default="Không rõ tựa đề" />
                                            </strong></span>
                                        <span>👤
                                            <c:out value="${record.user.fullName}" default="Độc giả chưa xác định" /> ·
                                            <c:out value="${record.user.email}" default="Không có email" /> ·
                                            <c:out value="${record.user.phone}" default="Không có số" />
                                        </span>
                                        <span>⏰ Hạn trả hiện tại: <strong>
                                                <c:out value="${record.dueDate}" default="Chưa cập nhật" />
                                            </strong></span>
                                        <span>📩 Liên hệ:
                                            <c:out
                                                value="${not empty ticket.contactPhone ? ticket.contactPhone : record.user.phone}"
                                                default="Không có số" /> ·
                                            <c:out
                                                value="${not empty ticket.contactEmail ? ticket.contactEmail : record.user.email}"
                                                default="Không có email" />
                                        </span>
                                        <span>📝 Gửi lúc: <c:choose>
                                                <c:when test="${not empty ticket.requestedAt}">
                                                    <c:out value="${fn:replace(ticket.requestedAt, 'T', ' ')}" />
                                                </c:when>
                                                <c:otherwise>---</c:otherwise>
                                            </c:choose></span>
                                    </div>
                                    <div class="renewal-card__reason">
                                        <strong>Lý do gia hạn:</strong>
                                        <p style="margin-top:6px;">${fn:escapeXml(ticket.reason)}</p>
                                    </div>
                                    <c:set var="reservationQueue"
                                        value="${reservationQueueMap[record.book.id]}" />
                                    <div class="renewal-queue">
                                        <div class="renewal-queue__head">
                                            <div>
                                                <p class="renewal-queue__title">Hàng chờ của cuốn sách này</p>
                                                <div class="renewal-queue__summary">Có ${fn:length(reservationQueue)} người đang chờ</div>
                                            </div>
                                            <span class="renewal-queue__badge ${empty reservationQueue ? 'renewal-queue__badge--clear' : 'renewal-queue__badge--waiting'}">
                                                ${empty reservationQueue ? 'Không có người chờ' : 'Đang có hàng chờ'}
                                            </span>
                                        </div>
                                        <c:choose>
                                            <c:when test="${empty reservationQueue}">
                                                <p class="renewal-queue__empty">Hiện chưa có độc giả nào trong hàng chờ cho cuốn sách này.</p>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="renewal-queue__list">
                                                    <c:forEach var="res" items="${reservationQueue}">
                                                        <div class="renewal-queue__item">
                                                            <div class="renewal-queue__pos">
                                                                <c:out value="${not empty res.queuePosition ? res.queuePosition : '—'}" />
                                                            </div>
                                                            <div>
                                                                <p class="renewal-queue__name">
                                                                    <c:out value="${not empty res.userName ? res.userName : 'Độc giả không xác định'}" />
                                                                </p>
                                                                <div class="renewal-queue__meta">
                                                                    <c:out value="${not empty res.userEmail ? res.userEmail : 'Không có email'}" />
                                                                    ·
                                                                    <c:out value="${not empty res.userPhone ? res.userPhone : 'Không có số điện thoại'}" />
                                                                </div>
                                                            </div>
                                                            <div class="renewal-queue__meta" style="text-align:right;white-space:nowrap;">
                                                                <c:out value="${fn:escapeXml(res.statusLabel)}" />
                                                            </div>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="renewal-actions">
                                        <form action="${pageContext.request.contextPath}${actionPrefix}/approve"
                                            method="post">
                                            <input type="hidden" name="renewalId" value="${ticket.id}">
                                            <button type="submit" class="btn-modern success" style="padding: 10px;">Phê
                                                duyệt gia hạn</button>
                                        </form>
                                        <form class="reject-form"
                                            action="${pageContext.request.contextPath}${actionPrefix}/reject"
                                            method="post">
                                            <input type="hidden" name="renewalId" value="${ticket.id}">
                                            <textarea name="reason" placeholder="Ghi chú từ chối (tùy ý)"></textarea>
                                            <button type="submit" class="btn-modern danger" style="padding: 10px;">Từ
                                                chối yêu cầu</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
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