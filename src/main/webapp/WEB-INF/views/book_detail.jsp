<%@ page import="com.lbms.model.Comment" %>
<%@ page import="com.lbms.dao.CommentReplyDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>${book.title} - Book Details - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
    <style>
        .detail-page {
            max-width: 1000px;
            margin: 40px auto;
            padding: 0 20px;
        }

        .breadcrumb {
            margin-bottom: 20px;
            color: var(--text-muted);
            font-size: 14px;
        }

        .breadcrumb a {
            color: var(--primary-color);
            text-decoration: none;
        }

        .book-detail-card {
            display: flex;
            gap: 40px;
            background: white;
            border-radius: 12px;
            box-shadow: var(--shadow-lg);
            padding: 40px;
            border: 1px solid var(--border-color);
        }

        .book-visual {
            flex: 0 0 320px;
        }

        .detail-img-placeholder {
            width: 100%;
            height: 450px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 120px;
            color: #dee2e6;
            border: 1px solid var(--border-color);
        }

        .book-content {
            flex: 1;
            display: flex;
            flex-direction: column;
        }

        .badge-status {
            display: inline-block;
            padding: 6px 16px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            margin-bottom: 16px;
        }

        .badge-available {
            background: #dcfce7;
            color: #166534;
        }

        .badge-unavailable {
            background: #fee2e2;
            color: #991b1b;
        }

        .book-title {
            font-size: 36px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 12px;
            line-height: 1.2;
        }

        .book-author-name {
            font-size: 20px;
            color: var(--primary-color);
            margin-bottom: 24px;
            font-weight: 500;
        }

        .book-details-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 30px;
            padding: 24px;
            background: var(--light-bg);
            border-radius: 12px;
        }

        .detail-item {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }

        .detail-label {
            font-size: 12px;
            font-weight: 600;
            color: var(--text-muted);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .detail-value {
            font-size: 16px;
            color: var(--text-dark);
            font-weight: 500;
        }

        .book-description {
            color: var(--text-muted);
            line-height: 1.6;
            margin-bottom: 30px;
            font-size: 16px;
        }

        .action-footer {
            margin-top: auto;
            display: flex;
            gap: 16px;
            padding-top: 24px;
            border-top: 1px solid var(--border-color);
        }

        .action-footer .btn {
            padding: 12px 32px;
            font-size: 16px;
        }

        /* Comments Section Styles */
        .comments-section {
            max-width: 1000px;
            margin: 60px auto;
            padding: 0 20px;
        }

        .comments-title {
            font-size: 28px;
            font-weight: 800;
            color: var(--text-dark);
            margin-bottom: 30px;
        }

        .comment-form-wrapper {
            background: white;
            border-radius: 12px;
            padding: 24px;
            margin-bottom: 40px;
            box-shadow: var(--shadow-lg);
            border: 1px solid var(--border-color);
        }

        .comment-form-title {
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--text-dark);
        }

        .form-group {
            margin-bottom: 16px;
        }

        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: var(--text-dark);
        }

        .form-group textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            resize: vertical;
            min-height: 100px;
        }

        .form-group textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
        }

        .rating-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .rating-group label {
            margin: 0;
            font-weight: 600;
            color: var(--text-dark);
        }

        .star-rating {
            display: flex;
            gap: 12px;
            font-size: 24px;
        }

        .star-rating input {
            display: none;
        }

        .star-rating label {
            cursor: pointer;
            color: #ddd;
            transition: color 0.2s ease;
            margin: 0;
        }

        .star-rating label:hover {
            color: #fbbf24;
        }

        .star-rating input:checked + label {
            color: #fbbf24;
        }

        .form-actions {
            display: flex;
            gap: 12px;
            margin-top: 20px;
        }

        .form-actions .btn {
            padding: 10px 24px;
            font-size: 14px;
        }

        /* Comments List */
        .comments-list {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .comment-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: var(--shadow-md);
            border: 1px solid var(--border-color);
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
            background: linear-gradient(135deg, var(--primary-color), #60a5fa);
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
            color: var(--text-dark);
        }

        .comment-date {
            font-size: 12px;
            color: var(--text-muted);
        }

        .comment-actions {
            display: flex;
            gap: 12px;
        }

        .comment-actions a,
        .comment-actions button,
        .btn-action {
            font-size: 12px;
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            background: transparent;
            color: var(--primary-color);
            text-decoration: none;
            transition: background-color 0.2s;
        }

        .comment-actions a:hover,
        .comment-actions button:hover,
        .btn-action:hover {
            background-color: rgba(59, 130, 246, 0.1);
        }

        .btn-action.btn-danger {
            color: #d32f2f;
        }

        .btn-action.btn-danger:hover {
            background-color: rgba(211, 47, 47, 0.1);
        }

        .comment-rating {
            display: flex;
            gap: 4px;
            margin-bottom: 12px;
            font-size: 14px;
        }

        .star {
            color: #fbbf24;
        }

        .comment-content {
            color: var(--text-muted);
            line-height: 1.6;
            word-wrap: break-word;
        }

        .no-comments {
            text-align: center;
            padding: 40px;
            color: var(--text-muted);
        }

        .login-prompt {
            background: var(--light-bg);
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            margin-bottom: 40px;
        }

        .login-prompt a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .book-detail-card {
                flex-direction: column;
                padding: 20px;
            }

            .book-visual {
                flex: none;
                width: 100%;
            }

            .book-details-grid {
                grid-template-columns: 1fr;
            }

            .comment-header {
                flex-direction: column;
            }

            .comment-actions {
                margin-top: 12px;
            }
        }

        /* Modal star rating styles */
        .modal-star-group input[type="radio"]:checked + label {
            color: #fbbf24;
        }

        .modal-star-group label:hover,
        .modal-star-group label:hover ~ label {
            color: #fbbf24;
        }

        .modal-star-group input {
            display: none;
        }

        .modal-star-group label {
            cursor: pointer;
            color: #ddd;
            transition: color 0.2s;
        }

        .modal-star-group input:checked ~ label {
            color: #fbbf24;
        }

        .modal-star-group label:hover,
        .modal-star-group label:hover ~ label {
            color: #fbbf24;
        }

        .edit-star-group input {
            display: none;
        }

        .edit-star-group label {
            color: #d1d5db;
            cursor: pointer;
            transition: 0.2s;
        }

        .edit-star-group input:checked ~ label {
            color: #fbbf24;
        }

        .edit-star-group label:hover,
        .edit-star-group label:hover ~ label {
            color: #fbbf24;
        }

        @keyframes fadeIn {
            from {
                transform: scale(0.95);
                opacity: 0;
            }
            to {
                transform: scale(1);
                opacity: 1;
            }
        }
    </style>
</head>

<body>
<jsp:include page="header.jsp"/>

<div class="detail-page">
    <nav class="breadcrumb">
        <a href="${pageContext.request.contextPath}/books">
            <fmt:message key="catalog.title"/>
        </a> &nbsp;/&nbsp;
        <span>${book.title}</span>
    </nav>

    <div class="book-detail-card">
        <div class="book-visual">
            <div class="detail-img-placeholder">

            </div>
        </div>

        <div class="book-content">
            <div class="status-wrapper">
                <c:choose>
                    <c:when test="${book.quantity > 0}">
                                            <span class="badge-status badge-available">
                                                <fmt:message key="status.available"/>
                                            </span>
                    </c:when>
                    <c:otherwise>
                                            <span class="badge-status badge-unavailable">
                                                <fmt:message key="status.out_of_stock"/>
                                            </span>
                    </c:otherwise>
                </c:choose>
            </div>

            <h1 class="book-title">${book.title}</h1>
            <p class="book-author-name">
                <fmt:message key="book.by"/> ${book.author}
            </p>

            <div class="book-details-grid">
                <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.isbn"/>
                                        </span>
                    <span class="detail-value">${book.isbn}</span>
                </div>
                <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.publisher"/>
                                        </span>
                    <span class="detail-value">${not empty book.publisher ? book.publisher :
                            'Unknown'}</span>
                </div>
                <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.year"/>
                                        </span>
                    <span class="detail-value">${not empty book.publishYear ? book.publishYear :
                            'N/A'}</span>
                </div>
                <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.stock"/>
                                        </span>
                    <span class="detail-value">
                                            <fmt:message key="book.copies">
                                                <fmt:param value="${book.quantity}"/>
                                            </fmt:message>
                                        </span>
                </div>
            </div>

            <div class="book-description">
                <p>Explore the fascinating world of this book titled <strong>${book.title}</strong>
                    by
                    <strong>${book.author}</strong>. This resource is part of our extensive
                    collection,
                    provided to empower students and faculty with the knowledge they need for their
                    academic pursuits.
                </p>
            </div>

            <div class="action-footer">
                <!--                        Button add to cart-->
                <c:if test="${book.quantity > 0}">
                    <form action="${pageContext.request.contextPath}/cart/add" method="post">
                        <input type="hidden" name="bookId" value="${book.id}"/>
                        <input type="hidden" name="quantity" value="1"/>
                        <button type="submit" class="btn primary">
                            <fmt:message key="btn.add_to_cart"/>
                        </button>
                    </form>
                </c:if>
                <a href="${pageContext.request.contextPath}/books" class="btn">
                    <fmt:message key="book.back"/>
                </a>
            </div>
        </div>
    </div>
</div>

<!-- Phần Bình Luận -->
<div class="comments-section">
    <h2 class="comments-title">Bình Luận & Đánh Giá</h2>

    <!-- Biểu Mẫu Bình Luận (Chỉ Dành Cho Người Dùng Đã Đăng Nhập) -->
    <c:choose>
        <c:when test="${not empty sessionScope.currentUser}">
            <div class="comment-form-wrapper">
                <h3 class="comment-form-title">Chia Sẻ Suy Nghĩ Của Bạn</h3>
                <form action="${pageContext.request.contextPath}/comment" method="POST">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="bookId" value="${book.id}">

                    <div class="form-group">
                        <label for="content">Bình Luận Của Bạn</label>
                        <textarea id="content" name="content" required
                                  placeholder="Chia sẻ suy nghĩ của bạn về cuốn sách này..."></textarea>
                    </div>

                    <div class="form-group">
                        <div class="rating-group">
                            <label>Đánh Giá</label>
                            <div class="star-rating" id="ratingStars">
                                <input type="radio" id="star5" name="rating" value="5" required>
                                <label for="star5">★★★★★</label>

                                <input type="radio" id="star4" name="rating" value="4">
                                <label for="star4">★★★★☆</label>

                                <input type="radio" id="star3" name="rating" value="3">
                                <label for="star3">★★★☆☆</label>

                                <input type="radio" id="star2" name="rating" value="2">
                                <label for="star2">★★☆☆☆</label>

                                <input type="radio" id="star1" name="rating" value="1">
                                <label for="star1">★☆☆☆☆</label>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn primary">Gửi Bình Luận</button>
                    </div>
                </form>
            </div>
        </c:when>
        <c:otherwise>
            <div class="login-prompt">
                <p>Vui lòng <a href="${pageContext.request.contextPath}/auth/login">đăng nhập</a> để bình luận.</p>
            </div>
        </c:otherwise>
    </c:choose>

    <!-- Danh Sách Bình Luận -->
    <%
        List<Comment> comments = (List<com.lbms.model.Comment>) request.getAttribute("comments");
        if (comments == null) {
            try {
                com.lbms.dao.CommentDAO commentDAO = new com.lbms.dao.CommentDAO();
                comments = commentDAO.getCommentsByBook(Integer.parseInt(request.getParameter("id")));
            } catch (Exception e) {
                e.printStackTrace();
                comments = new java.util.ArrayList<>();
            }
        }

// Load replies cho TẤT CẢ trường hợp - đặt NGOÀI if
        try {
            com.lbms.dao.CommentReplyDAO replyDAO = new com.lbms.dao.CommentReplyDAO();
            for (com.lbms.model.Comment comment : comments) {
                java.util.List<com.lbms.model.CommentReply> replies = replyDAO.findByCommentId(comment.getCommentId());
                comment.setReplies(replies);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        request.setAttribute("comments", comments);
    %>

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
                                            <img src="${pageContext.request.contextPath}/${comment.avatar}"
                                                 alt="${comment.fullName}"
                                                 onerror="this.parentElement.innerText='${fn:substring(comment.fullName, 0, 1)}'">
                                        </c:when>
                                        <c:otherwise>
                                            <c:out value="${fn:substring(comment.fullName, 0, 1)}"/>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="comment-meta">
                                    <span class="comment-user">${comment.fullName}</span>
                                    <span class="comment-date">
                                    <fmt:formatDate value="${comment.createdAt}"
                                                    type="date"
                                                    dateStyle="medium"/>
                                </span>
                                </div>
                            </div>

                            <div class="comment-actions">
                                <c:if test="${sessionScope.currentUser.id == comment.userId
                                         || sessionScope.currentUser.role.name == 'ADMIN'
                                         || sessionScope.currentUser.role.name == 'LIBRARIAN'}">
                                    <button type="button"
                                            class="btn-action"
                                            data-id="${comment.commentId}"
                                            data-content="${fn:escapeXml(comment.content)}"
                                            data-rating="${comment.rating}"
                                            data-bookid="${book.id}"
                                            onclick="openEditForm(this)">
                                        Sửa
                                    </button>

                                    <button type="button"
                                            class="delete-btn"
                                            data-id="${comment.commentId}"
                                            data-book="${book.id}"
                                            onclick="openDeleteConfirm('${comment.commentId}', '${book.id}')">
                                        Xóa
                                    </button>
                                </c:if>
                            </div>
                        </div>

                        <div class="comment-rating">
                            <c:forEach begin="1" end="${comment.rating}">
                                <span class="star">★</span>
                            </c:forEach>
                        </div>

                        <p class="comment-content">${comment.content}</p>

                        <!-- Hiển thị phản hồi từ thủ thư (nếu có) -->
                        <c:if test="${not empty comment.replies}">
                            <div style="margin-top: 15px; padding-top: 15px; border-top: 1px solid #e5e7eb;">
                                <c:forEach var="reply" items="${comment.replies}">
                                    <div style="background: #f3f4f6; padding: 12px; border-radius: 8px; margin-top: 10px; border-left: 3px solid #0b57d0;">
                                        <div style="font-weight: 500; color: #1f2937;">
                                            <strong>Phản hồi từ thủ thư</strong>
                                            <span style="color: #9ca3af; font-size: 12px;">
                                        • <fmt:formatDate value="${reply.createdAt}" type="both" dateStyle="medium"
                                                          timeStyle="short"/>
                                    </span>
                                        </div>
                                        <p style="margin: 8px 0 0 0; color: #4b5563; line-height: 1.5;">${reply.content}</p>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>

            </div>
            <!-- comments-list -->
        </c:when>

        <c:otherwise>
            <div class="no-comments">
                <p>Chưa có bình luận nào. Hãy là người đầu tiên chia sẻ suy nghĩ của bạn!</p>
            </div>
        </c:otherwise>
    </c:choose>

</div> <!-- detail-page -->

<script>
    function openEditForm(button) {
        var commentId = button.dataset.id;
        var content = button.dataset.content;
        var rating = button.dataset.rating;
        var bookId = button.dataset.bookid;

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
            '<h2 style="margin:0 0 20px 0;font-size:22px;font-weight:700;color:#111827;">Chỉnh sửa bình luận</h2>' +
            '<form method="POST" action="${pageContext.request.contextPath}/comment">' +
            '<input type="hidden" name="action" value="update">' +
            '<input type="hidden" name="commentId" value="' + commentId + '">' +
            '<input type="hidden" name="bookId" value="' + bookId + '">' +
            '<textarea name="content" required style="width:100%;min-height:120px;padding:12px;border-radius:10px;border:1px solid #e5e7eb;font-size:14px;resize:none;outline:none;">' + content + '</textarea>' +
            '<div style="margin:20px 0 25px 0;">' +
            '<div class="edit-star-group" style="display:flex;flex-direction:row-reverse;justify-content:flex-end;gap:6px;font-size:30px;">' +
            '<input type="radio" id="edit5-' + commentId + '" name="rating" value="5"><label for="edit5-' + commentId + '">★</label>' +
            '<input type="radio" id="edit4-' + commentId + '" name="rating" value="4"><label for="edit4-' + commentId + '">★</label>' +
            '<input type="radio" id="edit3-' + commentId + '" name="rating" value="3"><label for="edit3-' + commentId + '">★</label>' +
            '<input type="radio" id="edit2-' + commentId + '" name="rating" value="2"><label for="edit2-' + commentId + '">★</label>' +
            '<input type="radio" id="edit1-' + commentId + '" name="rating" value="1"><label for="edit1-' + commentId + '">★</label>' +
            '</div>' +
            '</div>' +
            '<div style="display:flex;justify-content:flex-end;gap:12px;">' +
            '<button type="button" onclick="this.closest(\'.modal-overlay\').remove()" style="padding:10px 20px;border-radius:8px;border:1px solid #d1d5db;background:#f9fafb;cursor:pointer;font-weight:600;">Hủy</button>' +
            '<button type="submit" style="padding:10px 20px;border-radius:8px;border:none;background:#3b82f6;color:white;font-weight:600;cursor:pointer;">Lưu thay đổi</button>' +
            '</div>' +
            '</form>' +
            '</div>';

        document.body.appendChild(modal);

        var ratingInput = modal.querySelector('input[name="rating"][value="' + rating + '"]');
        if (ratingInput) ratingInput.checked = true;

        modal.addEventListener("click", function (e) {
            if (e.target === modal) modal.remove();
        });
    }

    function validateEditForm(form) {
        var content = form.querySelector('textarea[name="content"]').value.trim();
        var ratingChecked = form.querySelector('input[name="rating"]:checked');

        if (!content) {
            alert('Vui long nhap noi dung binh luan');
            return false;
        }
        if (!ratingChecked) {
            alert('Vui long chon danh gia');
            return false;
        }
        return true;
    }

    function closeEditForm(commentId) {
        var modal = document.getElementById('editModal-' + commentId);
        if (modal) modal.remove();
    }

    function openDeleteConfirm(commentId, bookId) {
        var overlay = document.createElement("div");
        overlay.style.position = "fixed";
        overlay.style.top = "0";
        overlay.style.left = "0";
        overlay.style.width = "100%";
        overlay.style.height = "100%";
        overlay.style.backgroundColor = "rgba(0,0,0,0.4)";
        overlay.style.display = "flex";
        overlay.style.justifyContent = "center";
        overlay.style.alignItems = "center";
        overlay.style.zIndex = "9999";

        overlay.innerHTML =
            '<div style="background:#fff;width:440px;border-radius:16px;padding:30px;box-shadow:0 20px 40px rgba(0,0,0,0.2);text-align:center;">' +
            '<h2 style="margin:0 0 12px 0;font-size:20px;font-weight:700;color:#111827;">Xác nhận xóa bình luận</h2>' +
            '<p style="color:#6b7280;margin-bottom:24px;">Bạn có chắc muốn xóa bình luận này không, khi đã xóa sẽ không thể hoàn tác.</p>' +
            '<div style="display:flex;justify-content:center;gap:12px;">' +
            '<button type="button" id="cancelDeleteBtn" style="padding:10px 20px;border-radius:8px;border:1px solid #d1d5db;background:#f9fafb;cursor:pointer;font-weight:600;">Hủy</button>' +
            '<form method="POST" action="${pageContext.request.contextPath}/comment" style="margin:0;">' +
            '<input type="hidden" name="action" value="delete">' +
            '<input type="hidden" name="commentId" value="' + commentId + '">' +
            '<input type="hidden" name="bookId" value="' + bookId + '">' +
            '<button type="submit" style="padding:10px 20px;border-radius:8px;border:none;background:#ef4444;color:white;font-weight:600;cursor:pointer;">Xóa</button>' +
            '</form>' +
            '</div>' +
            '</div>';

        document.body.appendChild(overlay);

        overlay.querySelector("#cancelDeleteBtn").onclick = function () {
            overlay.remove();
        };

        overlay.addEventListener("click", function (e) {
            if (e.target === overlay) overlay.remove();
        });
    }
</script>

<jsp:include page="footer.jsp"/>
</body>

</html>