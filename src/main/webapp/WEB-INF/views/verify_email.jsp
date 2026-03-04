<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8" />
            <title>Xác thực email - LBMS</title>
            <style>
                body {
                    font-family: Arial, Helvetica, sans-serif;
                    max-width: 720px;
                    margin: 40px auto;
                    padding: 0 16px;
                    background: #f7f7fb;
                }

                .card {
                    border: 1px solid #dfe3f2;
                    border-radius: 14px;
                    padding: 24px;
                    background: #fff;
                    box-shadow: 0 12px 30px rgba(15, 23, 42, .08);
                }

                .row {
                    margin: 14px 0;
                }

                label {
                    display: block;
                    margin-bottom: 6px;
                    font-weight: 600;
                    color: #1f2937;
                }

                input {
                    width: 100%;
                    padding: 10px 14px;
                    border: 1px solid #cbd5e1;
                    border-radius: 10px;
                    font-size: 14px;
                }

                button {
                    width: 100%;
                    padding: 12px 16px;
                    border: 0;
                    border-radius: 10px;
                    background: #2563eb;
                    color: #fff;
                    font-weight: 600;
                    cursor: pointer;
                    transition: .2s;
                }

                button:hover {
                    background: #1d4ed8;
                }

                .secondary {
                    background: #e5e7eb;
                    color: #1f2937;
                    margin-top: 6px;
                }

                .secondary:hover {
                    background: #d1d5db;
                }

                .info {
                    color: #2563eb;
                    font-size: 14px;
                    margin: 0 0 8px;
                }

                .msg {
                    color: #047857;
                    margin: 10px 0;
                    font-weight: 500;
                }

                .err {
                    color: #dc2626;
                    margin: 10px 0;
                    font-weight: 500;
                }

                a {
                    color: #1d4ed8;
                    text-decoration: none;
                    font-weight: 600;
                }
            </style>
        </head>

        <body>
            <h2>Xác thực email - LBMS</h2>
            <div class="card">
                <p class="info">Sau khi đăng ký, nhập email và mã để kích hoạt tài khoản.</p>
                <c:if test="${not empty message}">
                    <div class="msg">${message}</div>
                </c:if>
                <c:if test="${not empty error}">
                    <div class="err">${error}</div>
                </c:if>
                <c:if test="${not empty success}">
                    <div class="msg">${success}</div>
                </c:if>
                <form method="post" action="${pageContext.request.contextPath}/verify-email">
                    <div class="row">
                        <label>Email</label>
                        <input name="email" type="email" value="${email}" required />
                    </div>
                    <div class="row">
                        <label>Mã xác thực</label>
                        <input name="code" type="text" maxlength="6" autocomplete="off" required />
                    </div>
                    <div class="row">
                        <button type="submit">Xác thực email</button>
                    </div>
                    <div class="row">
                        <button type="submit" name="action" value="resend" class="secondary">Gửi lại mã</button>
                    </div>
                </form>
                <div class="row">
                    <a href="${pageContext.request.contextPath}/login">Quay lại đăng nhập</a>
                </div>
            </div>
        </body>

        </html>