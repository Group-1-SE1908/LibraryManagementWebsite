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
        <div class="wallet-hero__text">
            <p class="wallet-hero__kicker"><fmt:message key="wallet.balance.label"/></p>
            <h1><fmt:message key="wallet.hero.title"/></h1>
            <p class="wallet-hero__description"><fmt:message key="wallet.hero.subtitle"/></p>
            <div class="wallet-hero__tagline">
                <span><fmt:message key="wallet.hero.tagline"/></span>
                <span class="wallet-hero__badge">VNPay Sandbox</span>
            </div>
        </div>
        <div class="wallet-hero__balance-card">
            <p class="wallet-hero__balance-label"><fmt:message key="wallet.title"/></p>
            <div class="wallet-hero__balance-value">
                <fmt:formatNumber value="${walletBalance}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                <span>&#8363;</span>
            </div>
            <a class="wallet-hero__topup-link" href="#topupForm"><fmt:message key="wallet.topup.button"/></a>
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
        <c:choose>
            <c:when test="${not empty walletHistory}">
                <ul class="wallet-history-list">
                    <c:forEach var="entry" items="${walletHistory}">
                        <li class="wallet-history-entry">
                            <div class="wallet-history-entry__header">
                                <div>
                                    <div class="wallet-history-entry__title">
                                        <c:choose>
                                            <c:when test="${entry.type == 'TOPUP'}">
                                                <fmt:message key="wallet.history.entry.topup">
                                                    <fmt:param value="${entry.source}"/>
                                                </fmt:message>
                                            </c:when>
                                            <c:otherwise>
                                                <fmt:message key="wallet.history.entry.other"/>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <c:if test="${not empty entry.description}">
                                        <p class="wallet-history-entry__context">${entry.description}</p>
                                    </c:if>
                                </div>
                                <span class="wallet-history-entry__amount ${entry.credit ? 'wallet-history-entry__amount--credit' : 'wallet-history-entry__amount--debit'}">
                                    <fmt:formatNumber value="${entry.amount}" type="number" groupingUsed="true" maxFractionDigits="0"/>
                                    <span class="wallet-history-entry__currency">₫</span>
                                </span>
                            </div>
                            <div class="wallet-history-entry__meta">
                                <span class="wallet-history-entry__date">
                                    <fmt:formatDate value="${entry.createdAt}" pattern="dd MMM yyyy, HH:mm"/>
                                </span>
                                <c:if test="${not empty entry.reference}">
                                    <span class="wallet-history-entry__reference">
                                        <fmt:message key="wallet.history.entry.reference">
                                            <fmt:param value="${entry.reference}"/>
                                        </fmt:message>
                                    </span>
                                </c:if>
                            </div>
                        </li>
                    </c:forEach>
                </ul>
            </c:when>
            <c:otherwise>
                <div class="wallet-history-empty">
                    <p><fmt:message key="wallet.history.empty"/></p>
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp"/>

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
