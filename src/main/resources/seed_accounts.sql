USE LibraryDB;
GO

-- ROLE
INSERT INTO Role (role_name) VALUES
(N'Admin'),
(N'Librarian'),
(N'Member');

-- USER
INSERT INTO [User] (name, email, password, role_id) VALUES
(N'Nguyễn Văn A', 'admin@gmail.com', '123456', 1),
(N'Trần Thị B', 'librarian@gmail.com', '123456', 2),
(N'Lê Văn C', 'user@gmail.com', '123456', 3);

-- PERMISSION
INSERT INTO Permission (permission_name, role_id) VALUES
(N'Manage Users', 1),
(N'Manage Books', 1),
(N'Manage Borrowing', 2),
(N'View Books', 3),
(N'Borrow Books', 3);

-- CATEGORY
INSERT INTO Category (category_name) VALUES
(N'Sách giáo khoa'),
(N'Văn học Việt Nam'),
(N'Kỹ năng sống'),
(N'Công nghệ thông tin');

-- BOOK (SÁCH VIỆT NAM)
INSERT INTO Book (title, author, price, availability, category_id) VALUES
(N'Toán lớp 12', N'Bộ GD&ĐT', 25000, 1, 1),
(N'Ngữ văn lớp 12', N'Bộ GD&ĐT', 24000, 1, 1),
(N'Tắt đèn', N'Ngô Tất Tố', 60000, 1, 2),
(N'Lão Hạc', N'Nam Cao', 55000, 1, 2),
(N'Đắc nhân tâm', N'Dale Carnegie', 90000, 1, 3),
(N'Lập trình Java cơ bản', N'Nguyễn Văn Minh', 120000, 1, 4),
(N'Học SQL trong 30 ngày', N'Trần Hoàng', 110000, 1, 4);

-- CART
INSERT INTO Cart (user_id) VALUES
(3);

-- CART ITEM
INSERT INTO CartItem (cart_id, book_id, quantity) VALUES
(1, 3, 1),
(1, 6, 2);

-- BORROWING
INSERT INTO Borrowing (user_id, borrow_date, return_date, status) VALUES
(3, GETDATE(), DATEADD(DAY, 14, GETDATE()), N'Borrowed');

-- BORROW ITEM
INSERT INTO BorrowItem (borrowing_id, book_id, quantity) VALUES
(1, 3, 1),
(1, 6, 1);

-- DELIVERY
INSERT INTO Delivery (borrowing_id, delivery_status, shipping_code) VALUES
(1, N'Đang giao', 'SHIP001');

-- PAYMENT
INSERT INTO Payment (borrowing_id, amount, payment_date, method) VALUES
(1, 180000, GETDATE(), N'COD');

-- FEEDBACK
INSERT INTO Feedback (user_id, book_id, content, rating, created_at) VALUES
(3, 3, N'Sách rất hay, phản ánh xã hội xưa', 5, GETDATE()),
(3, 6, N'Dễ hiểu cho người mới học Java', 4, GETDATE());

-- NOTIFICATION
INSERT INTO Notification (user_id, message, created_at) VALUES
(3, N'Bạn đã mượn sách thành công!', GETDATE()),
(3, N'Sách đang được giao tới bạn.', GETDATE());

-- PASSWORD RESET TOKEN (TEST)
INSERT INTO password_reset_token (user_id, token, expired_at, used)
VALUES (3, 'ABC123TOKEN', DATEADD(HOUR, 1, GETDATE()), 0);
