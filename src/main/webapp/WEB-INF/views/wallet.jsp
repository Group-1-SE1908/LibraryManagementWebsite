<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <title><fmt:message key="wallet.title"/> - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css"/>
</head>
<body>

<jsp:include page="/WEB-INF/views/header.jsp"/>

<main class="wallet-page">
    <section class="wallet-hero">
        <div class="hero-text">
            <p class="hero-kicker"><fmt:message key="wallet.balance.label"/></p>
            <h1><fmt:message key="wallet.hero.title"/></h1>
            <p class="hero-description"><fmt:message key="wallet.hero.subtitle"/></p>
            <div class="hero-tagline">
                <span><fmt:message key="wallet.hero.tagline"/></span>
                <span class="hero-badge">VNPay Sandbox</span>
            </div>
        </div>
        <div class="hero-balance-card">
            <p class="hero-balance-label"><fmt:message key="wallet.title"/></p>
            <div class="hero-balance-value">
                <fmt:formatNumber value="${walletBalance}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                <span>₫</span>
            </div>
            <a class="hero-topup-link" href="#topupForm"><fmt:message key="wallet.topup.button"/></a>
        </div>
    </section>

    <c:if test="${not empty flash}">
        <div class="wallet-flash ${flashType == 'error' ? 'wallet-flash--error' : 'wallet-flash--success'}">
            ${flash}
        </div>
    </c:if>

    <section class="wallet-grid">
        <article class="wallet-card wallet-card--topup" id="topupForm">
            <header>
                <h2><fmt:message key="wallet.topup.title"/></h2>
                <p><fmt:message key="wallet.topup.description"/></p>
            </header>
            <form method="post" action="${pageContext.request.contextPath}/wallet/top-up" novalidate>
                <label for="amount"><fmt:message key="wallet.topup.amount.label"/></label>
                <div class="wallet-input-group">
                    <input type="number" name="amount" id="amount" min="1000" step="1000" required placeholder="100000"/>
                    <span class="wallet-input-suffix">VND</span>
                </div>
                <div class="wallet-quick-amounts">
                    <p class="wallet-quick-label"><fmt:message key="wallet.quick.label"/></p>
                    <div class="wallet-quick-buttons">
                        <button type="button" data-quick-amount="50000">50k</button>
                        <button type="button" data-quick-amount="100000">100k</button>
                        <button type="button" data-quick-amount="200000">200k</button>
                        <button type="button" data-quick-amount="500000">500k</button>
                    </div>
                </div>
                <button type="submit" class="wallet-submit">
                    <fmt:message key="wallet.topup.button"/>
                </button>
                <p class="wallet-note"><fmt:message key="wallet.topup.note"/></p>
            </form>
        </article>

        <article class="wallet-card wallet-card--info">
            <h3><fmt:message key="wallet.info.title"/></h3>
            <p><fmt:message key="wallet.info.subtitle"/></p>
            <ul class="wallet-benefits">
                <li><fmt:message key="wallet.info.tip1"/></li>
                <li><fmt:message key="wallet.info.tip2"/></li>
                <li><fmt:message key="wallet.info.tip3"/></li>
            </ul>
            <div class="wallet-guideline">
                <p><fmt:message key="wallet.guideline.header"/></p>
                <ol>
                    <li><fmt:message key="wallet.guideline.step1"/></li>
                    <li><fmt:message key="wallet.guideline.step2"/></li>
                    <li><fmt:message key="wallet.guideline.step3"/></li>
                </ol>
            </div>
        </article>
    </section>

    <section class="wallet-history">
        <h3><fmt:message key="wallet.history.title"/></h3>
        <div class="wallet-history-empty">
            <p><fmt:message key="wallet.history.empty"/></p>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp"/>

<style>
    :root {
        --wallet-page-bg: #f8fafc;
        --wallet-card-bg: #ffffff;
        --wallet-border: #e2e8f0;
        --wallet-accent: #2563eb;
    }

    .wallet-page {
        min-height: calc(100vh - 140px);
        padding: 40px 20px 60px;
        background: var(--wallet-page-bg);
    }

    .wallet-hero {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
        margin-bottom: 24px;
    }

    .hero-text h1 {
        margin: 12px 0;
        font-size: 32px;
        color: #0f172a;
    }

    .hero-description {
        margin-bottom: 18px;
        color: #475569;
        line-height: 1.6;
    }

    .hero-tagline {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 14px;
        color: #475569;
    }

    .hero-badge {
        padding: 4px 10px;
        border-radius: 999px;
        background: rgba(37, 99, 235, 0.1);
        color: #1d4ed8;
        font-weight: 600;
        font-size: 12px;
    }

    .hero-kicker {
        margin: 0;
        letter-spacing: 0.4em;
        text-transform: uppercase;
        font-size: 12px;
        color: #94a3b8;
    }

    .hero-balance-card {
        padding: 28px;
        border-radius: 24px;
        background: linear-gradient(135deg, #1f2937, #312e81);
        color: #fff;
        box-shadow: 0 20px 50px rgba(15, 23, 42, 0.25);
    }

    .hero-balance-label {
        margin: 0 0 12px;
        font-size: 14px;
        color: rgba(255, 255, 255, 0.7);
    }

    .hero-balance-value {
        font-size: 36px;
        font-weight: 700;
        display: flex;
        align-items: baseline;
        gap: 6px;
    }

    .hero-topup-link {
        margin-top: 20px;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 8px 16px;
        border-radius: 999px;
        background: #fff;
        color: #1f2937;
        text-decoration: none;
        font-weight: 600;
        font-size: 13px;
        transition: transform 0.2s;
    }

    .hero-topup-link:hover {
        transform: translateY(-1px);
    }

    .wallet-flash {
        margin-bottom: 24px;
        padding: 12px 16px;
        border-radius: 14px;
        font-weight: 600;
    }

    .wallet-flash--success {
        background: #ecfdf5;
        color: #166534;
        border: 1px solid #a7f3d0;
    }

    .wallet-flash--error {
        background: #fef2f2;
        color: #991b1b;
        border: 1px solid #fecaca;
    }

    .wallet-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        gap: 20px;
        margin-bottom: 32px;
    }

    .wallet-card {
        background: var(--wallet-card-bg);
        border-radius: 24px;
        padding: 24px;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.08);
        border: 1px solid var(--wallet-border);
        display: flex;
        flex-direction: column;
        gap: 12px;
    }

    .wallet-card--info {
        background: #0f172a;
        color: #fff;
        border-color: transparent;
    }

    .wallet-card--info h3 {
        margin: 0;
    }

    .wallet-card--info p {
        margin: 0;
        color: rgba(255, 255, 255, 0.8);
        line-height: 1.6;
    }

    .wallet-benefits {
        list-style: none;
        padding: 0;
        margin: 0;
        display: flex;
        flex-direction: column;
        gap: 8px;
        color: rgba(255, 255, 255, 0.9);
    }

    .wallet-benefits li::before {
        content: '•';
        margin-right: 8px;
        color: #38bdf8;
    }

    .wallet-guideline {
        margin-top: 8px;
        padding: 12px;
        border-radius: 16px;
        background: rgba(255, 255, 255, 0.06);
    }

    .wallet-guideline p {
        margin: 0 0 6px;
        font-weight: 600;
        color: #fff;
    }

    .wallet-guideline ol {
        margin: 0;
        padding-left: 20px;
        color: rgba(255, 255, 255, 0.8);
        line-height: 1.6;
    }

    .wallet-input-group {
        display: flex;
        align-items: center;
        border-radius: 12px;
        border: 1px solid var(--wallet-border);
        overflow: hidden;
    }

    .wallet-input-group input {
        flex: 1;
        border: none;
        padding: 14px;
        font-size: 16px;
        outline: none;
        font-weight: 500;
    }

    .wallet-input-suffix {
        padding: 0 18px;
        background: #f1f5f9;
        font-size: 14px;
        color: #475569;
        font-weight: 500;
    }

    .wallet-quick-amounts {
        margin-top: 14px;
    }

    .wallet-quick-label {
        margin: 0 0 8px;
        font-size: 13px;
        color: #475569;
    }

    .wallet-quick-buttons {
        display: flex;
        flex-wrap: wrap;
        gap: 10px;
    }

    .wallet-quick-buttons button {
        border: 1px solid var(--wallet-border);
        background: #fff;
        color: #0f172a;
        padding: 6px 12px;
        border-radius: 999px;
        font-weight: 600;
        cursor: pointer;
        transition: border-color 0.2s, background 0.2s;
    }

    .wallet-quick-buttons button:hover {
        border-color: var(--wallet-accent);
        background: rgba(37, 99, 235, 0.08);
    }

    .wallet-submit {
        margin-top: 18px;
        padding: 12px 16px;
        border: none;
        border-radius: 14px;
        background: var(--wallet-accent);
        color: #fff;
        font-size: 15px;
        font-weight: 600;
        cursor: pointer;
        transition: background 0.2s;
    }

    .wallet-submit:hover {
        background: #1d4ed8;
    }

    .wallet-note {
        margin: 0;
        color: #475569;
        font-size: 13px;
    }

    .wallet-history h3 {
        margin-bottom: 12px;
        color: #0f172a;
    }

    .wallet-history-empty {
        border: 1px dashed var(--wallet-border);
        border-radius: 16px;
        padding: 24px;
        text-align: center;
        color: #475569;
        background: #fff;
        box-shadow: 0 10px 30px rgba(15, 23, 42, 0.05);
    }

    @media (max-width: 640px) {
        .wallet-hero {
            grid-template-columns: 1fr;
        }

        .hero-balance-card {
            text-align: left;
        }
    }
</style>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const input = document.getElementById('amount');
        document.querySelectorAll('[data-quick-amount]').forEach(button => {
            button.addEventListener('click', function () {
                if (!input) return;
                input.value = this.dataset.quickAmount;
                input.focus();
            });
        });
    });
</script>

</body>
</html>
