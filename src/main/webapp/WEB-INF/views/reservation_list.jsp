<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <!DOCTYPE html>
      <html lang="vi">

      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Đặt trước sách | LBMS Portal</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
      </head>

      <body class="mp-body">
        <jsp:include page="header.jsp" />

        <c:set var="totalRes" value="${empty reservations ? 0 : fn:length(reservations)}" />
        <c:set var="filterParam" value="${not empty param.status ? param.status : 'all'}" />

        <section class="mp-hero">
          <div class="mp-hero__inner">
            <div>
              <p class="mp-hero__eyebrow">📋 Đặt trước sách</p>
              <h1 class="mp-hero__title">Danh sách đặt trước của bạn</h1>
              <p class="mp-hero__subtitle">Theo dõi trạng thái từng đầu sách bạn đã đặt trước — từ khi chờ xếp hàng đến
                lúc sẵn sàng nhận.</p>
            </div>
            <div class="mp-hero__cards">
              <div class="mp-hero__card">
                <p class="mp-hero__card-label">Tổng đặt trước</p>
                <p class="mp-hero__card-value">${totalRes}</p>
                <p class="mp-hero__card-detail">phiếu đang theo dõi</p>
              </div>
              <div class="mp-hero__card">
                <p class="mp-hero__card-label">Trạng thái lọc</p>
                <p class="mp-hero__card-value" style="font-size:1.2rem;letter-spacing:.04em;">${not empty param.status ?
                  param.status : 'TẤT CẢ'}</p>
                <p class="mp-hero__card-detail">bộ lọc hiện tại</p>
              </div>
            </div>
          </div>
        </section>

        <main>
          <div class="mp-content">
            <c:if test="${not empty flash}">
              <div class="mp-flash">${flash}</div>
            </c:if>

            <div class="mp-filters">
              <a class="mp-pill ${filterParam == 'all' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations">Tất cả</a>
              <a class="mp-pill ${filterParam == 'WAITING' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=WAITING">Đang chờ</a>
              <a class="mp-pill ${filterParam == 'NOTIFIED' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=NOTIFIED">Đã thông báo</a>
              <a class="mp-pill ${filterParam == 'EXPIRED' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=EXPIRED">Hết hạn</a>
              <a class="mp-pill ${filterParam == 'CANCELLED' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=CANCELLED">Đã hủy</a>
            </div>

            <c:choose>
              <c:when test="${empty reservations}">
                <div class="mp-empty">
                  <div class="mp-empty__icon">📚</div>
                  <h2>Chưa có đặt trước nào</h2>
                  <p>Bạn chưa đặt trước cuốn sách nào. Hãy khám phá thư viện và đặt trước khi sách chưa có sẵn.</p>
                  <a href="${pageContext.request.contextPath}/books" class="btn primary">Khám phá thư viện</a>
                </div>
              </c:when>
              <c:otherwise>
                <div class="mp-table-wrap">
                  <table class="mp-table">
                    <thead>
                      <tr>
                        <th>#</th>
                        <th>Sách</th>
                        <c:if test="${isStaff}">
                          <th>Người dùng</th>
                        </c:if>
                        <th>Trạng thái</th>
                        <th>Ngày tạo</th>
                        <th>Thao tác</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach items="${reservations}" var="r">
                        <c:set var="statusLower" value="${fn:toLowerCase(r.status)}" />
                        <tr>
                          <td class="td-id" data-label="ID">#${r.id}</td>

                          <td data-label="Sách">
                            <div class="mp-book-cell">
                              <div class="mp-book-icon">📖</div>
                              <div>
                                <div class="mp-cell-title">${r.book.title}</div>
                                <div class="mp-cell-sub">${r.book.author}<c:if test="${not empty r.book.isbn}"> ·
                                    ${r.book.isbn}</c:if>
                                </div>
                              </div>
                            </div>
                          </td>

                          <c:if test="${isStaff}">
                            <td data-label="Người dùng">
                              <div class="mp-cell-title">${r.user.fullName}</div>
                              <div class="mp-cell-sub">${r.user.email}</div>
                            </td>
                          </c:if>

                          <td data-label="Trạng thái">
                            <c:choose>
                              <c:when test="${r.status == 'WAITING'}">
                                <span class="mp-badge mp-badge--waiting">
                                  <span class="mp-badge__dot"></span>Đang chờ
                                </span>
                              </c:when>
                              <c:when test="${r.status == 'NOTIFIED'}">
                                <span class="mp-badge mp-badge--notified">
                                  <span class="mp-badge__dot"></span>Đã thông báo
                                </span>
                              </c:when>
                              <c:when test="${r.status == 'EXPIRED'}">
                                <span class="mp-badge mp-badge--expired">
                                  <span class="mp-badge__dot"></span>Hết hạn
                                </span>
                              </c:when>
                              <c:when test="${r.status == 'CANCELLED'}">
                                <span class="mp-badge mp-badge--cancelled">
                                  <span class="mp-badge__dot"></span>Đã hủy
                                </span>
                              </c:when>
                              <c:otherwise>
                                <span class="mp-badge mp-badge--waiting">
                                  <span class="mp-badge__dot"></span>${r.status}
                                </span>
                              </c:otherwise>
                            </c:choose>
                          </td>

                          <td data-label="Ngày tạo">
                            <span class="mp-date">${r.createdAt}</span>
                          </td>

                          <td data-label="Thao tác">
                            <div class="mp-action-cell">
                              <c:if test="${not isStaff}">
                                <c:if test="${r.status == 'WAITING' || r.status == 'NOTIFIED'}">
                                  <form class="mp-inline-form" method="post"
                                    action="${pageContext.request.contextPath}/reservations/cancel"
                                    onsubmit="return confirm('Hủy đặt trước cuốn sách này?');">
                                    <input type="hidden" name="id" value="${r.id}" />
                                    <button type="submit" class="mp-btn-cancel">✕ Hủy</button>
                                  </form>
                                </c:if>
                              </c:if>
                              <c:if test="${isStaff && (r.status == 'WAITING' || r.status == 'NOTIFIED')}">
                                <form class="mp-inline-form" method="post"
                                  action="${pageContext.request.contextPath}/reservations/cancel"
                                  onsubmit="return confirm('Hủy đặt trước của người dùng này?');">
                                  <input type="hidden" name="id" value="${r.id}" />
                                  <button type="submit" class="mp-btn-cancel">✕ Hủy</button>
                                </form>
                              </c:if>
                              <c:if test="${r.status != 'WAITING' && r.status != 'NOTIFIED'}">
                                <span style="font-size:0.8rem; color:#94a3b8;">—</span>
                              </c:if>
                            </div>
                          </td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </div>
              </c:otherwise>
            </c:choose>
          </div>
        </main>

        <jsp:include page="footer.jsp" />
      </body>

      </html>