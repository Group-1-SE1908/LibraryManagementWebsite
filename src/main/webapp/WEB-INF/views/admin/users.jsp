<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
      <meta charset="UTF-8" />
      <title>Quản lý user - LBMS</title>
      <style>
        body {
          font-family: Arial, Helvetica, sans-serif;
          max-width: 1100px;
          margin: 30px auto;
          padding: 0 16px;
        }

        table {
          width: 100%;
          border-collapse: collapse;
        }

        th,
        td {
          border-bottom: 1px solid #eee;
          padding: 10px;
          text-align: left;
          vertical-align: top;
        }

        a.btn,
        button {
          display: inline-block;
          padding: 8px 10px;
          border-radius: 8px;
          border: 1px solid #ddd;
          text-decoration: none;
          color: #111;
          background: #fff;
          cursor: pointer;
        }

        select {
          padding: 8px;
          border: 1px solid #ccc;
          border-radius: 8px;
        }

        .danger {
          border-color: #ffcccc;
          color: #b00020;
        }

        .ok {
          border-color: #ccffcc;
          color: #0b6b0b;
        }

        .flash {
          margin: 10px 0;
          padding: 10px;
          border: 1px solid #ddd;
          border-radius: 8px;
          background: #fafafa;
        }

        .muted {
          color: #666;
        }

        form {
          margin: 0;
        }

        .top {
          display: flex;
          align-items: center;
          justify-content: space-between;
          margin-bottom: 12px;
        }
      </style>
    </head>

    <body>
      <div class="top">
        <div>
          <h2>LBMS - Admin: Quản lý user</h2>
          <div>
            <a class="btn" href="${pageContext.request.contextPath}/admin/categories">Danh mục</a>
            <a class="btn" href="${pageContext.request.contextPath}/books">Sách</a>
            <a class="btn" href="${pageContext.request.contextPath}/borrow">Mượn/Trả</a>
          </div>
        </div>
        <a class="btn" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
      </div>

      <c:if test="${not empty flash}">
        <div class="flash">${flash}</div>
      </c:if>

      <table>
        <thead>
          <tr>
            <th>ID</th>
            <th>Email</th>
            <th>Họ tên</th>
            <th>Role</th>
            <th>Trạng thái</th>
            <th>Thao tác</th>
          </tr>
        </thead>
        <tbody>
          <c:forEach items="${users}" var="u">
            <tr>
              <td>${u.id}</td>
              <td><strong>${u.email}</strong></td>
              <td>${u.fullName}</td>
              <td>
                <form method="post" action="${pageContext.request.contextPath}/admin/users/role">
                  <input type="hidden" name="userId" value="${u.id}" />
                  <select name="role" onchange="this.form.submit()">
                    <c:forEach items="${roles}" var="r">
                      <option value="${r.name}" <c:if test="${u.role.name == r.name}">selected</c:if>>${r.name}</option>
                    </c:forEach>
                  </select>
                </form>
              </td>
              <td>
                <span class="muted">${u.status}</span>
              </td>
              <td>
                <c:choose>
                  <c:when test="${u.status == 'ACTIVE'}">
                    <form method="post" action="${pageContext.request.contextPath}/admin/users/status">
                      <input type="hidden" name="userId" value="${u.id}" />
                      <input type="hidden" name="status" value="LOCKED" />
                      <button class="danger" type="submit">Khóa</button>
                    </form>
                  </c:when>
                  <c:otherwise>
                    <form method="post" action="${pageContext.request.contextPath}/admin/users/status">
                      <input type="hidden" name="userId" value="${u.id}" />
                      <input type="hidden" name="status" value="ACTIVE" />
                      <button class="ok" type="submit">Mở khóa</button>
                    </form>
                  </c:otherwise>
                </c:choose>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </body>

    </html>