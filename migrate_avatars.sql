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

