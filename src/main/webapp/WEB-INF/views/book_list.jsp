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
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
              rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
        <style>
            .catalog-popup {
                position: fixed;
                inset: 0;
                background: rgba(15, 23, 42, 0.55);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 999;
                padding: 24px;
                opacity: 0;
                pointer-events: none;
                transition: opacity 0.25s ease;
            }
            .catalog-popup--visible {
                opacity: 1;
                pointer-events: all;
            }
            .catalog-popup__panel {
                width: min(460px, 100%);
                border-radius: 22px;
                padding: 34px 30px 24px;
                background: linear-gradient(145deg, rgba(255, 255, 255, 0.95), rgba(248, 250, 252, 0.95));
                box-shadow: 0 25px 60px rgba(15, 23, 42, 0.35);
                border: 1px solid rgba(59, 130, 246, 0.35);
                transform: translateY(-8px);
            }
            .catalog-popup__title {
                font-size: 1.25rem;
                letter-spacing: 0.3em;
                text-transform: uppercase;
                margin-bottom: 8px;
                color: #0f172a;
            }
            .catalog-popup__message {
                font-size: 1rem;
                color: #1f2937;
                margin-bottom: 22px;
                line-height: 1.4;
            }
            .catalog-popup__actions {
                display: flex;
                justify-content: flex-end;
                gap: 10px;
            }
            .catalog-popup__actions .btn {
                padding: 10px 20px;
                font-size: 0.85rem;
                letter-spacing: 0.08em;
                border-radius: 12px;
                border: none;
                cursor: pointer;
            }
            .catalog-popup__actions .btn-primary {
                background: linear-gradient(135deg, #0ea5e9, #2563eb);
                color: #fff;
            }
            .catalog-popup__actions .btn-outline {
                background: transparent;
                border: 1px solid rgba(15, 23, 42, 0.2);
                color: #0f172a;
            }
        </style>
    
    </head>


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
                               placeholder="${searchPlaceholder}" value="${fn:escapeXml(searchKeyword)}">
                        <select name="category" class="search-panel__select">
                            <option value="0">
                                <fmt:message key="category.all" />
                            </option>
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}" ${selectedCategoryId==cat.id ? 'selected' : '' }>
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
                    <c:url var="allCategoriesUrl" value="/books">
                        <c:if test="${not empty searchKeyword}">
                            <c:param name="search" value="${searchKeyword}" />
                        </c:if>
                    </c:url>
                    <a href="${allCategoriesUrl}"
                       class="category-chip ${selectedCategoryId == null ? 'active' : ''}">
                        <fmt:message key="category.all" />
                    </a>
                    <c:forEach var="cat" items="${categories}">
                        <c:url var="categoryUrl" value="/books">
                            <c:param name="category" value="${cat.id}" />
                            <c:if test="${not empty searchKeyword}">
                                <c:param name="search" value="${searchKeyword}" />
                            </c:if>
                        </c:url>
                        <a href="${categoryUrl}"
                           class="category-chip ${selectedCategoryId == cat.id ? 'active' : ''}">
                            ${cat.name}
                        </a>
                    </c:forEach>
                </div>
            </section>

            <c:if test="${not empty param.cartSuccess || not empty param.cartError}">
                <div id="catalog-popup" class="catalog-popup ${not empty param.cartError ? 'catalog-popup--error' : ''}">
                    <div class="catalog-popup__panel">
                        <div class="catalog-popup__title">
                            <c:choose>
                                <c:when test="${not empty param.cartError}">Lỗi giỏ hàng</c:when>
                                <c:otherwise>Đã thêm vào giỏ hàng</c:otherwise>
                            </c:choose>
                        </div>
                        <p class="catalog-popup__message">
                            <c:out value="${not empty param.cartError ? param.cartError : param.cartSuccess}"/>
                        </p>
                        <div class="catalog-popup__actions">
                            <button type="button" class="btn btn-outline" data-popup-close>Đóng</button>
                        </div>
                    </div>
                </div>
            </c:if>

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
                                            <button type="button"
                                                    onclick="confirmDelete('${book.id}', '${book.title}')"
                                                    class="btn-full btn-danger">
                                                Xóa
                                            </button>
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

                    <c:if test="${totalPages > 1}">
                        <nav class="pagination" aria-label="Book pagination">
                            <c:choose>
                                <c:when test="${hasPreviousPage}">
                                    <c:url var="previousPageUrl" value="/books">
                                        <c:param name="page" value="${currentPage - 1}" />
                                        <c:if test="${not empty searchKeyword}">
                                            <c:param name="search" value="${searchKeyword}" />
                                        </c:if>
                                        <c:if test="${selectedCategoryId != null}">
                                            <c:param name="category" value="${selectedCategoryId}" />
                                        </c:if>
                                    </c:url>
                                    <a href="${previousPageUrl}">
                                        <fmt:message key="pagination.previous" />
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span>
                                        <fmt:message key="pagination.previous" />
                                    </span>
                                </c:otherwise>
                            </c:choose>

                            <c:if test="${startPage > 1}">
                                <c:url var="firstPageUrl" value="/books">
                                    <c:param name="page" value="1" />
                                    <c:if test="${not empty searchKeyword}">
                                        <c:param name="search" value="${searchKeyword}" />
                                    </c:if>
                                    <c:if test="${selectedCategoryId != null}">
                                        <c:param name="category" value="${selectedCategoryId}" />
                                    </c:if>
                                </c:url>
                                <a href="${firstPageUrl}">1</a>
                                <c:if test="${startPage > 2}">
                                    <span>...</span>
                                </c:if>
                            </c:if>

                            <c:forEach var="pageNumber" begin="${startPage}" end="${endPage}">
                                <c:choose>
                                    <c:when test="${pageNumber == currentPage}">
                                        <span class="current">${pageNumber}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <c:url var="pageUrl" value="/books">
                                            <c:param name="page" value="${pageNumber}" />
                                            <c:if test="${not empty searchKeyword}">
                                                <c:param name="search" value="${searchKeyword}" />
                                            </c:if>
                                            <c:if test="${selectedCategoryId != null}">
                                                <c:param name="category" value="${selectedCategoryId}" />
                                            </c:if>
                                        </c:url>
                                        <a href="${pageUrl}">${pageNumber}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>

                            <c:if test="${endPage < totalPages}">
                                <c:if test="${endPage < totalPages - 1}">
                                    <span>...</span>
                                </c:if>
                                <c:url var="lastPageUrl" value="/books">
                                    <c:param name="page" value="${totalPages}" />
                                    <c:if test="${not empty searchKeyword}">
                                        <c:param name="search" value="${searchKeyword}" />
                                    </c:if>
                                    <c:if test="${selectedCategoryId != null}">
                                        <c:param name="category" value="${selectedCategoryId}" />
                                    </c:if>
                                </c:url>
                                <a href="${lastPageUrl}">${totalPages}</a>
                            </c:if>

                            <c:choose>
                                <c:when test="${hasNextPage}">
                                    <c:url var="nextPageUrl" value="/books">
                                        <c:param name="page" value="${currentPage + 1}" />
                                        <c:if test="${not empty searchKeyword}">
                                            <c:param name="search" value="${searchKeyword}" />
                                        </c:if>
                                        <c:if test="${selectedCategoryId != null}">
                                            <c:param name="category" value="${selectedCategoryId}" />
                                        </c:if>
                                    </c:url>
                                    <a href="${nextPageUrl}">
                                        <fmt:message key="pagination.next" />
                                    </a>
                                </c:when>
                                <c:otherwise>
                                    <span>
                                        <fmt:message key="pagination.next" />
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </nav>
                    </c:if>
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
        <script>
                                                        function confirmDelete(bookId, bookTitle) {
                                                            Swal.fire({
                                                                title: 'Xác nhận xóa?',
                                                                text: "Bạn có chắc chắn muốn xóa cuốn sách '" + bookTitle + "' không? Hành động này không thể hoàn tác!",
                                                                icon: 'warning',
                                                                showCancelButton: true,
                                                                confirmButtonColor: '#d33',
                                                                cancelButtonColor: '#3085d6',
                                                                confirmButtonText: 'Đồng ý xóa',
                                                                cancelButtonText: 'Hủy bỏ'
                                                                
                                                            }).then((result) => {
                                                                if (result.isConfirmed) {
                                                                    // Chuyển hướng đến URL xóa đã định nghĩa trong BookController
                                                                    window.location.href = '${pageContext.request.contextPath}/books/delete?id=' + bookId;
                                                                }
                                                            });
                                                        }
        </script>
        <script>
            (function () {
                const popup = document.getElementById('catalog-popup');
                if (!popup) {
                    return;
                }
                const closeBtn = popup.querySelector('[data-popup-close]');

                const hidePopup = () => popup.classList.remove('catalog-popup--visible');

                popup.classList.add('catalog-popup--visible');

                popup.addEventListener('click', (event) => {
                    if (event.target === popup) {
                        hidePopup();
                    }
                });

                if (closeBtn) {
                    closeBtn.addEventListener('click', hidePopup);
                }
            })();
        </script>
    </body>

</html>