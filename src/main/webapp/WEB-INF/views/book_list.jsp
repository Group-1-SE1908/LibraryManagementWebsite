<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>
                        <fmt:message key="catalog.title" /> | LBMS Library
                    </title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
                    <style>
                        :root {
                            --primary-gradient: linear-gradient(135deg, #0b57d0 0%, #3366cc 100%);
                            --shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
                        }

                        .page-header {
                            background: var(--primary-gradient);
                            color: white;
                            padding: 50px 0;
                            text-align: center;
                            margin-bottom: 40px;
                        }

                        .search-container {
                            background: white;
                            padding: 25px;
                            border-radius: 15px;
                            box-shadow: var(--shadow);
                            margin-top: -60px;
                            position: relative;
                            z-index: 10;
                        }

                        .books-grid {
                            display: grid;
                            grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                            gap: 25px;
                            margin-top: 30px;
                        }

                        .book-card {
                            background: white;
                            border-radius: 12px;
                            overflow: hidden;
                            transition: transform 0.3s ease, box-shadow 0.3s ease;
                            border: 1px solid #eef0f2;
                            display: flex;
                            flex-direction: column;
                        }

                        .book-card:hover {
                            transform: translateY(-5px);
                            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);
                        }

                        .book-image {
                            height: 320px;
                            background: #f1f5f9;
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            position: relative;
                            overflow: hidden;
                            border-bottom: 1px solid #eef0f2;
                        }

                        .book-image img {
                            width: 100%;
                            height: 100%;
                            object-fit: cover;
                            transition: transform 0.5s ease;
                        }

                        .book-card:hover .book-image img {
                            transform: scale(1.05);
                        }


                        .book-title {
                            font-size: 16px;
                            font-weight: 700;
                            margin-bottom: 6px;
                            color: #1e293b;
                            display: -webkit-box;
                            -webkit-line-clamp: 2;
                            -webkit-box-orient: vertical;
                            overflow: hidden;
                            height: 40px;
                        }

                        .status-badge {
                            position: absolute;
                            top: 12px;
                            right: 12px;
                            padding: 5px 12px;
                            border-radius: 20px;
                            font-size: 11px;
                            font-weight: 700;
                            text-transform: uppercase;
                        }

                        .badge-available {
                            background: #dcfce7;
                            color: #166534;
                        }

                        .badge-out {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        .book-info {
                            padding: 20px;
                            flex-grow: 1;
                        }

                        .book-title {
                            font-size: 18px;
                            font-weight: 700;
                            margin-bottom: 8px;
                            color: #1e293b;
                        }

                        .book-author {
                            color: #64748b;
                            font-size: 14px;
                            margin-bottom: 15px;
                        }

                        .book-actions {
                            padding: 15px 20px;
                            background: #f8fafc;
                            border-top: 1px solid #edf2f7;
                            display: flex;
                            gap: 10px;
                        }

                        .btn-full {
                            flex: 1;
                            text-align: center;
                            padding: 10px;
                            border-radius: 8px;
                            text-decoration: none;
                            font-size: 14px;
                            font-weight: 600;
                        }

                        .btn-staff {
                            background: #f1f5f9;
                            color: #475569;
                            border: 1px solid #cbd5e1;
                        }

                        .btn-staff:hover {
                            background: #e2e8f0;
                        }

                        /* Chức năng 30-35 cho Thủ thư */
                        .admin-controls {
                            margin-bottom: 20px;
                            display: flex;
                            justify-content: flex-end;
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="header.jsp" />

                    <c:set var="user" value="${sessionScope.currentUser}" />
                    <c:set var="isStaff" value="${user.role.name == 'ADMIN' || user.role.name == 'LIBRARIAN'}" />

                    <header class="page-header">
                        <div class="container">
                            <h1>📚 Thư viện số LBMS</h1>
                            <p>Khám phá hàng ngàn cuốn sách tri thức</p>
                        </div>
                    </header>

                    <main class="container">
                        <div class="search-container">
                            <form action="${pageContext.request.contextPath}/books" method="get" class="filter-group"
                                style="display: flex; gap: 15px; flex-wrap: wrap;">
                                <input type="text" name="search" placeholder="<fmt:message key=" search.placeholder" />"
                                value="${param.search}"
                                style="flex: 2; min-width: 250px; padding: 12px; border: 1px solid #ddd; border-radius:
                                8px;">

                                <select name="category"
                                    style="flex: 1; min-width: 150px; padding: 12px; border: 1px solid #ddd; border-radius: 8px;">
                                    <option value="0">
                                        <fmt:message key="category.all" />
                                    </option>
                                    <c:forEach var="cat" items="${categories}">
                                        <option value="${cat.id}" ${param.category==cat.id ? 'selected' : '' }>
                                            ${cat.name}
                                        </option>
                                    </c:forEach>
                                </select>

                                <button type="submit" class="btn primary" style="padding: 12px 25px;">
                                    <fmt:message key="search.button" />
                                </button>
                            </form>
                        </div>

                        <c:if test="${isStaff}">
                            <div class="admin-controls" style="margin-top: 30px;">
                                <a href="${pageContext.request.contextPath}/books/new" class="btn primary">➕
                                    <fmt:message key="btn.add_new" />
                                </a>
                            </div>
                        </c:if>

                        <div class="results-info" style="margin-top: 20px; color: #64748b;">
                            <fmt:message key="results.info">
                                <fmt:param value="${totalBooks}" />
                            </fmt:message>
                        </div>

                        <div class="books-grid">
                            <c:forEach var="book" items="${books}">
                                <div class="book-card">
                                    <div class="book-image">
                                        <c:choose>
                                            <c:when test="${not empty book.image}">
                                                <img src="${pageContext.request.contextPath}/${book.image}"
                                                    alt="${book.title}"
                                                    style="width: 100%; height: 100%; object-fit: cover;">
                                            </c:when>
                                            <c:otherwise>
                                                <div style="font-size: 50px;">📖</div>
                                            </c:otherwise>
                                        </c:choose>

                                        <c:choose>
                                            <c:when test="${book.quantity > 0}">
                                                <span class="status-badge badge-available">
                                                    <fmt:message key="status.available" />
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge badge-out">
                                                    <fmt:message key="status.out_of_stock" />
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>

                                    <div class="book-info">
                                        <div class="book-title">${book.title}</div>
                                        <div class="book-author">
                                            <fmt:message key="book.author" />: ${book.author}
                                        </div>
                                        <div style="font-size: 12px; color: #94a3b8;">
                                            <fmt:message key="book.isbn" />: ${book.isbn} |
                                            <fmt:message key="book.year" />: ${book.publishYear}
                                        </div>
                                    </div>

                                    <div class="book-actions">
                                        <a href="${pageContext.request.contextPath}/books/detail?id=${book.id}"
                                            class="btn-full btn-staff">
                                            <fmt:message key="btn.detail" />
                                        </a>

                                        <c:choose>
                                            <c:when test="${isStaff}">
                                                <a href="${pageContext.request.contextPath}/books/edit?id=${book.id}"
                                                    class="btn-full primary">
                                                    <fmt:message key="btn.edit" />
                                                </a>
                                            </c:when>
                                            <c:otherwise>
                                                <c:if test="${book.quantity > 0}">
                                                    <form action="${pageContext.request.contextPath}/cart/add"
                                                        method="post" style="flex: 1;">
                                                        <input type="hidden" name="bookId" value="${book.id}">
                                                        <button type="submit" class="btn-full primary"
                                                            style="width: 100%; border: none; cursor: pointer;">
                                                            <fmt:message key="btn.add_to_cart" />
                                                        </button>
                                                    </form>
                                                </c:if>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <c:if test="${empty books}">
                            <div style="text-align: center; padding: 50px;">
                                <div style="font-size: 50px;">🔍</div>
                                <h3>
                                    <fmt:message key="book.not_found" />
                                </h3>
                                <a href="${pageContext.request.contextPath}/books" class="btn">
                                    <fmt:message key="book.back" />
                                </a>
                            </div>
                        </c:if>
                    </main>

                    <jsp:include page="footer.jsp" />
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                </body>

                </html>