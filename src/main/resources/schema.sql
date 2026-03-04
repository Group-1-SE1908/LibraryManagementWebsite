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

-- 1. XÓA DATABASE CŨ NẾU TỒN TẠI
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
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    address NVARCHAR(255) NULL,
    status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, LOCKED
    role_id INT NOT NULL,
    avatar VARCHAR(255) NULL,
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

-- Bảng 4: Sách (Book)
CREATE TABLE Book (
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    author NVARCHAR(255) NOT NULL,
    category_id INT,
    
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 0,
    isbn VARCHAR(50) NOT NULL UNIQUE,
    image NVARCHAR(500) NULL,
    
    -- Computed Column: Tự động xác định còn sách hay không
    availability AS (CASE WHEN quantity > 0 THEN 1 ELSE 0 END),

    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Book_Category 
        FOREIGN KEY (category_id) REFERENCES Category(category_id)
        ON DELETE SET NULL
);
GO

-- Bảng 5: Bản sao sách (BookCopy)
CREATE TABLE BookCopy (
    copy_id INT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    barcode VARCHAR(30) UNIQUE,
    status VARCHAR(20) DEFAULT 'AVAILABLE', -- AVAILABLE, BORROWED, LOST, DAMAGED
    condition VARCHAR(20) DEFAULT 'NEW',
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_BookCopy_Book
        FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);
GO

-- Bảng 6: Quản lý mượn trả (Borrow Records)
CREATE TABLE borrow_records (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    copy_id INT NULL,
    borrow_date DATE NULL,
    due_date DATE NULL,
    return_date DATE NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
    fine_amount DECIMAL(10,2) DEFAULT 0,
    is_paid BIT DEFAULT 0,
    borrow_method VARCHAR(20) NULL,
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Borrow_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Borrow_Book FOREIGN KEY (book_id) REFERENCES Book(book_id),
    CONSTRAINT FK_Borrow_Copy FOREIGN KEY (copy_id) REFERENCES BookCopy(copy_id)
);
GO

-- Bảng 7: Đặt trước sách (Reservations)
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

-- Bảng 8: Reset mật khẩu
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

-- Bảng 9: Xác thực email
CREATE TABLE email_verification_token (
    verification_token_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    code VARCHAR(255) NOT NULL,
    expired_at DATETIME NOT NULL,
    used BIT DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Verify_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- Bảng 10: Giỏ hàng
CREATE TABLE Cart (
    cart_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Cart_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- Bảng 11: Chi tiết giỏ hàng
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

-- Bảng 12: Nhật ký hoạt động thủ thư
CREATE TABLE LibrarianActivityLog (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    action NVARCHAR(255) NOT NULL,
    timestamp DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_ActivityLog_User FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

-- Bảng Comment
CREATE TABLE Comment (
    comment_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    book_id INT NOT NULL,
    user_id INT NOT NULL,
    content NVARCHAR(MAX) NOT NULL,
    rating INT DEFAULT 5,
    status NVARCHAR(20) DEFAULT 'VISIBLE',
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL
);
GO

-- Bảng phản hồi comment
CREATE TABLE CommentReply (
    comment_reply_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    comment_id BIGINT NOT NULL,
    admin_id INT NULL,
    content NVARCHAR(MAX) NOT NULL,
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_CommentReply_Comment 
        FOREIGN KEY (comment_id) REFERENCES Comment(comment_id) ON DELETE CASCADE,

    CONSTRAINT FK_CommentReply_Admin 
        FOREIGN KEY (admin_id) REFERENCES [User](user_id) ON DELETE SET NULL
);
GO

-- =============================================
-- 3. TRIGGER TẠO BOOK COPY
-- =============================================

CREATE TRIGGER trg_AfterInsert_Book
ON Book
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @book_id INT;
    DECLARE @quantity INT;
    DECLARE @new_copy_id INT;
    DECLARE @i INT;

    DECLARE book_cursor CURSOR FOR
    SELECT book_id, quantity FROM inserted;

    OPEN book_cursor;
    FETCH NEXT FROM book_cursor INTO @book_id, @quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;

        WHILE @i <= @quantity
        BEGIN
            INSERT INTO BookCopy (book_id)
            VALUES (@book_id);
            
            SET @new_copy_id = SCOPE_IDENTITY();

            UPDATE BookCopy
            SET barcode = 'LIB-' + RIGHT('000000' + CAST(@new_copy_id AS VARCHAR), 6)
            WHERE copy_id = @new_copy_id;

            SET @i = @i + 1;
        END

        FETCH NEXT FROM book_cursor INTO @book_id, @quantity;
    END

    CLOSE book_cursor;
    DEALLOCATE book_cursor;
END;
GO

-- =============================================
-- 4. SEED DATA
-- =============================================

-- Roles
INSERT INTO Role (role_name) VALUES 
('ADMIN'),
('LIBRARIAN'),
('MEMBER');
GO

-- Users (password: 123456)
INSERT INTO [User] (email, password, full_name, status, role_id) VALUES 
('admin@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Quản Trị Viên', 'ACTIVE', 1),
('lib@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Thủ Thư', 'ACTIVE', 2),
('member@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Nguyễn Văn A', 'ACTIVE', 3);
GO

-- Categories
INSERT INTO Category (category_name) VALUES 
(N'Công nghệ thông tin'),
(N'Văn học Việt Nam'),
(N'Kỹ năng sống'),
(N'Giáo trình THPT');
GO

-- Books
INSERT INTO Book (title, author, category_id, price, quantity, isbn, image) VALUES 
(N'Lập trình Java cơ bản', N'Nguyễn Văn Minh', 1, 150000, 10, 'ISBN-001', 'assets/images/books/java.jpg'),
(N'Học SQL trong 30 ngày', N'Trần Hoàng', 1, 120000, 0, 'ISBN-002', 'assets/images/books/sql.jpg'),
(N'Tắt đèn', N'Ngô Tất Tố', 2, 60000, 8, 'ISBN-003', 'assets/images/books/tatden.jpg'),
(N'Lão Hạc', N'Nam Cao', 2, 55000, 3, 'ISBN-004', 'assets/images/books/laohac.jpg'),
(N'Đắc nhân tâm', N'Dale Carnegie', 3, 90000, 20, 'ISBN-005', 'assets/images/books/dacnhantam.jpg'),
(N'Toán lớp 12', N'Bộ GD&ĐT', 4, 25000, 50, 'ISBN-006', 'assets/images/books/toan12.jpg'),
(N'Ngữ văn lớp 12', N'Bộ GD&ĐT', 4, 24000, 50, 'ISBN-007', 'assets/images/books/van12.jpg');
GO

-- Borrow sample
INSERT INTO borrow_records (user_id, book_id, borrow_date, due_date, status) VALUES
(3, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'BORROWED');
GO

PRINT '--- CÀI ĐẶT DATABASE LIBRARYDB HOÀN TẤT ---';