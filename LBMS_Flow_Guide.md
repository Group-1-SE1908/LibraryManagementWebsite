# LBMS – Hướng dẫn sử dụng & Luồng hệ thống (A/B/C/D)

Tài liệu này mô tả **toàn bộ luồng hệ thống LBMS** theo đúng phiên bản đang triển khai trong project (Java Servlet/JSP + JDBC + MySQL).

- **A**: Profile (Hồ sơ + Đổi mật khẩu)
- **B**: Admin quản lý User (role + khóa/mở)
- **C**: Reservation (Đặt trước khi sách hết)
- **D**: Shipping (GHTK – tạo đơn giao sách + tracking)

---

## 1) Tổng quan truy cập & điều hướng

### 1.1 URL chính
- `GET /login` – trang đăng nhập
- `GET /register` – trang đăng ký
- `GET /forgot-password` – quên mật khẩu
- `GET /reset-password?token=...` – đặt lại mật khẩu

Sau khi đăng nhập:
- **ADMIN**: tự chuyển đến `GET /admin/users`
- **LIBRARIAN / USER**: tự chuyển đến `GET /books`

### 1.2 Điều kiện bắt buộc
- Database đã chạy `schema.sql`
- (Khuyến nghị) chạy `seed_accounts.sql` để có sẵn tài khoản mẫu

### 1.3 Tài khoản mẫu
Mật khẩu mặc định: `123456`
- **Admin**: `admin@lbms.local`
- **Librarian**: `librarian@lbms.local`
- **User**: `user@lbms.local`

---

## 2) Phân quyền theo Role (RBAC)

### 2.1 USER
- Được:
  - Xem/tìm sách (`/books`)
  - Gửi yêu cầu mượn (`/borrow/request`)
  - Xem phiếu mượn của mình (`/borrow`)
  - Đặt trước khi sách hết (`/reservations` + `POST /reservations/create`)
  - Hủy đặt trước (khi còn `WAITING/NOTIFIED`) (`/reservations/cancel?id=...`)
  - Xem/cập nhật hồ sơ (`/profile`)
  - Đổi mật khẩu (`/change-password`)

- Không được:
  - Thêm/Sửa/Xóa sách (`/books/new`, `/books/edit`, `/books/delete`) – bị chặn 403
  - Vào Admin (`/admin/*`) – bị chặn 403
  - Vào Shipping (`/shipping*`) – bị chặn 403

### 2.2 LIBRARIAN
- Được:
  - CRUD sách (`/books/new|edit|delete`)
  - Duyệt/Từ chối yêu cầu mượn (`/borrow/approve`, `/borrow/reject`)
  - Đánh dấu trả (`/borrow/return`)
  - Tạo shipment & xem shipment (`/shipping*`)
  - Xem Reservations (xem tất cả) (`/reservations`)
  - Profile/đổi mật khẩu (`/profile`, `/change-password`)

- Không được:
  - Quản lý user admin (`/admin/*`) – bị chặn 403

### 2.3 ADMIN
- Được:
  - Toàn bộ quyền Librarian
  - Quản lý users (`/admin/users`) – đổi role, khóa/mở

---

## 3) Luồng nghiệp vụ chi tiết theo module

## A) Profile (Hồ sơ + đổi mật khẩu)

### A1. Xem hồ sơ
- **URL**: `GET /profile`
- **Hiển thị**:
  - Email
  - Role
  - Status (`ACTIVE/LOCKED`)
  - Họ tên (có thể sửa)

### A2. Cập nhật họ tên
- **URL**: `POST /profile`
- **Input**:
  - `fullName`
- **Kết quả**:
  - Cập nhật `users.full_name`
  - Trả về trang `/profile` với thông báo `flash`

### A3. Đổi mật khẩu
- **URL**: `POST /change-password`
- **Input**:
  - `oldPassword`
  - `newPassword`
  - `confirm`
- **Business rules**:
  - `newPassword` tối thiểu 6 ký tự
  - `confirm` phải trùng `newPassword`
  - `oldPassword` phải đúng (BCrypt)
- **Kết quả**:
  - Update `users.password_hash`
  - Bắt buộc **logout** và yêu cầu đăng nhập lại

---

## B) Admin quản lý User

### B1. Trang quản lý users
- **URL**: `GET /admin/users`
- **Yêu cầu**: role phải là `ADMIN`
- **Hiển thị danh sách**:
  - ID, Email, Full name, Role, Status

### B2. Đổi role cho user
- **URL**: `POST /admin/users/role`
- **Input**:
  - `userId`
  - `role` (ADMIN/LIBRARIAN/USER)
- **Kết quả**:
  - Cập nhật `users.role_id`
  - Thông báo `flash`

### B3. Khóa / mở khóa user
- **URL**: `POST /admin/users/status`
- **Input**:
  - `userId`
  - `status` (ACTIVE/LOCKED)
- **Kết quả**:
  - Cập nhật `users.status`
  - User bị LOCKED sẽ **không login được**

---

## C) Reservation (Đặt trước)

### C1. Điều kiện đặt trước
- Chỉ cho đặt trước khi `book.quantity <= 0`
- Không cho đặt trùng nếu đã có reservation `WAITING/NOTIFIED`

### C2. Tạo đặt trước
- **URL**: `POST /reservations/create`
- **Input**:
  - `bookId`
- **Luồng UI**:
  - Trên trang `GET /borrow/request`:
    - Nếu sách còn (`quantity > 0`) hiện nút `Gửi yêu cầu`
    - Nếu sách hết (`quantity == 0`) hiện nút `Đặt trước`

### C3. Xem danh sách đặt trước
- **URL**: `GET /reservations`
- **Kết quả**:
  - USER: chỉ thấy đặt trước của mình
  - STAFF (ADMIN/LIBRARIAN): thấy tất cả

### C4. Hủy đặt trước
- **URL**: `GET /reservations/cancel?id=...`
- **Điều kiện**:
  - USER chỉ hủy được reservation của chính mình
  - Chỉ hủy khi status là `WAITING/NOTIFIED`

---

## D) Shipping (GHTK)

### D1. Điều kiện tạo giao hàng
- Chỉ staff (ADMIN/LIBRARIAN) được thao tác
- Chỉ tạo shipment khi BorrowRecord đang `BORROWED`
- 1 BorrowRecord chỉ có tối đa 1 Shipment

### D2. Tạo shipment
- **URL**:
  - `GET /shipping/new?borrowId=...` (form)
  - `POST /shipping/new` (submit)
- **Input**:
  - `borrowId`
  - `address`
  - `phone`
- **Kết quả**:
  - Tạo record trong `shipments`
  - Sinh `tracking_code`
    - Nếu chưa cấu hình token GHTK ⇒ `MOCK-...`
    - Nếu có token ⇒ gọi API tạo đơn (skeleton)

### D3. Xem danh sách shipment
- **URL**: `GET /shipping`
- Hiển thị:
  - borrow id, tracking code, status, address, phone

### D4. Refresh trạng thái
- **URL**: `GET /shipping/status?id=...`
- Kết quả:
  - Gọi `GHTKService.getStatus(trackingCode)`
  - Update `shipments.status`

---

## 4) Luồng Borrow/Return (liên quan đến Shipping)

### 4.1 User gửi yêu cầu mượn
- `GET /borrow/request` chọn sách còn hàng ⇒ `POST /borrow/request`
- Tạo `borrow_records` với status `REQUESTED`

### 4.2 Librarian/Admin duyệt
- `GET /borrow` thấy REQUESTED ⇒ `GET /borrow/approve?id=...`
- Chuyển `borrow_records.status` ⇒ `BORROWED`
- Trừ `books.quantity = quantity - 1`

### 4.3 Tạo shipping (nếu giao)
- Khi đã BORROWED, staff có thể bấm `Tạo giao hàng` trên `/borrow`
- Điều hướng qua `/shipping/new?borrowId=...`

### 4.4 Trả sách
- Staff bấm `Đánh dấu trả`
- Update `borrow_records` ⇒ `RETURNED`
- Tăng `books.quantity = quantity + 1`
- Tính phạt nếu trễ hạn

---

## 5) Quên mật khẩu (Forgot Password – Gmail)

### 5.1 Luồng
- `GET /forgot-password` nhập email ⇒ `POST /forgot-password`
- Hệ thống:
  - tạo token
  - hash token (SHA-256)
  - lưu `password_reset_tokens`
  - gửi email link reset

### 5.2 Reset
- `GET /reset-password?token=...`
- `POST /reset-password`
  - token hợp lệ, còn hạn, chưa dùng
  - update password (BCrypt)
  - token đánh dấu used

### 5.3 Cấu hình SMTP
Trong Tomcat run configuration:
- `LBMS_SMTP_USERNAME` (gmail)
- `LBMS_SMTP_PASSWORD` (App Password)
- `LBMS_APP_BASE_URL` (vd: `http://localhost:8080/lbms`)

---

## 6) Checklist vận hành (để bạn không bị "không thấy")

Sau mỗi lần update code:
1. `mvn clean package`
2. **Redeploy / Restart Tomcat** trong IntelliJ
3. Nếu JSP không update:
   - xóa folder `CATALINA_BASE/work` của IntelliJ Tomcat rồi chạy lại

---

## 7) Bản đồ trang theo Role (tóm tắt)

### USER
- `/books`
- `/borrow`, `/borrow/request`
- `/reservations`
- `/profile`
- `/forgot-password`

### LIBRARIAN
- `/books` + CRUD
- `/borrow` (duyệt/trả)
- `/shipping`
- `/reservations`
- `/profile`

### ADMIN
- Tất cả của Librarian
- `/admin/users`

---

## 8) Ghi chú triển khai
- LBMS hiện đang chạy theo **Tomcat 10.x + Jakarta Servlet 6**
- JDBC driver MySQL nằm trong WAR (`WEB-INF/lib/mysql-connector-j-8.4.0.jar`)

