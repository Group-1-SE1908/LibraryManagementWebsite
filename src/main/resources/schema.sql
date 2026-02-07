-- LBMS schema (SQL Server)
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'lbms')
BEGIN
    CREATE DATABASE lbms;
END
GO

USE lbms;
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[roles]') AND type in (N'U'))
BEGIN
    CREATE TABLE roles (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        name NVARCHAR(50) NOT NULL UNIQUE
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[users]') AND type in (N'U'))
BEGIN
    CREATE TABLE users (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        email NVARCHAR(255) NOT NULL UNIQUE,
        password_hash NVARCHAR(100) NOT NULL,
        full_name NVARCHAR(255) NULL,
        status NVARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
        role_id BIGINT NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[categories]') AND type in (N'U'))
BEGIN
    CREATE TABLE categories (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        name NVARCHAR(120) NOT NULL UNIQUE
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[books]') AND type in (N'U'))
BEGIN
    CREATE TABLE books (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        isbn NVARCHAR(32) NOT NULL UNIQUE,
        title NVARCHAR(255) NOT NULL,
        author NVARCHAR(255) NOT NULL,
        publisher NVARCHAR(255) NULL,
        publish_year INT NULL,
        quantity INT NOT NULL DEFAULT 0,
        status NVARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
        category_id BIGINT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_books_category FOREIGN KEY (category_id) REFERENCES categories(id)
    );
    CREATE INDEX idx_books_title ON books (title);
    CREATE INDEX idx_books_author ON books (author);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[borrow_records]') AND type in (N'U'))
BEGIN
    CREATE TABLE borrow_records (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        user_id BIGINT NOT NULL,
        book_id BIGINT NOT NULL,
        borrow_date DATE NOT NULL,
        due_date DATE NOT NULL,
        return_date DATE NULL,
        status NVARCHAR(30) NOT NULL,
        fine_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_borrow_user FOREIGN KEY (user_id) REFERENCES users(id),
        CONSTRAINT fk_borrow_book FOREIGN KEY (book_id) REFERENCES books(id)
    );
    CREATE INDEX idx_borrow_user_status ON borrow_records (user_id, status);
    CREATE INDEX idx_borrow_book ON borrow_records (book_id);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[reservations]') AND type in (N'U'))
BEGIN
    CREATE TABLE reservations (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        user_id BIGINT NOT NULL,
        book_id BIGINT NOT NULL,
        status NVARCHAR(30) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_res_user FOREIGN KEY (user_id) REFERENCES users(id),
        CONSTRAINT fk_res_book FOREIGN KEY (book_id) REFERENCES books(id)
    );
    CREATE INDEX idx_res_user ON reservations (user_id);
    CREATE INDEX idx_res_book ON reservations (book_id);
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[shipments]') AND type in (N'U'))
BEGIN
    CREATE TABLE shipments (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        borrow_record_id BIGINT NOT NULL,
        tracking_code NVARCHAR(100) NULL,
        status NVARCHAR(50) NOT NULL DEFAULT 'CREATED',
        address NVARCHAR(MAX) NOT NULL,
        phone NVARCHAR(30) NOT NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_ship_borrow FOREIGN KEY (borrow_record_id) REFERENCES borrow_records(id),
        CONSTRAINT uq_ship_tracking UNIQUE (tracking_code)
    );
END
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[password_reset_tokens]') AND type in (N'U'))
BEGIN
    CREATE TABLE password_reset_tokens (
        id BIGINT PRIMARY KEY IDENTITY(1,1),
        user_id BIGINT NOT NULL,
        token_hash NVARCHAR(128) NOT NULL,
        expires_at DATETIME2 NOT NULL,
        used_at DATETIME2 NULL,
        created_at DATETIME2 NOT NULL DEFAULT GETDATE(),
        CONSTRAINT fk_prt_user FOREIGN KEY (user_id) REFERENCES users(id)
    );
    CREATE INDEX idx_prt_user ON password_reset_tokens (user_id);
    CREATE INDEX idx_prt_expires ON password_reset_tokens (expires_at);
END
GO

IF NOT EXISTS (SELECT * FROM roles WHERE name = 'ADMIN') INSERT INTO roles(name) VALUES ('ADMIN');
IF NOT EXISTS (SELECT * FROM roles WHERE name = 'LIBRARIAN') INSERT INTO roles(name) VALUES ('LIBRARIAN');
IF NOT EXISTS (SELECT * FROM roles WHERE name = 'USER') INSERT INTO roles(name) VALUES ('USER');
GO
