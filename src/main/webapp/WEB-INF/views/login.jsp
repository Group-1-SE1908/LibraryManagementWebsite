<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
      <meta charset="UTF-8" />
      <title>Auth - LBMS</title>
      <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
      <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    </head>

    <body class="auth-page">
      <div class="auth-container" id="container">
        <!-- Sign-Up Container (Visible initially on the LEFT) -->
        <div class="form-container sign-in-container">
          <form method="post" action="${pageContext.request.contextPath}/register">
            <h1>Đăng ký</h1>
            <div class="social-container">
              <a href="#" class="social social-fb"><i class="fab fa-facebook-f"></i></a>
              <a href="#" class="social social-google"><i class="fab fa-google-plus-g"></i></a>
              <a href="#" class="social social-linkedin"><i class="fab fa-linkedin-in"></i></a>
            </div>
            <span>hoặc sử dụng email để đăng ký</span>
            <input type="text" name="fullName" placeholder="Họ tên" required />
            <input type="email" name="email" placeholder="Email" required />
            <input type="password" name="password" placeholder="Mật khẩu" required />
            <button type="submit" style="margin-top: 10px;">Tạo tài khoản</button>
          </form>
        </div>

        <!-- Sign-In Container (Appears on the RIGHT when active) -->
        <div class="form-container sign-up-container">
          <form method="post" action="${pageContext.request.contextPath}/login">
            <h1>Đăng nhập</h1>
            <div class="social-container">
              <a href="#" class="social social-fb"><i class="fab fa-facebook-f"></i></a>
              <a href="#" class="social social-google"><i class="fab fa-google-plus-g"></i></a>
              <a href="#" class="social social-linkedin"><i class="fab fa-linkedin-in"></i></a>
            </div>
            <span>hoặc điền thông tin bên dưới</span>
            <c:if test="${not empty error}">
              <p style="color: #ea868f; margin: 10px 0; font-size: 14px;">${error}</p>
            </c:if>
            <input type="email" name="email" placeholder="Email" required />
            <input type="password" name="password" placeholder="Mật khẩu" required />
            <a href="${pageContext.request.contextPath}/reset-password" style="margin: 10px 0; font-size: 13px;">Quên
              mật khẩu?</a>
            <button type="submit">Đăng nhập</button>
          </form>
        </div>

        <!-- Overlay Panels -->
        <div class="overlay-container">
          <div class="overlay">
            <!-- Overlay Left: Appears when Sign In form is showing -->
            <div class="overlay-panel overlay-left">
              <h1>Bạn mới đến?</h1>
              <p>Nhấn nút bên dưới để quay lại trang đăng ký và tạo tài khoản mới ngay</p>
              <button class="ghost" id="signUp">Đăng ký</button>
            </div>
            <!-- Overlay Right: Appears when Sign Up form is showing -->
            <div class="overlay-panel overlay-right">
              <h1>Chào mừng trở lại!</h1>
              <p>Nếu bạn đã có tài khoản, nhấn nút này để chuyển sang đăng nhập</p>
              <button class="ghost" id="signIn">Đăng nhập</button>
            </div>
          </div>
        </div>
      </div>

      <script>
        const signUpButton = document.getElementById('signUp');
        const signInButton = document.getElementById('signIn');
        const container = document.getElementById('container');

        // Mặc định không có class, "Đăng ký" ở bên trái.
        // Khi nhấn "Đăng nhập", thêm class, form chạy sang phải.

        signInButton.addEventListener('click', () => {
          container.classList.add('right-panel-active');
        });

        signUpButton.addEventListener('click', () => {
          container.classList.remove('right-panel-active');
        });
      </script>
    </body>

    </html>