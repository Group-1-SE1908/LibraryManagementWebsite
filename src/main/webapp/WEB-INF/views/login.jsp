<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Đăng nhập & Đăng ký - LBMS</title>
          <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
          <style>
            body.auth-page {
              display: flex;
              flex-direction: column;
              min-height: 100vh;
            }

            body.auth-page main {
              flex: 1;
              display: flex;
              justify-content: center;
              align-items: center;
              background: linear-gradient(135deg, #f0f4f8 0%, #e8eef6 100%);
              padding: 2rem 1rem;
            }
          </style>
        </head>

        <body class="auth-page">
          <%@ include file="header.jsp" %>

            <main>
              <div class="auth-container" id="container">
                <!-- Sign Up Form (Left side - Visible by default) -->
                <div class="form-container form-signup">
                  <form method="post" action="${pageContext.request.contextPath}/register">
                    <h1>Đăng ký</h1>
                    <div class="social-container">
                      <a href="#" class="social social-fb" title="Đăng ký qua Facebook"><i
                          class="fab fa-facebook-f"></i></a>
                      <a href="#" class="social social-google" title="Đăng ký qua Google"><i
                          class="fab fa-google-plus-g"></i></a>
                      <a href="#" class="social social-linkedin" title="Đăng ký qua LinkedIn"><i
                          class="fab fa-linkedin-in"></i></a>
                    </div>
                    <span>hoặc sử dụng email để đăng ký</span>
                    <input type="text" name="fullName" placeholder="Họ tên" required />
                    <input type="email" name="email" placeholder="Email" required />
                    <input type="password" name="password" placeholder="Mật khẩu" required />
                    <button type="submit" class="btn-submit">Tạo tài khoản</button>
                  </form>
                </div>

                <!-- Sign In Form (Right side - Visible when activated) -->
                <div class="form-container form-signin">
                  <form method="post" action="${pageContext.request.contextPath}/login">
                    <h1>Đăng nhập</h1>
                    <div class="social-container">
                      <a href="#" class="social social-fb" title="Đăng nhập qua Facebook"><i
                          class="fab fa-facebook-f"></i></a>
                      <a href="#" class="social social-google" title="Đăng nhập qua Google"><i
                          class="fab fa-google-plus-g"></i></a>
                      <a href="#" class="social social-linkedin" title="Đăng nhập qua LinkedIn"><i
                          class="fab fa-linkedin-in"></i></a>
                    </div>
                    <span>hoặc điền thông tin bên dưới</span>
                    <c:if test="${not empty error}">
                      <p style="color: #ea868f; margin: 10px 0; font-size: 14px;">${error}</p>
                    </c:if>
                    <input type="email" name="email" placeholder="Email" required />
                    <input type="password" name="password" placeholder="Mật khẩu" required />
                    <a href="${pageContext.request.contextPath}/reset-password" class="forgot-password">Quên mật
                      khẩu?</a>
                    <button type="submit" class="btn-submit">Đăng nhập</button>
                  </form>
                </div>

                <!-- Overlay Panel -->
                <div class="overlay-container">
                  <div class="overlay">
                    <!-- Left Overlay - Show when Sign In is active -->
                    <div class="overlay-panel overlay-left">
                      <h1>Bạn mới đến?</h1>
                      <p>Nhấn nút bên dưới để quay lại trang đăng ký và tạo tài khoản mới ngay</p>
                      <button class="ghost" id="signUp">Đăng ký</button>
                    </div>
                    <!-- Right Overlay - Show when Sign Up is active -->
                    <div class="overlay-panel overlay-right">
                      <h1>Chào mừng trở lại!</h1>
                      <p>Nếu bạn đã có tài khoản, nhấn nút này để chuyển sang đăng nhập</p>
                      <button class="ghost" id="signIn">Đăng nhập</button>
                    </div>
                  </div>
                </div>
              </div>
            </main>

            <%@ include file="footer.jsp" %>

              <script>
                const signUpButton = document.getElementById('signUp');
                const signInButton = document.getElementById('signIn');
                const container = document.getElementById('container');

                // Default: Đăng ký form on the left
                // Click Đăng nhập: form slides to the right
                signInButton.addEventListener('click', () => {
                  container.classList.add('right-panel-active');
                });

                signUpButton.addEventListener('click', () => {
                  container.classList.remove('right-panel-active');
                });
              </script>
        </body>

        </html>