<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

                <style>
                    .borrow-container {
                        display: flex;
                        gap: 22px;
                        align-items: flex-start;
                    }

                    /* BOOK IMAGE */

                    .borrow-book-image {
                        width: 150px;
                        flex-shrink: 0;
                    }

                    .borrow-book-image img {
                        width: 100%;
                        border-radius: 10px;
                        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
                    }

                    /* INFO */

                    .borrow-info {
                        flex: 1;
                    }

                    .borrow-title {
                        font-size: 20px;
                        font-weight: 700;
                        margin-bottom: 10px;
                        color: #1e293b;
                    }

                    .borrow-id {
                        font-size: 12px;
                        color: #94a3b8;
                        margin-bottom: 8px;
                    }

                    /* ROW */

                    .detail-row {
                        display: flex;
                        margin-bottom: 10px;
                        font-size: 14px;
                    }

                    .detail-label {
                        width: 130px;
                        font-weight: 600;
                        color: #64748b;
                    }

                    .detail-value {
                        color: #0f172a;
                        font-weight: 500;
                    }

                    /* STATUS BADGE */

                    .status {
                        padding: 5px 10px;
                        border-radius: 8px;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    .status-APPROVED {
                        background: #dbeafe;
                        color: #1d4ed8;
                    }

                    .status-BORROWED {
                        background: #e0f2fe;
                        color: #0369a1;
                    }

                    .status-RETURNED {
                        background: #dcfce7;
                        color: #166534;
                    }

                    .status-REJECTED {
                        background: #fee2e2;
                        color: #b91c1c;
                    }

                    /* FINE */

                    .fine {
                        font-weight: 700;
                        color: #ef4444;
                    }
                </style>

                <div>

                    <h3 style="margin-bottom:16px;">📋 Chi tiết phiếu mượn</h3>

                    <div class="borrow-container">

                        <!-- BOOK IMAGE -->

                        <div class="borrow-book-image">

                            <c:choose>
                                <c:when test="${not empty record.book.image}">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(record.book.image, 'http')}">
                                            <img src="${record.book.image}">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/${record.book.image}">
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>

                                <c:otherwise>
                                    <img src="https://via.placeholder.com/150x210?text=Book">
                                </c:otherwise>
                            </c:choose>

                        </div>

                        <!-- INFO -->

                        <div class="borrow-info">

                            <div class="borrow-id">Phiếu mượn #${record.id}</div>

                            <div class="borrow-title">
                                ${record.book.title}
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Người mượn</div>
                                <div class="detail-value">${record.user.fullName}</div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Email</div>
                                <div class="detail-value">${record.user.email}</div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Tác giả</div>
                                <div class="detail-value">${record.book.author}</div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">ISBN</div>
                                <div class="detail-value">${record.book.isbn}</div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Số lượng</div>
                                <div class="detail-value">${record.quantity} cuốn</div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Ngày mượn</div>
                                <div class="detail-value">

                                    ${record.formattedBorrowDate}
                                </div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Hạn trả</div>
                                <div class="detail-value">

                                    ${record.formattedDueDate}
                                </div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Ngày trả</div>
                                <div class="detail-value">

                                    ${record.formattedReturnDate}
                                </div>
                            </div>
                            <div class="detail-row">
                                <div class="detail-label">Trạng thái</div>
                                <div class="detail-value">
                                    <span class="status status-${record.status}">
                                        ${record.status}
                                    </span>
                                </div>
                            </div>

                            <div class="detail-row">
                                <div class="detail-label">Tiền phạt</div>
                                <div class="detail-value fine">

                                    <c:choose>
                                        <c:when test="${record.fineAmount > 0}">
                                            <fmt:formatNumber value="${record.fineAmount}" type="currency" />
                                        </c:when>
                                        <c:otherwise>
                                            0
                                        </c:otherwise>
                                    </c:choose>

                                </div>
                            </div>

                        </div>

                    </div>

                </div>