<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Profile - LBMS</title>

        <style>

            /* ==============================
               BODY
            =================================*/
            body{
                font-family: 'Segoe UI', Tahoma, sans-serif;
                background:#f4f6fb;
                display:flex;
                justify-content:center;
                padding:40px;
            }

            /* ==============================
               CONTAINER (Card giống Catalog)
            =================================*/
            .container{
                width:750px;
                background:white;
                padding:35px;
                border-radius:18px;
                box-shadow:0 12px 35px rgba(0,0,0,0.08);
            }

            /* ==============================
               TABS
            =================================*/
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

            /* ==============================
               SECTION
            =================================*/
            .section{
                display:none;
            }

            .section.active{
                display:block;
            }

            /* ==============================
               AVATAR
            =================================*/
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

            /* ==============================
               INPUT
            =================================*/
            input{
                width:100%;
                padding:11px 14px;
                margin-bottom:18px;
                border-radius:10px;
                border:1px solid #ddd;
                transition:0.2s;
                font-size:14px;
            }

            input:focus{
                border-color:#2b63d9;
                outline:none;
                box-shadow:0 0 0 3px rgba(43,99,217,0.15);
            }

            /* ==============================
               BUTTON (Gradient giống Search)
            =================================*/
            button{
                padding:10px 20px;
                border:none;
                border-radius:10px;
                background:linear-gradient(135deg,#2b63d9,#5f5bd7);
                color:white;
                cursor:pointer;
                font-weight:500;
                transition:0.3s;
            }

            button:hover{
                opacity:0.9;
                transform:translateY(-1px);
            }

            /* ==============================
               TAG (pill)
            =================================*/
            .tag{
                display:inline-block;
                padding:5px 12px;
                border-radius:999px;
                color:white;
                font-size:13px;
                font-weight:500;
            }

            /* ==============================
               ROLE COLORS
            =================================*/
            .role-member{
                background:#3b82f6;
            }

            .role-librarian{
                background:#22c55e;
            }

            .role-admin{
                background:#8b5cf6;
            }

            /* ==============================
               STATUS COLORS
            =================================*/
            .status-active{
                background:#16a34a;
            }

            .status-inactive{
                background:#9ca3af;
            }

        </style>
    </head>

    <body>

        <div class="container">

            <h2>THÔNG TIN TÀI KHOẢN</h2>

            <!-- Tabs -->
            <div class="tabs">
                <div class="tab active" onclick="showTab('profile')">Thông Tin Cá Nhân</div>
                <div class="tab" onclick="showTab('password')">Mật Khẩu</div>
            </div>

            <!-- PROFILE SECTION -->
            <div id="profile" class="section active">

                <form method="post" action="${pageContext.request.contextPath}/profile" enctype="multipart/form-data">

                    <!-- Avatar UI Only -->
                    <div class="avatar-wrapper">
                        <img src="https://i.pravatar.cc/150?img=3"
                             id="previewAvatar"
                             onclick="document.getElementById('avatarUpload').click();">

                        <div class="avatar-text">
                            Bấm vào hình bên trên để thay đổi avatar
                        </div>

                        <!-- Chỉ để preview, không submit -->
                        <input type="file"
                               id="avatarUpload"
                               accept="image/*"
                               hidden
                               onchange="previewImage(event)">
                    </div>

                    <label>Họ tên</label>
                    <input name="fullName" value="${user.fullName}" required>

                    <label>Email</label>
                    <input name="email" type="email" value="${user.email}" required>

                    <label>Số điện thoại</label>
                    <input name="phone" value="${user.phone}">

                    <label>Địa chỉ</label>
                    <input name="address" value="${user.address}">

                    <p>
                        Role:
                        <span class="tag
                              <c:choose>
                                  <c:when test="${user.role.name eq 'Member'}">role-member</c:when>
                                  <c:when test="${user.role.name eq 'Librarian'}">role-librarian</c:when>
                                  <c:when test="${user.role.name eq 'Admin'}">role-admin</c:when>
                              </c:choose>
                              ">
                            ${user.role.name}
                        </span>
                    </p>

                    <p>
                        Status:
                        <span class="tag
                              <c:choose>
                                  <c:when test="${user.status eq 'ACTIVE'}">status-active</c:when>
                                  <c:otherwise>status-inactive</c:otherwise>
                              </c:choose>
                              ">
                            <c:choose>
                                <c:when test="${user.status eq 'ACTIVE'}">Hoạt động</c:when>
                                <c:otherwise>Không hoạt động</c:otherwise>
                            </c:choose>
                        </span>
                    </p>

                    <button type="submit">LƯU THAY ĐỔI</button>

                </form>
            </div>

            <!-- PASSWORD SECTION -->
            <div id="password" class="section">

                <form method="post" action="${pageContext.request.contextPath}/change-password">

                    <label>Mật khẩu hiện tại</label>
                    <input type="password" name="oldPassword" required>

                    <label>Mật khẩu mới</label>
                    <input type="password" name="newPassword" required>

                    <label>Xác nhận mật khẩu mới</label>
                    <input type="password" name="confirm" required>

                    <button type="submit">THAY ĐỔI MẬT KHẨU</button>

                </form>

            </div>

        </div>

        <script>
            function showTab(tabId) {
                document.querySelectorAll('.section').forEach(s => s.classList.remove('active'));
                document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));

                document.getElementById(tabId).classList.add('active');
                event.target.classList.add('active');
            }

            function previewImage(event) {
                const reader = new FileReader();
                reader.onload = function () {
                    document.getElementById('previewAvatar').src = reader.result;
                }
                reader.readAsDataURL(event.target.files[0]);
            }
        </script>

    </body>
</html>