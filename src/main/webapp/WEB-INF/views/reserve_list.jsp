<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Danh sách đặt trước – LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"/>
    <link rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"/>

    <style>
        :root {
            --primary: #1a6fc4;
            --primary-light: #e8f1fb;
        }


        body {
            background: #f4f7fb;
            font-family: 'Segoe UI', sans-serif;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }


        .container.pb-5 {
            flex: 1;
        }

        /* ── Page banner ── */
        .page-banner {
            padding: 1.5rem 0;
        }

        .page-banner h3 {
            font-weight: 700;
            letter-spacing: -.3px;
        }

        /* ── Stats row ── */
        .stat-card {
            border: none;
            border-radius: 14px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, .07);
        }

        .stat-card .icon-wrap {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.25rem;
        }

        /* ── Table card ── */
        .table-card {
            border: none;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,.07);
        }

        .table thead th {
            background: #f8fafc;
            color: #64748b;
            font-size: .78rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .06em;
            border-bottom: 2px solid #e2e8f0;
            padding: .85rem 1rem;
            white-space: nowrap;
        }

        .table tbody tr {
            transition: background .15s;
        }

        .table tbody tr:hover {
            background: #f0f7ff;
        }

        .table tbody td {
            vertical-align: middle;
            padding: .85rem 1rem;
            font-size: .9rem;
            border-bottom: 1px solid #f1f5f9;
        }

        /* ── Book thumb ── */
        .book-thumb {
            width: 46px;
            height: 62px;
            object-fit: cover;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, .15);
        }

        .book-thumb-ph {
            width: 46px;
            height: 62px;
            background: #e2e8f0;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #94a3b8;
            font-size: 1.4rem;
        }

        /* ── Status badges ── */
        .badge-status {
            font-size: .74rem;
            font-weight: 600;
            padding: .35em .75em;
            border-radius: 20px;
            letter-spacing: .04em;
        }

        .badge-WAITING {
            background: #fef3c7;
            color: #92400e;
        }

        .badge-AVAILABLE {
            background: #d1fae5;
            color: #065f46;
        }

        .badge-BORROWED {
            background: #dbeafe;
            color: #1e40af;
        }

        .badge-CANCELLED {
            background: #f1f5f9;
            color: #475569;
        }

        .badge-EXPIRED {
            background: #fee2e2;
            color: #991b1b;
        }

        /* ── Cancel button ── */
        .btn-cancel {
            font-size: .8rem;
            padding: .3rem .85rem;
            border-radius: 8px;
            border: 1.5px solid #ef4444;
            color: #ef4444;
            background: transparent;
            transition: all .15s;
            white-space: nowrap;
        }

        .btn-cancel:hover {
            background: #ef4444;
            color: #fff;
        }

        /* ── Filter tabs ── */
        .filter-tabs .nav-link {
            color: #64748b;
            font-size: .85rem;
            font-weight: 500;
            border-radius: 8px;
            padding: .4rem .9rem;
            border: none;
        }

        .filter-tabs .nav-link.active {
            background: var(--primary-light);
            color: var(--primary);
            font-weight: 600;
        }

        /* ── Empty state ── */
        .empty-state {
            padding: 4rem 1rem;
        }

        .empty-state .empty-icon {
            font-size: 4rem;
            color: #cbd5e1;
        }
    </style>
</head>
<body>

<%-- ══ NAVBAR — thay bằng jsp:include header của project ══ --%>
<jsp:include page="/WEB-INF/views/header.jsp"/>

<%-- ══ BANNER ══ --%>
<div class="page-banner">
    <div class="container">
        <div class="d-flex align-items-center gap-3">
            <i class="bi bi-bookmark-star fs-2"></i>
            <div>
                <h3 class="mb-0">Danh sách đặt trước</h3>
                <p class="mb-0 opacity-75 small">
                    Theo dõi trạng thái các sách bạn đã đặt trước
                </p>
            </div>
        </div>
    </div>
</div>

<%-- ══ MAIN ══ --%>
<div class="container pb-5">

    <%-- Flash messages --%>
    <c:if test="${not empty sessionScope.successMsg}">
        <div class="alert alert-success d-flex align-items-center gap-2 mt-4 rounded-3 shadow-sm">
            <i class="bi bi-check-circle-fill fs-5"></i>
            <span>${sessionScope.successMsg}</span>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="successMsg" scope="session"/>
    </c:if>
    <c:if test="${not empty sessionScope.errorMsg}">
        <div class="alert alert-danger d-flex align-items-center gap-2 mt-4 rounded-3 shadow-sm">
            <i class="bi bi-x-circle-fill fs-5"></i>
            <span>${sessionScope.errorMsg}</span>
            <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
        </div>
        <c:remove var="errorMsg" scope="session"/>
    </c:if>

    <%-- ── Stats (chỉ hiện khi có dữ liệu) ── --%>
    <c:if test="${not empty reservations}">
        <c:set var="cntWaiting" value="0"/>
        <c:set var="cntAvail" value="0"/>
        <c:set var="cntBorrowed" value="0"/>
        <c:forEach var="r" items="${reservations}">
            <c:if test="${r.status == 'WAITING'}">
                <c:set var="cntWaiting" value="${cntWaiting  + 1}"/>
            </c:if>
            <c:if test="${r.status == 'AVAILABLE'}">
                <c:set var="cntAvail" value="${cntAvail    + 1}"/>
            </c:if>
            <c:if test="${r.status == 'BORROWED'}">
                <c:set var="cntBorrowed" value="${cntBorrowed + 1}"/>
            </c:if>
        </c:forEach>

        <div class="row g-3 mt-3 mb-3">
            <div class="col-6 col-md-3">
                <div class="card stat-card p-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="icon-wrap bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-list-ul"></i>
                        </div>
                        <div>
                            <div class="fw-bold fs-5">${reservations.size()}</div>
                            <div class="text-muted small">Tổng</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-card p-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="icon-wrap" style="background:#fef3c7;color:#92400e">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                        <div>
                            <div class="fw-bold fs-5">${cntWaiting}</div>
                            <div class="text-muted small">Đang chờ</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-card p-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="icon-wrap" style="background:#d1fae5;color:#065f46">
                            <i class="bi bi-check-circle"></i>
                        </div>
                        <div>
                            <div class="fw-bold fs-5">${cntAvail}</div>
                            <div class="text-muted small">Sẵn sàng</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-6 col-md-3">
                <div class="card stat-card p-3">
                    <div class="d-flex align-items-center gap-3">
                        <div class="icon-wrap" style="background:#dbeafe;color:#1e40af">
                            <i class="bi bi-book"></i>
                        </div>
                        <div>
                            <div class="fw-bold fs-5">${cntBorrowed}</div>
                            <div class="text-muted small">Đã mượn</div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </c:if>

    <%-- ── Table card ── --%>
    <div class="card table-card">

        <div class="card-header bg-white border-0 px-4 pt-4 pb-2
                    d-flex flex-wrap align-items-center justify-content-between gap-3">

            <ul class="nav filter-tabs gap-1" id="statusFilter">
                <li class="nav-item">
                    <a class="nav-link active" href="#" data-filter="ALL">Tất cả</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-filter="WAITING">
                        <i class="bi bi-hourglass-split me-1"></i>Đang chờ
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-filter="AVAILABLE">
                        <i class="bi bi-check-circle me-1"></i>Sẵn sàng
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-filter="BORROWED">
                        <i class="bi bi-book me-1"></i>Đã mượn
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#" data-filter="CANCELLED">
                        <i class="bi bi-x-circle me-1"></i>Đã hủy
                    </a>
                </li>
            </ul>

            <a href="${pageContext.request.contextPath}/books"
               class="btn btn-primary btn-sm rounded-pill px-3">
                <i class="bi bi-plus-lg me-1"></i>Đặt thêm sách
            </a>
        </div>

        <div class="card-body p-0">

            <%-- Empty state --%>
            <c:if test="${empty reservations}">
                <div class="empty-state text-center">
                    <div class="empty-icon mb-3"><i class="bi bi-bookmark-x"></i></div>
                    <h5 class="text-muted fw-semibold">Chưa có sách đặt trước nào</h5>
                    <p class="text-muted small mb-4">
                        Khi sách bạn muốn mượn hết hàng, hãy đặt trước để được<br/>
                        thông báo ngay khi sách có sẵn.
                    </p>
                    <a href="${pageContext.request.contextPath}/books"
                       class="btn btn-primary rounded-pill px-4">
                        <i class="bi bi-search me-1"></i>Tìm sách ngay
                    </a>
                </div>
            </c:if>

            <%-- Table --%>
            <c:if test="${not empty reservations}">
                <div class="table-responsive">
                    <table class="table mb-0" id="resTable">
                        <thead>
                        <tr>
                            <th style="width:46px">#</th>
                            <th>Sách</th>
                            <th>Trạng thái</th>
                            <th>Ngày đặt</th>
                            <th>Hạn lấy</th>
                            <th style="width:110px">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="res" items="${reservations}" varStatus="loop">
                            <tr data-status="${res.status}">

                                    <%-- STT --%>
                                <td class="text-muted small">${loop.index + 1}</td>

                                    <%-- Sách --%>
                                <td>
                                    <div class="d-flex align-items-center gap-3">
                                        <c:choose>
                                            <c:when test="${not empty res.bookImage}">
                                                <img src="${pageContext.request.contextPath}/${res.bookImage}"
                                                     alt="${res.bookTitle}"
                                                     class="book-thumb flex-shrink-0"/>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="book-thumb-ph flex-shrink-0">
                                                    <i class="bi bi-book"></i>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                        <div>
                                            <div class="fw-semibold"
                                                 style="max-width:220px;white-space:nowrap;
                                                        overflow:hidden;text-overflow:ellipsis"
                                                 title="${res.bookTitle}">
                                                    ${res.bookTitle}
                                            </div>
                                            <div class="text-muted small">
                                                <i class="bi bi-person me-1"></i>${res.bookAuthor}
                                            </div>
                                        </div>
                                    </div>
                                </td>

                                    <%-- Trạng thái --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.status == 'WAITING'}">
                                            <span class="badge-status badge-WAITING">
                                                <i class="bi bi-hourglass-split me-1"></i>Đang chờ
                                            </span>
                                        </c:when>
                                        <c:when test="${res.status == 'AVAILABLE'}">
                                            <span class="badge-status badge-AVAILABLE">
                                                <i class="bi bi-check-circle me-1"></i>Sẵn sàng nhận
                                            </span>
                                        </c:when>
                                        <c:when test="${res.status == 'BORROWED'}">
                                            <span class="badge-status badge-BORROWED">
                                                <i class="bi bi-book me-1"></i>Đã mượn
                                            </span>
                                        </c:when>
                                        <c:when test="${res.status == 'CANCELLED'}">
                                            <span class="badge-status badge-CANCELLED">
                                                <i class="bi bi-x-circle me-1"></i>Đã hủy
                                            </span>
                                        </c:when>
                                        <c:when test="${res.status == 'EXPIRED'}">
                                            <span class="badge-status badge-EXPIRED">
                                                <i class="bi bi-clock-history me-1"></i>Hết hạn
                                            </span>
                                        </c:when>
                                    </c:choose>
                                </td>

                                    <%-- Ngày đặt --%>
                                <td class="text-muted small">
                                    <fmt:formatDate value="${res.createdAt}" pattern="dd/MM/yyyy"/>
                                    <br/>
                                    <span class="opacity-75">
                                        <fmt:formatDate value="${res.createdAt}" pattern="HH:mm"/>
                                    </span>
                                </td>

                                    <%-- Hạn lấy --%>
                                <td class="small">
                                    <c:choose>
                                        <c:when test="${not empty res.expiredAt}">
                                            <span class="text-danger fw-semibold">
                                                <i class="bi bi-alarm me-1"></i>
                                                <fmt:formatDate value="${res.expiredAt}"
                                                                pattern="dd/MM/yyyy"/>
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                                    <%-- Thao tác --%>
                                <td>
                                    <c:choose>
                                        <c:when test="${res.status == 'WAITING' || res.status == 'AVAILABLE'}">
                                            <form method="post"
                                                  action="${pageContext.request.contextPath}/reservation"
                                                  onsubmit="return confirmCancel(this)">
                                                <input type="hidden" name="action" value="cancel"/>
                                                <input type="hidden" name="resId" value="${res.id}"/>
                                                <button type="submit" class="btn-cancel">
                                                    <i class="bi bi-trash3 me-1"></i>Hủy
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="text-muted small">—</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>

                            </tr>
                        </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>

        </div>
    </div>
    <%-- end .table-card --%>

</div>
<%-- end .container --%>

<%-- ══ FOOTER — thay bằng jsp:include footer của project ══ --%>

<jsp:include page="/WEB-INF/views/footer.jsp"/>


<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Filter theo status
    document.querySelectorAll('#statusFilter .nav-link').forEach(function (tab) {
        tab.addEventListener('click', function (e) {
            e.preventDefault();
            document.querySelectorAll('#statusFilter .nav-link')
                .forEach(function (t) {
                    t.classList.remove('active');
                });
            this.classList.add('active');

            var filter = this.dataset.filter;
            document.querySelectorAll('#resTable tbody tr').forEach(function (row) {
                row.style.display =
                    (filter === 'ALL' || row.dataset.status === filter) ? '' : 'none';
            });
        });
    });

    // Confirm hủy + disable button tránh double submit
    function confirmCancel(form) {
        if (!confirm('Bạn có chắc muốn hủy đặt trước này?')) return false;
        var btn = form.querySelector('button[type="submit"]');
        btn.disabled = true;
        btn.innerHTML = '<span class="spinner-border spinner-border-sm"></span>';
        return true;
    }
</script>
</body>
</html>
