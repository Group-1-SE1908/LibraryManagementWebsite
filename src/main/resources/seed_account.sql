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

	DECLARE @userId INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'user@gmail.com');
	DECLARE @member2Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member2@gmail.com');
	DECLARE @member3Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member3@gmail.com');
	DECLARE @member4Id INT = (SELECT TOP 1 user_id FROM [User] WHERE email = 'member4@gmail.com');

	DECLARE @bookJava INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-001');
	DECLARE @bookSql INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-002');
	DECLARE @bookTatDen INT = (SELECT TOP 1 book_id FROM Book WHERE isbn = 'ISBN-003');

	IF @bookJava IS NULL OR @bookSql IS NULL OR @bookTatDen IS NULL
	BEGIN
		THROW 50002, N'Không tìm thấy sách mẫu ISBN-001 đến ISBN-003. Hãy chạy schema.sql bản hiện tại trước.', 1;
	END;

	-- Dọn dữ liệu demo cũ để script có thể chạy lại nhiều lần.
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

	-- Seed bộ đơn mượn/trả đa trạng thái để demo lịch sử, quản lý mượn và quản lý phạt.
	INSERT INTO borrow_records (
		user_id,
		book_id,
		borrow_date,
		due_date,
		return_date,
		status,
		fine_amount,
		is_paid,
		reject_reason,
		borrow_method,
		quantity,
		deposit_amount,
		group_code,
		shipping_recipient,
		shipping_phone,
		shipping_street,
		shipping_residence,
		shipping_ward,
		shipping_district,
		shipping_city,
		created_at
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
			N'Ngô Hải Yến', '0901000006', N'25 Trần Phú', N'Khách sạn mini đối diện biển', N'Phường Lộc Thọ', N'TP. Nha Trang', N'Khánh Hòa', DATEADD(HOUR, -5, GETDATE()));

	IF OBJECT_ID('renewal_requests', 'U') IS NOT NULL
	BEGIN
		DECLARE @renewBorrowId BIGINT = (
			SELECT TOP 1 id
			FROM borrow_records
			WHERE group_code = 'DEMO-RENEW-001'
			ORDER BY id DESC
		);

		INSERT INTO renewal_requests (
			borrow_id,
			user_id,
			reason,
			contact_name,
			contact_phone,
			contact_email,
			status,
			requested_at
		)
		VALUES (
			@renewBorrowId,
			@member3Id,
			N'Cần thêm thời gian để hoàn thành bài tập nhóm môn cơ sở dữ liệu.',
			N'Võ Minh Khôi',
			'0901000005',
			'member3@gmail.com',
			'PENDING',
			DATEADD(HOUR, -6, GETDATE())
		);
	END;

	IF OBJECT_ID('password_reset_token', 'U') IS NOT NULL
	BEGIN
		INSERT INTO password_reset_token (user_id, token, expired_at, used, created_at)
		VALUES
			(@userId, 'DEMO-RESET-USER', DATEADD(HOUR, 2, GETDATE()), 0, GETDATE()),
			(@member3Id, 'DEMO-RESET-MEMBER3', DATEADD(HOUR, 1, GETDATE()), 0, GETDATE());
	END;

	COMMIT TRANSACTION;

	PRINT N'Seed demo borrowing data completed successfully.';
	PRINT N'Demo login: admin@gmail.com / librarian@gmail.com / user@gmail.com / member2@gmail.com / member3@gmail.com / member4@gmail.com';
	PRINT N'Common password for all demo accounts: 123456';
END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION;

	THROW;
END CATCH;
