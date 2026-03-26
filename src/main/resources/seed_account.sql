USE
LibraryDB;
GO

    SET NOCOUNT ON;
    SET
XACT_ABORT ON;

BEGIN TRY
BEGIN
TRANSACTION;

        IF
OBJECT_ID('Role', 'U') IS NULL
            OR OBJECT_ID('[User]', 'U') IS NULL
            OR OBJECT_ID('Book', 'U') IS NULL
            OR OBJECT_ID('borrow_records', 'U') IS NULL
BEGIN
            THROW
50001, N'Vui lòng chạy schema.sql trước khi chạy seed_account.sql.', 1;
END;

        DECLARE
@defaultPasswordHash VARCHAR(255) = '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa';
        DECLARE
@today DATE = CAST(GETDATE() AS DATE);

        -- Đảm bảo role cơ bản tồn tại để script có thể chạy lại an toàn.
        IF
NOT EXISTS (SELECT 1 FROM Role WHERE UPPER(role_name) = 'ADMIN')
            INSERT INTO Role (role_name) VALUES ('ADMIN');

        IF
NOT EXISTS (SELECT 1 FROM Role WHERE UPPER(role_name) = 'LIBRARIAN')
            INSERT INTO Role (role_name) VALUES ('LIBRARIAN');

        IF
NOT EXISTS (SELECT 1 FROM Role WHERE UPPER(role_name) = 'MEMBER')
            INSERT INTO Role (role_name) VALUES ('MEMBER');

        DECLARE
@adminRoleId INT = (SELECT TOP 1 role_id FROM Role WHERE UPPER(role_name) = 'ADMIN');
        DECLARE
@librarianRoleId INT = (SELECT TOP 1 role_id FROM Role WHERE UPPER(role_name) = 'LIBRARIAN');
        DECLARE
@memberRoleId INT = (SELECT TOP 1 role_id FROM Role WHERE UPPER(role_name) = 'MEMBER');

        -- Tài khoản demo. Mật khẩu chung: 123456
        IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'admin@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('admin@gmail.com', @defaultPasswordHash, N'Nguyễn Văn A', '0901000001', N'1 Lý Thường Kiệt, Hà Nội', 'ACTIVE', @adminRoleId, 'uploads/admin.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Nguyễn Văn A', phone = '0901000001', address = N'1 Lý Thường Kiệt, Hà Nội', status = 'ACTIVE', role_id = @adminRoleId
WHERE email = 'admin@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'librarian@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('librarian@gmail.com', @defaultPasswordHash, N'Trần Thị B', '0901000002', N'15 Pasteur, Quận 3, TP. Hồ Chí Minh', 'ACTIVE', @librarianRoleId, 'uploads/lib.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Trần Thị B', phone = '0901000002', address = N'15 Pasteur, Quận 3, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @librarianRoleId
WHERE email = 'librarian@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'user@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('user@gmail.com', @defaultPasswordHash, N'Lê Văn C', '0901000003', N'12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Lê Văn C', phone = '0901000003', address = N'12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @memberRoleId
WHERE email = 'user@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member2@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('member2@gmail.com', @defaultPasswordHash, N'Phạm Thu Trang', '0901000004', N'45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Phạm Thu Trang', phone = '0901000004', address = N'45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @memberRoleId
WHERE email = 'member2@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member3@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('member3@gmail.com', @defaultPasswordHash, N'Võ Minh Khôi', '0901000005', N'88 Hùng Vương, Hải Châu, Đà Nẵng', 'ACTIVE', @memberRoleId, 'uploads/user.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Võ Minh Khôi', phone = '0901000005', address = N'88 Hùng Vương, Hải Châu, Đà Nẵng', status = 'ACTIVE', role_id = @memberRoleId
WHERE email = 'member3@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member4@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('member4@gmail.com', @defaultPasswordHash, N'Ngô Hải Yến', '0901000006', N'25 Trần Phú, Nha Trang, Khánh Hòa', 'ACTIVE', @memberRoleId, 'uploads/user.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Ngô Hải Yến', phone = '0901000006', address = N'25 Trần Phú, Nha Trang, Khánh Hòa', status = 'ACTIVE', role_id = @memberRoleId
WHERE email = 'member4@gmail.com';

-- ── Thành viên bổ sung ────────────────────────────────────────────
IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member5@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
VALUES ('member5@gmail.com', @defaultPasswordHash, N'Đặng Thị Lan', '0901000007', N'33 Lê Lợi, Quận 1, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png', 200000);
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Đặng Thị Lan', phone = '0901000007', address = N'33 Lê Lợi, Quận 1, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @memberRoleId, wallet_balance = 200000
WHERE email = 'member5@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member6@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
VALUES ('member6@gmail.com', @defaultPasswordHash, N'Bùi Quang Huy', '0901000008', N'17 Bạch Đằng, Hải Châu, Đà Nẵng', 'ACTIVE', @memberRoleId, 'uploads/user.png', 500000);
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Bùi Quang Huy', phone = '0901000008', address = N'17 Bạch Đằng, Hải Châu, Đà Nẵng', status = 'ACTIVE', role_id = @memberRoleId, wallet_balance = 500000
WHERE email = 'member6@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member7@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
VALUES ('member7@gmail.com', @defaultPasswordHash, N'Trương Ngọc Ánh', '0901000009', N'56 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', 'ACTIVE', @memberRoleId, 'uploads/user.png', 150000);
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Trương Ngọc Ánh', phone = '0901000009', address = N'56 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', status = 'ACTIVE', role_id = @memberRoleId, wallet_balance = 150000
WHERE email = 'member7@gmail.com';

IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member8@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('member8@gmail.com', @defaultPasswordHash, N'Đinh Văn Tùng', '0901000010', N'9 Lý Tự Trọng, Ninh Kiều, Cần Thơ', 'LOCKED', @memberRoleId, 'uploads/user.png');
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Đinh Văn Tùng', phone = '0901000010', address = N'9 Lý Tự Trọng, Ninh Kiều, Cần Thơ', status = 'LOCKED', role_id = @memberRoleId
WHERE email = 'member8@gmail.com';

-- ── Thủ thư thứ 2 ────────────────────────────────────────────────
IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'librarian2@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('librarian2@gmail.com', @defaultPasswordHash, N'Nguyễn Thị Minh', '0901000011', N'22 Lê Duẩn, Quận 1, TP. Hồ Chí Minh', 'ACTIVE', @librarianRoleId, 'uploads/user.png');
END;
UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Nguyễn Thị Minh', phone = '0901000011', address = N'22 Lê Duẩn, Quận 1, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @librarianRoleId
WHERE email = 'librarian2@gmail.com';

-- ── Thành viên trạng thái PENDING (chờ xác thực email) ──────────────
IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member9@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
VALUES ('member9@gmail.com', @defaultPasswordHash, N'Lý Thanh Sơn', '0901000012', N'30 Hai Bà Trưng, Quận 1, TP. Hồ Chí Minh', 'PENDING', @memberRoleId, 'uploads/user.png');
END;
UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Lý Thanh Sơn', phone = '0901000012', address = N'30 Hai Bà Trưng, Quận 1, TP. Hồ Chí Minh', status = 'PENDING', role_id = @memberRoleId
WHERE email = 'member9@gmail.com';

-- ── Thành viên bị cấm bình luận (comment_banned_until) ─────────────
IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member10@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, comment_banned_until)
VALUES ('member10@gmail.com', @defaultPasswordHash, N'Hoàng Văn Đức', '0901000013', N'45 Đinh Tiên Hoàng, Bình Thạnh, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png', DATEADD(DAY, 7, GETDATE()));
END;
UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Hoàng Văn Đức', phone = '0901000013', address = N'45 Đinh Tiên Hoàng, Bình Thạnh, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @memberRoleId, comment_banned_until = DATEADD(DAY, 7, GETDATE())
WHERE email = 'member10@gmail.com';

-- ── Thành viên bị khóa tạm thời (banned_until) ─────────────────────
IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member11@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, banned_until,
                    comment_banned_until)
VALUES ('member11@gmail.com', @defaultPasswordHash, N'Vũ Thị Thu', '0901000014', N'8 Nguyễn Thị Minh Khai, Đa Kao, Quận 1, TP. Hồ Chí Minh', 'LOCKED', @memberRoleId, 'uploads/user.png', DATEADD(DAY, 14, GETDATE()), DATEADD(DAY, 14, GETDATE()));
END;
UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Vũ Thị Thu', phone = '0901000014', address = N'8 Nguyễn Thị Minh Khai, Đa Kao, Quận 1, TP. Hồ Chí Minh', status = 'LOCKED', role_id = @memberRoleId, banned_until = DATEADD(DAY, 14, GETDATE()), comment_banned_until = DATEADD(DAY, 14, GETDATE())
WHERE email = 'member11@gmail.com';

-- ── Thành viên mới có ví 200.000đ ──────────────────────────────────
IF
NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member12@gmail.com')
BEGIN
INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
VALUES ('member12@gmail.com', @defaultPasswordHash, N'Phan Thị Hồng Nhung', '0901000015', N'72 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png', 200000);
END;

UPDATE [User]
SET password = @defaultPasswordHash, full_name = N'Phan Thị Hồng Nhung', phone = '0901000015', address = N'72 Nguyễn Huệ, Quận 1, TP. Hồ Chí Minh', status = 'ACTIVE', role_id = @memberRoleId, wallet_balance = 200000
WHERE email = 'member12@gmail.com';

-- Cập nhật member8: thêm banned_until để test tính năng ban có thời hạn
UPDATE [User]
SET banned_until = DATEADD(DAY, 30, GETDATE())
WHERE email = 'member8@gmail.com';

DECLARE
@userId INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'user@gmail.com');
        DECLARE
@member2Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member2@gmail.com');
        DECLARE
@member3Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member3@gmail.com');
        DECLARE
@member4Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member4@gmail.com');
        DECLARE
@member5Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member5@gmail.com');
        DECLARE
@member6Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member6@gmail.com');
        DECLARE
@member7Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member7@gmail.com');
        DECLARE
@member8Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member8@gmail.com');
        DECLARE
@adminUserId INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'admin@gmail.com');
        DECLARE
@lib2Id INT     = (SELECT TOP 1 user_id FROM [User] WHERE email = 'librarian2@gmail.com');
        DECLARE
@member9Id INT  = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member9@gmail.com');
        DECLARE
@member10Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member10@gmail.com');
        DECLARE
@member11Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member11@gmail.com');
        DECLARE
@member12Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member12@gmail.com');

        -- Seed thÃªm sáº¡ch má»›i Ä‘á»ƒ hiá»ƒn thá»‹ kho sáº£n pháº©m demo.
        -- Seed sách mới từ Open Library (dữ liệu thực).
        -- 3 sách ban đầu đã được tạo bởi schema.sql:
        --   9780132350884  Clean Code              (Lập trình & Công nghệ)
        --   9780451524935  Nineteen Eighty-Four    (Văn học thế giới)
        --   9780156012195  The Little Prince       (Văn học thế giới)

        DECLARE
@catTech   INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Lập trình & Công nghệ');
        DECLARE
@catLit    INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Văn học thế giới');
        DECLARE
@catSkills INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Phát triển bản thân');
        DECLARE
@catSci    INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Khoa học & Tự nhiên');
        DECLARE
@catHist   INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Lịch sử & Văn minh');
        DECLARE
@catEcon   INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Kinh tế & Kinh doanh');
        DECLARE
@catSciFi  INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Khoa học viễn tưởng');
        DECLARE
@catKids   INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Thiếu nhi');

        -- ── Lập trình & Công nghệ ─────────────────────────────────────────
        IF
@catTech IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780135957059')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('The Pragmatic Programmer', 'David Thomas, Andy Hunt', @catTech, 320000, 6, 'ISBN-9780135957059', 'https://covers.openlibrary.org/b/id/10143650-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780201633610')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Design Patterns', 'Erich Gamma, Richard Helm, Ralph Johnson, John Vlissides', @catTech, 380000, 5, 'ISBN-9780201633610', 'https://covers.openlibrary.org/b/id/10827044-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780262033848')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Introduction to Algorithms', 'Thomas H. Cormen, Charles E. Leiserson, Ronald L. Rivest, Clifford Stein', @catTech, 450000, 4, 'ISBN-9780262033848', 'https://covers.openlibrary.org/b/id/11106524-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780596517748')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('JavaScript: The Good Parts', 'Douglas Crockford', @catTech, 280000, 7, 'ISBN-9780596517748', 'https://covers.openlibrary.org/b/id/2536428-M.jpg');
END;

        -- ── Văn học thế giới ──────────────────────────────────────────────
        IF
@catLit IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780062315007')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('The Alchemist', 'Paulo Coelho', @catLit, 108000, 11, 'ISBN-9780062315007', 'https://covers.openlibrary.org/b/id/15091614-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780060883287')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('One Hundred Years of Solitude', 'Gabriel García Márquez', @catLit, 145000, 9, 'ISBN-9780060883287', 'https://covers.openlibrary.org/b/isbn/9780060883287-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780141439518')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Pride and Prejudice', 'Jane Austen', @catLit, 85000, 14, 'ISBN-9780141439518', 'https://covers.openlibrary.org/b/isbn/9780141439518-M.jpg');
END;

        -- ── Phát triển bản thân ───────────────────────────────────────────
        IF
@catSkills IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780671027032')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('How to Win Friends and Influence People', 'Dale Carnegie', @catSkills, 155000, 14, 'ISBN-9780671027032', 'https://covers.openlibrary.org/b/isbn/9780671027032-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780735211292')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Atomic Habits', 'James Clear', @catSkills, 178000, 10, 'ISBN-9780735211292', 'https://covers.openlibrary.org/b/isbn/9780735211292-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780743269513')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('The 7 Habits of Highly Effective People', 'Stephen R. Covey', @catSkills, 168000, 8, 'ISBN-9780743269513', 'https://covers.openlibrary.org/b/isbn/9780743269513-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780374533557')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Thinking, Fast and Slow', 'Daniel Kahneman', @catSkills, 225000, 7, 'ISBN-9780374533557', 'https://covers.openlibrary.org/b/isbn/9780374533557-M.jpg');
END;

        -- ── Khoa học & Tự nhiên ───────────────────────────────────────────
        IF
@catSci IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780553380163')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('A Brief History of Time', 'Stephen Hawking', @catSci, 132000, 9, 'ISBN-9780553380163', 'https://covers.openlibrary.org/b/id/14589690-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780198788607')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('The Selfish Gene', 'Richard Dawkins', @catSci, 165000, 6, 'ISBN-9780198788607', 'https://covers.openlibrary.org/b/isbn/9780198788607-M.jpg');
END;

        -- ── Lịch sử & Văn minh ────────────────────────────────────────────
        IF
@catHist IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780062316097')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Sapiens: A Brief History of Humankind', 'Yuval Noah Harari', @catHist, 210000, 8, 'ISBN-9780062316097', 'https://covers.openlibrary.org/b/id/14369194-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780393061314')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Guns, Germs, and Steel', 'Jared Diamond', @catHist, 200000, 6, 'ISBN-9780393061314', 'https://covers.openlibrary.org/b/isbn/9780393061314-M.jpg');
END;

        -- ── Kinh tế & Kinh doanh ──────────────────────────────────────────
        IF
@catEcon IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9781612680194')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Rich Dad Poor Dad', 'Robert T. Kiyosaki', @catEcon, 175000, 11, 'ISBN-9781612680194', 'https://covers.openlibrary.org/b/isbn/9781612680194-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780307887894')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('The Lean Startup', 'Eric Ries', @catEcon, 195000, 7, 'ISBN-9780307887894', 'https://covers.openlibrary.org/b/isbn/9780307887894-M.jpg');
END;

        -- ── Khoa học viễn tưởng ───────────────────────────────────────────
        IF
@catSciFi IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780804139021')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('The Martian', 'Andy Weir', @catSciFi, 155000, 8, 'ISBN-9780804139021', 'https://covers.openlibrary.org/b/id/14641755-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780441013593')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Dune', 'Frank Herbert', @catSciFi, 145000, 7, 'ISBN-9780441013593', 'https://covers.openlibrary.org/b/isbn/9780441013593-M.jpg');
END;

        -- ── Thiếu nhi ─────────────────────────────────────────────────────
        IF
@catKids IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780590353427')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', @catKids, 145000, 16, 'ISBN-9780590353427', 'https://covers.openlibrary.org/b/isbn/9780590353427-M.jpg');

            IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780141439761')
                INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
                VALUES ('Alice''s Adventures in Wonderland', 'Lewis Carroll', @catKids, 75000, 13, 'ISBN-9780141439761', 'https://covers.openlibrary.org/b/isbn/9780141439761-M.jpg');
END;

        -- ── Biến sách cho borrow / comment / reservation demo ─────────────
        -- (Tên biến giữ nguyên để không phải sửa toàn bộ phần demo bên dưới)
        DECLARE
@bookJava    INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780132350884'); -- Clean Code
        DECLARE
@bookSql     INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780451524935'); -- Nineteen Eighty-Four
        DECLARE
@bookTatDen  INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780156012195'); -- The Little Prince
        DECLARE
@bookPython  INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780735211292'); -- Atomic Habits
        DECLARE
@bookMicro   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780062316097'); -- Sapiens
        DECLARE
@bookKieu    INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780590353427'); -- Harry Potter
        DECLARE
@bookDeMen   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780062315007'); -- The Alchemist
        DECLARE
@bookSkills  INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780671027032'); -- How to Win Friends
        DECLARE
@bookToan    INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780262033848'); -- Introduction to Algorithms
        DECLARE
@bookReact   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780743269513'); -- The 7 Habits
        DECLARE
@bookClean   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780201633610'); -- Design Patterns
        DECLARE
@bookDocker  INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780307887894'); -- The Lean Startup
        DECLARE
@bookSoDo    INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780060883287'); -- One Hundred Years of Solitude
        DECLARE
@bookChiPheo INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780804139021'); -- The Martian
        DECLARE
@book7Habits INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9781612680194'); -- Rich Dad Poor Dad
        DECLARE
@bookToeic   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780553380163'); -- A Brief History of Time

        IF
@bookJava IS NULL OR @bookSql IS NULL OR @bookTatDen IS NULL
BEGIN
            THROW
50002, N'Không tìm thấy sách từ schema.sql. Vui lòng chạy schema.sql bản hiện tại trước.', 1;
END;

        -- =============================================
        -- Dọn dữ liệu demo cũ để script có thể chạy lại nhiều lần.
        -- =============================================
        IF
OBJECT_ID('shipments', 'U') IS NOT NULL
BEGIN
            DELETE
s
            FROM shipments s
            INNER JOIN borrow_records br ON br.id = s.borrow_record_id
            WHERE br.group_code LIKE 'DEMO-%';
END;

        IF
OBJECT_ID('renewal_requests', 'U') IS NOT NULL
BEGIN
            DELETE
rr
            FROM renewal_requests rr
            INNER JOIN borrow_records br ON br.id = rr.borrow_id
            WHERE br.group_code LIKE 'DEMO-%';
END;

        IF
OBJECT_ID('password_reset_token', 'U') IS NOT NULL
BEGIN
DELETE
FROM password_reset_token
WHERE token LIKE 'DEMO-%';
END;

DELETE
FROM borrow_records
WHERE group_code LIKE 'DEMO-%';

-- Dọn Comment, reservations, wallet_transaction, notifications của các tài khoản demo.
IF
OBJECT_ID('Comment', 'U') IS NOT NULL
BEGIN
DELETE
FROM Comment
WHERE user_id IN (
                  @userId, @member2Id, @member3Id, @member4Id,
                  @member5Id, @member6Id, @member7Id, @member8Id,
                  @member9Id, @member10Id, @member11Id
    );
END;

        IF
OBJECT_ID('reservations', 'U') IS NOT NULL
BEGIN
DELETE
FROM reservations
WHERE user_id IN (
                  @userId, @member2Id, @member3Id, @member4Id,
                  @member5Id, @member6Id, @member7Id, @member8Id,
                  @member9Id, @member10Id, @member11Id
    );
END;

        IF
OBJECT_ID('wallet_transaction', 'U') IS NOT NULL
BEGIN
DELETE
FROM wallet_transaction
WHERE reference LIKE 'DEMO-%';
END;

        IF
OBJECT_ID('notifications', 'U') IS NOT NULL
BEGIN
DELETE
FROM notifications
WHERE user_id IN (
                  @userId, @member2Id, @member3Id, @member4Id,
                  @member5Id, @member6Id, @member7Id, @member8Id,
                  @member9Id, @member10Id, @member11Id
    );
END;

        IF
OBJECT_ID('CartItem', 'U') IS NOT NULL
BEGIN
            DELETE
ci FROM CartItem ci
            INNER JOIN Cart c ON c.cart_id = ci.cart_id
            WHERE c.user_id IN (
                @userId, @member2Id, @member3Id, @member4Id,
                @member5Id, @member6Id, @member7Id, @member8Id,
                @member9Id, @member10Id, @member11Id
            );
END;

        IF
OBJECT_ID('LibrarianActivityLog', 'U') IS NOT NULL
BEGIN
DELETE
FROM LibrarianActivityLog
WHERE user_id IN (SELECT user_id
                  FROM [User]
WHERE email IN ('librarian@gmail.com'
    , 'librarian2@gmail.com')
    );
END;

        IF
OBJECT_ID('email_verification_token', 'U') IS NOT NULL
BEGIN
DELETE
FROM email_verification_token
WHERE user_id IN (
                  @member9Id, @member10Id, @member11Id
    );
END;

        -- =============================================
        -- Seed bộ đơn mượn/trả đa trạng thái.
        -- Khoá kiểm tra trùng: (group_code, book_id)
        -- =============================================
        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-REQ-001' AND book_id = @bookJava)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@userId,@bookJava,NULL,NULL,NULL,'REQUESTED',0,0,NULL,'ONLINE',1,50000,'DEMO-REQ-001',N'Lê Văn C','0901000003',N'12 Nguyễn Trãi',N'Chung cư Minh Khai',N'Phường 5',N'Quận 5',N'TP. Hồ Chí Minh',DATEADD(HOUR,-18,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-REQ-001' AND book_id = @bookSql)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@userId,@bookSql,NULL,NULL,NULL,'REQUESTED',0,0,NULL,'ONLINE',1,50000,'DEMO-REQ-001',N'Lê Văn C','0901000003',N'12 Nguyễn Trãi',N'Chung cư Minh Khai',N'Phường 5',N'Quận 5',N'TP. Hồ Chí Minh',DATEADD(HOUR,-18,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-BORROW-001' AND book_id = @bookTatDen)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@userId,@bookTatDen,DATEADD(DAY,-3,@today),DATEADD(DAY,4,@today),NULL,'BORROWED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-BORROW-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-3,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-RETURN-001' AND book_id = @bookSql)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@userId,@bookSql,DATEADD(DAY,-24,@today),DATEADD(DAY,-17,@today),DATEADD(DAY,-19,@today),'RETURNED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-RETURN-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-24,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-APPROVED-001' AND book_id = @bookJava)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member2Id,@bookJava,NULL,NULL,NULL,'APPROVED',0,0,NULL,'ONLINE',1,50000,'DEMO-APPROVED-001',N'Phạm Thu Trang','0901000004',N'45 Điện Biên Phủ',N'Tòa nhà Pearl Plaza',N'Phường 25',N'Bình Thạnh',N'TP. Hồ Chí Minh',DATEADD(HOUR,-10,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-APPROVED-001' AND book_id = @bookTatDen)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member2Id,@bookTatDen,NULL,NULL,NULL,'APPROVED',0,0,NULL,'ONLINE',1,50000,'DEMO-APPROVED-001',N'Phạm Thu Trang','0901000004',N'45 Điện Biên Phủ',N'Tòa nhà Pearl Plaza',N'Phường 25',N'Bình Thạnh',N'TP. Hồ Chí Minh',DATEADD(HOUR,-10,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-OVERDUE-001' AND book_id = @bookSql)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member2Id,@bookSql,DATEADD(DAY,-18,@today),DATEADD(DAY,-4,@today),NULL,'BORROWED',20000,0,NULL,'IN_PERSON',1,50000,'DEMO-OVERDUE-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-18,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-RECEIVED-001' AND book_id = @bookJava)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member3Id,@bookJava,DATEADD(DAY,-1,@today),DATEADD(DAY,6,@today),NULL,'RECEIVED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-RECEIVED-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-1,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-RENEW-001' AND book_id = @bookTatDen)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member3Id,@bookTatDen,DATEADD(DAY,-8,@today),DATEADD(DAY,1,@today),NULL,'RENEWAL_REQUESTED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-RENEW-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-8,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-LATE-UNPAID-001' AND book_id = @bookTatDen)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member4Id,@bookTatDen,DATEADD(DAY,-25,@today),DATEADD(DAY,-18,@today),DATEADD(DAY,-14,@today),'RETURNED',20000,0,NULL,'IN_PERSON',1,50000,'DEMO-LATE-UNPAID-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-25,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-LATE-PAID-001' AND book_id = @bookJava)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member4Id,@bookJava,DATEADD(DAY,-40,@today),DATEADD(DAY,-30,@today),DATEADD(DAY,-27,@today),'RETURNED',15000,1,NULL,'IN_PERSON',1,50000,'DEMO-LATE-PAID-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-40,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-REJECTED-001' AND book_id = @bookSql)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member4Id,@bookSql,NULL,NULL,NULL,'REJECTED',0,0,N'Độc giả đang còn phiếu mượn quá hạn cần xử lý trước.','ONLINE',1,50000,'DEMO-REJECTED-001',N'Ngô Hải Yến','0901000006',N'25 Trần Phú',N'Khách sạn mini đối diện biển',N'Phường Lộc Thọ',N'TP. Nha Trang',N'Khánh Hòa',DATEADD(HOUR,-7,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-CANCELLED-001' AND book_id = @bookJava)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member4Id,@bookJava,NULL,NULL,NULL,'CANCELLED',0,0,NULL,'ONLINE',1,50000,'DEMO-CANCELLED-001',N'Ngô Hải Yến','0901000006',N'25 Trần Phú',N'Khách sạn mini đối diện biển',N'Phường Lộc Thọ',N'TP. Nha Trang',N'Khánh Hòa',DATEADD(HOUR,-5,GETDATE()));

        -- member5
        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M5-BORROW-001' AND book_id = @bookPython)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member5Id,@bookPython,DATEADD(DAY,-5,@today),DATEADD(DAY,9,@today),NULL,'BORROWED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-M5-BORROW-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-5,GETDATE()));

        IF
@bookClean IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M5-BORROW-001' AND book_id = @bookClean)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member5Id,@bookClean,DATEADD(DAY,-5,@today),DATEADD(DAY,9,@today),NULL,'BORROWED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-M5-BORROW-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-5,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M5-RETURN-001' AND book_id = @bookSkills)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member5Id,@bookSkills,DATEADD(DAY,-35,@today),DATEADD(DAY,-22,@today),DATEADD(DAY,-25,@today),'RETURNED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-M5-RETURN-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-35,GETDATE()));

        IF
@bookReact IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M5-REQ-001' AND book_id = @bookReact)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member5Id,@bookReact,NULL,NULL,NULL,'REQUESTED',0,0,NULL,'ONLINE',1,50000,'DEMO-M5-REQ-001',N'Đặng Thị Lan','0901000007',N'33 Lê Lợi',N'Cao ốc văn phòng Harbour View',N'Phường Bến Nghé',N'Quận 1',N'TP. Hồ Chí Minh',DATEADD(HOUR,-2,GETDATE()));

        IF
@bookDocker IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M5-REQ-001' AND book_id = @bookDocker)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member5Id,@bookDocker,NULL,NULL,NULL,'REQUESTED',0,0,NULL,'ONLINE',1,50000,'DEMO-M5-REQ-001',N'Đặng Thị Lan','0901000007',N'33 Lê Lợi',N'Cao ốc văn phòng Harbour View',N'Phường Bến Nghé',N'Quận 1',N'TP. Hồ Chí Minh',DATEADD(HOUR,-2,GETDATE()));

        IF
@bookToeic IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M5-REQ-001' AND book_id = @bookToeic)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member5Id,@bookToeic,NULL,NULL,NULL,'REQUESTED',0,0,NULL,'ONLINE',1,50000,'DEMO-M5-REQ-001',N'Đặng Thị Lan','0901000007',N'33 Lê Lợi',N'Cao ốc văn phòng Harbour View',N'Phường Bến Nghé',N'Quận 1',N'TP. Hồ Chí Minh',DATEADD(HOUR,-2,GETDATE()));

        -- member6
        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M6-OVERDUE-001' AND book_id = @bookMicro)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member6Id,@bookMicro,DATEADD(DAY,-22,@today),DATEADD(DAY,-8,@today),NULL,'BORROWED',35000,0,NULL,'IN_PERSON',1,50000,'DEMO-M6-OVERDUE-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-22,GETDATE()));

        IF
@bookSoDo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M6-LATEPAID-001' AND book_id = @bookSoDo)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member6Id,@bookSoDo,DATEADD(DAY,-50,@today),DATEADD(DAY,-36,@today),DATEADD(DAY,-32,@today),'RETURNED',20000,1,NULL,'IN_PERSON',1,50000,'DEMO-M6-LATEPAID-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-50,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M6-APPROVED-001' AND book_id = @bookKieu)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member6Id,@bookKieu,NULL,NULL,NULL,'APPROVED',0,0,NULL,'ONLINE',1,50000,'DEMO-M6-APPROVED-001',N'Bùi Quang Huy','0901000008',N'17 Bạch Đằng',N'Chung cư The Song',N'Phường Thuận Phước',N'Hải Châu',N'Đà Nẵng',DATEADD(HOUR,-4,GETDATE()));

        IF
@bookChiPheo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M6-APPROVED-001' AND book_id = @bookChiPheo)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member6Id,@bookChiPheo,NULL,NULL,NULL,'APPROVED',0,0,NULL,'ONLINE',1,50000,'DEMO-M6-APPROVED-001',N'Bùi Quang Huy','0901000008',N'17 Bạch Đằng',N'Chung cư The Song',N'Phường Thuận Phước',N'Hải Châu',N'Đà Nẵng',DATEADD(HOUR,-4,GETDATE()));

        -- member7
        IF
@book7Habits IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M7-RENEW-001' AND book_id = @book7Habits)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member7Id,@book7Habits,DATEADD(DAY,-12,@today),DATEADD(DAY,-5,@today),NULL,'RENEWAL_REQUESTED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-M7-RENEW-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-12,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M7-RETURN-001' AND book_id = @bookToan)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member7Id,@bookToan,DATEADD(DAY,-60,@today),DATEADD(DAY,-47,@today),DATEADD(DAY,-50,@today),'RETURNED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-M7-RETURN-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-60,GETDATE()));

        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M7-RECEIVED-001' AND book_id = @bookPython)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member7Id,@bookPython,DATEADD(DAY,-2,@today),DATEADD(DAY,12,@today),NULL,'RECEIVED',0,0,NULL,'ONLINE',1,50000,'DEMO-M7-RECEIVED-001',N'Trương Ngọc Ánh','0901000009',N'56 Trần Hưng Đạo',N'Chung cư Goldmark City',N'Phường Hàng Bài',N'Hoàn Kiếm',N'Hà Nội',DATEADD(DAY,-2,GETDATE()));

        -- member8
        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-M8-REJECTED-001' AND book_id = @bookJava)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member8Id,@bookJava,NULL,NULL,NULL,'REJECTED',0,0,N'Tài khoản bị khóa, không thể xử lý yêu cầu.','ONLINE',1,50000,'DEMO-M8-REJECTED-001',N'Đinh Văn Tùng','0901000010',N'9 Lý Tự Trọng',NULL,N'Phường Tân An',N'Ninh Kiều',N'Cần Thơ',DATEADD(HOUR,-1,GETDATE()));

        -- =============================================
        -- Seed yêu cầu gia hạn.
        -- Khoá kiểm tra trùng: borrow_id
        -- =============================================
        IF
OBJECT_ID('renewal_requests', 'U') IS NOT NULL
BEGIN
            DECLARE
@renewBorrowId BIGINT = (
                SELECT TOP 1 id FROM borrow_records WHERE group_code = 'DEMO-RENEW-001' ORDER BY id DESC
            );
            DECLARE
@renewM7BorrowId BIGINT = (
                SELECT TOP 1 id FROM borrow_records WHERE group_code = 'DEMO-M7-RENEW-001' ORDER BY id DESC
            );

            IF
@renewBorrowId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM renewal_requests WHERE borrow_id = @renewBorrowId)
                INSERT INTO renewal_requests (borrow_id,user_id,reason,contact_name,contact_phone,contact_email,status,requested_at)
                VALUES (@renewBorrowId,@member3Id,N'Cần thêm thời gian để hoàn thành bài tập nhóm môn cơ sở dữ liệu.',N'Võ Minh Khôi','0901000005','member3@gmail.com','PENDING',DATEADD(HOUR,-6,GETDATE()));

            IF
@renewM7BorrowId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM renewal_requests WHERE borrow_id = @renewM7BorrowId)
                INSERT INTO renewal_requests (borrow_id,user_id,reason,contact_name,contact_phone,contact_email,status,requested_at)
                VALUES (@renewM7BorrowId,@member7Id,N'Chưa đọc xong, muốn gia hạn thêm 7 ngày để áp dụng thực tiễn vào công việc.',N'Trương Ngọc Ánh','0901000009','member7@gmail.com','PENDING',DATEADD(HOUR,-3,GETDATE()));
END;

        -- =============================================
        -- Seed bình luận sách.
        -- Khoá kiểm tra trùng: (book_id, user_id)
        -- =============================================
        IF
OBJECT_ID('Comment', 'U') IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookJava AND user_id = @userId)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookJava,@userId,N'Cuốn sách thay đổi cách tôi viết code. Mỗi chương là một bài học thực tiễn, áp dụng ngay vào dự án được luôn.',5,'VISIBLE',DATEADD(DAY,-20,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookJava AND user_id = @member2Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookJava,@member2Id,N'Một trong những cuốn sách lập trình hay nhất tôi từng đọc. Nguyên tắc SOLID được diễn giải rất dễ tiếp thu.',4,'VISIBLE',DATEADD(DAY,-15,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookJava AND user_id = @member5Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookJava,@member5Id,N'Đọc lần hai vẫn thấy nhiều điều mới. Quy tắc đặt tên và single responsibility thay đổi hoàn toàn cách viết code của tôi.',5,'VISIBLE',DATEADD(DAY,-8,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookJava AND user_id = @member6Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookJava,@member6Id,N'Ví dụ code hơi cũ nhưng các nguyên tắc vẫn cực kỳ giá trị. Must-read cho mọi lập trình viên.',3,'VISIBLE',DATEADD(DAY,-3,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSql AND user_id = @userId)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSql,@userId,N'Tiểu thuyết dystopia kinh điển. Big Brother vẫn còn nguyên giá trị trong thời đại internet hôm nay.',5,'VISIBLE',DATEADD(DAY,-19,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSql AND user_id = @member3Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSql,@member3Id,N'Đọc mà thấy ọn lạnh. Orwell viết về thế giới 1984 nhưng cảm giác như đang đọc về xã hội hiện tại.',3,'VISIBLE',DATEADD(DAY,-10,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSql AND user_id = @member7Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSql,@member7Id,N'Một trong những cuốn sách có tầm ảnh hưởng lớn nhất thế kỷ 20. Đọc chậm từng trang mới thấm.',4,'VISIBLE',DATEADD(DAY,-5,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookTatDen AND user_id = @member4Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookTatDen,@member4Id,N'Câu chuyện thiếu nhi nhưng thực ra dành cho người lớn. Mỗi lần đọc lại hiểu thêm một tầng nghĩa mới.',5,'VISIBLE',DATEADD(DAY,-14,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookTatDen AND user_id = @member5Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookTatDen,@member5Id,N'Đọc trong một buổi chiều không dứt ra được. Câu chuyện về tình bạn và ý nghĩa cuộc sống cảm động vô cùng.',5,'VISIBLE',DATEADD(DAY,-9,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookTatDen AND user_id = @member6Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookTatDen,@member6Id,N'Mua bản có tranh minh hoạ màu sắc đẹp lắm. Những câu thoại của Hoàng tử bé vẫn khiến mình suy nghĩ mãi.',4,'VISIBLE',DATEADD(DAY,-2,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookPython AND user_id = @member5Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookPython,@member5Id,N'Hệ thống 1% mỗi ngày thực sự thay đổi cách tôi hình thành thói quen. Đã áp dụng được 3 tháng rồi.',5,'VISIBLE',DATEADD(DAY,-4,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookPython AND user_id = @member7Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookPython,@member7Id,N'Lý thuyết hay nhưng cần kiên nhẫn áp dụng thực tế. Không áp dụng thì chỉ là đọc cho vui thôi.',3,'VISIBLE',DATEADD(DAY,-1,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookMicro AND user_id = @member6Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookMicro,@member6Id,N'Harari nhìn lịch sử loài người từ góc độ hoàn toàn mới. Rất đáng đọc dù bạn theo ngành nào.',4,'VISIBLE',DATEADD(DAY,-6,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSkills AND user_id = @member5Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSkills,@member5Id,N'Những nguyên tắc của Carnegie dù viết năm 1936 nhưng vẫn rất giá trị hôm nay. Thay đổi cách tôi giao tiếp với khách hàng.',4,'VISIBLE',DATEADD(DAY,-30,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSkills AND user_id = @member7Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSkills,@member7Id,N'Cuốn sách kinh điển về kỹ năng giao tiếp. Ai cũng nên đọc ít nhất một lần trong đời.',4,'VISIBLE',DATEADD(DAY,-18,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookKieu AND user_id = @member6Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookKieu,@member6Id,N'Đọc lại lần thứ 5 vẫn cực kỳ hấp dẫn. Hệ thống ma thuật của Rowling xây dựng chính xác và nhất quán quá mức.',5,'VISIBLE',DATEADD(DAY,-7,GETDATE()));

            IF
@bookClean IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookClean AND user_id = @member5Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookClean,@member5Id,N'GoF kinh điển cho mọi kỹ sư phần mềm. Hiểu Design Patterns giúp code maintainable hơn rất nhiều.',5,'VISIBLE',DATEADD(DAY,-3,GETDATE()));

            IF
@bookSoDo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSoDo AND user_id = @member6Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSoDo,@member6Id,N'García Márquez xây dựng gia tộc Buendía qua 100 năm, đọc mà hoa mắt vì tên nhân vật trùng nhau nhưng rất cuốn!',5,'VISIBLE',DATEADD(DAY,-28,GETDATE()));
            IF
@bookSoDo IS NOT NULL AND NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookSoDo AND user_id = @member7Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at) VALUES (@bookSoDo,@member7Id,N'Tuyến sự kiện phức tạp nhưng cuốn không thể dừng. Magical realism ở tầm cao nhất của văn học.',4,'VISIBLE',DATEADD(DAY,-12,GETDATE()));
END;

        -- =============================================
        -- Seed đặt trước sách.
        -- Khoá kiểm tra trùng: (user_id, book_id)
        -- =============================================
        IF
OBJECT_ID('reservations', 'U') IS NOT NULL
BEGIN
            IF
@bookClean IS NOT NULL AND NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member5Id AND book_id = @bookClean)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member5Id,@bookClean,'WAITING',N'Cần đọc gấp để chuẩn bị cho dự án cuối kỳ.',NULL,NULL,DATEADD(DAY,-5,GETDATE()));
            IF
@bookClean IS NOT NULL AND NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member6Id AND book_id = @bookClean)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member6Id,@bookClean,'WAITING',NULL,NULL,NULL,DATEADD(DAY,-4,GETDATE()));
            IF
@bookClean IS NOT NULL AND NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member7Id AND book_id = @bookClean)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member7Id,@bookClean,'WAITING',NULL,NULL,NULL,DATEADD(DAY,-2,GETDATE()));
            IF
@bookDocker IS NOT NULL AND NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member3Id AND book_id = @bookDocker)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member3Id,@bookDocker,'NOTIFIED',NULL,DATEADD(DAY,-1,GETDATE()),DATEADD(DAY,2,GETDATE()),DATEADD(DAY,-10,GETDATE()));
            IF
@bookReact IS NOT NULL AND NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member4Id AND book_id = @bookReact)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member4Id,@bookReact,'EXPIRED',NULL,DATEADD(DAY,-8,GETDATE()),DATEADD(DAY,-5,GETDATE()),DATEADD(DAY,-20,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member8Id AND book_id = @bookPython)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member8Id,@bookPython,'CANCELLED',N'Không cần nữa.',NULL,NULL,DATEADD(DAY,-15,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member2Id AND book_id = @bookMicro)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at) VALUES (@member2Id,@bookMicro,'WAITING',NULL,NULL,NULL,DATEADD(DAY,-3,GETDATE()));
END;

        -- =============================================
        -- Seed lịch sử giao dịch ví.
        -- Khoá kiểm tra trùng: reference
        -- =============================================
        IF
OBJECT_ID('wallet_transaction', 'U') IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-M5-001')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@member5Id,'TOPUP',N'VNPay Sandbox',N'Nạp 200.000 ₫ vào ví',200000,'DEMO-WALLET-M5-001',DATEADD(DAY,-30,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-M6-001')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@member6Id,'TOPUP',N'VNPay Sandbox',N'Nạp 100.000 ₫ vào ví',100000,'DEMO-WALLET-M6-001',DATEADD(DAY,-45,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-M6-002')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@member6Id,'TOPUP',N'VNPay Sandbox',N'Nạp 200.000 ₫ vào ví',200000,'DEMO-WALLET-M6-002',DATEADD(DAY,-20,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-M6-003')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@member6Id,'TOPUP',N'VNPay Sandbox',N'Nạp 200.000 ₫ vào ví',200000,'DEMO-WALLET-M6-003',DATEADD(DAY,-5,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-M7-001')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@member7Id,'TOPUP',N'VNPay Sandbox',N'Nạp 150.000 ₫ vào ví',150000,'DEMO-WALLET-M7-001',DATEADD(DAY,-10,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-U1-001')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@userId,'TOPUP',N'VNPay Sandbox',N'Nạp 500.000 ₫ vào ví',500000,'DEMO-WALLET-U1-001',DATEADD(DAY,-60,GETDATE()));
            IF
NOT EXISTS (SELECT 1 FROM wallet_transaction WHERE reference = 'DEMO-WALLET-U1-002')
                INSERT INTO wallet_transaction (user_id,type,source,description,amount,reference,created_at) VALUES (@userId,'TOPUP',N'VNPay Sandbox',N'Nạp 300.000 ₫ vào ví',300000,'DEMO-WALLET-U1-002',DATEADD(DAY,-25,GETDATE()));
END;

        -- =============================================
        -- Seed thông báo.
        -- Khoá kiểm tra trùng: (user_id, type, title)
        -- =============================================
        IF
OBJECT_ID('notifications', 'U') IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member3Id AND type = 'RESERVATION_AVAILABLE' AND title = N'Sách đã sẵn sàng để nhận!')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member3Id,'RESERVATION_AVAILABLE',N'Sách đã sẵn sàng để nhận!',N'Cuốn sách "The Lean Startup" bạn đặt trước đã có sẵn. Vui lòng đến thư viện nhận sách trong vòng 3 ngày. Nếu không đến đúng hạn, đặt trước sẽ bị hủy tự động.',0,DATEADD(DAY,-1,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member3Id AND type = 'RESERVATION_EXPIRING')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member3Id,'RESERVATION_EXPIRING',N'Sắp hết hạn nhận sách!',N'Bạn chỉ còn 1 ngày để nhận cuốn sách "The Lean Startup". Hạn cuối: 23:59 - ngày mai.',0,DATEADD(HOUR,-6,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member4Id AND type = 'RESERVATION_EXPIRED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member4Id,'RESERVATION_EXPIRED',N'Đặt trước đã bị hủy do hết hạn',N'Đặt trước cho cuốn sách "The 7 Habits of Highly Effective People" đã bị hủy tự động vì bạn không đến nhận trong 3 ngày. Bạn có thể đặt trước lại nếu muốn.',1,DATEADD(DAY,-5,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member8Id AND type = 'RESERVATION_CANCELLED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member8Id,'RESERVATION_CANCELLED',N'Đặt trước đã được hủy',N'Đặt trước cho cuốn sách "Atomic Habits" đã được hủy thành công.',1,DATEADD(DAY,-15,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member5Id AND type = 'RESERVATION_AVAILABLE')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member5Id,'RESERVATION_AVAILABLE',N'Sách đã sẵn sàng để nhận!',N'Cuốn sách "Design Patterns" bạn đặt trước đã có sẵn. Vui lòng đến thư viện nhận sách trong vòng 3 ngày.',0,DATEADD(HOUR,-2,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member2Id AND type = 'RESERVATION_AVAILABLE')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member2Id,'RESERVATION_AVAILABLE',N'Sách đã sẵn sàng để nhận!',N'Cuốn sách "Sapiens: A Brief History of Humankind" bạn đặt trước đã có sẵn. Vui lòng đến thư viện nhận sách trong vòng 3 ngày.',0,GETDATE());
END;

        -- =============================================
        -- Seed mã đặt lại mật khẩu.
        -- Khoá kiểm tra trùng: token
        -- =============================================
        IF
OBJECT_ID('password_reset_token', 'U') IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM password_reset_token WHERE token = 'DEMO-RESET-USER')
                INSERT INTO password_reset_token (user_id,token,expired_at,used,created_at) VALUES (@userId,'DEMO-RESET-USER',DATEADD(HOUR,2,GETDATE()),0,GETDATE());
            IF
NOT EXISTS (SELECT 1 FROM password_reset_token WHERE token = 'DEMO-RESET-MEMBER3')
                INSERT INTO password_reset_token (user_id,token,expired_at,used,created_at) VALUES (@member3Id,'DEMO-RESET-MEMBER3',DATEADD(HOUR,1,GETDATE()),0,GETDATE());
            IF
NOT EXISTS (SELECT 1 FROM password_reset_token WHERE token = 'DEMO-RESET-MEMBER6')
                INSERT INTO password_reset_token (user_id,token,expired_at,used,created_at) VALUES (@member6Id,'DEMO-RESET-MEMBER6',DATEADD(MINUTE,30,GETDATE()),0,GETDATE());
END;

        -- ============================================================
        -- PHẦN BỔ SUNG: Dữ liệu mở rộng để test đầy đủ mọi trạng thái
        -- ============================================================

        -- ── Sách hết hàng (quantity = 0) ─────────────────────────────────
        IF
NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-9780136083252')
BEGIN
            DECLARE
@catTechExt INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Lập trình & Công nghệ');
INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
VALUES (N'Head First Design Patterns', N'Eric Freeman, Elisabeth Robson', @catTechExt, 320000, 0, 'ISBN-9780136083252',
        'https://covers.openlibrary.org/b/isbn/9780596007126-M.jpg');
END;
        DECLARE
@bookOutOfStock INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780136083252');

        -- ── Cập nhật BookCopy: LOST và DAMAGED ───────────────────────────
        IF
OBJECT_ID('BookCopy', 'U') IS NOT NULL
BEGIN
            DECLARE
@lostCopyId INT = (SELECT TOP 1 copy_id FROM BookCopy WHERE book_id = @bookJava AND status = 'AVAILABLE' ORDER BY copy_id DESC);
            IF
@lostCopyId IS NOT NULL
UPDATE BookCopy
SET status = 'LOST'
WHERE copy_id = @lostCopyId;

DECLARE
@damagedCopyId INT = (SELECT TOP 1 copy_id FROM BookCopy WHERE book_id = @bookSql AND status = 'AVAILABLE' ORDER BY copy_id DESC);
            IF
@damagedCopyId IS NOT NULL
UPDATE BookCopy
SET status = 'DAMAGED'
WHERE copy_id = @damagedCopyId;
END;

        -- ── Borrow records: SHIPPING (đơn hàng đang giao) ────────────────
        DECLARE
@bkDune  INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780441013593');
        DECLARE
@bkAlice INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780141439761');

        IF
@bkDune IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-SHIPPING-001' AND book_id = @bkDune)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member2Id,@bkDune,NULL,NULL,NULL,'SHIPPING',0,0,NULL,'ONLINE',1,50000,'DEMO-SHIPPING-001',N'Phạm Thu Trang','0901000004',N'45 Điện Biên Phủ',N'Tòa nhà Pearl Plaza',N'Phường 25',N'Bình Thạnh',N'TP. Hồ Chí Minh',DATEADD(HOUR,-12,GETDATE()));

        IF
@bkAlice IS NOT NULL AND NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-SHIPPING-001' AND book_id = @bkAlice)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member2Id,@bkAlice,NULL,NULL,NULL,'SHIPPING',0,0,NULL,'ONLINE',1,50000,'DEMO-SHIPPING-001',N'Phạm Thu Trang','0901000004',N'45 Điện Biên Phủ',N'Tòa nhà Pearl Plaza',N'Phường 25',N'Bình Thạnh',N'TP. Hồ Chí Minh',DATEADD(HOUR,-12,GETDATE()));

        -- ── Borrow records: RETURN_REQUESTED (đã yêu cầu trả sách) ───────
        IF
NOT EXISTS (SELECT 1 FROM borrow_records WHERE group_code = 'DEMO-RETREQ-001' AND book_id = @bookMicro)
            INSERT INTO borrow_records (user_id,book_id,borrow_date,due_date,return_date,status,fine_amount,is_paid,reject_reason,borrow_method,quantity,deposit_amount,group_code,shipping_recipient,shipping_phone,shipping_street,shipping_residence,shipping_ward,shipping_district,shipping_city,created_at)
            VALUES (@member3Id,@bookMicro,DATEADD(DAY,-10,@today),DATEADD(DAY,4,@today),NULL,'RETURN_REQUESTED',0,0,NULL,'IN_PERSON',1,50000,'DEMO-RETREQ-001',NULL,NULL,NULL,NULL,NULL,NULL,NULL,DATEADD(DAY,-10,GETDATE()));

        -- ── Shipments (vận đơn giao hàng) ────────────────────────────────
        IF
OBJECT_ID('shipments', 'U') IS NOT NULL
BEGIN
            DECLARE
@shipBrId1 BIGINT = (SELECT TOP 1 id FROM borrow_records WHERE group_code = 'DEMO-SHIPPING-001' AND book_id = @bkDune);
            IF
@shipBrId1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM shipments WHERE borrow_record_id = @shipBrId1)
                INSERT INTO shipments (borrow_record_id,tracking_code,status,address,phone,created_at,updated_at)
                VALUES (@shipBrId1,'VN-TRACK-2025-001','SHIPPING',N'45 Điện Biên Phủ, Tòa nhà Pearl Plaza, Phường 25, Bình Thạnh, TP. Hồ Chí Minh','0901000004',DATEADD(HOUR,-11,GETDATE()),DATEADD(HOUR,-6,GETDATE()));

            DECLARE
@shipBrId2 BIGINT = (SELECT TOP 1 id FROM borrow_records WHERE group_code = 'DEMO-M6-APPROVED-001' AND book_id = @bookChiPheo);
            IF
@shipBrId2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM shipments WHERE borrow_record_id = @shipBrId2)
                INSERT INTO shipments (borrow_record_id,tracking_code,status,address,phone,created_at,updated_at)
                VALUES (@shipBrId2,'VN-TRACK-2025-002','DELIVERED',N'17 Bạch Đằng, Chung cư The Song, Phường Thuận Phước, Hải Châu, Đà Nẵng','0901000008',DATEADD(HOUR,-30,GETDATE()),DATEADD(HOUR,-4,GETDATE()));
END;

        -- ── Renewal requests: APPROVED và REJECTED ───────────────────────
        IF
OBJECT_ID('renewal_requests', 'U') IS NOT NULL
BEGIN
            DECLARE
@renewApprId BIGINT = (SELECT TOP 1 id FROM borrow_records WHERE group_code = 'DEMO-M5-BORROW-001' AND book_id = @bookPython);
            IF
@renewApprId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM renewal_requests WHERE borrow_id = @renewApprId)
                INSERT INTO renewal_requests (borrow_id,user_id,reason,contact_name,contact_phone,contact_email,status,requested_at)
                VALUES (@renewApprId,@member5Id,N'Cần thêm thời gian để hoàn thành bài đọc và ghi chú thực hành.',N'Đặng Thị Lan','0901000007','member5@gmail.com','APPROVED',DATEADD(DAY,-3,GETDATE()));

            DECLARE
@renewRejId BIGINT = (SELECT TOP 1 id FROM borrow_records WHERE group_code = 'DEMO-M6-OVERDUE-001' AND book_id = @bookMicro);
            IF
@renewRejId IS NOT NULL AND NOT EXISTS (SELECT 1 FROM renewal_requests WHERE borrow_id = @renewRejId)
                INSERT INTO renewal_requests (borrow_id,user_id,reason,contact_name,contact_phone,contact_email,status,requested_at)
                VALUES (@renewRejId,@member6Id,N'Muốn đọc thêm một tuần nữa.',N'Bùi Quang Huy','0901000008','member6@gmail.com','REJECTED',DATEADD(DAY,-5,GETDATE()));
END;

        -- ── Comments: trạng thái DELETED ─────────────────────────────────
        IF
OBJECT_ID('Comment', 'U') IS NOT NULL AND @bookChiPheo IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookChiPheo AND user_id = @member3Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at,deleted_at)
                VALUES (@bookChiPheo,@member3Id,N'Bình luận vi phạm nội quy - đã bị xóa bởi admin.',1,'DELETED',DATEADD(DAY,-15,GETDATE()),DATEADD(DAY,-14,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM Comment WHERE book_id = @bookChiPheo AND user_id = @member10Id)
                INSERT INTO Comment (book_id,user_id,content,rating,status,created_at,deleted_at)
                VALUES (@bookChiPheo,@member10Id,N'Spam - comment này đã bị admin xóa.',1,'DELETED',DATEADD(DAY,-12,GETDATE()),DATEADD(DAY,-12,GETDATE()));
END;

        -- ── CommentReply (admin/thủ thư phản hồi bình luận) ──────────────
        IF
OBJECT_ID('CommentReply', 'U') IS NOT NULL
BEGIN
            DECLARE
@repComm1 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookJava AND user_id = @userId AND status = 'VISIBLE');
            IF
@repComm1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReply WHERE comment_id = @repComm1)
                INSERT INTO CommentReply (comment_id,admin_id,content,created_at)
                VALUES (@repComm1,@adminUserId,N'Cảm ơn bạn đã chia sẻ! Thư viện rất vui khi cuốn sách mang lại giá trị cho bạn. Chúc bạn đọc sách vui!',DATEADD(DAY,-19,GETDATE()));

            DECLARE
@repComm2 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookTatDen AND user_id = @member4Id AND status = 'VISIBLE');
            IF
@repComm2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReply WHERE comment_id = @repComm2)
                INSERT INTO CommentReply (comment_id,admin_id,content,created_at)
                VALUES (@repComm2,@lib2Id,N'Đúng vậy bạn ơi! "Hoàng tử bé" luôn là cuốn sách mà ai đọc ở độ tuổi nào cũng tìm thấy điều gì đó mới. Hẹn gặp bạn ở thư viện!',DATEADD(DAY,-13,GETDATE()));

            DECLARE
@repComm3 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookMicro AND user_id = @member6Id AND status = 'VISIBLE');
            IF
@repComm3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReply WHERE comment_id = @repComm3)
                INSERT INTO CommentReply (comment_id,admin_id,content,created_at)
                VALUES (@repComm3,@adminUserId,N'Harari quả nhiên là tác giả xuất sắc! Bạn có thể tham khảo thêm cuốn "Homo Deus" của ông - thư viện sắp nhập sách mới.',DATEADD(DAY,-5,GETDATE()));
END;

        -- ── CommentReport (báo cáo bình luận) ────────────────────────────
        IF
OBJECT_ID('CommentReport', 'U') IS NOT NULL
BEGIN
            -- PENDING: member3 báo cáo bình luận của member6 về Clean Code
            DECLARE
@rptTarget1 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookJava AND user_id = @member6Id AND status = 'VISIBLE');
            IF
@rptTarget1 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReport WHERE comment_id = @rptTarget1 AND reporter_user_id = @member3Id)
                INSERT INTO CommentReport (comment_id,reporter_user_id,reason,description,report_time,status)
                VALUES (@rptTarget1,@member3Id,N'Đánh giá không khách quan',N'Người dùng cho rằng ví dụ code cũ là lỗi nhưng đó là phong cách tác giả.',DATEADD(DAY,-2,GETDATE()),'PENDING');

            -- PENDING: member5 báo cáo bình luận của member7 về 1984
            DECLARE
@rptTarget2 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookSql AND user_id = @member7Id AND status = 'VISIBLE');
            IF
@rptTarget2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReport WHERE comment_id = @rptTarget2 AND reporter_user_id = @member5Id)
                INSERT INTO CommentReport (comment_id,reporter_user_id,reason,description,report_time,status)
                VALUES (@rptTarget2,@member5Id,N'Nội dung sai lệch',N'Nhận xét có thể gây hiểu nhầm cho độc giả về nội dung cuốn sách.',DATEADD(DAY,-1,GETDATE()),'PENDING');

            -- RESOLVED: bình luận DELETED của member3 (đã xử lý)
            DECLARE
@rptTarget3 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookChiPheo AND user_id = @member3Id AND status = 'DELETED');
            IF
@rptTarget3 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReport WHERE comment_id = @rptTarget3 AND reporter_user_id = @member7Id)
                INSERT INTO CommentReport (comment_id,reporter_user_id,reason,description,report_time,status)
                VALUES (@rptTarget3,@member7Id,N'Nội dung không phù hợp',N'Bình luận vi phạm nội quy thư viện.',DATEADD(DAY,-15,GETDATE()),'RESOLVED');

            -- IGNORED: member2 báo cáo bình luận của member3 về 1984
            DECLARE
@rptTarget4 BIGINT = (SELECT TOP 1 comment_id FROM Comment WHERE book_id = @bookSql AND user_id = @member3Id AND status = 'VISIBLE');
            IF
@rptTarget4 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CommentReport WHERE comment_id = @rptTarget4 AND reporter_user_id = @member2Id)
                INSERT INTO CommentReport (comment_id,reporter_user_id,reason,description,report_time,status)
                VALUES (@rptTarget4,@member2Id,N'Ngôn từ không lịch sự',N'Cụm từ trong bình luận có vẻ thiếu chuẩn mực.',DATEADD(DAY,-9,GETDATE()),'IGNORED');
END;

        -- ── Reservation: BORROWED status ─────────────────────────────────
        IF
OBJECT_ID('reservations', 'U') IS NOT NULL AND @bookChiPheo IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM reservations WHERE user_id = @member5Id AND book_id = @bookChiPheo)
                INSERT INTO reservations (user_id,book_id,status,note,notified_at,expired_at,created_at)
                VALUES (@member5Id,@bookChiPheo,'BORROWED',N'Đặt trước rồi đã mượn thành công.',DATEADD(DAY,-6,GETDATE()),DATEADD(DAY,-3,GETDATE()),DATEADD(DAY,-15,GETDATE()));
END;

        -- ── Cart / CartItem (giỏ hàng) ────────────────────────────────────
        IF
OBJECT_ID('Cart', 'U') IS NOT NULL AND OBJECT_ID('CartItem', 'U') IS NOT NULL
BEGIN
            DECLARE
@bkPragmatic2 INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780135957059');
            DECLARE
@bkDesignPat2 INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780201633610');
            DECLARE
@bkRichDad2   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9781612680194');
            DECLARE
@bkHarryPot2  INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780590353427');
            DECLARE
@bkBriefHist2 INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780553380163');
            DECLARE
@bkAtomicH2   INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-9780735211292');

            -- Cart member2
            DECLARE
@cartIdM2 BIGINT = (SELECT TOP 1 cart_id FROM Cart WHERE user_id = @member2Id);
            IF
@cartIdM2 IS NULL
BEGIN
INSERT INTO Cart (user_id)
VALUES (@member2Id);
SET
@cartIdM2 = SCOPE_IDENTITY();
END;
            IF
@bkPragmatic2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cartIdM2 AND book_id = @bkPragmatic2)
                INSERT INTO CartItem (cart_id,book_id,quantity,added_at) VALUES (@cartIdM2,@bkPragmatic2,1,DATEADD(DAY,-2,GETDATE()));
            IF
@bkRichDad2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cartIdM2 AND book_id = @bkRichDad2)
                INSERT INTO CartItem (cart_id,book_id,quantity,added_at) VALUES (@cartIdM2,@bkRichDad2,1,DATEADD(DAY,-1,GETDATE()));

            -- Cart member5
            DECLARE
@cartIdM5 BIGINT = (SELECT TOP 1 cart_id FROM Cart WHERE user_id = @member5Id);
            IF
@cartIdM5 IS NULL
BEGIN
INSERT INTO Cart (user_id)
VALUES (@member5Id);
SET
@cartIdM5 = SCOPE_IDENTITY();
END;
            IF
@bkDesignPat2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cartIdM5 AND book_id = @bkDesignPat2)
                INSERT INTO CartItem (cart_id,book_id,quantity,added_at) VALUES (@cartIdM5,@bkDesignPat2,1,DATEADD(HOUR,-5,GETDATE()));
            IF
@bkHarryPot2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cartIdM5 AND book_id = @bkHarryPot2)
                INSERT INTO CartItem (cart_id,book_id,quantity,added_at) VALUES (@cartIdM5,@bkHarryPot2,1,DATEADD(HOUR,-3,GETDATE()));

            -- Cart member7
            DECLARE
@cartIdM7 BIGINT = (SELECT TOP 1 cart_id FROM Cart WHERE user_id = @member7Id);
            IF
@cartIdM7 IS NULL
BEGIN
INSERT INTO Cart (user_id)
VALUES (@member7Id);
SET
@cartIdM7 = SCOPE_IDENTITY();
END;
            IF
@bkBriefHist2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cartIdM7 AND book_id = @bkBriefHist2)
                INSERT INTO CartItem (cart_id,book_id,quantity,added_at) VALUES (@cartIdM7,@bkBriefHist2,1,DATEADD(HOUR,-1,GETDATE()));
            IF
@bkAtomicH2 IS NOT NULL AND NOT EXISTS (SELECT 1 FROM CartItem WHERE cart_id = @cartIdM7 AND book_id = @bkAtomicH2)
                INSERT INTO CartItem (cart_id,book_id,quantity,added_at) VALUES (@cartIdM7,@bkAtomicH2,1,DATEADD(MINUTE,-30,GETDATE()));
END;

        -- ── LibrarianActivityLog (nhật ký hoạt động thủ thư) ──────────────
        IF
OBJECT_ID('LibrarianActivityLog', 'U') IS NOT NULL
BEGIN
            DECLARE
@libPrimId INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'librarian@gmail.com');
            IF
@libPrimId IS NOT NULL
BEGIN
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@libPrimId, N'Duyệt yêu cầu mượn sách nhóm DEMO-APPROVED-001 của thành viên member2.',
        DATEADD(HOUR,-10, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@libPrimId, N'Từ chối yêu cầu mượn sách nhóm DEMO-REJECTED-001 của thành viên member4.',
        DATEADD(HOUR,-7, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@libPrimId, N'Cập nhật trạng thái vận chuyển DEMO-SHIPPING-001 sang SHIPPING.', DATEADD(HOUR,-6, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@libPrimId, N'Nhận sách trả từ thành viên member4 - nhóm DEMO-LATE-UNPAID-001.', DATEADD(HOUR,-5, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@libPrimId, N'Phê duyệt gia hạn cho thành viên member5 - nhóm DEMO-M5-BORROW-001.', DATEADD(DAY,-2, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@libPrimId, N'Từ chối gia hạn cho thành viên member6 - nhóm DEMO-M6-OVERDUE-001.', DATEADD(DAY,-4, GETDATE()));
END;
            IF
@lib2Id IS NOT NULL
BEGIN
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@lib2Id, N'Duyệt yêu cầu mượn sách nhóm DEMO-M6-APPROVED-001 của thành viên member6.',
        DATEADD(HOUR,-4, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@lib2Id, N'Cập nhật trạng thái giao hàng sang DELIVERED cho VN-TRACK-2025-002.', DATEADD(HOUR,-3, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@lib2Id, N'Thêm sách mới "Head First Design Patterns" vào kho (quantity = 0).', DATEADD(DAY,-1, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@lib2Id, N'Ghi nhận sách bị mất: Clean Code - một bản sao.', DATEADD(DAY,-3, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@lib2Id, N'Ghi nhận sách bị hư hỏng: Nineteen Eighty-Four - một bản sao.', DATEADD(DAY,-3, GETDATE()));
INSERT INTO LibrarianActivityLog (user_id, action, timestamp)
VALUES (@lib2Id, N'Xóa bình luận vi phạm nội quy của thành viên member10.', DATEADD(DAY,-12, GETDATE()));
END;
END;

        -- ── Notifications bổ sung ────────────────────────────────────────
        IF
OBJECT_ID('notifications', 'U') IS NOT NULL
BEGIN
            -- BORROW_APPROVED
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member2Id AND type = 'BORROW_APPROVED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member2Id,'BORROW_APPROVED',N'Yêu cầu mượn sách đã được duyệt!',N'Yêu cầu mượn sách nhóm DEMO-APPROVED-001 đã được phê duyệt. Sách đang được chuẩn bị để giao đến địa chỉ của bạn.',1,DATEADD(HOUR,-9,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member6Id AND type = 'BORROW_APPROVED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member6Id,'BORROW_APPROVED',N'Yêu cầu mượn sách đã được duyệt!',N'Yêu cầu mượn sách nhóm DEMO-M6-APPROVED-001 đã được duyệt. Sách đang trên đường giao đến bạn.',0,DATEADD(HOUR,-3,GETDATE()));

            -- BORROW_REJECTED
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member4Id AND type = 'BORROW_REJECTED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member4Id,'BORROW_REJECTED',N'Yêu cầu mượn sách đã bị từ chối',N'Yêu cầu mượn sách nhóm DEMO-REJECTED-001 đã bị từ chối. Lý do: Độc giả đang còn phiếu mượn quá hạn. Vui lòng liên hệ thư viện để được hỗ trợ.',1,DATEADD(HOUR,-6,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member8Id AND type = 'BORROW_REJECTED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member8Id,'BORROW_REJECTED',N'Yêu cầu mượn sách đã bị từ chối',N'Yêu cầu mượn sách đã bị từ chối do tài khoản bị khóa. Vui lòng liên hệ quản trị viên để được hỗ trợ.',0,DATEADD(HOUR,-1,GETDATE()));

            -- RENEWAL_APPROVED
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member5Id AND type = 'RENEWAL_APPROVED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member5Id,'RENEWAL_APPROVED',N'Yêu cầu gia hạn đã được chấp thuận!',N'Yêu cầu gia hạn sách "Atomic Habits" của bạn đã được phê duyệt. Hạn trả sách mới: 7 ngày kể từ hôm nay.',0,DATEADD(DAY,-2,GETDATE()));

            -- RENEWAL_REJECTED
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member6Id AND type = 'RENEWAL_REJECTED')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member6Id,'RENEWAL_REJECTED',N'Yêu cầu gia hạn đã bị từ chối',N'Yêu cầu gia hạn sách "Sapiens" đã bị từ chối. Lý do: Sách đang có độc giả khác đặt trước và phiếu mượn đã quá hạn.',0,DATEADD(DAY,-4,GETDATE()));

            -- OVERDUE_WARNING
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member2Id AND type = 'OVERDUE_WARNING')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member2Id,'OVERDUE_WARNING',N'Sách sắp đến hạn trả!',N'Cuốn sách "Nineteen Eighty-Four" của bạn sẽ đến hạn trả sau 2 ngày. Vui lòng trả sách đúng hạn để tránh bị tính phạt.',0,DATEADD(DAY,-16,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member6Id AND type = 'OVERDUE_WARNING')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member6Id,'OVERDUE_WARNING',N'Sách đã quá hạn trả - phát sinh tiền phạt!',N'Cuốn sách "Sapiens" của bạn đã quá hạn 8 ngày. Tiền phạt hiện tại: 35.000 ₫. Vui lòng trả sách ngay.',0,DATEADD(DAY,-8,GETDATE()));

            -- GENERAL_NOTICE
            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @userId AND type = 'GENERAL_NOTICE')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@userId,'GENERAL_NOTICE',N'Thông báo: Thư viện nghỉ lễ',N'Thư viện sẽ đóng cửa từ ngày 30/04 đến 02/05 nhân dịp Lễ 30 tháng 4. Mọi yêu cầu mượn/trả sẽ được xử lý sau ngày 03/05.',1,DATEADD(DAY,-7,GETDATE()));

            IF
NOT EXISTS (SELECT 1 FROM notifications WHERE user_id = @member5Id AND type = 'GENERAL_NOTICE')
                INSERT INTO notifications (user_id,type,title,message,is_read,created_at)
                VALUES (@member5Id,'GENERAL_NOTICE',N'Sách mới vừa về kho!',N'Thư viện vừa bổ sung thêm 5 đầu sách mới về Lập trình và Phát triển bản thân. Truy cập danh mục sách để xem chi tiết.',0,DATEADD(DAY,-3,GETDATE()));
END;

        -- ── Password reset tokens bổ sung: đã dùng (used=1) và đã hết hạn ─
        IF
OBJECT_ID('password_reset_token', 'U') IS NOT NULL
BEGIN
            -- Token đã sử dụng (used = 1)
            IF
NOT EXISTS (SELECT 1 FROM password_reset_token WHERE token = 'DEMO-RESET-USED-M5')
                INSERT INTO password_reset_token (user_id,token,expired_at,used,created_at)
                VALUES (@member5Id,'DEMO-RESET-USED-M5',DATEADD(HOUR,2,DATEADD(DAY,-1,GETDATE())),1,DATEADD(DAY,-1,GETDATE()));

            -- Token đã hết hạn (expired_at trong quá khứ)
            IF
NOT EXISTS (SELECT 1 FROM password_reset_token WHERE token = 'DEMO-RESET-EXPIRED-M7')
                INSERT INTO password_reset_token (user_id,token,expired_at,used,created_at)
                VALUES (@member7Id,'DEMO-RESET-EXPIRED-M7',DATEADD(HOUR,-3,GETDATE()),0,DATEADD(HOUR,-5,GETDATE()));
END;

        -- ── Email verification token cho user PENDING (member9) ───────────
        IF
OBJECT_ID('email_verification_token', 'U') IS NOT NULL AND @member9Id IS NOT NULL
BEGIN
            IF
NOT EXISTS (SELECT 1 FROM email_verification_token WHERE user_id = @member9Id)
                INSERT INTO email_verification_token (user_id,code,expired_at,used,created_at)
                VALUES (@member9Id,'DEMO-VERIFY-123456',DATEADD(HOUR,24,GETDATE()),0,GETDATE());
END;

COMMIT TRANSACTION;

PRINT
N'Seed demo data completed successfully.';
        PRINT
N'Accounts: admin@gmail.com / librarian@gmail.com / librarian2@gmail.com';
        PRINT
N'          user@gmail.com / member2@gmail.com ~ member11@gmail.com';
        PRINT
N'Common password: 123456  |  member8/member11=LOCKED  |  member9=PENDING  |  member10=comment-banned';
END TRY
BEGIN CATCH
IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
END CATCH;
