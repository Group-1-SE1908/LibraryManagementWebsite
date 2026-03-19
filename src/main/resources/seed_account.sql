USE LibraryDB;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
	BEGIN TRANSACTION;

	IF OBJECT_ID('Role', 'U') IS NULL
		OR OBJECT_ID('[User]', 'U') IS NULL
		OR OBJECT_ID('Book', 'U') IS NULL
		OR OBJECT_ID('borrow_records', 'U') IS NULL
	BEGIN
		THROW 50001, N'Vui lòng chạy schema.sql trước khi chạy seed_account.sql.', 1;
	END;

	DECLARE @defaultPasswordHash VARCHAR(255) = '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa';
	DECLARE @today DATE = CAST(GETDATE() AS DATE);

	-- Đảm bảo role cơ bản tồn tại để script có thể chạy lại an toàn.
	IF NOT EXISTS (SELECT 1 FROM Role WHERE UPPER(role_name) = 'ADMIN')
		INSERT INTO Role (role_name) VALUES ('ADMIN');

	IF NOT EXISTS (SELECT 1 FROM Role WHERE UPPER(role_name) = 'LIBRARIAN')
		INSERT INTO Role (role_name) VALUES ('LIBRARIAN');

	IF NOT EXISTS (SELECT 1 FROM Role WHERE UPPER(role_name) = 'MEMBER')
		INSERT INTO Role (role_name) VALUES ('MEMBER');

	DECLARE @adminRoleId INT = (SELECT TOP 1 role_id FROM Role WHERE UPPER(role_name) = 'ADMIN');
	DECLARE @librarianRoleId INT = (SELECT TOP 1 role_id FROM Role WHERE UPPER(role_name) = 'LIBRARIAN');
	DECLARE @memberRoleId INT = (SELECT TOP 1 role_id FROM Role WHERE UPPER(role_name) = 'MEMBER');

	-- Tài khoản demo. Mật khẩu chung: 123456
	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'admin@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('admin@gmail.com', @defaultPasswordHash, N'Nguyễn Văn A', '0901000001', N'1 Lý Thường Kiệt, Hà Nội', 'ACTIVE', @adminRoleId, 'uploads/admin.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Nguyễn Văn A',
		phone = '0901000001',
		address = N'1 Lý Thường Kiệt, Hà Nội',
		status = 'ACTIVE',
		role_id = @adminRoleId
	WHERE email = 'admin@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'librarian@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('librarian@gmail.com', @defaultPasswordHash, N'Trần Thị B', '0901000002', N'15 Pasteur, Quận 3, TP. Hồ Chí Minh', 'ACTIVE', @librarianRoleId, 'uploads/lib.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Trần Thị B',
		phone = '0901000002',
		address = N'15 Pasteur, Quận 3, TP. Hồ Chí Minh',
		status = 'ACTIVE',
		role_id = @librarianRoleId
	WHERE email = 'librarian@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'user@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('user@gmail.com', @defaultPasswordHash, N'Lê Văn C', '0901000003', N'12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Lê Văn C',
		phone = '0901000003',
		address = N'12 Nguyễn Trãi, Quận 5, TP. Hồ Chí Minh',
		status = 'ACTIVE',
		role_id = @memberRoleId
	WHERE email = 'user@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member2@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('member2@gmail.com', @defaultPasswordHash, N'Phạm Thu Trang', '0901000004', N'45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Phạm Thu Trang',
		phone = '0901000004',
		address = N'45 Điện Biên Phủ, Bình Thạnh, TP. Hồ Chí Minh',
		status = 'ACTIVE',
		role_id = @memberRoleId
	WHERE email = 'member2@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member3@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('member3@gmail.com', @defaultPasswordHash, N'Võ Minh Khôi', '0901000005', N'88 Hùng Vương, Hải Châu, Đà Nẵng', 'ACTIVE', @memberRoleId, 'uploads/user.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Võ Minh Khôi',
		phone = '0901000005',
		address = N'88 Hùng Vương, Hải Châu, Đà Nẵng',
		status = 'ACTIVE',
		role_id = @memberRoleId
	WHERE email = 'member3@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member4@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('member4@gmail.com', @defaultPasswordHash, N'Ngô Hải Yến', '0901000006', N'25 Trần Phú, Nha Trang, Khánh Hòa', 'ACTIVE', @memberRoleId, 'uploads/user.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Ngô Hải Yến',
		phone = '0901000006',
		address = N'25 Trần Phú, Nha Trang, Khánh Hòa',
		status = 'ACTIVE',
		role_id = @memberRoleId
	WHERE email = 'member4@gmail.com';

	-- ── Thành viên bổ sung ────────────────────────────────────────────
	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member5@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
		VALUES ('member5@gmail.com', @defaultPasswordHash, N'Đặng Thị Lan', '0901000007', N'33 Lê Lợi, Quận 1, TP. Hồ Chí Minh', 'ACTIVE', @memberRoleId, 'uploads/user.png', 200000);
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Đặng Thị Lan',
		phone = '0901000007',
		address = N'33 Lê Lợi, Quận 1, TP. Hồ Chí Minh',
		status = 'ACTIVE',
		role_id = @memberRoleId,
		wallet_balance = 200000
	WHERE email = 'member5@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member6@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
		VALUES ('member6@gmail.com', @defaultPasswordHash, N'Bùi Quang Huy', '0901000008', N'17 Bạch Đằng, Hải Châu, Đà Nẵng', 'ACTIVE', @memberRoleId, 'uploads/user.png', 500000);
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Bùi Quang Huy',
		phone = '0901000008',
		address = N'17 Bạch Đằng, Hải Châu, Đà Nẵng',
		status = 'ACTIVE',
		role_id = @memberRoleId,
		wallet_balance = 500000
	WHERE email = 'member6@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member7@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar, wallet_balance)
		VALUES ('member7@gmail.com', @defaultPasswordHash, N'Trương Ngọc Ánh', '0901000009', N'56 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội', 'ACTIVE', @memberRoleId, 'uploads/user.png', 150000);
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Trương Ngọc Ánh',
		phone = '0901000009',
		address = N'56 Trần Hưng Đạo, Hoàn Kiếm, Hà Nội',
		status = 'ACTIVE',
		role_id = @memberRoleId,
		wallet_balance = 150000
	WHERE email = 'member7@gmail.com';

	IF NOT EXISTS (SELECT 1 FROM [User] WHERE email = 'member8@gmail.com')
	BEGIN
		INSERT INTO [User] (email, password, full_name, phone, address, status, role_id, avatar)
		VALUES ('member8@gmail.com', @defaultPasswordHash, N'Đinh Văn Tùng', '0901000010', N'9 Lý Tự Trọng, Ninh Kiều, Cần Thơ', 'LOCKED', @memberRoleId, 'uploads/user.png');
	END;

	UPDATE [User]
	SET password = @defaultPasswordHash,
		full_name = N'Đinh Văn Tùng',
		phone = '0901000010',
		address = N'9 Lý Tự Trọng, Ninh Kiều, Cần Thơ',
		status = 'LOCKED',
		role_id = @memberRoleId
	WHERE email = 'member8@gmail.com';

	DECLARE @userId INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'user@gmail.com');
	DECLARE @member2Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member2@gmail.com');
	DECLARE @member3Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member3@gmail.com');
	DECLARE @member4Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member4@gmail.com');
	DECLARE @member5Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member5@gmail.com');
	DECLARE @member6Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member6@gmail.com');
	DECLARE @member7Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member7@gmail.com');
	DECLARE @member8Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member8@gmail.com');

	-- Seed thÃªm sáº¡ch má»›i Ä‘á»ƒ hiá»ƒn thá»‹ kho sáº£n pháº©m demo.
	DECLARE @catTech INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Công nghệ thông tin');
	DECLARE @catLit INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Văn học Việt Nam');
	DECLARE @catSkills INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Kỹ năng sống');
	DECLARE @catHighSchool INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Giáo trình THPT');

	IF @catTech IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-004')
		BEGIN
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Lập trình Python nâng cao', N'Hoàng Vũ', @catTech, 170000, 8, 'ISBN-004', 'assets/images/books/python.jpg');
		END;

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-005')
		BEGIN
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Thiết kế hệ thống microservices', N'Nguyễn Thị Hạ', @catTech, 190000, 6, 'ISBN-005', 'assets/images/books/microservices.jpg');
		END;
	END;

	IF @catLit IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-006')
		BEGIN
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Truyện Kiều', N'Nguyễn Du', @catLit, 110000, 12, 'ISBN-006', 'assets/images/books/truyen_kieu.jpg');
		END;

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-007')
		BEGIN
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Dế Mèn phiêu lưu ký', N'Tạ Duy Anh', @catLit, 85000, 10, 'ISBN-007', 'assets/images/books/de_men.jpg');
		END;
	END;

	IF @catSkills IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-008')
		BEGIN
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Kỹ năng mềm cho sinh viên', N'Hoàng Minh Sơn', @catSkills, 95000, 9, 'ISBN-008', 'assets/images/books/soft_skills.jpg');
		END;
	END;

	IF @catHighSchool IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-009')
		BEGIN
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Giáo trình Toán cao cấp', N'Lê Thị Bình', @catHighSchool, 130000, 7, 'ISBN-009', 'assets/images/books/giaotrinh_toan.jpg');
		END;
	END;

	-- ── Thêm danh mục mới ────────────────────────────────────────────
	IF NOT EXISTS (SELECT 1 FROM Category WHERE category_name = N'Kinh tế - Tài chính')
		INSERT INTO Category (category_name) VALUES (N'Kinh tế - Tài chính');

	IF NOT EXISTS (SELECT 1 FROM Category WHERE category_name = N'Khoa học tự nhiên')
		INSERT INTO Category (category_name) VALUES (N'Khoa học tự nhiên');

	IF NOT EXISTS (SELECT 1 FROM Category WHERE category_name = N'Lịch sử - Địa lý')
		INSERT INTO Category (category_name) VALUES (N'Lịch sử - Địa lý');

	IF NOT EXISTS (SELECT 1 FROM Category WHERE category_name = N'Ngoại ngữ')
		INSERT INTO Category (category_name) VALUES (N'Ngoại ngữ');

	DECLARE @catEcon INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Kinh tế - Tài chính');
	DECLARE @catSci INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Khoa học tự nhiên');
	DECLARE @catHist INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Lịch sử - Địa lý');
	DECLARE @catLang INT = (SELECT TOP 1 category_id FROM Category WHERE category_name = N'Ngoại ngữ');

	-- ── Sách bổ sung (ISBN-010 → ISBN-022) ───────────────────────────
	IF @catTech IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-010')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Lập trình Web với React.js', N'Nguyễn Hoàng Nam', @catTech, 185000, 6, 'ISBN-010', 'assets/images/books/react.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-011')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Clean Code – Viết code sạch', N'Robert C. Martin', @catTech, 210000, 4, 'ISBN-011', 'assets/images/books/clean_code.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-012')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Docker & Kubernetes thực chiến', N'Trần Đức Anh', @catTech, 220000, 5, 'ISBN-012', 'assets/images/books/docker_k8s.jpg');
	END;

	IF @catLit IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-013')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Số đỏ', N'Vũ Trọng Phụng', @catLit, 75000, 9, 'ISBN-013', 'assets/images/books/so_do.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-014')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Chí Phèo và các truyện ngắn', N'Nam Cao', @catLit, 80000, 11, 'ISBN-014', 'assets/images/books/chi_pheo.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-015')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Bỉ vỏ', N'Nguyên Hồng', @catLit, 69000, 8, 'ISBN-015', 'assets/images/books/bi_vo.jpg');
	END;

	IF @catSkills IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-016')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Đắc nhân tâm', N'Dale Carnegie', @catSkills, 98000, 15, 'ISBN-016', 'assets/images/books/dac_nhan_tam.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-017')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'7 thói quen của người thành đạt', N'Stephen R. Covey', @catSkills, 115000, 7, 'ISBN-017', 'assets/images/books/7_habits.jpg');
	END;

	IF @catHighSchool IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-018')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Lý thuyết Hóa học lớp 12', N'Phạm Văn Hùng', @catHighSchool, 125000, 6, 'ISBN-018', 'assets/images/books/hoa12.jpg');
	END;

	IF @catEcon IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-019')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Kinh tế học vi mô', N'Nguyễn Thu Hương', @catEcon, 145000, 8, 'ISBN-019', 'assets/images/books/kinh_te_vi_mo.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-020')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Phân tích tài chính doanh nghiệp', N'Bùi Thị Ngọc', @catEcon, 168000, 5, 'ISBN-020', 'assets/images/books/tai_chinh.jpg');
	END;

	IF @catSci IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-021')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Vật lý đại cương – Tập 1', N'Lương Duyên Bình', @catSci, 138000, 7, 'ISBN-021', 'assets/images/books/vat_ly.jpg');
	END;

	IF @catHist IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-022')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Đại cương lịch sử Việt Nam – Tập 2', N'Trương Hữu Quýnh', @catHist, 105000, 10, 'ISBN-022', 'assets/images/books/lich_su.jpg');
	END;

	IF @catLang IS NOT NULL
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-023')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'TOEIC 900+ – Chinh phục điểm tối đa', N'Dương Thị Mai', @catLang, 155000, 6, 'ISBN-023', 'assets/images/books/toeic.jpg');

		IF NOT EXISTS (SELECT 1 FROM Book WHERE isbn = 'ISBN-024')
			INSERT INTO Book (title, author, category_id, price, quantity, isbn, image)
			VALUES (N'Tiếng Nhật sơ cấp – Minna no Nihongo', N'3A Corporation', @catLang, 172000, 4, 'ISBN-024', 'assets/images/books/nihongo.jpg');
	END;

	DECLARE @bookJava INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-001');
	DECLARE @bookSql INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-002');
	DECLARE @bookTatDen INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-003');
	DECLARE @bookPython INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-004');
	DECLARE @bookMicro INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-005');
	DECLARE @bookKieu INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-006');
	DECLARE @bookDeMen INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-007');
	DECLARE @bookSkills INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-008');
	DECLARE @bookToan INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-009');
	DECLARE @bookReact INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-010');
	DECLARE @bookClean INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-011');
	DECLARE @bookDocker INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-012');
	DECLARE @bookSoDo INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-013');
	DECLARE @bookChiPheo INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-014');
	DECLARE @book7Habits INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-017');
	DECLARE @bookToeic INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-023');

	IF @bookJava IS NULL OR @bookSql IS NULL OR @bookTatDen IS NULL
	BEGIN
		THROW 50002, N'Không tìm thấy sách mẫu ISBN-001 đến ISBN-003. Hãy chạy schema.sql bản hiện tại trước.', 1;
	END;

	-- =============================================
	-- Dọn dữ liệu demo cũ để script có thể chạy lại nhiều lần.
	-- =============================================
	IF OBJECT_ID('shipments', 'U') IS NOT NULL
	BEGIN
		DELETE s
		FROM shipments s
		INNER JOIN borrow_records br ON br.id = s.borrow_record_id
		WHERE br.group_code LIKE 'DEMO-%';
	END;

	IF OBJECT_ID('renewal_requests', 'U') IS NOT NULL
	BEGIN
		DELETE rr
		FROM renewal_requests rr
		INNER JOIN borrow_records br ON br.id = rr.borrow_id
		WHERE br.group_code LIKE 'DEMO-%';
	END;

	IF OBJECT_ID('password_reset_token', 'U') IS NOT NULL
	BEGIN
		DELETE FROM password_reset_token WHERE token LIKE 'DEMO-%';
	END;

	DELETE FROM borrow_records WHERE group_code LIKE 'DEMO-%';

	-- Dọn Comment, reservations, wallet_transaction, notifications của các tài khoản demo.
	IF OBJECT_ID('Comment', 'U') IS NOT NULL
	BEGIN
		DELETE FROM Comment WHERE user_id IN (
			@userId, @member2Id, @member3Id, @member4Id,
			@member5Id, @member6Id, @member7Id, @member8Id
		);
	END;

	IF OBJECT_ID('reservations', 'U') IS NOT NULL
	BEGIN
		DELETE FROM reservations WHERE user_id IN (
			@userId, @member2Id, @member3Id, @member4Id,
			@member5Id, @member6Id, @member7Id, @member8Id
		);
	END;

	IF OBJECT_ID('wallet_transaction', 'U') IS NOT NULL
	BEGIN
		DELETE FROM wallet_transaction WHERE reference LIKE 'DEMO-%';
	END;

	IF OBJECT_ID('notifications', 'U') IS NOT NULL
	BEGIN
		DELETE FROM notifications WHERE user_id IN (
			@userId, @member2Id, @member3Id, @member4Id,
			@member5Id, @member6Id, @member7Id, @member8Id
		);
	END;

	-- =============================================
	-- Seed bộ đơn mượn/trả đa trạng thái.
	-- =============================================
	INSERT INTO borrow_records (
		user_id, book_id, borrow_date, due_date, return_date, status,
		fine_amount, is_paid, reject_reason, borrow_method, quantity,
		deposit_amount, group_code, shipping_recipient, shipping_phone,
		shipping_street, shipping_residence, shipping_ward, shipping_district,
		shipping_city, created_at
	)
	VALUES
		-- Đơn online đang chờ duyệt: 2 sách trong cùng 1 đơn.
		(@userId, @bookJava, NULL, NULL, NULL, 'REQUESTED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-REQ-001',
			N'Lê Văn C', '0901000003', N'12 Nguyễn Trãi', N'Chung cư Minh Khai', N'Phường 5', N'Quận 5', N'TP. Hồ Chí Minh', DATEADD(HOUR, -18, GETDATE())),
		(@userId, @bookSql, NULL, NULL, NULL, 'REQUESTED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-REQ-001',
			N'Lê Văn C', '0901000003', N'12 Nguyễn Trãi', N'Chung cư Minh Khai', N'Phường 5', N'Quận 5', N'TP. Hồ Chí Minh', DATEADD(HOUR, -18, GETDATE())),

		-- Đang mượn còn hạn.
		(@userId, @bookTatDen, DATEADD(DAY, -3, @today), DATEADD(DAY, 4, @today), NULL, 'BORROWED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-BORROW-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -3, GETDATE())),

		-- Đã trả đúng hạn.
		(@userId, @bookSql, DATEADD(DAY, -24, @today), DATEADD(DAY, -17, @today), DATEADD(DAY, -19, @today), 'RETURNED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-RETURN-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -24, GETDATE())),

		-- Đơn online đã duyệt, chờ tạo giao hàng / xác nhận nhận sách.
		(@member2Id, @bookJava, NULL, NULL, NULL, 'APPROVED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-APPROVED-001',
			N'Phạm Thu Trang', '0901000004', N'45 Điện Biên Phủ', N'Tòa nhà Pearl Plaza', N'Phường 25', N'Bình Thạnh', N'TP. Hồ Chí Minh', DATEADD(HOUR, -10, GETDATE())),
		(@member2Id, @bookTatDen, NULL, NULL, NULL, 'APPROVED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-APPROVED-001',
			N'Phạm Thu Trang', '0901000004', N'45 Điện Biên Phủ', N'Tòa nhà Pearl Plaza', N'Phường 25', N'Bình Thạnh', N'TP. Hồ Chí Minh', DATEADD(HOUR, -10, GETDATE())),

		-- Đang mượn quá hạn, chưa trả.
		(@member2Id, @bookSql, DATEADD(DAY, -18, @today), DATEADD(DAY, -4, @today), NULL, 'BORROWED', 20000, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-OVERDUE-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -18, GETDATE())),

		-- Đã nhận sách từ thủ thư, còn hạn.
		(@member3Id, @bookJava, DATEADD(DAY, -1, @today), DATEADD(DAY, 6, @today), NULL, 'RECEIVED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-RECEIVED-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -1, GETDATE())),

		-- Đang chờ duyệt gia hạn.
		(@member3Id, @bookTatDen, DATEADD(DAY, -8, @today), DATEADD(DAY, 1, @today), NULL, 'RENEWAL_REQUESTED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-RENEW-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -8, GETDATE())),

		-- Đã trả trễ hạn, chưa nộp phạt.
		(@member4Id, @bookTatDen, DATEADD(DAY, -25, @today), DATEADD(DAY, -18, @today), DATEADD(DAY, -14, @today), 'RETURNED', 20000, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-LATE-UNPAID-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -25, GETDATE())),

		-- Đã trả trễ hạn và đã thanh toán tiền phạt.
		(@member4Id, @bookJava, DATEADD(DAY, -40, @today), DATEADD(DAY, -30, @today), DATEADD(DAY, -27, @today), 'RETURNED', 15000, 1, NULL, 'IN_PERSON', 1, 50000, 'DEMO-LATE-PAID-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -40, GETDATE())),

		-- Đơn bị từ chối.
		(@member4Id, @bookSql, NULL, NULL, NULL, 'REJECTED', 0, 0, N'Độc giả đang còn phiếu mượn quá hạn cần xử lý trước.', 'ONLINE', 1, 50000, 'DEMO-REJECTED-001',
			N'Ngô Hải Yến', '0901000006', N'25 Trần Phú', N'Khách sạn mini đối diện biển', N'Phường Lộc Thọ', N'TP. Nha Trang', N'Khánh Hòa', DATEADD(HOUR, -7, GETDATE())),

		-- Đơn đã hủy bởi người dùng.
		(@member4Id, @bookJava, NULL, NULL, NULL, 'CANCELLED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-CANCELLED-001',
			N'Ngô Hải Yến', '0901000006', N'25 Trần Phú', N'Khách sạn mini đối diện biển', N'Phường Lộc Thọ', N'TP. Nha Trang', N'Khánh Hòa', DATEADD(HOUR, -5, GETDATE())),

		-- ── member5: đang mượn 2 sách còn hạn ───────────────────────
		(@member5Id, @bookPython, DATEADD(DAY, -5, @today), DATEADD(DAY, 9, @today), NULL, 'BORROWED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M5-BORROW-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -5, GETDATE())),
		(@member5Id, @bookClean, DATEADD(DAY, -5, @today), DATEADD(DAY, 9, @today), NULL, 'BORROWED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M5-BORROW-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -5, GETDATE())),

		-- member5: đã trả đúng hạn (lịch sử)
		(@member5Id, @bookSkills, DATEADD(DAY, -35, @today), DATEADD(DAY, -22, @today), DATEADD(DAY, -25, @today), 'RETURNED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M5-RETURN-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -35, GETDATE())),

		-- member5: đơn online mới REQUESTED, 3 sách
		(@member5Id, @bookReact, NULL, NULL, NULL, 'REQUESTED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-M5-REQ-001',
			N'Đặng Thị Lan', '0901000007', N'33 Lê Lợi', N'Cao ốc văn phòng Harbour View', N'Phường Bến Nghé', N'Quận 1', N'TP. Hồ Chí Minh', DATEADD(HOUR, -2, GETDATE())),
		(@member5Id, @bookDocker, NULL, NULL, NULL, 'REQUESTED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-M5-REQ-001',
			N'Đặng Thị Lan', '0901000007', N'33 Lê Lợi', N'Cao ốc văn phòng Harbour View', N'Phường Bến Nghé', N'Quận 1', N'TP. Hồ Chí Minh', DATEADD(HOUR, -2, GETDATE())),
		(@member5Id, @bookToeic, NULL, NULL, NULL, 'REQUESTED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-M5-REQ-001',
			N'Đặng Thị Lan', '0901000007', N'33 Lê Lợi', N'Cao ốc văn phòng Harbour View', N'Phường Bến Nghé', N'Quận 1', N'TP. Hồ Chí Minh', DATEADD(HOUR, -2, GETDATE())),

		-- ── member6: đang mượn quá hạn + đã trả trễ (đã thanh toán) ─
		(@member6Id, @bookMicro, DATEADD(DAY, -22, @today), DATEADD(DAY, -8, @today), NULL, 'BORROWED', 35000, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M6-OVERDUE-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -22, GETDATE())),
		(@member6Id, @bookSoDo, DATEADD(DAY, -50, @today), DATEADD(DAY, -36, @today), DATEADD(DAY, -32, @today), 'RETURNED', 20000, 1, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M6-LATEPAID-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -50, GETDATE())),

		-- member6: đơn APPROVED online
		(@member6Id, @bookKieu, NULL, NULL, NULL, 'APPROVED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-M6-APPROVED-001',
			N'Bùi Quang Huy', '0901000008', N'17 Bạch Đằng', N'Chung cư The Song', N'Phường Thuận Phước', N'Hải Châu', N'Đà Nẵng', DATEADD(HOUR, -4, GETDATE())),
		(@member6Id, @bookChiPheo, NULL, NULL, NULL, 'APPROVED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-M6-APPROVED-001',
			N'Bùi Quang Huy', '0901000008', N'17 Bạch Đằng', N'Chung cư The Song', N'Phường Thuận Phước', N'Hải Châu', N'Đà Nẵng', DATEADD(HOUR, -4, GETDATE())),

		-- ── member7: đang chờ gia hạn + mượn cũ đã trả ──────────────
		(@member7Id, @book7Habits, DATEADD(DAY, -12, @today), DATEADD(DAY, -5, @today), NULL, 'RENEWAL_REQUESTED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M7-RENEW-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -12, GETDATE())),
		(@member7Id, @bookToan, DATEADD(DAY, -60, @today), DATEADD(DAY, -47, @today), DATEADD(DAY, -50, @today), 'RETURNED', 0, 0, NULL, 'IN_PERSON', 1, 50000, 'DEMO-M7-RETURN-001',
			NULL, NULL, NULL, NULL, NULL, NULL, NULL, DATEADD(DAY, -60, GETDATE())),

		-- member7: đã nhận sách (RECEIVED) qua giao hàng
		(@member7Id, @bookPython, DATEADD(DAY, -2, @today), DATEADD(DAY, 12, @today), NULL, 'RECEIVED', 0, 0, NULL, 'ONLINE', 1, 50000, 'DEMO-M7-RECEIVED-001',
			N'Trương Ngọc Ánh', '0901000009', N'56 Trần Hưng Đạo', N'Chung cư Goldmark City', N'Phường Hàng Bài', N'Hoàn Kiếm', N'Hà Nội', DATEADD(DAY, -2, GETDATE())),

		-- ── member8 (LOCKED): đơn bị từ chối vì tài khoản bị khóa ───
		(@member8Id, @bookJava, NULL, NULL, NULL, 'REJECTED', 0, 0, N'Tài khoản bị khóa, không thể xử lý yêu cầu.', 'ONLINE', 1, 50000, 'DEMO-M8-REJECTED-001',
			N'Đinh Văn Tùng', '0901000010', N'9 Lý Tự Trọng', NULL, N'Phường Tân An', N'Ninh Kiều', N'Cần Thơ', DATEADD(HOUR, -1, GETDATE()));

	-- =============================================
	-- Seed yêu cầu gia hạn.
	-- =============================================
	IF OBJECT_ID('renewal_requests', 'U') IS NOT NULL
	BEGIN
		DECLARE @renewBorrowId BIGINT = (
			SELECT TOP 1 id FROM borrow_records
			WHERE group_code = 'DEMO-RENEW-001' ORDER BY id DESC
		);
		DECLARE @renewM7BorrowId BIGINT = (
			SELECT TOP 1 id FROM borrow_records
			WHERE group_code = 'DEMO-M7-RENEW-001' ORDER BY id DESC
		);

		INSERT INTO renewal_requests (borrow_id, user_id, reason, contact_name, contact_phone, contact_email, status, requested_at)
		VALUES
			(@renewBorrowId, @member3Id,
				N'Cần thêm thời gian để hoàn thành bài tập nhóm môn cơ sở dữ liệu.',
				N'Võ Minh Khôi', '0901000005', 'member3@gmail.com', 'PENDING',
				DATEADD(HOUR, -6, GETDATE())),
			(@renewM7BorrowId, @member7Id,
				N'Chưa đọc xong, muốn gia hạn thêm 7 ngày để áp dụng thực tiễn vào công việc.',
				N'Trương Ngọc Ánh', '0901000009', 'member7@gmail.com', 'PENDING',
				DATEADD(HOUR, -3, GETDATE()));
	END;

	-- =============================================
	-- Seed bình luận sách.
	-- =============================================
	IF OBJECT_ID('Comment', 'U') IS NOT NULL
	BEGIN
		INSERT INTO Comment (book_id, user_id, content, rating, status, created_at)
		VALUES
			-- Java
			(@bookJava, @userId, N'Sách rất hay, phù hợp cho người mới bắt đầu học Java. Giải thích rõ ràng, ví dụ thực tế.', 5, 'VISIBLE', DATEADD(DAY, -20, GETDATE())),
			(@bookJava, @member2Id, N'Nội dung súc tích, dễ hiểu. Tuy nhiên thiếu phần về Java 17+ mới nhất.', 4, 'VISIBLE', DATEADD(DAY, -15, GETDATE())),
			(@bookJava, @member5Id, N'Đọc lần hai vẫn thấy nhiều điều mới. Tác giả giải thích OOP rất tốt.', 5, 'VISIBLE', DATEADD(DAY, -8, GETDATE())),
			(@bookJava, @member6Id, N'Sách ổn nhưng một số ví dụ code cần cập nhật theo chuẩn mới hơn.', 3, 'VISIBLE', DATEADD(DAY, -3, GETDATE())),

			-- SQL
			(@bookSql, @userId, N'30 ngày học SQL theo sách này thấy hiệu quả thực sự. Bài tập phong phú.', 5, 'VISIBLE', DATEADD(DAY, -19, GETDATE())),
			(@bookSql, @member3Id, N'Nội dung tốt nhưng tập trung nhiều vào MySQL, thiếu phần SQL Server.', 3, 'VISIBLE', DATEADD(DAY, -10, GETDATE())),
			(@bookSql, @member7Id, N'Phù hợp cả người học lẫn ôn luyện. Cách trình bày logic, dễ theo dõi.', 4, 'VISIBLE', DATEADD(DAY, -5, GETDATE())),

			-- Tắt đèn
			(@bookTatDen, @member4Id, N'Tác phẩm kinh điển, phản ánh chân thực xã hội phong kiến. Buồn mà đẹp.', 5, 'VISIBLE', DATEADD(DAY, -14, GETDATE())),
			(@bookTatDen, @member5Id, N'Đọc trong một buổi tối không dứt ra được. Ngô Tất Tố viết quá hay.', 5, 'VISIBLE', DATEADD(DAY, -9, GETDATE())),
			(@bookTatDen, @member6Id, N'Bản in này chất lượng tốt, chú thích đầy đủ cho từ cổ.', 4, 'VISIBLE', DATEADD(DAY, -2, GETDATE())),

			-- Python
			(@bookPython, @member5Id, N'Phần decorator và generator được giải thích rất rõ. Học xong thấy code Python của mình sạch hơn nhiều.', 5, 'VISIBLE', DATEADD(DAY, -4, GETDATE())),
			(@bookPython, @member7Id, N'Tốt nhưng cần pre-requisite là đã biết Python cơ bản. Không phù hợp cho người mới.', 3, 'VISIBLE', DATEADD(DAY, -1, GETDATE())),

			-- Microservices
			(@bookMicro, @member6Id, N'Sách lý thú, giúp tôi hiểu tại sao cần microservices và khi nào nên áp dụng.', 4, 'VISIBLE', DATEADD(DAY, -6, GETDATE())),

			-- Kỹ năng mềm
			(@bookSkills, @member5Id, N'Đọc trong 2 buổi chiều. Lời khuyên thực tế, không hoa mỹ. Rất hữu ích cho sinh viên năm cuối.', 4, 'VISIBLE', DATEADD(DAY, -30, GETDATE())),
			(@bookSkills, @member7Id, N'Nội dung quen thuộc nhưng được trình bày mới mẻ, có ví dụ từ thực tiễn Việt Nam.', 4, 'VISIBLE', DATEADD(DAY, -18, GETDATE())),

			-- Đắc nhân tâm
			(@bookKieu, @member6Id, N'Bản dịch mới này sát nghĩa hơn các bản cũ. Rất nên đọc.', 5, 'VISIBLE', DATEADD(DAY, -7, GETDATE())),

			-- Clean Code
			(@bookClean, @member5Id, N'Mỗi chương là một bài học quý giá về cách viết code mà đồng nghiệp còn hiểu được sau 6 tháng.', 5, 'VISIBLE', DATEADD(DAY, -3, GETDATE())),

			-- Số đỏ
			(@bookSoDo, @member6Id, N'Đọc mà cười ra nước mắt. Vũ Trọng Phụng châm biếm sắc bén quá!', 5, 'VISIBLE', DATEADD(DAY, -28, GETDATE())),
			(@bookSoDo, @member7Id, N'Tái bản đẹp, có tranh minh họa. Cần thêm phần chú giải từ ngữ thời cũ.', 4, 'VISIBLE', DATEADD(DAY, -12, GETDATE()));
	END;

	-- =============================================
	-- Seed đặt trước sách.
	-- =============================================
	IF OBJECT_ID('reservations', 'U') IS NOT NULL
	BEGIN
		INSERT INTO reservations (user_id, book_id, status, queue_position, note, notified_at, expired_at, created_at)
		VALUES
			-- Java hết sách, 3 người xếp hàng chờ
			(@member5Id, @bookClean, 'WAITING', 1, N'Cần đọc gấp để chuẩn bị cho dự án cuối kỳ.', NULL, NULL, DATEADD(DAY, -5, GETDATE())),
			(@member6Id, @bookClean, 'WAITING', 2, NULL, NULL, NULL, DATEADD(DAY, -4, GETDATE())),
			(@member7Id, @bookClean, 'WAITING', 3, NULL, NULL, NULL, DATEADD(DAY, -2, GETDATE())),

			-- Đã được thông báo, còn 2 ngày để đến nhận
			(@member3Id, @bookDocker, 'NOTIFIED', NULL, NULL,
				DATEADD(DAY, -1, GETDATE()), DATEADD(DAY, 2, GETDATE()),
				DATEADD(DAY, -10, GETDATE())),

			-- Đặt trước đã hết hạn (chưa đến nhận lúc được thông báo)
			(@member4Id, @bookReact, 'EXPIRED', NULL, NULL,
				DATEADD(DAY, -8, GETDATE()), DATEADD(DAY, -5, GETDATE()),
				DATEADD(DAY, -20, GETDATE())),

			-- Đặt trước đã bị hủy bởi thành viên
			(@member8Id, @bookPython, 'CANCELLED', NULL, N'Không cần nữa.', NULL, NULL, DATEADD(DAY, -15, GETDATE())),

			-- Docker: member2 đang xếp hàng chờ
			(@member2Id, @bookMicro, 'WAITING', 1, NULL, NULL, NULL, DATEADD(DAY, -3, GETDATE()));
	END;

	-- =============================================
	-- Seed lịch sử giao dịch ví.
	-- =============================================
	IF OBJECT_ID('wallet_transaction', 'U') IS NOT NULL
	BEGIN
		INSERT INTO wallet_transaction (user_id, type, source, description, amount, reference, created_at)
		VALUES
			-- member5: nạp ví 2 lần
			(@member5Id, 'TOPUP', N'VNPay Sandbox', N'Nạp 200.000 ₫ vào ví', 200000, 'DEMO-WALLET-M5-001', DATEADD(DAY, -30, GETDATE())),

			-- member6: nạp ví 3 lần
			(@member6Id, 'TOPUP', N'VNPay Sandbox', N'Nạp 100.000 ₫ vào ví', 100000, 'DEMO-WALLET-M6-001', DATEADD(DAY, -45, GETDATE())),
			(@member6Id, 'TOPUP', N'VNPay Sandbox', N'Nạp 200.000 ₫ vào ví', 200000, 'DEMO-WALLET-M6-002', DATEADD(DAY, -20, GETDATE())),
			(@member6Id, 'TOPUP', N'VNPay Sandbox', N'Nạp 200.000 ₫ vào ví', 200000, 'DEMO-WALLET-M6-003', DATEADD(DAY, -5, GETDATE())),

			-- member7: nạp ví 1 lần
			(@member7Id, 'TOPUP', N'VNPay Sandbox', N'Nạp 150.000 ₫ vào ví', 150000, 'DEMO-WALLET-M7-001', DATEADD(DAY, -10, GETDATE())),

			-- user (member1): nạp ví
			(@userId, 'TOPUP', N'VNPay Sandbox', N'Nạp 500.000 ₫ vào ví', 500000, 'DEMO-WALLET-U1-001', DATEADD(DAY, -60, GETDATE())),
			(@userId, 'TOPUP', N'VNPay Sandbox', N'Nạp 300.000 ₫ vào ví', 300000, 'DEMO-WALLET-U1-002', DATEADD(DAY, -25, GETDATE()));
	END;

	-- =============================================
	-- Seed thông báo.
	-- =============================================
	IF OBJECT_ID('notifications', 'U') IS NOT NULL
	BEGIN
		INSERT INTO notifications (user_id, type, title, message, is_read, created_at)
		VALUES
			-- member3: đặt trước sách Docker đã sẵn sàng để nhận
			(@member3Id, 'RESERVATION_AVAILABLE',
				N'Sách đã sẵn sàng để nhận!',
				N'Cuốn sách "Docker & Kubernetes thực chiến" bạn đặt trước đã có sẵn. Vui lòng đến thư viện nhận sách trong vòng 3 ngày. Nếu không đến đúng hạn, đặt trước sẽ bị hủy tự động.',
				0, DATEADD(DAY, -1, GETDATE())),

			-- member3: nhắc sắp hết hạn nhận sách Docker
			(@member3Id, 'RESERVATION_EXPIRING',
				N'Sắp hết hạn nhận sách!',
				N'Bạn chỉ còn 1 ngày để nhận cuốn sách "Docker & Kubernetes thực chiến". Hạn cuối: 23:59 - ngày mai.',
				0, DATEADD(HOUR, -6, GETDATE())),

			-- member4: đặt trước React bị hủy do hết hạn
			(@member4Id, 'RESERVATION_EXPIRED',
				N'Đặt trước đã bị hủy do hết hạn',
				N'Đặt trước cho cuốn sách "Lập trình Web với React.js" đã bị hủy tự động vì bạn không đến nhận trong 3 ngày. Bạn có thể đặt trước lại nếu muốn.',
				1, DATEADD(DAY, -5, GETDATE())),

			-- member8: đặt trước Python đã hủy
			(@member8Id, 'RESERVATION_CANCELLED',
				N'Đặt trước đã được hủy',
				N'Đặt trước cho cuốn sách "Lập trình Python nâng cao" đã được hủy thành công.',
				1, DATEADD(DAY, -15, GETDATE())),

			-- member5: thông báo sách đặt trước (Clean Code) có người khác trả
			(@member5Id, 'RESERVATION_AVAILABLE',
				N'Sách đã sẵn sàng để nhận!',
				N'Cuốn sách "Clean Code – Viết code sạch" bạn đặt trước đã có sẵn. Vui lòng đến thư viện nhận sách trong vòng 3 ngày.',
				0, DATEADD(HOUR, -2, GETDATE())),

			-- member2: nhắc đặt trước microservices
			(@member2Id, 'RESERVATION_AVAILABLE',
				N'Sách đã sẵn sàng để nhận!',
				N'Cuốn sách "Thiết kế hệ thống microservices" bạn đặt trước đã có sẵn. Vui lòng đến thư viện nhận sách trong vòng 3 ngày.',
				0, GETDATE());
	END;

	-- =============================================
	-- Seed mã đặt lại mật khẩu.
	-- =============================================
	IF OBJECT_ID('password_reset_token', 'U') IS NOT NULL
	BEGIN
		INSERT INTO password_reset_token (user_id, token, expired_at, used, created_at)
		VALUES
			(@userId, 'DEMO-RESET-USER', DATEADD(HOUR, 2, GETDATE()), 0, GETDATE()),
			(@member3Id, 'DEMO-RESET-MEMBER3', DATEADD(HOUR, 1, GETDATE()), 0, GETDATE()),
			(@member6Id, 'DEMO-RESET-MEMBER6', DATEADD(MINUTE, 30, GETDATE()), 0, GETDATE());
	END;

	COMMIT TRANSACTION;

	PRINT N'Seed demo data completed successfully.';
	PRINT N'Accounts: admin@gmail.com / librarian@gmail.com / user@gmail.com / member2@gmail.com ~ member8@gmail.com';
	PRINT N'Common password: 123456  |  member8 is LOCKED';
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	THROW;
END CATCH;
