/*
===========================================================================
 PROJECT: LIBRARY MANAGEMENT SYSTEM (LBMS)
 DATABASE: LibraryDB
 TYPE: SQL SERVER
 UPDATED: T�ch h?p Computed Column cho Availability (T? d?ng t�nh to�n)
===========================================================================
*/

USE master;
GO

-- 1. X�A DB CU N?U T?N T?I (�? t?o m?i s?ch s?)
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
-- 2. T?O C�C B?NG (TABLES)
-- =============================================

-- B?ng 1: Ph�n quy?n (Role)
CREATE TABLE Role (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- B?ng 2: Ngu?i d�ng (User)
CREATE TABLE [User] (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL, -- M?t kh?u (n�n m� h�a MD5/BCrypt)
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

-- B?ng 3: Th? lo?i s�ch (Category)
CREATE TABLE Category (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- B?ng 4: S�ch (Book) - T�CH H?P C?T T? �?NG
CREATE TABLE Book (
    book_id INT IDENTITY(1,1) PRIMARY KEY,
    title NVARCHAR(255) NOT NULL,
    author NVARCHAR(255) NOT NULL,
    category_id INT,
    
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    quantity INT NOT NULL DEFAULT 0,    -- S? lu?ng t?n kho
    isbn VARCHAR(50) NOT NULL UNIQUE,   -- M� s�ch (ISBN)
    image NVARCHAR(500) NULL,           -- �u?ng d?n ?nh (assets/images/...)
    
    -- --- C?T T? �?NG (COMPUTED COLUMN) ---
    -- T? d?ng tr? v? 1 n?u quantity > 0, ngu?c l?i l� 0.
    -- Kh�ng c?n Insert/Update v�o c?t n�y.
    availability AS (CASE WHEN quantity > 0 THEN 1 ELSE 0 END),
    
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Book_Category FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE SET NULL
);
GO

-- B?ng 5: B?n sao s�ch (BookCopy)
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

-- B?ng 6: Qu?n l� Mu?n Tr? (Borrow Records)
CREATE TABLE borrow_records (
    id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    copy_id INT NULL,
    borrow_date DATE NULL,
    due_date DATE NULL,     -- Ng�y ph?i tr?
    return_date DATE NULL,  -- Ng�y th?c t? tr?
    status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED', -- REQUESTED, APPROVED, BORROWED, RETURNED, REJECTED, OVERDUE
    fine_amount DECIMAL(10,2) DEFAULT 0, -- Ti?n ph?t
    is_paid BIT DEFAULT 0, -- 0 = chua thanh toan, 1 = da thanh toan
    borrow_method VARCHAR(20) NULL, -- Ghi l?i h�nh th?c mu?n
    created_at DATETIME DEFAULT GETDATE(),
    
    CONSTRAINT FK_Borrow_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
    CONSTRAINT FK_Borrow_Book FOREIGN KEY (book_id) REFERENCES Book(book_id),
    CONSTRAINT FK_Borrow_Copy FOREIGN KEY (copy_id) REFERENCES BookCopy(copy_id)
);
GO

-- B?ng 7: �?t tru?c s�ch (Reservations)
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

-- B?ng 8: Qu�n m?t kh?u (Password Reset)
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

-- B?ng 9: Gi? h�ng (Cart) / Shopping Cart
CREATE TABLE Cart (
    cart_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_Cart_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- B?ng 10: Chi ti?t gi? h�ng (CartItem) / Cart Items
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

-- B?ng 11: Nh?t k� ho?t d?ng (LibrarianActivityLog)
CREATE TABLE [LibrarianActivityLog] (
    [log_id] INT IDENTITY(1,1) PRIMARY KEY,
    [user_id] INT NOT NULL, -- Kh�a ngo?i li�n k?t t?i b?ng User
    [action] NVARCHAR(255) NOT NULL, -- H�nh d?ng th?c hi?n
    [timestamp] DATETIME DEFAULT GETDATE(), -- Th?i gian th?c hi?n
    CONSTRAINT FK_ActivityLog_User FOREIGN KEY ([user_id]) REFERENCES [User]([user_id])
);
GO

-- =============================================
-- 3. TRIGGERS
-- =============================================

-- Trigger t? d?ng sinh copy khi th�m s�ch m?i
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
    SELECT book_id, quantity
    FROM inserted;

    OPEN book_cursor;
    FETCH NEXT FROM book_cursor INTO @book_id, @quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @i = 1;

        WHILE @i <= @quantity
        BEGIN
            -- Th�m m?i 1 b?n copy
            INSERT INTO BookCopy (book_id)
            VALUES (@book_id);
            
            SET @new_copy_id = SCOPE_IDENTITY();

            -- C?p nh?t l?i barcode
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
-- 4. N?P D? LI?U M?U (SEED DATA)
-- =============================================

-- 4.1 Roles
INSERT INTO Role (role_name) VALUES ('ADMIN'), ('LIBRARIAN'), ('MEMBER');
GO

-- 4.2 Users (M?t kh?u m?c d?nh: 123456)
INSERT INTO [User] (email, password, full_name, status, role_id) VALUES 
('admin@library.com', '/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Qu?n Tr? Vi�n', 'ACTIVE', 1),
('lib@library.com', '/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Th? Thu', 'ACTIVE', 2),
('member@library.com', '/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Nguy?n Van A', 'ACTIVE', 3);
GO

-- 4.3 Categories (QUAN TR?NG: Ph?i ch?y c�i n�y tru?c Book)
INSERT INTO Category (category_name) VALUES 
(N'C�ng ngh? th�ng tin'), 
(N'Van h?c Vi?t Nam'), 
(N'K? nang s?ng'), 
(N'Gi�o tr�nh THPT');
GO

-- 4.4 Books 
-- Luu �: KH�NG INSERT c?t availability, SQL t? t�nh.
INSERT INTO Book (title, author, category_id, price, quantity, isbn, image) VALUES 
(N'L?p tr�nh Java co b?n', N'Nguy?n Van Minh', 1, 150000, 10, 'ISBN-001', 'assets/images/books/java.jpg'),
(N'H?c SQL trong 30 ng�y', N'Tr?n Ho�ng', 1, 120000, 0, 'ISBN-002', 'assets/images/books/sql.jpg'), -- S? lu?ng 0 -> Availability t? = 0
(N'T?t d�n', N'Ng� T?t T?', 2, 60000, 8, 'ISBN-003', 'assets/images/books/tatden.jpg'),
(N'L�o H?c', N'Nam Cao', 2, 55000, 3, 'ISBN-004', 'assets/images/books/laohac.jpg'),
(N'�?c nh�n t�m', N'Dale Carnegie', 3, 90000, 20, 'ISBN-005', 'assets/images/books/dacnhantam.jpg'),
(N'To�n l?p 12', N'B? GD&�T', 4, 25000, 50, 'ISBN-006', 'assets/images/books/toan12.jpg'),
(N'Ng? van l?p 12', N'B? GD&�T', 4, 24000, 50, 'ISBN-007', 'assets/images/books/van12.jpg');
GO

-- 4.5 Mu?n s�ch m?u
INSERT INTO borrow_records (user_id, book_id, borrow_date, due_date, status) VALUES
(3, 1, GETDATE(), DATEADD(DAY, 14, GETDATE()), 'BORROWED'); -- �ang mu?n
GO

PRINT '--- C�I �?T DATABASE LIBRARYDB HO�N T?T V� TH�NH C�NG ---';
