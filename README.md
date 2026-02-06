# Library Management Website (LBMS)

## Introduction
**Library Management Website (LBMS)** is a modern library management system built on the **Jakarta EE 10** platform. The project aims to provide a comprehensive solution for managing book inventories, tracking borrow/return cycles, and integrating with third-party services like domestic shipping (GHTK) and email notifications.

## 🚀 Key Features

### For Users
*   **Account Management:** Register, login, and update personal profiles.
*   **Advanced Search:** Filter books by category, author, status, and keywords.
*   **Borrow & Reservation:** Online borrowing workflow and a reservation system for books currently on loan.
*   **Shipping Integration:** Real-time order tracking via **Giao Hang Tiet Kiem (GHTK)**.
*   **Security:** Password recovery with secure email-based tokens.

### For Administrators
*   **Inventory Control:** Full CRUD operations for books and categories.
*   **User Governance:** Approve new accounts, manage roles, and enforce account locks.
*   **Transaction Monitoring:** Oversee all borrowing records and handle returns.
*   **Logistics Management:** Generate shipping labels and track delivery status.

## 🛠 Tech Stack
*   **Language:** Java 11
*   **Framework:** Jakarta EE 10 (Servlet 6.0, JSP, JSTL)
*   **Build Tool:** Maven 3.8+
*   **Persistence:** JPA 3.1 / Hibernate
*   **Server:** Apache Tomcat 10.1+ (Recommended)
*   **API Integrations:** GHTK API (Shipping), JavaMail / SMTP (Email).

## 📁 Directory Structure
*   `src/main/java/com/lbms/controller`: Servlet layers handling HTTP requests.
*   `src/main/java/com/lbms/service`: Business logic and service implementations.
*   `src/main/java/com/lbms/dao`: Data Access Object (DAO) layer using JPA.
*   `src/main/java/com/lbms/model`: Entity classes and database mappings.
*   `src/main/java/com/lbms/filter`: Authentication and Role-based access filters.
*   `src/main/java/com/lbms/util`: Helper classes (DB Connector, Crypto, Config).
*   `src/main/webapp/WEB-INF/views`: JSP template files.

## ⚙️ Project Setup

### Prerequisites
*   JDK 11
*   Maven 3.8+
*   Apache Tomcat 10.1+
*   MySQL/PostgreSQL (Configurable)

### Installation Steps
1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Group-1-SE1908/LibraryManagementWebsite.git
    ```
2.  **Database Configuration:** 
    Update [src/main/resources/META-INF/persistence.xml](src/main/resources/META-INF/persistence.xml) with your database credentials.
3.  **Initialize Database:**
    Execute [src/main/resources/schema.sql](src/main/resources/schema.sql) and [src/main/resources/seed_accounts.sql](src/main/resources/seed_accounts.sql) to set up tables and initial data.
4.  **Build the project:**
    ```bash
    mvn clean install
    ```
5.  **Deployment:** 
    Deploy the generated `.war` file to your Tomcat server.

## 📝 Contribution & Development Rules
To maintain consistency, all contributors must follow these rules:

### Commit Convention
Strictly follow the format: `[UC-xx][Name] Action`
*   **Example:** `[UC-10][QuanNM] Create User Account`
*   **UC-xx:** Refers to the Use Case ID being implemented.

---
*This project is currently under active development.*
