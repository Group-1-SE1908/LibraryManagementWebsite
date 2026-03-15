/*
===========================================================================
 PROJECT: LIBRARY MANAGEMENT SYSTEM (LBMS) - FULL VERSION
 DATABASE: LibraryDB
 DESCRIPTION: Bản tổng hợp hoàn chỉnh từ DB gốc và các script cập nhật.
===========================================================================
*/

USE master;
GO

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
-- 1. TẠO CÁC BẢNG (TABLES)
-- =============================================

-- Bảng 1: Phân quyền (Role)
CREATE TABLE Role (
                      role_id INT IDENTITY(1,1) PRIMARY KEY,
                      role_name NVARCHAR(50) NOT NULL UNIQUE
);
GO

-- Bảng 2: Người dùng (User) - Bao gồm Avatar và thông tin cá nhân
CREATE TABLE [User] (
                        user_id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100) NULL,
    phone VARCHAR(20) NULL,
    address NVARCHAR(255) NULL,
                        status VARCHAR(20) DEFAULT 'ACTIVE', -- ACTIVE, LOCKED
    role_id INT NOT NULL,
    avatar VARCHAR(255) NULL, --
    wallet_balance DECIMAL(14,2) NOT NULL DEFAULT 0,
    banned_until DATETIME NULL,
    comment_banned_until DATETIME NULL,
    created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_User_Role FOREIGN KEY (role_id) REFERENCES Role(role_id)
                    );
GO

-- Bảng 2.1: Lịch sử giao dịch ví (Wallet transactions)
IF OBJECT_ID('wallet_transaction', 'U') IS NOT NULL
    DROP TABLE wallet_transaction;
GO

CREATE TABLE wallet_transaction (
    transaction_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    type VARCHAR(30) NOT NULL,
    source NVARCHAR(150) NOT NULL,
    description NVARCHAR(255) NULL,
    amount DECIMAL(14,2) NOT NULL,
    reference VARCHAR(255) NULL,
    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    CONSTRAINT FK_WalletTransaction_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

CREATE INDEX IX_wallet_transaction_user_date ON wallet_transaction (user_id, created_at DESC);
GO

-- Bảng 3: Thể loại sách (Category)
CREATE TABLE Category (
                          category_id INT IDENTITY(1,1) PRIMARY KEY,
                          category_name NVARCHAR(100) NOT NULL UNIQUE
);
GO

-- Bảng 4: Sách (Book) - Tích hợp Computed Column
CREATE TABLE Book (
                      book_id INT IDENTITY(1,1) PRIMARY KEY,
                      title NVARCHAR(255) NOT NULL,
                      author NVARCHAR(255) NOT NULL,
                      category_id INT,
                      price DECIMAL(10,2) NOT NULL DEFAULT 0,
                      quantity INT NOT NULL DEFAULT 0,
                      isbn VARCHAR(50) NOT NULL UNIQUE,
                      image NVARCHAR(500) NULL,

    -- Tự động xác định còn sách hay không [cite: 7]
                      availability AS (CASE WHEN quantity > 0 THEN 1 ELSE 0 END),

                      created_at DATETIME DEFAULT GETDATE(),
                      CONSTRAINT FK_Book_Category FOREIGN KEY (category_id) REFERENCES Category(category_id) ON DELETE SET NULL
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
                          CONSTRAINT FK_BookCopy_Book FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE
);
GO

-- Bảng 6: Quản lý mượn trả (Borrow Records) - Đầy đủ các cột mở rộng
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
                                is_paid BIT DEFAULT 0, --
                                reject_reason NVARCHAR(255) NULL, --
                                borrow_method VARCHAR(20) DEFAULT 'IN_PERSON', --
                                quantity INT DEFAULT 1, --
                                deposit_amount DECIMAL(10,2) DEFAULT 0,
                                group_code VARCHAR(50) NULL,

    -- Thông tin giao hàng/nhận hàng
                                shipping_recipient NVARCHAR(255) NULL,
                                shipping_phone VARCHAR(30) NULL,
                                shipping_street NVARCHAR(255) NULL,
                                shipping_residence NVARCHAR(255) NULL,
                                shipping_ward NVARCHAR(255) NULL,
                                shipping_district NVARCHAR(255) NULL,
                                shipping_city NVARCHAR(255) NULL,


                                created_at DATETIME DEFAULT GETDATE(),
                                CONSTRAINT FK_Borrow_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
                                CONSTRAINT FK_Borrow_Book FOREIGN KEY (book_id) REFERENCES Book(book_id),
                                CONSTRAINT FK_Borrow_Copy FOREIGN KEY (copy_id) REFERENCES BookCopy(copy_id)
);
GO

-- Bảng 7: Yêu cầu gia hạn (Renewal Requests)
CREATE TABLE renewal_requests (
                                  id BIGINT IDENTITY(1,1) PRIMARY KEY,
                                  borrow_id BIGINT NOT NULL,
                                  user_id INT NOT NULL,
                                  reason NVARCHAR(1000) NOT NULL,
                                  contact_name NVARCHAR(255) NULL,
                                  contact_phone VARCHAR(30) NULL,
                                  contact_email VARCHAR(255) NULL,
                                  status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
                                  requested_at DATETIME NOT NULL DEFAULT GETDATE(),
                                  CONSTRAINT FK_RenewalRequest_Borrow FOREIGN KEY (borrow_id) REFERENCES borrow_records(id),
                                  CONSTRAINT FK_RenewalRequest_User FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

CREATE INDEX IX_RenewalRequest_BorrowId ON renewal_requests (borrow_id);
CREATE INDEX IX_RenewalRequest_Status ON renewal_requests (status);
GO

-- Bảng 8: Đặt trước sách (Reservations)
CREATE TABLE reservations (
                              id BIGINT IDENTITY(1,1) PRIMARY KEY,
                              user_id INT NOT NULL,
                              book_id INT NOT NULL,
                              status VARCHAR(20) DEFAULT 'WAITING',
                              created_at DATETIME DEFAULT GETDATE(),
                              CONSTRAINT FK_Res_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
                              CONSTRAINT FK_Res_Book FOREIGN KEY (book_id) REFERENCES Book(book_id)
);
GO
-- =============================================
-- CẬP NHẬT BẢNG reservations (phiên bản mới)
-- =============================================




-- Xóa bảng cũ nếu tồn tại
IF OBJECT_ID('reservations', 'U') IS NOT NULL
DROP TABLE reservations;
GO

CREATE TABLE reservations (
                              id            BIGINT IDENTITY(1,1) PRIMARY KEY,
                              user_id       INT            NOT NULL,
                              book_id       INT            NOT NULL,
                              status        VARCHAR(20)    NOT NULL DEFAULT 'WAITING',
    -- WAITING   : đang chờ sách được trả
    -- AVAILABLE : sách đã có, đang chờ member đến lấy
    -- BORROWED  : member đã mượn sau khi reserve
    -- CANCELLED : member tự hủy
    -- EXPIRED   : quá hạn không đến lấy
                              note          NVARCHAR(255)  NULL,          -- ghi chú thêm nếu cần
                              notified_at   DATETIME       NULL,          -- thời điểm hệ thống gửi thông báo "sách đã có"
                              expired_at    DATETIME       NULL,          -- hạn cuối member phải đến lấy (set khi status -> AVAILABLE)
                              created_at    DATETIME       NOT NULL DEFAULT GETDATE(),
                              updated_at    DATETIME       NULL,

                              CONSTRAINT FK_Res_User FOREIGN KEY (user_id) REFERENCES [User](user_id),
                              CONSTRAINT FK_Res_Book FOREIGN KEY (book_id) REFERENCES Book(book_id),

    -- Mỗi member chỉ được reserve 1 lần cho 1 cuốn sách (khi đang WAITING/AVAILABLE)
                              CONSTRAINT UQ_Res_User_Book UNIQUE (user_id, book_id)
);
GO

-- Index hỗ trợ query theo user và status
CREATE INDEX IX_Res_UserId   ON reservations (user_id);
CREATE INDEX IX_Res_BookId   ON reservations (book_id);
CREATE INDEX IX_Res_Status   ON reservations (status);
GO

PRINT 'Table reservations updated successfully.';
GO

-- Bảng 8: Giỏ hàng (Cart)
CREATE TABLE Cart (
                      cart_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                      user_id INT NOT NULL UNIQUE,
                      created_at DATETIME DEFAULT GETDATE(),
                      CONSTRAINT FK_Cart_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- Bảng 9: Chi tiết giỏ hàng (CartItem)
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

-- Bảng 10: Nhật ký hoạt động thủ thư
CREATE TABLE LibrarianActivityLog (
                                      log_id INT IDENTITY(1,1) PRIMARY KEY,
                                      user_id INT NOT NULL,
                                      action NVARCHAR(255) NOT NULL,
                                      timestamp DATETIME DEFAULT GETDATE(),
                                      CONSTRAINT FK_ActivityLog_User FOREIGN KEY (user_id) REFERENCES [User](user_id)
);
GO

-- Bảng 11: Bình luận (Comment) - Giới hạn 500 ký tự và Check Rating
CREATE TABLE Comment (
                         comment_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                         book_id INT NOT NULL,
                         user_id INT NOT NULL,
                         content NVARCHAR(500) NOT NULL,
                         rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
                         status VARCHAR(20) NOT NULL DEFAULT 'VISIBLE',
                         created_at DATETIME NOT NULL DEFAULT GETDATE(),
                         updated_at DATETIME NULL,
                         deleted_at DATETIME NULL,
                         CONSTRAINT FK_Comment_Book FOREIGN KEY (book_id) REFERENCES Book(book_id) ON DELETE CASCADE,
                         CONSTRAINT FK_Comment_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);
GO

-- Bảng 12: Phản hồi bình luận [cite: 19]
CREATE TABLE CommentReply (
                              comment_reply_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                              comment_id BIGINT NOT NULL,
                              admin_id INT NULL,
                              content NVARCHAR(MAX) NOT NULL,
                              created_at DATETIME DEFAULT GETDATE(),
    CONSTRAINT FK_CommentReply_Comment FOREIGN KEY (comment_id) REFERENCES Comment(comment_id) ON DELETE CASCADE,
    CONSTRAINT FK_CommentReply_Admin FOREIGN KEY (admin_id) REFERENCES [User](user_id) ON DELETE NO ACTION
);
GO

-- Bảng 13: Báo cáo bình luận (Comment Reports)
CREATE TABLE CommentReport (
                               report_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                               comment_id BIGINT NOT NULL,
                               reporter_user_id INT NOT NULL,
                               reason NVARCHAR(100) NOT NULL,
                               description NVARCHAR(MAX) NULL,
                               report_time DATETIME DEFAULT GETDATE(),
                               status VARCHAR(20) DEFAULT 'PENDING', -- PENDING, RESOLVED, IGNORED
                               CONSTRAINT FK_CommentReport_Comment FOREIGN KEY (comment_id) REFERENCES Comment(comment_id) ON DELETE CASCADE,
                               CONSTRAINT FK_CommentReport_User FOREIGN KEY (reporter_user_id) REFERENCES [User](user_id) ON DELETE NO ACTION,
                               CONSTRAINT CHK_ReportStatus CHECK (status IN ('PENDING', 'RESOLVED', 'IGNORED'))
);
GO

-- Bảng 14: Bảo mật & Xác thực [cite: 13, 14]
CREATE TABLE password_reset_token (
                                      token_id INT IDENTITY(1,1) PRIMARY KEY,
                                      user_id INT NOT NULL,
                                      token VARCHAR(255) NOT NULL,
                                      expired_at DATETIME NOT NULL,
                                      used BIT DEFAULT 0,
                                      created_at DATETIME DEFAULT GETDATE(),
                                      CONSTRAINT FK_Token_User FOREIGN KEY (user_id) REFERENCES [User](user_id) ON DELETE CASCADE
);

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

-- =============================================
-- 2. TRIGGER TỰ ĐỘNG TẠO BẢN SAO SÁCH (BOOKCOPY)
-- =============================================

CREATE TRIGGER trg_AfterInsert_Book
    ON Book
    AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @book_id INT, @quantity INT, @new_copy_id INT, @i INT;
    DECLARE book_cursor CURSOR FOR SELECT book_id, quantity FROM inserted;

OPEN book_cursor;
FETCH NEXT FROM book_cursor INTO @book_id, @quantity;

WHILE @@FETCH_STATUS = 0
BEGIN
        SET @i = 1;
        WHILE @i <= @quantity
BEGIN
INSERT INTO BookCopy (book_id) VALUES (@book_id);
SET @new_copy_id = SCOPE_IDENTITY();
            -- Cập nhật barcode định dạng LIB-000001
UPDATE BookCopy SET barcode = 'LIB-' + RIGHT('000000' + CAST(@new_copy_id AS VARCHAR), 6)
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
-- 3. NẠP DỮ LIỆU MẪU (SEED DATA)
-- =============================================

INSERT INTO Role (role_name) VALUES ('ADMIN'), ('LIBRARIAN'), ('MEMBER');

-- Mật khẩu: 123456 (BCrypt tương ứng) [cite: 28]
INSERT INTO [User] (email, password, full_name, status, role_id, avatar) VALUES
    ('admin@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Quản Trị Viên', 'ACTIVE', 1, 'uploads/admin.png'),
    ('lib@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Thủ Thư', 'ACTIVE', 2, 'uploads/lib.png'),
    ('member@library.com', '$2a$10$EEMWWLX4kbl3U/UPiBn0R.WFU3u04UZjS47nwWkwRYh0AjDYjzpDa', N'Nguyễn Văn A', 'ACTIVE', 3, 'uploads/user.png');

INSERT INTO Category (category_name) VALUES (N'Công nghệ thông tin'), (N'Văn học Việt Nam'), (N'Kỹ năng sống'), (N'Giáo trình THPT');

-- Chèn sách sẽ tự động kích hoạt Trigger tạo BookCopy
INSERT INTO Book (title, author, category_id, price, quantity, isbn, image) VALUES
                                                                                (N'Lập trình Java cơ bản', N'Nguyễn Văn Minh', 1, 150000, 10, 'ISBN-001', 'assets/images/books/java.jpg'),
                                                                                (N'Học SQL trong 30 ngày', N'Trần Hoàng', 1, 120000, 5, 'ISBN-002', 'assets/images/books/sql.jpg'),
                                                                                (N'Tắt đèn', N'Ngô Tất Tố', 2, 60000, 8, 'ISBN-003', 'assets/images/books/tatden.jpg');

GO
PRINT '--- DATABASE LIBRARYDB HAS BEEN FULLY ASSEMBLED ---';
