<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8" />
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <title>&#272;&#259;ng nh&#7853;p &amp; &#272;&#259;ng k&yacute; - LBMS</title>
            <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
            <style>
                :root {
                    --primary: #4f46e5;
                    --primary-light: #6366f1;
                    --primary-glow: rgba(99, 102, 241, .35);
                    --success: #059669;
                    --success-light: #10b981;
                    --danger: #f43f5e;
                }

                body.auth-page {
                    display: flex;
                    flex-direction: column;
                    min-height: 100vh;
                }

                body.auth-page main {
                    flex: 1;
                    display: flex;
                    overflow: hidden;
                }

                /* ===== LEFT BRAND PANEL ===== */
                .lp-brand {
                    flex: 1;
                    background: linear-gradient(135deg, #1e1b4b 0%, #312e81 40%, #4338ca 80%, #6366f1 100%);
                    display: flex;
                    flex-direction: column;
                    align-items: center;
                    justify-content: center;
                    padding: 3rem;
                    position: relative;
                    overflow: hidden;
                }

                .lp-brand::before {
                    content: '';
                    position: absolute;
                    inset: 0;
                    background-image:
                        linear-gradient(rgba(255, 255, 255, .03) 1px, transparent 1px),
                        linear-gradient(90deg, rgba(255, 255, 255, .03) 1px, transparent 1px);
                    background-size: 40px 40px;
                }

                .lp-orb {
                    position: absolute;
                    border-radius: 50%;
                    filter: blur(80px);
                    pointer-events: none;
                }

                .lp-orb-1 {
                    width: 450px;
                    height: 450px;
                    background: rgba(99, 102, 241, .3);
                    top: -120px;
                    left: -120px;
                    animation: orb-float 9s ease-in-out infinite;
                }

                .lp-orb-2 {
                    width: 320px;
                    height: 320px;
                    background: rgba(167, 139, 250, .2);
                    bottom: -90px;
                    right: -60px;
                    animation: orb-float 11s ease-in-out infinite reverse;
                }

                .lp-orb-3 {
                    width: 200px;
                    height: 200px;
                    background: rgba(56, 189, 248, .15);
                    top: 50%;
                    left: 60%;
                    animation: orb-float 7s ease-in-out infinite 2s;
                }

                @keyframes orb-float {

                    0%,
                    100% {
                        transform: translateY(0) scale(1);
                    }

                    50% {
                        transform: translateY(-22px) scale(1.06);
                    }
                }

                .lp-brand-inner {
                    position: relative;
                    z-index: 2;
                    text-align: center;
                    max-width: 460px;
                }

                .lp-book-icon {
                    width: 96px;
                    height: 96px;
                    background: rgba(255, 255, 255, .12);
                    backdrop-filter: blur(12px);
                    border: 1px solid rgba(255, 255, 255, .2);
                    border-radius: 26px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin: 0 auto 1.8rem;
                    font-size: 42px;
                    color: #fff;
                    box-shadow: 0 20px 60px rgba(0, 0, 0, .25), inset 0 1px 0 rgba(255, 255, 255, .15);
                    animation: icon-pulse 3.5s ease-in-out infinite;
                }

                @keyframes icon-pulse {

                    0%,
                    100% {
                        box-shadow: 0 20px 60px rgba(0, 0, 0, .25), 0 0 0 0 rgba(99, 102, 241, .4);
                    }

                    50% {
                        box-shadow: 0 20px 60px rgba(0, 0, 0, .25), 0 0 0 18px rgba(99, 102, 241, 0);
                    }
                }

                .lp-brand-title {
                    font-size: 2.6rem;
                    font-weight: 800;
                    color: #fff;
                    letter-spacing: -1px;
                    margin-bottom: .5rem;
                    line-height: 1.1;
                }

                .lp-brand-title span {
                    color: #a5b4fc;
                }

                .lp-brand-sub {
                    font-size: .95rem;
                    color: rgba(255, 255, 255, .65);
                    line-height: 1.75;
                    margin-bottom: 2.5rem;
                }

                .lp-features-list {
                    display: flex;
                    flex-direction: column;
                    gap: 1rem;
                    text-align: left;
                    margin-bottom: 2.5rem;
                }

                .lp-feat-item {
                    display: flex;
                    align-items: center;
                    gap: 14px;
                }

                .lp-feat-icon {
                    width: 40px;
                    height: 40px;
                    background: rgba(255, 255, 255, .1);
                    border-radius: 11px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #a5b4fc;
                    font-size: 16px;
                    flex-shrink: 0;
                    backdrop-filter: blur(4px);
                    border: 1px solid rgba(255, 255, 255, .1);
                }

                .lp-feat-text strong {
                    display: block;
                    font-size: .875rem;
                    font-weight: 600;
                    color: #fff;
                    margin-bottom: 1px;
                }

                .lp-feat-text span {
                    font-size: .78rem;
                    color: rgba(255, 255, 255, .5);
                }

                .lp-stats {
                    display: flex;
                    gap: 2rem;
                    justify-content: center;
                    padding-top: 2rem;
                    border-top: 1px solid rgba(255, 255, 255, .1);
                }

                .lp-stat-val {
                    font-size: 1.6rem;
                    font-weight: 800;
                    color: #c7d2fe;
                    line-height: 1;
                }

                .lp-stat-lbl {
                    font-size: .7rem;
                    color: rgba(255, 255, 255, .4);
                    text-transform: uppercase;
                    letter-spacing: .07em;
                    margin-top: 4px;
                }

                /* ===== RIGHT FORM PANEL ===== */
                .lp-form-panel {
                    width: 500px;
                    min-width: 500px;
                    background: #fff;
                    overflow-y: auto;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    padding: 3rem 3.5rem;
                }

                .lp-form-inner {
                    width: 100%;
                }

                .lp-mobile-logo {
                    display: none;
                    align-items: center;
                    gap: 10px;
                    margin-bottom: 1.5rem;
                }

                .lp-mobile-logo-icon {
                    width: 40px;
                    height: 40px;
                    background: linear-gradient(135deg, var(--primary), var(--primary-light));
                    border-radius: 11px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    color: #fff;
                    font-size: 17px;
                }

                .lp-mobile-logo-text {
                    font-size: 1.25rem;
                    font-weight: 800;
                    color: #0f172a;
                    letter-spacing: -.5px;
                }

                .lp-mobile-logo-text span {
                    color: var(--primary);
                }

                /* ===== TABS ===== */
                .lp-tabs {
                    display: flex;
                    background: #f1f5f9;
                    border-radius: 14px;
                    padding: 4px;
                    margin-bottom: 2rem;
                    gap: 4px;
                }

                .lp-tab {
                    flex: 1;
                    padding: 11px 0;
                    font-size: 13.5px;
                    font-weight: 600;
                    color: #64748b;
                    cursor: pointer;
                    background: none;
                    border: none;
                    border-radius: 11px;
                    transition: all .2s;
                    letter-spacing: .01em;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 7px;
                }

                .lp-tab.active {
                    background: #fff;
                    color: var(--primary);
                    box-shadow: 0 2px 10px rgba(15, 23, 42, .1);
                }

                .lp-tab:not(.active):hover {
                    color: #334155;
                }

                .lp-panel {
                    display: none;
                }

                .lp-panel.active {
                    display: block;
                    animation: panel-in .25s ease;
                }

                @keyframes panel-in {
                    from {
                        opacity: 0;
                        transform: translateY(6px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
                }

                .lp-panel-title {
                    font-size: 1.5rem;
                    font-weight: 800;
                    color: #0f172a;
                    margin-bottom: .3rem;
                    letter-spacing: -.5px;
                }

                .lp-panel-sub {
                    font-size: .83rem;
                    color: #64748b;
                    margin-bottom: 1.5rem;
                    line-height: 1.6;
                }

                /* ===== ALERT ===== */
                .lp-alert {
                    background: #fff1f2;
                    border: 1px solid #fecdd3;
                    border-left: 4px solid var(--danger);
                    border-radius: 10px;
                    padding: 12px 14px;
                    display: flex;
                    align-items: center;
                    gap: 9px;
                    font-size: 13px;
                    color: #9f1239;
                    margin-bottom: 1.2rem;
                    animation: slide-in .3s ease;
                }

                @keyframes slide-in {
                    from {
                        opacity: 0;
                        transform: translateY(-8px);
                    }

                    to {
                        opacity: 1;
                        transform: translateY(0);
                    }
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
                    font-size: 12.5px;
                    font-weight: 600;
                    color: #374151;
                    margin-bottom: 6px;
                    letter-spacing: .02em;
                }

                .lp-iw {
                    position: relative;
                }

                .lp-iw i.field-icon {
                    position: absolute;
                    left: 14px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #94a3b8;
                    font-size: 14px;
                    pointer-events: none;
                    transition: color .2s;
                }

                .lp-iw:focus-within i.field-icon {
                    color: var(--primary-light);
                }

                .lp-iw input {
                    width: 100%;
                    padding: 13px 14px 13px 42px;
                    border: 1.5px solid #e2e8f0;
                    border-radius: 12px;
                    font-size: 14px;
                    color: #0f172a;
                    background: #f8fafc;
                    transition: border-color .2s, background .2s, box-shadow .2s;
                }

                .lp-iw input:focus {
                    outline: none;
                    border-color: var(--primary-light);
                    background: #fff;
                    box-shadow: 0 0 0 4px rgba(99, 102, 241, .1);
                }

                .lp-iw input::placeholder {
                    color: #cbd5e1;
                }

                .lp-iw .toggle-pw {
                    position: absolute;
                    right: 13px;
                    top: 50%;
                    transform: translateY(-50%);
                    color: #94a3b8;
                    cursor: pointer;
                    font-size: 13px;
                    padding: 4px;
                    border: none;
                    background: none;
                    transition: color .2s;
                }

                .lp-iw .toggle-pw:hover {
                    color: var(--primary-light);
                }

                .lp-iw.has-toggle input {
                    padding-right: 40px;
                }

                .lp-forgot {
                    align-self: flex-end;
                    font-size: 12px;
                    color: var(--primary-light);
                    text-decoration: none;
                    margin-top: 6px;
                    font-weight: 500;
                }

                .lp-forgot:hover {
                    text-decoration: underline;
                }

                /* ===== SUBMIT BUTTONS ===== */
                .lp-btn {
                    margin-top: 4px;
                    width: 100%;
                    padding: 14px;
                    border: none;
                    border-radius: 12px;
                    font-size: 14.5px;
                    font-weight: 700;
                    cursor: pointer;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    gap: 8px;
                    transition: all .2s;
                    letter-spacing: .02em;
                }

                .lp-btn-primary {
                    background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
                    color: #fff;
                    box-shadow: 0 4px 16px var(--primary-glow);
                }

                .lp-btn-primary:hover {
                    transform: translateY(-1.5px);
                    box-shadow: 0 8px 28px var(--primary-glow);
                    filter: brightness(1.05);
                }

                .lp-btn-primary:active {
                    transform: translateY(0);
                }

                .lp-btn-success {
                    background: linear-gradient(135deg, var(--success), var(--success-light));
                    color: #fff;
                    box-shadow: 0 4px 16px rgba(16, 185, 129, .3);
                }

                .lp-btn-success:hover {
                    transform: translateY(-1.5px);
                    box-shadow: 0 8px 28px rgba(16, 185, 129, .4);
                    filter: brightness(1.05);
                }

                .lp-btn-success:active {
                    transform: translateY(0);
                }

                .lp-divider {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    color: #cbd5e1;
                    font-size: 11.5px;
                    margin: .1rem 0;
                }

                .lp-divider::before,
                .lp-divider::after {
                    content: '';
                    flex: 1;
                    height: 1px;
                    background: #e5e7eb;
                }

                .lp-switch {
                    text-align: center;
                    font-size: 13px;
                    color: #64748b;
                }

                .lp-switch a {
                    color: var(--primary);
                    font-weight: 600;
                    text-decoration: none;
                    cursor: pointer;
                }

                .lp-switch a:hover {
                    text-decoration: underline;
                }

                .lp-pills {
                    display: flex;
                    gap: 7px;
                    flex-wrap: wrap;
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
                    font-weight: 600;
                    padding: 5px 11px;
                }

                .lp-pill i {
                    font-size: 10px;
                }

                /* ===== RESPONSIVE ===== */
                @media (max-width: 900px) {
                    .lp-brand {
                        display: none;
                    }

                    .lp-form-panel {
                        width: 100%;
                        min-width: unset;
                    }

                    .lp-mobile-logo {
                        display: flex;
                    }
                }

                @media (max-width: 540px) {
                    .lp-form-panel {
                        padding: 2rem 1.5rem;
                    }
                }
            </style>
        </head>

        <body class="auth-page">
            <%@ include file="header.jsp" %>

                <main>
                    <!-- LEFT: BRAND PANEL -->
                    <div class="lp-brand">
                        <div class="lp-orb lp-orb-1"></div>
                        <div class="lp-orb lp-orb-2"></div>
                        <div class="lp-orb lp-orb-3"></div>

                        <div class="lp-brand-inner">
                            <div class="lp-book-icon">
                                <i class="fas fa-book-open"></i>
                            </div>
                            <div class="lp-brand-title">Th&#432; vi&#7879;n<br><span>s&#7889; LBMS</span></div>
                            <p class="lp-brand-sub">
                                N&#7873;n t&#7843;ng qu&#7843;n l&#253; th&#432; vi&#7879;n hi&#7879;n &#273;&#7841;i
                                &mdash; m&#432;&#7907;n s&aacute;ch,<br>
                                gia h&#7841;n v&agrave; theo d&#245;i l&#7883;ch s&#7917; &#273;&#7885;c s&aacute;ch
                                d&#7877; d&agrave;ng.
                            </p>

                            <div class="lp-features-list">
                                <div class="lp-feat-item">
                                    <div class="lp-feat-icon"><i class="fas fa-laptop"></i></div>
                                    <div class="lp-feat-text">
                                        <strong>M&#432;&#7907;n s&aacute;ch tr&#7921;c tuy&#7871;n</strong>
                                        <span>&#272;&#7863;t m&#432;&#7907;n v&agrave; nh&#7853;n s&aacute;ch t&#7853;n
                                            n&#417;i t&#7915; kho s&aacute;ch &#273;a d&#7841;ng</span>
                                    </div>
                                </div>
                                <div class="lp-feat-item">
                                    <div class="lp-feat-icon"><i class="fas fa-bell"></i></div>
                                    <div class="lp-feat-text">
                                        <strong>Th&ocirc;ng b&aacute;o t&#7921; &#273;&#7897;ng</strong>
                                        <span>Nh&#7855;c nh&#7903; h&#7841;n tr&#7843; s&aacute;ch v&agrave; &#432;u
                                            &#273;&atilde;i th&agrave;nh vi&ecirc;n</span>
                                    </div>
                                </div>
                                <div class="lp-feat-item">
                                    <div class="lp-feat-icon"><i class="fas fa-clock-rotate-left"></i></div>
                                    <div class="lp-feat-text">
                                        <strong>L&#7883;ch s&#7917; &#273;&#7885;c s&aacute;ch</strong>
                                        <span>Theo d&#245;i h&agrave;nh tr&igrave;nh &#273;&#7885;c s&aacute;ch
                                            c&#7911;a b&#7841;n theo th&#7901;i gian</span>
                                    </div>
                                </div>
                            </div>

                            <div class="lp-stats">
                                <div>
                                    <div class="lp-stat-val">5,000+</div>
                                    <div class="lp-stat-lbl">&#272;&#7847;u s&aacute;ch</div>
                                </div>
                                <div>
                                    <div class="lp-stat-val">1,200+</div>
                                    <div class="lp-stat-lbl">&#272;&#7897;c gi&#7843;</div>
                                </div>
                                <div>
                                    <div class="lp-stat-val">98%</div>
                                    <div class="lp-stat-lbl">H&agrave;i l&ograve;ng</div>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- RIGHT: FORM PANEL -->
                    <div class="lp-form-panel">
                        <div class="lp-form-inner">

                            <div class="lp-mobile-logo">
                                <div class="lp-mobile-logo-icon"><i class="fas fa-book-open"></i></div>
                                <div class="lp-mobile-logo-text">LB<span>MS</span></div>
                            </div>

                            <div class="lp-tabs">
                                <button class="lp-tab <c:if test='${empty showRegister}'>active</c:if>" id="tab-login"
                                    onclick="switchTab('login')">
                                    <i class="fas fa-arrow-right-to-bracket"></i> &#272;&#259;ng nh&#7853;p
                                </button>
                                <button class="lp-tab <c:if test='${not empty showRegister}'>active</c:if>"
                                    id="tab-register" onclick="switchTab('register')">
                                    <i class="fas fa-user-plus"></i> &#272;&#259;ng k&yacute;
                                </button>
                            </div>

                            <!-- LOGIN PANEL -->
                            <div class="lp-panel <c:if test='${empty showRegister}'>active</c:if>" id="panel-login">
                                <div class="lp-panel-title">Ch&agrave;o m&#7915;ng tr&#7903; l&#7841;i!</div>
                                <div class="lp-panel-sub">&#272;&#259;ng nh&#7853;p &#273;&#7875; ti&#7871;p t&#7909;c
                                    kh&aacute;m ph&aacute; kho s&aacute;ch c&#7911;a b&#7841;n.</div>

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
                                            <i class="fas fa-envelope field-icon"></i>
                                            <input type="email" name="email" placeholder="you@example.com" required
                                                autofocus />
                                        </div>
                                    </div>
                                    <div class="lp-field">
                                        <div class="lp-label">M&#7853;t kh&#7849;u</div>
                                        <div class="lp-iw has-toggle">
                                            <i class="fas fa-lock field-icon"></i>
                                            <input type="password" name="password" id="pw-login"
                                                placeholder="&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;&#8226;"
                                                required />
                                            <button type="button" class="toggle-pw"
                                                onclick="togglePw('pw-login', this)">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                        <a href="${pageContext.request.contextPath}/reset-password" class="lp-forgot">
                                            Qu&ecirc;n m&#7853;t kh&#7849;u?
                                        </a>
                                    </div>
                                    <button type="submit" class="lp-btn lp-btn-primary">
                                        <i class="fas fa-arrow-right-to-bracket"></i> &#272;&#259;ng nh&#7853;p
                                    </button>
                                    <div class="lp-divider">ho&#7863;c</div>
                                    <div class="lp-switch">
                                        Ch&#432;a c&oacute; t&agrave;i kho&#7843;n? <a
                                            onclick="switchTab('register')">&#272;&#259;ng k&yacute; ngay</a>
                                    </div>
                                </form>
                            </div>

                            <!-- REGISTER PANEL -->
                            <div class="lp-panel <c:if test='${not empty showRegister}'>active</c:if>"
                                id="panel-register">
                                <div class="lp-panel-title">T&#7841;o t&agrave;i kho&#7843;n</div>
                                <div class="lp-panel-sub">Mi&#7877;n ph&iacute;. Kh&ocirc;ng gi&#7899;i h&#7841;n.
                                    B&#7855;t &#273;&#7847;u ngay h&ocirc;m nay.</div>

                                <div class="lp-pills">
                                    <div class="lp-pill"><i class="fas fa-check"></i> M&#432;&#7907;n s&aacute;ch online
                                    </div>
                                    <div class="lp-pill"><i class="fas fa-check"></i> Gia h&#7841;n t&#7921;
                                        &#273;&#7897;ng</div>
                                    <div class="lp-pill"><i class="fas fa-check"></i> Th&ocirc;ng b&aacute;o h&#7841;n
                                        tr&#7843;</div>
                                </div>

                                <form class="lp-form" method="post"
                                    action="${pageContext.request.contextPath}/register">
                                    <div class="lp-field">
                                        <div class="lp-label">H&#7885; v&agrave; t&ecirc;n</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-user field-icon"></i>
                                            <input type="text" name="fullName" placeholder="Nguy&#7877;n V&#259;n A"
                                                required />
                                        </div>
                                    </div>
                                    <div class="lp-field">
                                        <div class="lp-label">Email</div>
                                        <div class="lp-iw">
                                            <i class="fas fa-envelope field-icon"></i>
                                            <input type="email" name="email" placeholder="you@example.com" required />
                                        </div>
                                    </div>
                                    <div class="lp-field">
                                        <div class="lp-label">M&#7853;t kh&#7849;u</div>
                                        <div class="lp-iw has-toggle">
                                            <i class="fas fa-lock field-icon"></i>
                                            <input type="password" name="password" id="pw-reg"
                                                placeholder="T&#7889;i thi&#7875;u 6 k&yacute; t&#7921;" required />
                                            <button type="button" class="toggle-pw" onclick="togglePw('pw-reg', this)">
                                                <i class="fas fa-eye"></i>
                                            </button>
                                        </div>
                                    </div>
                                    <button type="submit" class="lp-btn lp-btn-success">
                                        <i class="fas fa-user-plus"></i> T&#7841;o t&agrave;i kho&#7843;n
                                    </button>
                                    <div class="lp-divider">ho&#7863;c</div>
                                    <div class="lp-switch">
                                        &#272;&atilde; c&oacute; t&agrave;i kho&#7843;n? <a
                                            onclick="switchTab('login')">&#272;&#259;ng nh&#7853;p</a>
                                    </div>
                                </form>
                            </div>

                        </div>
                    </div>
                </main>

                <%@ include file="footer.jsp" %>

                    <script>
                        function switchTab(tab) {
                            document.querySelectorAll('.lp-tab').forEach(t => t.classList.remove('active'));
                            document.querySelectorAll('.lp-panel').forEach(p => p.classList.remove('active'));
                            document.getElementById('tab-' + tab).classList.add('active');
                            document.getElementById('panel-' + tab).classList.add('active');
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