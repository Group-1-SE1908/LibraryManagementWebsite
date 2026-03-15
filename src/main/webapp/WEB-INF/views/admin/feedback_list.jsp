<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý phản hồi - LBMS</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
    <style>
        body { display: flex; flex-direction: column; min-height: 100vh; background: #f8fafc; }
        main { flex: 1; }
        .container-page { max-width: 1200px; margin: 40px auto; padding: 0 20px; }
        .panel { background: white; padding: 28px; border-radius: 16px; box-shadow: 0 6px 24px rgba(0,0,0,0.05); }
        h2 { margin-bottom: 6px; font-size: 22px; }

        /* MAIN TABS */
        .tab-bar {
            display: flex; gap: 8px; margin: 20px 0 0;
            border-bottom: 2px solid #e5e7eb;
        }
        .tab-btn {
            padding: 9px 20px; border-radius: 8px 8px 0 0;
            border: 1.5px solid transparent; border-bottom: none;
            background: transparent; cursor: pointer;
            font-weight: 600; font-size: 13px; color: #6b7280;
            text-decoration: none; transition: 0.2s;
            position: relative; bottom: -2px;
        }
        .tab-btn:hover { color: #0b57d0; background: #f0f4ff; }
        .tab-btn.active { background: white; color: #0b57d0; border-color: #e5e7eb; border-bottom-color: white; }

        .badge {
            display: inline-block; background: #ef4444; color: white;
            border-radius: 99px; font-size: 11px; font-weight: 700;
            padding: 1px 7px; margin-left: 6px; vertical-align: middle;
        }

        .tab-content { display: none; padding-top: 24px; }
        .tab-content.active { display: block; }

        /* SUB FILTER (dùng cho tab reports) */
        .sub-filter-bar {
            display: flex; gap: 8px; margin-bottom: 20px;
        }
        .sub-filter-btn {
            padding: 6px 16px; border-radius: 20px;
            border: 1.5px solid #e5e7eb; background: white;
            cursor: pointer; font-weight: 600; font-size: 12px;
            color: #6b7280; text-decoration: none; transition: 0.2s;
        }
        .sub-filter-btn:hover { border-color: #0b57d0; color: #0b57d0; }
        .sub-filter-btn.active { background: #0b57d0; color: white; border-color: #0b57d0; }

        /* FEEDBACK ROWS */
        .filter-bar { display: flex; gap: 10px; margin-bottom: 20px; }
        .filter-btn {
            padding: 8px 18px; border-radius: 20px;
            border: 1.5px solid #e5e7eb; background: white;
            cursor: pointer; font-weight: 600; font-size: 13px;
            transition: 0.2s; text-decoration: none; color: #374151;
        }
        .filter-btn:hover { border-color: #0b57d0; color: #0b57d0; }
        .filter-btn.active { background: #0b57d0; color: white; border-color: #0b57d0; }

        .feedback-row {
            display: flex; justify-content: space-between; gap: 20px;
            padding: 18px 0; border-bottom: 1px solid #f1f5f9;
        }
        .feedback-row:last-child { border-bottom: none; }
        .feedback-content { flex: 1; }
        .feedback-title { font-weight: 600; font-size: 15px; }
        .feedback-meta { font-size: 12px; color: #9ca3af; margin-top: 6px; }
        .feedback-text { margin-top: 10px; color: #4b5563; line-height: 1.6; }
        .star { color: #fbbf24; font-size: 13px; letter-spacing: 2px; margin-top: 6px; }
        .feedback-actions { display: flex; gap: 10px; align-items: flex-start; }

        /* REPORT TABLE */
        .report-table { width: 100%; border-collapse: collapse; font-size: 14px; }
        .report-table th {
            text-align: left; padding: 10px 14px; background: #f8fafc;
            color: #6b7280; font-weight: 600; font-size: 12px;
            text-transform: uppercase; letter-spacing: 0.5px;
            border-bottom: 2px solid #e5e7eb;
        }
        .report-table td { padding: 14px; border-bottom: 1px solid #f1f5f9; vertical-align: top; }
        .report-table tr:last-child td { border-bottom: none; }
        .report-table tr:hover td { background: #fafbff; }

        .comment-box {
            background: #f8fafc; border-left: 3px solid #e5e7eb;
            padding: 8px 12px; border-radius: 4px;
            color: #374151; font-size: 13px; line-height: 1.5; max-width: 250px;
        }
        .comment-author { font-size: 12px; color: #9ca3af; margin-top: 4px; }
        .reporter-name { font-weight: 600; color: #111827; }

        .status-badge { display: inline-block; padding: 4px 12px; border-radius: 99px; font-size: 12px; font-weight: 600; }
        .status-PENDING  { background: #fef3c7; color: #d97706; }
        .status-RESOLVED { background: #d1fae5; color: #059669; }
        .status-IGNORED  { background: #f3f4f6; color: #6b7280; }

        .reason-tag {
            display: inline-block; background: #fef2f2; color: #dc2626;
            border: 1px solid #fecaca; border-radius: 6px;
            padding: 3px 10px; font-size: 12px; font-weight: 600;
        }
        .desc-text { font-size: 12px; color: #6b7280; margin-top: 4px; font-style: italic; }

        /* BUTTONS */
        .btn {
            background: #0b57d0; color: white; padding: 7px 13px;
            border-radius: 8px; text-decoration: none; font-size: 12px;
            font-weight: 600; transition: 0.2s; border: none;
            cursor: pointer; white-space: nowrap; display: inline-block;
        }
        .btn:hover { background: #0946a8; }
        .btn-danger { background: white; color: #ef4444; border: 1px solid #ef4444; }
        .btn-danger:hover { background: #ef4444; color: white; }
        .btn-muted { background: white; color: #6b7280; border: 1px solid #d1d5db; }
        .btn-muted:hover { background: #6b7280; color: white; }
        .btn-orange { background: white; color: #f97316; border: 1px solid #f97316; }
        .btn-orange:hover { background: #f97316; color: white; }

        .action-group { display: flex; gap: 6px; flex-wrap: wrap; align-items: center; }

        /* LOCK DROPDOWN */
        .lock-wrapper { position: relative; display: inline-block; }
        .lock-dropdown {
            display: none; position: absolute; top: calc(100% + 6px); left: 0;
            background: white; border: 1px solid #e5e7eb;
            border-radius: 10px; box-shadow: 0 8px 24px rgba(0,0,0,0.1);
            z-index: 100; min-width: 200px; padding: 8px 0;
        }
        .lock-wrapper:hover .lock-dropdown,
        .lock-wrapper.open .lock-dropdown { display: block; }
        .lock-option {
            display: block; padding: 9px 16px; font-size: 13px;
            color: #374151; cursor: pointer; transition: 0.15s;
            border: none; background: none; width: 100%; text-align: left;
        }
        .lock-option:hover { background: #f0f4ff; color: #0b57d0; }
        .lock-option-label {
            font-size: 11px; color: #9ca3af; padding: 6px 16px 2px;
            text-transform: uppercase; letter-spacing: 0.5px; font-weight: 600;
        }
        .lock-divider { border: none; border-top: 1px solid #f1f5f9; margin: 4px 0; }

        .empty-state { text-align: center; color: #9ca3af; padding: 50px 0; }
    </style>
</head>
<body>

<jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

<main>
    <div class="container-page">
        <div class="panel">

            <h2>Quản lý phản hồi sách</h2>
            <p style="color:#6b7280;">Quản lý bình luận và báo cáo từ độc giả.</p>

            <!-- MAIN TAB BAR -->
            <div class="tab-bar">
                <a href="#tab-feedback"
                   class="tab-btn ${empty activeTab || activeTab eq 'feedback' ? 'active' : ''}"
                   onclick="switchTab('feedback'); return false;">
                    Phản hồi cần trả lời
                </a>
                <a href="#tab-reports"
                   class="tab-btn ${activeTab eq 'reports' ? 'active' : ''}"
                   onclick="switchTab('reports'); return false;">
                    Bình luận bị báo cáo
                    <%-- Đếm số PENDING --%>
                    <c:set var="pendingCount" value="${0}"/>
                    <c:forEach var="r" items="${reports}">
                        <c:if test="${r.status eq 'PENDING'}">
                            <c:set var="pendingCount" value="${pendingCount + 1}"/>
                        </c:if>
                    </c:forEach>
                    <c:if test="${pendingCount > 0}">
                        <span class="badge">${pendingCount}</span>
                    </c:if>
                </a>
            </div>

            <!-- ===== TAB 1: PHẢN HỒI CẦN TRẢ LỜI ===== -->
            <div id="tab-feedback"
                 class="tab-content ${empty activeTab || activeTab eq 'feedback' ? 'active' : ''}">

                <div class="filter-bar">
                    <a href="${pageContext.request.contextPath}/admin/feedback?filter=all&tab=feedback"
                       class="filter-btn ${filter eq 'all' || empty filter ? 'active' : ''}">Tất cả</a>
                    <a href="${pageContext.request.contextPath}/admin/feedback?filter=unreplied&tab=feedback"
                       class="filter-btn ${filter eq 'unreplied' ? 'active' : ''}">Chưa phản hồi</a>
                    <a href="${pageContext.request.contextPath}/admin/feedback?filter=replied&tab=feedback"
                       class="filter-btn ${filter eq 'replied' ? 'active' : ''}">Đã phản hồi</a>
                </div>

                <c:choose>
                    <c:when test="${not empty comments}">
                        <c:forEach var="cmt" items="${comments}">
                            <div class="feedback-row">
                                <div class="feedback-content">
                                    <div class="feedback-title">#${cmt.commentId} — ${cmt.fullName}</div>
                                    <div class="star">
                                        <c:forEach begin="1" end="${cmt.rating}">★</c:forEach>
                                        <c:forEach begin="${cmt.rating + 1}" end="5"><span style="color:#e5e7eb;">★</span></c:forEach>
                                    </div>
                                    <div class="feedback-text">${cmt.content}</div>
                                    <div class="feedback-meta">
                                        Sách ID: ${cmt.bookId} •
                                        <fmt:formatDate value="${cmt.createdAt}" type="both" dateStyle="medium" timeStyle="short"/>
                                    </div>
                                </div>
                                <div class="feedback-actions">
                                    <a href="${pageContext.request.contextPath}/admin/feedback?action=view&id=${cmt.commentId}" class="btn">Xem & Trả lời</a>
                                    <form action="${pageContext.request.contextPath}/admin/feedback" method="post"
                                          onsubmit="return confirm('Xóa phản hồi này?');">
                                        <input type="hidden" name="action" value="delete"/>
                                        <input type="hidden" name="id" value="${cmt.commentId}"/>
                                        <button type="submit" class="btn btn-danger">Xóa</button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">Không có phản hồi nào.</div>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- ===== TAB 2: BÌNH LUẬN BỊ BÁO CÁO ===== -->
            <div id="tab-reports"
                 class="tab-content ${activeTab eq 'reports' ? 'active' : ''}">

                <!-- SUB FILTER: Chưa xử lý / Đã xử lý -->
                <div class="sub-filter-bar">
                    <a href="#" class="sub-filter-btn active" onclick="filterReports('pending'); return false;">
                        Chưa xử lý
                        <c:if test="${pendingCount > 0}">
                            <span class="badge" style="background:#f97316;">${pendingCount}</span>
                        </c:if>
                    </a>
                    <a href="#" class="sub-filter-btn" onclick="filterReports('done'); return false;">
                        Đã xử lý
                    </a>
                </div>

                <c:choose>
                    <c:when test="${not empty reports}">
                        <table class="report-table">
                            <thead>
                            <tr>
                                <th>ID</th>
                                <th>Người báo cáo</th>
                                <th>Bình luận bị báo cáo</th>
                                <th>Lý do</th>
                                <th>Thời gian</th>
                                <th>Trạng thái</th>
                                <th>Thao tác</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="report" items="${reports}">
                                <tr class="report-row"
                                    data-status="${report.status}">

                                    <td style="color:#9ca3af; font-size:13px;">#${report.reportId}</td>

                                    <td><div class="reporter-name">${report.reporterFullName}</div></td>

                                    <td>
                                        <div class="comment-box">${report.commentContent}</div>
                                        <div class="comment-author">Bởi: ${report.commentUserFullName}</div>
                                    </td>

                                    <td>
                                    <span class="reason-tag">
                                        <c:choose>
                                            <c:when test="${report.reason eq 'Harassment'}">Quấy rối</c:when>
                                            <c:when test="${report.reason eq 'Spam'}">Spam</c:when>
                                            <c:when test="${report.reason eq 'Hate Speech'}">Ngôn từ thù địch</c:when>
                                            <c:when test="${report.reason eq 'False Information'}">Thông tin sai lệch</c:when>
                                            <c:when test="${report.reason eq 'Inappropriate Content'}">Nội dung không phù hợp</c:when>
                                            <c:when test="${report.reason eq 'Violence'}">Bạo lực</c:when>
                                            <c:otherwise>${report.reason}</c:otherwise>
                                        </c:choose>
                                    </span>
                                        <c:if test="${not empty report.description}">
                                            <div class="desc-text">${report.description}</div>
                                        </c:if>
                                    </td>

                                    <td style="font-size:13px; color:#6b7280; white-space:nowrap;">
                                        <fmt:formatDate value="${report.reportTime}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>

                                    <td>
                                    <span class="status-badge status-${report.status}">
                                        <c:choose>
                                            <c:when test="${report.status eq 'PENDING'}">Chờ xử lý</c:when>
                                            <c:when test="${report.status eq 'RESOLVED'}">Đã xử lý</c:when>
                                            <c:when test="${report.status eq 'IGNORED'}">Bỏ qua</c:when>
                                            <c:otherwise>${report.status}</c:otherwise>
                                        </c:choose>
                                    </span>
                                    </td>

                                    <td>
                                        <c:choose>
                                            <c:when test="${report.status eq 'PENDING'}">
                                                <div class="action-group">

                                                    <!-- Xóa bình luận -->
                                                    <form action="${pageContext.request.contextPath}/admin/feedback"
                                                          method="post"
                                                          onsubmit="return confirm('Xóa bình luận này?');">
                                                        <input type="hidden" name="action" value="deleteComment"/>
                                                        <input type="hidden" name="reportId" value="${report.reportId}"/>
                                                        <button type="submit" class="btn btn-danger">Xóa BL</button>
                                                    </form>

                                                    <!-- Bỏ qua -->
                                                    <form action="${pageContext.request.contextPath}/admin/feedback"
                                                          method="post">
                                                        <input type="hidden" name="action" value="ignore"/>
                                                        <input type="hidden" name="reportId" value="${report.reportId}"/>
                                                        <button type="submit" class="btn btn-muted">Bỏ qua</button>
                                                    </form>

                                                    <!-- Khóa comment (dropdown) -->
                                                    <div class="lock-wrapper" id="lock-${report.reportId}">
                                                        <button type="button" class="btn btn-orange"
                                                                onclick="toggleLock('lock-${report.reportId}')">
                                                            🔒 Khóa comment
                                                        </button>
                                                        <div class="lock-dropdown">
                                                            <div class="lock-option-label">Thời gian khóa</div>

                                                            <form action="${pageContext.request.contextPath}/admin/feedback"
                                                                  method="post"
                                                                  onsubmit="return confirm('Khóa comment người dùng này 3 ngày và xóa toàn bộ comment cũ?');">
                                                                <input type="hidden" name="action" value="lockComment"/>
                                                                <input type="hidden" name="reportId" value="${report.reportId}"/>
                                                                <input type="hidden" name="lockDays" value="3"/>
                                                                <button type="submit" class="lock-option">🕒 3 ngày</button>
                                                            </form>

                                                            <form action="${pageContext.request.contextPath}/admin/feedback"
                                                                  method="post"
                                                                  onsubmit="return confirm('Khóa comment người dùng này 7 ngày và xóa toàn bộ comment cũ?');">
                                                                <input type="hidden" name="action" value="lockComment"/>
                                                                <input type="hidden" name="reportId" value="${report.reportId}"/>
                                                                <input type="hidden" name="lockDays" value="7"/>
                                                                <button type="submit" class="lock-option">🕒 7 ngày</button>
                                                            </form>

                                                            <hr class="lock-divider"/>

                                                            <form action="${pageContext.request.contextPath}/admin/feedback"
                                                                  method="post"
                                                                  onsubmit="return confirm('Khóa comment người dùng này 30 ngày và xóa toàn bộ comment cũ?');">
                                                                <input type="hidden" name="action" value="lockComment"/>
                                                                <input type="hidden" name="reportId" value="${report.reportId}"/>
                                                                <input type="hidden" name="lockDays" value="30"/>
                                                                <button type="submit" class="lock-option" style="color:#ef4444;">🔴 30 ngày</button>
                                                            </form>
                                                        </div>
                                                    </div>

                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <span style="color:#9ca3af; font-size:12px;">—</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">Không có báo cáo nào.</div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>
</main>

<jsp:include page="/WEB-INF/views/footer.jsp"/>

<script>
    // ── Main tab switch ──────────────────────────────────────────
    function switchTab(tabName) {
        document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
        document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
        document.getElementById('tab-' + tabName).classList.add('active');
        document.querySelector('[onclick="switchTab(\'' + tabName + '\'); return false;"]').classList.add('active');
        sessionStorage.setItem('activeTab', tabName);
    }

    // ── Sub filter (Chưa xử lý / Đã xử lý) ──────────────────────
    function filterReports(type) {
        const rows = document.querySelectorAll('.report-row');
        rows.forEach(row => {
            const status = row.dataset.status;
            if (type === 'pending') {
                row.style.display = (status === 'PENDING') ? '' : 'none';
            } else {
                row.style.display = (status === 'RESOLVED' || status === 'IGNORED') ? '' : 'none';
            }
        });

        // Update sub-filter button styles
        document.querySelectorAll('.sub-filter-btn').forEach(btn => btn.classList.remove('active'));
        event.target.closest('.sub-filter-btn').classList.add('active');

        sessionStorage.setItem('reportFilter', type);
    }

    // ── Lock dropdown toggle ──────────────────────────────────────
    function toggleLock(id) {
        const el = document.getElementById(id);
        el.classList.toggle('open');
    }

    // Close dropdown when clicking outside
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.lock-wrapper')) {
            document.querySelectorAll('.lock-wrapper').forEach(el => el.classList.remove('open'));
        }
    });

    // ── Restore state on load ─────────────────────────────────────
    window.addEventListener('DOMContentLoaded', function () {
        // Restore main tab
        const savedTab = sessionStorage.getItem('activeTab');
        if (savedTab) switchTab(savedTab);

        // Restore sub filter
        const savedFilter = sessionStorage.getItem('reportFilter') || 'pending';
        const subBtns = document.querySelectorAll('.sub-filter-btn');
        if (savedFilter === 'done' && subBtns[1]) {
            subBtns[0].classList.remove('active');
            subBtns[1].classList.add('active');
            filterReportsOnLoad('done');
        } else {
            filterReportsOnLoad('pending');
        }
    });

    function filterReportsOnLoad(type) {
        const rows = document.querySelectorAll('.report-row');
        rows.forEach(row => {
            const status = row.dataset.status;
            if (type === 'pending') {
                row.style.display = (status === 'PENDING') ? '' : 'none';
            } else {
                row.style.display = (status === 'RESOLVED' || status === 'IGNORED') ? '' : 'none';
            }
        });
    }
</script>

</body>
</html>
