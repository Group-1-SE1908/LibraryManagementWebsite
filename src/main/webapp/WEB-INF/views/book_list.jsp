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
    </head>

    <body>
    <body>
        
        <c:set var="user" value="${sessionScope.currentUser}" />
        <c:set var="isStaff" value="${user.role.name == 'LIBRARIAN'}" />

        <c:choose>
            <c:when test="${isStaff}">
                
                <jsp:include page="headerLibBook.jsp" />
            </c:when>
            <c:otherwise>
                
                <jsp:include page="header.jsp" />
            </c:otherwise>
        </c:choose>


        <c:set var="user" value="${sessionScope.currentUser}" />
        <c:set var="isStaff" value="${user.role.name == 'ADMIN' || user.role.name == 'LIBRARIAN'}" />
        <c:set var="catCount" value="${fn:length(categories)}" />
        <fmt:message key="search.placeholder" var="searchPlaceholder" />

        <header class="catalog-hero">
            <div class="catalog-hero__grid container">
                <div class="catalog-hero__copy">
                    <div class="catalog-hero__label">
                        <fmt:message key="catalog.title" />
                    </div>
                    <h1 class="catalog-hero__title">Thư viện số LBMS</h1>
                    <p class="catalog-hero__subtitle">Khám phá hàng ngàn cuốn sách tri thức, được tuyển chọn
                        mỗi ngày.</p>
                    <div class="catalog-hero__stats">
                        <div class="catalog-hero__stat">
                            <span class="catalog-hero__stat-value">
                                <fmt:formatNumber value="${totalBooks}" />
                            </span>
                            <span class="catalog-hero__stat-label">cuốn sách</span>
                        </div>
                        <div class="catalog-hero__stat">
                            <span class="catalog-hero__stat-value">
                                <fmt:formatNumber value="${catCount}" />
                            </span>
                            <span class="catalog-hero__stat-label">thể loại</span>
                        </div>
                    </div>
                </div>
                <div class="catalog-hero__panel" aria-hidden="true">
                    <div class="catalog-hero__panel-content">
                        <p class="catalog-hero__panel-title">Gợi ý hôm nay</p>
                        <p class="catalog-hero__panel-subtitle">Những đầu sách được bạn đọc yêu thích đang
                            chờ bạn khám phá.</p>
                        <div class="catalog-hero__panel-badges">
                            <span>📘 Cổ điển</span>
                            <span>🌿 Phát triển bản thân</span>
                            <span>🔬 Khoa học</span>
                        </div>
                    </div>
                </div>
            </div>
        </header>

        <main class="catalog-page">
            <section class="catalog-controls container">
                <div class="search-panel">
                    <form action="${pageContext.request.contextPath}/books" method="get"
                          class="search-panel__form">
                        <input type="text" name="search" class="search-panel__input"
                               placeholder="${searchPlaceholder}" value="${param.search}">
                        <select name="category" class="search-panel__select">
                            <option value="0">
                                <fmt:message key="category.all" />
                            </option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${param.category==cat.id ? 'selected' : '' }>
                                    ${cat.name}
                                </option>
                            </c:forEach>
                        </select>
                        <button type="submit" class="btn primary search-panel__cta">
                            <fmt:message key="search.button" />
                        </button>
                    </form>
                </div>

                <c:if test="${isStaff}">
                    <div class="admin-controls">
                        <a href="${pageContext.request.contextPath}/books/new" class="btn primary">➕
                            <fmt:message key="btn.add_new" />
                        </a>
                    </div>
                </c:if>

                <div class="category-chips">
                    <a href="${pageContext.request.contextPath}/books"
                       class="category-chip ${empty param.category || param.category == '0' ? 'active' : ''}">
                        <fmt:message key="category.all" />
                    </a>
                    <c:forEach var="cat" items="${categories}">
                        <a href="${pageContext.request.contextPath}/books?category=${cat.id}"
                           class="category-chip ${param.category == cat.id ? 'active' : ''}">
                            ${cat.name}
                        </a>
                    </c:forEach>
                </div>
            </section>

            <section class="catalog-results container">
                <div class="results-info">
                    <fmt:message key="results.info">
                        <fmt:param value="${totalBooks}" />
                    </fmt:message>
                </div>

                <c:if test="${not empty books}">
                    <div class="books-grid">
                        <c:forEach var="book" items="${books}">
                            <div class="book-card">
                                <div class="book-image">
                                    <c:choose>
                                        <c:when test="${not empty book.image}">
                                            <img src="${pageContext.request.contextPath}/${book.image}"
                                                 alt="${book.title}">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="book-image__fallback">📖</div>
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

                                <div class="book-card__body">
                                    <div class="book-title">${book.title}</div>
                                    <div class="book-author">
                                        <fmt:message key="book.author" />: ${book.author}
                                    </div>
                                    <div class="book-meta">
                                        <span>
                                            <fmt:message key="book.isbn" />: ${book.isbn}
                                        </span>
                                        <span>
                                            <fmt:message key="book.year" />: ${book.publishYear}
                                        </span>
                                    </div>
                                    <div class="book-meta book-meta--stock">
                                        <span>
                                            <fmt:message key="book.stock" />:
                                            <fmt:message key="book.copies">
                                                <fmt:param value="${book.quantity}" />
                                            </fmt:message>
                                        </span>
                                    </div>
                                </div>

                                <div class="book-card__footer book-actions">
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
                                                      method="post">
                                                    <input type="hidden" name="bookId" value="${book.id}">
                                                    <button type="submit" class="btn-full primary">
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
                </c:if>

                <c:if test="${empty books}">
                    <div class="empty-state">
                        <div class="empty-state__icon">🔍</div>
                        <h3>
                            <fmt:message key="book.not_found" />
                        </h3>
                        <p class="empty-state__text">Thử một từ khoá khác hoặc mở rộng phạm vi tìm kiếm.</p>
                        <a href="${pageContext.request.contextPath}/books" class="btn primary">
                            <fmt:message key="book.back" />
                        </a>
                    </div>
                </c:if>
            </section>
        </main>

        <jsp:include page="footer.jsp" />
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>

</html>