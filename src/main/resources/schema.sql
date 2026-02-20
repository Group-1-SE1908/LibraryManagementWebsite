/*
===========================================================================
 PROJECT: LIBRARY MANAGEMENT SYSTEM (LBMS)
 DATABASE: LibraryDB
 TYPE: SQL SERVER
 UPDATED: Tích hợp Computed Column cho Availability (Tự động tính toán)
===========================================================================
*/

USE master;
GO

-- 1. XÓA DB CŨ NẾU TỒN TẠI (Để tạo mới sạch sẽ)
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'LibraryDB')
BEGIN
    ALTER DATABASE LibraryDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE LibraryDB;
END
GO

CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

-- =============================================
-- 2. TẠO CÁC BẢNG (TABLES)
-- =============================================

-- Bảng 1: Phân quyền (Role)
CREATE TABLE Role (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Bảng 2: Người dùng (User)
CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- Mật khẩu (nên mã hóa MD5/BCrypt)
    full_name NVARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    address NVARCHAR(255) NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, LOCKED
    role_id INT NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_User_Role FOREIGN KEY (role_id) REFERENCES Role(role_id)
);
GO

-- Bảng 3: Thể loại sách (Category)
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Bảng 4: Sách (Book) - TÍCH HỢP CỘT TỰ ĐỘNG
CREATE TABLE Book (
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    author NVARCHAR(255) NOT NULL,
    category_id INT,
    
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 0,    -- Số lượng tồn kho
    isbn VARCHAR(50) NOT NULL UNIQUE,   -- Mã sách (ISBN)
    image NVARCHAR(500) NULL,           -- Đường dẫn ảnh (assets/images/...)
    
    -- --- CỘT TỰ ĐỘNG (COMPUTED COLUMN) ---
    -- Tự động trả về 1 nếu quantity > 0, ngược lại là 0.
    -- Không cần Insert/Update vào cột này.
    availability AS (CASE WHEN quantity > 0 THEN 1 ELSE 0 END),
    
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Book_Category FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE SET NULL
);
GO

-- Bảng 5: Quản lý Mượn Trả (Borrow Records)
CREATE TABLE borrow_records (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    borrow_date DATE NULL,
    due_date DATE NULL,     -- Ngày phải trả
    return_date DATE NULL,  -- Ngày thực tế trả
    status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED', -- REQUESTED, APPROVED, BORROWED, RETURNED, REJECTED, OVERDUE
    fine_amount DECIMAL(10,2) DEFAULT 0, -- Tiền phạt
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Borrow_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Borrow_Book FOREIGN KEY (book_id) REFERENCES Book(book_id)
);
GO

-- Bảng 6: Đặt trước sách (Reservations)
CREATE TABLE reservations (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    status VARCHAR(20) DEFAULT 'WAITING', -- WAITING, FULFILLED, CANCELLED
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Res_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Res_Book FOREIGN KEY (book_id) REFERENCES Book(book_id)
);
GO

-- Bảng 7: Quên mật khẩu (Password Reset)
CREATE TABLE password_reset_token (
    token_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) NOT NULL,
    expired_at DATETIME NOT NULL,
    used BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Token_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- Bảng 8: Giỏ hàng (Cart) / Shopping Cart
CREATE TABLE Cart (
    cart_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Cart_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- Bảng 9: Chi tiết giỏ hàng (CartItem) / Cart Items
CREATE TABLE CartItem (
    cart_item_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    cart_id BIGINT NOT NULL,
    book_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    added_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CartItem_Cart FOREIGN KEY (cart_id) REFERENCES Cart(cart_id) ON DELETE CASCADE,
    CONSTRAINT FK_CartItem_Book FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);
GO

-- =============================================
-- 3. NẠP DỮ LIỆU MẪU (SEED DATA)
-- =============================================

-- 3.1 Roles
INSERT INTO Role (role_name) VALUES ('ADMIN'), ('LIBRARIAN'), ('MEMBER');
GO

-- 3.2 Users (Mật khẩu mặc định: 123456)
INSERT INTO [User] (email, password, full_name, status, role_id) VALUES 
('admin@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Quản Trị Viên', 'ACTIVE', 1),
('lib@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Thủ Thư', 'ACTIVE', 2),
('member@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Nguyễn Văn A', 'ACTIVE', 3);
GO

-- 3.3 Categories (QUAN TRỌNG: Phải chạy cái này trước Book)
INSERT INTO Category (category_name) VALUES 
(N'Công nghệ thông tin'), 
(N'Văn học Việt Nam'), 
(N'Kỹ năng sống'), 
(N'Giáo trình THPT');
GO

-- 3.4 Books 
-- Lưu ý: KHÔNG INSERT cột availability, SQL tự tính.
INSERT INTO Book (title, author, category_id, price, quantity, isbn, image) VALUES 
(N'Lập trình Java cơ bản', N'Nguyễn Văn Minh', 1, 150000, 10, 'ISBN-001', 'assets/images/books/java.jpg'),
(N'Học SQL trong 30 ngày', N'Trần Hoàng', 1, 120000, 0, 'ISBN-002', 'assets/images/books/sql.jpg'), -- Số lượng 0 -> Availability tự = 0
(N'Tắt đèn', N'Ngô Tất Tố', 2, 60000, 8, 'ISBN-003', 'assets/images/books/tatden.jpg'),
(N'Lão Hạc', N'Nam Cao', 2, 55000, 3, 'ISBN-004', 'assets/images/books/laohac.jpg'),
(N'Đắc nhân tâm', N'Dale Carnegie', 3, 90000, 20, 'ISBN-005', 'assets/images/books/dacnhantam.jpg'),
(N'Toán lớp 12', N'Bộ GD&ĐT', 4, 25000, 50, 'ISBN-006', 'assets/images/books/toan12.jpg'),
(N'Ngữ văn lớp 12', N'Bộ GD&ĐT', 4, 24000, 50, 'ISBN-007', 'assets/images/books/van12.jpg');
GO

-- 3.5 Mượn sách mẫu
INSERT INTO borrow_records (user_id, book_id, borrow_date, due_date, status) VALUES
(3, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'BORROWED'); -- Đang mượn
GO

PRINT '--- CÀI ĐẶT DATABASE LIBRARYDB HOÀN TẤT VÀ THÀNH CÔNG ---';