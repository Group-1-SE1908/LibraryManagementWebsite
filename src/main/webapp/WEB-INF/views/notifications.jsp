<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Thông báo – LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        :root {
            --bg: #f0f4f8; --surface: #fff; --border: #e2e8f0;
            --text: #1e293b; --text-soft: #64748b; --text-muted: #94a3b8;
            --primary: #3b82f6; --primary-light: #eff6ff;
            --radius-sm: 6px; --radius: 12px;
            --shadow: 0 1px 3px rgba(0,0,0,.08);
        }
        body { font-family: 'Inter', sans-serif; background: var(--bg); color: var(--text); min-height: 100vh; display: flex; flex-direction: column; }
        .main-wrap { flex: 1; }

        /* PAGE HEADER */
        .page-header { background: var(--surface); border-bottom: 1px solid var(--border); padding: 24px 40px; }
        .page-header__inner { max-width: 760px; margin: 0 auto; display: flex; align-items: center; justify-content: space-between; gap: 14px; }
        .page-header__left { display: flex; align-items: center; gap: 14px; }
        .page-header__icon { width: 40px; height: 40px; border-radius: var(--radius-sm); background: var(--primary-light); display: flex; align-items: center; justify-content: center; color: var(--primary); font-size: 1.2rem; }
        .page-header__title { font-size: 1.2rem; font-weight: 700; }
        .page-header__sub { font-size: .8rem; color: var(--text-soft); margin-top: 2px; }

        /* MARK ALL BTN */
        .btn-mark-all { display: inline-flex; align-items: center; gap: 6px; padding: 7px 16px; font-size: .82rem; font-weight: 600; border-radius: var(--radius-sm); border: 1.5px solid var(--border); background: var(--surface); color: var(--text-soft); cursor: pointer; transition: all .15s; }
        .btn-mark-all:hover { border-color: var(--primary); color: var(--primary); }

        /* CONTENT */
        .content { max-width: 760px; margin: 0 auto; padding: 24px 40px 60px; }

        /* EMPTY */
        .empty-state { background: var(--surface); border: 1px solid var(--border); border-radius: var(--radius); padding: 80px 20px; text-align: center; }
        .empty-state__icon { font-size: 3rem; color: #cbd5e1; margin-bottom: 12px; }
        .empty-state__title { font-size: 1rem; font-weight: 600; color: var(--text-soft); margin-bottom: 6px; }

        /* NOTIFICATION LIST */
        .notif-list { display: flex; flex-direction: column; gap: 10px; }

        .notif-card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: var(--radius); padding: 16px 20px;
            display: flex; align-items: flex-start; gap: 14px;
            box-shadow: var(--shadow); transition: background .1s;
            position: relative;
        }
        .notif-card.unread { background: #f0f7ff; border-color: #bfdbfe; }
        .notif-card.unread::before {
            content: ''; position: absolute; left: 0; top: 50%; transform: translateY(-50%);
            width: 4px; height: 60%; background: var(--primary);
            border-radius: 0 4px 4px 0;
        }

        /* Icon theo loại */
        .notif-icon { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; flex-shrink: 0; }
        .notif-icon--available  { background: #dcfce7; color: #16a34a; }
        .notif-icon--expiring   { background: #fef9c3; color: #ca8a04; }
        .notif-icon--expired    { background: #fee2e2; color: #dc2626; }
        .notif-icon--cancelled  { background: #f1f5f9; color: #64748b; }

        .notif-body { flex: 1; min-width: 0; }
        .notif-title { font-size: .9rem; font-weight: 600; color: var(--text); margin-bottom: 4px; }
        .notif-message { font-size: .82rem; color: var(--text-soft); line-height: 1.5; }
        .notif-time { font-size: .75rem; color: var(--text-muted); margin-top: 6px; }

        .notif-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
        .btn-read { padding: 4px 10px; font-size: .75rem; font-weight: 500; border-radius: var(--radius-sm); border: 1px solid var(--border); background: transparent; color: var(--text-soft); cursor: pointer; white-space: nowrap; transition: all .15s; }
        .btn-read:hover { border-color: var(--primary); color: var(--primary); }

        @media (max-width: 768px) {
            .page-header { padding: 16px 20px; }
            .content { padding: 14px 20px 40px; }
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<div class="main-wrap">
    <header class="page-header">
        <div class="page-header__inner">
            <div class="page-header__left">
                <div class="page-header__icon"><i class="bi bi-bell"></i></div>
                <div>
                    <div class="page-header__title">Thông báo</div>
                    <div class="page-header__sub">
                        <c:choose>
                            <c:when test="${unreadCount > 0}">
                                Bạn có <strong>${unreadCount}</strong> thông báo chưa đọc
                            </c:when>
                            <c:otherwise>Tất cả đã đọc</c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
            <c:if test="${unreadCount > 0}">
                <form method="post" action="${pageContext.request.contextPath}/notifications">
                    <input type="hidden" name="action" value="markAllRead"/>
                    <button type="submit" class="btn-mark-all">
                        <i class="bi bi-check2-all"></i> Đánh dấu tất cả đã đọc
                    </button>
                </form>
            </c:if>
        </div>
    </header>

    <main class="content">
        <c:choose>
            <c:when test="${empty notifications}">
                <div class="empty-state">
                    <div class="empty-state__icon"><i class="bi bi-bell-slash"></i></div>
                    <div class="empty-state__title">Chưa có thông báo nào</div>
                </div>
            </c:when>
            <c:otherwise>
                <div class="notif-list">
                    <c:forEach var="n" items="${notifications}">
                        <div class="notif-card ${n.isRead ? '' : 'unread'}">

                                <%-- Icon theo loại --%>
                            <div class="notif-icon
                                <c:choose>
                                    <c:when test="${n.type == 'RESERVATION_AVAILABLE'}">notif-icon--available</c:when>
                                    <c:when test="${n.type == 'RESERVATION_EXPIRING'}">notif-icon--expiring</c:when>
                                    <c:when test="${n.type == 'RESERVATION_EXPIRED'}">notif-icon--expired</c:when>
                                    <c:otherwise>notif-icon--cancelled</c:otherwise>
                                </c:choose>">
                                <c:choose>
                                    <c:when test="${n.type == 'RESERVATION_AVAILABLE'}"><i class="bi bi-check-circle-fill"></i></c:when>
                                    <c:when test="${n.type == 'RESERVATION_EXPIRING'}"><i class="bi bi-alarm-fill"></i></c:when>
                                    <c:when test="${n.type == 'RESERVATION_EXPIRED'}"><i class="bi bi-x-circle-fill"></i></c:when>
                                    <c:otherwise><i class="bi bi-slash-circle"></i></c:otherwise>
                                </c:choose>
                            </div>

                            <div class="notif-body">
                                <div class="notif-title">${n.title}</div>
                                <div class="notif-message">${n.message}</div>
                                <div class="notif-time">
                                    <i class="bi bi-clock" style="font-size:.7rem"></i>
                                    <fmt:formatDate value="${n.createdAt}" pattern="HH:mm - dd/MM/yyyy"/>
                                </div>
                            </div>

                                <%-- Nút đánh dấu đã đọc nếu chưa đọc --%>
                            <c:if test="${!n.isRead}">
                                <div class="notif-actions">
                                    <form method="post"
                                          action="${pageContext.request.contextPath}/notifications">
                                        <input type="hidden" name="action" value="markRead"/>
                                        <input type="hidden" name="notifId" value="${n.id}"/>
                                        <button type="submit" class="btn-read">
                                            Đã đọc
                                        </button>
                                    </form>
                                </div>
                            </c:if>

                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<jsp:include page="/WEB-INF/views/footer.jsp"/>
</body>
</html>
