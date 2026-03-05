/*

PROJECT: LIBRARY MANAGEMENT SYSTEM (LBMS)
DATABASE: LibraryDB
TYPE: SQL SERVER


*/

-- =============================================
-- 1. CREATE DATABASE IF NOT EXISTS
-- =============================================

IF DB_ID('LibraryDB') IS NULL
BEGIN
    CREATE DATABASE LibraryDB;
END
GO

USE LibraryDB;
GO

-- =============================================
-- ROLE
-- =============================================

IF OBJECT_ID('Role','U') IS NULL
BEGIN
CREATE TABLE Role (
                      role_id INT IDENTITY(1,1) PRIMARY KEY,
                      role_name NVARCHAR(50) NOT NULL UNIQUE
);
END
GO

-- =============================================
-- USER
-- =============================================

IF OBJECT_ID('[User]','U') IS NULL
BEGIN
CREATE TABLE [User] (
                        user_id INT IDENTITY(1,1) PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name NVARCHAR(100),
    phone VARCHAR(20),
    address NVARCHAR(255),
    status VARCHAR(20) DEFAULT 'ACTIVE',
    role_id INT NOT NULL,
    avatar VARCHAR(255),
    created_at DATETIME DEFAULT GETDATE(),

    CONSTRAINT FK_User_Role
    FOREIGN KEY (role_id) REFERENCES Role(role_id)
    );
END
GO

-- =============================================
-- CATEGORY
-- =============================================

IF OBJECT_ID('Category','U') IS NULL
BEGIN
CREATE TABLE Category (
                          category_id INT IDENTITY(1,1) PRIMARY KEY,
                          category_name NVARCHAR(100) NOT NULL UNIQUE
);
END
GO

-- =============================================
-- BOOK
-- =============================================

IF OBJECT_ID('Book','U') IS NULL
BEGIN
CREATE TABLE Book (
                      book_id INT IDENTITY(1,1) PRIMARY KEY,
                      title NVARCHAR(255) NOT NULL,
                      author NVARCHAR(255) NOT NULL,
                      category_id INT,
                      price DECIMAL(10,2) DEFAULT 0,
                      quantity INT DEFAULT 0,
                      isbn VARCHAR(50) NOT NULL UNIQUE,
                      image NVARCHAR(500),

                      availability AS (CASE WHEN quantity > 0 THEN 1 ELSE 0 END),

                      created_at DATETIME DEFAULT GETDATE(),

                      CONSTRAINT FK_Book_Category
                          FOREIGN KEY (category_id)
                              REFERENCES Category(category_id)
                              ON DELETE SET NULL
);
END
GO

-- =============================================
-- BOOK COPY
-- =============================================

IF OBJECT_ID('BookCopy','U') IS NULL
BEGIN
CREATE TABLE BookCopy (
                          copy_id INT IDENTITY(1,1) PRIMARY KEY,
                          book_id INT NOT NULL,
                          barcode VARCHAR(30) UNIQUE,
                          status VARCHAR(20) DEFAULT 'AVAILABLE',
                          condition VARCHAR(20) DEFAULT 'NEW',
                          created_at DATETIME DEFAULT GETDATE(),

                          CONSTRAINT FK_BookCopy_Book
                              FOREIGN KEY (book_id)
                                  REFERENCES Book(book_id)
                                  ON DELETE CASCADE
);
END
GO

-- =============================================
-- BORROW RECORD
-- =============================================

IF OBJECT_ID('borrow_records','U') IS NULL
BEGIN
CREATE TABLE borrow_records (
                                id BIGINT IDENTITY(1,1) PRIMARY KEY,
                                user_id INT NOT NULL,
                                book_id INT NOT NULL,
                                copy_id INT NULL,
                                borrow_date DATE,
                                due_date DATE,
                                return_date DATE,
                                status VARCHAR(20) DEFAULT 'REQUESTED',
                                fine_amount DECIMAL(10,2) DEFAULT 0,
                                is_paid BIT DEFAULT 0,
                                borrow_method VARCHAR(20),
                                created_at DATETIME DEFAULT GETDATE(),

                                CONSTRAINT FK_Borrow_User
                                    FOREIGN KEY (user_id) REFERENCES [User](user_id),

                                CONSTRAINT FK_Borrow_Book
                                    FOREIGN KEY (book_id) REFERENCES Book(book_id),

                                CONSTRAINT FK_Borrow_Copy
                                    FOREIGN KEY (copy_id) REFERENCES BookCopy(copy_id)
);
END
GO

-- =============================================
-- RENEWAL REQUEST
-- =============================================

IF OBJECT_ID('renewal_requests','U') IS NULL
BEGIN
CREATE TABLE renewal_requests (
                                  id BIGINT IDENTITY(1,1) PRIMARY KEY,
                                  borrow_id BIGINT NOT NULL,
                                  user_id INT NOT NULL,
                                  reason NVARCHAR(1024) NOT NULL,
                                  contact_name NVARCHAR(255),
                                  contact_phone VARCHAR(30),
                                  contact_email VARCHAR(255),
                                  status VARCHAR(20) DEFAULT 'PENDING',
                                  requested_at DATETIME DEFAULT GETDATE(),

                                  CONSTRAINT FK_Renewal_Borrow
                                      FOREIGN KEY (borrow_id)
                                          REFERENCES borrow_records(id)
                                          ON DELETE CASCADE,

                                  CONSTRAINT FK_Renewal_User
                                      FOREIGN KEY (user_id)
                                          REFERENCES [User](user_id)
);
END
GO

-- =============================================
-- RESERVATION
-- =============================================

IF OBJECT_ID('reservations','U') IS NULL
BEGIN
CREATE TABLE reservations (
                              id BIGINT IDENTITY(1,1) PRIMARY KEY,
                              user_id INT NOT NULL,
                              book_id INT NOT NULL,
                              status VARCHAR(20) DEFAULT 'WAITING',
                              created_at DATETIME DEFAULT GETDATE(),

                              CONSTRAINT FK_Res_User
                                  FOREIGN KEY (user_id) REFERENCES [User](user_id),

                              CONSTRAINT FK_Res_Book
                                  FOREIGN KEY (book_id) REFERENCES Book(book_id)
);
END
GO

-- =============================================
-- PASSWORD RESET
-- =============================================

IF OBJECT_ID('password_reset_token','U') IS NULL
BEGIN
CREATE TABLE password_reset_token (
                                      token_id INT IDENTITY(1,1) PRIMARY KEY,
                                      user_id INT NOT NULL,
                                      token VARCHAR(255) NOT NULL,
                                      expired_at DATETIME NOT NULL,
                                      used BIT DEFAULT 0,
                                      created_at DATETIME DEFAULT GETDATE(),

                                      CONSTRAINT FK_Token_User
                                          FOREIGN KEY (user_id)
                                              REFERENCES [User](user_id)
                                              ON DELETE CASCADE
);
END
GO

-- =============================================
-- EMAIL VERIFICATION
-- =============================================

IF OBJECT_ID('email_verification_token','U') IS NULL
BEGIN
CREATE TABLE email_verification_token (
                                          verification_token_id INT IDENTITY(1,1) PRIMARY KEY,
                                          user_id INT NOT NULL,
                                          code VARCHAR(255) NOT NULL,
                                          expired_at DATETIME NOT NULL,
                                          used BIT DEFAULT 0,
                                          created_at DATETIME DEFAULT GETDATE(),

                                          CONSTRAINT FK_Verify_User
                                              FOREIGN KEY (user_id)
                                                  REFERENCES [User](user_id)
                                                  ON DELETE CASCADE
);
END
GO

-- =============================================
-- CART
-- =============================================

IF OBJECT_ID('Cart','U') IS NULL
BEGIN
CREATE TABLE Cart (
                      cart_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                      user_id INT NOT NULL UNIQUE,
                      created_at DATETIME DEFAULT GETDATE(),

                      CONSTRAINT FK_Cart_User
                          FOREIGN KEY (user_id)
                              REFERENCES [User](user_id)
                              ON DELETE CASCADE
);
END
GO

-- =============================================
-- CART ITEM
-- =============================================

IF OBJECT_ID('CartItem','U') IS NULL
BEGIN
CREATE TABLE CartItem (
                          cart_item_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                          cart_id BIGINT NOT NULL,
                          book_id INT NOT NULL,
                          quantity INT DEFAULT 1,
                          added_at DATETIME DEFAULT GETDATE(),

                          CONSTRAINT FK_CartItem_Cart
                              FOREIGN KEY (cart_id)
                                  REFERENCES Cart(cart_id)
                                  ON DELETE CASCADE,

                          CONSTRAINT FK_CartItem_Book
                              FOREIGN KEY (book_id)
                                  REFERENCES Book(book_id)
                                  ON DELETE CASCADE
);
END
GO

-- =============================================
-- LIBRARIAN ACTIVITY LOG
-- =============================================

IF OBJECT_ID('LibrarianActivityLog','U') IS NULL
BEGIN
CREATE TABLE LibrarianActivityLog (
                                      log_id INT IDENTITY(1,1) PRIMARY KEY,
                                      user_id INT NOT NULL,
                                      action NVARCHAR(255) NOT NULL,
                                      timestamp DATETIME DEFAULT GETDATE(),

                                      CONSTRAINT FK_ActivityLog_User
                                          FOREIGN KEY (user_id)
                                              REFERENCES [User](user_id)
);
END
GO

-- =============================================
-- COMMENT
-- =============================================

IF OBJECT_ID('Comment','U') IS NULL
BEGIN
CREATE TABLE Comment (
                         comment_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                         book_id INT NOT NULL,
                         user_id INT NOT NULL,
                         content NVARCHAR(MAX) NOT NULL,
                         rating INT DEFAULT 5,
                         status NVARCHAR(20) DEFAULT 'VISIBLE',
                         created_at DATETIME DEFAULT GETDATE(),
                         updated_at DATETIME,
                         deleted_at DATETIME
);
END
GO

-- =============================================
-- COMMENT REPLY
-- =============================================

IF OBJECT_ID('CommentReply','U') IS NULL
BEGIN
CREATE TABLE CommentReply (
                              comment_reply_id BIGINT IDENTITY(1,1) PRIMARY KEY,
                              comment_id BIGINT NOT NULL,
                              admin_id INT,
                              content NVARCHAR(MAX) NOT NULL,
                              created_at DATETIME DEFAULT GETDATE(),

                              CONSTRAINT FK_CommentReply_Comment
                                  FOREIGN KEY (comment_id)
                                      REFERENCES Comment(comment_id)
                                      ON DELETE CASCADE,

                              CONSTRAINT FK_CommentReply_Admin
                                  FOREIGN KEY (admin_id)
                                      REFERENCES [User](user_id)
                                      ON DELETE SET NULL
);
END
GO

PRINT 'DATABASE LBMS READY';