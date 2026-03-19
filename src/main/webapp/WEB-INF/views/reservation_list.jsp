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
        <style>
          :root {
            --res-gradient: linear-gradient(135deg, #0c6cd0 0%, #2f49f5 65%, #7c3aed 100%);
            --res-border: #dfe4ff;
            --res-bg: #f4f6fb;
          }

          body {
            background: var(--res-bg);
          }

          main {
            padding-bottom: 80px;
          }

          /* ── HERO ── */
          .res-hero {
            padding: 60px 0 50px;
            background: var(--res-gradient);
            color: white;
            position: relative;
            overflow: hidden;
          }

          .res-hero::after {
            content: '';
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at top right, rgba(255, 255, 255, 0.35), transparent 55%);
            pointer-events: none;
          }

          .res-hero__inner {
            position: relative;
            z-index: 1;
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 28px;
            align-items: center;
          }

          .res-hero__eyebrow {
            font-size: 0.75rem;
            letter-spacing: 0.3em;
            text-transform: uppercase;
            color: rgba(255, 255, 255, 0.8);
            margin: 0 0 10px;
          }

          .res-hero__title {
            font-size: clamp(26px, 4vw, 42px);
            font-weight: 700;
            line-height: 1.2;
            margin: 0 0 10px;
          }

          .res-hero__subtitle {
            font-size: 1rem;
            color: rgba(255, 255, 255, 0.9);
            margin: 0;
          }

          .res-hero__card {
            background: rgba(255, 255, 255, 0.15);
            border: 1px solid rgba(255, 255, 255, 0.3);
            border-radius: 20px;
            padding: 22px 26px;
            box-shadow: 0 20px 35px rgba(12, 108, 208, 0.35);
          }

          .res-hero__card h3 {
            margin: 0 0 6px;
            font-size: 0.85rem;
            letter-spacing: 0.15em;
            text-transform: uppercase;
            color: rgba(255, 255, 255, 0.85);
          }

          .res-hero__stat {
            font-size: 2.8rem;
            font-weight: 700;
            line-height: 1;
            margin-bottom: 6px;
          }

          .res-hero__card small {
            font-size: 0.85rem;
            color: rgba(255, 255, 255, 0.8);
          }

          /* ── CONTENT ── */
          .res-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 36px 20px 0;
          }

          /* ── FLASH ── */
          .res-flash {
            padding: 14px 18px;
            border-radius: 12px;
            background: #eef2ff;
            border: 1px solid #c7d3ff;
            color: #1b1f3b;
            font-weight: 600;
            margin-bottom: 24px;
            box-shadow: inset 0 1px 0 rgba(255, 255, 255, 0.6);
          }

          /* ── FILTER PILLS ── */
          .res-filter {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-bottom: 28px;
            justify-content: flex-start;
          }

          .res-filter__pill {
            border: 1px solid rgba(15, 23, 42, 0.15);
            border-radius: 999px;
            padding: 8px 20px;
            font-size: 0.82rem;
            font-weight: 600;
            letter-spacing: 0.05em;
            text-transform: uppercase;
            color: #475569;
            text-decoration: none;
            background: #fff;
            transition: all 0.2s ease;
            cursor: pointer;
          }

          .res-filter__pill.is-active,
          .res-filter__pill:hover {
            background: linear-gradient(120deg, #0c6cd0, #2f49f5);
            color: white;
            border-color: transparent;
            box-shadow: 0 10px 30px rgba(15, 23, 42, 0.18);
          }

          /* ── TABLE ── */
          .res-table-wrap {
            background: #fff;
            border-radius: 20px;
            border: 1px solid var(--res-border);
            box-shadow: 0 10px 40px rgba(15, 23, 42, 0.08);
            overflow: hidden;
          }

          .res-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.875rem;
          }

          .res-table thead th {
            background: #f8fafc;
            color: #64748b;
            font-weight: 600;
            font-size: 0.72rem;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            padding: 14px 20px;
            text-align: left;
            border-bottom: 1px solid var(--res-border);
          }

          .res-table tbody tr {
            border-bottom: 1px solid #f0f4ff;
            transition: background 0.1s ease;
          }

          .res-table tbody tr:last-child {
            border-bottom: none;
          }

          .res-table tbody tr:hover {
            background: #f8fafc;
          }

          .res-table td {
            padding: 16px 20px;
            vertical-align: middle;
            color: #374151;
          }

          .res-table td.td-id {
            color: #94a3b8;
            font-size: 0.8rem;
            font-weight: 600;
          }

          /* Book cell */
          .book-cell {
            display: flex;
            align-items: center;
            gap: 12px;
          }

          .book-icon {
            width: 38px;
            height: 38px;
            border-radius: 10px;
            background: #eff6ff;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
            color: #2563eb;
            font-size: 1rem;
          }

          .book-title {
            font-weight: 600;
            color: #0f172a;
            font-size: 0.88rem;
          }

          .book-meta {
            font-size: 0.76rem;
            color: #94a3b8;
            margin-top: 2px;
          }

          /* User cell */
          .user-name {
            font-weight: 600;
            color: #0f172a;
            font-size: 0.88rem;
          }

          .user-sub {
            font-size: 0.77rem;
            color: #94a3b8;
            margin-top: 1px;
          }

          /* Date cell */
          .date-text {
            font-size: 0.83rem;
            color: #64748b;
            white-space: nowrap;
          }

          /* Status badges */
          .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 4px 12px;
            border-radius: 999px;
            font-size: 0.72rem;
            font-weight: 700;
            letter-spacing: 0.06em;
            text-transform: uppercase;
            border: 1px solid transparent;
            white-space: nowrap;
          }

          .status-badge__dot {
            width: 5px;
            height: 5px;
            border-radius: 50%;
            flex-shrink: 0;
          }

          .badge-waiting {
            background: #fffbeb;
            color: #92400e;
            border-color: #fcd34d;
          }

          .badge-waiting .status-badge__dot {
            background: #d97706;
          }

          .badge-notified {
            background: #eff6ff;
            color: #1e40af;
            border-color: #93c5fd;
          }

          .badge-notified .status-badge__dot {
            background: #2563eb;
          }

          .badge-expired {
            background: #fef2f2;
            color: #991b1b;
            border-color: #fca5a5;
          }

          .badge-expired .status-badge__dot {
            background: #dc2626;
          }

          .badge-cancelled {
            background: #f1f5f9;
            color: #475569;
            border-color: #cbd5e1;
          }

          .badge-cancelled .status-badge__dot {
            background: #94a3b8;
          }

          /* Action buttons */
          .action-cell {
            display: flex;
            gap: 8px;
          }

          .btn-cancel {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            padding: 7px 14px;
            border-radius: 10px;
            font-size: 0.78rem;
            font-weight: 600;
            background: #fef2f2;
            color: #b91c1c;
            border: 1px solid #fca5a5;
            text-decoration: none;
            cursor: pointer;
            transition: background 0.15s ease;
          }

          .btn-cancel:hover {
            background: #fee2e2;
          }

          form.inline-form {
            margin: 0;
          }

          /* Empty state */
          .res-empty {
            padding: 60px 20px;
            text-align: center;
            color: #64748b;
          }

          .res-empty__icon {
            font-size: 2.5rem;
            margin-bottom: 12px;
          }

          .res-empty h2 {
            margin: 0 0 8px;
            color: #0f172a;
          }

          .res-empty p {
            font-size: 0.9rem;
            margin: 0 0 18px;
          }

          @media (max-width: 768px) {
            .res-table thead {
              display: none;
            }

            .res-table tbody tr {
              display: block;
              padding: 14px 16px;
              border-bottom: 1px solid #f0f4ff;
            }

            .res-table td {
              display: block;
              padding: 4px 0;
              border: none;
            }

            .res-table td::before {
              content: attr(data-label) ': ';
              font-weight: 700;
              font-size: 0.68rem;
              color: #94a3b8;
              text-transform: uppercase;
              letter-spacing: 0.05em;
            }

            .res-table td.td-id {
              display: none;
            }
          }
        </style>
      </head>

      <body>
        <jsp:include page="header.jsp" />

        <c:set var="totalRes" value="${empty reservations ? 0 : fn:length(reservations)}" />
        <c:set var="filterParam" value="${not empty param.status ? param.status : 'all'}" />

        <section class="res-hero">
          <div class="res-hero__inner">
            <div>
              <p class="res-hero__eyebrow">Đặt trước</p>
              <h1 class="res-hero__title">Danh sách đặt trước sách</h1>
              <p class="res-hero__subtitle">Theo dõi trạng thái các đầu sách bạn đã đặt trước trong thư viện.</p>
            </div>
            <div class="res-hero__card">
              <h3>Tổng đặt trước</h3>
              <div class="res-hero__stat">${totalRes}</div>
              <small>phiếu đang theo dõi</small>
            </div>
          </div>
        </section>

        <main>
          <div class="res-content">
            <c:if test="${not empty flash}">
              <div class="res-flash">${flash}</div>
            </c:if>

            <div class="res-filter">
              <a class="res-filter__pill ${filterParam == 'all' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations">Tất cả</a>
              <a class="res-filter__pill ${filterParam == 'WAITING' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=WAITING">Đang chờ</a>
              <a class="res-filter__pill ${filterParam == 'NOTIFIED' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=NOTIFIED">Đã thông báo</a>
              <a class="res-filter__pill ${filterParam == 'EXPIRED' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=EXPIRED">Hết hạn</a>
              <a class="res-filter__pill ${filterParam == 'CANCELLED' ? 'is-active' : ''}"
                href="${pageContext.request.contextPath}/reservations?status=CANCELLED">Đã hủy</a>
            </div>

            <c:choose>
              <c:when test="${empty reservations}">
                <div class="res-empty">
                  <div class="res-empty__icon">📚</div>
                  <h2>Chưa có đặt trước nào</h2>
                  <p>Bạn chưa đặt trước cuốn sách nào. Hãy khám phá thư viện và đặt trước khi sách chưa có sẵn.</p>
                  <a href="${pageContext.request.contextPath}/books" class="btn primary">Khám phá thư viện</a>
                </div>
              </c:when>
              <c:otherwise>
                <div class="res-table-wrap">
                  <table class="res-table">
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
                            <div class="book-cell">
                              <div class="book-icon">📖</div>
                              <div>
                                <div class="book-title">${r.book.title}</div>
                                <div class="book-meta">${r.book.author}<c:if test="${not empty r.book.isbn}"> ·
                                    ${r.book.isbn}</c:if>
                                </div>
                              </div>
                            </div>
                          </td>

                          <c:if test="${isStaff}">
                            <td data-label="Người dùng">
                              <div class="user-name">${r.user.fullName}</div>
                              <div class="user-sub">${r.user.email}</div>
                            </td>
                          </c:if>

                          <td data-label="Trạng thái">
                            <c:choose>
                              <c:when test="${r.status == 'WAITING'}">
                                <span class="status-badge badge-waiting">
                                  <span class="status-badge__dot"></span>Đang chờ
                                </span>
                              </c:when>
                              <c:when test="${r.status == 'NOTIFIED'}">
                                <span class="status-badge badge-notified">
                                  <span class="status-badge__dot"></span>Đã thông báo
                                </span>
                              </c:when>
                              <c:when test="${r.status == 'EXPIRED'}">
                                <span class="status-badge badge-expired">
                                  <span class="status-badge__dot"></span>Hết hạn
                                </span>
                              </c:when>
                              <c:when test="${r.status == 'CANCELLED'}">
                                <span class="status-badge badge-cancelled">
                                  <span class="status-badge__dot"></span>Đã hủy
                                </span>
                              </c:when>
                              <c:otherwise>
                                <span class="status-badge badge-waiting">
                                  <span class="status-badge__dot"></span>${r.status}
                                </span>
                              </c:otherwise>
                            </c:choose>
                          </td>

                          <td data-label="Ngày tạo">
                            <span class="date-text">${r.createdAt}</span>
                          </td>

                          <td data-label="Thao tác">
                            <div class="action-cell">
                              <c:if test="${not isStaff}">
                                <c:if test="${r.status == 'WAITING' || r.status == 'NOTIFIED'}">
                                  <form class="inline-form" method="post"
                                    action="${pageContext.request.contextPath}/reservations/cancel"
                                    onsubmit="return confirm('Hủy đặt trước cuốn sách này?');">
                                    <input type="hidden" name="id" value="${r.id}" />
                                    <button type="submit" class="btn-cancel">✕ Hủy</button>
                                  </form>
                                </c:if>
                              </c:if>
                              <c:if test="${isStaff && (r.status == 'WAITING' || r.status == 'NOTIFIED')}">
                                <form class="inline-form" method="post"
                                  action="${pageContext.request.contextPath}/reservations/cancel"
                                  onsubmit="return confirm('Hủy đặt trước của người dùng này?');">
                                  <input type="hidden" name="id" value="${r.id}" />
                                  <button type="submit" class="btn-cancel">✕ Hủy</button>
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