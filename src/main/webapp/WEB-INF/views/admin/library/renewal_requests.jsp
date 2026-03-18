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