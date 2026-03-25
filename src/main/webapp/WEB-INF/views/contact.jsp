<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Liên Hệ - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        .contact-grid {
            display: grid;
            grid-template-columns: 380px 1fr;
            gap: 0;
            background: var(--mp-surface);
            border-radius: var(--mp-radius);
            border: 1.5px solid var(--mp-border);
            box-shadow: var(--mp-shadow-lg);
            overflow: hidden;
            margin-top: 40px; /* Pushed down from hero */
            position: relative;
            z-index: 10;
        }

        .contact-sidebar {
            background: var(--mp-gradient-rich);
            color: #fff;
            padding: 50px 40px;
            display: flex;
            flex-direction: column;
            position: relative;
            overflow: hidden;
        }

        .contact-sidebar::before {
            content: "";
            position: absolute;
            inset: 0;
            background: radial-gradient(circle at 80% 20%, rgba(255, 255, 255, 0.1), transparent 60%);
            pointer-events: none;
        }

        .contact-sidebar h3 {
            font-size: 1.5rem;
            font-weight: 800;
            margin-bottom: 12px;
            color: #fff;
        }

        .contact-sidebar p {
            font-size: 0.9rem;
            color: rgba(255, 255, 255, 0.7);
            line-height: 1.6;
            margin-bottom: 40px;
        }

        .contact-info-list {
            display: flex;
            flex-direction: column;
            gap: 24px;
        }

        .info-item {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .info-icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            background: rgba(255, 255, 255, 0.1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            color: #fff;
            flex-shrink: 0;
        }

        .info-content span {
            display: block;
            font-size: 0.7rem;
            text-transform: uppercase;
            letter-spacing: 0.1em;
            color: rgba(255, 255, 255, 0.5);
            margin-bottom: 2px;
        }

        .info-content strong {
            font-size: 0.95rem;
            font-weight: 600;
        }

        .contact-form-area {
            padding: 50px 60px;
            background: #fff;
        }

        .form-title {
            font-size: 1.35rem;
            font-weight: 800;
            color: var(--mp-text);
            margin-bottom: 30px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .mp-form-group {
            margin-bottom: 22px;
        }

        .mp-form-group label {
            display: block;
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--mp-text-secondary);
            margin-bottom: 8px;
            text-transform: uppercase;
            letter-spacing: 0.04em;
        }

        .mp-input {
            width: 100%;
            padding: 12px 16px;
            border-radius: var(--mp-radius-xs);
            border: 1.5px solid var(--mp-border);
            font-size: 0.9rem;
            color: var(--mp-text);
            transition: all var(--mp-transition);
            background: var(--mp-surface-2);
        }

        .mp-input:focus {
            outline: none;
            background: #fff;
            border-color: var(--mp-primary-mid);
            box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.1);
        }

        .feedback-options {
            display: flex;
            gap: 16px;
            flex-wrap: wrap;
            margin-top: 5px;
        }

        .feedback-option {
            flex: 1;
            min-width: 120px;
            position: relative;
        }

        .feedback-option input {
            position: absolute;
            opacity: 0;
            cursor: pointer;
        }

        .feedback-label {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 10px;
            border: 1.5px solid var(--mp-border);
            border-radius: var(--mp-radius-xs);
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--mp-text-secondary);
            cursor: pointer;
            transition: all var(--mp-transition);
            background: var(--mp-surface-2);
            text-align: center;
        }

        .feedback-option input:checked + .feedback-label {
            background: var(--mp-primary-xlight);
            border-color: var(--mp-primary-mid);
            color: var(--mp-primary-mid);
            box-shadow: 0 4px 12px rgba(37, 99, 235, 0.08);
        }

        .btn-send {
            background: var(--mp-gradient);
            color: #fff;
            border: none;
            padding: 14px 32px;
            font-size: 0.95rem;
            font-weight: 700;
            border-radius: 999px;
            cursor: pointer;
            transition: all var(--mp-transition);
            box-shadow: 0 8px 24px rgba(30, 58, 138, 0.25);
            display: inline-flex;
            align-items: center;
            gap: 10px;
            margin-top: 10px;
        }

        .btn-send:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 32px rgba(30, 58, 138, 0.35);
        }

        .btn-send i {
            font-size: 1rem;
        }

        @media (max-width: 900px) {
            .contact-grid {
                grid-template-columns: 1fr;
            }
            .contact-sidebar {
                padding: 40px;
            }
            .contact-form-area {
                padding: 40px;
            }
        }
    </style>
</head>
<body class="mp-body">
    <jsp:include page="/WEB-INF/views/header.jsp" />

    <!-- HERO -->
    <section class="mp-hero">
        <div class="mp-hero__inner">
            <div>
                <p class="mp-hero__eyebrow">Hỗ trợ</p>
                <h1 class="mp-hero__title">Liên hệ với chúng tôi</h1>
                <p class="mp-hero__subtitle">Gửi yêu cầu hoặc phản hồi của bạn để được hỗ trợ tốt nhất từ đội ngũ thư viện.</p>
            </div>
            <div class="mp-hero__cards">
                <div class="mp-hero__card" style="min-width: 240px">
                    <p class="mp-hero__card-label">Email hỗ trợ</p>
                    <p class="mp-hero__card-value" style="font-size: 1.2rem; -webkit-text-fill-color: initial; color: #fff; background: none;">lbms.support@gmail.com</p>
                    <p class="mp-hero__card-detail">Phản hồi trong 24h</p>
                </div>
            </div>
        </div>
    </section>

    <main class="mp-content" style="padding-top: 60px; padding-bottom: 80px;">
        <div class="contact-grid" style="margin-top: 0; margin-bottom: 40px;">
            <div class="contact-sidebar">
                <h3>Thông tin liên hệ</h3>
                <p>Chúng tôi luôn lắng nghe ý kiến đóng góp của bạn để hoàn thiện hệ thống thư viện mỗi ngày.</p>
                
                <div class="contact-info-list">
                    <div class="info-item">
                        <div class="info-icon"><i class="fas fa-map-marker-alt"></i></div>
                        <div class="info-content">
                            <span>Địa chỉ</span>
                            <strong>Số 600 Nguyễn Văn Cừ, Cần Thơ</strong>
                        </div>
                    </div>
                    <div class="info-item">
                        <div class="info-icon"><i class="fas fa-phone-alt"></i></div>
                        <div class="info-content">
                            <span>Điện thoại</span>
                            <strong>+84 287 300 5588</strong>
                        </div>
                    </div>
                    <div class="info-item">
                        <div class="info-icon"><i class="fas fa-envelope"></i></div>
                        <div class="info-content">
                            <span>Email</span>
                            <strong>lbms.support@gmail.com</strong>
                        </div>
                    </div>
                </div>

                <div style="margin-top: auto; padding-top: 40px; display: flex; gap: 16px;">
                    <a href="#" style="color: #fff; font-size: 1.2rem; opacity: 0.7"><i class="fab fa-facebook-f"></i></a>
                    <a href="#" style="color: #fff; font-size: 1.2rem; opacity: 0.7"><i class="fab fa-twitter"></i></a>
                    <a href="#" style="color: #fff; font-size: 1.2rem; opacity: 0.7"><i class="fab fa-instagram"></i></a>
                    <a href="#" style="color: #fff; font-size: 1.2rem; opacity: 0.7"><i class="fab fa-linkedin-in"></i></a>
                </div>
            </div>

            <div class="contact-form-area">
                <h2 class="form-title">Gửi tin nhắn cho chúng tôi</h2>

                <c:if test="${not empty error}">
                    <div class="mp-flash mp-flash--error">
                        <i class="fas fa-exclamation-circle"></i>
                        <span>${error}</span>
                    </div>
                </c:if>
                <c:if test="${not empty sessionScope.toastMessage}">
                    <div class="mp-flash mp-flash--success">
                        <i class="fas fa-check-circle"></i>
                        <span>${sessionScope.toastMessage}</span>
                    </div>
                    <c:remove var="toastMessage" scope="session" />
                </c:if>

                <form action="${pageContext.request.contextPath}/contact" method="POST">
                    <c:set var="user" value="${sessionScope.currentUser}" />
                    
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
                        <div class="mp-form-group">
                            <label>Họ và Tên *</label>
                            <input type="text" name="fullName" value="${not empty user ? user.fullName : ''}" required class="mp-input" placeholder="Nhập họ và tên" />
                        </div>
                        <div class="mp-form-group">
                            <label>Số điện thoại *</label>
                            <input type="text" name="phone" value="${not empty user ? user.phone : ''}" required class="mp-input" placeholder="09xxxx-xxxx" pattern="[0-9]{10}" />
                        </div>
                    </div>

                    <div class="mp-form-group">
                        <label>Email liên hệ *</label>
                        <input type="email" name="email" value="${not empty user ? user.email : ''}" required class="mp-input" placeholder="example@email.com" />
                    </div>

                    <div class="mp-form-group">
                        <label>Loại phản hồi *</label>
                        <div class="feedback-options">
                            <label class="feedback-option">
                                <input type="radio" name="feedbackType" value="Lời khen" required>
                                <span class="feedback-label">Lời khen</span>
                            </label>
                            <label class="feedback-option">
                                <input type="radio" name="feedbackType" value="Lỗi">
                                <span class="feedback-label">Báo lỗi</span>
                            </label>
                            <label class="feedback-option">
                                <input type="radio" name="feedbackType" value="Góp ý">
                                <span class="feedback-label">Góp ý</span>
                            </label>
                            <label class="feedback-option">
                                <input type="radio" name="feedbackType" value="Khác" checked>
                                <span class="feedback-label">Khác</span>
                            </label>
                        </div>
                    </div>

                    <div class="mp-form-group">
                        <label>Lời nhắn của bạn *</label>
                        <textarea name="message" rows="5" required class="mp-input" style="resize: vertical;" placeholder="Mô tả chi tiết nội dung bạn muốn gửi..."></textarea>
                    </div>
                    
                    <div style="display: flex; justify-content: flex-end;">
                        <button type="submit" class="btn-send">
                            <i class="fas fa-paper-plane"></i> Gửi tin nhắn
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/views/footer.jsp" />
</body>

</html>
