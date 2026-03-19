<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                    <title>
                        <fmt:message key="fines.hero.title" />
                    </title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
                </head>

                <body class="mp-body">
                    <jsp:include page="header.jsp" />

                    <main>
                        <c:set var="historyCount" value="${not empty historyRecords ? fn:length(historyRecords) : 0}" />
                        <section class="mp-hero">
                            <div class="mp-hero__inner">
                                <div>
                                    <p class="mp-hero__eyebrow">💳 Quản lý phí phạt</p>
                                    <h1 class="mp-hero__title">
                                        <fmt:message key="fines.hero.title" />
                                    </h1>
                                    <p class="mp-hero__subtitle">
                                        <fmt:message key="fines.hero.subtitle" />
                                    </p>
                                </div>
                                <div class="mp-hero__cards">
                                    <div class="mp-hero__card">
                                        <p class="mp-hero__card-label">
                                            <fmt:message key="fines.outstanding.title" />
                                        </p>
                                        <p class="mp-hero__card-value">
                                            <fmt:formatNumber value="${totalOutstanding}" pattern="#,##0" /> ₫
                                        </p>
                                        <p class="mp-hero__card-detail">
                                            <fmt:message key="fines.hero.stripe" />
                                        </p>
                                    </div>
                                    <div class="mp-hero__card">
                                        <p class="mp-hero__card-label">
                                            <fmt:message key="fines.history.title" />
                                        </p>
                                        <p class="mp-hero__card-value">${historyCount}</p>
                                        <p class="mp-hero__card-detail">
                                            <fmt:message key="fines.hero.history_detail" />
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </section>

                        <section class="mp-content">
                            <c:if test="${not empty flash}">
                                <div class="mp-flash">${flash}</div>
                            </c:if>

                            <div class="mp-panels">
                                <article class="mp-panel">
                                    <div class="mp-panel__header">
                                        <h2>
                                            <fmt:message key="fines.outstanding.title" />
                                        </h2>
                                        <span class="mp-panel__badge">
                                            <fmt:message key="fines.outstanding.subtitle" />
                                        </span>
                                    </div>

                                    <div class="mp-panel__body">
                                        <c:choose>
                                            <c:when test="${not empty unpaidRecords}">
                                                <c:forEach items="${unpaidRecords}" var="record">
                                                    <article class="mp-fine">
                                                        <div class="mp-fine__top">
                                                            <div>
                                                                <p class="eyebrow">Phiếu #${record.id}</p>
                                                                <h3>${record.book.title}</h3>
                                                                <p class="mp-fine__author">${record.book.author}</p>
                                                            </div>
                                                            <span class="mp-fine__status">
                                                                <fmt:message key="fines.label.pending" />
                                                            </span>
                                                        </div>
                                                        <div class="mp-fine__grid">
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.overdue" />
                                                                </small>
                                                                <strong>${record.overdueDays} ngày</strong>
                                                            </div>
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.amount" />
                                                                </small>
                                                                <strong>
                                                                    <fmt:formatNumber value="${record.fineAmount}"
                                                                        pattern="#,##0" /> ₫
                                                                </strong>
                                                            </div>
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.due_date" />
                                                                </small>
                                                                <strong>
                                                                    <c:out value="${record.dueDate}" />
                                                                </strong>
                                                            </div>
                                                            <div>
                                                                <small>
                                                                    <fmt:message key="fines.field.return_date" />
                                                                </small>
                                                                <strong>
                                                                    <c:out value="${record.returnDate}" />
                                                                </strong>
                                                            </div>
                                                        </div>
                                                        <div class="mp-fine__actions">
                                                            <a href="${pageContext.request.contextPath}/checkout?borrowId=${record.id}&mode=fine"
                                                                class="btn">
                                                                <fmt:message key="fines.action.pay" />
                                                            </a>
                                                        </div>
                                                    </article>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="mp-empty mp-empty--dashed">
                                                    <strong>
                                                        <fmt:message key="fines.empty" />
                                                    </strong>
                                                    <p>
                                                        <fmt:message key="fines.empty_hint" />
                                                    </p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </article>

                                <article class="mp-panel">
                                    <div class="mp-panel__header">
                                        <h2>
                                            <fmt:message key="fines.history.title" />
                                        </h2>
                                        <span class="mp-panel__badge">
                                            <fmt:message key="fines.history.subtitle" />
                                        </span>
                                    </div>
                                    <div class="table-wrapper">
                                        <table class="mp-htable">
                                            <thead>
                                                <tr>
                                                    <th>Phiếu</th>
                                                    <th>
                                                        <fmt:message key="fines.field.book" />
                                                    </th>
                                                    <th>
                                                        <fmt:message key="fines.field.amount" />
                                                    </th>
                                                    <th>
                                                        <fmt:message key="fines.field.status" />
                                                    </th>
                                                    <th>
                                                        <fmt:message key="fines.field.overdue" />
                                                    </th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach items="${historyRecords}" var="record">
                                                    <tr>
                                                        <td>#${record.id}</td>
                                                        <td>${record.book.title}</td>
                                                        <td>
                                                            <fmt:formatNumber value="${record.fineAmount}"
                                                                pattern="#,##0" /> ₫
                                                        </td>
                                                        <td>
                                                            <span
                                                                class="mp-badge ${record.paid ? 'mp-badge--paid' : 'mp-badge--pending'}">
                                                                <fmt:message
                                                                    key="${record.paid ? 'fines.label.paid' : 'fines.label.pending'}" />
                                                            </span>
                                                        </td>
                                                        <td>${record.overdueDays} ngày</td>
                                                    </tr>
                                                </c:forEach>
                                                <c:if test="${empty historyRecords}">
                                                    <tr>
                                                        <td colspan="5" style="text-align:center; color:#6b7280;">
                                                            <fmt:message key="fines.history.empty" />
                                                        </td>
                                                    </tr>
                                                </c:if>
                                            </tbody>
                                        </table>
                                    </div>
                                </article>
                            </div>
                        </section>
                    </main>

                    <jsp:include page="footer.jsp" />
                </body>

                </html>