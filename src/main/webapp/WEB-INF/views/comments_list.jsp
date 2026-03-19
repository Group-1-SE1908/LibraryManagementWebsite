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
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
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
                            max-height: 4.8em;
                            /* 3 lines * 1.6 */
                            overflow: hidden;
                            position: relative;
                        }

                        .comment-content.expanded {
                            max-height: none;
                        }

                        .comment-content::after {
                            content: '';
                            position: absolute;
                            bottom: 0;
                            right: 0;
                            width: 100%;
                            height: 1.6em;
                            background: linear-gradient(to right, transparent, #ffffff);
                            pointer-events: none;
                        }

                        .comment-content.truncated::after {
                            content: '';
                        }

                        .read-more-btn {
                            color: #2563eb;
                            cursor: pointer;
                            font-weight: 600;
                            margin-left: 4px;
                            text-decoration: underline;
                        }

                        .no-comments {
                            text-align: center;
                            padding: 40px;
                            color: #6b7280;
                        }

                        .comment-reply-section {
                            margin-top: 15px;
                            padding-top: 15px;
                            border-top: 1px solid #e5e7eb;
                        }

                        .comment-reply {
                            background: #f3f4f6;
                            padding: 12px;
                            border-radius: 8px;
                            margin-top: 10px;
                            border-left: 3px solid #0b57d0;
                        }

                        .reply-admin-badge {
                            background: #0b57d0;
                            color: white;
                            padding: 2px 6px;
                            border-radius: 4px;
                            font-size: 11px;
                            font-weight: 600;
                            display: inline-block;
                            margin-right: 5px;
                        }

                        .reply-time {
                            color: #9ca3af;
                            font-size: 12px;
                        }

                        /* Styles for reported comments section */
                        .reports-section {
                            margin-top: 32px;
                            padding-top: 24px;
                            border-top: 2px solid #e5e7eb;
                        }

                        .reports-title {
                            font-size: 20px;
                            font-weight: 600;
                            color: #1f2937;
                            margin-bottom: 8px;
                        }

                        .reports-list {
                            display: grid;
                            gap: 16px;
                        }

                        .report-card {
                            border-radius: 18px;
                            border: 1px solid #dbeafe;
                            padding: 18px;
                            background: #ffffff;
                            box-shadow: 0 8px 22px rgba(15, 23, 42, 0.06);
                            margin-bottom: 16px;
                        }

                        .report-reason {
                            color: #ef4444;
                            font-weight: 600;
                        }

                        .report-time {
                            color: #6b7280;
                            font-size: 12px;
                        }

                        .report-details p {
                            margin: 4px 0;
                            color: #374151;
                        }

                        .report-actions {
                            margin-top: 12px;
                            display: flex;
                            gap: 8px;
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="header.jsp" />

                    <div class="comments-container">
                        <h1>Bình Luận Cho Sách ID: ${bookId}</h1>

                        <c:choose>
                            <c:when test="${not empty comments}">
                                <div class="comments-list">
                                    <c:forEach var="comment" items="${comments}">
                                        <div class="comment-card">
                                            <div class="comment-header">
                                                <div class="comment-user-info">
                                                    <div class="comment-avatar">
                                                        <c:choose>
                                                            <c:when
                                                                test="${not empty comment.avatar && comment.avatar != 'null'}">
                                                                <img src="${pageContext.request.contextPath}/${comment.avatar}"
                                                                    alt="${comment.fullName}"
                                                                    onerror="this.parentElement.innerText='${fn:substring(comment.fullName, 0, 1)}'">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <c:out
                                                                    value="${fn:substring(comment.fullName, 0, 1)}" />
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="comment-meta">
                                                        <span class="comment-user">${comment.fullName}</span>
                                                        <span class="comment-date">
                                                            <fmt:formatDate value="${comment.createdAt}" type="date"
                                                                dateStyle="medium" />
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

                                            <!-- Hiển thị phản hồi của thủ thư (nếu có) -->
                                            <c:if test="${comment.hasReply}">
                                                <div class="comment-reply-section">
                                                    <div
                                                        style="font-size: 13px; color: #374151; margin-bottom: 8px; font-weight: 500;">
                                                        <span class="reply-admin-badge">Phản hồi từ thủ thư</span>
                                                    </div>
                                                    <c:forEach var="reply" items="${comment.replies}">
                                                        <div class="comment-reply">
                                                            <div style="font-weight: 500; color: #1f2937;">
                                                                Quản lý thư viện
                                                                <span class="reply-time">•
                                                                    <fmt:formatDate value="${reply.createdAt}"
                                                                        type="both" dateStyle="medium"
                                                                        timeStyle="short" />
                                                                </span>
                                                            </div>
                                                            <p
                                                                style="margin: 8px 0 0 0; color: #4b5563; line-height: 1.5;">
                                                                ${reply.content}</p>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:if>
                                            <!-- Reply form for librarians -->
                                            <c:if test="${not empty sessionScope.currentUser && (fn:toUpperCase(sessionScope.currentUser.role.name) == 'LIBRARIAN' || fn:toUpperCase(sessionScope.currentUser.role.name) == 'ADMIN')}">
                                                <div class="reply-form"
                                                    style="margin-top: 10px; padding: 10px; border-top: 1px solid #e5e7eb;">
                                                    <form action="${pageContext.request.contextPath}/comment" method="POST">
                                                        <input type="hidden" name="action" value="reply">
                                                        <input type="hidden" name="commentId" value="${comment.commentId}">
                                                        <input type="hidden" name="bookId" value="${bookId}">
                                                        <textarea name="content" placeholder="Phản hồi của thủ thư..."
                                                            required
                                                            style="width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 4px;"></textarea>
                                                        <button type="submit"
                                                            style="margin-top: 5px; padding: 5px 10px; background: #3b82f6; color: white; border: none; border-radius: 4px;">Gửi phản hồi</button>
                                                    </form>
                                                </div>
                                            </c:if>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="no-comments">
                                    <p>Chưa có bình luận nào.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Reported comments section for librarian/admin -->
                        <c:set var="reportsBasePath"
                            value="${not empty reportsBasePath ? reportsBasePath : '/staff/reports'}" />
                        <c:if
                            test="${not empty sessionScope.currentUser && (fn:toUpperCase(sessionScope.currentUser.role.name) == 'LIBRARIAN' || fn:toUpperCase(sessionScope.currentUser.role.name) == 'ADMIN')}">
                            <div class="reports-section">
                                <h3 class="reports-title">Bình luận bị báo cáo</h3>
                                <p class="message-note">Các bình luận bị báo cáo cần được xem xét.</p>
                                <c:choose>
                                    <c:when test="${not empty bookReports}">
                                        <div class="reports-list">
                                            <c:forEach var="report" items="${bookReports}">
                                                <div class="report-card">
                                                    <div class="report-header">
                                                        <span class="report-reason"><strong>Lý do:</strong>
                                                            ${report.reason}</span>
                                                        <span class="report-time">
                                                            <fmt:formatDate value="${report.reportTime}" type="both"
                                                                dateStyle="short" timeStyle="short" />
                                                        </span>
                                                    </div>
                                                    <div class="report-details">
                                                        <p><strong>Người báo cáo:</strong> ${report.reporterFullName}</p>
                                                        <p><strong>Bình luận:</strong> ${report.commentContent}</p>
                                                        <p><strong>Người viết:</strong> ${report.commentUserFullName}</p>
                                                    </div>
                                                    <div class="report-actions">
                                                        <form method="post"
                                                            action="${pageContext.request.contextPath}${reportsBasePath}"
                                                            style="display: inline;">
                                                            <input type="hidden" name="action" value="resolve">
                                                            <input type="hidden" name="reportId" value="${report.reportId}">
                                                            <button type="submit" class="btn btn-success">Giải quyết</button>
                                                        </form>
                                                        <form method="post"
                                                            action="${pageContext.request.contextPath}${reportsBasePath}"
                                                            style="display: inline;">
                                                            <input type="hidden" name="action" value="ignore">
                                                            <input type="hidden" name="reportId" value="${report.reportId}">
                                                            <button type="submit" class="btn btn-secondary">Bỏ qua</button>
                                                        </form>
                                                        <form method="post"
                                                            action="${pageContext.request.contextPath}${reportsBasePath}"
                                                            style="display: inline;"
                                                            onsubmit="return confirm('Bạn có chắc muốn xóa bình luận này?')">
                                                            <input type="hidden" name="action" value="delete">
                                                            <input type="hidden" name="reportId" value="${report.reportId}">
                                                            <button type="submit" class="btn btn-danger">Xóa bình luận</button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <p>Không có bình luận bị báo cáo nào.</p>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>

                    <jsp:include page="footer.jsp" />
                </body>

                </html>