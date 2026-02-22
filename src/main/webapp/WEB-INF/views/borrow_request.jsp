<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>Tra cứu sách - LBMS</title>
  <style>
    :root {
      --primary: #4361ee;
      --primary-hover: #3a53d0;
      --success: #2ecc71;
      --bg: #f4f7f6;
      --text: #333;
      --border: #e2e8f0;
    }
    body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: var(--bg); color: var(--text); max-width: 1100px; margin: 40px auto; padding: 0 20px; line-height: 1.6; }
    .container { background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); padding: 24px; }
    .top { display: flex; flex-wrap: wrap; gap: 20px; align-items: center; justify-content: space-between; margin-bottom: 25px; border-bottom: 2px solid var(--border); padding-bottom: 20px; }
    h2 { margin: 0; color: #2c3e50; font-size: 24px; }
    
    /* Search form */
    .search-box { display: flex; gap: 8px; }
    .search-input { padding: 10px 16px; border: 1px solid #cbd5e1; border-radius: 8px; min-width: 300px; font-size: 14px; outline: none; transition: all 0.2s; }
    .search-input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.15); }
    
    /* Nút bấm */
    .btn { display: inline-flex; align-items: center; justify-content: center; padding: 10px 18px; border-radius: 8px; border: none; font-size: 14px; font-weight: 500; text-decoration: none; cursor: pointer; transition: all 0.2s; background: #f1f5f9; color: #475569; }
    .btn:hover { background: #e2e8f0; transform: translateY(-1px); }
    .btn-primary { background: var(--primary); color: #fff; }
    .btn-primary:hover { background: var(--primary-hover); box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2); color: #fff; }
    .btn-disabled { background: #f1f5f9; color: #94a3b8; cursor: not-allowed; }
    
    table { width: 100%; border-collapse: collapse; }
    th { background: #f8fafc; color: #64748b; font-weight: 600; text-transform: uppercase; font-size: 13px; padding: 14px 15px; text-align: left; border-bottom: 2px solid var(--border); }
    td { padding: 16px 15px; border-bottom: 1px solid var(--border); vertical-align: middle; }
    tr:hover td { background-color: #f8fafc; }
    
    .err { background: #fff0f0; color: #e74c3c; padding: 12px 16px; border-radius: 8px; border-left: 4px solid #e74c3c; margin-bottom: 20px; font-weight: 500; }
    .muted { color: #64748b; font-size: 13px; }
    .qty-badge { display: inline-block; padding: 4px 12px; border-radius: 20px; font-weight: bold; font-size: 13px; background: #e8f5e9; color: #2e7d32; }
    .qty-out { background: #f1f5f9; color: #94a3b8; }
  </style>
</head>
<body>
  <div class="container">
    <div class="top">
      <div>
        <h2>🔍 Tra cứu & Mượn sách</h2>
        <div style="margin-top: 10px;">
          <a class="btn" href="${pageContext.request.contextPath}/borrow/history">⬅ Quay lại Lịch sử</a>
        </div>
      </div>

      <form class="search-box" method="get" action="${pageContext.request.contextPath}/borrow/request">
        <input class="search-input" name="q" value="${q}" placeholder="Nhập tên sách, tác giả hoặc ISBN..." />
        <button type="submit" class="btn btn-primary">Tìm kiếm</button>
      </form>
    </div>

    <c:if test="${not empty error}">
      <div class="err">⚠️ ${error}</div>
    </c:if>

    <table>
      <thead>
      <tr>
        <th>Mã</th>
        <th>Thông tin sách</th>
        <th>Số lượng</th>
        <th width="150">Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${books}" var="b">
        <tr>
          <td><strong style="color: #475569;">#${b.bookId}</strong></td>
          <td>
            <div style="font-size: 16px; font-weight: 600; color: var(--primary); margin-bottom: 4px;">${b.title}</div>
            <div class="muted">Tác giả: ${b.author} | ISBN: ${b.isbn}</div>
          </td>
          <td>
            <c:choose>
              <c:when test="${b.quantity > 0}">
                <span class="qty-badge">${b.quantity} khả dụng</span>
              </c:when>
              <c:otherwise>
                <span class="qty-badge qty-out">Đã hết sách</span>
              </c:otherwise>
            </c:choose>
          </td>
          <td>
            <c:choose>
              <c:when test="${b.quantity > 0}">
                <form method="post" action="${pageContext.request.contextPath}/borrow/request" style="margin:0;">
                  <input type="hidden" name="bookId" value="${b.bookId}" />
                  <button type="submit" class="btn btn-primary">Mượn ngay</button>
                </form>
              </c:when>
              <c:otherwise>
                <form method="post" action="${pageContext.request.contextPath}/reservations/create" style="margin:0;">
                  <input type="hidden" name="bookId" value="${b.bookId}" />
                  <button type="submit" class="btn btn-disabled" disabled>Tạm hết</button>
                </form>
              </c:otherwise>
            </c:choose>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty books}">
        <tr><td colspan="4" style="text-align:center; padding:40px;" class="muted">Không tìm thấy sách nào phù hợp với từ khóa của bạn.</td></tr>
      </c:if>
      </tbody>
    </table>
  </div>
</body>
</html>