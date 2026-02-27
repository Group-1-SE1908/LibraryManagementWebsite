## Hướng dẫn Fix Avatar Comments

### Vấn đề:
- Avatar không hiển thị trong comments vì đường dẫn sai
- Database lưu avatar chỉ có tên file (ví: `1772042030188_avatar.jpg`)
- Nhưng URL cần `uploads/1772042030188_avatar.jpg`

### Giải pháp:

#### 1. Cập nhật Database (Migration)
Chạy SQL script này trong SQL Server Management Studio:

```sql
UPDATE [User]
SET avatar = 'uploads/' + avatar
WHERE avatar IS NOT NULL 
  AND avatar != ''
  AND avatar NOT LIKE 'uploads/%'
  AND avatar NOT LIKE 'null';
```

#### 2. Rebuild Project
Chạy command:
```cmd
cd d:\FPT-KTPM\ki5\SWP301\Project_LBMS\LibraryManagementWebsite
mvn clean package -DskipTests
```

#### 3. Redeploy Application
- Restart Tomcat server hoặc
- Click Deploy/Run trong IDE

#### 4. Cập nhật Avatar Mới
Khi upload avatar mới, nó sẽ tự động lưu với prefix `uploads/`

### Các files đã được sửa:
✅ **web.xml** - Thêm servlet mapping cho `/uploads/*`
✅ **ProfileController.java** - Lưu avatar với prefix `uploads/`
✅ **migrate_avatars.sql** - Script để cập nhật avatars cũ

### Sau khi hoàn tất:
- Avatar cũ sẽ hiển thị trong comments ✓
- Avatar mới sẽ tự động hiển thị ✓
- Nếu avatar load fail, sẽ hiển thị chữ cái đầu tiên ✓
