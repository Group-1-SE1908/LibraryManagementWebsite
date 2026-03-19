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
                *,
                *::before,
                *::after {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }

                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', sans-serif;
                    min-height: 100vh;
                    display: flex;
                    background: #0f172a;
                }

                /* ========== SPLIT LAYOUT ========== */
                .al-split {
                    display: flex;
                    width: 100%;
                    min-height: 100vh;
                }

                /* ========== LEFT BRAND PANEL ========== */
                .al-brand {
                    flex: 1;
                    background: linear-gradient(150deg, #0f172a 0%, #1e1b4b 45%, #2d1f6e 100%);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    padding: 3rem;
                    position: relative;
                    overflow: hidden;
                }

                /* Large decorative rings */
                .al-brand::before {
                    content: '';
                    position: absolute;
                    width: 700px;
                    height: 700px;
                    border: 1.5px solid rgba(99, 102, 241, .1);
                    border-radius: 50%;
                    top: -220px;
                    left: -280px;
                }

                .al-brand::after {
                    content: '';
                    position: absolute;
                    width: 500px;
                    height: 500px;
                    border: 1.5px solid rgba(129, 140, 248, .12);
                    border-radius: 50%;
                    bottom: -160px;
                    right: -160px;
                }

                .al-brand-inner {
                    position: relative;
                    z-index: 1;
                    text-align: center;
                    max-width: 400px;
                }

                .al-shield {
                    width: 100px;
                    height: 100px;
                    background: linear-gradient(135deg, #6366f1, #818cf8);
                    border-radius: 28px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin: 0 auto 2rem;
                    font-size: 46px;
                    color: #fff;
                    box-shadow: 0 20px 70px rgba(99, 102, 241, .55);
                    transform: rotate(-5deg);
                }

                .al-logo {
                    font-size: 2.2rem;
                    font-weight: 800;
                    color: #fff;
                    letter-spacing: -1px;
                    margin-bottom: .4rem;
                }

                .al-logo span {
                    color: #a5b4fc;
                }

                .al-tagline {
                    font-size: .9rem;
                    color: #94a3b8;
                    line-height: 1.7;
                    margin-bottom: 2.5rem;
                }

                .al-stats {
                    display: flex;
                    gap: 2.5rem;
                    justify-content: center;
                }

                .al-stat-val {
                    font-size: 1.5rem;
                    font-weight: 700;
                    color: #c7d2fe;
                }

                .al-stat-lbl {
                    font-size: .7rem;
                    color: #64748b;
                    text-transform: uppercase;
                    letter-spacing: .06em;
                    margin-top: 2px;
                }

                /* Floating decorative dots */
                .al-dot {
                    position: absolute;
                    border-radius: 50%;
                    background: rgba(99, 102, 241, .18);
                }

                .al-d1 {
                    width: 14px;
                    height: 14px;
                    top: 14%;
                    left: 8%;
                }

                .al-d2 {
                    width: 9px;
                    height: 9px;
                    top: 28%;
                    right: 12%;
                }

                .al-d3 {
                    width: 18px;
                    height: 18px;
                    bottom: 18%;
                    left: 16%;
                }

                .al-d4 {
                    width: 11px;
                    height: 11px;
                    bottom: 32%;
                    right: 9%;
                }

                .al-d5 {
                    width: 6px;
                    height: 6px;
                    top: 50%;
                    left: 4%;
                    opacity: .6;
                }

                /* Grid texture overlay */
                .al-brand-grid {
                    position: absolute;
                    inset: 0;
                    background-image:
                        linear-gradient(rgba(99, 102, 241, .04) 1px, transparent 1px),
                        linear-gradient(90deg, rgba(99, 102, 241, .04) 1px, transparent 1px);
                    background-size: 32px 32px;
                }

                /* ========== RIGHT FORM PANEL ========== */
                .al-form-panel {
                    width: 500px;
                    min-width: 500px;
                    background: #fff;
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    padding: 3.5rem;
                    position: relative;
                }

                .al-form-top {
                    width: 100%;
                    margin-bottom: 2rem;
                }

                .al-badge {
                    display: inline-flex;
                    align-items: center;
                    gap: 6px;
                    background: #ede9fe;
                    color: #5b21b6;
                    font-size: 11.5px;
                    font-weight: 600;
                    padding: 4px 12px;
                    border-radius: 999px;
                    margin-bottom: .9rem;
                    letter-spacing: .02em;
                }

                .al-form-top h2 {
                    font-size: 1.85rem;
                    font-weight: 800;
                    color: #0f172a;
                    letter-spacing: -.6px;
                    margin-bottom: .35rem;
                }

                .al-form-top p {
                    font-size: .85rem;
                    color: #64748b;
                }

                /* Error alert */
                .al-alert {
                    width: 100%;
                    background: #fff1f2;
                    border: 1px solid #fecdd3;
                    border-left: 4px solid #f43f5e;
                    border-radius: 10px;
                    padding: 12px 16px;
                    display: flex;
                    align-items: center;
                    gap: 10px;
                    font-size: 13.5px;
                    color: #9f1239;
                    margin-bottom: 1.25rem;
                }

                /* Form */
                .al-form {
                    width: 100%;
                    display: flex;
                    flex-direction: column;
                    gap: 1.1rem;
                }

                .al-field {
                    display: flex;
                    flex-direction: column;
                }

                .al-label {
                    font-size: 12.5px;
                    font-weight: 600;
                    color: #374151;
                    margin-bottom: 7px;
                    letter-spacing: .01em;
                }

                .al-input-wrap {
                    position: relative;
                }

                .al-input-wrap i {
                    position: absolute;
                    left: 14px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #94a3b8;
                    font-size: 14px;
                    pointer-events: none;
                    transition: color .2s;
                }

                .al-input-wrap:focus-within i {
                    color: #6366f1;
                }

                .al-input-wrap input {
                    width: 100%;
                    padding: 13px 14px 13px 42px;
                    border: 1.5px solid #e2e8f0;
                    border-radius: 11px;
                    font-size: 14px;
                    color: #0f172a;
                    background: #f8fafc;
                    transition: border-color .2s, background .2s, box-shadow .2s;
                }

                .al-input-wrap input:focus {
                    outline: none;
                    border-color: #6366f1;
                    background: #fff;
                    box-shadow: 0 0 0 4px rgba(99, 102, 241, .1);
                }

                .al-input-wrap input::placeholder {
                    color: #cbd5e1;
                }

                .al-forgot {
                    align-self: flex-end;
                    font-size: 12.5px;
                    color: #6366f1;
                    text-decoration: none;
                    margin-top: 5px;
                }

                .al-forgot:hover {
                    text-decoration: underline;
                }

                .al-submit {
                    margin-top: 4px;
                    width: 100%;
                    padding: 14px;
                    background: linear-gradient(135deg, #6366f1, #4f46e5);
                    color: #fff;
                    border: none;
                    border-radius: 12px;
                    font-size: 15px;
                    font-weight: 600;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 9px;
                    transition: all .2s;
                    box-shadow: 0 4px 18px rgba(99, 102, 241, .38);
                    letter-spacing: .01em;
                }

                .al-submit:hover {
                    background: linear-gradient(135deg, #4f46e5, #4338ca);
                    box-shadow: 0 8px 28px rgba(99, 102, 241, .48);
                    transform: translateY(-1px);
                }

                .al-submit:active {
                    transform: translateY(0);
                }

                .al-divider {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    color: #cbd5e1;
                    font-size: 12px;
                }

                .al-divider::before,
                .al-divider::after {
                    content: '';
                    flex: 1;
                    height: 1px;
                    background: #e2e8f0;
                }

                .al-user-link {
                    width: 100%;
                    padding: 13px 14px;
                    border: 1.5px solid #e2e8f0;
                    border-radius: 12px;
                    font-size: 13.5px;
                    font-weight: 500;
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

                .al-user-link:hover {
                    border-color: #c7d2fe;
                    background: #f5f3ff;
                    color: #4f46e5;
                }

                .al-footer-note {
                    margin-top: 2rem;
                    font-size: 11.5px;
                    color: #94a3b8;
                    display: flex;
                    align-items: center;
                    gap: 6px;
                }

                /* ========== RESPONSIVE ========== */
                @media (max-width: 860px) {
                    .al-brand {
                        display: none;
                    }

                    .al-form-panel {
                        width: 100%;
                        min-width: unset;
                    }
                }

                @media (max-width: 480px) {
                    .al-form-panel {
                        padding: 2rem 1.5rem;
                    }
                }
            </style>
        </head>

        <body>
            <div class="al-split">

                <!-- ===== LEFT: Brand Panel ===== -->
                <div class="al-brand">
                    <div class="al-brand-grid"></div>
                    <div class="al-dot al-d1"></div>
                    <div class="al-dot al-d2"></div>
                    <div class="al-dot al-d3"></div>
                    <div class="al-dot al-d4"></div>
                    <div class="al-dot al-d5"></div>

                    <div class="al-brand-inner">
                        <div class="al-shield">
                            <i class="fas fa-shield-halved"></i>
                        </div>
                        <div class="al-logo">LB<span>MS</span></div>
                        <p class="al-tagline">
                            Cổng quản trị hệ thống thư viện số.<br>
                            Quản lý sách, độc giả và vận hành thư viện<br>một cách hiệu quả.
                        </p>
                        <div class="al-stats">
                            <div>
                                <div class="al-stat-val">5000+</div>
                                <div class="al-stat-lbl">Đầu sách</div>
                            </div>
                            <div>
                                <div class="al-stat-val">1200+</div>
                                <div class="al-stat-lbl">Độc giả</div>
                            </div>
                            <div>
                                <div class="al-stat-val">24/7</div>
                                <div class="al-stat-lbl">Hỗ trợ</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== RIGHT: Form Panel ===== -->
                <div class="al-form-panel">
                    <div class="al-form-top">
                        <div class="al-badge">
                            <i class="fas fa-lock fa-2xs"></i>&nbsp;Truy cập nội bộ
                        </div>
                        <h2>Đăng nhập</h2>
                        <p>Chỉ dành cho quản trị viên và nhân viên thư viện.</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="al-alert">
                            <i class="fas fa-circle-exclamation"></i>
                            <span>${error}</span>
                        </div>
                    </c:if>

                    <form class="al-form" method="post" action="${pageContext.request.contextPath}/adminlogin">
                        <div class="al-field">
                            <div class="al-label">Email công việc</div>
                            <div class="al-input-wrap">
                                <i class="fas fa-envelope"></i>
                                <input type="email" name="email" placeholder="admin@library.edu" required autofocus />
                            </div>
                        </div>

                        <div class="al-field">
                            <div class="al-label">Mật khẩu</div>
                            <div class="al-input-wrap">
                                <i class="fas fa-lock"></i>
                                <input type="password" name="password" placeholder="••••••••" required />
                            </div>
                            <a href="${pageContext.request.contextPath}/reset-password" class="al-forgot">Quên mật
                                khẩu?</a>
                        </div>

                        <button type="submit" class="al-submit">
                            <i class="fas fa-arrow-right-to-bracket"></i>
                            Đăng nhập hệ thống
                        </button>

                        <div class="al-divider">hoặc</div>

                        <a href="${pageContext.request.contextPath}/login" class="al-user-link">
                            <i class="fas fa-user"></i> Tôi là bạn đọc thường
                        </a>
                    </form>

                    <div class="al-footer-note">
                        <i class="fas fa-shield fa-2xs"></i>
                        Kết nối được mã hóa và bảo mật
                    </div>
                </div>

            </div>
        </body>

        </html>