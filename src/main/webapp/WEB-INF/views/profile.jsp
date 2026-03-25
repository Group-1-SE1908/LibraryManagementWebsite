<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

            <!DOCTYPE html>
            <html>

            <head>
                <meta charset="UTF-8">
                <title>Profile - LBMS</title>
                <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />

                <style>
                    body {
                        font-family: 'Segoe UI', Tahoma, sans-serif;
                        background: #f4f6fb;
                        margin: 0;
                    }

                    .profile-wrapper {
                        display: flex;
                        justify-content: center;
                        padding: 40px;
                    }

                    .profile-container {
                        width: 750px;
                        background: white;
                        padding: 35px;
                        border-radius: 18px;
                        box-shadow: 0 12px 35px rgba(0, 0, 0, 0.08);
                    }

                    .tabs {
                        display: flex;
                        border-bottom: 2px solid #eef1ff;
                        margin-bottom: 30px;
                    }

                    .tab {
                        padding: 12px 22px;
                        cursor: pointer;
                        font-weight: 500;
                        color: #666;
                        transition: 0.3s;
                    }

                    .tab:hover {
                        color: #2b63d9;
                    }

                    .tab.active {
                        color: #2b63d9;
                        border-bottom: 3px solid #2b63d9;
                        font-weight: 600;
                    }

                    .section {
                        display: none;
                    }

                    .section.active {
                        display: block;
                    }

                    .avatar-wrapper {
                        text-align: center;
                        margin-bottom: 25px;
                    }

                    .avatar-wrapper img {
                        width: 140px;
                        height: 140px;
                        border-radius: 50%;
                        object-fit: cover;
                        cursor: pointer;
                        border: 5px solid #eef1ff;
                        transition: 0.3s;
                    }

                    .avatar-wrapper img:hover {
                        transform: scale(1.05);
                    }

                    .avatar-text {
                        font-size: 13px;
                        color: #777;
                        margin-top: 10px;
                    }

                    .profile-container input {
                        width: 100%;
                        padding: 11px 14px;
                        margin-bottom: 18px;
                        border-radius: 10px;
                        border: 1px solid #ddd;
                        transition: 0.2s;
                        font-size: 14px;
                    }

                    .profile-container input:focus {
                        border-color: #2b63d9;
                        outline: none;
                        box-shadow: 0 0 0 3px rgba(43, 99, 217, 0.15);
                    }

                    input:invalid {
                        border-color: #dc3545;
                    }

                    .profile-container button {
                        padding: 10px 20px;
                        border: none;
                        border-radius: 10px;
                        background: linear-gradient(135deg, #2b63d9, #5f5bd7);
                        color: white;
                        cursor: pointer;
                        font-weight: 500;
                        transition: 0.3s;
                    }

                    .profile-container button:hover {
                        opacity: 0.9;
                        transform: translateY(-1px);
                    }

                    .tag {
                        display: inline-block;
                        padding: 5px 12px;
                        border-radius: 999px;
                        color: white;
                        font-size: 13px;
                        font-weight: 500;
                        background-color: green;
                    }

                    .role-member {
                        background: #3b82f6;
                    }

                    .role-librarian {
                        background: #22c55e;
                    }

                    .role-admin {
                        background: #8b5cf6;
                    }

                    .status-active {
                        background: #16a34a;
                    }

                    .status-inactive {
                        background: #9ca3af;
                    }

                    .form-group {
                        display: flex;
                        align-items: center;
                        margin-bottom: 18px;
                    }

                    .form-group label {
                        width: 140px;
                        font-weight: 600;
                    }

                    .form-group input,
                    .form-group select {
                        flex: 1;
                    }

                    .profile-container select {
                        width: 100%;
                        padding: 11px 14px;
                        margin-bottom: 18px;
                        border-radius: 10px;
                        border: 1px solid #ddd;
                        transition: 0.2s;
                        font-size: 14px;
                        background: #fff;
                        cursor: pointer;
                        appearance: auto;
                    }

                    .profile-container select:focus {
                        border-color: #2b63d9;
                        outline: none;
                        box-shadow: 0 0 0 3px rgba(43, 99, 217, 0.15);
                    }

                    .message {
                        margin: 15px 0 25px 0;
                        padding: 12px 16px;
                        border-radius: 8px;
                        font-weight: 500;
                    }

                    .message.success {
                        background: #e6f4ea;
                        color: #1e7e34;
                    }

                    .message.error {
                        background: #fdecea;
                        color: #b02a37;
                    }

                    #phoneError {
                        display: block;
                        margin-top: 5px;
                        font-size: 13px;
                        color: #dc3545;
                        font-weight: 500;
                    }

                    input#phoneInput.phone-error {
                        border-color: #dc3545 !important;
                        background-color: #fff5f5;
                    }

                    .ph-badge {
                        display: inline-block;
                        padding: 2px 10px;
                        border-radius: 999px;
                        font-size: 12px;
                        font-weight: 600;
                    }

                    .ph-badge-success {
                        background: #d1fae5;
                        color: #065f46;
                    }

                    .ph-badge-failed {
                        background: #fee2e2;
                        color: #991b1b;
                    }

                    .ph-method-wallet {
                        color: #16a34a;
                        font-weight: 700;
                    }

                    .ph-method-vnpay {
                        color: #1d4ed8;
                        font-weight: 700;
                    }

                    .ph-table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 14px;
                    }

                    .ph-table th {
                        background: #f8faff;
                        padding: 10px 14px;
                        text-align: left;
                        font-size: 12px;
                        font-weight: 600;
                        color: #666;
                        border-bottom: 2px solid #eef1ff;
                        text-transform: uppercase;
                        letter-spacing: .04em;
                    }

                    .ph-table td {
                        padding: 10px 14px;
                        border-bottom: 1px solid #f0f0f0;
                        vertical-align: middle;
                    }

                    .ph-table tr:last-child td {
                        border-bottom: none;
                    }

                    .ph-empty {
                        text-align: center;
                        padding: 32px 0;
                        color: #999;
                        font-size: 14px;
                    }

                    .ph-amount {
                        font-weight: 700;
                        color: #dc2626;
                        white-space: nowrap;
                    }
                </style>
            </head>

            <body>

                <jsp:include page="header.jsp" />

                <div class="profile-wrapper">
                    <div class="profile-container">

                        <h2>THÔNG TIN TÀI KHOẢN</h2>


                        <c:if test="${not empty flash}">
                            <div class="message ${flashType}" id="flashMessage">
                                ${flash}
                            </div>
                            <script>
                                document.addEventListener("DOMContentLoaded", function () {
                                    const flashMsg = document.getElementById('flashMessage');
                                    if (flashMsg && flashMsg.classList.contains('error')) {
                                        flashMsg.scrollIntoView({ behavior: 'smooth', block: 'start' });
                                    }
                                });
                            </script>
                        </c:if>

                        <div class="tabs">
                            <div class="tab active" onclick="showTab(event, 'profile')">Thông Tin Cá Nhân</div>
                            <div class="tab" onclick="showTab(event, 'password')">Mật Khẩu</div>
                            <div class="tab" onclick="showTab(event, 'paymentHistory')">Lịch Sử Thanh Toán</div>
                        </div>

                        <!-- PROFILE -->
                        <div id="profile" class="section active">

                            <!-- AVATAR FORM -->
                            <div class="avatar-wrapper">

                                <form id="avatarForm" method="post" action="upload-avatar"
                                    enctype="multipart/form-data">

                                    <c:choose>
                                        <c:when test="${not empty user.avatar}">
                                            <img src="${pageContext.request.contextPath}/${user.avatar}?v=${timestamp}"
                                                id="previewAvatar"
                                                onclick="document.getElementById('avatarUpload').click();"
                                                onerror="this.src='https://i.pravatar.cc/150?img=3'">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="https://i.pravatar.cc/150?img=3" id="previewAvatar"
                                                onclick="document.getElementById('avatarUpload').click();">
                                        </c:otherwise>
                                    </c:choose>

                                    <div class="avatar-text">
                                        Bấm vào hình để thay đổi avatar
                                    </div>

                                    <input type="file" id="avatarUpload" name="avatar" accept="image/*" hidden
                                        onchange="previewImage(event); document.getElementById('avatarForm').submit();">
                                </form>

                            </div>
                            <!-- UPDATE PROFILE FORM -->
                            <form method="post" action="${pageContext.request.contextPath}/profile" id="profileForm">

                                <div class="form-group">
                                    <label>Họ tên</label>
                                    <input type="text" name="fullName" id="fullName" value="${user.fullName}"
                                        maxlength="100" required>
                                </div>

                                <div class="form-group">
                                    <label>Email</label>
                                    <input type="email" value="${user.email}" readonly>
                                </div>

                                <div class="form-group">
                                    <label>Số điện thoại</label>
                                    <input type="text" name="phone" id="phoneInput" value="${user.phone}"
                                        pattern="[0-9]{10}" title="Số điện thoại phải đúng 10 số"
                                        placeholder="Nhập 10 chữ số" required>
                                    <small id="phoneError" style="color: #dc3545; display: none;"></small>
                                </div>

                                <div class="form-group">
                                    <label>Địa chỉ (Số nhà / Đường)</label>
                                    <input type="text" name="address" value="${user.address}" maxlength="200"
                                        placeholder="Ví dụ: 118/2/14 Lê Văn Thọ">
                                </div>

                                <div class="form-group">
                                    <label>Tỉnh / Thành phố</label>
                                    <select id="profileCity">
                                        <option value="">Chọn tỉnh/thành</option>
                                    </select>
                                    <input type="hidden" name="city" id="hiddenCity" value="${user.city}">
                                </div>

                                <div class="form-group">
                                    <label>Quận / Huyện</label>
                                    <select id="profileDistrict">
                                        <option value="">Chọn quận/huyện</option>
                                    </select>
                                    <input type="hidden" name="district" id="hiddenDistrict" value="${user.district}">
                                </div>

                                <div class="form-group">
                                    <label>Phường / Xã</label>
                                    <select id="profileWard">
                                        <option value="">Chọn phường/xã</option>
                                    </select>
                                    <input type="hidden" name="ward" id="hiddenWard" value="${user.ward}">
                                </div>

                                <p>
                                    Vai trò:
                                    <span class="tag
      <c:choose>
          <c:when test=" ${user.role.name eq 'MEMBER' }">role-member</c:when>
                                        <c:when test="${user.role.name eq 'LIBRARIAN'}">role-librarian</c:when>
                                        <c:when test="${user.role.name eq 'ADMIN'}">role-admin</c:when>
                                        </c:choose>">

                                        <c:choose>
                                            <c:when test="${user.role.name eq 'MEMBER'}">Thành viên</c:when>
                                            <c:when test="${user.role.name eq 'LIBRARIAN'}">Thủ thư</c:when>
                                            <c:when test="${user.role.name eq 'ADMIN'}">Quản trị viên</c:when>
                                            <c:otherwise>Không xác định</c:otherwise>
                                        </c:choose>

                                    </span>
                                </p>

                                <p>
                                    Trạng thái:
                                    <span class="tag
                                  <c:choose>
                                      <c:when test=" ${user.status eq 'ACTIVE' }">status-active</c:when>
                                        <c:otherwise>status-inactive</c:otherwise>
                                        </c:choose>">
                                        <c:choose>
                                            <c:when test="${user.status eq 'ACTIVE'}">Hoạt động</c:when>
                                            <c:otherwise>Không hoạt động</c:otherwise>
                                        </c:choose>
                                    </span>
                                </p>

                                <div style="text-align:center;">
                                    <button type="submit">LƯU THAY ĐỔI</button>
                                </div>
                            </form>
                        </div>

                        <!-- PASSWORD -->
                        <div id="password" class="section">

                            <form method="post" action="${pageContext.request.contextPath}/change-password">

                                <label>Mật khẩu hiện tại</label>
                                <input type="password" name="oldPassword" required>

                                <label>Mật khẩu mới</label>
                                <input type="password" name="newPassword" minlength="6" required>

                                <label>Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirm" minlength="6" required>

                                <div style="text-align:center;">
                                    <button type="submit">Thay đổi mật khẩu</button>
                                </div>

                            </form>
                        </div>

                        <!-- PAYMENT HISTORY -->
                        <div id="paymentHistory" class="section">
                            <h3 style="margin-bottom:16px;font-size:1.1rem;">Lịch Sử Thanh Toán</h3>
                            <c:choose>
                                <c:when test="${not empty paymentHistory}">
                                    <div style="overflow-x:auto;">
                                        <table class="ph-table">
                                            <thead>
                                                <tr>
                                                    <th>Thời gian</th>
                                                    <th>Loại</th>
                                                    <th>Phương thức</th>
                                                    <th>Mô tả</th>
                                                    <th>Số tiền</th>
                                                    <th>Trạng thái</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <c:forEach var="ph" items="${paymentHistory}">
                                                    <tr>
                                                        <td style="white-space:nowrap;color:#666;font-size:12px;">
                                                            <fmt:formatDate value="${ph.createdAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${ph.paymentType == 'BOOK_DEPOSIT'}">🛒
                                                                    Đặt cọc sách</c:when>
                                                                <c:when test="${ph.paymentType == 'FINE'}">⚠️ Phí phạt
                                                                </c:when>
                                                                <c:when test="${ph.paymentType == 'BOOK_RETURN'}">📚 Trả
                                                                    sách</c:when>
                                                                <c:otherwise>${ph.paymentType}</c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${ph.paymentMethod == 'WALLET'}">
                                                                    <span class="ph-method-wallet">💰 Ví</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="ph-method-vnpay">💳 VNPay</span>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td
                                                            style="max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                                            <c:choose>
                                                                <c:when test="${not empty ph.description}">
                                                                    ${ph.description}</c:when>
                                                                <c:otherwise>—</c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td class="ph-amount">
                                                            <fmt:formatNumber value="${ph.amount}" pattern="#,##0" /> ₫
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${ph.status == 'SUCCESS'}">
                                                                    <span class="ph-badge ph-badge-success">Thành
                                                                        công</span>
                                                                </c:when>
                                                                <c:otherwise>
                                                                    <span class="ph-badge ph-badge-failed">Thất
                                                                        bại</span>
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
                                    <div class="ph-empty">
                                        <p>Bạn chưa có lịch sử thanh toán nào.</p>
                                        <p style="margin-top:8px;">Các giao dịch sẽ xuất hiện tại đây sau khi bạn thanh
                                            toán.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>

                    </div>
                </div>

                <script>
                    function showTab(e, tabId) {
                        document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
                        document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));

                        document.getElementById(tabId).classList.add('active');
                        e.target.classList.add('active');
                    }

                    function previewImage(event) {
                        const reader = new FileReader();
                        reader.onload = function () {
                            document.getElementById('previewAvatar').src = reader.result;
                        }
                        reader.readAsDataURL(event.target.files[0]);
                    }

                    // Phone validation
                    document.addEventListener("DOMContentLoaded", function () {
                        const phoneInput = document.getElementById('phoneInput');
                        const phoneError = document.getElementById('phoneError');
                        const profileForm = document.getElementById('profileForm');

                        if (phoneInput) {
                            // Real-time validation - chỉ kiểm tra format
                            phoneInput.addEventListener('input', function () {
                                const phone = this.value.trim();

                                // Clear error message
                                phoneError.textContent = '';
                                phoneInput.classList.remove('phone-error');

                                // Check format
                                if (phone && phone.length > 0 && !/^\d{10}$/.test(phone)) {
                                    phoneError.textContent = 'Số điện thoại phải đúng 10 chữ số';
                                    phoneInput.classList.add('phone-error');
                                }
                            });

                            // Form submit validation
                            profileForm.addEventListener('submit', function (e) {
                                const phone = phoneInput.value.trim();

                                // Validate format
                                if (!phone || !/^\d{10}$/.test(phone)) {
                                    e.preventDefault();
                                    phoneError.textContent = 'Số điện thoại phải đúng 10 chữ số';
                                    phoneInput.classList.add('phone-error');
                                    phoneInput.focus();
                                    phoneInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                    return false;
                                }

                                // Format hợp lệ, cho phép submit form bình thường
                                // Server sẽ check trùng phone và trả về flash message error nếu cần
                                return true;
                            });
                        }
                    });
                </script>

                <!-- Province/District/Ward API Integration -->
                <script>
                    document.addEventListener('DOMContentLoaded', function () {
                        const PROVINCE_API_URL = 'https://provinces.open-api.vn/api/?depth=3';
                        const citySelect = document.getElementById('profileCity');
                        const districtSelect = document.getElementById('profileDistrict');
                        const wardSelect = document.getElementById('profileWard');
                        const hiddenCity = document.getElementById('hiddenCity');
                        const hiddenDistrict = document.getElementById('hiddenDistrict');
                        const hiddenWard = document.getElementById('hiddenWard');

                        if (!citySelect || !districtSelect || !wardSelect) return;

                        const savedCity = (hiddenCity?.value || '').trim();
                        const savedDistrict = (hiddenDistrict?.value || '').trim();
                        const savedWard = (hiddenWard?.value || '').trim();

                        const locationCatalog = new Map();

                        const resetSelect = (select, placeholder) => {
                            select.innerHTML = '<option value="">' + placeholder + '</option>';
                        };

                        const buildCatalog = (provinces) => {
                            locationCatalog.clear();
                            if (!Array.isArray(provinces)) return;
                            provinces.forEach(p => {
                                if (!p || !p.name) return;
                                const districts = new Map();
                                (p.districts || []).forEach(d => {
                                    if (!d || !d.name) return;
                                    const wards = Array.isArray(d.wards)
                                        ? d.wards.map(w => w.name).filter(Boolean) : [];
                                    districts.set(d.name, wards);
                                });
                                locationCatalog.set(p.name, { districts });
                            });
                        };

                        const populateCities = () => {
                            resetSelect(citySelect, 'Chọn tỉnh/thành');
                            locationCatalog.forEach((val, name) => {
                                const opt = document.createElement('option');
                                opt.value = name;
                                opt.textContent = name;
                                citySelect.appendChild(opt);
                            });
                        };

                        const renderDistricts = (city) => {
                            resetSelect(districtSelect, 'Chọn quận/huyện');
                            resetSelect(wardSelect, 'Chọn phường/xã');
                            if (!city) return;
                            const province = locationCatalog.get(city);
                            if (!province) return;
                            province.districts.forEach((wards, distName) => {
                                const opt = document.createElement('option');
                                opt.value = distName;
                                opt.textContent = distName;
                                districtSelect.appendChild(opt);
                            });
                        };

                        const renderWards = (city, district) => {
                            resetSelect(wardSelect, 'Chọn phường/xã');
                            if (!city || !district) return;
                            const province = locationCatalog.get(city);
                            const wardList = province?.districts.get(district);
                            if (!Array.isArray(wardList)) return;
                            wardList.forEach(w => {
                                const opt = document.createElement('option');
                                opt.value = w;
                                opt.textContent = w;
                                wardSelect.appendChild(opt);
                            });
                        };

                        const syncHidden = () => {
                            hiddenCity.value = citySelect.value;
                            hiddenDistrict.value = districtSelect.value;
                            hiddenWard.value = wardSelect.value;
                        };

                        citySelect.addEventListener('change', () => {
                            renderDistricts(citySelect.value);
                            syncHidden();
                        });
                        districtSelect.addEventListener('change', () => {
                            renderWards(citySelect.value, districtSelect.value);
                            syncHidden();
                        });
                        wardSelect.addEventListener('change', syncHidden);

                        fetch(PROVINCE_API_URL)
                            .then(r => { if (!r.ok) throw new Error('API error'); return r.json(); })
                            .then(data => {
                                buildCatalog(data);
                                populateCities();
                                if (savedCity) {
                                    citySelect.value = savedCity;
                                    renderDistricts(savedCity);
                                    if (savedDistrict) {
                                        districtSelect.value = savedDistrict;
                                        renderWards(savedCity, savedDistrict);
                                        if (savedWard) {
                                            wardSelect.value = savedWard;
                                        }
                                    }
                                }
                            })
                            .catch(err => console.error('Không tải được tỉnh/thành:', err));
                    });
                </script>

                <!-- POPUP ĐỔI MẬT KHẨU -->
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

                <c:if test="${not empty flash
                      and flashType == 'success' 
                      and flash eq 'Đổi mật khẩu thành công.'}">

                    <div class="modal fade" id="successModal" tabindex="-1">
                        <div class="modal-dialog modal-dialog-centered">
                            <div class="modal-content shadow-lg border-0 rounded-4">
                                <div class="modal-body text-center p-4">

                                    <div style="font-size:60px;color:#28a745;">✔</div>

                                    <h5 class="fw-bold mt-3">Thành công</h5>
                                    <p class="text-muted">${flash}</p>

                                    <button class="btn btn-success rounded-pill px-4" data-bs-dismiss="modal">
                                        OK
                                    </button>

                                </div>
                            </div>
                        </div>
                    </div>

                    <script>
                        document.addEventListener("DOMContentLoaded", function () {
                            var myModal = new bootstrap.Modal(
                                document.getElementById('successModal')
                            );
                            myModal.show();
                        });
                    </script>

                </c:if>

            </body>

            </html>