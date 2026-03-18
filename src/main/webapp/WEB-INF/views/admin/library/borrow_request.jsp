<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Yêu cầu mượn sách - LBMS</title>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
      <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
      <style>
        .table-wrap {
          overflow-x: auto;
        }

        table {
          width: 100%;
          border-collapse: collapse;
        }

        th,
        td {
          padding: 14px 16px;
          text-align: left;
          vertical-align: middle;
          border-top: 1px solid #eef2f7;
        }

        th {
          font-size: 11.5px;
          text-transform: uppercase;
          letter-spacing: .08em;
          color: #64748b;
          font-weight: 700;
          background: #f8fafc;
          white-space: nowrap;
        }

        td {
          font-size: 14px;
          color: #1e293b;
        }

        tr:hover td {
          background: #f8fafc;
        }

        .status-available {
          color: #16a34a;
          font-weight: 600;
        }

        .status-unavailable {
          color: #dc2626;
          font-weight: 600;
        }
      </style>
    </head>

    <body class="panel-body">
      <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

      <main class="panel-main">
        <div class="pm-header">
          <h1 class="pm-title">Tạo yêu cầu mượn</h1>
          <p class="pm-subtitle">Tìm kiếm sách và tạo phiếu mượn cho độc giả.</p>
        </div>

        <div class="pm-toolbar">
          <form method="get" action="${pageContext.request.contextPath}/borrow/request"
            style="display:flex;gap:12px;align-items:center;flex-wrap:wrap;">
            <input name="q" value="${q}" placeholder="Tìm theo tên/tác giả/ISBN..."
              style="padding:10px 14px;border:1px solid #cbd5e1;border-radius:10px;font-size:14px;min-width:280px;outline:none;" />
            <button type="submit" class="btn-modern primary" style="padding:10px 20px;">
              <i class="fas fa-search"></i> Tìm kiếm
            </button>
          </form>
          <div style="display:flex;gap:8px;">
            <a class="btn-modern secondary" href="${pageContext.request.contextPath}/staff/borrowlibrary"
              style="padding:10px 16px;font-size:13px;">
              <i class="fas fa-list"></i> Danh sách phiếu
            </a>
          </div>
        </div>

        <c:if test="${not empty error}">
          <div
            style="background:#fee2e2;border:1px solid #fecaca;color:#dc2626;padding:12px 16px;border-radius:10px;margin-bottom:20px;font-size:14px;font-weight:600;">
            <i class="fas fa-exclamation-circle"></i> ${error}
          </div>
        </c:if>

        <div class="pm-card" style="padding:0;">
          <div class="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>ID</th>
                  <th>ISBN</th>
                  <th>Tên sách</th>
                  <th>Tác giả</th>
                  <th>Số lượng</th>
                  <th>Trạng thái</th>
                  <th>Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach items="${books}" var="b">
                  <tr>
                    <td><span style="font-weight:600;color:#6366f1;">#${b.id}</span></td>
                    <td><code
                        style="background:#f1f5f9;padding:2px 6px;border-radius:4px;font-size:12px;">${b.isbn}</code>
                    </td>
                    <td style="font-weight:600;">${b.title}</td>
                    <td style="color:#64748b;">${b.author}</td>
                    <td style="font-weight:700;text-align:center;">${b.quantity}</td>
                    <td>
                      <c:choose>
                        <c:when test="${b.quantity > 0}">
                          <span class="status-available"><i class="fas fa-check-circle"></i> Còn sách</span>
                        </c:when>
                        <c:otherwise>
                          <span class="status-unavailable"><i class="fas fa-times-circle"></i> Hết sách</span>
                        </c:otherwise>
                      </c:choose>
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${b.quantity > 0}">
                          <form method="post" action="${pageContext.request.contextPath}/borrow/request"
                            style="margin:0;">
                            <input type="hidden" name="bookId" value="${b.id}" />
                            <button type="submit" class="btn-modern primary" style="padding:7px 14px;font-size:12px;">
                              <i class="fas fa-paper-plane"></i> Gửi yêu cầu
                            </button>
                          </form>
                        </c:when>
                        <c:otherwise>
                          <form method="post" action="${pageContext.request.contextPath}/reservations/create"
                            style="margin:0;">
                            <input type="hidden" name="bookId" value="${b.id}" />
                            <button type="submit" class="btn-modern secondary" style="padding:7px 14px;font-size:12px;">
                              <i class="fas fa-bookmark"></i> Đặt trước
                            </button>
                          </form>
                        </c:otherwise>
                      </c:choose>
                    </td>
                  </tr>
                </c:forEach>
                <c:if test="${empty books}">
                  <tr>
                    <td colspan="7" style="text-align:center;padding:40px;color:#94a3b8;">
                      <i class="fas fa-search" style="font-size:24px;display:block;margin-bottom:10px;"></i>
                      Nhập từ khóa để tìm kiếm sách.
                    </td>
                  </tr>
                </c:if>
              </tbody>
            </table>
          </div>
        </div>
      </main>
    </body>

    </html>