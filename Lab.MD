# PROJECT CONTEXT: Library Management System (LBMS)

## 1. SYSTEM OVERVIEW & GOAL
This document defines the requirements, architecture, and logic for the **Library Management System (LBMS)**.
**Goal:** Build a Java Web Application using the **MVC (Model-View-Controller)** pattern.
**Key Features:** Core library operations (Borrow/Return), User Management, and Third-party integrations (Gmail, GHTK).

---

## 2. TECHNOLOGY STACK (STRICT)
* **Language:** Java (JDK 17 or 21 recommended).
* **Architecture Pattern:** MVC (Model - View - Controller).
* **Web Framework:** Java Servlet/JSP **OR** Spring MVC (Specify based on setup).
* **Database:** MySQL or SQL Server.
* **Frontend:** JSP, HTML5, CSS3, JavaScript (Bootstrap recommended).
* **Build Tool:** Maven or Gradle.
* **External APIs:**
    * **Gmail SMTP:** For password reset emails.
    * **GHTK API (Giao Hang Tiet Kiem):** For book shipping integration.

---

## 3. ARCHITECTURE DESIGN (MVC)

### 3.1. Folder Structure & Responsibilities
The project **MUST** follow this separation of concerns:

1.  **MODEL (Data & Logic layer):**
    * `src/main/java/com/lbms/model`: Entity classes (POJOs) mapping to DB tables.
    * `src/main/java/com/lbms/dao`: Data Access Objects. Contains raw JDBC/Hibernate queries. **NO** business logic here, only CRUD.
    * `src/main/java/com/lbms/service` (Optional but recommended): Contains business rules (e.g., calculating fines, calling GHTK API).
2.  **VIEW (Presentation layer):**
    * `src/main/webapp/views`: JSP files.
    * **Rule:** Views must only display data passed by the Controller. No SQL queries in JSP.
3.  **CONTROLLER (Request handling):**
    * `src/main/java/com/lbms/controller`: Servlets or Spring Controllers.
    * **Flow:** Receive Request -> Validate Input -> Call Service/DAO -> Update Model -> Forward to View.

---

## 4. DATABASE SCHEMA (ERD)
The database **MUST** implement the following tables with appropriate constraints/indexes.

* **Users**: `id` (PK), `email` (Unique), `password_hash`, `full_name`, `role` (ENUM: ADMIN, LIBRARIAN, USER), `status` (ACTIVE, LOCKED).
* **Books**: `id` (PK), `isbn` (Index), `title`, `author`, `publisher`, `publication_year`, `quantity` (Total), `available_qty` (Current stock).
* **BorrowRecords**: `id` (PK), `user_id` (FK), `book_id` (FK), `borrow_date`, `due_date`, `return_date` (Nullable), `status` (BORROWED, RETURNED, OVERDUE), `fine_amount`.
* **PasswordResetTokens**: `id` (PK), `user_id` (FK), `token` (Unique), `expiry_date`.
* **Shipments**: `id` (PK), `borrow_record_id` (FK), `ghtk_tracking_code`, `status` (PENDING, SHIPPING, DELIVERED).

---

## 5. FUNCTIONAL REQUIREMENTS & LOGIC FLOWS

### 5.1. User Management (Auth)
* **Actors:** Guest, Admin, User.
* **Flows:**
    * **Login:** Check email/password (BCrypt). Save User object to `HttpSession`.
    * **Register:** Create new user with role `USER`. Default status `ACTIVE`.
    * **Authorization:** Admin creates Librarian. Admin/Librarian can lock/unlock User accounts.

### 5.2. Forgot Password (Gmail Integration)
* **Logic:**
    1.  User inputs email.
    2.  System checks if email exists.
    3.  Generate a random UUID `token`. Save to `PasswordResetTokens` with 15-min expiry.
    4.  **JavaMailSender** sends link: `http://domain/reset?token=XYZ`.
    5.  User clicks link -> Controller validates token (exists & not expired).
    6.  User updates password -> Hash new password -> Update DB -> Delete/Invalidate token.

### 5.3. Book Management
* **Actors:** Librarian, Admin.
* **Logic:**
    * **Add Book:** Input details. `available_qty` must equal `quantity` initially.
    * **Search:** Filter by Title, Author, or Category using SQL `LIKE`.

### 5.4. Borrow & Return (CORE BUSINESS LOGIC)
**A. Borrowing Flow:**
1.  User requests a book.
2.  **Validation:**
    * User status must be `ACTIVE`.
    * Book `available_qty` > 0.
    * User has not exceeded max borrow limit (e.g., 3 books).
3.  **Action:**
    * Create `BorrowRecord` (Status: BORROWED, DueDate: +14 days).
    * **Decrease** Book `available_qty` by 1.
    * Commit Transaction.

**B. Returning Flow:**
1.  Librarian scans book/inputs ID.
2.  **Calculation:**
    * If `current_date` > `due_date`: Calculate `fine = (days_late * daily_fee)`.
3.  **Action:**
    * Update `BorrowRecord`: Set `return_date` = now, `status` = RETURNED, update `fine_amount`.
    * **Increase** Book `available_qty` by 1.

### 5.5. Shipping Integration (GHTK)
* **Trigger:** User requests "Home Delivery" when borrowing.
* **Flow:**
    1.  Collect shipping address from User.
    2.  **API Call:** Send JSON payload to Giao Hang Tiet Kiem API (create order).
    3.  Receive `tracking_code` from API response.
    4.  Save to `Shipments` table.
    5.  **Job/Update:** Provide a feature to query GHTK API to update shipment status.

---

## 6. NON-FUNCTIONAL REQUIREMENTS
1.  **Security:**
    * Never store plain-text passwords. Use **BCrypt**.
    * Prevent SQL Injection by using **PreparedStatement** (JDBC) or parameterized queries.
    * Role-based Access Control (RBAC) via Filter/Interceptor.
2.  **Performance:** Database connection pooling (HikariCP or standard Pool) is required.
3.  **Reliability:** Transactions (ACID) must be used for Borrow/Return logic to prevent data inconsistency.

---

## 7. NEXT STEPS FOR AI IMPLEMENTATION
When generating code, please follow this order:
1.  **Database:** Generate SQL script for Schema setup.
2.  **Model:** Generate Entity classes and DAO interfaces.
3.  **Config:** DB Connection setup.
4.  **Core Logic:** Implement Service methods for Borrow/Return with transactional integrity.
5.  **Controller & View:** Create the Web layer.

Chào bạn, để "train" cho AI (như ChatGPT, Claude, GitHub Copilot, hoặc Cursor) hiểu và code đúng hệ thống Library Management System (LBMS) theo đúng chuẩn MVC và yêu cầu nghiệp vụ bạn đưa ra, bạn cần một file văn bản có cấu trúc cực kỳ chặt chẽ (Context file).

Dưới đây là file LBMS_System_Design.md được thiết kế chuyên biệt để làm đầu vào (input) cho AI. Nó được viết bằng ngôn ngữ kỹ thuật, chia nhỏ logic để AI không bị "ảo giác" (hallucinate) khi viết code.

Cách sử dụng file này
Copy toàn bộ nội dung trong khối code bên dưới.

Lưu thành file LBMS_System_Design.md hoặc CONTEXT.md trong thư mục gốc của dự án.

Khi chat với AI, hãy bắt đầu bằng: "Dựa trên file LBMS_System_Design.md, hãy giúp tôi thực hiện chức năng [Tên chức năng]..."

File MD: LBMS_System_Design.md
Markdown
# PROJECT CONTEXT: Library Management System (LBMS)

## 1. SYSTEM OVERVIEW & GOAL
This document defines the requirements, architecture, and logic for the **Library Management System (LBMS)**.
**Goal:** Build a Java Web Application using the **MVC (Model-View-Controller)** pattern.
**Key Features:** Core library operations (Borrow/Return), User Management, and Third-party integrations (Gmail, GHTK).

---

## 2. TECHNOLOGY STACK (STRICT)
* **Language:** Java (JDK 17 or 21 recommended).
* **Architecture Pattern:** MVC (Model - View - Controller).
* **Web Framework:** Java Servlet/JSP **OR** Spring MVC (Specify based on setup).
* **Database:** MySQL or SQL Server.
* **Frontend:** JSP, HTML5, CSS3, JavaScript (Bootstrap recommended).
* **Build Tool:** Maven or Gradle.
* **External APIs:**
    * **Gmail SMTP:** For password reset emails.
    * **GHTK API (Giao Hang Tiet Kiem):** For book shipping integration.

---

## 3. ARCHITECTURE DESIGN (MVC)

### 3.1. Folder Structure & Responsibilities
The project **MUST** follow this separation of concerns:

1.  **MODEL (Data & Logic layer):**
    * `src/main/java/com/lbms/model`: Entity classes (POJOs) mapping to DB tables.
    * `src/main/java/com/lbms/dao`: Data Access Objects. Contains raw JDBC/Hibernate queries. **NO** business logic here, only CRUD.
    * `src/main/java/com/lbms/service` (Optional but recommended): Contains business rules (e.g., calculating fines, calling GHTK API).
2.  **VIEW (Presentation layer):**
    * `src/main/webapp/views`: JSP files.
    * **Rule:** Views must only display data passed by the Controller. No SQL queries in JSP.
3.  **CONTROLLER (Request handling):**
    * `src/main/java/com/lbms/controller`: Servlets or Spring Controllers.
    * **Flow:** Receive Request -> Validate Input -> Call Service/DAO -> Update Model -> Forward to View.

---

## 4. DATABASE SCHEMA (ERD)
The database **MUST** implement the following tables with appropriate constraints/indexes.

* **Users**: `id` (PK), `email` (Unique), `password_hash`, `full_name`, `role` (ENUM: ADMIN, LIBRARIAN, USER), `status` (ACTIVE, LOCKED).
* **Books**: `id` (PK), `isbn` (Index), `title`, `author`, `publisher`, `publication_year`, `quantity` (Total), `available_qty` (Current stock).
* **BorrowRecords**: `id` (PK), `user_id` (FK), `book_id` (FK), `borrow_date`, `due_date`, `return_date` (Nullable), `status` (BORROWED, RETURNED, OVERDUE), `fine_amount`.
* **PasswordResetTokens**: `id` (PK), `user_id` (FK), `token` (Unique), `expiry_date`.
* **Shipments**: `id` (PK), `borrow_record_id` (FK), `ghtk_tracking_code`, `status` (PENDING, SHIPPING, DELIVERED).

---

## 5. FUNCTIONAL REQUIREMENTS & LOGIC FLOWS

### 5.1. User Management (Auth)
* **Actors:** Guest, Admin, User.
* **Flows:**
    * **Login:** Check email/password (BCrypt). Save User object to `HttpSession`.
    * **Register:** Create new user with role `USER`. Default status `ACTIVE`.
    * **Authorization:** Admin creates Librarian. Admin/Librarian can lock/unlock User accounts.

### 5.2. Forgot Password (Gmail Integration)
* **Logic:**
    1.  User inputs email.
    2.  System checks if email exists.
    3.  Generate a random UUID `token`. Save to `PasswordResetTokens` with 15-min expiry.
    4.  **JavaMailSender** sends link: `http://domain/reset?token=XYZ`.
    5.  User clicks link -> Controller validates token (exists & not expired).
    6.  User updates password -> Hash new password -> Update DB -> Delete/Invalidate token.

### 5.3. Book Management
* **Actors:** Librarian, Admin.
* **Logic:**
    * **Add Book:** Input details. `available_qty` must equal `quantity` initially.
    * **Search:** Filter by Title, Author, or Category using SQL `LIKE`.

### 5.4. Borrow & Return (CORE BUSINESS LOGIC)
**A. Borrowing Flow:**
1.  User requests a book.
2.  **Validation:**
    * User status must be `ACTIVE`.
    * Book `available_qty` > 0.
    * User has not exceeded max borrow limit (e.g., 3 books).
3.  **Action:**
    * Create `BorrowRecord` (Status: BORROWED, DueDate: +14 days).
    * **Decrease** Book `available_qty` by 1.
    * Commit Transaction.

**B. Returning Flow:**
1.  Librarian scans book/inputs ID.
2.  **Calculation:**
    * If `current_date` > `due_date`: Calculate `fine = (days_late * daily_fee)`.
3.  **Action:**
    * Update `BorrowRecord`: Set `return_date` = now, `status` = RETURNED, update `fine_amount`.
    * **Increase** Book `available_qty` by 1.

### 5.5. Shipping Integration (GHTK)
* **Trigger:** User requests "Home Delivery" when borrowing.
* **Flow:**
    1.  Collect shipping address from User.
    2.  **API Call:** Send JSON payload to Giao Hang Tiet Kiem API (create order).
    3.  Receive `tracking_code` from API response.
    4.  Save to `Shipments` table.
    5.  **Job/Update:** Provide a feature to query GHTK API to update shipment status.

---

## 6. NON-FUNCTIONAL REQUIREMENTS
1.  **Security:**
    * Never store plain-text passwords. Use **BCrypt**.
    * Prevent SQL Injection by using **PreparedStatement** (JDBC) or parameterized queries.
    * Role-based Access Control (RBAC) via Filter/Interceptor.
2.  **Performance:** Database connection pooling (HikariCP or standard Pool) is required.
3.  **Reliability:** Transactions (ACID) must be used for Borrow/Return logic to prevent data inconsistency.

---

## 7. NEXT STEPS FOR AI IMPLEMENTATION
When generating code, please follow this order:
1.  **Database:** Generate SQL script for Schema setup.
2.  **Model:** Generate Entity classes and DAO interfaces.
3.  **Config:** DB Connection setup.
4.  **Core Logic:** Implement Service methods for Borrow/Return with transactional integrity.
5.  **Controller & View:** Create the Web layer.
Mẹo để AI hoạt động hiệu quả nhất

Shutterstock
Yêu cầu tạo SQL trước: Sau khi nạp file này, hãy bảo AI: "Tạo cho tôi script SQL MySQL đầy đủ cho các bảng đã mô tả trong phần 4."

Yêu cầu Code theo lớp: Đừng bảo AI viết hết 1 lúc. Hãy đi từng bước:

"Viết cho tôi lớp BorrowDAO và BorrowService xử lý logic mượn trả, chú ý Transaction."

"Viết Controller cho chức năng Forgot Password tích hợp Gmail."

Xử lý GHTK: Vì API GHTK cần tài khoản thật, hãy bảo AI: "Tạo cho tôi một Interface IGHTKService và một class Mock (giả lập) để test chức năng tạo đơn hàng mà không cần gọi API thật."

<!-- admin@lbms.local / 123456 -->
