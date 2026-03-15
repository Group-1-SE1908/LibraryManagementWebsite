<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <!DOCTYPE html>
        <html lang="vi">

        <head>
            <meta charset="UTF-8">
            <title>Nhập kho sách | LBMS Staff</title>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
            <style>
                :root {
                    --admin-primary: #1e293b;
                    --admin-accent: #0b57d0;
                }

                body {
                    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                    margin: 0;
                    display: flex;
                    background-color: #f8fafc;
                }

                .main-content {
                    margin-left: 280px;
                    /* Khớp với chiều rộng sidebar của bạn */
                    padding: 40px;
                    width: calc(100% - 280px);
                }

                .card {
                    background: white;
                    padding: 30px;
                    border-radius: 12px;
                    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
                    max-width: 600px;
                    margin: 0 auto;
                }

                .header-area {
                    display: flex;
                    align-items: center;
                    gap: 15px;
                    margin-bottom: 30px;
                    border-bottom: 1px solid #e2e8f0;
                    padding-bottom: 15px;
                }

                .header-area h2 {
                    margin: 0;
                    color: var(--admin-primary);
                }

                .book-info {
                    background: #f1f5f9;
                    padding: 15px;
                    border-radius: 8px;
                    margin-bottom: 25px;
                }

                .info-row {
                    display: flex;
                    margin-bottom: 8px;
                }

                .info-label {
                    width: 120px;
                    font-weight: 600;
                    color: #64748b;
                }

                .form-group {
                    margin-bottom: 20px;
                }

                label {
                    display: block;
                    margin-bottom: 8px;
                    font-weight: 600;
                    color: var(--admin-primary);
                }

                input[type="number"] {
                    width: 100%;
                    padding: 12px;
                    border: 1px solid #cbd5e1;
                    border-radius: 6px;
                    font-size: 16px;
                    box-sizing: border-box;
                }

                .btn-group {
                    display: flex;
                    gap: 10px;
                    margin-top: 30px;
                }

                .btn {
                    padding: 12px 24px;
                    border-radius: 6px;
                    border: none;
                    cursor: pointer;
                    font-weight: 600;
                    text-decoration: none;
                    display: inline-flex;
                    align-items: center;
                    gap: 8px;
                    transition: 0.2s;
                }

                .btn-submit {
                    background: var(--admin-accent);
                    color: white;
                }

                .btn-submit:hover {
                    background: #0842a0;
                }

                .btn-back {
                    background: #e2e8f0;
                    color: #475569;
                }

                .btn-back:hover {
                    background: #cbd5e1;
                }
            </style>
        </head>

        <body>

            <jsp:include page="librarian_sidebar.jsp" />
            <c:set var="booksBasePath" value="${not empty booksBasePath ? booksBasePath : '/staff/books'}" />

            <div class="main-content">
                <div class="card">
                    <div class="header-area">
                        <i class="fas fa-file-import" style="font-size: 24px; color: var(--admin-accent);"></i>
                        <h2>Phiếu Nhập Kho</h2>
                    </div>

                    <div class="book-info">
                        <div class="info-row">
                            <span class="info-label">Tên sách:</span>
                            <span><strong>${book.title}</strong></span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Mã ISBN:</span>
                            <span>${book.isbn}</span>
                        </div>
                        <div class="info-row">
                            <span class="info-label">Tồn kho hiện tại:</span>
                            <span style="color: var(--admin-accent); font-weight: bold;">${book.quantity} cuốn</span>
                        </div>
                    </div>

                    <form action="${pageContext.request.contextPath}${booksBasePath}/restock" method="POST">
                        <input type="hidden" name="bookId" value="${book.id}">
                        <input type="hidden" name="action" value="restock">

                        <div class="form-group">
                            <label for="amount">Số lượng nhập thêm:</label>
                            <input type="number" id="amount" name="amount" min="1" value="1" required autofocus>
                            <small style="color: #64748b; margin-top: 5px; display: block;">
                                * Số lượng này sẽ được cộng dồn vào tồn kho hiện tại.
                            </small>
                        </div>

                        <div class="btn-group">
                            <button type="submit" class="btn btn-submit">
                                <i class="fas fa-check"></i> Xác nhận nhập kho
                            </button>
                            <a href="${pageContext.request.contextPath}${booksBasePath}?action=viewImportList"
                                class="btn btn-back">
                                Quay lại danh sách
                            </a>
                        </div>
                    </form>
                </div>
            </div>

        </body>

        </html>