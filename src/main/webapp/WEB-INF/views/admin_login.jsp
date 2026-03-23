<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">

<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Đăng nhập nhân viên - LBMS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    <style>
        *, *::before, *::after { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #f1f5f9;
        }

        .admin-card {
            background: #fff;
            border-radius: 20px;
            box-shadow: 0 4px 24px rgba(15, 23, 42, .1);
            padding: 2.5rem;
            width: 100%;
            max-width: 420px;
        }

        .admin-logo {
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 1.75rem;
        }

        .admin-logo-icon {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, #4f46e5, #6366f1);
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #fff;
            font-size: 17px;
        }

        .admin-logo-text {
            font-size: 1.3rem;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -.5px;
        }

        .admin-logo-text span { color: #4f46e5; }

        .admin-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: #ede9fe;
            color: #5b21b6;
            font-size: 11px;
            font-weight: 700;
            padding: 4px 12px;
            border-radius: 999px;
            margin-bottom: .9rem;
            letter-spacing: .04em;
            text-transform: uppercase;
        }

        .admin-title {
            font-size: 1.4rem;
            font-weight: 800;
            color: #0f172a;
            letter-spacing: -.5px;
            margin-bottom: .25rem;
        }

        .admin-sub {
            font-size: .83rem;
            color: #64748b;
            margin-bottom: 1.75rem;
        }

        .admin-alert {
            background: #fff1f2;
            border: 1px solid #fecdd3;
            border-left: 4px solid #f43f5e;
            border-radius: 10px;
            padding: 11px 14px;
            display: flex;
            align-items: center;
            gap: 9px;
            font-size: 13px;
            color: #9f1239;
            margin-bottom: 1.25rem;
        }

        .admin-form {
            display: flex;
            flex-direction: column;
            gap: 1.1rem;
        }

        .admin-label {
            display: block;
            font-size: 12.5px;
            font-weight: 600;
            color: #374151;
            margin-bottom: 6px;
        }

        .admin-iw { position: relative; }

        .admin-iw i.fi {
            position: absolute;
            left: 13px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            font-size: 13px;
            pointer-events: none;
        }

        .admin-iw:focus-within i.fi { color: #6366f1; }

        .admin-iw input {
            width: 100%;
            padding: 12px 12px 12px 38px;
            border: 1.5px solid #e2e8f0;
            border-radius: 10px;
            font-size: 14px;
            color: #0f172a;
            background: #f8fafc;
            transition: border-color .2s, box-shadow .2s;
        }

        .admin-iw input:focus {
            outline: none;
            border-color: #6366f1;
            background: #fff;
            box-shadow: 0 0 0 3px rgba(99, 102, 241, .1);
        }

        .admin-iw input::placeholder { color: #cbd5e1; }

        .admin-iw .toggle-pw {
            position: absolute;
            right: 11px;
            top: 50%;
            transform: translateY(-50%);
            color: #94a3b8;
            cursor: pointer;
            font-size: 13px;
            padding: 4px;
            border: none;
            background: none;
        }

        .admin-iw .toggle-pw:hover { color: #6366f1; }
        .admin-iw.has-toggle input { padding-right: 38px; }

        .admin-forgot {
            display: block;
            text-align: right;
            font-size: 12px;
            color: #6366f1;
            font-weight: 500;
            text-decoration: none;
            margin-top: 5px;
        }

        .admin-forgot:hover { text-decoration: underline; }

        .admin-submit {
            margin-top: 4px;
            width: 100%;
            padding: 13px;
            background: linear-gradient(135deg, #6366f1, #4f46e5);
            color: #fff;
            border: none;
            border-radius: 10px;
            font-size: 14.5px;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all .2s;
            box-shadow: 0 3px 12px rgba(99, 102, 241, .38);
        }

        .admin-submit:hover {
            box-shadow: 0 6px 20px rgba(99, 102, 241, .5);
            transform: translateY(-1px);
        }

        .admin-submit:active { transform: translateY(0); }

        .admin-divider {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #cbd5e1;
            font-size: 11.5px;
        }

        .admin-divider::before, .admin-divider::after {
            content: '';
            flex: 1;
            height: 1px;
            background: #e2e8f0;
        }

        .admin-user-link {
            width: 100%;
            padding: 12px 14px;
            border: 1.5px solid #e2e8f0;
            border-radius: 10px;
            font-size: 13.5px;
            font-weight: 600;
            color: #475569;
            background: #fff;
            cursor: pointer;
            text-align: center;
            text-decoration: none;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
            transition: all .2s;
        }

        .admin-user-link:hover {
            border-color: #c7d2fe;
            background: #f5f3ff;
            color: #4f46e5;
        }

        .admin-footer {
            margin-top: 1.75rem;
            font-size: 11.5px;
            color: #94a3b8;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
        }
    </style>
</head>

<body>
    <div class="admin-card">

        <div class="admin-logo">
            <div class="admin-logo-icon"><i class="fas fa-shield-halved"></i></div>
            <div class="admin-logo-text">LB<span>MS</span></div>
        </div>

        <div class="admin-badge">
            <i class="fas fa-lock fa-xs"></i> Truy cập nội bộ
        </div>
        <div class="admin-title">Đăng nhập</div>
        <div class="admin-sub">Chỉ dành cho quản trị viên và nhân viên thư viện.</div>

        <c:if test="${not empty error}">
            <div class="admin-alert">
                <i class="fas fa-circle-exclamation"></i>
                <span>${error}</span>
            </div>
        </c:if>

        <form class="admin-form" method="post" action="${pageContext.request.contextPath}/adminlogin">
            <div>
                <label class="admin-label">Email công việc</label>
                <div class="admin-iw">
                    <i class="fas fa-envelope fi"></i>
                    <input type="email" name="email" placeholder="admin@library.edu" required autofocus />
                </div>
            </div>
            <div>
                <label class="admin-label">Mật khẩu</label>
                <div class="admin-iw has-toggle">
                    <i class="fas fa-lock fi"></i>
                    <input type="password" name="password" id="al-pw" placeholder="••••••••" required />
                    <button type="button" class="toggle-pw" onclick="togglePw('al-pw', this)">
                        <i class="fas fa-eye"></i>
                    </button>
                </div>
                <a href="${pageContext.request.contextPath}/reset-password" class="admin-forgot">Quên mật khẩu?</a>
            </div>
            <button type="submit" class="admin-submit">
                <i class="fas fa-arrow-right-to-bracket"></i> Đăng nhập hệ thống
            </button>
            <div class="admin-divider">hoặc</div>
            <a href="${pageContext.request.contextPath}/login" class="admin-user-link">
                <i class="fas fa-user"></i> Tôi là bạn đọc thường
            </a>
        </form>

        <div class="admin-footer">
            <i class="fas fa-shield fa-xs"></i>
            Kết nối được mã hóa và bảo mật
        </div>

    </div>

    <script>
        function togglePw(id, btn) {
            const input = document.getElementById(id);
            const icon = btn.querySelector('i');
            if (input.type === 'password') {
                input.type = 'text';
                icon.className = 'fas fa-eye-slash';
            } else {
                input.type = 'password';
                icon.className = 'fas fa-eye';
            }
        }
    </script>
</body>

</html>