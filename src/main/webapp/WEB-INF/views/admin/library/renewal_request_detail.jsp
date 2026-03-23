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
                    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                    <style>
                        * {
                            box-sizing: border-box;
                        }

                        :root {
                            --bg: #f0f4f8;
                            --surface: #ffffff;
                            --border: #e2e8f0;
                            --text: #1e293b;
                            --text-soft: #64748b;
                            --text-muted: #94a3b8;
                            --primary: #3b82f6;
                            --primary-light: #eff6ff;
                            --pending-bg: #fffbeb;
                            --pending-bd: #fcd34d;
                            --pending-tx: #92400e;
                            --approved-bg: #f0fdf4;
                            --approved-bd: #86efac;
                            --approved-tx: #166534;
                            --rejected-bg: #fef2f2;
                            --rejected-bd: #fca5a5;
                            --rejected-tx: #991b1b;
                            --radius-sm: 6px;
                            --radius: 12px;
                            --shadow: 0 1px 3px rgba(0, 0, 0, .08), 0 1px 2px rgba(0, 0, 0, .04);
                        }

                        body {
                            margin: 0;
                            font-family: 'Inter', sans-serif;
                            background: var(--bg);
                            color: var(--text);
                            min-height: 100vh;
                        }

                        .page-header {
                            background: var(--surface);
                            border-bottom: 1px solid var(--border);
                            padding: 24px 40px;
                        }

                        .page-header__inner {
                            max-width: 1100px;
                            margin: 0 auto;
                            display: flex;
                            align-items: center;
                            justify-content: space-between;
                            gap: 16px;
                            flex-wrap: wrap;
                        }

                        .page-header__link {
                            color: var(--primary);
                            text-decoration: none;
                            font-size: .9rem;
                            font-weight: 600;
                        }

                        .page-header__title {
                            font-size: 1.35rem;
                            font-weight: 700;
                            margin: 0;
                        }

                        .page-header__sub {
                            margin-top: 4px;
                            font-size: .84rem;
                            color: var(--text-soft);
                        }

                        .content {
                            max-width: 1100px;
                            margin: 0 auto;
                            padding: 20px 40px 60px;
                        }

                        .detail-card {
                            background: var(--surface);
                            border-radius: var(--radius);
                            border: 1px solid var(--border);
                            box-shadow: var(--shadow);
                            padding: 32px;
                            max-width: 900px;
                            margin: 0 auto;
                            display: grid;
                            gap: 20px;
                        }

                        .detail-head {
                            display: flex;
                            justify-content: space-between;
                            align-items: flex-start;
                            gap: 14px;
                            flex-wrap: wrap;
                        }

                        .detail-head__title {
                            margin: 0;
                            font-size: 1.15rem;
                            font-weight: 700;
                            color: var(--text);
                        }

                        .detail-head__meta {
                            font-size: .8rem;
                            color: var(--text-soft);
                            margin-top: 4px;
                        }

                        .detail-meta {
                            display: grid;
                            gap: 8px;
                            color: var(--text-soft);
                            font-size: .92rem;
                        }

                        .detail-meta strong {
                            color: var(--text);
                        }

                        .detail-reason {
                            background: #f8fafc;
                            border: 1px solid var(--border);
                            border-radius: 10px;
                            padding: 16px 18px;
                            color: var(--text);
                        }

                        .detail-reason strong {
                            display: block;
                            margin-bottom: 6px;
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

                        .renewal-queue__status {
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            padding: 3px 10px;
                            border-radius: 999px;
                            font-size: .72rem;
                            font-weight: 700;
                            text-transform: uppercase;
                            letter-spacing: .05em;
                            border: 1px solid #bae6fd;
                            background: #f0f9ff;
                            color: #0f172a;
                            white-space: nowrap;
                        }

                        .detail-actions {
                            display: grid;
                            gap: 12px;
                        }

                        .detail-actions__note {
                            display: flex;
                            flex-direction: column;
                            gap: 8px;
                        }

                        .detail-actions__note label {
                            font-size: .86rem;
                            font-weight: 600;
                            color: var(--text);
                        }

                        .detail-actions__note textarea {
                            width: 100%;
                            resize: vertical;
                            min-height: 72px;
                            border-radius: 8px;
                            border: 1px solid #cbd5e1;
                            padding: 10px;
                            font-family: inherit;
                            background: #fff;
                        }

                        .detail-actions__buttons {
                            display: flex;
                            gap: 10px;
                            flex-wrap: wrap;
                        }

                        .detail-actions__buttons form {
                            flex: 1 1 260px;
                        }

                        .detail-actions .btn-modern {
                            width: 100%;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            gap: 8px;
                            font-weight: 700;
                            border-radius: 999px;
                            padding: 14px 16px;
                            color: #fff;
                            text-transform: uppercase;
                            letter-spacing: 0.04em;
                            border: none;
                            cursor: pointer;
                        }

                        .detail-actions .btn-approve {
                            background: linear-gradient(120deg, #22c55e, #16a34a);
                            box-shadow: 0 15px 30px rgba(34, 197, 94, 0.3);
                        }

                        .detail-actions .btn-reject {
                            background: linear-gradient(120deg, #f97316, #dc2626);
                            box-shadow: 0 15px 30px rgba(249, 115, 22, 0.35);
                        }

                        @media (max-width: 768px) {
                            .page-header {
                                padding: 16px 20px;
                            }

                            .content {
                                padding: 14px 20px 40px;
                            }
                        }
                    </style>
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet">
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                </head>

                <body class="panel-body">
                    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

                    <main class="panel-main">
                        <a class="page-header__link" href="${pageContext.request.contextPath}/admin/renewal"
                            style="display:inline-flex;align-items:center;gap:8px;margin-bottom:16px;">
                            ← Quay lại danh sách yêu cầu
                        </a>

                        <div class="content" style="padding:0;max-width:none;margin:0;">
                            <div class="detail-card">
                                <div class="detail-head">
                                    <div>
                                        <h1 class="detail-head__title">Mã yêu cầu # <c:out value="${renewalTicket.id}" /></h1>
                                        <div class="detail-head__meta">Phiếu mượn # <c:out value="${renewalTicket.borrowId}" /></div>
                                    </div>
                                    <div class="detail-head__meta">
                                        Gửi lúc: <c:out value="${fn:replace(renewalTicket.requestedAt, 'T', ' ')}" />
                                    </div>
                                </div>

                                <div class="detail-meta">
                                    <span>📘 <strong><c:out value="${renewalTicket.borrowRecord.book.title}" default="Không rõ tựa đề" /></strong></span>
                                    <span>👤 <c:out value="${renewalTicket.borrowRecord.user.fullName}" /> · <c:out value="${renewalTicket.borrowRecord.user.email}" /></span>
                                    <span>⏰ Hạn trả hiện tại: <strong><c:out value="${renewalTicket.borrowRecord.dueDate}" default="Chưa cập nhật" /></strong></span>
                                    <span>📩 Liên hệ: <c:out value="${not empty renewalTicket.contactPhone ? renewalTicket.contactPhone : renewalTicket.borrowRecord.user.phone}" default="Không có số" /> · <c:out value="${not empty renewalTicket.contactEmail ? renewalTicket.contactEmail : renewalTicket.borrowRecord.user.email}" default="Không có email" /></span>
                                    <span>🔁 Số lần đã gửi yêu cầu gia hạn: <strong><c:out value="${renewalRequestCount}" default="0" /></strong></span>
                                </div>

                                <div class="detail-reason">
                                    <strong>Lý do gia hạn:</strong>
                                    <div>${fn:escapeXml(renewalTicket.reason)}</div>
                                </div>

                                <div class="renewal-queue">
                                    <div class="renewal-queue__head">
                                        <div>
                                            <p class="renewal-queue__title">Hàng đợi đặt trước cuốn này</p>
                                            <div class="renewal-queue__summary">(hiện có ${fn:length(reservationQueue)} người đang chờ)</div>
                                        </div>
                                        <span class="renewal-queue__badge ${empty reservationQueue ? 'renewal-queue__badge--clear' : 'renewal-queue__badge--waiting'}">
                                            ${empty reservationQueue ? 'Không có người chờ' : 'Có người chờ'}
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
                                                            <p class="renewal-queue__name"><c:out value="${not empty res.userName ? res.userName : 'Độc giả không xác định'}" /></p>
                                                            <div class="renewal-queue__meta">
                                                                <c:out value="${not empty res.userEmail ? res.userEmail : 'Không có email'}" />
                                                                ·
                                                                <c:out value="${not empty res.userPhone ? res.userPhone : 'Không có số điện thoại'}" />
                                                            </div>
                                                        </div>
                                                        <div style="text-align:right;">
                                                            <span class="renewal-queue__status"><c:out value="${fn:escapeXml(res.statusLabel)}" /></span>
                                                            <div class="renewal-queue__meta" style="margin-top:6px;white-space:nowrap;">
                                                                <fmt:formatDate value="${res.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                            </div>
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="detail-actions">
                                    <div class="detail-actions__note">
                                        <label for="rejectReason">Ghi chú từ chối (tùy ý)</label>
                                        <textarea id="rejectReason" placeholder="Nhập lý do từ chối nếu cần"></textarea>
                                    </div>
                                    <div class="detail-actions__buttons">
                                        <form action="${pageContext.request.contextPath}${renewalActionPrefix}/approve" method="post">
                                            <input type="hidden" name="renewalId" value="${renewalTicket.id}">
                                            <button type="submit" class="btn-modern btn-approve">Phê duyệt gia hạn</button>
                                        </form>
                                        <form class="reject-form" action="${pageContext.request.contextPath}${renewalActionPrefix}/reject" method="post">
                                            <input type="hidden" name="renewalId" value="${renewalTicket.id}">
                                            <input type="hidden" name="reason" id="rejectReasonValue">
                                            <button type="submit" class="btn-modern btn-reject">Từ chối yêu cầu</button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </main>

                    <script>
                        const rejectReasonInput = document.getElementById('rejectReason');
                        const rejectReasonValue = document.getElementById('rejectReasonValue');

                        document.querySelectorAll('.reject-form').forEach(form => {
                            form.addEventListener('submit', event => {
                                if (rejectReasonInput && rejectReasonValue) {
                                    rejectReasonValue.value = rejectReasonInput.value || '';
                                }
                                const confirmed = confirm('Bạn có chắc chắn muốn từ chối yêu cầu gia hạn này?');
                                if (!confirmed) {
                                    event.preventDefault();
                                }
                            });
                        });
                    </script>
                </body>

                </html>