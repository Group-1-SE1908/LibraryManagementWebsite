# ✅ FEATURES: Edit & Delete Reply (Thủ Thư)

## 🎯 Tính năng mới

Thủ thư (admin) giờ có thể **sửa** và **xóa** reply của chính mình bên phía quản lý phản hồi.

### **1. Chỉnh sửa Reply ✓**
- **Nút:** "Sửa" (màu vàng)
- **Hoạt động:** Click → Modal form hiển thị → Sửa nội dung → "Lưu thay đổi"
- **Kiểm soát:** Chỉ thủ thư là chủ reply mới có nút này
- **Lưu vào DB:** Table `CommentReply` column `content`

### **2. Xóa Reply ✓**
- **Nút:** "Xóa" (màu đỏ)
- **Hoạt động:** Click → Confirm dialog → Xóa khỏi DB
- **Kiểm soát:** Chỉ thủ thư là chủ reply mới có nút này
- **DB:** Delete record từ table `CommentReply`

---

## 🚀 Implementation Details

### **Backend (Java)**

#### **CommentReplyDAO - 3 methods mới:**
```java
// 1. Cập nhật reply
public boolean updateReply(long replyId, String content, int adminId)

// 2. Xóa reply
public boolean deleteReply(long replyId, int adminId)

// 3. Tìm reply theo ID
public CommentReply findById(long replyId)
```

#### **AdminFeedbackController - 2 actions mới:**
```java
// 1. POST action=editReply
// - Kiểm tra reply thuộc về user hiện tại
// - Gọi replyDAO.updateReply()
// - Redirect về feedback detail page

// 2. POST action=deleteReply
// - Kiểm tra reply thuộc về user hiện tại
// - Gọi replyDAO.deleteReply()
// - Redirect về feedback detail page
```

### **Frontend (JSP)**

#### **feedback_detail.jsp - Cập nhật hiển thị:**
```jsp
<!-- Kiểm tra nếu reply thuộc về user hiện tại -->
<c:if test="${r.adminId == sessionScope.currentUser.id}">
    <!-- Hiển thị nút Sửa & Xóa -->
</c:if>

<!-- Modal form để chỉnh sửa -->
<script>
function editReplyModal(replyId, commentId, content) {
    // Tạo modal với textarea
    // Form POST action=editReply
}
</script>
```

---

## 📋 Cách Test

### **Test 1: Sửa Reply**
1. **Login thủ thư** → `/admin/feedback?action=view&id=X`
2. **Xem reply của mình** → Nút "Sửa" (vàng)
3. **Click "Sửa"** → Modal hiển thị với nội dung hiện tại
4. **Chỉnh sửa nội dung** → Click "Lưu thay đổi"
5. ✅ **Kỳ vọng:** 
   - Reply được update trong DB
   - Trang reload, hiển thị nội dung mới
   - Nếu login bằng user khác, sẽ không thấy nút "Sửa"

### **Test 2: Xóa Reply**
1. **Login thủ thư** → `/admin/feedback?action=view&id=X`
2. **Xem reply của mình** → Nút "Xóa" (đỏ)
3. **Click "Xóa"** → Confirm dialog
4. **Click xác nhận**
5. ✅ **Kỳ vọng:**
   - Reply bị xóa khỏi DB
   - Trang reload, reply không còn hiển thị
   - Section "Phản hồi từ thủ thư" hiển thị "Chưa có phản hồi..."

### **Test 3: Security Check**
1. **Login user A (thủ thư)** → Gửi reply
2. **Logout → Login user B (thủ thư khác)**
3. **Vào feedback detail của reply của A**
4. ✅ **Kỳ vọng:** Không thấy nút "Sửa" & "Xóa"
5. **Nếu modify request URL trực tiếp:**
   ```
   POST /admin/feedback
   action=deleteReply&replyId=X&commentId=Y
   ```
6. ✅ **Kỳ vọng:** Server kiểm tra `adminId == currentUser.id`, từ chối nếu không match

---

## 📝 Files Changed

### **Java:**
- ✅ `src/main/java/com/lbms/dao/CommentReplyDAO.java`
  - Thêm `updateReply(long, String, int)`
  - Thêm `deleteReply(long, int)`
  - Thêm `findById(long)`

- ✅ `src/main/java/com/lbms/controller/AdminFeedbackController.java`
  - Thêm action "editReply"
  - Thêm action "deleteReply"

### **JSP:**
- ✅ `src/main/webapp/WEB-INF/views/admin/library/feedback_detail.jsp`
  - Thêm import `fn:escapeXml`
  - Hiển thị nút "Sửa" & "Xóa" (nếu reply thuộc user)
  - Thêm modal form để sửa reply
  - Thêm script `editReplyModal()`

---

## 🔒 Security

**Bảo vệ:**
1. **DB level:** WHERE clause kiểm tra `admin_id = ?`
2. **Java level:** Kiểm tra `existing.getAdminId() == (int) currentUser.getId()`
3. **JSP level:** `<c:if test="${r.adminId == sessionScope.currentUser.id}">`

Nếu user cố gắng sửa/xóa reply của người khác:
- DB: WHERE clause không match → update/delete 0 rows
- Java: Check `existing.getAdminId()` không match → không execute

---

## 🚀 Build & Deploy

```bash
# 1. Build
mvn clean package -DskipTests

# 2. Deploy WAR
# Copy target/lbms.war to Tomcat/webapps/

# 3. Restart Tomcat

# 4. Test 2 scenarios ở trên
```

---

## ✅ Checklist

- [ ] Build project không có error
- [ ] Login thủ thư → `/admin/feedback?action=view&id=1`
- [ ] Nút "Sửa" & "Xóa" hiển thị trên reply của mình
- [ ] Click "Sửa" → Modal hiển thị → Sửa → "Lưu thay đổi" → Reload page
- [ ] Click "Xóa" → Confirm → Reply biến mất
- [ ] Login user khác → Không thấy nút "Sửa" & "Xóa"

---

**Status:** ✅ ALL FEATURES IMPLEMENTED

**Next:** Build & test 2 use cases ở trên
