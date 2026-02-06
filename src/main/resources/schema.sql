CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

CREATE TABLE Role (
  role_id INT IDENTITY(1,1) PRIMARY KEY,
  role_name NVARCHAR(255) NOT NULL
);
GO

CREATE TABLE [User] (
  user_id INT IDENTITY(1,1) PRIMARY KEY,
  name NVARCHAR(255),
  email NVARCHAR(255),
  password NVARCHAR(255),
  role_id INT
);
GO

CREATE TABLE Permission (
  permission_id INT IDENTITY(1,1) PRIMARY KEY,
  permission_name NVARCHAR(255),
  role_id INT
);
GO

CREATE TABLE Category (
  category_id INT IDENTITY(1,1) PRIMARY KEY,
  category_name NVARCHAR(255)
);
GO

CREATE TABLE Book (
  book_id INT IDENTITY(1,1) PRIMARY KEY,
  title NVARCHAR(255),
  author NVARCHAR(255),
  price DECIMAL(10,2),
  availability BIT,
  category_id INT
);
GO

CREATE TABLE Cart (
  cart_id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT
);
GO

CREATE TABLE CartItem (
  cart_item_id INT IDENTITY(1,1) PRIMARY KEY,
  cart_id INT,
  book_id INT,
  quantity INT
);
GO

CREATE TABLE Borrowing (
  borrowing_id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT,
  borrow_date DATETIME,
  return_date DATETIME,
  status NVARCHAR(255)
);
GO

CREATE TABLE BorrowItem (
  borrow_item_id INT IDENTITY(1,1) PRIMARY KEY,
  borrowing_id INT,
  book_id INT,
  quantity INT
);
GO

CREATE TABLE Delivery (
  delivery_id INT IDENTITY(1,1) PRIMARY KEY,
  borrowing_id INT,
  delivery_status NVARCHAR(255),
  shipping_code NVARCHAR(255)
);
GO

CREATE TABLE Payment (
  payment_id INT IDENTITY(1,1) PRIMARY KEY,
  borrowing_id INT,
  amount DECIMAL(10,2),
  payment_date DATETIME,
  method NVARCHAR(255)
);
GO

CREATE TABLE Feedback (
  feedback_id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT,
  book_id INT,
  content NVARCHAR(MAX),
  rating INT,
  created_at DATETIME
);
GO

CREATE TABLE Notification (
  notification_id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT,
  message NVARCHAR(MAX),
  created_at DATETIME
);
GO

CREATE TABLE LibraryInfo (
  info_id INT IDENTITY(1,1) PRIMARY KEY,
  description NVARCHAR(MAX)
);
GO

CREATE TABLE password_reset_token (
  token_id INT IDENTITY(1,1) PRIMARY KEY,
  user_id INT NOT NULL,
  token VARCHAR(255) NOT NULL,
  expired_at DATETIME NOT NULL,
  used BIT DEFAULT 0,
  created_at DATETIME DEFAULT GETDATE()
);
GO

-- FOREIGN KEYS

ALTER TABLE [User] 
ADD CONSTRAINT FK_User_Role FOREIGN KEY (role_id) REFERENCES Role(role_id);
GO

ALTER TABLE Permission 
ADD CONSTRAINT FK_Permission_Role FOREIGN KEY (role_id) REFERENCES Role(role_id);
GO

ALTER TABLE Book 
ADD CONSTRAINT FK_Book_Category FOREIGN KEY (category_id) REFERENCES Category(category_id);
GO

ALTER TABLE Cart 
ADD CONSTRAINT FK_Cart_User FOREIGN KEY (user_id) REFERENCES [User](user_id);
GO

ALTER TABLE CartItem 
ADD CONSTRAINT FK_CartItem_Cart FOREIGN KEY (cart_id) REFERENCES Cart(cart_id);
GO

ALTER TABLE CartItem 
ADD CONSTRAINT FK_CartItem_Book FOREIGN KEY (book_id) REFERENCES Book(book_id);
GO

ALTER TABLE Borrowing 
ADD CONSTRAINT FK_Borrowing_User FOREIGN KEY (user_id) REFERENCES [User](user_id);
GO

ALTER TABLE BorrowItem 
ADD CONSTRAINT FK_BorrowItem_Borrowing FOREIGN KEY (borrowing_id) REFERENCES Borrowing(borrowing_id);
GO

ALTER TABLE BorrowItem 
ADD CONSTRAINT FK_BorrowItem_Book FOREIGN KEY (book_id) REFERENCES Book(book_id);
GO

ALTER TABLE Delivery 
ADD CONSTRAINT FK_Delivery_Borrowing FOREIGN KEY (borrowing_id) REFERENCES Borrowing(borrowing_id);
GO

ALTER TABLE Payment 
ADD CONSTRAINT FK_Payment_Borrowing FOREIGN KEY (borrowing_id) REFERENCES Borrowing(borrowing_id);
GO

ALTER TABLE Feedback 
ADD CONSTRAINT FK_Feedback_User FOREIGN KEY (user_id) REFERENCES [User](user_id);
GO

ALTER TABLE Feedback 
ADD CONSTRAINT FK_Feedback_Book FOREIGN KEY (book_id) REFERENCES Book(book_id);
GO

ALTER TABLE Notification 
ADD CONSTRAINT FK_Notification_User FOREIGN KEY (user_id) REFERENCES [User](user_id);
GO

ALTER TABLE password_reset_token 
ADD CONSTRAINT FK_ResetToken_User FOREIGN KEY (user_id) REFERENCES [User](user_id);
GO
