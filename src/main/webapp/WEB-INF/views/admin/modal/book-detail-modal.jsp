<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib uri="jakarta.tags.core" prefix="c" %>
        <%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
            <%@ taglib uri="jakarta.tags.functions" prefix="fn" %>

                <style>
                    :root {
                        --primary-color: #2563eb;
                        --text-main: #1e293b;
                        --text-muted: #64748b;
                        --bg-empty: #f8fafc;
                        --border-color: #e2e8f0;
                    }

                    .book-card {
                        background: #ffffff;
                        border-radius: 16px;
                        padding: 24px;
                        max-width: 550px;
                        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    }

                    .book-detail-container {
                        display: flex;
                        gap: 28px;
                        align-items: flex-start;
                    }


                    .book-image-wrapper {
                        width: 180px;
                        flex-shrink: 0;
                        perspective: 1000px;
                    }

                    .book-image {
                        width: 100%;
                        height: 240px;
                        border-radius: 12px;
                        object-fit: cover;
                        box-shadow: 0 10px 25px rgba(0, 0, 0, 0.1);
                        transition: transform 0.3s ease;
                        border: 1px solid var(--border-color);
                    }

                    .book-image:hover {
                        transform: translateY(-5px);
                    }


                    .image-placeholder {
                        width: 100%;
                        height: 240px;
                        background: var(--bg-empty);
                        border-radius: 12px;
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        border: 2px dashed var(--border-color);
                        color: var(--text-muted);
                    }

                    .image-placeholder i {
                        font-size: 40px;
                        margin-bottom: 8px;
                    }


                    .book-info {
                        flex: 1;
                    }

                    .book-id {
                        display: inline-block;
                        font-size: 11px;
                        text-transform: uppercase;
                        letter-spacing: 1px;
                        color: var(--text-muted);
                        background: #f1f5f9;
                        padding: 2px 8px;
                        border-radius: 4px;
                        margin-bottom: 12px;
                    }

                    .book-title {
                        font-size: 24px;
                        font-weight: 800;
                        line-height: 1.3;
                        margin-bottom: 16px;
                        color: var(--text-main);
                    }

                    .detail-grid {
                        display: grid;
                        gap: 12px;
                    }

                    .detail-row {
                        display: flex;
                        align-items: center;
                        border-bottom: 1px solid #f1f5f9;
                        padding-bottom: 8px;
                    }

                    .detail-label {
                        width: 90px;
                        font-size: 13px;
                        color: var(--text-muted);
                        font-weight: 500;
                    }

                    .detail-value {
                        font-size: 14px;
                        color: var(--text-main);
                        font-weight: 600;
                    }


                    .price-value {
                        font-size: 18px;
                        color: var(--primary-color);
                        font-weight: 700;
                    }


                    .badge-stock {
                        padding: 6px 12px;
                        border-radius: 20px;
                        font-size: 12px;
                        font-weight: 600;
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                    }

                    .stock-ok {
                        background: #ecfdf5;
                        color: #059669;
                    }

                    .stock-empty {
                        background: #fff1f2;
                        color: #e11d48;
                    }
                </style>

                <div class="book-card">
                    <h3 style="margin-top:0; margin-bottom:24px; display:flex; align-items:center; gap:10px;">
                        <span style="background: #e0e7ff; padding: 8px; border-radius: 10px;">📚</span>
                        Chi tiết sản phẩm
                    </h3>

                    <div class="book-detail-container">
                        <div class="book-image-wrapper">
                            <c:choose>
                                <c:when test="${not empty book.image}">
                                    <img src="${book.image.startsWith('http') ? book.image : pageContext.request.contextPath.concat('/').concat(book.image)}"
                                        class="book-image" alt="${book.title}">
                                </c:when>
                                <c:otherwise>
                                    <div class="image-placeholder">
                                        <span style="font-size: 40px;">📖</span>
                                        <span style="font-size: 12px; font-weight: 500;">Chưa có ảnh</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="book-info">
                            <div class="book-id">ID: #${book.id}</div>
                            <div class="book-title">${book.title}</div>

                            <div class="detail-grid">
                                <div class="detail-row">
                                    <div class="detail-label">Tác giả</div>
                                    <div class="detail-value">${book.author}</div>
                                </div>

                                <div class="detail-row">
                                    <div class="detail-label">Mã ISBN</div>
                                    <div class="detail-value">${book.isbn}</div>
                                </div>

                                <div class="detail-row">
                                    <div class="detail-label">Giá bán</div>
                                    <div class="detail-value price-value">
                                        <fmt:formatNumber value="${book.price}" type="currency" currencySymbol="₫" />
                                    </div>
                                </div>

                                <div class="detail-row" style="border-bottom: none;">
                                    <div class="detail-label">Trạng thái</div>
                                    <div class="detail-value">
                                        <c:choose>
                                            <c:when test="${book.quantity > 0}">
                                                <span class="badge-stock stock-ok">
                                                    ● Còn ${book.quantity} cuốn
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-stock stock-empty">
                                                    ✕ Hết hàng
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>