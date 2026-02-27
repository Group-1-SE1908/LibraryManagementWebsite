<%@ page import="com.lbms.model.Comment" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                <!DOCTYPE html>
                <html lang="en">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>${book.title} - Book Details - LBMS</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
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
                            gap: 12px;
                            align-items: center;
                        }

                        .rating-group label {
                            margin: 0;
                        }

                        .star-rating {
                            display: flex;
                            gap: 8px;
                            font-size: 24px;
                        }

                        .star-rating input {
                            display: none;
                        }

                        .star-rating label {
                            cursor: pointer;
                            color: #ddd;
                            transition: color 0.2s;
                        }

                        .star-rating label:hover,
                        .star-rating input:checked ~ label {
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
                        .comment-actions button {
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
                        .comment-actions button:hover {
                            background-color: rgba(59, 130, 246, 0.1);
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
                    </style>
                </head>

                <body>
                    <jsp:include page="header.jsp" />

                    <div class="detail-page">
                        <nav class="breadcrumb">
                            <a href="${pageContext.request.contextPath}/books">
                                <fmt:message key="catalog.title" />
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
                                                <fmt:message key="status.available" />
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge-status badge-unavailable">
                                                <fmt:message key="status.out_of_stock" />
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <h1 class="book-title">${book.title}</h1>
                                <p class="book-author-name">
                                    <fmt:message key="book.by" /> ${book.author}
                                </p>

                                <div class="book-details-grid">
                                    <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.isbn" />
                                        </span>
                                        <span class="detail-value">${book.isbn}</span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.publisher" />
                                        </span>
                                        <span class="detail-value">${not empty book.publisher ? book.publisher :
                                            'Unknown'}</span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.year" />
                                        </span>
                                        <span class="detail-value">${not empty book.publishYear ? book.publishYear :
                                            'N/A'}</span>
                                    </div>
                                    <div class="detail-item">
                                        <span class="detail-label">
                                            <fmt:message key="book.stock" />
                                        </span>
                                        <span class="detail-value">
                                            <fmt:message key="book.copies">
                                                <fmt:param value="${book.quantity}" />
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
                                            <input type="hidden" name="bookId" value="${book.id}" />
                                            <input type="hidden" name="quantity" value="1" />
                                            <button type="submit" class="btn primary">
                                                <fmt:message key="btn.add_to_cart" />
                                            </button>
                                        </form>
                                    </c:if>
                                    <a href="${pageContext.request.contextPath}/books" class="btn">
                                        <fmt:message key="book.back" />
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Comments Section -->
                    <div class="comments-section">
                        <h2 class="comments-title">Comments & Reviews</h2>

                        <!-- Comment Form (Only for logged-in users) -->
                        <c:choose>
                            <c:when test="${not empty sessionScope.currentUser}">
                                <div class="comment-form-wrapper">
                                    <h3 class="comment-form-title">Share Your Thoughts</h3>
                                    <form action="${pageContext.request.contextPath}/comment" method="POST">
                                        <input type="hidden" name="action" value="add">
                                        <input type="hidden" name="bookId" value="${book.id}">

                                        <div class="form-group">
                                            <label for="content">Your Comment</label>
                                            <textarea id="content" name="content" required placeholder="Share your thoughts about this book..."></textarea>
                                        </div>

                                        <div class="form-group">
                                            <div class="rating-group">
                                                <label>Rating</label>
                                                <div class="star-rating" id="ratingStars">
                                                    <input type="radio" id="star5" name="rating" value="5" required>
                                                    <label for="star5">★</label>

                                                    <input type="radio" id="star4" name="rating" value="4">
                                                    <label for="star4">★</label>

                                                    <input type="radio" id="star3" name="rating" value="3">
                                                    <label for="star3">★</label>

                                                    <input type="radio" id="star2" name="rating" value="2">
                                                    <label for="star2">★</label>

                                                    <input type="radio" id="star1" name="rating" value="1">
                                                    <label for="star1">★</label>
                                                </div>
                                            </div>
                                        </div>

                                        <div class="form-actions">
                                            <button type="submit" class="btn primary">Post Comment</button>
                                        </div>
                                    </form>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="login-prompt">
                                    <p>Please <a href="${pageContext.request.contextPath}/auth/login">log in</a> to leave a comment.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Comments List -->
                        <%
                            // Lấy comments từ request attribute nếu có, hoặc tạo mới từ DAO
                            List<Comment> comments = (List<com.lbms.model.Comment>) request.getAttribute("comments");
                            if (comments == null) {
                                try {
                                    com.lbms.dao.CommentDAO commentDAO = new com.lbms.dao.CommentDAO();
                                    comments = commentDAO.getCommentsByBook(Integer.parseInt(request.getParameter("id")));
                                } catch (Exception e) {
                                    comments = new java.util.ArrayList<>();
                                }
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
                                                <div class="comment-actions">
                                                    <c:if test="${sessionScope.currentUser.id == comment.userId || sessionScope.currentUser.role.name == 'ADMIN' || sessionScope.currentUser.role.name == 'LIBRARIAN'}">
                                                        <a href="javascript:void(0)" onclick="editComment(${comment.commentId}, '${fn:escapeXml(comment.content)}', ${comment.rating}, ${book.id})">Edit</a>
                                                        <a href="${pageContext.request.contextPath}/comment?action=delete&commentId=${comment.commentId}&bookId=${book.id}" onclick="return confirm('Are you sure?')">Delete</a>
                                                    </c:if>
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
                                    <p>No comments yet. Be the first to share your thoughts!</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <script>
                        function editComment(commentId, content, rating, bookId) {
                            const newContent = prompt('Edit your comment:', content);
                            if (newContent !== null && newContent.trim() !== '') {
                                const newRating = prompt('Update rating (1-5):', rating);
                                if (newRating !== null && newRating >= 1 && newRating <= 5) {
                                    const form = document.createElement('form');
                                    form.method = 'POST';
                                    form.action = '${pageContext.request.contextPath}/comment';
                                    
                                    form.innerHTML = 
                                        '<input type="hidden" name="action" value="update">' +
                                        '<input type="hidden" name="commentId" value="' + commentId + '">' +
                                        '<input type="hidden" name="content" value="' + newContent.replace(/"/g, '&quot;') + '">' +
                                        '<input type="hidden" name="rating" value="' + newRating + '">' +
                                        '<input type="hidden" name="bookId" value="' + bookId + '">';
                                    
                                    document.body.appendChild(form);
                                    form.submit();
                                }
                            }
                        }
                    </script>

                    <jsp:include page="footer.jsp" />
                </body>

                </html>