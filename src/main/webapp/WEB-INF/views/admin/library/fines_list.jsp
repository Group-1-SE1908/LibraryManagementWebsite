<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>

            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Tiền phạt | LBMS</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css">
                <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
                <style>
                    .admin-main-content {
                        margin-left: 280px;
                        min-height: 100vh;
                        padding: 24px 32px;
                        box-sizing: border-box;
                        background: #f4f7fb;
                    }

                    .page-shell {
                        display: flex;
                        flex-direction: column;
                        gap: 24px;
                    }

                    .page-hero {
                        background: linear-gradient(135deg, #0f172a 0%, #1d4ed8 55%, #38bdf8 100%);
                        color: white;
                        border-radius: 24px;
                        padding: 28px 32px;
                        box-shadow: 0 24px 48px rgba(15, 23, 42, 0.18);
                    }

                    .page-hero h1 {
                        margin: 0 0 8px;
                        font-size: 30px;
                        font-weight: 800;
                    }

                    .page-hero p {
                        margin: 0;
                        max-width: 720px;
                        color: rgba(255, 255, 255, 0.86);
                        line-height: 1.6;
                    }

                    .summary-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                        gap: 18px;
                    }

                    .summary-card {
                        background: white;
                        border-radius: 18px;
                        padding: 20px 22px;
                        border: 1px solid #dbe3f0;
                        box-shadow: 0 10px 28px rgba(15, 23, 42, 0.06);
                    }

                    .summary-card .label {
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        color: #64748b;
                        font-weight: 700;
                    }

                    .summary-card .value {
                        margin-top: 10px;
                        font-size: 28px;
                        font-weight: 800;
                        color: #0f172a;
                    }

                    .summary-card .hint {
                        margin-top: 6px;
                        font-size: 13px;
                        color: #64748b;
                    }

                    .toolbar {
                        background: white;
                        border-radius: 18px;
                        padding: 18px 20px;
                        border: 1px solid #dbe3f0;
                        box-shadow: 0 10px 28px rgba(15, 23, 42, 0.05);
                        display: flex;
                        gap: 14px;
                        align-items: end;
                        flex-wrap: wrap;
                    }

                    .field-group {
                        display: flex;
                        flex-direction: column;
                        gap: 6px;
                        min-width: 220px;
                    }

                    .field-group label {
                        font-size: 12px;
                        font-weight: 700;
                        color: #64748b;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                    }

                    .field-group input,
                    .field-group select {
                        border: 1px solid #cbd5e1;
                        border-radius: 12px;
                        padding: 11px 14px;
                        font-size: 14px;
                        outline: none;
                    }

                    .field-group input:focus,
                    .field-group select:focus {
                        border-color: #2563eb;
                        box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
                    }

                    .btn-action {
                        border: none;
                        border-radius: 12px;
                        padding: 12px 18px;
                        font-weight: 700;
                        font-size: 14px;
                        cursor: pointer;
                        text-decoration: none;
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                    }

                    .btn-primary {
                        background: #2563eb;
                        color: white;
                    }

                    .btn-secondary {
                        background: #e2e8f0;
                        color: #0f172a;
                    }

                    .btn-success {
                        background: #16a34a;
                        color: white;
                        width: 100%;
                    }

                    .data-panel {
                        background: white;
                        border-radius: 20px;
                        border: 1px solid #dbe3f0;
                        box-shadow: 0 16px 36px rgba(15, 23, 42, 0.06);
                        overflow: hidden;
                    }

                    .panel-header {
                        padding: 22px 24px 16px;
                        border-bottom: 1px solid #e2e8f0;
                    }

                    .panel-header h2 {
                        margin: 0 0 6px;
                        font-size: 22px;
                        color: #0f172a;
                    }

                    .panel-header p {
                        margin: 0;
                        color: #64748b;
                        font-size: 14px;
                    }

                    .table-wrap {
                        overflow-x: auto;
                    }

                    table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    th,
                    td {
                        padding: 16px 18px;
                        text-align: left;
                        vertical-align: top;
                        border-top: 1px solid #eef2f7;
                    }

                    th {
                        font-size: 12px;
                        text-transform: uppercase;
                        letter-spacing: 0.08em;
                        color: #64748b;
                        font-weight: 800;
                        background: #f8fafc;
                        white-space: nowrap;
                    }

                    td {
                        font-size: 14px;
                        color: #0f172a;
                    }

                    .record-title {
                        font-weight: 700;
                        color: #0f172a;
                        margin-bottom: 4px;
                    }

                    .subtext {
                        color: #64748b;
                        font-size: 13px;
                    }

                    .pill {
                        display: inline-flex;
                        align-items: center;
                        justify-content: center;
                        padding: 6px 12px;
                        border-radius: 999px;
                        font-size: 12px;
                        font-weight: 800;
                        white-space: nowrap;
                    }

                    .pill-paid {
                        background: rgba(22, 163, 74, 0.14);
                        color: #166534;
                    }

                    .pill-unpaid {
                        background: rgba(234, 88, 12, 0.14);
                        color: #c2410c;
                    }

                    .pill-overdue {
                        background: rgba(220, 38, 38, 0.12);
                        color: #b91c1c;
                    }

                    .pill-returned {
                        background: rgba(37, 99, 235, 0.12);
                        color: #1d4ed8;
                    }

                    .empty-state {
                        padding: 40px 24px;
                        text-align: center;
                        color: #64748b;
                    }

                    .empty-state strong {
                        display: block;
                        color: #0f172a;
                        font-size: 18px;
                        margin-bottom: 8px;
                    }

                    .muted-note {
                        color: #64748b;
                        font-size: 13px;
                        line-height: 1.5;
                    }

                    @media (max-width: 1024px) {
                        .admin-main-content {
                            margin-left: 0;
                            padding: 16px;
                        }
                    }
                </style>
            </head>

            <body>
                <jsp:include page="/WEB-INF/views/admin/library/librarian_sidebar.jsp" />

                <main class="admin-main-content">
                    <div class="page-shell">
                        <section class="page-hero">
                            <h1>💸 Quản lý Tiền phạt</h1>
                            <p>Theo dõi các phiếu quá hạn, các khoản phạt chưa thu và những khoản đã tự cập nhật sau
                                thanh toán online. Nếu độc giả trả trực tiếp tại quầy, dùng nút xác nhận để chốt trạng
                                thái đã thanh toán.</p>
                        </section>

                        <section class="summary-grid">
                            <article class="summary-card">
                                <div class="label">Đơn quá hạn chưa trả sách</div>
                                <div class="value">${overdueActiveCount}</div>
                                <div class="hint">Cần theo dõi và nhắc độc giả hoàn trả.</div>
                            </article>
                            <article class="summary-card">
                                <div class="label">Khoản phạt chưa thanh toán</div>
                                <div class="value">${unpaidCount}</div>
                                <div class="hint">
                                    <fmt:formatNumber value="${pendingTotal}" pattern="#,##0" /> đ đang chờ thu.
                                </div>
                            </article>
                            <article class="summary-card">
                                <div class="label">Khoản phạt đã thanh toán</div>
                                <div class="value">${paidCount}</div>
                                <div class="hint">
                                    <fmt:formatNumber value="${paidTotal}" pattern="#,##0" /> đ đã ghi nhận.
                                </div>
                            </article>
                        </section>

                        <form action="${pageContext.request.contextPath}${finesBasePath}" method="get" class="toolbar">
                            <div class="field-group">
                                <label for="q">Tìm kiếm</label>
                                <input id="q" type="text" name="q" value="${param.q}"
                                    placeholder="Tên độc giả, tên sách, mã phiếu...">
                            </div>
                            <div class="field-group">
                                <label for="paymentStatus">Trạng thái thanh toán</label>
                                <select id="paymentStatus" name="paymentStatus">
                                    <option value="">Tất cả</option>
                                    <option value="UNPAID" ${param.paymentStatus=='UNPAID' ? 'selected' : '' }>Chưa trả
                                        tiền phạt</option>
                                    <option value="PAID" ${param.paymentStatus=='PAID' ? 'selected' : '' }>Đã trả tiền
                                        phạt</option>
                                </select>
                            </div>
                            <button type="submit" class="btn-action btn-primary">Lọc danh sách</button>
                            <a href="${pageContext.request.contextPath}${finesBasePath}"
                                class="btn-action btn-secondary">Xóa lọc</a>
                        </form>

                        <section class="data-panel">
                            <div class="panel-header">
                                <h2>Danh sách phiếu có liên quan đến tiền phạt</h2>
                                <p>Các khoản thanh toán online sẽ tự động chuyển sang trạng thái đã thanh toán ngay khi
                                    VNPay trả kết quả thành công.</p>
                            </div>

                            <c:if test="${not empty flash}">
                                <script>
                                    const flashMessage = '<c:out value="${flash}"/>';
                                    const isSuccess = flashMessage.includes('Đã xác nhận') || flashMessage.includes('thành công');
                                    Swal.fire({
                                        icon: isSuccess ? 'success' : 'info',
                                        title: isSuccess ? 'Cập nhật thành công' : 'Thông báo',
                                        text: flashMessage,
                                        confirmButtonColor: '#2563eb'
                                    });
                                </script>
                            </c:if>

                            <c:choose>
                                <c:when test="${not empty fineRecords}">
                                    <div class="table-wrap">
                                        <table>
                                            <thead>
                                                <tr>
                                                    <th>Phiếu</th>
                                                    <th>Độc giả</th>
                                                    <th>Sách</th>
                                                    <th>Tình trạng</th>
                                                    <th>Quá hạn</th>
                                                    <th>Tiền phạt</th>
                                                    <th>Thanh toán</th>
                                                    <th>Thao tác</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="record" items="${fineRecords}">
                                                    <tr>
                                                        <td>
                                                            <div class="record-title">#${record.id}</div>
                                                            <div class="subtext">${record.borrowMethod}</div>
                                                        </td>
                                                        <td>
                                                            <div class="record-title">${record.user.fullName}</div>
                                                            <div class="subtext">${record.user.email}</div>
                                                        </td>
                                                        <td>
                                                            <div class="record-title">${record.book.title}</div>
                                                            <div class="subtext">Hạn trả: ${record.formattedDueDate}
                                                            </div>
                                                            <c:if test="${not empty record.returnDate}">
                                                                <div class="subtext">Ngày trả: ${record.returnDate}
                                                                </div>
                                                            </c:if>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${record.currentlyOverdue}">
                                                                    <span class="pill pill-overdue">Đang quá hạn</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span
                                                                        class="pill pill-returned">${record.status}</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <div class="record-title">${record.overdueDays} ngày</div>
                                                            <div class="subtext">
                                                                <c:choose>
                                                                    <c:when test="${empty record.returnDate}">Chưa trả
                                                                        sách</c:when>
                                                                    <c:otherwise>Đã trả sách</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <div class="record-title">
                                                                <fmt:formatNumber
                                                                    value="${record.outstandingFineAmount}"
                                                                    pattern="#,##0" /> đ
                                                            </div>
                                                            <div class="subtext">
                                                                <c:choose>
                                                                    <c:when
                                                                        test="${not empty record.fineAmount and record.fineAmount gt 0}">
                                                                        Đã chốt tiền phạt</c:when>
                                                                    <c:otherwise>Tạm tính theo ngày quá hạn
                                                                    </c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${record.paid}">
                                                                    <span class="pill pill-paid">Đã trả tiền phạt</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="pill pill-unpaid">Chưa trả tiền
                                                                        phạt</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${record.paid}">
                                                                    <div class="muted-note">Đã được xác nhận hoặc thanh
                                                                        toán online.</div>
                                                                </c:when>
                                                                <c:when test="${empty record.returnDate}">
                                                                    <div class="muted-note">Cần nhận sách trả trước khi
                                                                        thu tiền phạt.</div>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <form method="post"
                                                                        action="${pageContext.request.contextPath}${finesBasePath}/confirm-paid">
                                                                        <input type="hidden" name="id"
                                                                            value="${record.id}">
                                                                        <button type="submit"
                                                                            class="btn-action btn-success">Xác nhận đã
                                                                            trả tại quầy</button>
                                                                    </form>
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
                                    <div class="empty-state">
                                        <strong>Chưa có phiếu nào phù hợp bộ lọc hiện tại.</strong>
                                        Danh sách này sẽ hiển thị các đơn quá hạn, các khoản phạt chưa thu và các khoản
                                        đã thanh toán để thủ thư theo dõi tập trung.
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </section>
                    </div>
                </main>
            </body>

            </html>