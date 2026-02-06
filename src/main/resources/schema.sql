CREATE DATABASE LibraryDB;
GO

USE LibraryDB;
GO

CREATE TABLE [User] (
  [user_id] int PRIMARY KEY,
  [name] nvarchar(255),
  [email] nvarchar(255),
  [password] nvarchar(255),
  [role_id] int
)
GO

CREATE TABLE [Role] (
  [role_id] int PRIMARY KEY,
  [role_name] nvarchar(255)
)
GO

CREATE TABLE [Permission] (
  [permission_id] int PRIMARY KEY,
  [permission_name] nvarchar(255),
  [role_id] int
)
GO

CREATE TABLE [Book] (
  [book_id] int PRIMARY KEY,
  [title] nvarchar(255),
  [author] nvarchar(255),
  [price] decimal,
  [availability] boolean,
  [category_id] int
)
GO

CREATE TABLE [Category] (
  [category_id] int PRIMARY KEY,
  [category_name] nvarchar(255)
)
GO

CREATE TABLE [Cart] (
  [cart_id] int PRIMARY KEY,
  [user_id] int
)
GO

CREATE TABLE [CartItem] (
  [cart_item_id] int PRIMARY KEY,
  [cart_id] int,
  [book_id] int,
  [quantity] int
)
GO

CREATE TABLE [Borrowing] (
  [borrowing_id] int PRIMARY KEY,
  [user_id] int,
  [borrow_date] datetime,
  [return_date] datetime,
  [status] nvarchar(255)
)
GO

CREATE TABLE [BorrowItem] (
  [borrow_item_id] int PRIMARY KEY,
  [borrowing_id] int,
  [book_id] int,
  [quantity] int
)
GO

CREATE TABLE [Delivery] (
  [delivery_id] int PRIMARY KEY,
  [borrowing_id] int,
  [delivery_status] nvarchar(255),
  [shipping_code] nvarchar(255)
)
GO

CREATE TABLE [Payment] (
  [payment_id] int PRIMARY KEY,
  [borrowing_id] int,
  [amount] decimal,
  [payment_date] datetime,
  [method] nvarchar(255)
)
GO

CREATE TABLE [Feedback] (
  [feedback_id] int PRIMARY KEY,
  [user_id] int,
  [book_id] int,
  [content] text,
  [rating] int,
  [created_at] datetime
)
GO

CREATE TABLE [Notification] (
  [notification_id] int PRIMARY KEY,
  [user_id] int,
  [message] text,
  [created_at] datetime
)
GO

CREATE TABLE [LibraryInfo] (
  [info_id] int PRIMARY KEY,
  [description] text
)
GO

CREATE TABLE [password_reset_token] (
  [token_id] int PRIMARY KEY IDENTITY(1, 1),
  [user_id] int NOT NULL,
  [token] varchar(255) NOT NULL,
  [expired_at] datetime NOT NULL,
  [used] boolean DEFAULT (false),
  [created_at] datetime DEFAULT (CURRENT_TIMESTAMP)
)
GO

ALTER TABLE [password_reset_token] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([user_id])
GO

ALTER TABLE [User] ADD FOREIGN KEY ([role_id]) REFERENCES [Role] ([role_id])
GO

ALTER TABLE [Permission] ADD FOREIGN KEY ([role_id]) REFERENCES [Role] ([role_id])
GO

ALTER TABLE [Book] ADD FOREIGN KEY ([category_id]) REFERENCES [Category] ([category_id])
GO

ALTER TABLE [Cart] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([user_id])
GO

ALTER TABLE [CartItem] ADD FOREIGN KEY ([cart_id]) REFERENCES [Cart] ([cart_id])
GO

ALTER TABLE [CartItem] ADD FOREIGN KEY ([book_id]) REFERENCES [Book] ([book_id])
GO

ALTER TABLE [Borrowing] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([user_id])
GO

ALTER TABLE [BorrowItem] ADD FOREIGN KEY ([borrowing_id]) REFERENCES [Borrowing] ([borrowing_id])
GO

ALTER TABLE [BorrowItem] ADD FOREIGN KEY ([book_id]) REFERENCES [Book] ([book_id])
GO

ALTER TABLE [Delivery] ADD FOREIGN KEY ([borrowing_id]) REFERENCES [Borrowing] ([borrowing_id])
GO

ALTER TABLE [Payment] ADD FOREIGN KEY ([borrowing_id]) REFERENCES [Borrowing] ([borrowing_id])
GO

ALTER TABLE [Feedback] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([user_id])
GO

ALTER TABLE [Feedback] ADD FOREIGN KEY ([book_id]) REFERENCES [Book] ([book_id])
GO

ALTER TABLE [Notification] ADD FOREIGN KEY ([user_id]) REFERENCES [User] ([user_id])
GO
