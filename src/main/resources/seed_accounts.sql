-- Seed default accounts for LBMS (SQL Server)
USE lbms;
GO

-- Roles (idempotent)
IF NOT EXISTS (SELECT * FROM roles WHERE name = 'ADMIN') INSERT INTO roles(name) VALUES ('ADMIN');
IF NOT EXISTS (SELECT * FROM roles WHERE name = 'LIBRARIAN') INSERT INTO roles(name) VALUES ('LIBRARIAN');
IF NOT EXISTS (SELECT * FROM roles WHERE name = 'USER') INSERT INTO roles(name) VALUES ('USER');
GO

-- Default passwords (BCrypt for '123456')
DECLARE @HASH_123456 NVARCHAR(100) = '';

-- Admin
IF NOT EXISTS (SELECT * FROM users WHERE email = 'admin@lbms.local')
BEGIN
    INSERT INTO users(email, password_hash, full_name, status, role_id)
    SELECT 'admin@lbms.local', @HASH_123456, 'Admin', 'ACTIVE', id
    FROM roles WHERE name = 'ADMIN';
END
ELSE
BEGIN
    UPDATE users 
    SET role_id = (SELECT id FROM roles WHERE name = 'ADMIN'), status = 'ACTIVE'
    WHERE email = 'admin@lbms.local';
END

-- Librarian
IF NOT EXISTS (SELECT * FROM users WHERE email = 'librarian@lbms.local')
BEGIN
    INSERT INTO users(email, password_hash, full_name, status, role_id)
    SELECT 'librarian@lbms.local', @HASH_123456, 'Librarian', 'ACTIVE', id
    FROM roles WHERE name = 'LIBRARIAN';
END
ELSE
BEGIN
    UPDATE users 
    SET role_id = (SELECT id FROM roles WHERE name = 'LIBRARIAN'), status = 'ACTIVE'
    WHERE email = 'librarian@lbms.local';
END

-- User
IF NOT EXISTS (SELECT * FROM users WHERE email = 'user@lbms.local')
BEGIN
    INSERT INTO users(email, password_hash, full_name, status, role_id)
    SELECT 'user@lbms.local', @HASH_123456, 'User', 'ACTIVE', id
    FROM roles WHERE name = 'USER';
END
ELSE
BEGIN
    UPDATE users 
    SET role_id = (SELECT id FROM roles WHERE name = 'USER'), status = 'ACTIVE'
    WHERE email = 'user@lbms.local';
END
GO
