<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng nhập nhân viên - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <link rel="stylesheet"
        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
</head>

<body class="auth-page">
    <%@ include file="header.jsp" %>

    <main>
        <div class="admin-login-wrapper">
            <div class="admin-login-card">
                <form method="post" action="${pageContext.request.contextPath}/adminlogin">
                    <h1>Đăng nhập nhân viên</h1>
                    <p class="admin-login-subtitle">Chỉ dành cho quản trị viên và nhân viên thư viện.</p>
                    <c:if test="${not empty error}">
                        <div class="auth-error">
                            <i class="fas fa-exclamation-circle"></i>
                            ${error}
                        </div>
                    </c:if>
                    <div class="input-group">
                        <i class="fas fa-envelope"></i>
                        <input type="email" name="email" placeholder="Email" required />
                    </div>
                    <div class="input-group">
                        <i class="fas fa-lock"></i>
                        <input type="password" name="password" placeholder="Mật khẩu" required />
                    </div>
                    <a href="${pageContext.request.contextPath}/reset-password" class="forgot-password">Quên mật khẩu?</a>
                    <button type="submit" class="btn-submit">Đăng nhập</button>
                    <p class="admin-login-helper">
                        Nếu bạn là bạn đọc thường, vui lòng <a href="${pageContext.request.contextPath}/login">đăng nhập tại đây</a>.
                    </p>
                </form>
            </div>
        </div>
    </main>

    <%@ include file="footer.jsp" %>
</body>

</html>
