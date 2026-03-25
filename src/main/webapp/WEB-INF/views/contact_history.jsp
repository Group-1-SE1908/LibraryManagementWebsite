<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8">
                    <title>Lịch sử Liên hệ - LBMS</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/member-pages.css" />
                    <link rel="stylesheet"
                        href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
                    <link rel="stylesheet"
                        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />
                    <style>
                        .contact-card {
                            background: var(--mp-surface);
                            border-radius: var(--mp-radius);
                            padding: 24px;
                            margin-bottom: 20px;
                            border: 1px solid var(--mp-border);
                            box-shadow: var(--mp-shadow-sm);
                            transition: transform 0.2s ease, box-shadow 0.2s ease;
                        }

                        .contact-card:hover {
                            transform: translateY(-2px);
                            box-shadow: var(--mp-shadow-md);
                        }

                        .contact-header {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            margin-bottom: 16px;
                            padding-bottom: 16px;
                            border-bottom: 1px solid var(--mp-border);
                        }

                        .contact-type {
                            font-size: 1.1rem;
                            font-weight: 700;
                            color: var(--mp-text);
                            display: flex;
                            align-items: center;
                            gap: 8px;
                        }

                        .contact-id {
                            color: var(--mp-text-lighter);
                            font-size: 0.9rem;
                            font-weight: normal;
                        }

                        .contact-status {
                            padding: 6px 12px;
                            border-radius: 20px;
                            font-size: 0.8rem;
                            font-weight: 600;
                            display: inline-flex;
                            align-items: center;
                            gap: 6px;
                        }

                        .status-pending {
                            background: #fef3c7;
                            color: #92400e;
                        }

                        .status-resolved {
                            background: #d1fae5;
                            color: #065f46;
                        }

                        .status-cancelled {
                            background: #f3f4f6;
                            color: #4b5563;
                        }

                        .contact-message-container {
                            background: #f8fafc;
                            border-radius: var(--mp-radius, 8px);
                            padding: 16px;
                            margin-bottom: 20px;
                            border: 1px solid #e2e8f0;
                            text-align: left;
                        }

                        .contact-message-label {
                            font-size: 0.85rem;
                            font-weight: 700;
                            color: #64748b;
                            text-transform: uppercase;
                            letter-spacing: 0.5px;
                            margin-bottom: 8px;
                            border-bottom: 1px solid #e2e8f0;
                            padding-bottom: 8px;
                        }

                        .contact-message-content {
                            color: var(--mp-text);
                            font-size: 0.95rem;
                            line-height: 1.6;
                            white-space: pre-wrap;
                            word-break: break-word;
                            padding-top: 4px;
                        }

                        .contact-footer {
                            display: flex;
                            justify-content: space-between;
                            align-items: center;
                            font-size: 0.85rem;
                            color: var(--mp-text-lighter);
                        }

                        .contact-actions {
                            display: flex;
                            gap: 12px;
                        }

                        .btn-cancel {
                            background: #fff;
                            color: #ef4444;
                            border: 1px solid #fca5a5;
                            padding: 6px 16px;
                            border-radius: var(--mp-radius-sm);
                            font-weight: 600;
                            font-size: 0.85rem;
                            cursor: pointer;
                            transition: all 0.2s;
                        }

                        .btn-cancel:hover {
                            background: #fef2f2;
                            border-color: #ef4444;
                        }

                        .btn-edit {
                            background: #fff;
                            color: #3b82f6;
                            border: 1px solid #93c5fd;
                            padding: 6px 16px;
                            border-radius: var(--mp-radius-sm);
                            font-weight: 600;
                            font-size: 0.85rem;
                            cursor: pointer;
                            transition: all 0.2s;
                        }

                        .btn-edit:hover {
                            background: #eff6ff;
                            border-color: #3b82f6;
                        }

                        .filter-tabs {
                            display: flex;
                            gap: 10px;
                            margin-bottom: 32px;
                            border-bottom: 2px solid var(--mp-border);
                            padding-bottom: 2px;
                        }

                        .filter-tab {
                            padding: 10px 20px;
                            color: var(--mp-text-light);
                            text-decoration: none;
                            font-weight: 600;
                            font-size: 0.95rem;
                            position: relative;
                            transition: color 0.2s;
                        }

                        .filter-tab:hover {
                            color: var(--mp-primary);
                        }

                        .filter-tab.active {
                            color: var(--mp-primary);
                        }

                        .filter-tab.active::after {
                            content: '';
                            position: absolute;
                            bottom: -4px;
                            left: 0;
                            right: 0;
                            height: 3px;
                            background: var(--mp-primary);
                            border-radius: 3px 3px 0 0;
                        }

                        .empty-state {
                            text-align: center;
                            padding: 60px 20px;
                            background: #f8fafc;
                            border-radius: var(--mp-radius);
                            border: 1px dashed var(--mp-border);
                            color: var(--mp-text-light);
                        }

                        .empty-state i {
                            font-size: 3rem;
                            color: #cbd5e1;
                            margin-bottom: 16px;
                        }
                    </style>
                </head>

                <body class="member-page">

                    <jsp:include page="/WEB-INF/views/header.jsp" />

                    <section class="mp-hero">
                        <div class="mp-hero__bg">
                            <div class="mp-hero__shape mp-hero__shape--1"></div>
                            <div class="mp-hero__shape mp-hero__shape--2"></div>
                        </div>
                        <div class="mp-hero__container">
                            <div class="mp-hero__inner">
                                <div class="mp-hero__content">
                                    <div class="mp-hero__tag">
                                        <span>Lịch sử liên hệ</span>
                                    </div>
                                    <h1 class="mp-hero__title">Yêu cầu của bạn</h1>
                                    <p class="mp-hero__desc" style="max-width: 600px; margin: 0 auto;">
                                        Theo dõi trạng thái các câu hỏi, góp ý và phản hồi bạn đã gửi đến thư viện.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </section>

                    <main class="mp-content" style="padding-top: 40px;">
                        <c:if test="${not empty error}">
                            <div class="mp-flash mp-flash--error">
                                <i class="bi bi-x-circle-fill"></i>
                                <span>${error}</span>
                            </div>
                        </c:if>
                        <c:if test="${not empty sessionScope.toastMessage}">
                            <div class="mp-flash mp-flash--success">
                                <i class="bi bi-check-circle-fill"></i>
                                <span>${sessionScope.toastMessage}</span>
                            </div>
                            <c:remove var="toastMessage" scope="session" />
                        </c:if>

                        <div class="mp-toolbar">
                            <div class="mp-tabs">
                                <a href="${pageContext.request.contextPath}/contact-history?filter=all"
                                    style="text-decoration: none;"
                                    class="mp-tab ${currentFilter == 'all' ? 'active' : ''}">
                                    <i class="bi bi-list-ul"></i> Tất cả
                                </a>
                                <a href="${pageContext.request.contextPath}/contact-history?filter=pending"
                                    class="mp-tab ${currentFilter == 'pending' ? 'active' : ''}"
                                    style="text-decoration: none;">
                                    <i class="bi bi-hourglass-split"></i> Đang chờ
                                </a>
                                <a href="${pageContext.request.contextPath}/contact-history?filter=resolved"
                                    style="text-decoration: none;"
                                    class="mp-tab ${currentFilter == 'resolved' ? 'active' : ''}">
                                    <i class="bi bi-check-circle-fill"></i> Đã xử lý
                                </a>
                                <a href="${pageContext.request.contextPath}/contact-history?filter=cancelled"
                                    style="text-decoration: none;"
                                    class="mp-tab ${currentFilter == 'cancelled' ? 'active' : ''}">
                                    <i class="bi bi-x-circle-fill"></i> Đã đóng / Hủy
                                </a>
                            </div>
                            <div style="flex:1"></div>
                            <a href="${pageContext.request.contextPath}/contact" class="mp-btn-add">
                                <i class="bi bi-plus-lg"></i> Gửi yêu cầu mới
                            </a>
                        </div>

                        <c:choose>
                            <c:when test="${empty messages}">
                                <div class="mp-empty">
                                    <div class="mp-empty__icon">
                                        <i class="bi bi-inbox" style="font-size:2.5rem;color:#cbd5e1"></i>
                                    </div>
                                    <h2>Không có liên hệ nào</h2>
                                    <p>Bạn chưa gửi liên hệ nào hoặc không có dữ liệu phù hợp với bộ lọc này.</p>
                                    <a href="${pageContext.request.contextPath}/contact" class="btn primary">
                                        <i class="bi bi-envelope"></i> Gửi yêu cầu ngay
                                    </a>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="mp-table-wrap">
                                    <table class="mp-table">
                                        <thead>
                                            <tr>
                                                <th>#</th>
                                                <th>Loại yêu cầu</th>
                                                <th>Trạng thái</th>
                                                <th>Nội dung</th>
                                                <th>Ngày gửi</th>
                                                <th>Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="msg" items="${messages}" varStatus="loop">
                                                <tr>
                                                    <td class="td-num" data-label="STT">${loop.index + 1}</td>

                                                    <td data-label="Loại yêu cầu">
                                                        <div class="mp-cell-title">
                                                            <c:choose>
                                                                <c:when test="${msg.feedbackType == 'Lỗi'}"><i
                                                                        class="bi bi-bug-fill text-danger"></i> &nbsp;
                                                                </c:when>
                                                                <c:when test="${msg.feedbackType == 'Lời khen'}"><i
                                                                        class="bi bi-star-fill text-warning"></i> &nbsp;
                                                                </c:when>
                                                                <c:when test="${msg.feedbackType == 'Góp ý'}"><i
                                                                        class="bi bi-lightbulb-fill text-primary"></i>
                                                                    &nbsp;</c:when>
                                                                <c:otherwise><i
                                                                        class="bi bi-chat-left-text-fill text-secondary"></i>
                                                                    &nbsp;</c:otherwise>
                                                            </c:choose>
                                                            ${msg.feedbackType} <span
                                                                style="color:#64748b;font-size:0.85rem">#${msg.id}</span>
                                                        </div>
                                                    </td>

                                                    <td data-label="Trạng thái">
                                                        <c:choose>
                                                            <c:when test="${msg.status == 'PENDING'}">
                                                                <span class="mp-badge mp-badge--waiting">
                                                                    <span class="mp-badge__dot"></span>Đang chờ
                                                                </span>
                                                            </c:when>
                                                            <c:when
                                                                test="${msg.status == 'RESOLVED' || msg.status == 'IGNORED'}">
                                                                <span class="mp-badge mp-badge--available">
                                                                    <span class="mp-badge__dot"></span>Đã xử lý
                                                                </span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="mp-badge mp-badge--cancelled is-outline">
                                                                    <span class="mp-badge__dot"></span>Đã hủy
                                                                </span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>

                                                    <td data-label="Nội dung">
                                                        <div style="max-width:300px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;"
                                                            title="${fn:escapeXml(msg.message)}">
                                                            ${fn:escapeXml(msg.message)}
                                                        </div>
                                                    </td>

                                                    <td data-label="Ngày gửi">
                                                        <span class="mp-date">
                                                            ${msg.formattedCreatedAt}
                                                        </span>
                                                    </td>

                                                    <td data-label="Thao tác">
                                                        <div style="display:flex; gap:8px;">
                                                            <c:if test="${msg.status == 'PENDING'}">
                                                                <button type="button" class="mp-btn-sm"
                                                                    style="background:#fff;border:1px solid #cce5ff;color:#004085;padding:4px 12px;border-radius:4px;cursor:pointer;"
                                                                    data-id="${msg.id}" data-type="${msg.feedbackType}"
                                                                    data-message="${fn:escapeXml(msg.message)}"
                                                                    onclick="openEditModal(this)">
                                                                    <i class="bi bi-pencil-square"></i> Sửa
                                                                </button>
                                                                <form method="post"
                                                                    action="${pageContext.request.contextPath}/contact-history"
                                                                    onsubmit="return confirm('Bạn có chắc muốn hủy yêu cầu này?')"
                                                                    style="display:inline">
                                                                    <input type="hidden" name="action" value="cancel" />
                                                                    <input type="hidden" name="id" value="${msg.id}" />
                                                                    <input type="hidden" name="filter"
                                                                        value="${currentFilter}" />
                                                                    <button type="submit" class="mp-btn-cancel"
                                                                        style="padding:4px 12px;">
                                                                        <i class="bi bi-trash3"></i> Hủy
                                                                    </button>
                                                                </form>
                                                            </c:if>
                                                            <c:if test="${msg.status != 'PENDING'}">
                                                                <span
                                                                    style="font-size:0.8rem;color:var(--mp-text-muted)">—</span>
                                                            </c:if>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </main>

                    <jsp:include page="/WEB-INF/views/footer.jsp" />

                    <!-- Edit Modal -->
                    <div id="editModal" class="modal-overlay"
                        style="display: none; position: fixed; top: 0; left: 0; right: 0; bottom: 0; background: rgba(0,0,0,0.5); align-items: center; justify-content: center; z-index: 1000;">
                        <div class="modal-panel"
                            style="background: white; padding: 24px; border-radius: 8px; width: 100%; max-width: 500px; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);">
                            <h2 style="margin-top: 0; margin-bottom: 16px; font-size: 1.25rem;">Chỉnh sửa yêu cầu</h2>
                            <form action="${pageContext.request.contextPath}/contact-history" method="POST">
                                <input type="hidden" name="action" value="edit">
                                <input type="hidden" name="id" id="editId">
                                <input type="hidden" name="filter" value="${currentFilter}">
                                <div style="margin-bottom: 16px;">
                                    <label
                                        style="display: block; margin-bottom: 8px; font-weight: 600; font-size: 0.95rem;">Loại
                                        yêu cầu</label>
                                    <select name="feedbackType" id="editFeedbackType"
                                        style="width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 0.95rem;"
                                        required>
                                        <option value="Hỏi đáp">Hỏi đáp</option>
                                        <option value="Góp ý">Góp ý</option>
                                        <option value="Lỗi">Báo lỗi</option>
                                        <option value="Lời khen">Lời khen</option>
                                        <option value="Khác">Khác</option>
                                    </select>
                                </div>
                                <div style="margin-bottom: 20px;">
                                    <label
                                        style="display: block; margin-bottom: 8px; font-weight: 600; font-size: 0.95rem;">Nội
                                        dung</label>
                                    <textarea name="message" id="editMessage" rows="5"
                                        style="width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; font-family: inherit; font-size: 0.95rem; resize: vertical;"
                                        required></textarea>
                                </div>
                                <div style="display: flex; justify-content: flex-end; gap: 12px;">
                                    <button type="button"
                                        style="padding: 8px 16px; border: 1px solid #ccc; border-radius: 6px; background: #fff; cursor: pointer;"
                                        onclick="closeEditModal()">Hủy</button>
                                    <button type="submit" class="mp-btn"
                                        style="padding: 8px 20px; border: none; border-radius: 6px; background: var(--mp-primary, #3b82f6); color: white; cursor: pointer; font-weight: 600; font-size: 0.95rem;">Lưu
                                        thay đổi</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <script>
                        function openEditModal(btn) {
                            document.getElementById('editId').value = btn.getAttribute('data-id');
                            var type = btn.getAttribute('data-type');
                            if (type === 'Lỗi' || type === 'Báo lỗi') {
                                document.getElementById('editFeedbackType').value = 'Lỗi';
                            } else {
                                document.getElementById('editFeedbackType').value = type;
                            }
                            document.getElementById('editMessage').value = btn.getAttribute('data-message');
                            document.getElementById('editModal').style.display = 'flex';
                        }
                        function closeEditModal() {
                            document.getElementById('editModal').style.display = 'none';
                        }

                        // Close modal when clicking outside
                        document.getElementById('editModal').addEventListener('click', function (e) {
                            if (e.target === this) {
                                closeEditModal();
                            }
                        });
                    </script>
                </body>

                </html>