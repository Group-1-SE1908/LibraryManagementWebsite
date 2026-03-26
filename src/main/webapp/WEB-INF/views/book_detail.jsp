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

                                    <script>
                                        function showAlert(title, message) {
                                            // Wait for DOM to load
                                            if (document.readyState === 'loading') {
                                                document.addEventListener('DOMContentLoaded', function () {
                                                    showAlertModal(title, message);
                                                });
                                            } else {
                                                showAlertModal(title, message);
                                            }
                                        }

                                        function showAlertModal(title, message) {
                                            document.getElementById('alertTitle').textContent = title;
                                            document.getElementById('alertMessage').textContent = message;
                                            document.getElementById('alertModal').style.display = 'grid';
                                        }

                                        function closeAlertModal() {
                                            document.getElementById('alertModal').style.display = 'none';
                                        }
                                    </script>

                                    <% String message=(String) session.getAttribute("message"); if (message !=null) {
                                        session.removeAttribute("message"); %>
                                        <script>
                                            showAlert('Thông báo', '<%= message %>');
                                        </script>
                                        <% } %>

                                            <c:set var="booksBasePath"
                                                value="${not empty booksBasePath ? booksBasePath : '/books'}" />
                                            <c:set var="opsDetailView"
                                                value="${booksBasePath == '/staff/books' || booksBasePath == '/admin/books'}" />

                                            <c:choose>
                                                <c:when test="${opsDetailView}">
                                                    <jsp:include
                                                        page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
                                                    <style>
                                                        @media (min-width: 1025px) {
                                                            .detail-page {
                                                                margin-left: 280px;
                                                            }
                                                        }
                                                    </style>
                                                </c:when>
                                                <c:otherwise>
                                                    <jsp:include page="header.jsp" />
                                                </c:otherwise>
                                            </c:choose>

                                            <main class="detail-page">
                                                <nav class="breadcrumb">
                                                    <a href="${pageContext.request.contextPath}${booksBasePath}">Danh
                                                        mục sách</a>
                                                    <span class="breadcrumb-separator">/</span>
                                                    <span>${book.title}</span>
                                                </nav>

                                                <section class="book-hero" data-average="${averageRating}"
                                                    data-count="${ratingCount}">
                                                    <div class="book-hero__visual">
                                                        <c:choose>
                                                            <c:when test="${not empty book.image}">
                                                                <c:choose>
                                                                    <c:when test="${fn:startsWith(book.image, 'http')}">
                                                                        <img src="${book.image}" alt="${book.title}"
                                                                            loading="lazy" />
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <img src="${pageContext.request.contextPath}/${book.image}"
                                                                            alt="${book.title}" loading="lazy" />
                                                                    </c:otherwise>
                                                                </c:choose>
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
                                                                    <span
                                                                        class="book-status-pill book-status-pill--available">
                                                                        <fmt:message key="status.available" />
                                                                    </span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span
                                                                        class="book-status-pill book-status-pill--out">
                                                                        <fmt:message key="status.out_of_stock" />
                                                                    </span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                             <div class="book-hero__rating" id="bookRatingDisplay">
                                                                <style>
                                                                    .book-hero__rating {
                                                                        display: flex !important;
                                                                        align-items: center;
                                                                        gap: 8px;
                                                                    }
                                                                    .comment-rating {
                                                                        display: flex;
                                                                        gap: 2px;
                                                                        font-size: 18px;
                                                                        line-height: 1;
                                                                    }
                                                                    .book-hero__rating-value {
                                                                        font-size: 20px !important;
                                                                        font-weight: 700;
                                                                    }
                                                                    .book-hero__rating-count {
                                                                        font-size: 14px !important;
                                                                        margin-left: 4px;
                                                                    }
                                                                </style>
                                                                <c:choose>
                                                                    <c:when test="${ratingCount > 0}">
                                                                        <div class="comment-rating">
                                                                            <c:forEach begin="1" end="5" var="i">
                                                                                <span class="star"
                                                                                    style="color: ${averageRating > (i - 1) ? '#f59e0b' : '#cbd5e1'};">★</span>
                                                                            </c:forEach>
                                                                        </div>
                                                                        <span class="book-hero__rating-value"
                                                                            id="bookRatingValue">
                                                                            <fmt:formatNumber value="${averageRating}"
                                                                                maxFractionDigits="1"
                                                                                minFractionDigits="1" />
                                                                        </span>
                                                                        <span class="book-hero__rating-count"
                                                                            id="bookRatingCount">
                                                                            (${ratingCount} <fmt:message
                                                                                key="book.reviews" />)
                                                                        </span>
                                                                    </c:when>
                                                                    <c:otherwise>
                                                                        <span class="book-hero__rating-count">
                                                                            <fmt:message key="book.no_reviews" />
                                                                        </span>
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>

                                                        <h1 class="book-title">${book.title}</h1>
                                                        <p class="book-author-name">
                                                            <fmt:message key="book.by" /> ${book.author}
                                                        </p>

                                                        <div class="book-meta-chips">
                                                            <c:if test="${not empty book.category}">
                                                                <span
                                                                    class="book-meta-chip">${book.category.name}</span>
                                                            </c:if>
                                                            <span class="book-meta-chip">
                                                                <fmt:message key="book.year" />:
                                                                ${not empty book.publishYear ? book.publishYear : 'N/A'}
                                                            </span>
                                                        </div>

                                                        <p class="book-highlight">
                                                            Discover this edition of <strong>${book.title}</strong> – a
                                                            thoughtful
                                                            resource from our collection that brings new insights to
                                                            readers who
                                                            crave knowledge.
                                                        </p>

                                                        <div class="detail-actions">
                                                            <c:if test="${book.quantity > 0}">
                                                                <form
                                                                    action="${pageContext.request.contextPath}/cart/add"
                                                                    method="post">
                                                                    <input type="hidden" name="bookId"
                                                                        value="${book.id}" />
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
                                                                        <form
                                                                            action="${pageContext.request.contextPath}/reservation"
                                                                            method="post"
                                                                            onsubmit="return confirm('Are you sure you want to reserve this book?');">
                                                                            <input type="hidden" name="action"
                                                                                value="add" />
                                                                            <input type="hidden" name="bookId"
                                                                                value="${book.id}" />
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
                                                            ${not empty book.category ? book.category.name : 'Chưa phân
                                                            loại'}
                                                        </span>
                                                    </article>
                                                </section>

                                                <section class="book-description-card">
                                                    <h2 class="book-description-title">Giới thiệu</h2>
                                                    <p>
                                                        Explore the fascinating world of this book titled
                                                        <strong>${book.title}</strong>
                                                        by <strong>${book.author}</strong>. This resource is part of our
                                                        extensive collection, provided to empower students and faculty
                                                        with
                                                        the knowledge they need for their academic pursuits.
                                                    </p>
                                                </section>
                                            </main>


                                            <section class="comments-section">
                                                <div class="comments-section__header">
                                                    <h2 class="comments-title">Bình Luận & Đánh Giá</h2>
                                                    <p class="message-note">Cảm nhận của bạn sẽ giúp cộng đồng chọn sách
                                                        phù hợp hơn.</p>
                                                </div>

                                                <c:choose>
                                                    <c:when test="${not empty sessionScope.currentUser}">
                                                        <c:if test="${hasCommented}">
                                                            <div class="already-commented-message">
                                                                <p>Bạn đã đánh giá và bình luận cho cuốn sách này rồi!
                                                                </p>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${isCommentLocked}">
                                                            <div class="already-commented-message"
                                                                style="background-color: #fee2e2; border-color: #fca5a5; color: #991b1b;">
                                                                <p>⚠️ Tài khoản của bạn đang bị hạn chế bình luận. Vui
                                                                    lòng thử lại sau.</p>
                                                            </div>
                                                        </c:if>
                                                        <c:if test="${!hasCommented && !isCommentLocked}">
                                                            <div class="comment-form-wrapper">
                                                                <h3 class="comment-form-title">Chia sẻ suy nghĩ của bạn
                                                                </h3>
                                                                <form
                                                                    action="${pageContext.request.contextPath}/comment"
                                                                    method="POST">
                                                                    <input type="hidden" name="action" value="add">
                                                                    <input type="hidden" name="bookId"
                                                                        value="${book.id}">

                                                                    <div class="form-group">
                                                                        <label for="content">Bình luận của bạn</label>
                                                                        <textarea id="content" name="content" required
                                                                            placeholder="Chia sẻ suy nghĩ của bạn về cuốn sách này..."></textarea>
                                                                    </div>

                                                                    <div class="form-group rating-group">
                                                                        <label>Đánh giá</label>
                                                                        <div class="star-rating" role="radiogroup">
                                                                            <input type="radio" id="rate1" name="rating"
                                                                                value="1" required>
                                                                            <label for="rate1"
                                                                                aria-label="1 sao">★</label>
                                                                            <input type="radio" id="rate2" name="rating"
                                                                                value="2">
                                                                            <label for="rate2"
                                                                                aria-label="2 sao">★</label>
                                                                            <input type="radio" id="rate3" name="rating"
                                                                                value="3">
                                                                            <label for="rate3"
                                                                                aria-label="3 sao">★</label>
                                                                            <input type="radio" id="rate4" name="rating"
                                                                                value="4">
                                                                            <label for="rate4"
                                                                                aria-label="4 sao">★</label>
                                                                            <input type="radio" id="rate5" name="rating"
                                                                                value="5">
                                                                            <label for="rate5"
                                                                                aria-label="5 sao">★</label>
                                                                        </div>
                                                                    </div>

                                                                    <div class="form-actions">
                                                                        <button type="submit" class="btn primary">Gửi
                                                                            bình
                                                                            luận</button>
                                                                    </div>
                                                                </form>
                                                            </div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="login-prompt">
                                                            <p>Vui lòng
                                                                <a href="${pageContext.request.contextPath}/auth/login">đăng
                                                                    nhập</a>
                                                                để bình luận.
                                                            </p>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>

                                                <%-- Comments are loaded in controller --%>

                                                    <c:choose>
                                                        <c:when test="${not empty comments}">
                                                            <div class="comments-list">
                                                                <c:forEach var="comment" items="${comments}">
                                                                    <article class="comment-card"
                                                                        id="comment-${comment.commentId}">
                                                                        <header class="comment-header">
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
                                                                                    <span
                                                                                        class="comment-user">${comment.fullName}</span>
                                                                                    <div class="comment-rating">
                                                                                        <c:forEach begin="1"
                                                                                            end="${comment.rating != null ? comment.rating : 0}">
                                                                                            <span class="star">★</span>
                                                                                        </c:forEach>
                                                                                    </div>
                                                                                    <span class="comment-date">
                                                                                        <c:if
                                                                                            test="${comment.createdAt != null}">
                                                                                            <fmt:formatDate
                                                                                                value="${comment.createdAt}"
                                                                                                type="date"
                                                                                                dateStyle="medium" />
                                                                                        </c:if>
                                                                                    </span>
                                                                                </div>
                                                                            </div>
                                                                            <div class="comment-actions">
                                                                                <!-- Edit and Delete buttons: shown for comment owner or admins/librarians -->
                                                                                <c:if
                                                                                    test="${not empty sessionScope.currentUser && (sessionScope.currentUser.id == comment.userId || sessionScope.currentUser.role.name == 'ADMIN' || sessionScope.currentUser.role.name == 'LIBRARIAN')}">
                                                                                    <button type="button"
                                                                                        class="btn ghost btn-action btn-primary"
                                                                                        data-id="${comment.commentId}"
                                                                                        data-content="${fn:escapeXml(comment.content)}"
                                                                                        data-rating="${comment.rating}"
                                                                                        data-bookid="${book.id}"
                                                                                        onclick="openEditForm(this)">
                                                                                        Sửa
                                                                                    </button>
                                                                                    <button type="button"
                                                                                        class="btn ghost btn-action btn-danger"
                                                                                        onclick="openDeleteConfirm('${comment.commentId}', '${book.id}')">
                                                                                        Xóa
                                                                                    </button>
                                                                                </c:if>
                                                                                <!-- Report button: temporarily always shown for debugging -->
                                                                                <button type="button"
                                                                                    class="btn ghost btn-action btn-warning"
                                                                                    onclick="openReportModal('${comment.commentId}')">
                                                                                    Báo cáo
                                                                                </button>
                                                                            </div>
                                                                        </header>
                                                                        <p class="comment-content ${fn:length(comment.content) > 200 ? 'truncated' : ''}"
                                                                            data-full-content="${fn:escapeXml(comment.content)}">
                                                                            <c:out value="${comment.content}" />
                                                                            <c:if
                                                                                test="${fn:length(comment.content) > 200}">
                                                                                <span class="read-more-btn"
                                                                                    onclick="toggleComment(this)">Đọc
                                                                                    thêm</span>
                                                                            </c:if>
                                                                        </p>
                                                                        <!-- Replies section if applicable -->
                                                                        <c:if test="${not empty comment.replies}">
                                                                            <div class="reply-thread">
                                                                                <c:forEach var="reply"
                                                                                    items="${comment.replies}">
                                                                                    <div class="reply-card">
                                                                                        <div class="reply-card__header">
                                                                                            <strong>Phản hồi từ thủ
                                                                                                thư</strong>
                                                                                            <span class="comment-date">
                                                                                                &bull;
                                                                                                <fmt:formatDate
                                                                                                    value="${reply.createdAt}"
                                                                                                    type="both"
                                                                                                    dateStyle="medium"
                                                                                                    timeStyle="short" />
                                                                                            </span>
                                                                                        </div>
                                                                                        <p class="reply-card__body">
                                                                                            ${reply.content}</p>
                                                                                    </div>
                                                                                </c:forEach>
                                                                            </div>
                                                                        </c:if>
                                                                        <!-- Reply form for librarians -->
                                                                        <c:if
                                                                            test="${not empty sessionScope.currentUser && (fn:toUpperCase(sessionScope.currentUser.role.name) == 'LIBRARIAN' || fn:toUpperCase(sessionScope.currentUser.role.name) == 'ADMIN')}">
                                                                            <div class="reply-form"
                                                                                style="margin-top: 10px; padding: 10px; border-top: 1px solid #e5e7eb;">
                                                                                <form
                                                                                    action="${pageContext.request.contextPath}/comment"
                                                                                    method="POST">
                                                                                    <input type="hidden" name="action"
                                                                                        value="reply">
                                                                                    <input type="hidden"
                                                                                        name="commentId"
                                                                                        value="${comment.commentId}">
                                                                                    <input type="hidden" name="bookId"
                                                                                        value="${book.id}">
                                                                                    <textarea name="content"
                                                                                        placeholder="Phản hồi của thủ thư..."
                                                                                        required
                                                                                        style="width: 100%; padding: 8px; border: 1px solid #d1d5db; border-radius: 4px;"></textarea>
                                                                                    <button type="submit"
                                                                                        style="margin-top: 5px; padding: 5px 10px; background: #3b82f6; color: white; border: none; border-radius: 4px;">Gửi
                                                                                        phản hồi</button>
                                                                                </form>
                                                                            </div>
                                                                        </c:if>
                                                                    </article>
                                                                </c:forEach>
                                                            </div>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <div class="no-comments">
                                                                <p>Chưa có bình luận nào. Hãy là người đầu tiên chia sẻ
                                                                    suy nghĩ của bạn!</p>
                                                            </div>
                                                        </c:otherwise>
                                                    </c:choose>

                                                    <!-- Reported Comments Section for Librarians -->
                                                    <c:set var="reportsBasePath"
                                                        value="${not empty reportsBasePath ? reportsBasePath : '/staff/reports'}" />
                                                    <c:if
                                                        test="${not empty sessionScope.currentUser && (fn:toUpperCase(sessionScope.currentUser.role.name) == 'LIBRARIAN' || fn:toUpperCase(sessionScope.currentUser.role.name) == 'ADMIN')}">
                                                        <div class="reports-section">
                                                            <h3 class="reports-title">Bình luận bị báo cáo</h3>
                                                            <p class="message-note">Các bình luận bị báo cáo cần được
                                                                xem xét.</p>
                                                            <c:choose>
                                                                <c:when test="${not empty bookReports}">
                                                                    <div class="reports-list">
                                                                        <c:forEach var="report" items="${bookReports}">
                                                                            <div class="report-card">
                                                                                <div class="report-header">
                                                                                    <span class="report-reason"><strong>Lý
                                                                                            do:</strong>
                                                                                        ${report.reason}</span>
                                                                                    <span class="report-time">
                                                                                        <fmt:formatDate
                                                                                            value="${report.reportTime}"
                                                                                            type="both"
                                                                                            dateStyle="short"
                                                                                            timeStyle="short" />
                                                                                    </span>
                                                                                </div>
                                                                                <div class="report-details">
                                                                                    <p><strong>Người báo cáo:</strong>
                                                                                        ${report.reporterFullName}</p>
                                                                                    <p><strong>Bình luận:</strong>
                                                                                        ${report.commentContent}</p>
                                                                                    <p><strong>Người viết:</strong>
                                                                                        ${report.commentUserFullName}
                                                                                    </p>
                                                                                </div>
                                                                                <div class="report-actions">
                                                                                    <form method="post"
                                                                                        action="${pageContext.request.contextPath}${reportsBasePath}"
                                                                                        style="display: inline;">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="resolve">
                                                                                        <input type="hidden"
                                                                                            name="reportId"
                                                                                            value="${report.reportId}">
                                                                                        <button type="submit"
                                                                                            class="btn btn-success">Giải
                                                                                            quyết</button>
                                                                                    </form>
                                                                                    <form method="post"
                                                                                        action="${pageContext.request.contextPath}${reportsBasePath}"
                                                                                        style="display: inline;">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="ignore">
                                                                                        <input type="hidden"
                                                                                            name="reportId"
                                                                                            value="${report.reportId}">
                                                                                        <button type="submit"
                                                                                            class="btn btn-secondary">Bỏ
                                                                                            qua</button>
                                                                                    </form>
                                                                                    <form method="post"
                                                                                        action="${pageContext.request.contextPath}${reportsBasePath}"
                                                                                        style="display: inline;"
                                                                                        onsubmit="return confirm('Bạn có chắc muốn xóa bình luận này?')">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="delete">
                                                                                        <input type="hidden"
                                                                                            name="reportId"
                                                                                            value="${report.reportId}">
                                                                                        <button type="submit"
                                                                                            class="btn btn-danger">Xóa
                                                                                            bình
                                                                                            luận</button>
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
                                                        '<input type="radio" id="edit5-' + commentId + '" name="rating" value="5">' +
                                                        '<label for="edit5-' + commentId + '">★</label>' +
                                                        '<input type="radio" id="edit4-' + commentId + '" name="rating" value="4">' +
                                                        '<label for="edit4-' + commentId + '">★</label>' +
                                                        '<input type="radio" id="edit3-' + commentId + '" name="rating" value="3">' +
                                                        '<label for="edit3-' + commentId + '">★</label>' +
                                                        '<input type="radio" id="edit2-' + commentId + '" name="rating" value="2">' +
                                                        '<label for="edit2-' + commentId + '">★</label>' +
                                                        '<input type="radio" id="edit1-' + commentId + '" name="rating" value="1">' +
                                                        '<label for="edit1-' + commentId + '">★</label>' +
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

                                                function toggleComment(readMoreBtn) {
                                                    var commentContent = readMoreBtn.parentElement;
                                                    var fullContent = commentContent.dataset.fullContent;

                                                    if (commentContent.classList.contains('truncated')) {
                                                        commentContent.classList.remove('truncated');
                                                        commentContent.innerHTML = fullContent + ' <span class="read-more-btn" onclick="toggleComment(this)">Đọc ít lại</span>';
                                                    } else {
                                                        commentContent.classList.add('truncated');
                                                        commentContent.innerHTML = fullContent.substring(0, 200) + '... <span class="read-more-btn" onclick="toggleComment(this)">Đọc thêm</span>';
                                                    }
                                                }

                                                function toggleComment(btn) {
                                                    const content = btn.parentElement;
                                                    const isExpanded = content.classList.contains('expanded');
                                                    if (isExpanded) {
                                                        content.classList.remove('expanded');
                                                        content.classList.add('truncated');
                                                        btn.textContent = 'Đọc thêm';
                                                    } else {
                                                        content.classList.add('expanded');
                                                        content.classList.remove('truncated');
                                                        btn.textContent = 'Thu gọn';
                                                    }
                                                }
                                            </script>

                                            <!-- Report Modal -->
                                            <div id="reportModal" class="modal-overlay" style="display: none;">
                                                <div class="modal-panel">
                                                    <h2>Báo cáo bình luận</h2>
                                                    <form id="reportForm">
                                                        <input type="hidden" name="action" value="submit">
                                                        <input type="hidden" id="reportCommentId" name="commentId"
                                                            value="">

                                                        <div class="form-group">
                                                            <label for="reportReason">Lý do báo cáo</label>
                                                            <select id="reportReason" name="reason" required>
                                                                <option value="">Chọn lý do</option>
                                                                <option value="Spam">Spam</option>
                                                                <option value="Offensive language">Ngôn ngữ thô tục
                                                                </option>
                                                                <option value="Harassment">Quấy rối</option>
                                                                <option value="False information">Thông tin sai lệch
                                                                </option>
                                                                <option value="Other">Khác</option>
                                                            </select>
                                                        </div>

                                                        <div class="form-group">
                                                            <label for="reportDescription">Mô tả chi tiết (tùy
                                                                chọn)</label>
                                                            <textarea id="reportDescription" name="description" rows="3"
                                                                placeholder="Cung cấp thêm chi tiết..."></textarea>
                                                        </div>

                                                        <div class="modal-actions">
                                                            <button type="button" class="btn secondary"
                                                                onclick="closeReportModal()">Hủy</button>
                                                            <button type="submit" class="btn primary">Gửi báo
                                                                cáo</button>
                                                        </div>
                                                    </form>
                                                </div>
                                            </div>

                                            <script>
                                                function openReportModal(commentId) {
                                                    document.getElementById('reportCommentId').value = commentId;
                                                    document.getElementById('reportModal').style.display = 'grid';
                                                }

                                                function closeReportModal() {
                                                    document.getElementById('reportModal').style.display = 'none';
                                                    document.getElementById('reportForm').reset();
                                                }

                                                document.getElementById('reportForm').addEventListener('submit', function (e) {
                                                    e.preventDefault();

                                                    const formData = new FormData(this);

                                                    fetch('${pageContext.request.contextPath}/reportComment', {
                                                        method: 'POST',
                                                        body: formData
                                                    })
                                                        .then(response => {
                                                            if (!response.ok) {
                                                                throw new Error('HTTP ' + response.status + ': ' + response.statusText);
                                                            }
                                                            return response.json();
                                                        })
                                                        .then(data => {
                                                            if (data.success) {
                                                                showAlert('Thành công', 'Báo cáo đã được gửi thành công!');
                                                                closeReportModal();
                                                            } else {
                                                                showAlert('Lỗi', 'Lỗi: ' + data.message);
                                                            }
                                                        })
                                                        .catch(error => {
                                                            console.error('Error:', error);
                                                            showAlert('Lỗi', 'Có lỗi xảy ra khi gửi báo cáo: ' + error.message);
                                                        });

                                                });

                                                // Close modal when clicking outside
                                                document.getElementById('reportModal').addEventListener('click', function (e) {
                                                    if (e.target === this) {
                                                        closeReportModal();
                                                    }
                                                });
                                            </script>

                                            <!-- Alert Modal -->
                                            <div id="alertModal" class="modal-overlay" style="display: none;">
                                                <div class="modal-panel">
                                                    <h2 id="alertTitle">Thông báo</h2>
                                                    <p id="alertMessage"></p>
                                                    <div class="modal-actions">
                                                        <button type="button" class="btn primary"
                                                            onclick="closeAlertModal()">OK</button>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Close alert modal when clicking outside -->
                                            <script>
                                                document.getElementById('alertModal').addEventListener('click', function (e) {
                                                    if (e.target === this) {
                                                        closeAlertModal();
                                                    }
                                                });
                                            </script>

                                            <jsp:include page="footer.jsp" />
                                </body>

                                </html>