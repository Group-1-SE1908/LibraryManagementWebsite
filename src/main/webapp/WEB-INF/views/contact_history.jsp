<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử Liên hệ - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .contact-card {
            background: var(--mp-surface);
            border-radius: var(--mp-radius);
            padding: 24px;
            margin-bottom: 20px;
            border: 1px solid var(--mp-border);
            box-shadow: var(--mp-shadow-sm);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .contact-card:hover {
            transform: translateY(-2px);
            box-shadow: var(--mp-shadow-md);
        }

        .contact-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 16px;
            padding-bottom: 16px;
            border-bottom: 1px solid var(--mp-border);
        }

        .contact-type {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--mp-text);
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .contact-id {
            color: var(--mp-text-lighter);
            font-size: 0.9rem;
            font-weight: normal;
        }

        .contact-status {
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .status-pending { background: #fef3c7; color: #92400e; }
        .status-resolved { background: #d1fae5; color: #065f46; }
        .status-cancelled { background: #f3f4f6; color: #4b5563; }

        .contact-body {
            color: var(--mp-text-light);
            font-size: 0.95rem;
            line-height: 1.6;
            margin-bottom: 20px;
        }

        .contact-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 0.85rem;
            color: var(--mp-text-lighter);
        }

        .contact-actions {
            display: flex;
            gap: 12px;
        }

        .btn-cancel {
            background: #fff;
            color: #ef4444;
            border: 1px solid #fca5a5;
            padding: 6px 16px;
            border-radius: var(--mp-radius-sm);
            font-weight: 600;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-cancel:hover {
            background: #fef2f2;
            border-color: #ef4444;
        }

        .filter-tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 32px;
            border-bottom: 2px solid var(--mp-border);
            padding-bottom: 2px;
        }

        .filter-tab {
            padding: 10px 20px;
            color: var(--mp-text-light);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            position: relative;
            transition: color 0.2s;
        }

        .filter-tab:hover {
            color: var(--mp-primary);
        }

        .filter-tab.active {
            color: var(--mp-primary);
        }

        .filter-tab.active::after {
            content: '';
            position: absolute;
            bottom: -4px;
            left: 0;
            right: 0;
            height: 3px;
            background: var(--mp-primary);
            border-radius: 3px 3px 0 0;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: #f8fafc;
            border-radius: var(--mp-radius);
            border: 1px dashed var(--mp-border);
            color: var(--mp-text-light);
        }

        .empty-state i {
            font-size: 3rem;
            color: #cbd5e1;
            margin-bottom: 16px;
        }
    </style>
</head>
<body class="member-page">

    <jsp:include page="/WEB-INF/views/header.jsp" />

    <section class="mp-hero">
        <div class="mp-hero__bg">
            <div class="mp-hero__shape mp-hero__shape--1"></div>
            <div class="mp-hero__shape mp-hero__shape--2"></div>
        </div>
        <div class="mp-hero__container">
            <div class="mp-hero__inner">
                <div class="mp-hero__content">
                    <div class="mp-hero__tag">
                        <span>Lịch sử liên hệ</span>
                    </div>
                    <h1 class="mp-hero__title">Yêu cầu của bạn</h1>
                    <p class="mp-hero__desc" style="max-width: 600px; margin: 0 auto;">
                        Theo dõi trạng thái các câu hỏi, góp ý và phản hồi bạn đã gửi đến thư viện.
                    </p>
                </div>
            </div>
        </div>
    </section>

    <main class="mp-content" style="padding-top: 40px;">
        <c:if test="${not empty error}">
            <div class="mp-flash mp-flash--error">
                <i class="fas fa-exclamation-circle"></i>
                <span>${error}</span>
            </div>
        </c:if>
        <c:if test="${not empty sessionScope.toastMessage}">
            <div class="mp-flash mp-flash--success">
                <i class="fas fa-check-circle"></i>
                <span>${sessionScope.toastMessage}</span>
            </div>
            <c:remove var="toastMessage" scope="session" />
        </c:if>

        <div class="filter-tabs">
            <a href="${pageContext.request.contextPath}/contact-history?filter=all" class="filter-tab ${currentFilter == 'all' ? 'active' : ''}">
                Tất cả
            </a>
            <a href="${pageContext.request.contextPath}/contact-history?filter=pending" class="filter-tab ${currentFilter == 'pending' ? 'active' : ''}">
                Đang chờ
            </a>
            <a href="${pageContext.request.contextPath}/contact-history?filter=resolved" class="filter-tab ${currentFilter == 'resolved' ? 'active' : ''}">
                Đã giải quyết
            </a>
            <a href="${pageContext.request.contextPath}/contact-history?filter=cancelled" class="filter-tab ${currentFilter == 'cancelled' ? 'active' : ''}">
                Đã đóng / Hủy
            </a>
        </div>

        <div class="contact-list">
            <c:choose>
                <c:when test="${empty messages}">
                    <div class="empty-state">
                        <i class="far fa-folder-open"></i>
                        <h3>Không có liên hệ nào</h3>
                        <p>Bạn chưa gửi liên hệ nào hoặc không có dữ liệu phù hợp với bộ lọc này.</p>
                        <a href="${pageContext.request.contextPath}/contact" class="mp-btn mp-btn--primary" style="margin-top: 16px; display: inline-flex;">
                            Liên hệ ngay
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="msg" items="${messages}">
                        <div class="contact-card">
                            <div class="contact-header">
                                <div class="contact-type">
                                    <c:choose>
                                        <c:when test="${msg.feedbackType == 'Lỗi'}"><i class="fas fa-bug" style="color: #ef4444;"></i></c:when>
                                        <c:when test="${msg.feedbackType == 'Lời khen'}"><i class="fas fa-star" style="color: #f59e0b;"></i></c:when>
                                        <c:when test="${msg.feedbackType == 'Góp ý'}"><i class="fas fa-lightbulb" style="color: #3b82f6;"></i></c:when>
                                        <c:otherwise><i class="fas fa-envelope-open-text" style="color: #6366f1;"></i></c:otherwise>
                                    </c:choose>
                                    ${msg.feedbackType} <span class="contact-id">#${msg.id}</span>
                                </div>
                                
                                <c:choose>
                                    <c:when test="${msg.status == 'PENDING'}">
                                        <span class="contact-status status-pending">
                                            <i class="fas fa-clock"></i> Đang chờ
                                        </span>
                                    </c:when>
                                    <c:when test="${msg.status == 'RESOLVED' || msg.status == 'IGNORED'}">
                                        <span class="contact-status status-resolved">
                                            <i class="fas fa-check-circle"></i> Đã xử lý
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="contact-status status-cancelled">
                                            <i class="fas fa-times-circle"></i> Đã đóng/Hủy
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            
                            <div class="contact-body" style="white-space: pre-wrap;">
                                <strong>Nội dung:</strong><br/><c:out value="${msg.message}" />
                            </div>
                            
                            <div class="contact-footer">
                                <div class="contact-date">
                                    <i class="far fa-calendar-alt"></i> Ngày gửi: ${msg.formattedCreatedAt}
                                </div>
                                
                                <c:if test="${msg.status == 'PENDING'}">
                                    <div class="contact-actions">
                                        <form action="${pageContext.request.contextPath}/contact-history" method="POST" onsubmit="return confirm('Bạn có chắc muốn hủy yêu cầu liên hệ này không?');">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="id" value="${msg.id}">
                                            <input type="hidden" name="filter" value="${currentFilter}">
                                            <button type="submit" class="btn-cancel">
                                                <i class="fas fa-times"></i> Hủy yêu cầu
                                            </button>
                                        </form>
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/footer.jsp" />
</body>
</html>
