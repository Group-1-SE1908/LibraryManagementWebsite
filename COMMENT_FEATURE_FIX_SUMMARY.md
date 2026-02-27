## Tóm tắt các lỗi đã được sửa trong Comment Feature

### 1. **CommentDAO.java**
   - ✅ Thêm import `java.util.ArrayList`
   - ✅ Sửa lỗi SQL trong `updateComment` - xóa câu "select * from comment" thừa
   - ✅ Thêm `throws Exception` vào phương thức `updateComment`
   - ✅ Sửa `insertComment` để thêm `created_at` và `status` vào câu INSERT
   - ✅ Sửa `getCommentsByBook` để lấy `created_at` từ database

### 2. **CommentController.java**
   - ✅ Sửa lỗi sử dụng `user.getId()` thay vì `user.getUserId()` (vì User model không có method `getUserId`)
   - ✅ Sửa cách kiểm tra role - sử dụng `user.getRole().getName()` thay vì cast trực tiếp
   - ✅ Thêm null check cho role object
   - ✅ Sửa cách cast user ID từ `long` sang `int` khi cần

### 3. **BookController.java**
   - ✅ Thêm import `CommentDAO`
   - ✅ Thêm `commentDAO` field vào class
   - ✅ Khởi tạo `commentDAO` trong `init()` method
   - ✅ Sửa `handleDetail` để lấy comments từ database và đặt vào request attribute

### 4. **book_detail.jsp**
   - ✅ Sửa cách lấy comments - dùng request attribute thay vì gọi DAO trực tiếp trong JSP
   - ✅ Sửa cách kiểm tra user role - sử dụng `sessionScope.user.role.name` thay vì `sessionScope.user.role`
   - ✅ Sửa cách kiểm tra user ID - sử dụng `sessionScope.user.id` thay vì `sessionScope.user.userId`
   - ✅ Sửa hàm JavaScript `editComment` - sử dụng string concatenation thay vì template literal để tránh lỗi JSP
   - ✅ Thêm proper escaping cho HTML entities trong hidden input fields

### 5. **comments_list.jsp**
   - ✅ Tạo file view riêng cho hiển thị comments (tùy chọn)

## Các feature hoạt động:
1. ✅ **Thêm comment** - Người dùng đã đăng nhập có thể thêm comment với rating (1-5 sao)
2. ✅ **Hiển thị comments** - Hiển thị comments VISIBLE theo thứ tự mới nhất trước, kèm theo thông tin người dùng
3. ✅ **Sửa comment** - Chỉ chủ sở hữu comment hoặc admin/librarian mới có thể sửa
4. ✅ **Xóa comment** - Chỉ chủ sở hữu hoặc admin/librarian mới có thể xóa (soft delete, đánh dấu DELETED)

## Yêu cầu Database:
Đảm bảo bảng `Comment` có các cột:
- `comment_id` (primary key)
- `book_id` (foreign key)
- `user_id` (foreign key)
- `content` (text)
- `rating` (int, 1-5)
- `status` (varchar, 'VISIBLE' hoặc 'DELETED')
- `created_at` (timestamp, default GETDATE())
- `updated_at` (timestamp, nullable)
- `deleted_at` (timestamp, nullable)
