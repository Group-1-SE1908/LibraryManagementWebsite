<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
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
            }
        </style>
    </head>

    <body>
        <jsp:include page="header.jsp" />

        <div class="detail-page">
            <nav class="breadcrumb">
                <a href="${pageContext.request.contextPath}/books">Catalog</a> &nbsp;/&nbsp;
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
                                <span class="badge-status badge-available">Available</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge-status badge-unavailable">Out of Stock</span>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <h1 class="book-title">${book.title}</h1>
                    <p class="book-author-name">by ${book.author}</p>

                    <div class="book-details-grid">
                        <div class="detail-item">
                            <span class="detail-label">ISBN</span>
                            <span class="detail-value">${book.isbn}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Publisher</span>
                            <span class="detail-value">${not empty book.publisher ? book.publisher :
                                                         'Unknown'}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Published Year</span>
                            <span class="detail-value">${not empty book.publishYear ? book.publishYear :
                                                         'N/A'}</span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Current Stock</span>
                            <span class="detail-value">${book.quantity} copies</span>
                        </div>
                    </div>

                    <div class="book-description">
                        <p>Explore the fascinating world of this book titled <strong>${book.title}</strong> by
                            <strong>${book.author}</strong>. This resource is part of our extensive collection,
                            provided to empower students and faculty with the knowledge they need for their
                            academic pursuits.</p>
                    </div>

                    <div class="action-footer">
<!--                        Button add to cart-->
                        <c:if test="${book.quantity > 0}">
                            <form action="${pageContext.request.contextPath}/cart/add" method="post">
                                <input type="hidden" name="bookId" value="${book.id}" />
                                <input type="hidden" name="quantity" value="1" />
                                <button type="submit" class="btn primary">
                                    Add to Cart
                                </button>
                            </form>
                        </c:if>
                        <a href="${pageContext.request.contextPath}/books" class="btn">
                            Back to Catalog
                        </a>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="footer.jsp" />
    </body>

</html>