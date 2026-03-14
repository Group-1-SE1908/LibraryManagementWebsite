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
                                    <meta charset="UTF-8" />
                                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                                    <title>${book.title} - Book Details - LBMS</title>
                                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                                </head>

                                <body>

                                    <jsp:include page="header.jsp" />

                                                                        <main class="detail-page">
                                        <nav class="breadcrumb">
                                            <a href="${pageContext.request.contextPath}/books">Danh mục sách</a>
                                            <span class="breadcrumb-separator">/</span>
                                            <span>${book.title}</span>
                                        </nav>

                                        <section class="book-hero"
                                                 data-average="${averageRating}"
                                                 data-count="${ratingCount}">
                                            <div class="book-hero__visual">
                                                <c:choose>
                                                    <c:when test="${not empty book.image}">
                                                        <img src="${pageContext.request.contextPath}/${book.image}"
                                                             alt="${book.title}" loading="lazy" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="book-hero__placeholder">
                                                            <span>📚</span>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="book-hero__info">
                                                <div class="book-status">
                                                    <c:choose>
                                                        <c:when test="${book.quantity > 0}">
                                                            <span class="book-status-pill book-status-pill--available">
                                                                <fmt:message key="status.available" />
                                                            </span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="book-status-pill book-status-pill--out">
                                                                <fmt:message key="status.out_of_stock" />
                                                            </span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                    <div class="book-hero__rating" id="bookRatingDisplay">
                                                        <span class="book-hero__rating-value" id="bookRatingValue"></span>
                                                        <span class="book-hero__rating-count" id="bookRatingCount"></span>
                                                    </div>
                                                </div>

                                                <h1 class="book-title">${book.title}</h1>
                                                <p class="book-author-name">
                                                    <fmt:message key="book.by" /> ${book.author}
                                                </p>

                                                <div class="book-meta-chips">
                                                    <c:if test="${not empty book.category}">
                                                        <span class="book-meta-chip">${book.category.name}</span>
                                                    </c:if>
                                                    <span class="book-meta-chip">
                                                        <fmt:message key="book.year" />:
                                                        ${not empty book.publishYear ? book.publishYear : 'N/A'}
                                                    </span>
                                                </div>

                                                <p class="book-highlight">
                                                    Discover this edition of <strong>${book.title}</strong> – a thoughtful
                                                    resource from our collection that brings new insights to readers who
                                                    crave knowledge.
                                                </p>

                                                <div class="detail-actions">
                                                    <c:if test="${book.quantity > 0}">
                                                        <form action="${pageContext.request.contextPath}/cart/add" method="post">
                                                            <input type="hidden" name="bookId" value="${book.id}" />
                                                            <input type="hidden" name="quantity" value="1" />
                                                            <button type="submit" class="btn primary">
                                                                <fmt:message key="btn.add_to_cart" />
                                                            </button>
                                                        </form>
                                                    </c:if>

                                                    <c:if test="${book.quantity <= 0}">
                                                        <c:choose>
                                                            <c:when test="${hasReserved}">
                                                                <p class="reservation-status">
                                                                    Bạn đã đặt trước cuốn sách này rồi.
                                                                </p>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <form action="${pageContext.request.contextPath}/reservation"
                                                                      method="post">
                                                                    <input type="hidden" name="action" value="add" />
                                                                    <input type="hidden" name="bookId" value="${book.id}" />
                                                                    <button type="submit" class="btn secondary">
                                                                        Đặt trước
                                                                    </button>
                                                                </form>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </c:if>
                                                </div>
                                            </div>
                                        </section>

                                        <section class="book-meta-panel">
                                            <article class="book-meta-card">
                                                <span class="book-meta-card__label">
                                                    <fmt:message key="book.isbn" />
                                                </span>
                                                <span class="book-meta-card__value">${book.isbn}</span>
                                            </article>
                                            <article class="book-meta-card">
                                                <span class="book-meta-card__label">
                                                    <fmt:message key="book.publisher" />
                                                </span>
                                                <span class="book-meta-card__value">
                                                    ${not empty book.publisher ? book.publisher : 'Unknown'}
                                                </span>
                                            </article>
                                            <article class="book-meta-card">
                                                <span class="book-meta-card__label">
                                                    <fmt:message key="book.year" />
                                                </span>
                                                <span class="book-meta-card__value">
                                                    ${not empty book.publishYear ? book.publishYear : 'N/A'}
                                                </span>
                                            </article>
                                            <article class="book-meta-card">
                                                <span class="book-meta-card__label">
                                                    <fmt:message key="book.stock" />
                                                </span>
                                                <span class="book-meta-card__value">
                                                    <fmt:message key="book.copies">
                                                        <fmt:param value="${book.quantity}" />
                                                    </fmt:message>
                                                </span>
                                            </article>
                                            <article class="book-meta-card">
                                                <span class="book-meta-card__label">Thể loại</span>
                                                <span class="book-meta-card__value">
                                                    ${not empty book.category ? book.category.name : 'Chưa phân loại'}
                                                </span>
                                            </article>
                                        </section>

                                        <section class="book-description-card">
                                            <h2 class="book-description-title">Giới thiệu</h2>
                                            <p>
                                                Explore the fascinating world of this book titled
                                                <strong>${book.title}</strong>
                                                by <strong>${book.author}</strong>. This resource is part of our
                                                extensive collection, provided to empower students and faculty with
                                                the knowledge they need for their academic pursuits.
                                            </p>
                                        </section>
                                    </main>


                                    <section class="comments-section">
                                        <div class="comments-section__header">
                                            <h2 class="comments-title">Bình Luận & Đánh Giá</h2>
                                            <p class="message-note">Cảm nhận của bạn sẽ giúp cộng đồng chọn sách phù hợp hơn.</p>
                                        </div>

                                        <c:choose>
                                            <c:when test="${not empty sessionScope.currentUser}">
                                                <c:choose>
                                                    <c:when test="${not hasCommented}">
                                                        <div class="comment-form-wrapper">
                                                            <h3 class="comment-form-title">Chia sẻ suy nghĩ của bạn</h3>
                                                            <form action="${pageContext.request.contextPath}/comment" method="POST">
                                                                <input type="hidden" name="action" value="add">
                                                                <input type="hidden" name="bookId" value="${book.id}">

                                                                <div class="form-group">
                                                                    <label for="content">Bình luận của bạn</label>
                                                                    <textarea id="content" name="content" required placeholder="Chia sẻ suy nghĩ của bạn về cuốn sách này..."></textarea>
                                                                </div>

                                                                <div class="form-group rating-group">
                                                                    <label>Đánh giá</label>
                                                                    <div class="star-rating" role="radiogroup">
                                                                        <input type="radio" id="rate1" name="rating" value="1" required>
                                                                        <label for="rate1" aria-label="1 sao">★</label>
                                                                        <input type="radio" id="rate2" name="rating" value="2">
                                                                        <label for="rate2" aria-label="2 sao">★</label>
                                                                        <input type="radio" id="rate3" name="rating" value="3">
                                                                        <label for="rate3" aria-label="3 sao">★</label>
                                                                        <input type="radio" id="rate4" name="rating" value="4">
                                                                        <label for="rate4" aria-label="4 sao">★</label>
                                                                        <input type="radio" id="rate5" name="rating" value="5">
                                                                        <label for="rate5" aria-label="5 sao">★</label>
                                                                    </div>
                                                                </div>

                                                                <div class="form-actions">
                                                                    <button type="submit" class="btn primary">Gửi bình luận</button>
                                                                </div>
                                                            </form>
                                                        </div>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="comment-form-wrapper">
                                                            <p class="already-commented">Bạn đã đánh giá và bình luận cho cuốn sách này rồi!</p>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="login-prompt">
                                                    <p>Vui lòng
                                                        <a href="${pageContext.request.contextPath}/auth/login">đăng nhập</a>
                                                        để bình luận.
                                                    </p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>

                                        <%-- Load comments --%>
                                            <% List<Comment> comments = (List<com.lbms.model.Comment>)
                                                    request.getAttribute("comments");
                                                if (comments == null) {
                                                    try {
                                                        com.lbms.dao.CommentDAO commentDAO = new com.lbms.dao.CommentDAO();
                                                        comments =
                                                            commentDAO.getCommentsByBook(Integer.parseInt(request.getParameter("id")));
                                                    } catch (Exception e) {
                                                        e.printStackTrace();
                                                        comments = new java.util.ArrayList<>();
                                                    }
                                                }
                                                try {
                                                    com.lbms.dao.CommentReplyDAO replyDAO = new com.lbms.dao.CommentReplyDAO();
                                                    for (com.lbms.model.Comment comment : comments) {
                                                        java.util.List<com.lbms.model.CommentReply> replies =
                                                            replyDAO.findByCommentId(comment.getCommentId());
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
                                                        <article class="comment-card">
                                                            <header class="comment-header">
                                                                <div class="comment-user-info">
                                                                    <div class="comment-avatar">
                                                                        <c:choose>
                                                                            <c:when test="${not empty comment.avatar && comment.avatar != 'null'}">
                                                                                <img src="${pageContext.request.contextPath}/${comment.avatar}"
                                                                                     alt="${comment.fullName}"
                                                                                     onerror="this.parentElement.innerText='${fn:substring(comment.fullName, 0, 1)}'">
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <c:out value="${fn:substring(comment.fullName, 0, 1)}" />
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </div>
                                                                    <div class="comment-meta">
                                                                        <span class="comment-user">${comment.fullName}</span>
                                                                        <span class="comment-date">
                                                                            <fmt:formatDate value="${comment.createdAt}" type="date" dateStyle="medium" />
                                                                        </span>
                                                                    </div>
                                                                </div>
                                                                <div class="comment-actions">
                                                                    <c:if test="${sessionScope.currentUser.id == comment.userId
                                                                            || sessionScope.currentUser.role.name == 'ADMIN'
                                                                            || sessionScope.currentUser.role.name == 'LIBRARIAN'}">
                                                                        <button type="button" class="btn ghost btn-action"
                                                                                data-id="${comment.commentId}"
                                                                                data-content="${fn:escapeXml(comment.content)}"
                                                                                data-rating="${comment.rating}"
                                                                                data-bookid="${book.id}"
                                                                                onclick="openEditForm(this)">
                                                                            Sửa
                                                                        </button>
                                                                        <button type="button" class="btn ghost btn-action btn-danger"
                                                                                onclick="openDeleteConfirm('${comment.commentId}', '${book.id}')">
                                                                            Xóa
                                                                        </button>
                                                                    </c:if>
                                                                </div>
                                                            </header>

                                                            <div class="comment-rating">
                                                                <c:forEach begin="1" end="${comment.rating}">
                                                                    <span class="star">★</span>
                                                                </c:forEach>
                                                            </div>

                                                            <p class="comment-content">
                                                                ${comment.content}
                                                            </p>

                                                            <c:if test="${not empty comment.replies}">
                                                                <div class="reply-thread">
                                                                    <c:forEach var="reply" items="${comment.replies}">
                                                                        <div class="reply-card">
                                                                            <div class="reply-card__header">
                                                                                <strong>Phản hồi từ thủ thư</strong>
                                                                                <span class="comment-date">
                                                                                    &bull;
                                                                                    <fmt:formatDate value="${reply.createdAt}"
                                                                                                     type="both"
                                                                                                     dateStyle="medium"
                                                                                                     timeStyle="short" />
                                                                                </span>
                                                                            </div>
                                                                            <p class="reply-card__body">${reply.content}</p>
                                                                        </div>
                                                                    </c:forEach>
                                                                </div>
                                                            </c:if>
                                                        </article>
                                                    </c:forEach>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="no-comments">
                                                    <p>Chưa có bình luận nào. Hãy là người đầu tiên chia sẻ suy nghĩ của bạn!</p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </section>

                                    <script>
                                        function openEditForm(button) {
                                            var commentId = button.dataset.id;
                                            var content = button.dataset.content;
                                            var rating = button.dataset.rating;
                                            var bookId = button.dataset.bookid;

                                            var modal = document.createElement('div');
                                            modal.className = 'modal-overlay';

                                            modal.innerHTML =
                                                '<div class="modal-panel">' +
                                                    '<h2>Chỉnh sửa bình luận</h2>' +
                                                    '<form method="POST" action="${pageContext.request.contextPath}/comment">' +
                                                        '<input type="hidden" name="action" value="update">' +
                                                        '<input type="hidden" name="commentId" value="' + commentId + '">' +
                                                        '<input type="hidden" name="bookId" value="' + bookId + '">' +
                                                        '<textarea name="content" required class="modal-textarea">' + content + '</textarea>' +
                                                        '<div class="rating-group modal-rating">' +
                                                            '<label>Đánh giá</label>' +
                                                            '<div class="star-rating edit-star-group">' +
                                                                '<input type="radio" id="edit1-' + commentId + '" name="rating" value="1">' +
                                                                '<label for="edit1-' + commentId + '">★</label>' +
                                                                '<input type="radio" id="edit2-' + commentId + '" name="rating" value="2">' +
                                                                '<label for="edit2-' + commentId + '">★</label>' +
                                                                '<input type="radio" id="edit3-' + commentId + '" name="rating" value="3">' +
                                                                '<label for="edit3-' + commentId + '">★</label>' +
                                                                '<input type="radio" id="edit4-' + commentId + '" name="rating" value="4">' +
                                                                '<label for="edit4-' + commentId + '">★</label>' +
                                                                '<input type="radio" id="edit5-' + commentId + '" name="rating" value="5">' +
                                                                '<label for="edit5-' + commentId + '">★</label>' +
                                                            '</div>' +
                                                        '</div>' +
                                                        '<div class="modal-actions">' +
                                                            '<button type="button" class="btn secondary" onclick="this.closest(\'.modal-overlay\').remove()">Hủy</button>' +
                                                            '<button type="submit" class="btn primary">Lưu thay đổi</button>' +
                                                        '</div>' +
                                                    '</form>' +
                                                '</div>';

                                            document.body.appendChild(modal);

                                            var ratingInput = modal.querySelector('input[name="rating"][value="' + rating + '"]');
                                            if (ratingInput) {
                                                ratingInput.checked = true;
                                            }

                                            modal.addEventListener('click', function (e) {
                                                if (e.target === modal) modal.remove();
                                            });
                                        }

                                        function openDeleteConfirm(commentId, bookId) {
                                            var overlay = document.createElement('div');
                                            overlay.className = 'modal-overlay';

                                            overlay.innerHTML =
                                                '<div class="modal-panel">' +
                                                    '<h2>Xác nhận xóa bình luận</h2>' +
                                                    '<p>Bạn có chắc muốn xóa bình luận này không?</p>' +
                                                    '<div class="modal-actions">' +
                                                        '<button type="button" class="btn secondary" id="cancelDeleteBtn">Hủy</button>' +
                                                        '<form method="POST" action="${pageContext.request.contextPath}/comment" class="modal-inline-form">' +
                                                            '<input type="hidden" name="action" value="delete">' +
                                                            '<input type="hidden" name="commentId" value="' + commentId + '">' +
                                                            '<input type="hidden" name="bookId" value="' + bookId + '">' +
                                                            '<button type="submit" class="btn danger">Xóa</button>' +
                                                        '</form>' +
                                                    '</div>' +
                                                '</div>';

                                            document.body.appendChild(overlay);

                                            overlay.querySelector('#cancelDeleteBtn').onclick = function () { overlay.remove(); };
                                            overlay.addEventListener('click', function (e) {
                                                if (e.target === overlay) overlay.remove();
                                            });
                                        }
                                    </script>

                                    <script>
                                        document.addEventListener('DOMContentLoaded', function() {
                                            const hero = document.querySelector('.book-hero');
                                            const ratingValue = document.getElementById('bookRatingValue');
                                            const ratingCountEl = document.getElementById('bookRatingCount');

                                            if (!hero || !ratingValue) return;

                                            const averageRating = parseFloat(hero.dataset.average) || 0;
                                            const ratingCount = parseInt(hero.dataset.count || '0', 10) || 0;

                                            if (ratingCount > 0) {
                                                ratingValue.textContent = averageRating.toFixed(1) + ' ★';
                                                if (ratingCountEl) {
                                                    ratingCountEl.textContent = '(' + ratingCount + ' lượt đánh giá)';
                                                }
                                            } else {
                                                ratingValue.textContent = 'Chưa có lượt đánh giá';
                                                if (ratingCountEl) {
                                                    ratingCountEl.textContent = '';
                                                }
                                            }
                                        });
                                    </script>

<jsp:include page="footer.jsp" />
                                </body>

                                </html>
