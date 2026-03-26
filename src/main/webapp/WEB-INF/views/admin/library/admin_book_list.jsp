<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
            <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>LBMS – Kho sách</title>
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                        rel="stylesheet" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
                    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                    <style>
                        /* ── Book thumbnail cell ── */
                        .bl-thumb {
                            width: 48px;
                            height: 64px;
                            object-fit: cover;
                            border-radius: 6px;
                            box-shadow: 0 1px 4px rgba(0, 0, 0, .15);
                            background: #f1f5f9;
                            display: block;
                        }

                        .bl-thumb-placeholder {
                            width: 48px;
                            height: 64px;
                            border-radius: 6px;
                            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            font-size: 1.4rem;
                            color: #6366f1;
                            flex-shrink: 0;
                        }

                        /* ── Stock badge ── */
                        .bl-badge {
                            display: inline-flex;
                            align-items: center;
                            gap: 4px;
                            padding: 3px 10px;
                            border-radius: 20px;
                            font-size: .72rem;
                            font-weight: 700;
                            white-space: nowrap;
                        }

                        .bl-badge-available {
                            background: #dcfce7;
                            color: #166534;
                        }

                        .bl-badge-empty {
                            background: #fee2e2;
                            color: #991b1b;
                        }

                        /* ── Category pill ── */
                        .bl-cat {
                            display: inline-block;
                            padding: 2px 10px;
                            border-radius: 12px;
                            font-size: .75rem;
                            font-weight: 600;
                            background: #ede9fe;
                            color: #5b21b6;
                            max-width: 140px;
                            overflow: hidden;
                            text-overflow: ellipsis;
                            white-space: nowrap;
                        }

                        /* ── Pagination ── */
                        .bl-pagination {
                            display: flex;
                            align-items: center;
                            justify-content: center;
                            gap: 6px;
                            padding: 20px 0 8px;
                            flex-wrap: wrap;
                        }

                        .bl-pagination a,
                        .bl-pagination span {
                            min-width: 34px;
                            height: 34px;
                            display: inline-flex;
                            align-items: center;
                            justify-content: center;
                            border-radius: 8px;
                            font-size: .83rem;
                            font-weight: 600;
                            text-decoration: none;
                            transition: all .2s ease;
                            padding: 0 6px;
                        }

                        .bl-pagination a {
                            background: #fff;
                            color: var(--panel-text);
                            border: 1.5px solid var(--panel-border);
                        }

                        .bl-pagination a:hover {
                            background: var(--panel-accent);
                            color: #fff;
                            border-color: var(--panel-accent);
                        }

                        .bl-pagination span.current {
                            background: var(--panel-accent);
                            color: #fff;
                            border: 1.5px solid var(--panel-accent);
                        }

                        .bl-pagination span.ellipsis {
                            background: transparent;
                            color: var(--panel-text-sub);
                            border: none;
                        }

                        /* ── Result count ── */
                        .bl-result-count {
                            font-size: .82rem;
                            color: var(--panel-text-sub);
                            margin-bottom: 10px;
                        }

                        /* ── Empty state ── */
                        .bl-empty {
                            text-align: center;
                            padding: 60px 24px;
                            color: var(--panel-text-sub);
                        }

                        .bl-empty i {
                            font-size: 3rem;
                            margin-bottom: 12px;
                            opacity: .4;
                        }

                        .bl-empty p {
                            margin: 6px 0 0;
                            font-size: .9rem;
                        }

                        /* ── Title+author cell ── */
                        .bl-title {
                            font-weight: 600;
                            color: var(--panel-text);
                            font-size: .88rem;
                        }

                        .bl-author {
                            font-size: .75rem;
                            color: var(--panel-text-sub);
                            margin-top: 2px;
                        }

                        /* ── ISBN cell ── */
                        .bl-isbn {
                            font-size: .75rem;
                            color: var(--panel-text-sub);
                            font-family: monospace;
                        }

                        /* ── Actions cell ── */
                        .bl-actions {
                            display: flex;
                            gap: 6px;
                            justify-content: flex-end;
                            flex-wrap: nowrap;
                        }
                    </style>
                </head>

                <body class="panel-body">

                    <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                    <main class="panel-main">

                        <%-- Page Header --%>
                            <div class="pm-page-header">
                                <div>
                                    <h1 class="pm-title">
                                        <i class="fas fa-book"
                                            style="color:var(--panel-accent);margin-right:8px;"></i>Kho sách
                                    </h1>
                                    <p class="pm-subtitle">Quản lý toàn bộ đầu sách trong thư viện — tìm kiếm, thêm mới,
                                        chỉnh sửa và xóa.</p>
                                </div>
                                <a href="${pageContext.request.contextPath}/admin/books/new"
                                    class="pm-btn pm-btn-primary">
                                    <i class="fas fa-plus"></i> Thêm sách mới
                                </a>
                            </div>

                            <%-- Toast flash --%>
                                <c:if test="${not empty flash}">
                                    <c:set var="isErr"
                                        value="${fn:contains(flash,'Lỗi') || fn:contains(flash,'Error') || fn:contains(flash,'không thể')}" />
                                    <div id="toast-msg"
                                        class="pm-toast ${isErr ? 'pm-toast-danger' : 'pm-toast-success'}">
                                        <i class="fas ${isErr ? 'fa-circle-exclamation' : 'fa-circle-check'}"></i>
                                        <span>
                                            <c:out value="${flash}" />
                                        </span>
                                    </div>
                                </c:if>
                                <c:if test="${not empty flashError}">
                                    <div id="toast-msg" class="pm-toast pm-toast-danger">
                                        <i class="fas fa-circle-exclamation"></i>
                                        <span>
                                            <c:out value="${flashError}" />
                                        </span>
                                    </div>
                                </c:if>

                                <%-- Search / Filter toolbar --%>
                                    <div class="pm-toolbar">
                                        <form method="get" action="${pageContext.request.contextPath}/admin/books"
                                            style="flex:1;display:flex;gap:10px;align-items:center;flex-wrap:wrap;">
                                            <%-- Keyword --%>
                                                <div style="position:relative;flex:1;min-width:220px;">
                                                    <i class="fas fa-search"
                                                        style="position:absolute;left:12px;top:50%;transform:translateY(-50%);color:var(--panel-text-sub);font-size:.85rem;pointer-events:none;"></i>
                                                    <input type="text" name="search"
                                                        value="${fn:escapeXml(searchKeyword)}" class="pm-input"
                                                        style="width:100%;padding-left:36px;"
                                                        placeholder="Tìm theo tên sách, tác giả hoặc ISBN...">
                                                </div>
                                                <%-- Category --%>
                                                    <select name="category" class="pm-input" style="min-width:160px;">
                                                        <option value="0">Tất cả thể loại</option>
                                                        <c:forEach var="cat" items="${categories}">
                                                            <option value="${cat.id}" ${selectedCategoryId==cat.id
                                                                ? 'selected' : '' }>${fn:escapeXml(cat.name)}</option>
                                                        </c:forEach>
                                                    </select>
                                                    <button type="submit" class="pm-btn pm-btn-primary">
                                                        <i class="fas fa-search"></i> Tìm kiếm
                                                    </button>
                                                    <c:if
                                                        test="${not empty searchKeyword || (selectedCategoryId != null && selectedCategoryId > 0)}">
                                                        <a href="${pageContext.request.contextPath}/admin/books"
                                                            class="pm-btn pm-btn-outline">
                                                            <i class="fas fa-xmark"></i> Xóa lọc
                                                        </a>
                                                    </c:if>
                                        </form>
                                    </div>

                                    <%-- Result count --%>
                                        <div class="bl-result-count">
                                            Tìm thấy <strong>${totalBooks}</strong> đầu sách
                                            <c:if test="${not empty searchKeyword}">
                                                — từ khoá: "<strong>
                                                    <c:out value="${searchKeyword}" />
                                                </strong>"
                                            </c:if>
                                        </div>

                                        <%-- Table card --%>
                                            <div class="pm-card" style="padding:0;overflow:hidden;">
                                                <c:choose>
                                                    <c:when test="${not empty books}">
                                                        <div class="pm-table-wrap">
                                                            <table class="pm-table">
                                                                <thead>
                                                                    <tr>
                                                                        <th style="width:60px;">Ảnh</th>
                                                                        <th>Tên sách / Tác giả</th>
                                                                        <th>ISBN</th>
                                                                        <th>Thể loại</th>
                                                                        <th style="text-align:center;">Số lượng</th>
                                                                        <th style="text-align:right;">Giá</th>
                                                                        <th style="text-align:right;">Thao tác</th>
                                                                    </tr>
                                                                </thead>
                                                                <tbody>
                                                                    <c:forEach var="book" items="${books}">
                                                                        <tr>
                                                                            <%-- Thumbnail --%>
                                                                                <td>
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${not empty book.image}">
                                                                                            <c:choose>
                                                                                                <c:when
                                                                                                    test="${fn:startsWith(book.image,'http')}">
                                                                                                    <img class="bl-thumb"
                                                                                                        src="${fn:escapeXml(book.image)}"
                                                                                                        alt="${fn:escapeXml(book.title)}"
                                                                                                        loading="lazy">
                                                                                                </c:when>
                                                                                                <c:otherwise>
                                                                                                    <img class="bl-thumb"
                                                                                                        src="${pageContext.request.contextPath}/${fn:escapeXml(book.image)}"
                                                                                                        alt="${fn:escapeXml(book.title)}"
                                                                                                        loading="lazy">
                                                                                                </c:otherwise>
                                                                                            </c:choose>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <div
                                                                                                class="bl-thumb-placeholder">
                                                                                                📖</div>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </td>

                                                                                <%-- Title + Author --%>
                                                                                    <td>
                                                                                        <div class="bl-title">
                                                                                            ${fn:escapeXml(book.title)}
                                                                                        </div>
                                                                                        <div class="bl-author">
                                                                                            ${fn:escapeXml(book.author)}
                                                                                        </div>
                                                                                    </td>

                                                                                    <%-- ISBN --%>
                                                                                        <td class="bl-isbn">
                                                                                            ${fn:escapeXml(book.isbn)}
                                                                                        </td>

                                                                                        <%-- Category --%>
                                                                                            <td>
                                                                                                <c:set var="catName"
                                                                                                    value="—" />
                                                                                                <c:forEach var="cat"
                                                                                                    items="${categories}">
                                                                                                    <c:if
                                                                                                        test="${cat.id == book.categoryId}">
                                                                                                        <c:set
                                                                                                            var="catName"
                                                                                                            value="${cat.name}" />
                                                                                                    </c:if>
                                                                                                </c:forEach>
                                                                                                <c:choose>
                                                                                                    <c:when
                                                                                                        test="${catName != '—'}">
                                                                                                        <span
                                                                                                            class="bl-cat"
                                                                                                            title="${fn:escapeXml(catName)}">${fn:escapeXml(catName)}</span>
                                                                                                    </c:when>
                                                                                                    <c:otherwise><span
                                                                                                            style="color:var(--panel-text-sub);">—</span>
                                                                                                    </c:otherwise>
                                                                                                </c:choose>
                                                                                            </td>

                                                                                            <%-- Quantity / availability
                                                                                                --%>
                                                                                                <td
                                                                                                    style="text-align:center;">
                                                                                                    <c:choose>
                                                                                                        <c:when
                                                                                                            test="${book.quantity > 0}">
                                                                                                            <span
                                                                                                                class="bl-badge bl-badge-available">
                                                                                                                <i class="fas fa-circle"
                                                                                                                    style="font-size:.45rem;"></i>
                                                                                                                ${book.quantity}
                                                                                                                cuốn
                                                                                                            </span>
                                                                                                        </c:when>
                                                                                                        <c:otherwise>
                                                                                                            <span
                                                                                                                class="bl-badge bl-badge-empty">
                                                                                                                <i class="fas fa-circle"
                                                                                                                    style="font-size:.45rem;"></i>
                                                                                                                Hết sách
                                                                                                            </span>
                                                                                                        </c:otherwise>
                                                                                                    </c:choose>
                                                                                                </td>

                                                                                                <%-- Price --%>
                                                                                                    <td
                                                                                                        style="text-align:right;font-weight:600;">
                                                                                                        <c:choose>
                                                                                                            <c:when
                                                                                                                test="${not empty book.price && book.price > 0}">
                                                                                                                <fmt:formatNumber
                                                                                                                    value="${book.price}"
                                                                                                                    pattern="#,##0" />
                                                                                                                ₫
                                                                                                            </c:when>
                                                                                                            <c:otherwise>
                                                                                                                <span
                                                                                                                    style="color:var(--panel-text-sub);">—</span>
                                                                                                            </c:otherwise>
                                                                                                        </c:choose>
                                                                                                    </td>

                                                                                                    <%-- Actions --%>
                                                                                                        <td>
                                                                                                            <div
                                                                                                                class="bl-actions">
                                                                                                                <a href="${pageContext.request.contextPath}/admin/books/detail?id=${book.id}"
                                                                                                                    class="pm-btn pm-btn-sm pm-btn-outline"
                                                                                                                    title="Xem chi tiết">
                                                                                                                    <i
                                                                                                                        class="fas fa-eye"></i>
                                                                                                                </a>
                                                                                                                <a href="${pageContext.request.contextPath}/admin/books/edit?id=${book.id}"
                                                                                                                    class="pm-btn pm-btn-sm pm-btn-warning"
                                                                                                                    title="Chỉnh sửa">
                                                                                                                    <i
                                                                                                                        class="fas fa-pen"></i>
                                                                                                                </a>
                                                                                                                <button
                                                                                                                    type="button"
                                                                                                                    class="pm-btn pm-btn-sm pm-btn-danger"
                                                                                                                    title="Xóa sách"
                                                                                                                    data-book-id="${book.id}"
                                                                                                                    data-book-title="${fn:escapeXml(book.title)}"
                                                                                                                    onclick="confirmDelete(this)">
                                                                                                                    <i
                                                                                                                        class="fas fa-trash"></i>
                                                                                                                </button>
                                                                                                            </div>
                                                                                                        </td>
                                                                        </tr>
                                                                    </c:forEach>
                                                                </tbody>
                                                            </table>
                                                        </div>

                                                        <%-- Pagination --%>
                                                            <c:if test="${totalPages > 1}">
                                                                <div class="bl-pagination">
                                                                    <%-- Previous --%>
                                                                        <c:choose>
                                                                            <c:when test="${hasPreviousPage}">
                                                                                <c:url var="prevUrl"
                                                                                    value="/admin/books">
                                                                                    <c:param name="page"
                                                                                        value="${currentPage - 1}" />
                                                                                    <c:if
                                                                                        test="${not empty searchKeyword}">
                                                                                        <c:param name="search"
                                                                                            value="${searchKeyword}" />
                                                                                    </c:if>
                                                                                    <c:if
                                                                                        test="${selectedCategoryId != null && selectedCategoryId > 0}">
                                                                                        <c:param name="category"
                                                                                            value="${selectedCategoryId}" />
                                                                                    </c:if>
                                                                                </c:url>
                                                                                <a href="${prevUrl}"><i
                                                                                        class="fas fa-chevron-left"></i></a>
                                                                            </c:when>
                                                                            <c:otherwise><span
                                                                                    style="opacity:.35;cursor:not-allowed;border:1.5px solid var(--panel-border);background:#fff;"><i
                                                                                        class="fas fa-chevron-left"></i></span>
                                                                            </c:otherwise>
                                                                        </c:choose>

                                                                        <%-- First page + ellipsis --%>
                                                                            <c:if test="${startPage > 1}">
                                                                                <c:url var="p1Url" value="/admin/books">
                                                                                    <c:param name="page" value="1" />
                                                                                    <c:if
                                                                                        test="${not empty searchKeyword}">
                                                                                        <c:param name="search"
                                                                                            value="${searchKeyword}" />
                                                                                    </c:if>
                                                                                    <c:if
                                                                                        test="${selectedCategoryId != null && selectedCategoryId > 0}">
                                                                                        <c:param name="category"
                                                                                            value="${selectedCategoryId}" />
                                                                                    </c:if>
                                                                                </c:url>
                                                                                <a href="${p1Url}">1</a>
                                                                                <c:if test="${startPage > 2}"><span
                                                                                        class="ellipsis">…</span></c:if>
                                                                            </c:if>

                                                                            <%-- Page numbers --%>
                                                                                <c:forEach var="pageNum"
                                                                                    begin="${startPage}"
                                                                                    end="${endPage}">
                                                                                    <c:choose>
                                                                                        <c:when
                                                                                            test="${pageNum == currentPage}">
                                                                                            <span
                                                                                                class="current">${pageNum}</span>
                                                                                        </c:when>
                                                                                        <c:otherwise>
                                                                                            <c:url var="pNUrl"
                                                                                                value="/admin/books">
                                                                                                <c:param name="page"
                                                                                                    value="${pageNum}" />
                                                                                                <c:if
                                                                                                    test="${not empty searchKeyword}">
                                                                                                    <c:param
                                                                                                        name="search"
                                                                                                        value="${searchKeyword}" />
                                                                                                </c:if>
                                                                                                <c:if
                                                                                                    test="${selectedCategoryId != null && selectedCategoryId > 0}">
                                                                                                    <c:param
                                                                                                        name="category"
                                                                                                        value="${selectedCategoryId}" />
                                                                                                </c:if>
                                                                                            </c:url>
                                                                                            <a
                                                                                                href="${pNUrl}">${pageNum}</a>
                                                                                        </c:otherwise>
                                                                                    </c:choose>
                                                                                </c:forEach>

                                                                                <%-- Last page + ellipsis --%>
                                                                                    <c:if
                                                                                        test="${endPage < totalPages}">
                                                                                        <c:if
                                                                                            test="${endPage < totalPages - 1}">
                                                                                            <span
                                                                                                class="ellipsis">…</span>
                                                                                        </c:if>
                                                                                        <c:url var="pLastUrl"
                                                                                            value="/admin/books">
                                                                                            <c:param name="page"
                                                                                                value="${totalPages}" />
                                                                                            <c:if
                                                                                                test="${not empty searchKeyword}">
                                                                                                <c:param name="search"
                                                                                                    value="${searchKeyword}" />
                                                                                            </c:if>
                                                                                            <c:if
                                                                                                test="${selectedCategoryId != null && selectedCategoryId > 0}">
                                                                                                <c:param name="category"
                                                                                                    value="${selectedCategoryId}" />
                                                                                            </c:if>
                                                                                        </c:url>
                                                                                        <a
                                                                                            href="${pLastUrl}">${totalPages}</a>
                                                                                    </c:if>

                                                                                    <%-- Next --%>
                                                                                        <c:choose>
                                                                                            <c:when
                                                                                                test="${hasNextPage}">
                                                                                                <c:url var="nextUrl"
                                                                                                    value="/admin/books">
                                                                                                    <c:param name="page"
                                                                                                        value="${currentPage + 1}" />
                                                                                                    <c:if
                                                                                                        test="${not empty searchKeyword}">
                                                                                                        <c:param
                                                                                                            name="search"
                                                                                                            value="${searchKeyword}" />
                                                                                                    </c:if>
                                                                                                    <c:if
                                                                                                        test="${selectedCategoryId != null && selectedCategoryId > 0}">
                                                                                                        <c:param
                                                                                                            name="category"
                                                                                                            value="${selectedCategoryId}" />
                                                                                                    </c:if>
                                                                                                </c:url>
                                                                                                <a href="${nextUrl}"><i
                                                                                                        class="fas fa-chevron-right"></i></a>
                                                                                            </c:when>
                                                                                            <c:otherwise><span
                                                                                                    style="opacity:.35;cursor:not-allowed;border:1.5px solid var(--panel-border);background:#fff;"><i
                                                                                                        class="fas fa-chevron-right"></i></span>
                                                                                            </c:otherwise>
                                                                                        </c:choose>
                                                                </div>
                                                            </c:if>
                                                    </c:when>

                                                    <c:otherwise>
                                                        <div class="bl-empty">
                                                            <i class="fas fa-book-open"></i>
                                                            <h3
                                                                style="margin:0 0 6px;font-size:1rem;color:var(--panel-text);">
                                                                Không tìm thấy sách nào</h3>
                                                            <p>Thử từ khoá khác hoặc xóa bộ lọc để xem tất cả sách.</p>
                                                            <a href="${pageContext.request.contextPath}/admin/books"
                                                                class="pm-btn pm-btn-outline" style="margin-top:16px;">
                                                                <i class="fas fa-xmark"></i> Xóa bộ lọc
                                                            </a>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>

                    </main>

                    <%-- Toast auto-hide --%>
                        <script>
                            (function () {
                                const t = document.getElementById('toast-msg');
                                if (!t) return;
                                t.style.transition = 'opacity .4s ease';
                                setTimeout(() => { t.style.opacity = '0'; }, 3200);
                                setTimeout(() => { if (t.parentNode) t.parentNode.removeChild(t); }, 3700);
                            })();
                        </script>

                        <%-- Delete confirmation --%>
                            <script>
                                function confirmDelete(btn) {
                                    var bookId = btn.getAttribute('data-book-id');
                                    var bookTitle = btn.getAttribute('data-book-title');
                                    Swal.fire({
                                        title: 'Xác nhận xóa?',
                                        html: 'Bạn có chắc chắn muốn xóa cuốn sách <strong>' + bookTitle + '</strong>?<br><small style="color:#ef4444;">Hành động này không thể hoàn tác!</small>',
                                        icon: 'warning',
                                        showCancelButton: true,
                                        confirmButtonColor: '#ef4444',
                                        cancelButtonColor: '#6366f1',
                                        confirmButtonText: '<i class="fas fa-trash"></i> Đồng ý xóa',
                                        cancelButtonText: 'Hủy bỏ'
                                    }).then(function (result) {
                                        if (result.isConfirmed) {
                                            window.location.href = '${pageContext.request.contextPath}/admin/books/delete?id=' + bookId;
                                        }
                                    });
                                }
                            </script>

                </body>

                </html>