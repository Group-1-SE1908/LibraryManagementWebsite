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
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css">
                    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css"
                        rel="stylesheet">
                    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                    <style>
                        /* Catalog popup – polished modal */
                        .catalog-popup {
                            position: fixed;
                            inset: 0;
                            background: rgba(15, 23, 42, 0.6);
                            backdrop-filter: blur(6px);
                            -webkit-backdrop-filter: blur(6px);
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
                            width: min(480px, 100%);
                            border-radius: 24px;
                            padding: 36px 32px 26px;
                            background: #fff;
                            box-shadow: 0 32px 80px rgba(15, 23, 42, 0.32);
                            border: 1.5px solid rgba(37, 99, 235, 0.18);
                            transform: translateY(0);
                            animation: catalogPopupIn .25s cubic-bezier(.34, 1.56, .64, 1);
                        }

                        @keyframes catalogPopupIn {
                            from {
                                opacity: 0;
                                transform: translateY(12px) scale(.97);
                            }

                            to {
                                opacity: 1;
                                transform: translateY(0) scale(1);
                            }
                        }

                        .catalog-popup__title {
                            font-size: 1.15rem;
                            font-weight: 800;
                            letter-spacing: -0.01em;
                            margin-bottom: 8px;
                            color: #0f172a;
                        }

                        .catalog-popup__message {
                            font-size: 0.95rem;
                            color: #475569;
                            margin-bottom: 24px;
                            line-height: 1.55;
                        }

                        .catalog-popup__actions {
                            display: flex;
                            justify-content: flex-end;
                            gap: 10px;
                        }

                        .catalog-popup__actions .btn {
                            padding: 10px 22px;
                            font-size: 0.84rem;
                            font-weight: 700;
                            border-radius: 999px;
                            border: none;
                            cursor: pointer;
                            transition: all .2s ease;
                        }

                        .catalog-popup__actions .btn-primary {
                            background: linear-gradient(135deg, #2563eb, #4f46e5);
                            color: #fff;
                            box-shadow: 0 6px 20px rgba(37, 99, 235, .35);
                        }

                        .catalog-popup__actions .btn-primary:hover {
                            box-shadow: 0 10px 28px rgba(37, 99, 235, .45);
                            transform: translateY(-1px);
                        }

                        .catalog-popup__actions .btn-outline {
                            background: transparent;
                            border: 1.5px solid rgba(15, 23, 42, 0.18);
                            color: #475569;
                        }

                        .catalog-popup__actions .btn-outline:hover {
                            background: #f8faff;
                        }
                    </style>

                </head>


                <body>

                    <c:set var="user" value="${sessionScope.currentUser}" />
                    <c:set var="isLibrarian" value="${not empty user && user.role.name == 'LIBRARIAN'}" />
                    <c:set var="isStaff"
                        value="${not empty user && (user.role.name == 'ADMIN' || user.role.name == 'LIBRARIAN')}" />
                    <c:set var="booksBasePath" value="${not empty booksBasePath ? booksBasePath : '/books'}" />
                    <c:set var="opsCatalogView"
                        value="${booksBasePath == '/staff/books' || booksBasePath == '/admin/books'}" />

                    <c:choose>
                        <c:when test="${opsCatalogView}">
                            <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />
                        </c:when>
                        <c:when test="${isLibrarian}">
                            <jsp:include page="headerLibBook.jsp" />
                        </c:when>
                        <c:otherwise>
                            <jsp:include page="header.jsp" />
                        </c:otherwise>
                    </c:choose>

                    <c:set var="catCount" value="${fn:length(categories)}" />
                    <fmt:message key="search.placeholder" var="searchPlaceholder" />

                    <c:if test="${opsCatalogView}">
                        <style>
                            @media (min-width: 1025px) {

                                .catalog-hero,
                                .catalog-page {
                                    margin-left: 280px;
                                }
                            }
                        </style>
                    </c:if>

                    <header class="catalog-hero">
                        <div class="catalog-hero__grid container">
                            <div class="catalog-hero__copy">
                                <div class="catalog-hero__label">
                                    <fmt:message key="catalog.title" />
                                </div>
                                <h1 class="catalog-hero__title">Thư viện số LBMS</h1>
                                <p class="catalog-hero__subtitle">Khám phá hàng ngàn cuốn sách tri thức, được tuyển chọn
                                    mỗi ngày để nâng tầm trí thức của bạn.</p>
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
                                    <div class="catalog-hero__stat">
                                        <span class="catalog-hero__stat-value">∞</span>
                                        <span class="catalog-hero__stat-label">kiến thức</span>
                                    </div>
                                </div>
                            </div>
                            <div class="catalog-hero__panel" aria-hidden="true">
                                <div class="catalog-hero__panel-content">
                                    <p class="catalog-hero__panel-title">✨ Gợi ý hôm nay</p>
                                    <p class="catalog-hero__panel-subtitle">Những đầu sách được bạn đọc yêu thích nhất
                                        đang chờ bạn khám phá.</p>
                                    <div class="catalog-hero__panel-badges">
                                        <span>📘 Cổ điển</span>
                                        <span>🌿 Phát triển bản thân</span>
                                        <span>🔬 Khoa học</span>
                                        <span>🎭 Văn học</span>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </header>

                    <main class="catalog-page">
                        <section class="catalog-controls container">
                            <div class="search-panel">
                                <form action="${pageContext.request.contextPath}${booksBasePath}" method="get"
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
                                    <a href="${pageContext.request.contextPath}${booksBasePath}/new"
                                        class="btn primary">➕
                                        <fmt:message key="btn.add_new" />
                                    </a>
                                </div>
                            </c:if>

                            <div class="category-chips">
                                <c:url var="allCategoriesUrl" value="${booksBasePath}">
                                    <c:if test="${not empty searchKeyword}">
                                        <c:param name="search" value="${searchKeyword}" />
                                    </c:if>
                                </c:url>
                                <a href="${allCategoriesUrl}"
                                    class="category-chip ${selectedCategoryId == null ? 'active' : ''}">
                                    <fmt:message key="category.all" />
                                </a>
                                <c:forEach var="cat" items="${categories}">
                                    <c:url var="categoryUrl" value="${booksBasePath}">
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
                            <div id="catalog-popup"
                                class="catalog-popup ${not empty param.cartError ? 'catalog-popup--error' : ''}">
                                <div class="catalog-popup__panel">
                                    <div class="catalog-popup__title">
                                        <c:choose>
                                            <c:when test="${not empty param.cartError}">Lỗi giỏ hàng</c:when>
                                            <c:otherwise>Đã thêm vào giỏ hàng</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <p class="catalog-popup__message">
                                        <c:out
                                            value="${not empty param.cartError ? param.cartError : param.cartSuccess}" />
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
                                            <a class="book-card__link"
                                                href="${pageContext.request.contextPath}${booksBasePath}/detail?id=${book.id}">
                                                <div class="book-image">
                                                    <c:choose>
                                                        <c:when test="${not empty book.image}">
                                                            <c:choose>
                                                                <c:when test="${fn:startsWith(book.image, 'http')}">
                                                                    <img src="${book.image}" alt="${book.title}">
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <img src="${pageContext.request.contextPath}/${book.image}"
                                                                        alt="${book.title}">
                                                                </c:otherwise>
                                                            </c:choose>
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
                                                </div>

                                                <div class="book-card__footer">
                                                    <div class="book-price">
                                                        <c:choose>
                                                            <c:when test="${not empty book.price}">
                                                                <strong>
                                                                    <fmt:formatNumber value="${book.price}"
                                                                        pattern="#,##0" /> ₫
                                                                </strong>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <strong>
                                                                    <fmt:message key="book.price_unknown" />
                                                                </strong>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                </div>
                                            </a>
                                        </div>
                                    </c:forEach>
                                </div>

                                <c:if test="${totalPages > 1}">
                                    <nav class="pagination" aria-label="Book pagination">
                                        <c:choose>
                                            <c:when test="${hasPreviousPage}">
                                                <c:url var="previousPageUrl" value="${booksBasePath}">
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
                                            <c:url var="firstPageUrl" value="${booksBasePath}">
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
                                                    <c:url var="pageUrl" value="${booksBasePath}">
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
                                            <c:url var="lastPageUrl" value="${booksBasePath}">
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
                                                <c:url var="nextPageUrl" value="${booksBasePath}">
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
                                    <a href="${pageContext.request.contextPath}${booksBasePath}" class="btn primary">
                                        <fmt:message key="book.back" />
                                    </a>
                                </div>
                            </c:if>
                        </section>
                    </main>

                    <jsp:include page="footer.jsp" />
                    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                    <c:if test="${not empty flash}">
                        <script>
                            document.addEventListener('DOMContentLoaded', function () {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Thành công!',
                                    text: '${fn:escapeXml(flash)}',
                                    timer: 3000,
                                    timerProgressBar: true,
                                    showConfirmButton: false,
                                    toast: true,
                                    position: 'top-end'
                                });
                            });
                        </script>
                    </c:if>
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
                                    window.location.href = '${pageContext.request.contextPath}${booksBasePath}/delete?id=' + bookId;
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