<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8" />
  <title>${pageTitle} - LBMS</title>
  <style>
    :root {
      --bg: #f8f9fa;
      --text: #212529;
      --border: #dee2e6;
    }
    body { font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; background-color: var(--bg); color: var(--text); max-width: 1250px; margin: 40px auto; padding: 0 20px; line-height: 1.6; }
    .container { background: #fff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.08); padding: 24px; }
    .top { display: flex; flex-wrap: wrap; gap: 15px; align-items: center; justify-content: space-between; margin-bottom: 20px; border-bottom: 2px solid var(--border); padding-bottom: 15px; }
    h2 { margin: 0; color: #2c3e50; font-size: 24px; font-weight: 700; }
    .nav-links { display: flex; gap: 10px; flex-wrap: wrap; }
    
    /* Nút bấm */
    a.btn, button.btn { display: inline-flex; align-items: center; justify-content: center; padding: 8px 16px; border-radius: 6px; border: none; font-size: 14px; font-weight: 600; text-decoration: none; cursor: pointer; transition: all 0.2s; background-color: #e9ecef; color: #495057; }
    a.btn:hover, button.btn:hover { background-color: #ced4da; transform: translateY(-1px); }
    
    .btn-primary { background-color: #0d6efd !important; color: #ffffff !important; box-shadow: 0 2px 4px rgba(13, 110, 253, 0.2); }
    .btn-primary:hover { background-color: #0b5ed7 !important; box-shadow: 0 4px 8px rgba(13, 110, 253, 0.4); }
    
    .btn-success { background-color: #198754 !important; color: #ffffff !important; box-shadow: 0 2px 4px rgba(25, 135, 84, 0.2); }
    .btn-success:hover { background-color: #157347 !important; box-shadow: 0 4px 8px rgba(25, 135, 84, 0.4); }
    
    .btn-danger { background-color: #dc3545 !important; color: #ffffff !important; box-shadow: 0 2px 4px rgba(220, 53, 69, 0.2); }
    .btn-danger:hover { background-color: #bb2d3b !important; box-shadow: 0 4px 8px rgba(220, 53, 69, 0.4); }

    .nav-links a.btn { background-color: #f8f9fa; border: 1px solid #dee2e6; color: #495057; }
    .nav-links a.btn:hover { background-color: #e9ecef; }
    .nav-links a.btn-danger { background-color: #fff5f5 !important; color: #dc3545 !important; border-color: #ffcccc; }
    
    /* Bộ lọc */
    .filter-box { background: #f8f9fa; padding: 15px; border-radius: 8px; margin-bottom: 20px; display: flex; flex-wrap: wrap; gap: 12px; align-items: center; border: 1px solid var(--border); }
    .filter-select { padding: 8px 12px; border-radius: 6px; border: 1px solid #ced4da; outline: none; font-size: 14px; min-width: 180px;}
    
    /* Bảng */
    table { width: 100%; border-collapse: collapse; margin-top: 10px; }
    th { background: #f8f9fa; color: #6c757d; font-weight: 700; text-transform: uppercase; font-size: 13px; padding: 14px 15px; text-align: left; border-bottom: 2px solid var(--border); }
    td { padding: 16px 15px; border-bottom: 1px solid var(--border); vertical-align: middle; font-size: 14px; }
    tr:hover td { background-color: #f8f9fa; }
    
    /* Tag */
    .tag { display: inline-block; padding: 6px 12px; border-radius: 30px; font-size: 12px; font-weight: 700; text-align: center; }
    .tag-requested { background: #cff4fc; color: #055160; border: 1px solid #b6effb; }
    .tag-borrowed { background: #fff3cd; color: #664d03; border: 1px solid #ffecb5; }
    .tag-returned { background: #d1e7dd; color: #0f5132; border: 1px solid #badbcc; }
    .tag-rejected { background: #f8d7da; color: #842029; border: 1px solid #f5c2c7; }
    .tag-overdue { background: #dc3545; color: #ffffff; box-shadow: 0 2px 4px rgba(220,53,69,0.3); }
    
    .barcode-input { padding: 8px 12px; border: 1px solid #ced4da; border-radius: 6px; width: 130px; font-size: 13px; outline: none; transition: border-color 0.2s; }
    .barcode-input:focus { border-color: #0d6efd; box-shadow: 0 0 0 3px rgba(13, 110, 253, 0.25); }
    .muted { color: #6c757d; font-size: 13px; margin-top: 4px; font-weight: normal; }
    .flash { margin-bottom: 20px; padding: 14px 20px; border-left: 5px solid #198754; border-radius: 6px; background: #d1e7dd; color: #0f5132; font-weight: 600; font-size: 15px; }
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

    <c:if test="${pageTitle == 'Lịch sử mượn trả'}">
      <form class="filter-box" action="${pageContext.request.contextPath}/borrow/history" method="get">
        <strong style="color: #495057;">Lọc danh sách:</strong>
        
        <select name="method" class="filter-select">
          <option value="">-- Tất cả phương thức --</option>
          <option value="IN_PERSON" ${methodFilter == 'IN_PERSON' ? 'selected' : ''}>🏢 Trực tiếp tại thư viện</option>
          <option value="ONLINE" ${methodFilter == 'ONLINE' ? 'selected' : ''}>🛒 Order Online</option>
        </select>
        
        <select name="status" class="filter-select">
          <option value="">-- Tất cả trạng thái --</option>
          <option value="REQUESTED" ${statusFilter == 'REQUESTED' ? 'selected' : ''}>⏳ Đang đợi xử lý</option>
          <option value="BORROWED" ${statusFilter == 'BORROWED' ? 'selected' : ''}>📖 Đang mượn</option>
          <option value="RETURNED" ${statusFilter == 'RETURNED' ? 'selected' : ''}>✅ Đã trả</option>
        </select>

        <button type="submit" class="btn btn-primary">Áp dụng</button>
        <a href="${pageContext.request.contextPath}/borrow/history" class="btn">Xóa bộ lọc</a>
      </form>
    </c:if>

    <c:if test="${not empty flash}">
      <div class="flash">✓ ${flash}</div>
    </c:if>

    <table>
      <thead>
      <tr>
        <th>Mã</th>
        <th>Phương thức</th>
        <th>Người mượn</th>
        <th>Đầu sách & Mã vạch</th>
        <th>Thời gian</th>
        <th>Trạng thái</th>
        <th width="240">Thao tác</th>
      </tr>
      </thead>
      <tbody>
      <c:forEach items="${records}" var="r">
        <tr>
          <td><strong>#${r.id}</strong></td>
          <td>
            <c:choose>
              <c:when test="${r.borrowMethod == 'ONLINE'}">
                <span class="tag" style="background:#e0f2fe; color:#0284c7; border: 1px solid #bae6fd;">Online</span>
              </c:when>
              <c:otherwise>
                <span class="tag" style="background:#f1f5f9; color:#475569; border: 1px solid #e2e8f0;">Trực tiếp</span>
              </c:otherwise>
            </c:choose>
          </td>
          <td>
            <div style="font-weight: 600; color: var(--text);">
              ${r.user.fullName} <span class="muted">(${r.user.email})</span>
            </div>
          </td>
          <td>
            <div style="font-weight: 600; color: #0d6efd;">${r.book.title}</div>
            <div class="muted">
              <c:choose>
                <c:when test="${not empty r.bookCopy.barcode}">
                  Mã vạch: <strong style="color: #495057;">${r.bookCopy.barcode}</strong>
                </c:when>
                <c:otherwise>Chưa gán mã vạch</c:otherwise>
              </c:choose>
            </div>
          </td>
          <td>
            <div class="muted" style="margin-top:0;">Mượn: ${r.borrowDate != null ? r.borrowDate : '-'}</div>
            <div class="muted" style="color: ${r.status == 'BORROWED' ? '#dc3545' : '#6c757d'}">Hạn: ${r.dueDate != null ? r.dueDate : '-'}</div>
          </td>
          <td>
            <c:choose>
              <c:when test="${r.status == 'REQUESTED'}"><span class="tag tag-requested">Chờ duyệt</span></c:when>
              <c:when test="${r.status == 'BORROWED'}"><span class="tag tag-borrowed">Đang mượn</span></c:when>
              <c:when test="${r.status == 'RETURNED'}"><span class="tag tag-returned">Đã trả</span></c:when>
              <c:when test="${r.status == 'REJECTED'}"><span class="tag tag-rejected">Từ chối</span></c:when>
              <c:otherwise><span class="tag tag-overdue">${r.status}</span></c:otherwise>
            </c:choose>
            
            <c:if test="${r.fineAmount > 0}">
                <div style="color:var(--danger); font-size: 12px; font-weight: bold; margin-top: 5px;">Phạt: ${r.fineAmount}đ</div>
            </c:if>
          </td>
          <td>
            <a class="btn" style="margin-bottom: 6px; width: 100%; box-sizing: border-box;" href="${pageContext.request.contextPath}/borrow/detail?id=${r.id}">🔍 Xem chi tiết</a>
            
            <c:if test="${isStaff}">
              <c:if test="${r.status == 'REQUESTED'}">
                <form action="${pageContext.request.contextPath}/borrow/approve" method="get" style="display:flex; gap:5px; margin-bottom:6px;">
                  <input type="hidden" name="id" value="${r.id}" />
                  <input type="text" name="barcode" class="barcode-input" placeholder="Mã vạch..." required />
                  <button type="submit" class="btn btn-success">Duyệt</button>
                </form>
                <a class="btn btn-danger" style="width: 100%; box-sizing: border-box;" href="${pageContext.request.contextPath}/borrow/reject?id=${r.id}">Từ chối</a>
              </c:if>
              
              <c:if test="${r.status == 'BORROWED'}">
                <a class="btn btn-primary" style="width: 100%; box-sizing: border-box;" href="${pageContext.request.contextPath}/borrow/return?id=${r.id}">Xác nhận trả</a>
              </c:if>
            </c:if>
          </td>
        </tr>
      </c:forEach>
      <c:if test="${empty records}">
        <tr>
          <td colspan="7" style="text-align:center; padding:40px;" class="muted">Không có dữ liệu phiếu mượn nào.</td>
        </tr>
      </c:if>
      </tbody>
    </table>
  </div>
</body>
</html>