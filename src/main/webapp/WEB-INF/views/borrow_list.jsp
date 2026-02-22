<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>${pageTitle} - LBMS</title>
  <style>
    :root {
      --primary: #4361ee;
      --primary-hover: #3a53d0;
      --success: #2ecc71;
      --success-hover: #27ae60;
      --danger: #e74c3c;
      --danger-hover: #c0392b;
      --bg: #f4f7f6;
      --text: #333;
      --border: #e2e8f0;
    }
    body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: var(--bg); color: var(--text); max-width: 1200px; margin: 40px auto; padding: 0 20px; line-height: 1.6; }
    .container { background: #fff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); padding: 24px; }
    .top { display: flex; flex-wrap: wrap; gap: 15px; align-items: center; justify-content: space-between; margin-bottom: 20px; border-bottom: 2px solid var(--border); padding-bottom: 15px; }
    h2 { margin: 0; color: #2c3e50; font-size: 24px; }
    .nav-links { display: flex; gap: 10px; flex-wrap: wrap; }
    
    /* Nút bấm */
    a.btn, button.btn { display: inline-flex; align-items: center; justify-content: center; padding: 8px 16px; border-radius: 6px; border: none; font-size: 14px; font-weight: 500; text-decoration: none; cursor: pointer; transition: all 0.2s; background: #f1f5f9; color: #475569; }
    a.btn:hover, button.btn:hover { background: #e2e8f0; transform: translateY(-1px); }
    .btn-primary { background: var(--primary); color: #fff !important; }
    .btn-primary:hover { background: var(--primary-hover); box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2); }
    .btn-success { background: var(--success); color: #fff !important; }
    .btn-success:hover { background: var(--success-hover); box-shadow: 0 4px 12px rgba(46, 204, 113, 0.2); }
    .btn-danger { background: #fff0f0; color: var(--danger) !important; border: 1px solid #ffdcdc; }
    .btn-danger:hover { background: var(--danger); color: #fff !important; }
    
    /* Bảng */
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { background: #f8fafc; color: #64748b; font-weight: 600; text-transform: uppercase; font-size: 13px; padding: 12px 15px; text-align: left; border-bottom: 2px solid var(--border); }
    td { padding: 15px; border-bottom: 1px solid var(--border); vertical-align: middle; font-size: 14px; }
    tr:hover td { background-color: #f8fafc; }
    
    /* Tag trạng thái */
    .tag { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 600; text-align: center; }
    .tag-requested { background: #e1f5fe; color: #0288d1; }
    .tag-borrowed { background: #fff8e1; color: #f57c00; }
    .tag-returned { background: #e8f5e9; color: #2e7d32; }
    .tag-rejected { background: #ffebee; color: #c62828; }
    .tag-overdue { background: #ffebee; color: #c62828; border: 1px solid #ffcdd2; }
    
    .barcode-input { padding: 8px 12px; border: 1px solid #cbd5e1; border-radius: 6px; width: 140px; font-size: 13px; outline: none; transition: border 0.2s; }
    .barcode-input:focus { border-color: var(--primary); box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.15); }
    .muted { color: #64748b; font-size: 13px; margin-top: 4px; }
    .flash { margin-bottom: 20px; padding: 12px 16px; border-left: 4px solid var(--success); border-radius: 4px; background: #f0fdf4; color: #166534; font-weight: 500; }
  </style>
</head>
<body>
  <c:set var="roleName" value="${sessionScope.currentUser.role.name}" />
  <c:set var="isStaff" value="${roleName == 'ADMIN' || roleName == 'LIBRARIAN'}" />

  <div class="container">
    <div class="top">
      <div>
        <h2>📘 ${pageTitle}</h2>
        <div class="nav-links" style="margin-top: 10px;">
          <c:if test="${isStaff}">
            <a class="btn" href="${pageContext.request.contextPath}/borrow/requests">⏳ Chờ duyệt</a>
          </c:if>
          <a class="btn" href="${pageContext.request.contextPath}/borrow/history">📜 Lịch sử</a>
          <c:if test="${isStaff}">
            <a class="btn btn-danger" href="${pageContext.request.contextPath}/borrow/overdue">⚠️ Quá hạn</a>
          </c:if>
          <a class="btn" href="${pageContext.request.contextPath}/books">📚 Quản lý Sách</a>
        </div>
      </div>
      <div>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/borrow/request">+ Yêu cầu mượn sách</a>
      </div>
    </div>

    <c:if test="${not empty flash}">
      <div class="flash">✓ ${flash}</div>
    </c:if>

    <table>
      <thead>
      <tr>
        <th>Mã</th>
        <th>Mã vạch</th>
        <th>Người mượn</th>
        <th>Đầu sách</th>
        <th>Thời gian</th>
        <th>Trạng thái</th>
        <th>Tiền phạt</th>
        <th width="200">Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${records}" var="r">
        <tr>
          <td><strong>#${r.id}</strong></td>
          <td>
            <c:choose>
              <c:when test="${not empty r.bookCopy.barcode}">
                <span class="tag" style="background: #e2e8f0; color: #334155; font-family: monospace; font-size: 13px;">${r.bookCopy.barcode}</span>
              </c:when>
              <c:otherwise><span class="muted">-</span></c:otherwise>
            </c:choose>
          </td>
          <td>
            <div style="font-weight: 500; color: var(--text);">${r.user.fullName}</div>
            <div class="muted">${r.user.email}</div>
          </td>
          <td>
            <div style="font-weight: 500; color: var(--primary);">${r.book.title}</div>
            <div class="muted">ISBN: ${r.book.isbn}</div>
          </td>
          <td>
            <div class="muted">Mượn: ${r.borrowDate != null ? r.borrowDate : '-'}</div>
            <div class="muted" style="color: ${r.status == 'BORROWED' ? '#e74c3c' : '#64748b'}">Hạn: ${r.dueDate != null ? r.dueDate : '-'}</div>
          </td>
          <td>
            <c:choose>
              <c:when test="${r.status == 'REQUESTED'}"><span class="tag tag-requested">Chờ duyệt</span></c:when>
              <c:when test="${r.status == 'BORROWED'}"><span class="tag tag-borrowed">Đang mượn</span></c:when>
              <c:when test="${r.status == 'RETURNED'}"><span class="tag tag-returned">Đã trả</span></c:when>
              <c:when test="${r.status == 'REJECTED'}"><span class="tag tag-rejected">Từ chối</span></c:when>
              <c:otherwise><span class="tag tag-overdue">${r.status}</span></c:otherwise>
            </c:choose>
          </td>
          <td>
            <c:if test="${r.fineAmount > 0}"><strong style="color:var(--danger);">${r.fineAmount} đ</strong></c:if>
            <c:if test="${r.fineAmount == 0}"><span class="muted">0 đ</span></c:if>
          </td>
          <td>
            <c:if test="${isStaff}">
              <c:if test="${r.status == 'REQUESTED'}">
                <form action="${pageContext.request.contextPath}/borrow/approve" method="get" style="display:flex; gap:5px; margin-bottom:5px;">
                  <input type="hidden" name="id" value="${r.id}" />
                  <input type="text" name="barcode" class="barcode-input" placeholder="Mã vạch sách..." required />
                  <button type="submit" class="btn btn-success">Duyệt</button>
                </form>
                <a class="btn btn-danger" style="padding: 4px 10px; font-size: 12px;" href="${pageContext.request.contextPath}/borrow/reject?id=${r.id}">Từ chối</a>
              </c:if>
              
              <c:if test="${r.status == 'BORROWED'}">
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/borrow/return?id=${r.id}">Xác nhận trả</a>
              </c:if>
            </c:if>
            <c:if test="${not isStaff && r.status == 'REQUESTED'}">
              <span class="muted">Đang chờ xử lý...</span>
            </c:if>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty records}">
        <tr>
          <td colspan="8" style="text-align:center; padding:40px;" class="muted">Không có dữ liệu phiếu mượn nào.</td>
        </tr>
      </c:if>
      </tbody>
    </table>
  </div>
</body>
</html>