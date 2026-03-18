<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8" />
                <meta name="viewport" content="width=device-width, initial-scale=1.0" />
                <title>LBMS – Quản lý phản hồi</title>
                <link rel="stylesheet"
                    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"
                    rel="stylesheet" />
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/admin-panel.css" />
            </head>

            <body class="panel-body">

                <jsp:include page="/WEB-INF/views/admin/sidebar.jsp" />

                <main class="panel-main">

                    <div class="pm-page-header">
                        <div>
                            <h1 class="pm-title"><i class="fas fa-comment-dots"
                                    style="color:var(--panel-accent);margin-right:8px;"></i>Quản lý phản hồi sách</h1>
                            <p class="pm-subtitle">Quản lý bình luận và báo cáo từ độc giả.</p>
                        </div>
                    </div>

                    <div class="pm-card">
                        <%-- Tab bar --%>
                            <div class="pm-tab-bar">
                                <a href="#tab-feedback"
                                    class="pm-tab-btn ${empty activeTab || activeTab eq 'feedback' ? 'active' : ''}"
                                    onclick="switchTab('feedback'); return false;">
                                    <i class="fas fa-reply"></i> Phản hồi cần trả lời
                                </a>
                                <a href="#tab-reports" class="pm-tab-btn ${activeTab eq 'reports' ? 'active' : ''}"
                                    onclick="switchTab('reports'); return false;">
                                    <i class="fas fa-flag"></i> Bình luận bị báo cáo
                                    <c:set var="pendingCount" value="${0}" />
                                    <c:forEach var="r" items="${reports}">
                                        <c:if test="${r.status eq 'PENDING'}">
                                            <c:set var="pendingCount" value="${pendingCount + 1}" />
                                        </c:if>
                                    </c:forEach>
                                    <c:if test="${pendingCount > 0}">
                                        <span class="ps-badge">${pendingCount}</span>
                                    </c:if>
                                </a>
                            </div>

                            <%-- TAB 1: Phản hồi cần trả lời --%>
                                <div id="tab-feedback"
                                    class="pm-tab-content ${empty activeTab || activeTab eq 'feedback' ? 'active' : ''}">
                                    <div class="pm-filter-pills">
                                        <a href="${pageContext.request.contextPath}/admin/feedback?filter=all&tab=feedback"
                                            class="pm-filter-pill ${filter eq 'all' || empty filter ? 'active' : ''}">Tất
                                            cả</a>
                                        <a href="${pageContext.request.contextPath}/admin/feedback?filter=unreplied&tab=feedback"
                                            class="pm-filter-pill ${filter eq 'unreplied' ? 'active' : ''}">Chưa phản
                                            hồi</a>
                                        <a href="${pageContext.request.contextPath}/admin/feedback?filter=replied&tab=feedback"
                                            class="pm-filter-pill ${filter eq 'replied' ? 'active' : ''}">Đã phản
                                            hồi</a>
                                    </div>

                                    <c:choose>
                                        <c:when test="${not empty comments}">
                                            <c:forEach var="cmt" items="${comments}">
                                                <div class="pm-feedback-row">
                                                    <div class="pm-feedback-content">
                                                        <div class="pm-feedback-title">#${cmt.commentId} —
                                                            ${cmt.fullName}</div>
                                                        <div class="pm-feedback-stars">
                                                            <c:forEach begin="1" end="${cmt.rating}">★</c:forEach>
                                                            <c:forEach begin="${cmt.rating + 1}" end="5"><span
                                                                    style="color:#e5e7eb;">★</span></c:forEach>
                                                        </div>
                                                        <div class="pm-feedback-text">${cmt.content}</div>
                                                        <div class="pm-feedback-meta">
                                                            Sách ID: ${cmt.bookId} &bull;
                                                            <fmt:formatDate value="${cmt.createdAt}" type="both"
                                                                dateStyle="medium" timeStyle="short" />
                                                        </div>
                                                    </div>
                                                    <div class="pm-feedback-actions">
                                                        <a href="${pageContext.request.contextPath}/admin/feedback?action=view&id=${cmt.commentId}"
                                                            class="pm-btn pm-btn-primary pm-btn-sm">
                                                            <i class="fas fa-eye"></i> Xem &amp; Trả lời
                                                        </a>
                                                        <form action="${pageContext.request.contextPath}/admin/feedback"
                                                            method="post"
                                                            onsubmit="return confirm('Xóa phản hồi này?');">
                                                            <input type="hidden" name="action" value="delete" />
                                                            <input type="hidden" name="id" value="${cmt.commentId}" />
                                                            <button type="submit"
                                                                class="pm-btn pm-btn-danger pm-btn-sm">
                                                                <i class="fas fa-trash"></i> Xóa
                                                            </button>
                                                        </form>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="pm-empty"><i class="fas fa-inbox"></i>
                                                <p>Không có phản hồi nào.</p>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <%-- TAB 2: Bình luận bị báo cáo --%>
                                    <div id="tab-reports"
                                        class="pm-tab-content ${activeTab eq 'reports' ? 'active' : ''}">
                                        <div class="pm-sub-filter-bar">
                                            <button class="pm-sub-filter-btn active"
                                                onclick="filterReports('pending', this)">
                                                Chưa xử lý
                                                <c:if test="${pendingCount > 0}">
                                                    <span class="ps-badge"
                                                        style="background:var(--panel-warning);">${pendingCount}</span>
                                                </c:if>
                                            </button>
                                            <button class="pm-sub-filter-btn" onclick="filterReports('done', this)">Đã
                                                xử lý</button>
                                        </div>

                                        <c:choose>
                                            <c:when test="${not empty reports}">
                                                <div class="pm-table-wrap">
                                                    <table class="pm-table">
                                                        <thead>
                                                            <tr>
                                                                <th style="width:60px;">ID</th>
                                                                <th>Người báo cáo</th>
                                                                <th>Bình luận bị báo cáo</th>
                                                                <th>Lý do</th>
                                                                <th>Thời gian</th>
                                                                <th>Trạng thái</th>
                                                                <th style="text-align:right;">Thao tác</th>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                            <c:forEach var="report" items="${reports}">
                                                                <tr class="report-row" data-status="${report.status}">
                                                                    <td
                                                                        style="color:var(--panel-text-sub);font-size:.8rem;">
                                                                        #${report.reportId}</td>
                                                                    <td><strong>${report.reporterFullName}</strong></td>
                                                                    <td>
                                                                        <div class="pm-comment-box">
                                                                            ${report.commentContent}</div>
                                                                        <div class="pm-comment-author">Bởi:
                                                                            ${report.commentUserFullName}</div>
                                                                    </td>
                                                                    <td>
                                                                        <span class="pm-reason-tag">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${report.reason eq 'Harassment'}">
                                                                                    Quấy rối</c:when>
                                                                                <c:when
                                                                                    test="${report.reason eq 'Spam'}">
                                                                                    Spam</c:when>
                                                                                <c:when
                                                                                    test="${report.reason eq 'Hate Speech'}">
                                                                                    Ngôn từ thù địch</c:when>
                                                                                <c:when
                                                                                    test="${report.reason eq 'False Information'}">
                                                                                    Thông tin sai lệch</c:when>
                                                                                <c:when
                                                                                    test="${report.reason eq 'Inappropriate Content'}">
                                                                                    Nội dung không phù hợp</c:when>
                                                                                <c:when
                                                                                    test="${report.reason eq 'Violence'}">
                                                                                    Bạo lực</c:when>
                                                                                <c:otherwise>${report.reason}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </span>
                                                                        <c:if test="${not empty report.description}">
                                                                            <div
                                                                                style="font-size:.75rem;color:var(--panel-text-sub);margin-top:4px;font-style:italic;">
                                                                                ${report.description}</div>
                                                                        </c:if>
                                                                    </td>
                                                                    <td
                                                                        style="font-size:.8rem;color:var(--panel-text-sub);white-space:nowrap;">
                                                                        <fmt:formatDate value="${report.reportTime}"
                                                                            pattern="dd/MM/yyyy HH:mm" />
                                                                    </td>
                                                                    <td>
                                                                        <span
                                                                            class="pm-badge ${report.status eq 'PENDING' ? 'pm-badge-warning' : (report.status eq 'RESOLVED' ? 'pm-badge-success' : 'pm-badge-neutral')}">
                                                                            <c:choose>
                                                                                <c:when
                                                                                    test="${report.status eq 'PENDING'}">
                                                                                    Chờ xử lý</c:when>
                                                                                <c:when
                                                                                    test="${report.status eq 'RESOLVED'}">
                                                                                    Đã xử lý</c:when>
                                                                                <c:when
                                                                                    test="${report.status eq 'IGNORED'}">
                                                                                    Bỏ qua</c:when>
                                                                                <c:otherwise>${report.status}
                                                                                </c:otherwise>
                                                                            </c:choose>
                                                                        </span>
                                                                    </td>
                                                                    <td>
                                                                        <c:choose>
                                                                            <c:when
                                                                                test="${report.status eq 'PENDING'}">
                                                                                <div class="pm-actions"
                                                                                    style="justify-content:flex-end;flex-wrap:wrap;">
                                                                                    <form
                                                                                        action="${pageContext.request.contextPath}/admin/feedback"
                                                                                        method="post"
                                                                                        onsubmit="return confirm('Xóa bình luận này?');">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="deleteComment" />
                                                                                        <input type="hidden"
                                                                                            name="reportId"
                                                                                            value="${report.reportId}" />
                                                                                        <button type="submit"
                                                                                            class="pm-action-btn danger pm-btn-sm">
                                                                                            <i class="fas fa-trash"></i>
                                                                                            Xóa BL
                                                                                        </button>
                                                                                    </form>
                                                                                    <form
                                                                                        action="${pageContext.request.contextPath}/admin/feedback"
                                                                                        method="post">
                                                                                        <input type="hidden"
                                                                                            name="action"
                                                                                            value="ignore" />
                                                                                        <input type="hidden"
                                                                                            name="reportId"
                                                                                            value="${report.reportId}" />
                                                                                        <button type="submit"
                                                                                            class="pm-action-btn pm-btn-sm"
                                                                                            style="color:var(--panel-text-sub);">
                                                                                            <i class="fas fa-ban"></i>
                                                                                            Bỏ qua
                                                                                        </button>
                                                                                    </form>
                                                                                    <div class="pm-dropdown"
                                                                                        id="lock-${report.reportId}">
                                                                                        <button type="button"
                                                                                            class="pm-action-btn warning"
                                                                                            onclick="toggleDropdown('lock-${report.reportId}')">
                                                                                            <i class="fas fa-lock"></i>
                                                                                            Khóa
                                                                                        </button>
                                                                                        <div class="pm-dropdown-menu">
                                                                                            <div
                                                                                                class="pm-dropdown-label">
                                                                                                Thời gian khóa</div>
                                                                                            <form
                                                                                                action="${pageContext.request.contextPath}/admin/feedback"
                                                                                                method="post"
                                                                                                onsubmit="return confirm('Khóa comment người dùng 3 ngày?');">
                                                                                                <input type="hidden"
                                                                                                    name="action"
                                                                                                    value="lockComment" />
                                                                                                <input type="hidden"
                                                                                                    name="reportId"
                                                                                                    value="${report.reportId}" />
                                                                                                <input type="hidden"
                                                                                                    name="lockDays"
                                                                                                    value="3" />
                                                                                                <button type="submit"
                                                                                                    class="pm-dropdown-item">🕒
                                                                                                    3 ngày</button>
                                                                                            </form>
                                                                                            <form
                                                                                                action="${pageContext.request.contextPath}/admin/feedback"
                                                                                                method="post"
                                                                                                onsubmit="return confirm('Khóa comment người dùng 7 ngày?');">
                                                                                                <input type="hidden"
                                                                                                    name="action"
                                                                                                    value="lockComment" />
                                                                                                <input type="hidden"
                                                                                                    name="reportId"
                                                                                                    value="${report.reportId}" />
                                                                                                <input type="hidden"
                                                                                                    name="lockDays"
                                                                                                    value="7" />
                                                                                                <button type="submit"
                                                                                                    class="pm-dropdown-item">🕒
                                                                                                    7 ngày</button>
                                                                                            </form>
                                                                                            <hr
                                                                                                class="pm-dropdown-divider" />
                                                                                            <form
                                                                                                action="${pageContext.request.contextPath}/admin/feedback"
                                                                                                method="post"
                                                                                                onsubmit="return confirm('Khóa comment người dùng 30 ngày?');">
                                                                                                <input type="hidden"
                                                                                                    name="action"
                                                                                                    value="lockComment" />
                                                                                                <input type="hidden"
                                                                                                    name="reportId"
                                                                                                    value="${report.reportId}" />
                                                                                                <input type="hidden"
                                                                                                    name="lockDays"
                                                                                                    value="30" />
                                                                                                <button type="submit"
                                                                                                    class="pm-dropdown-item"
                                                                                                    style="color:var(--panel-danger);">🔴
                                                                                                    30 ngày</button>
                                                                                            </form>
                                                                                        </div>
                                                                                    </div>
                                                                                </div>
                                                                            </c:when>
                                                                            <c:otherwise>
                                                                                <span
                                                                                    style="color:var(--panel-text-sub);font-size:.8rem;">—</span>
                                                                            </c:otherwise>
                                                                        </c:choose>
                                                                    </td>
                                                                </tr>
                                                            </c:forEach>
                                                        </tbody>
                                                    </table>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="pm-empty"><i class="fas fa-flag"></i>
                                                    <p>Không có báo cáo nào.</p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                    </div>

                </main>

                <script>
                    function switchTab(tabName) {
                        document.querySelectorAll('.pm-tab-content').forEach(el => el.classList.remove('active'));
                        document.querySelectorAll('.pm-tab-btn').forEach(el => el.classList.remove('active'));
                        document.getElementById('tab-' + tabName).classList.add('active');
                        document.querySelector('[onclick="switchTab(\'' + tabName + '\'); return false;"]').classList.add('active');
                        sessionStorage.setItem('adminFeedbackTab', tabName);
                    }

                    function filterReports(type, btn) {
                        document.querySelectorAll('.report-row').forEach(row => {
                            const s = row.dataset.status;
                            row.style.display = (type === 'pending' ? s === 'PENDING' : (s === 'RESOLVED' || s === 'IGNORED')) ? '' : 'none';
                        });
                        document.querySelectorAll('.pm-sub-filter-btn').forEach(b => b.classList.remove('active'));
                        btn.classList.add('active');
                        sessionStorage.setItem('adminReportFilter', type);
                    }

                    function toggleDropdown(id) {
                        const el = document.getElementById(id);
                        el.classList.toggle('open');
                    }

                    document.addEventListener('click', e => {
                        if (!e.target.closest('.pm-dropdown')) {
                            document.querySelectorAll('.pm-dropdown').forEach(d => d.classList.remove('open'));
                        }
                    });

                    window.addEventListener('DOMContentLoaded', () => {
                        const savedTab = sessionStorage.getItem('adminFeedbackTab');
                        if (savedTab) switchTab(savedTab);

                        const savedFilter = sessionStorage.getItem('adminReportFilter') || 'pending';
                        const subBtns = document.querySelectorAll('.pm-sub-filter-btn');
                        if (savedFilter === 'done' && subBtns[1]) {
                            filterReports('done', subBtns[1]);
                            subBtns[0].classList.remove('active');
                        } else {
                            filterReports('pending', subBtns[0]);
                        }
                    });
                </script>
            </body>

            </html>