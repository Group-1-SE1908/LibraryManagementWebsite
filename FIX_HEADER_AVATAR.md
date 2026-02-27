## 🔧 Hướng dẫn Fix Avatar Không Hiển Thị Ở Header

### ❌ **Vấn đề:**
- Avatar không hiển thị ở header (chỉ hiển thị chữ cái đầu tiên)
- Bất cứ ảnh nào upload cũng bị lỗi

### ✅ **Nguyên nhân:**
Avatar được lưu với prefix `uploads/` (ví: `uploads/1234_avatar.jpg`)
Nhưng header.jsp sử dụng: `/uploads/${sessionScope.currentUser.avatar}`
Kết quả: URL sai `/uploads/uploads/1234_avatar.jpg` ❌

---

## 🔨 **Giải pháp (4 bước):**

### **Bước 1: Chạy SQL Migration**
Mở SQL Server Management Studio và chạy:

```sql
UPDATE [User]
SET avatar = 'uploads/' + avatar
WHERE avatar IS NOT NULL 
  AND avatar != ''
  AND avatar NOT LIKE 'uploads/%'
  AND avatar NOT LIKE 'null'
  AND avatar NOT LIKE '%/%';

-- Nếu có avatar bị trùng uploads/, xóa thừa
UPDATE [User]
SET avatar = SUBSTRING(avatar, 9, LEN(avatar))
WHERE avatar LIKE 'uploads/uploads/%';
```

### **Bước 2: Clean Build**
```cmd
cd d:\FPT-KTPM\ki5\SWP301\Project_LBMS\LibraryManagementWebsite
mvn clean package -DskipTests
```

### **Bước 3: Restart Tomcat**
- Dừng Tomcat Server
- Xóa folder `target/` nếu cần
- Start lại Tomcat

### **Bước 4: Test Avatar**
1. Đăng nhập vào hệ thống
2. Kiểm tra avatar ở header (phía trên bên phải)
3. Vào Profile → Upload ảnh mới
4. Refresh trang → Avatar phải hiển thị ✓

---

## 📝 **Các files đã được sửa:**

✅ **header.jsp**
- Thay đổi URL từ `/uploads/${avatar}` → `/${avatar}`
- Thêm fallback hiển thị chữ cái nếu ảnh load fail
- Cải thiện CSS với gradient màu

✅ **migrate_avatars.sql**
- Script toàn diện để migrate tất cả avatars
- Xử lý trường hợp trùng `uploads/uploads/`

---

## ⚠️ **Lưu ý:**
- **Avatar mới sẽ tự động lưu đúng format** (ProfileController đã sửa)
- **Avatar cũ cần chạy SQL để fix** 
- Nếu vẫn không hoạt động: check folder `/uploads/` có file avatar không

---

## 🆘 **Nếu vẫn bị lỗi:**
1. Kiểm tra console Tomcat có lỗi gì không
2. Kiểm tra file avatar có tồn tại trong `/src/main/webapp/uploads/` không
3. Xóa browser cache (Ctrl+Shift+Del) rồi refresh
4. Kiểm tra database - column avatar có giá trị gì
