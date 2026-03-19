<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>Đăng nhập & Đăng ký - LBMS</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
            <style>
                /* ===== PAGE SHELL ===== */
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
                    background:
                        radial-gradient(ellipse 80% 60% at 20% 0%, rgba(99, 102, 241, .13) 0%, transparent 60%),
                        radial-gradient(ellipse 60% 50% at 80% 100%, rgba(14, 165, 233, .1) 0%, transparent 60%),
                        #f0f4ff;
                    padding: 3rem 1rem;
                }

                /* ===== CARD ===== */
                .lp-card {
                    width: min(500px, 100%);
                    background: #fff;
                    border-radius: 24px;
                    box-shadow: 0 8px 40px rgba(15, 23, 42, .1), 0 1px 3px rgba(15, 23, 42, .06);
                    border: 1px solid rgba(99, 102, 241, .12);
                    overflow: hidden;
                }

                /* ===== CARD HEADER ===== */
                .lp-card-head {
                    background: linear-gradient(135deg, #4f46e5 0%, #6366f1 50%, #818cf8 100%);
                    padding: 2.2rem 2.5rem 0;
                    text-align: center;
                    position: relative;
                }

                .lp-logo {
                    display: inline-flex;
                    align-items: center;
                    gap: 10px;
                    margin-bottom: 1rem;
                }

                .lp-logo-icon {
                    width: 44px;
                    height: 44px;
                    background: rgba(255, 255, 255, .2);
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 20px;
                    color: #fff;
                    backdrop-filter: blur(4px);
                }

                .lp-logo-text {
                    font-size: 1.35rem;
                    font-weight: 800;
                    color: #fff;
                    letter-spacing: -0.5px;
                }

                .lp-logo-text span {
                    color: #c7d2fe;
                }

                /* ===== TABS ===== */
                .lp-tabs {
                    display: flex;
                    margin-top: 1.2rem;
                    position: relative;
                }

                .lp-tab {
                    flex: 1;
                    padding: 13px 0 14px;
                    font-size: 14px;
                    font-weight: 600;
                    color: rgba(255, 255, 255, .55);
                    cursor: pointer;
                    background: none;
                    border: none;
                    border-radius: 12px 12px 0 0;
                    transition: color .2s, background .2s;
                    letter-spacing: .02em;
                }

                .lp-tab.active {
                    color: #4f46e5;
                    background: #fff;
                }

                .lp-tab:not(.active):hover {
                    color: rgba(255, 255, 255, .85);
                }

                /* ===== CARD BODY ===== */
                .lp-body {
                    padding: 2rem 2.5rem 2.5rem;
                }

                /* ===== PANELS ===== */
                .lp-panel {
                    display: none;
                }

                .lp-panel.active {
                    display: block;
                }

                .lp-panel-title {
                    font-size: 1.3rem;
                    font-weight: 800;
                    color: #0f172a;
                    margin-bottom: .25rem;
                    letter-spacing: -.4px;
                }

                .lp-panel-sub {
                    font-size: .82rem;
                    color: #64748b;
                    margin-bottom: 1.4rem;
                }

                /* ===== ALERT ===== */
                .lp-alert {
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
                    margin-bottom: 1.1rem;
                }

                /* ===== FORM ===== */
                .lp-form {
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .lp-field {
                    display: flex;
                    flex-direction: column;
                }

                .lp-label {
                    font-size: 12px;
                    font-weight: 600;
                    color: #374151;
                    margin-bottom: 6px;
                    letter-spacing: .02em;
                }

                .lp-iw {
                    position: relative;
                }

                .lp-iw i {
                    position: absolute;
                    left: 13px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #94a3b8;
                    font-size: 14px;
                    pointer-events: none;
                    transition: color .2s;
                }

                .lp-iw:focus-within i {
                    color: #6366f1;
                }

                .lp-iw input {
                    width: 100%;
                    padding: 12px 13px 12px 40px;
                    border: 1.5px solid #e2e8f0;
                    border-radius: 11px;
                    font-size: 14px;
                    color: #0f172a;
                    background: #f8fafc;
                    transition: border-color .2s, background .2s, box-shadow .2s;
                }

                .lp-iw input:focus {
                    outline: none;
                    border-color: #6366f1;
                    background: #fff;
                    box-shadow: 0 0 0 4px rgba(99, 102, 241, .1);
                }

                .lp-iw input::placeholder {
                    color: #cbd5e1;
                }

                .lp-forgot {
                    align-self: flex-end;
                    font-size: 12px;
                    color: #6366f1;
                    text-decoration: none;
                }

                .lp-forgot:hover {
                    text-decoration: underline;
                }

                /* ===== SUBMIT BTN ===== */
                .lp-btn {
                    margin-top: 4px;
                    width: 100%;
                    padding: 13px;
                    border: none;
                    border-radius: 12px;
                    font-size: 14.5px;
                    font-weight: 600;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 8px;
                    transition: all .2s;
                    letter-spacing: .01em;
                }

                .lp-btn-primary {
                    background: linear-gradient(135deg, #4f46e5, #6366f1);
                    color: #fff;
                    box-shadow: 0 4px 16px rgba(99, 102, 241, .35);
                }

                .lp-btn-primary:hover {
                    background: linear-gradient(135deg, #4338ca, #4f46e5);
                    box-shadow: 0 6px 22px rgba(99, 102, 241, .45);
                    transform: translateY(-1px);
                }

                .lp-btn-primary:active {
                    transform: translateY(0);
                }

                .lp-btn-success {
                    background: linear-gradient(135deg, #059669, #10b981);
                    color: #fff;
                    box-shadow: 0 4px 16px rgba(16, 185, 129, .3);
                }

                .lp-btn-success:hover {
                    background: linear-gradient(135deg, #047857, #059669);
                    box-shadow: 0 6px 22px rgba(16, 185, 129, .4);
                    transform: translateY(-1px);
                }

                .lp-btn-success:active {
                    transform: translateY(0);
                }

                /* ===== DIVIDER ===== */
                .lp-divider {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    color: #d1d5db;
                    font-size: 11.5px;
                    margin: .25rem 0;
                }

                .lp-divider::before,
                .lp-divider::after {
                    content: '';
                    flex: 1;
                    height: 1px;
                    background: #e5e7eb;
                }

                /* ===== SWITCH LINK ===== */
                .lp-switch {
                    text-align: center;
                    font-size: 13px;
                    color: #64748b;
                }

                .lp-switch a {
                    color: #6366f1;
                    font-weight: 600;
                    text-decoration: none;
                    cursor: pointer;
                }

                .lp-switch a:hover {
                    text-decoration: underline;
                }

                /* ===== FEATURE PILLS ===== */
                .lp-features {
                    display: flex;
                    gap: 8px;
                    flex-wrap: wrap;
                    justify-content: center;
                    margin-bottom: 1.4rem;
                }

                .lp-pill {
                    display: inline-flex;
                    align-items: center;
                    gap: 5px;
                    background: #f0fdf4;
                    color: #065f46;
                    border: 1px solid #bbf7d0;
                    border-radius: 999px;
                    font-size: 11.5px;
                    font-weight: 500;
                    padding: 4px 10px;
                }

                .lp-pill i {
                    font-size: 10px;
                }

                /* ===== RESPONSIVE ===== */
                @media (max-width: 540px) {
                    .lp-body {
                        padding: 1.5rem;
                    }

                    .lp-card-head {
                        padding: 1.8rem 1.5rem 0;
                    }
                }
            </style>
        </head>

        <body class="auth-page">
            <%@ include file="header.jsp" %>

                <main>
                    <div class="lp-card">

                        <!-- Card header with gradient + tabs -->
                        <div class="lp-card-head">
                            <div class="lp-logo">
                                <div class="lp-logo-icon"><i class="fas fa-book-open"></i></div>
                                <div class="lp-logo-text">LB<span>MS</span></div>
                            </div>
                            <div class="lp-tabs">
                                <button class="lp-tab <c:if test='${empty showRegister}'>active</c:if>" id="tab-login"
                                    onclick="switchTab('login')">
                                    <i class="fas fa-arrow-right-to-bracket" style="margin-right:6px"></i>Đăng nhập
                                </button>
                                <button class="lp-tab <c:if test='${not empty showRegister}'>active</c:if>"
                                    id="tab-register" onclick="switchTab('register')">
                                    <i class="fas fa-user-plus" style="margin-right:6px"></i>Đăng ký
                                </button>
                            </div>
                        </div>

                        <!-- Card body -->
                        <div class="lp-body">

                            <!-- ===== LOGIN PANEL ===== -->
                            <div class="lp-panel <c:if test='${empty showRegister}'>active</c:if>" id="panel-login">
                                <div class="lp-panel-title">Chào mừng trở lại!</div>
                                <div class="lp-panel-sub">Đăng nhập để tiếp tục khám phá kho sách của bạn.</div>

                                <c:if test="${not empty error}">
                                    <div class="lp-alert">
                                        <i class="fas fa-circle-exclamation"></i>
                                        <span>${error}</span>
                                    </div>
                                </c:if>

                                <form class="lp-form" method="post" action="${pageContext.request.contextPath}/login">
                                    <div class="lp-field">
                                        <div class="lp-label">Email</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-envelope"></i>
                                            <input type="email" name="email" placeholder="you@example.com" required
                                                autofocus />
                                        </div>
                                    </div>
                                    <div class="lp-field">
                                        <div class="lp-label">Mật khẩu</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-lock"></i>
                                            <input type="password" name="password" placeholder="••••••••" required />
                                        </div>
                                        <a href="${pageContext.request.contextPath}/reset-password" class="lp-forgot"
                                            style="margin-top:6px">Quên mật khẩu?</a>
                                    </div>
                                    <button type="submit" class="lp-btn lp-btn-primary">
                                        <i class="fas fa-arrow-right-to-bracket"></i> Đăng nhập
                                    </button>
                                    <div class="lp-divider">hoặc</div>
                                    <div class="lp-switch">
                                        Chưa có tài khoản? <a onclick="switchTab('register')">Đăng ký ngay</a>
                                    </div>
                                </form>
                            </div>

                            <!-- ===== REGISTER PANEL ===== -->
                            <div class="lp-panel <c:if test='${not empty showRegister}'>active</c:if>"
                                id="panel-register">
                                <div class="lp-panel-title">Tạo tài khoản</div>
                                <div class="lp-panel-sub">Miễn phí. Không cần thẻ tín dụng. Bắt đầu ngay hôm nay.</div>

                                <div class="lp-features">
                                    <div class="lp-pill"><i class="fas fa-check"></i> Mượn sách online</div>
                                    <div class="lp-pill"><i class="fas fa-check"></i> Gia hạn tự động</div>
                                    <div class="lp-pill"><i class="fas fa-check"></i> Thông báo hạn trả</div>
                                </div>

                                <form class="lp-form" method="post"
                                    action="${pageContext.request.contextPath}/register">
                                    <div class="lp-field">
                                        <div class="lp-label">Họ và tên</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-user"></i>
                                            <input type="text" name="fullName" placeholder="Nguyễn Văn A" required />
                                        </div>
                                    </div>
                                    <div class="lp-field">
                                        <div class="lp-label">Email</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-envelope"></i>
                                            <input type="email" name="email" placeholder="you@example.com" required />
                                        </div>
                                    </div>
                                    <div class="lp-field">
                                        <div class="lp-label">Mật khẩu</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-lock"></i>
                                            <input type="password" name="password" placeholder="Tối thiểu 6 ký tự"
                                                required />
                                        </div>
                                    </div>
                                    <button type="submit" class="lp-btn lp-btn-success">
                                        <i class="fas fa-user-plus"></i> Tạo tài khoản
                                    </button>
                                    <div class="lp-divider">hoặc</div>
                                    <div class="lp-switch">
                                        Đã có tài khoản? <a onclick="switchTab('login')">Đăng nhập</a>
                                    </div>
                                </form>
                            </div>

                        </div><!-- /lp-body -->
                    </div><!-- /lp-card -->
                </main>

                <%@ include file="footer.jsp" %>

                    <script>
                        function switchTab(tab) {
                            document.querySelectorAll('.lp-tab').forEach(t => t.classList.remove('active'));
                            document.querySelectorAll('.lp-panel').forEach(p => p.classList.remove('active'));
                            document.getElementById('tab-' + tab).classList.add('active');
                            document.getElementById('panel-' + tab).classList.add('active');
                        }
                        // If error exists, ensure login tab is shown
                        <c:if test="${not empty error}">
                            switchTab('login');
                        </c:if>
                    </script>
        </body>

        </html>