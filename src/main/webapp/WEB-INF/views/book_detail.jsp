<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>${book.title} - Book Details</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                <style>
                    .detail-container {
                        max-width: 1000px;
                        margin: 40px auto;
                        padding: 20px;
                        display: flex;
                        gap: 40px;
                        background: white;
                        border-radius: 12px;
                        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
                    }

                    .detail-image {
                        flex: 1;
                        background: #f8f9fa;
                        border-radius: 8px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        min-height: 400px;
                        font-size: 100px;
                    }

                    .detail-info {
                        flex: 1.5;
                        display: flex;
                        flex-direction: column;
                    }

                    .detail-title {
                        font-size: 32px;
                        font-weight: 700;
                        margin-bottom: 10px;
                        color: #2d3436;
                    }

                    .detail-author {
                        font-size: 18px;
                        color: #636e72;
                        margin-bottom: 20px;
                    }

                    .detail-meta {
                        margin-bottom: 30px;
                        display: grid;
                        grid-template-columns: 1fr 1fr;
                        gap: 15px;
                    }

                    .meta-item {
                        padding: 10px;
                        background: #f0f2f5;
                        border-radius: 6px;
                    }

                    .meta-label {
                        font-size: 12px;
                        color: #b2bec3;
                        text-transform: uppercase;
                        display: block;
                    }

                    .meta-value {
                        font-weight: 600;
                        color: #2d3436;
                    }

                    .detail-actions {
                        margin-top: auto;
                        display: flex;
                        gap: 15px;
                        padding-top: 20px;
                        border-top: 1px solid #eee;
                    }

                    .status-badge {
                        display: inline-block;
                        padding: 4px 12px;
                        border-radius: 20px;
                        font-size: 14px;
                        font-weight: 600;
                        margin-bottom: 20px;
                    }

                    .status-available {
                        background: #e3f9e5;
                        color: #1f8b24;
                    }

                    .status-out {
                        background: #fee2e2;
                        color: #dc2626;
                    }

                    @media (max-width: 768px) {
                        .detail-container {
                            flex-direction: column;
                        }
                    }
                </style>
            </head>

            <body>
                <jsp:include page="header.jsp" />

                <div class="main-content">
                    <div style="max-width: 1000px; margin: 20px auto;">
                        <a href="${pageContext.request.contextPath}/books"
                            style="text-decoration: none; color: #636e72;">← Back to Books</a>
                    </div>

                    <div class="detail-container">
                        <div class="detail-image">
                            📖
                        </div>
                        <div class="detail-info">
                            <c:choose>
                                <c:when test="${book.availability}">
                                    <span class="status-badge status-available">Available</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-badge status-out">Unavailable</span>
                                </c:otherwise>
                            </c:choose>

                            <h1 class="detail-title">${book.title}</h1>
                            <p class="detail-author">by ${book.author}</p>

                            <div class="detail-meta">
                                <div class="meta-item">
                                    <span class="meta-label">ID</span>
                                    <span class="meta-value">#${book.id}</span>
                                </div>
                                <div class="meta-item">
                                    <span class="meta-label">Price</span>
                                    <span class="meta-value">${book.price} $</span>
                                </div>
                            </div>

                            <div class="detail-actions">
                                <c:if test="${book.availability}">
                                    <form method="post" action="${pageContext.request.contextPath}/cart/add"
                                        style="flex: 1;">
                                        <input type="hidden" name="bookId" value="${book.id}" />
                                        <input type="hidden" name="quantity" value="1" />
                                        <button type="submit" class="btn primary" style="width: 100%;">Add to
                                            Cart</button>
                                    </form>
                                </c:if>
                                <c:if test="${!book.availability}">
                                    <button class="btn secondary" style="flex: 1;"
                                        onclick="alert('Join the waitlist to be notified!')">Join Waitlist</button>
                                </c:if>

                                <c:if
                                    test="${sessionScope.currentUser.role.name == 'ADMIN' || sessionScope.currentUser.role.name == 'LIBRARIAN'}">
                                    <a href="${pageContext.request.contextPath}/books/edit?id=${book.id}" class="btn"
                                        style="flex: 0.5; text-align: center;">Edit</a>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>

                <jsp:include page="footer.jsp" />
            </body>

            </html>