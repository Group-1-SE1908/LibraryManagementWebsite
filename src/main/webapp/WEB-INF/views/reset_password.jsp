<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>
    <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
      <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
          <meta charset="UTF-8" />
          <meta name="viewport" content="width=device-width, initial-scale=1.0" />
          <title>Đặt lại mật khẩu - LBMS</title>
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
              background: radial-gradient(circle at top left, #e0e7ff, #f8fafc 50%, #f1f5f9);
              padding: 3rem 1rem;
            }

            .reset-password-container {
              background: white;
              border-radius: 12px;
              box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
              padding: 2rem;
              width: 100%;
              max-width: 500px;
            }

            .reset-password-container h1 {
              font-size: 28px;
              font-weight: 700;
              text-align: center;
              color: #1f2937;
              margin-bottom: 0.5rem;
            }

            .reset-password-container>span {
              display: block;
              text-align: center;
              color: #6b7280;
              font-size: 14px;
              margin-bottom: 2rem;
            }

            .reset-password-container .input-group {
              margin-bottom: 1.5rem;
              display: flex;
              align-items: center;
              border: 2px solid #e5e7eb;
              border-radius: 10px;
              padding: 0 12px;
              transition: border-color 0.3s;
            }

            .reset-password-container .input-group:focus-within {
              border-color: #3b82f6;
            }

            .reset-password-container .input-group i {
              color: #9ca3af;
              margin-right: 10px;
              width: 20px;
              text-align: center;
            }

            .reset-password-container .input-group input {
              flex: 1;
              border: none;
              padding: 12px 0;
              font-size: 14px;
              outline: none;
              background: transparent;
            }

            .reset-password-container .input-group input::placeholder {
              color: #d1d5db;
            }

            .reset-password-container .btn-submit {
              width: 100%;
              padding: 12px;
              background: linear-gradient(135deg, #3b82f6, #1d4ed8);
              color: white;
              border: none;
              border-radius: 10px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s;
              margin-bottom: 1rem;
            }

            .reset-password-container .btn-submit:hover {
              transform: translateY(-2px);
              box-shadow: 0 5px 20px rgba(59, 130, 246, 0.4);
            }

            .reset-password-container .form-divider {
              text-align: center;
              color: #9ca3af;
              font-size: 13px;
              margin: 1.5rem 0;
            }

            .reset-password-container .back-link {
              text-align: center;
              color: #3b82f6;
              text-decoration: none;
              font-weight: 600;
              transition: color 0.3s;
            }

            .reset-password-container .back-link:hover {
              color: #1d4ed8;
            }

            .reset-password-container .error-message {
              color: #ef4444;
              margin: 10px 0;
              padding: 12px;
              background: #fee2e2;
              border-radius: 8px;
              font-size: 14px;
              display: flex;
              align-items: center;
            }

            .reset-password-container .error-message i {
              margin-right: 8px;
            }

            .reset-password-container .success-message {
              color: #059669;
              margin: 10px 0;
              padding: 12px;
              background: #d1fae5;
              border-radius: 8px;
              font-size: 14px;
              display: flex;
              align-items: center;
            }

            .reset-password-container .success-message i {
              margin-right: 8px;
            }

            .form-tabs {
              display: flex;
              gap: 1rem;
              margin-bottom: 2rem;
              border-bottom: 2px solid #e5e7eb;
            }

            .form-tabs .tab-btn {
              flex: 1;
              padding: 12px;
              border: none;
              background: none;
              cursor: pointer;
              font-weight: 600;
              color: #9ca3af;
              border-bottom: 3px solid transparent;
              transition: all 0.3s;
              margin-bottom: -2px;
            }

            .form-tabs .tab-btn.active {
              color: #3b82f6;
              border-bottom-color: #3b82f6;
            }

            .form-content {
              display: none;
            }

            .form-content.active {
              display: block;
            }
          </style>
        </head>

        <body class="auth-page">
          <%@ include file="header.jsp" %>

            <main>
              <div class="reset-password-container">
                <h1>Đặt lại mật khẩu</h1>
                <span>Khôi phục quyền truy cập vào tài khoản của bạn</span>

                <c:if test="${not empty error}">
                  <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>${error}
                  </div>
                </c:if>
                <c:if test="${not empty success}">
                  <div class="success-message">
                    <i class="fas fa-check-circle"></i>${success}
                  </div>
                </c:if>
                <c:if test="${not empty message}">
                  <div class="success-message">
                    <i class="fas fa-info-circle"></i>${message}
                  </div>
                </c:if>

                <!-- Tab buttons -->
                <div class="form-tabs">
                  <button class="tab-btn active" onclick="showTab(event, 'send-code')">
                    <i class="fas fa-paper-plane"></i> Gửi mã
                  </button>
                  <button class="tab-btn" onclick="showTab(event, 'reset-form')">
                    <i class="fas fa-key"></i> Đặt lại
                  </button>
                </div>

                <!-- Tab 1: Send Code -->
                <div id="send-code" class="form-content active">
                  <form method="post" action="${pageContext.request.contextPath}/reset-password">
                    <input type="hidden" name="action" value="send-code" />
                    <div class="input-group">
                      <i class="fas fa-envelope"></i>
                      <input type="email" name="email" placeholder="Nhập email của bạn" value="${email}" required />
                    </div>
                    <button type="submit" class="btn-submit">
                      <i class="fas fa-paper-plane" style="margin-right: 8px;"></i>Gửi mã xác thực
                    </button>
                  </form>
                </div>

                <!-- Tab 2: Reset Password -->
                <div id="reset-form" class="form-content">
                  <form method="post" action="${pageContext.request.contextPath}/reset-password">
                    <input type="hidden" name="action" value="reset" />
                    <div class="input-group">
                      <i class="fas fa-envelope"></i>
                      <input type="email" name="email" placeholder="Email" value="${email}" required />
                    </div>
                    <div class="input-group">
                      <i class="fas fa-code"></i>
                      <input type="text" name="code" placeholder="Mã xác thực (6 ký tự)" maxlength="6"
                        autocomplete="off" required />
                    </div>
                    <div class="input-group">
                      <i class="fas fa-lock"></i>
                      <input type="password" name="password" placeholder="Mật khẩu mới" required />
                    </div>
                    <div class="input-group">
                      <i class="fas fa-lock"></i>
                      <input type="password" name="confirm" placeholder="Xác nhận mật khẩu" required />
                    </div>
                    <button type="submit" class="btn-submit">
                      <i class="fas fa-key" style="margin-right: 8px;"></i>Đổi mật khẩu
                    </button>
                  </form>
                </div>

                <div class="form-divider">
                  <a href="${pageContext.request.contextPath}/login" class="back-link">
                    <i class="fas fa-arrow-left" style="margin-right: 5px;"></i>Quay lại đăng nhập
                  </a>
                </div>
              </div>
            </main>

            <%@ include file="footer.jsp" %>

              <script>
                function showTab(event, tabName) {
                  event.preventDefault();

                  // Hide all tab contents
                  const contents = document.querySelectorAll('.form-content');
                  contents.forEach(content => {
                    content.classList.remove('active');
                  });

                  // Remove active class from all buttons
                  const buttons = document.querySelectorAll('.tab-btn');
                  buttons.forEach(btn => {
                    btn.classList.remove('active');
                  });

                  // Show selected tab and mark button as active
                  document.getElementById(tabName).classList.add('active');
                  event.target.closest('.tab-btn').classList.add('active');
                }
              </script>
        </body>

        </html>