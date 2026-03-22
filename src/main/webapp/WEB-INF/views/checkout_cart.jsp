<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
            <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

                <!DOCTYPE html>
                <html lang="vi">

                <head>
                    <meta charset="UTF-8" />
                    <title>Thanh toán đặt sách online</title>
                    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />
                    <style>
                        * {
                            margin: 0;
                            padding: 0;
                            box-sizing: border-box;
                        }

                        body {
                            font-family: Arial, sans-serif;
                            background: #f5f5f5;
                        }

                        .container {
                            max-width: 1200px;
                            margin: 40px auto;
                            padding: 0 20px;
                        }

                        .checkout-grid {
                            display: grid;
                            grid-template-columns: 2fr 1fr;
                            gap: 40px;
                        }

                        .section {
                            background: #fff;
                            padding: 24px;
                            border-radius: 8px;
                            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
                        }

                        .header {
                            margin-bottom: 30px;
                        }

                        .header h1 {
                            font-size: 2rem;
                            margin-bottom: 10px;
                        }

                        .header p {
                            color: #666;
                        }

                        .item {
                            border-bottom: 1px solid #eee;
                            padding: 16px 0;
                        }

                        .item:last-child {
                            border-bottom: none;
                        }

                        .item-title {
                            font-weight: bold;
                            margin-bottom: 5px;
                        }

                        .item-info {
                            color: #666;
                            font-size: 0.9rem;
                        }

                        .summary-row {
                            display: flex;
                            justify-content: space-between;
                            padding: 12px 0;
                            border-bottom: 1px solid #eee;
                        }

                        .summary-row:last-child {
                            border-bottom: none;
                        }

                        .summary-total {
                            display: flex;
                            justify-content: space-between;
                            padding: 16px 0;
                            border-top: 2px solid #333;
                            font-size: 1.2rem;
                            font-weight: bold;
                            margin-top: 16px;
                        }

                        .btn {
                            display: block;
                            width: 100%;
                            padding: 14px;
                            background: #007bff;
                            color: white;
                            border: none;
                            border-radius: 4px;
                            font-size: 1rem;
                            cursor: pointer;
                            margin-top: 20px;
                        }

                        .btn:hover {
                            background: #0056b3;
                        }

                        .back-link {
                            display: block;
                            text-align: center;
                            color: #666;
                            text-decoration: none;
                            margin-top: 15px;
                        }

                        .back-link:hover {
                            text-decoration: underline;
                        }

                        .alert {
                            padding: 16px;
                            margin: 20px 0;
                            border-radius: 4px;
                            background: #ffebee;
                            color: #c62828;
                        }

                        /* Modal Styles */
                        .modal {
                            position: fixed;
                            z-index: 9999;
                            left: 0;
                            top: 0;
                            width: 100%;
                            height: 100%;
                            background-color: rgba(0, 0, 0, 0.5);
                            display: none;
                            align-items: center;
                            justify-content: center;
                        }

                        .modal.show {
                            display: flex !important;
                        }

                        .modal-content {
                            background-color: #fff;
                            padding: 30px;
                            border-radius: 8px;
                            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
                            max-width: 500px;
                            width: 90%;
                            animation: slideDown 0.3s ease-out;
                            position: relative;
                            z-index: 10000;
                        }

                        @keyframes slideDown {
                            from {
                                transform: translateY(-50px);
                                opacity: 0;
                            }

                            to {
                                transform: translateY(0);
                                opacity: 1;
                            }
                        }

                        .modal-header {
                            font-size: 1.5rem;
                            font-weight: bold;
                            margin-bottom: 20px;
                            color: #333;
                        }

                        .modal-body {
                            margin-bottom: 24px;
                            line-height: 1.6;
                            color: #666;
                        }

                        .modal-body .info-item {
                            margin-bottom: 12px;
                            padding: 8px 0;
                            border-bottom: 1px solid #eee;
                        }

                        .modal-body .info-label {
                            font-weight: bold;
                            color: #333;
                            display: inline-block;
                            width: 120px;
                        }

                        .modal-warning {
                            background: #fff3cd;
                            border-left: 4px solid #ffc107;
                            padding: 12px;
                            margin-bottom: 20px;
                            border-radius: 4px;
                            color: #856404;
                            font-weight: 500;
                        }

                        .modal-footer {
                            display: flex;
                            gap: 12px;
                            justify-content: flex-end;
                        }

                        .btn-modal {
                            padding: 10px 24px;
                            font-size: 0.95rem;
                            border: none;
                            border-radius: 4px;
                            cursor: pointer;
                            font-weight: 500;
                        }

                        .btn-modal-confirm {
                            background: #28a745;
                            color: white;
                        }

                        .btn-modal-confirm:hover {
                            background: #218838;
                        }

                        .btn-modal-cancel {
                            background: #6c757d;
                            color: white;
                        }

                        .btn-modal-cancel:hover {
                            background: #5a6268;
                        }

                        @media (max-width: 768px) {
                            .checkout-grid {
                                grid-template-columns: 1fr;
                            }

                            .modal-content {
                                padding: 20px;
                            }
                        }
                    </style>
                </head>

                <body>
                    <jsp:include page="/WEB-INF/views/header.jsp" />

                    <div class="container">
                        <div class="header">
                            <h1>Thanh toán đặt sách online</h1>
                            <p>Kiểm tra thông tin sách và số tiền cọc (50% giá trị) trước khi xác nhận.</p>
                        </div>

                        <!-- Debug Info -->
                        <c:if test="${empty cart}">
                            <div class="alert error">Lỗi: Không tìm thấy dữ liệu giỏ hàng!</div>
                        </c:if>
                        <c:if test="${empty totalDeposit}">
                            <div class="alert error">Lỗi: Không thể tính toán cọc!</div>
                        </c:if>

                        <div class="checkout-grid">
                            <div class="section">
                                <h2>Chi tiết đơn hàng</h2>
                                <c:forEach var="cartItem" items="${cart.items}">
                                    <div class="item">
                                        <div class="item-title">${cartItem.book.title}</div>
                                        <div class="item-info">
                                            <p>Tác giả: ${cartItem.book.author}</p>
                                            <p>Số lượng: <strong>${cartItem.quantity}</strong> cuốn</p>
                                            <p>Giá: <strong>
                                                    <fmt:formatNumber value="${cartItem.book.price}" pattern="#,##0" />
                                                    ₫
                                                </strong> / cuốn</p>
                                            <p>Thành tiền: <strong>
                                                    <fmt:formatNumber value="${cartItem.subtotal}" pattern="#,##0" /> ₫
                                                </strong></p>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <div class="section">
                                <h2>Tóm tắt thanh toán</h2>
                                <div class="summary-row">
                                    <span>Tổng giá trị</span>
                                    <span>
                                        <fmt:formatNumber value="${totalValue}" pattern="#,##0" /> ₫
                                    </span>
                                </div>
                                <div class="summary-row">
                                    <span>Cọc (50%)</span>
                                    <span>
                                        <fmt:formatNumber value="${totalDeposit}" pattern="#,##0" /> ₫
                                    </span>
                                </div>
                                <div class="summary-total">
                                    <span>Tổng cọc thanh toán</span>
                                    <span>
                                        <fmt:formatNumber value="${totalDeposit}" pattern="#,##0" /> ₫
                                    </span>
                                </div>

                                <form id="checkoutForm"
                                    action="${pageContext.request.contextPath}/cart/checkout/process" method="post">
                                    <input type="hidden" name="borrowMethod" value="${borrowMethod}" />
                                    <input type="hidden" name="contactName" value="${contactName}" />
                                    <input type="hidden" name="contactPhone" value="${contactPhone}" />
                                    <input type="hidden" name="contactEmail" value="${contactEmail}" />
                                    <input type="hidden" name="borrowDuration" value="${borrowDuration}" />
                                    <input type="hidden" name="pickupDate" value="${pickupDate}" />
                                    <input type="hidden" name="returnDate" value="${returnDate}" />
                                    <input type="hidden" name="txnRef" value="${txnRef}" />
                                    <button type="button" class="btn" onclick="showConfirmModal('vnpay')">💳 Thanh toán
                                        cọc qua VNPay</button>
                                </form>

                                <form id="walletForm"
                                    action="${pageContext.request.contextPath}/cart/checkout/pay-wallet" method="post">
                                    <input type="hidden" name="txnRef" value="${txnRef}" />
                                    <button type="button" class="btn" style="background:#16a34a;margin-top:10px;"
                                        onclick="showConfirmModal('wallet')">
                                        💰 Thanh toán cọc bằng Ví
                                        <c:if test="${sessionScope.currentUser != null}">
                                            (
                                            <fmt:formatNumber
                                                value="${sessionScope.currentUser.walletBalance != null ? sessionScope.currentUser.walletBalance : 0}"
                                                pattern="#,##0" /> ₫)
                                        </c:if>
                                    </button>
                                </form>
                                <a href="${pageContext.request.contextPath}/cart" class="back-link">← Quay lại giỏ
                                    hàng</a>
                            </div>
                        </div>
                    </div>

                    <!-- Modal Xác Nhận -->
                    <div id="confirmModal" class="modal">
                        <div class="modal-content">
                            <div class="modal-header">
                                ⚠️ Xác nhận đặt sách online
                            </div>
                            <div class="modal-body">
                                <div class="modal-warning">
                                    ⚠️ Lưu ý quan trọng: Khi bạn thanh toán cọc, yêu cầu này sẽ được tạo và
                                    <strong>không thể hủy bỏ</strong>.
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Số loại sách:</span>
                                    <span id="modalItemCount">0</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Tổng giá trị:</span>
                                    <span id="modalTotalValue">0 ₫</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Cọc (50%):</span>
                                    <span id="modalDeposit" style="color: #d32f2f; font-weight: bold;">0 ₫</span>
                                </div>
                                <div class="info-item">
                                    <span class="info-label">Phương thức:</span>
                                    <span id="modalPayMethod" style="font-weight:bold;color:#1d4ed8;">VNPay</span>
                                </div>
                                <div style="margin-top: 20px; padding-top: 20px; border-top: 2px solid #eee;">
                                    <p style="color: #333; font-weight: 500; margin-bottom: 8px;">Bạn có xác nhận thực
                                        hiện thanh toán không?</p>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn-modal btn-modal-cancel"
                                    onclick="closeConfirmModal()">Hủy bỏ</button>
                                <button type="button" class="btn-modal btn-modal-confirm" id="modalConfirmBtn"
                                    onclick="submitPaymentForm()">Xác nhận & Thanh toán</button>
                            </div>
                        </div>
                    </div>

                    <jsp:include page="/WEB-INF/views/footer.jsp" />

                    <script type="text/javascript">
                        var _paymentMethod = 'vnpay';

                        function showConfirmModal(method) {
                            _paymentMethod = method || 'vnpay';
                            console.log('Show modal called, method:', _paymentMethod);
                            const modal = document.getElementById('confirmModal');
                            if (!modal) { console.error('Modal not found'); return; }

                            try {
                                const items = document.querySelectorAll('.item');
                                document.getElementById('modalItemCount').textContent = items.length;

                                const summaryRows = document.querySelectorAll('.summary-row');
                                if (summaryRows.length >= 1) {
                                    const spans1 = summaryRows[0].querySelectorAll('span');
                                    if (spans1.length >= 2) document.getElementById('modalTotalValue').textContent = spans1[1].textContent.trim();
                                }
                                if (summaryRows.length >= 2) {
                                    const spans2 = summaryRows[1].querySelectorAll('span');
                                    if (spans2.length >= 2) document.getElementById('modalDeposit').textContent = spans2[1].textContent.trim();
                                }

                                var methodEl = document.getElementById('modalPayMethod');
                                if (methodEl) {
                                    if (_paymentMethod === 'wallet') {
                                        methodEl.textContent = '💰 Ví LBMS';
                                        methodEl.style.color = '#16a34a';
                                    } else {
                                        methodEl.textContent = '💳 VNPay';
                                        methodEl.style.color = '#1d4ed8';
                                    }
                                }
                            } catch (e) { console.error('Error getting values:', e); }

                            modal.classList.add('show');
                        }

                        function closeConfirmModal() {
                            const modal = document.getElementById('confirmModal');
                            if (modal) modal.classList.remove('show');
                        }

                        function submitPaymentForm() {
                            closeConfirmModal();
                            if (_paymentMethod === 'wallet') {
                                const form = document.getElementById('walletForm');
                                if (form) form.submit();
                            } else {
                                const form = document.getElementById('checkoutForm');
                                if (form) form.submit();
                            }
                        }

                        // Close modal when clicking outside
                        document.addEventListener('click', function (event) {
                            const modal = document.getElementById('confirmModal');
                            if (modal && event.target === modal) closeConfirmModal();
                        });
                    </script>
                </body>

                </html>