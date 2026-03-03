<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý phản hồi - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">

    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background: #f8fafc;
        }

        main {
            flex: 1;
        }

        .container-page {
            max-width: 1100px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .panel {
            background: white;
            padding: 28px;
            border-radius: 16px;
            box-shadow: 0 6px 24px rgba(0, 0, 0, 0.05);
        }

        h2 {
            margin-bottom: 6px;
            font-size: 22px;
        }

        .filter-bar {
            display: flex;
            gap: 10px;
            margin: 20px 0 30px;
        }

        .filter-btn {
            padding: 8px 18px;
            border-radius: 20px;
            border: 1.5px solid #e5e7eb;
            background: white;
            cursor: pointer;
            font-weight: 600;
            font-size: 13px;
            transition: 0.2s;
            text-decoration: none;
            color: #374151;
        }

        .filter-btn:hover {
            border-color: #0b57d0;
            color: #0b57d0;
        }

        .filter-btn.active {
            background: #0b57d0;
            color: white;
            border-color: #0b57d0;
        }

        .feedback-row {
            display: flex;
            justify-content: space-between;
            gap: 20px;
            padding: 18px 0;
            border-bottom: 1px solid #f1f5f9;
        }

        .feedback-row:last-child {
            border-bottom: none;
        }

        .feedback-content {
            flex: 1;
        }

        .feedback-title {
            font-weight: 600;
            font-size: 15px;
        }

        .feedback-meta {
            font-size: 12px;
            color: #9ca3af;
            margin-top: 6px;
        }

        .feedback-text {
            margin-top: 10px;
            color: #4b5563;
            line-height: 1.6;
        }

        .star {
            color: #fbbf24;
            font-size: 13px;
            letter-spacing: 2px;
            margin-top: 6px;
        }

        .feedback-actions {
            display: flex;
            gap: 10px;
            align-items: flex-start;
        }

        .btn {
            background: #0b57d0;
            color: white;
            padding: 8px 14px;
            border-radius: 8px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: 0.2s;
            border: none;
            cursor: pointer;
        }

        .btn:hover {
            background: #0946a8;
        }

        .btn-delete {
            background: white;
            color: #ef4444;
            border: 1px solid #ef4444;
        }

        .btn-delete:hover {
            background: #ef4444;
            color: white;
        }

        .empty-state {
            text-align: center;
            color: #9ca3af;
            padding: 50px 0;
        }
    </style>
</head>

<body>

<jsp:include page="/WEB-INF/views/admin/library/header_lib.jsp"/>

<main>
    <div class="container-page">
        <div class="panel">

            <h2>Quản lý phản hồi sách</h2>
            <p style="color:#6b7280;">Danh sách phản hồi (bình luận) từ độc giả.</p>

            <!-- Filter -->
            <div class="filter-bar">
                <a href="${pageContext.request.contextPath}/admin/feedback?action=list&filter=all"
                   class="filter-btn ${filter == 'all' || empty filter ? 'active' : ''}">
                    Tất cả
                </a>

                <a href="${pageContext.request.contextPath}/admin/feedback?action=list&filter=unreplied"
                   class="filter-btn ${filter == 'unreplied' ? 'active' : ''}">
                    Chưa phản hồi
                </a>

                <a href="${pageContext.request.contextPath}/admin/feedback?action=list&filter=replied"
                   class="filter-btn ${filter == 'replied' ? 'active' : ''}">
                    Đã phản hồi
                </a>
            </div>

            <c:choose>
                <c:when test="${not empty comments}">
                    <c:forEach var="cmt" items="${comments}">

                        <div class="feedback-row">
                            <div class="feedback-content">

                                <div class="feedback-title">
                                    #${cmt.commentId} — ${cmt.fullName}
                                </div>

                                <div class="star">
                                    <c:forEach begin="1" end="${cmt.rating}">★</c:forEach>
                                    <c:forEach begin="${cmt.rating + 1}" end="5">
                                        <span style="color:#e5e7eb;">★</span>
                                    </c:forEach>
                                </div>

                                <div class="feedback-text">
                                        ${cmt.content}
                                </div>

                                <div class="feedback-meta">
                                    Sách ID: ${cmt.bookId} •
                                    <fmt:formatDate value="${cmt.createdAt}"
                                                    type="both"
                                                    dateStyle="medium"
                                                    timeStyle="short"/>
                                </div>

                            </div>

                            <div class="feedback-actions">
                                <a href="${pageContext.request.contextPath}/admin/feedback?action=view&id=${cmt.commentId}"
                                   class="btn">
                                    Xem & Trả lời
                                </a>

                                <form action="${pageContext.request.contextPath}/admin/feedback"
                                      method="post"
                                      onsubmit="return confirm('Xóa phản hồi này?');">

                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="id" value="${cmt.commentId}"/>

                                    <button type="submit" class="btn btn-delete">
                                        Xóa
                                    </button>
                                </form>
                            </div>
                        </div>

                    </c:forEach>
                </c:when>

                <c:otherwise>
                    <div class="empty-state">
                        Không có phản hồi nào.
                    </div>
                </c:otherwise>
            </c:choose>

        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp"/>

</body>
</html>