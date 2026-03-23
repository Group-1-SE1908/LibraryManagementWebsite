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
                :root {
                    --primary: #4f46e5;
                    --primary-light: #6366f1;
                    --success: #059669;
                    --success-light: #10b981;
                    --danger: #f43f5e;
                }

                body.auth-page {
                    display: flex;
                    flex-direction: column;
                    min-height: 100vh;
                    background: #f1f5f9;
                }

                body.auth-page main {
                    flex: 1;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 2rem 1rem;
                }

                .auth-card {
                    background: #fff;
                    border-radius: 20px;
                    box-shadow: 0 4px 24px rgba(15, 23, 42, .1);
                    padding: 2.5rem;
                    width: 100%;
                    max-width: 440px;
                }

                .auth-logo {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    margin-bottom: 2rem;
                }

                .auth-logo-icon {
                    width: 42px;
                    height: 42px;
                    background: linear-gradient(135deg, var(--primary), var(--primary-light));
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #fff;
                    font-size: 18px;
                }

                .auth-logo-text {
                    font-size: 1.3rem;
                    font-weight: 800;
                    color: #0f172a;
                    letter-spacing: -.5px;
                }

                .auth-logo-text span {
                    color: var(--primary);
                }

                .auth-tabs {
                    display: flex;
                    background: #f1f5f9;
                    border-radius: 12px;
                    padding: 4px;
                    margin-bottom: 1.75rem;
                    gap: 4px;
                }

                .auth-tab {
                    flex: 1;
                    padding: 10px 0;
                    font-size: 13.5px;
                    font-weight: 600;
                    color: #64748b;
                    cursor: pointer;
                    background: none;
                    border: none;
                    border-radius: 9px;
                    transition: all .2s;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 6px;
                }

                .auth-tab.active {
                    background: #fff;
                    color: var(--primary);
                    box-shadow: 0 2px 8px rgba(15, 23, 42, .1);
                }

                .auth-panel {
                    display: none;
                }

                .auth-panel.active {
                    display: block;
                }

                .auth-panel-title {
                    font-size: 1.35rem;
                    font-weight: 800;
                    color: #0f172a;
                    margin-bottom: .25rem;
                    letter-spacing: -.4px;
                }

                .auth-panel-sub {
                    font-size: .83rem;
                    color: #64748b;
                    margin-bottom: 1.5rem;
                }

                .auth-alert {
                    background: #fff1f2;
                    border: 1px solid #fecdd3;
                    border-left: 4px solid var(--danger);
                    border-radius: 10px;
                    padding: 11px 14px;
                    display: flex;
                    align-items: center;
                    gap: 9px;
                    font-size: 13px;
                    color: #9f1239;
                    margin-bottom: 1.2rem;
                }

                .auth-form {
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                }

                .auth-label {
                    display: block;
                    font-size: 12.5px;
                    font-weight: 600;
                    color: #374151;
                    margin-bottom: 5px;
                }

                .auth-iw {
                    position: relative;
                }

                .auth-iw i.fi {
                    position: absolute;
                    left: 13px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #94a3b8;
                    font-size: 13px;
                    pointer-events: none;
                }

                .auth-iw:focus-within i.fi {
                    color: var(--primary-light);
                }

                .auth-iw input {
                    width: 100%;
                    padding: 12px 12px 12px 38px;
                    border: 1.5px solid #e2e8f0;
                    border-radius: 10px;
                    font-size: 14px;
                    color: #0f172a;
                    background: #f8fafc;
                    transition: border-color .2s, box-shadow .2s;
                }

                .auth-iw input:focus {
                    outline: none;
                    border-color: var(--primary-light);
                    background: #fff;
                    box-shadow: 0 0 0 3px rgba(99, 102, 241, .1);
                }

                .auth-iw input::placeholder {
                    color: #cbd5e1;
                }

                .auth-iw .toggle-pw {
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

                .auth-iw .toggle-pw:hover {
                    color: var(--primary-light);
                }

                .auth-iw.has-toggle input {
                    padding-right: 38px;
                }

                .auth-forgot {
                    display: block;
                    text-align: right;
                    font-size: 12px;
                    color: var(--primary-light);
                    font-weight: 500;
                    text-decoration: none;
                    margin-top: 5px;
                }

                .auth-forgot:hover {
                    text-decoration: underline;
                }

                .auth-btn {
                    width: 100%;
                    padding: 13px;
                    border: none;
                    border-radius: 10px;
                    font-size: 14.5px;
                    font-weight: 700;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 7px;
                    transition: all .2s;
                    margin-top: 4px;
                }

                .auth-btn-primary {
                    background: linear-gradient(135deg, var(--primary), var(--primary-light));
                    color: #fff;
                    box-shadow: 0 3px 12px rgba(99, 102, 241, .35);
                }

                .auth-btn-primary:hover {
                    box-shadow: 0 6px 20px rgba(99, 102, 241, .45);
                    transform: translateY(-1px);
                }

                .auth-btn-success {
                    background: linear-gradient(135deg, var(--success), var(--success-light));
                    color: #fff;
                    box-shadow: 0 3px 12px rgba(16, 185, 129, .3);
                }

                .auth-btn-success:hover {
                    box-shadow: 0 6px 20px rgba(16, 185, 129, .4);
                    transform: translateY(-1px);
                }

                .auth-divider {
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    color: #cbd5e1;
                    font-size: 11.5px;
                }

                .auth-divider::before,
                .auth-divider::after {
                    content: '';
                    flex: 1;
                    height: 1px;
                    background: #e5e7eb;
                }

                .auth-switch {
                    text-align: center;
                    font-size: 13px;
                    color: #64748b;
                }

                .auth-switch a {
                    color: var(--primary);
                    font-weight: 600;
                    text-decoration: none;
                    cursor: pointer;
                }

                .auth-switch a:hover {
                    text-decoration: underline;
                }
            </style>
        </head>

        <body class="auth-page">
            <%@ include file="header.jsp" %>

                <main>
                    <div class="auth-card">

                        <div class="auth-logo">
                            <div class="auth-logo-icon"><i class="fas fa-book-open"></i></div>
                            <div class="auth-logo-text">LB<span>MS</span></div>
                        </div>

                        <div class="auth-tabs">
                            <button class="auth-tab <c:if test='${empty showRegister}'>active</c:if>" id="tab-login"
                                onclick="switchTab('login')">
                                <i class="fas fa-arrow-right-to-bracket"></i> Đăng nhập
                            </button>
                            <button class="auth-tab <c:if test='${not empty showRegister}'>active</c:if>"
                                id="tab-register" onclick="switchTab('register')">
                                <i class="fas fa-user-plus"></i> Đăng ký
                            </button>
                        </div>

                        <!-- LOGIN PANEL -->
                        <div class="auth-panel <c:if test='${empty showRegister}'>active</c:if>" id="panel-login">
                            <div class="auth-panel-title">Chào mừng trở lại!</div>
                            <div class="auth-panel-sub">Đăng nhập để tiếp tục khám phá kho sách.</div>

                            <c:if test="${not empty error}">
                                <div class="auth-alert">
                                    <i class="fas fa-circle-exclamation"></i>
                                    <span>${error}</span>
                                </div>
                            </c:if>

                            <form class="auth-form" method="post" action="${pageContext.request.contextPath}/login">
                                <div>
                                    <label class="auth-label">Email</label>
                                    <div class="auth-iw">
                                        <i class="fas fa-envelope fi"></i>
                                        <input type="email" name="email" placeholder="you@example.com" required
                                            autofocus />
                                    </div>
                                </div>
                                <div>
                                    <label class="auth-label">Mật khẩu</label>
                                    <div class="auth-iw has-toggle">
                                        <i class="fas fa-lock fi"></i>
                                        <input type="password" name="password" id="pw-login" placeholder="••••••••"
                                            required />
                                        <button type="button" class="toggle-pw" onclick="togglePw('pw-login', this)">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                    <a href="${pageContext.request.contextPath}/reset-password" class="auth-forgot">Quên
                                        mật khẩu?</a>
                                </div>
                                <button type="submit" class="auth-btn auth-btn-primary">
                                    <i class="fas fa-arrow-right-to-bracket"></i> Đăng nhập
                                </button>
                                <div class="auth-divider">hoặc</div>
                                <div class="auth-switch">Chưa có tài khoản? <a onclick="switchTab('register')">Đăng ký
                                        ngay</a></div>
                            </form>
                        </div>

                        <!-- REGISTER PANEL -->
                        <div class="auth-panel <c:if test='${not empty showRegister}'>active</c:if>"
                            id="panel-register">
                            <div class="auth-panel-title">Tạo tài khoản</div>
                            <div class="auth-panel-sub">Miễn phí. Bắt đầu ngay hôm nay.</div>

                            <form class="auth-form" method="post" action="${pageContext.request.contextPath}/register">
                                <div>
                                    <label class="auth-label">Họ và tên</label>
                                    <div class="auth-iw">
                                        <i class="fas fa-user fi"></i>
                                        <input type="text" name="fullName" placeholder="Nguyễn Văn A" required />
                                    </div>
                                </div>
                                <div>
                                    <label class="auth-label">Email</label>
                                    <div class="auth-iw">
                                        <i class="fas fa-envelope fi"></i>
                                        <input type="email" name="email" placeholder="you@example.com" required />
                                    </div>
                                </div>
                                <div>
                                    <label class="auth-label">Mật khẩu</label>
                                    <div class="auth-iw has-toggle">
                                        <i class="fas fa-lock fi"></i>
                                        <input type="password" name="password" id="pw-reg"
                                            placeholder="Tối thiểu 6 ký tự" required />
                                        <button type="button" class="toggle-pw" onclick="togglePw('pw-reg', this)">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                </div>
                                <div>
                                    <label class="auth-label">Xác nhận mật khẩu</label>
                                    <div class="auth-iw has-toggle">
                                        <i class="fas fa-lock fi"></i>
                                        <input type="password" id="pw-reg-confirm" placeholder="Nhập lại mật khẩu"
                                            required />
                                        <button type="button" class="toggle-pw"
                                            onclick="togglePw('pw-reg-confirm', this)">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                    </div>
                                    <span id="pw-match-msg" style="font-size:12px;margin-top:5px;display:none;"></span>
                                </div>
                                <button type="submit" class="auth-btn auth-btn-success" id="btn-register"
                                    onclick="return checkPasswords()">
                                    <i class="fas fa-user-plus"></i> Tạo tài khoản
                                </button>
                                <div class="auth-divider">hoặc</div>
                                <div class="auth-switch">Đã có tài khoản? <a onclick="switchTab('login')">Đăng nhập</a>
                                </div>
                            </form>
                        </div>

                    </div>
                </main>

                <%@ include file="footer.jsp" %>

                    <script>
                        function switchTab(tab) {
                            document.querySelectorAll('.auth-tab').forEach(t => t.classList.remove('active'));
                            document.querySelectorAll('.auth-panel').forEach(p => p.classList.remove('active'));
                            document.getElementById('tab-' + tab).classList.add('active');
                            document.getElementById('panel-' + tab).classList.add('active');
                        }

                        document.getElementById('pw-reg-confirm').addEventListener('input', function () {
                            const pw = document.getElementById('pw-reg').value;
                            const msg = document.getElementById('pw-match-msg');
                            msg.style.display = 'block';
                            if (this.value === '') { msg.style.display = 'none'; return; }
                            if (this.value === pw) {
                                msg.textContent = '✓ Mật khẩu khớp';
                                msg.style.color = '#059669';
                            } else {
                                msg.textContent = '✗ Mật khẩu không khớp';
                                msg.style.color = '#f43f5e';
                            }
                        });

                        function checkPasswords() {
                            const pw = document.getElementById('pw-reg').value;
                            const confirm = document.getElementById('pw-reg-confirm').value;
                            if (pw !== confirm) {
                                const msg = document.getElementById('pw-match-msg');
                                msg.style.display = 'block';
                                msg.textContent = '✗ Mật khẩu không khớp';
                                msg.style.color = '#f43f5e';
                                document.getElementById('pw-reg-confirm').focus();
                                return false;
                            }
                            return true;
                        }

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

                        <c:if test="${not empty error}">
                            switchTab('login');
                        </c:if>
                    </script>
        </body>

        </html>