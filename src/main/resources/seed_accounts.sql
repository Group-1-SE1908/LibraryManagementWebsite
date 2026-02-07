-- Seed default accounts for LBMS (MySQL)
USE lbms;

-- Roles (idempotent)
INSERT IGNORE INTO roles(name) VALUES ('ADMIN'), ('LIBRARIAN'), ('USER');

-- Default passwords (BCrypt for '123456')
-- Generated with jBCrypt (10 rounds)
SET @HASH_123456 = '$2a$10$1Q7lUSpJpZ8J3QpC9r7s4e8tYpXl6D9d3S0z8m7q5wYw8vZr8q3eK';

-- Admin
INSERT INTO users(email, password_hash, full_name, status, role_id)
SELECT 'admin@lbms.local', @HASH_123456, 'Admin', 'ACTIVE', r.id
FROM roles r
WHERE r.name='ADMIN'
ON DUPLICATE KEY UPDATE role_id=VALUES(role_id), status=VALUES(status);

-- Librarian
INSERT INTO users(email, password_hash, full_name, status, role_id)
SELECT 'librarian@lbms.local', @HASH_123456, 'Librarian', 'ACTIVE', r.id
FROM roles r
WHERE r.name='LIBRARIAN'
ON DUPLICATE KEY UPDATE role_id=VALUES(role_id), status=VALUES(status);

-- User
INSERT INTO users(email, password_hash, full_name, status, role_id)
SELECT 'user@lbms.local', @HASH_123456, 'User', 'ACTIVE', r.id
FROM roles r
WHERE r.name='USER'
ON DUPLICATE KEY UPDATE role_id=VALUES(role_id), status=VALUES(status);
