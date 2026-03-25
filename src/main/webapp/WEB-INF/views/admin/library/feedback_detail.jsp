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
        .container-page {
            max-width: 800px;
            margin: 0 auto;
            width: 100%;
        }

        .back-link {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 24px;
            color: var(--panel-text-sub);
            text-decoration: none;
            font-weight: 500;
            font-size: .9rem;
            transition: color var(--panel-transition);
        }

        .back-link:hover {
            color: var(--panel-accent);
        }

        /* ── Modern Card UI ── */
        .report-section {
            background: var(--panel-card);
            border: 1px solid var(--panel-border);
            border-radius: var(--panel-radius);
            box-shadow: var(--panel-shadow);
            margin-bottom: 24px;
            overflow: hidden;
        }

        .report-section-header {
            padding: 16px 24px;
            border-bottom: 1px solid var(--panel-border);
            background: rgba(248, 250, 252, 0.5);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .report-section-title {
            font-size: 1.1rem;
            font-weight: 600;
            color: var(--panel-text);
            margin: 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .report-section-body {
            padding: 24px;
        }

        .info-grid {
            display: grid;
            gap: 20px;
            grid-template-columns: 1fr 1fr;
        }

        .info-group {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .info-label {
            font-size: .8rem;
            font-weight: 600;
            color: var(--panel-text-sub);
            text-transform: uppercase;
            letter-spacing: .05em;
        }

        .info-value {
            font-size: .95rem;
            color: var(--panel-text);
            font-weight: 500;
        }

        /* ── Comment Preview ── */
        .comment-preview {
            border-left: 3px solid #f59e0b;
            padding: 14px 20px;
            background: #fffbeb;
            border-radius: 0 8px 8px 0;
            font-size: .95rem;
            line-height: 1.6;
            color: var(--panel-text);
            margin-top: 10px;
        }

        .star {
            color: #f59e0b;
            font-size: 16px;
            margin-top: 4px;
        }

        /* ── Reply items ── */
        .reply {
            background: #f8fafc;
            padding: 16px 20px;
            border-radius: 8px;
            margin-bottom: 12px;
            border: 1px solid var(--panel-border);
        }

        .reply-author {
            font-weight: 600;
            font-size: 14px;
            color: var(--panel-text);
        }

        .reply-time {
            color: var(--panel-text-sub);
            font-size: 12px;
            margin-left: 6px;
        }

        .reply div:last-child {
            margin-top: 8px;
            line-height: 1.6;
            color: var(--panel-text);
        }

        /* ── Actions Row ── */
        .actions-row {
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 8px;
        }

        .btn-modern {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            padding: 10px 20px;
            border-radius: 8px;
            font-size: .9rem;
            font-weight: 500;
            cursor: pointer;
            border: none;
            transition: var(--panel-transition);
        }

        .btn-modern.primary {
            background: var(--panel-accent);
            color: white;
        }

        .btn-modern.primary:hover {
            box-shadow: 0 4px 12px rgba(99, 102, 241, 0.3);
            transform: translateY(-1px);
        }

        .btn-modern.danger {
            background: #ef4444;
            color: white;
        }

        .btn-modern.danger:hover {
            box-shadow: 0 4px 12px rgba(239, 68, 68, 0.3);
            transform: translateY(-1px);
        }

        .btn-modern.warning {
            background: #f59e0b;
            color: white;
        }

        .btn-modern.warning:hover {
            background: #d97706;
        }

        .btn-modern.sm {
            padding: 6px 14px;
            font-size: .85rem;
        }
        </style>

                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
</head>

                <body class="panel-body">
                    <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
                    <c:set var="defaultFeedbackBase"
                        value="${fn:startsWith(pageContext.request.servletPath, '/admin/') ? '/admin/feedback' : '/staff/feedback'}" />
                    <c:set var="feedbackBasePath"
                        value="${not empty feedbackBasePath ? feedbackBasePath : defaultFeedbackBase}" />

                    <main class="main-content">
                        <div class="container-page">
                            <a href="${pageContext.request.contextPath}${feedbackBasePath}?tab=feedback" class="back-link">
                                <i class="fas fa-arrow-left"></i> Quay lại danh sách phản hồi
                            </a>

                            <div class="pm-page-header">
                                <div>
                                    <h1 class="pm-title">
                                        Chi tiết phản hồi #${comment.commentId}
                                    </h1>
                                </div>
                            </div>

                            <!-- Section: Thông tin bình luận -->
                            <div class="report-section">
                                <div class="report-section-header">
                                    <h2 class="report-section-title">
                                        <i class="fas fa-info-circle" style="color: var(--panel-text-sub);"></i> Nội dung phản hồi
                                    </h2>
                                </div>
                                <div class="report-section-body">
                                    <div class="info-grid">
                                        <div class="info-group">
                                            <div class="info-label">Người gửi</div>
                                            <div class="info-value">
                                                <div class="pm-user">
                                                    <div class="pm-user-avatar"><i class="fas fa-user"></i></div>
                                                    <strong>${comment.fullName}</strong>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="info-group">
                                            <div class="info-label">Thời gian</div>
                                            <div class="info-value" style="display:flex; align-items:center; height:36px;">
                                                <i class="far fa-clock" style="margin-right:8px; color:var(--panel-text-sub);"></i>
                                                <fmt:formatDate value="${comment.createdAt}" pattern="HH:mm - dd/MM/yyyy" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="info-grid" style="margin-top: 20px;">
                                        <div class="info-group">
                                            <div class="info-value">
                                                ID: ${comment.bookId}
                                            </div>
                                        </div>
                                        <div class="info-group">
                                            <div class="info-label">Số sao</div>
                                            <div class="info-value">
                                                <div class="star">
                                                    <c:forEach begin="1" end="${comment.rating}">★</c:forEach>
                                                    <c:forEach begin="${comment.rating + 1}" end="5"><span style="color: #ddd;">★</span></c:forEach>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="comment-preview" style="margin-top: 24px;">
                                        ${comment.content}
                                    </div>
                                </div>
                            </div>

                            <!-- Section: Phản hồi từ thủ thư -->
                            <div class="report-section">
                                <div class="report-section-header">
                                    <h2 class="report-section-title">
                                        <i class="fas fa-reply" style="color: var(--panel-text-sub);"></i> Phản hồi từ quản trị
                                    </h2>
                                </div>
                                <div class="report-section-body">
                                    <c:choose>
                                        <c:when test="${not empty replies}">
                                            <c:forEach var="r" items="${replies}">
                                                <div class="reply">
                                                    <div class="reply-author">
                                                        <i class="fas fa-user-shield" style="margin-right:6px;color:var(--panel-accent);"></i>
                                                        ${r.adminName} (ID: ${r.adminId})
                                                        <span class="reply-time">
                                                            • 
                                                            <c:if test="${not empty r.createdAt}">
                                                                <fmt:formatDate value="${r.createdAt}" pattern="HH:mm - dd/MM/yyyy" />
                                                            </c:if>
                                                        </span>
                                                    </div>
                                                    <div>${r.content}</div>

                                                    <c:if test="${r.adminId == sessionScope.currentUser.id}">
                                                        <div class="actions-row" style="margin-top: 12px;">
                                                            <button class="btn-modern warning sm"
                                                                onclick="editReplyModal('${r.replyId}', '${comment.commentId}', '${fn:escapeXml(r.content)}')">
                                                                <i class="fas fa-pen"></i> Sửa
                                                            </button>
                                                            <form action="${pageContext.request.contextPath}${feedbackBasePath}"
                                                                method="post" onsubmit="return confirm('Bạn có chắc muốn xóa câu trả lời này?');">
                                                                <input type="hidden" name="action" value="deleteReply" />
                                                                <input type="hidden" name="replyId" value="${r.replyId}" />
                                                                <input type="hidden" name="commentId" value="${comment.commentId}" />
                                                                <button type="submit" class="btn-modern danger sm">
                                                                    <i class="fas fa-trash"></i> Xóa
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </c:if>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div style="color: var(--panel-text-sub); padding: 16px; background: #f8fafc; border-radius: 8px; border: 1px dashed var(--panel-border); text-align: center;">
                                                Chưa có phản hồi nào với đánh giá này.
                                            </div>
                                        </c:otherwise>
                                    </c:choose>

                                    <!-- Thêm phản hồi -->
                                    <div style="margin-top: 24px; padding-top: 24px; border-top: 1px solid var(--panel-border);">
                                        <h3 style="font-size: 1rem; font-weight: 600; margin: 0 0 12px 0;">Thêm câu trả lời</h3>
                                        <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post">
                                            <input type="hidden" name="action" value="reply" />
                                            <input type="hidden" name="commentId" value="${comment.commentId}" />
                                            <textarea name="replyContent" required placeholder="Viết câu trả lời của bạn ở đây. Nội dung này sẽ được công khai." class="pm-input" style="width: 100%; min-height: 100px; resize: vertical; margin-bottom: 12px;"></textarea>
                                            <div class="actions-row">
                                                <button type="submit" class="btn-modern primary">
                                                    <i class="fas fa-paper-plane"></i> Gửi phản hồi
                                                </button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>

                            <!-- Section: Hành động khác -->
                            <div class="report-section">
                                <div class="report-section-header">
                                    <h2 class="report-section-title">
                                        <i class="fas fa-cog" style="color: var(--panel-text-sub);"></i> Hành động khác
                                    </h2>
                                </div>
                                <div class="report-section-body">
                                    <form action="${pageContext.request.contextPath}${feedbackBasePath}" method="post"
                                        onsubmit="return confirm('Bạn có chắc chắn xóa phản hồi này hoàn toàn khỏi hệ thống?');">
                                        <input type="hidden" name="action" value="delete" />
                                        <input type="hidden" name="id" value="${comment.commentId}" />
                                        <button type="submit" class="btn-modern danger">
                                            <i class="fas fa-trash-alt"></i> Xóa vĩnh viễn đánh giá
                                        </button>
                                    </form>
                                </div>
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
                                    '<form method="POST" action="' + contextPath + '${feedbackBasePath}">' +
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

                                modal.addEventListener("click", function (e) {
                                    if (e.target === modal) modal.remove();
                                });
                            }
                        </script>

                        <jsp:include page="/WEB-INF/views/footer.jsp" />
                </body>

                </html>
