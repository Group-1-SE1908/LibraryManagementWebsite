
-- TABLE: Comment

CREATE TABLE Comment (
    comment_id BIGINT IDENTITY(1,1) PRIMARY KEY,

    book_id INT NOT NULL,
    user_id INT NOT NULL,

    content NVARCHAR(500) NOT NULL,  -- giới hạn 500 ký tự theo BR

    rating INT NOT NULL 
        CHECK (rating BETWEEN 1 AND 5),

    status VARCHAR(20) NOT NULL DEFAULT 'VISIBLE',
    -- VISIBLE | HIDDEN | DELETED

    created_at DATETIME NOT NULL DEFAULT GETDATE(),
    updated_at DATETIME NULL,
    deleted_at DATETIME NULL,

    CONSTRAINT FK_Comment_Book
        FOREIGN KEY (book_id)
        REFERENCES Book(book_id)
        ON DELETE CASCADE,

    CONSTRAINT FK_Comment_User
        FOREIGN KEY (user_id)
        REFERENCES [User](user_id)
        ON DELETE CASCADE
);
GO
-- Script để migrate old avatars sang đường dẫn mới
-- Cập nhật những avatar có format cũ (chỉ tên file) sang format mới (uploads/filename)

UPDATE [User]
SET avatar = 'uploads/' + avatar
WHERE avatar IS NOT NULL 
  AND avatar != ''
  AND avatar NOT LIKE 'uploads/%'
  AND avatar NOT LIKE 'null'
  AND avatar NOT LIKE '%/%';  -- Loại bỏ những cái đã có đường dẫn

-- Kiểm tra kết quả
SELECT user_id, full_name, avatar FROM [User] WHERE avatar IS NOT NULL AND avatar != '' ORDER BY user_id;

-- Nếu có avatar bị trùng uploads/, xóa thừa
UPDATE [User]
SET avatar = SUBSTRING(avatar, 9, LEN(avatar))  -- Xóa "uploads/" đầu
WHERE avatar LIKE 'uploads/uploads/%';

-- Kiểm tra lại
SELECT user_id, full_name, avatar FROM [User] WHERE avatar LIKE '%/%' ORDER BY user_id;


--Fix header avatar 
UPDATE [User]
SET avatar = 'uploads/' + avatar
WHERE avatar IS NOT NULL 
  AND avatar != ''
  AND avatar NOT LIKE 'uploads/%'
  AND avatar NOT LIKE 'null'
  AND avatar NOT LIKE '%/%';

-- Nếu có avatar bị trùng uploads/, xóa thừa
UPDATE [User]
SET avatar = SUBSTRING(avatar, 9, LEN(avatar))
WHERE avatar LIKE 'uploads/uploads/%';


--fix avatar guide
UPDATE [User]
SET avatar = 'uploads/' + avatar
WHERE avatar IS NOT NULL 
  AND avatar != ''
  AND avatar NOT LIKE 'uploads/%'
  AND avatar NOT LIKE 'null';