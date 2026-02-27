<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Comments - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        .comments-container {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .comments-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .comment-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
            border: 1px solid #e5e7eb;
        }

        .comment-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }

        .comment-user-info {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .comment-avatar {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: linear-gradient(135deg, #3b82f6, #60a5fa);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 600;
            color: white;
            overflow: hidden;
            flex-shrink: 0;
            font-size: 16px;
        }

        .comment-avatar img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .comment-meta {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .comment-user {
            font-weight: 600;
            color: #1f2937;
        }

        .comment-date {
            font-size: 12px;
            color: #6b7280;
        }

        .comment-rating {
            display: flex;
            gap: 4px;
            margin: 12px 0;
            font-size: 14px;
        }

        .star {
            color: #fbbf24;
        }

        .comment-content {
            color: #6b7280;
            line-height: 1.6;
            word-wrap: break-word;
        }

        .no-comments {
            text-align: center;
            padding: 40px;
            color: #6b7280;
        }
    </style>
</head>
<body>
    <jsp:include page="header.jsp" />

    <div class="comments-container">
        <h1>Comments for Book ID: ${bookId}</h1>

        <c:choose>
            <c:when test="${not empty comments}">
                <div class="comments-list">
                    <c:forEach var="comment" items="${comments}">
                        <div class="comment-card">
                            <div class="comment-header">
                                <div class="comment-user-info">
                                    <div class="comment-avatar">
                                        <c:choose>
                                            <c:when test="${not empty comment.avatar && comment.avatar != 'null'}">
                                                <img src="${pageContext.request.contextPath}/${comment.avatar}" alt="${comment.fullName}" onerror="this.parentElement.innerText='${fn:substring(comment.fullName, 0, 1)}'">
                                            </c:when>
                                            <c:otherwise>
                                                <c:out value="${fn:substring(comment.fullName, 0, 1)}"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="comment-meta">
                                        <span class="comment-user">${comment.fullName}</span>
                                        <span class="comment-date">
                                            <fmt:formatDate value="${comment.createdAt}" type="date" dateStyle="medium"/>
                                        </span>
                                    </div>
                                </div>
                            </div>

                            <div class="comment-rating">
                                <c:forEach begin="1" end="${comment.rating}">
                                    <span class="star">★</span>
                                </c:forEach>
                            </div>

                            <p class="comment-content">${comment.content}</p>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="no-comments">
                    <p>No comments yet.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <jsp:include page="footer.jsp" />
</body>
</html>
