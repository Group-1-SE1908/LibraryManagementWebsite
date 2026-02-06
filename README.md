# Library Management Website

## Introduction
**Library Management Website** is a modern library management web application built on the Jakarta EE platform. The project is designed to simplify book management, borrowing/returning processes, and integrate with domestic shipping services.

## 🚀 Key Features

### For Users
*   **Account Management:** Register, login, and update personal information.
*   **Book Search:** Search for books by category, author, and status.
*   **Borrow & Reserve:** Online borrowing process and book reservation when a book is currently borrowed by others.
*   **Shipping Tracking:** View order status through GHTK integration.
*   **Password Recovery:** System sends tokens via email to reset passwords.

### For Administrators (Admin)
*   **Book Management:** CRUD (Create, Read, Update, Delete) book information and categories.
*   **User Management:** Approve accounts, manage roles, and lock users.
*   **Borrow/Return Management:** Monitor borrowing records and process book returns.
*   **Shipping Management:** Create orders and track them with shipping partners.

## 🛠 Technologies Used
*   **Language:** Java 11
*   **Framework:** Jakarta EE 10 (Servlet, JSP, JSTL)
*   **Build Tool:** Maven 3.8+
*   **Persistence:** JPA/Hibernate
*   **Database:** (Configurable in `persistence.xml`)
*   **Third-party Services:** GHTK API (Shipping), Email Service.

## 📁 Directory Structure
*   `src/main/java/com/lbms/controller`: Handles HTTP requests.
*   `src/main/java/com/lbms/service`: Contains the business logic of the application.
*   `src/main/java/com/lbms/dao`: Data Access Object layer.
*   `src/main/java/com/lbms/model`: Defines entities.
*   `src/main/webapp/WEB-INF/views`: Contains JSP views.

## ⚙️ Installation and Setup
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Group-1-SE1908/LibraryManagementWebsite.git
    ```
2.  **Database Configuration:** Update connection details in [src/main/resources/META-INF/persistence.xml](src/main/resources/META-INF/persistence.xml).
3.  **Initialize Database:** Run the [src/main/resources/schema.sql](src/main/resources/schema.sql) file in your DB manager.
4.  **Build the project:**
    ```bash
    mvn clean install
    ```
5.  **Deployment:** Deploy the `.war` file to servers like Tomcat 10+ or GlassFish/Payara.

---
*This project is under development.*
