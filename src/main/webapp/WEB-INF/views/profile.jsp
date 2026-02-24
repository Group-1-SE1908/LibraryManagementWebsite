<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Profile - LBMS</title>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/styles.css" />

        <style>
            body{
                font-family: 'Segoe UI', Tahoma, sans-serif;
                background:#f4f6fb;
                margin:0;
            }

            .profile-wrapper{
                display:flex;
                justify-content:center;
                padding:40px;
            }

            .profile-container{
                width:750px;
                background:white;
                padding:35px;
                border-radius:18px;
                box-shadow:0 12px 35px rgba(0,0,0,0.08);
            }

            .tabs{
                display:flex;
                border-bottom:2px solid #eef1ff;
                margin-bottom:30px;
            }

            .tab{
                padding:12px 22px;
                cursor:pointer;
                font-weight:500;
                color:#666;
                transition:0.3s;
            }

            .tab:hover{
                color:#2b63d9;
            }

            .tab.active{
                color:#2b63d9;
                border-bottom:3px solid #2b63d9;
                font-weight:600;
            }

            .section{
                display:none;
            }
            .section.active{
                display:block;
            }

            .avatar-wrapper{
                text-align:center;
                margin-bottom:25px;
            }

            .avatar-wrapper img{
                width:140px;
                height:140px;
                border-radius:50%;
                object-fit:cover;
                cursor:pointer;
                border:5px solid #eef1ff;
                transition:0.3s;
            }

            .avatar-wrapper img:hover{
                transform:scale(1.05);
            }

            .avatar-text{
                font-size:13px;
                color:#777;
                margin-top:10px;
            }

            .profile-container input{
                width:100%;
                padding:11px 14px;
                margin-bottom:18px;
                border-radius:10px;
                border:1px solid #ddd;
                transition:0.2s;
                font-size:14px;
            }

            .profile-container input:focus{
                border-color:#2b63d9;
                outline:none;
                box-shadow:0 0 0 3px rgba(43,99,217,0.15);
            }

            input:invalid {
                border-color:#dc3545;
            }

            .profile-container button{
                padding:10px 20px;
                border:none;
                border-radius:10px;
                background:linear-gradient(135deg,#2b63d9,#5f5bd7);
                color:white;
                cursor:pointer;
                font-weight:500;
                transition:0.3s;
            }

            .profile-container button:hover{
                opacity:0.9;
                transform:translateY(-1px);
            }

            .tag{
                display:inline-block;
                padding:5px 12px;
                border-radius:999px;
                color:white;
                font-size:13px;
                font-weight:500;
            }

            .role-member{
                background:#3b82f6;
            }
            .role-librarian{
                background:#22c55e;
            }
            .role-admin{
                background:#8b5cf6;
            }

            .status-active{
                background:#16a34a;
            }
            .status-inactive{
                background:#9ca3af;
            }

            .form-group {
                display:flex;
                align-items:center;
                margin-bottom:18px;
            }

            .form-group label {
                width:140px;
                font-weight:600;
            }

            .form-group input {
                flex:1;
            }

            .message {
                margin:15px 0 25px 0;
                padding:12px 16px;
                border-radius:8px;
                font-weight:500;
            }

            .message.success {
                background:#e6f4ea;
                color:#1e7e34;
            }

            .message.error {
                background:#fdecea;
                color:#b02a37;
            }
        </style>
    </head>

    <body>

        <jsp:include page="header.jsp"/>

        <div class="profile-wrapper">
            <div class="profile-container">

                <h2>THÔNG TIN TÀI KHOẢN</h2>
                

                <c:if test="${not empty flash}">
                    <div class="message ${flashType}">
                        ${flash}
                    </div>
                </c:if>

                <div class="tabs">
                    <div class="tab active" onclick="showTab(event, 'profile')">Thông Tin Cá Nhân</div>
                    <div class="tab" onclick="showTab(event, 'password')">Mật Khẩu</div>
                </div>

                <!-- PROFILE -->
                <div id="profile" class="section active">

                    <!-- AVATAR FORM -->
                    <div class="avatar-wrapper">

                        <form id="avatarForm"
                              method="post"
                              action="upload-avatar"
                              enctype="multipart/form-data">

                            <c:choose>
                                <c:when test="${not empty user.avatar}">
                                    <img src="${pageContext.request.contextPath}/uploads/${user.avatar}?v=${timestamp}"
                                         id="previewAvatar"
                                         onclick="document.getElementById('avatarUpload').click();">
                                </c:when>
                                <c:otherwise>
                                    <img src="https://i.pravatar.cc/150?img=3"
                                         id="previewAvatar"
                                         onclick="document.getElementById('avatarUpload').click();">
                                </c:otherwise>
                            </c:choose>

                            <div class="avatar-text">
                                Bấm vào hình để thay đổi avatar
                            </div>

                            <input type="file"
                                   id="avatarUpload"
                                   name="avatar"
                                   accept="image/*"
                                   hidden
                                   onchange="previewImage(event); document.getElementById('avatarForm').submit();">
                        </form>

                    </div>
                    <!-- UPDATE PROFILE FORM -->
                    <form method="post" action="${pageContext.request.contextPath}/profile">

                        <div class="form-group">
                            <label>Họ tên</label>
                            <input type="text"
                                   name="fullName"
                                   value="${user.fullName}"
                                   maxlength="100"
                                   required>
                        </div>

                        <div class="form-group">
                            <label>Email</label>
                            <input type="email"
                                   value="${user.email}"
                                   readonly>
                        </div>

                        <div class="form-group">
                            <label>Số điện thoại</label>
                            <input type="text"
                                   name="phone"
                                   value="${user.phone}"
                                   pattern="[0-9]{10}"
                                   title="Số điện thoại phải đúng 10 số"
                                   required>
                        </div>

                        <div class="form-group">
                            <label>Địa chỉ</label>
                            <input type="text"
                                   name="address"
                                   value="${user.address}"
                                   maxlength="200">
                        </div>

                        <p>
                            Role:
                            <span class="tag
                                  <c:choose>
                                      <c:when test="${user.role.name eq 'Member'}">role-member</c:when>
                                      <c:when test="${user.role.name eq 'Librarian'}">role-librarian</c:when>
                                      <c:when test="${user.role.name eq 'Admin'}">role-admin</c:when>
                                  </c:choose>">
                                ${user.role.name}
                            </span>
                        </p>

                        <p>
                            Status:
                            <span class="tag
                                  <c:choose>
                                      <c:when test="${user.status eq 'ACTIVE'}">status-active</c:when>
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

                              <button class="btn btn-success rounded-pill px-4"
                                      data-bs-dismiss="modal">
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