<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết phản hồi - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        body {
            display: flex;
            flex-direction: column;
            min-height: 100vh;
            background: #f5f6f8;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            color: #1f2937;
        }

        main {
            flex: 1;
        }

        .container-page {
            max-width: 860px;
            margin: 40px auto;
            padding: 0 20px;
            width: 100%;
        }

        .panel {
            background: #ffffff;
            padding: 28px;
            border-radius: 14px;
            box-shadow: 0 4px 18px rgba(0, 0, 0, 0.04);
        }

        h2 {
            margin-bottom: 10px;
            font-size: 22px;
            font-weight: 600;
        }

        h3 {
            margin-top: 30px;
            margin-bottom: 12px;
            font-size: 16px;
            font-weight: 600;
            border-top: 1px solid #ececec;
            padding-top: 18px;
        }

        .back-link {
            display: inline-block;
            margin-bottom: 20px;
            color: #374151;
            text-decoration: none;
            font-weight: 500;
            font-size: 14px;
        }

        .back-link:hover {
            text-decoration: underline;
        }

        .star {
            color: #f59e0b;
            font-size: 16px;
            margin-top: 4px;
        }

        .reply {
            background: #fafafa;
            padding: 14px 16px;
            border-radius: 10px;
            margin-top: 12px;
            border: 1px solid #eeeeee;
        }

        .reply-author {
            font-weight: 600;
            font-size: 14px;
        }

        .reply-time {
            color: #9ca3af;
            font-size: 12px;
            margin-left: 6px;
        }

        .reply div:last-child {
            margin-top: 6px;
            line-height: 1.6;
        }

        textarea {
            width: 100%;
            min-height: 110px;
            padding: 10px;
            border-radius: 8px;
            border: 1px solid #e5e7eb;
            font-size: 14px;
            resize: vertical;
            outline: none;
        }

        textarea:focus {
            border-color: #9ca3af;
        }

        .btn {
            background: #111827;
            color: white;
            padding: 8px 16px;
            border-radius: 8px;
            border: none;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: 0.2s;
        }

        .btn:hover {
            opacity: 0.9;
        }

        .btn-delete {
            background: #dc2626;
        }

        .btn-delete:hover {
            background: #b91c1c;
        }

        form {
            margin-top: 10px;
        }

        .reply-actions {
            margin-top: 8px;
            display: flex;
            gap: 8px;
        }

        .reply-actions .btn {
            padding: 5px 12px;
            font-size: 12px;
        }

    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

<main class="main-content">
    <div class="container-page">
        <a href="${pageContext.request.contextPath}/admin/feedback?action=list" class="back-link">← Quay lại danh
            sách</a>

        <div class="panel">
            <h2>Phản hồi #${comment.commentId}</h2>
            <div style="color: #374151; margin-bottom: 10px;">
                <strong>Người gửi:</strong> ${comment.fullName}
                <br/>
                <strong>Sách:</strong> ${not empty book ? book.title : 'N/A'} (ID: ${comment.bookId})
                <br/>
                <!-- Hiển thị rating sao -->
                <strong>Đánh giá:</strong>
                <div class="star">
                    <c:forEach begin="1" end="${comment.rating}">★</c:forEach>
                    <c:forEach begin="${comment.rating + 1}" end="5"><span style="color: #ddd;">★</span></c:forEach>
                </div>
            </div>

            <div style="margin-top: 12px; font-size: 16px; color: #111827; line-height: 1.6;">
                ${comment.content}
            </div>
            <div style="margin-top: 8px; color: #6b7280; font-size: 13px;">
                Ngày: <fmt:formatDate value="${comment.createdAt}" type="both" dateStyle="medium" timeStyle="short"/>
            </div>

            <h3 style="margin-top: 25px; border-top: 1px solid #f1f5f9; padding-top: 15px;">Phản hồi từ thủ thư</h3>
            <c:choose>
                <c:when test="${not empty replies}">
                    <c:forEach var="r" items="${replies}">
                        <div class="reply" style="position: relative;">
                            <div class="reply-author">${r.adminName} (ID: ${r.adminId}) <span class="reply-time">
    •
    <c:if test="${not empty r.createdAt}">
        <fmt:formatDate value="${r.createdAt}"
                        type="both"
                        dateStyle="medium"
                        timeStyle="short"/>
    </c:if>
</span></div>
                            <div style="margin-top: 6px; color: #111827;">${r.content}</div>

                            <!-- Action buttons (nếu là reply của user hiện tại) -->
                            <c:if test="${r.adminId == sessionScope.currentUser.id}">
                                <div style="margin-top: 8px; display: flex; gap: 8px;">
                                    <button class="btn" style="background: #f59e0b; padding: 6px 12px; font-size: 12px;"
                                            onclick="editReplyModal('${r.replyId}', '${comment.commentId}', '${fn:escapeXml(r.content)}')">
                                        Sửa
                                    </button>
                                    <form action="${pageContext.request.contextPath}/admin/feedback" method="post" style="display: inline;"
                                          onsubmit="return confirm('Xóa reply này?');">
                                        <input type="hidden" name="action" value="deleteReply" />
                                        <input type="hidden" name="replyId" value="${r.replyId}" />
                                        <input type="hidden" name="commentId" value="${comment.commentId}" />
                                        <button type="submit" class="btn" style="background: #ef4444; padding: 6px 12px; font-size: 12px;">Xóa</button>
                                    </form>
                                </div>
                            </c:if>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div style="color: #9ca3af; padding: 15px; background: #f8fafc; border-radius: 6px;">
                        Chưa có phản hồi từ thủ thư.
                    </div>
                </c:otherwise>
            </c:choose>

            <h3 style="margin-top: 20px;">Gửi phản hồi</h3>
            <form action="${pageContext.request.contextPath}/admin/feedback" method="post">
                <input type="hidden" name="action" value="reply"/>
                <input type="hidden" name="commentId" value="${comment.commentId}"/>
                <textarea name="replyContent" required placeholder="Viết câu trả lời ở đây..."
                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 6px; min-height: 100px;"></textarea>
                <div style="margin-top: 12px;">
                    <button type="submit" class="btn">Gửi phản hồi</button>
                </div>
            </form>

            <h3 style="margin-top: 20px;">Hành động khác</h3>
            <form action="${pageContext.request.contextPath}/admin/feedback" method="post"
                  onsubmit="return confirm('Xác nhận xóa phản hồi này?');" style="display: inline;">
                <input type="hidden" name="action" value="delete"/>
                <input type="hidden" name="id" value="${comment.commentId}"/>
                <button type="submit" class="btn btn-delete">Xóa phản hồi</button>
            </form>
        </div>
    </div>
</main>

<%-- Khai báo biến JS ở đầu trang, ngoài function --%>
<script>
    var contextPath = "${pageContext.request.contextPath}";

    function editReplyModal(replyId, commentId, content) {
        var modal = document.createElement('div');
        modal.className = "modal-overlay";
        modal.style.position = "fixed";
        modal.style.top = "0";
        modal.style.left = "0";
        modal.style.width = "100%";
        modal.style.height = "100%";
        modal.style.backgroundColor = "rgba(0,0,0,0.4)";
        modal.style.display = "flex";
        modal.style.justifyContent = "center";
        modal.style.alignItems = "center";
        modal.style.zIndex = "9999";

        modal.innerHTML =
            '<div style="background:#fff;width:520px;border-radius:16px;padding:30px;box-shadow:0 20px 40px rgba(0,0,0,0.2);position:relative;">' +
            '<h2 style="margin:0 0 20px 0;font-size:22px;font-weight:700;color:#111827;">Chỉnh sửa phản hồi</h2>' +
            '<form method="POST" action="' + contextPath + '/admin/feedback">' +
            '<input type="hidden" name="action" value="editReply">' +
            '<input type="hidden" name="replyId" value="' + replyId + '">' +
            '<input type="hidden" name="commentId" value="' + commentId + '">' +
            '<textarea name="replyContent" required style="width:100%;min-height:120px;padding:12px;border-radius:10px;border:1px solid #e5e7eb;font-size:14px;resize:none;outline:none;">' + content + '</textarea>' +
            '<div style="display:flex;justify-content:flex-end;gap:12px;margin-top:20px;">' +
            '<button type="button" onclick="this.closest(\'.modal-overlay\').remove()" style="padding:10px 20px;border-radius:8px;border:1px solid #d1d5db;background:#f9fafb;cursor:pointer;font-weight:600;">Hủy</button>' +
            '<button type="submit" style="padding:10px 20px;border-radius:8px;border:none;background:#f59e0b;color:white;font-weight:600;cursor:pointer;">Lưu thay đổi</button>' +
            '</div>' +
            '</form>' +
            '</div>';

        document.body.appendChild(modal);

        modal.addEventListener("click", function(e) {
            if (e.target === modal) modal.remove();
        });
    }
</script>

<jsp:include page="/WEB-INF/views/footer.jsp"/>
</body>
</html>
