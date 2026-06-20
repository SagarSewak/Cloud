# Project Architecture & Technical Overview: Global Digital Bank (GDB)

Welcome to the **Global Digital Bank (GDB)** project! This document provides a detailed overview of the project's architecture, the technologies used, and how everything works together in the backend. This guide is designed to be accessible for absolute beginners.

---

## 1. What is Global Digital Bank?
Global Digital Bank is a modern, distributed banking system designed to handle core banking operations like user management, account handling, and financial transactions. Unlike older "monolithic" systems where everything is in one big program, GDB uses a **Microservices Architecture**.

---

## 2. Architecture: The Microservices Approach
### Monolith vs. Microservices
*   **Monolith:** Imagine a giant factory where everything (making shoes, shirts, and hats) happens in one room. If the shoe machine breaks, the whole factory might stop.
*   **Microservices:** Imagine several smaller, specialized shops. One shop only makes shoes, another only makes shirts. If the shoe shop has a problem, the shirt shop keeps working.

### Our Microservices
GDB is split into several "services," each responsible for a specific task:
1.  **`eureka-server`:** The "Registry." It keeps track of which services are running and where they are located.
2.  **`gateway-service`:** The "Entrance." Every request from the outside world (like the frontend) goes here first. It routes the request to the right shop.
3.  **`auth-service`:** The "Security Guard." It handles logins, checks passwords, and issues "tokens" (like a digital badge) so users can stay logged in.
4.  **`users-service`:** The "Profile Manager." It stores user details like names, addresses, and roles (Admin, Teller, Manager).
5.  **`account-service`:** The "Banker." It manages bank accounts, balances, and links them to users.
6.  **`transactions-service`:** The "Cashier." It handles moving money (deposits, withdrawals, and transfers) and keeps a history of every transaction.
7.  **`aadhar-service`:** An "External Verification" simulator. It checks if a user's Aadhar number is valid.
8.  **`company-service` & `payment-gateway-service`:** Additional support services for business accounts and external payments.

---

## 3. The Technology Stack
We use **Java** as the programming language and **Spring Boot** as the primary framework.

### Why Spring Boot?
Spring Boot is like a "starter kit" for Java. It provides pre-built components so we don't have to write basic code from scratch.
*   **Spring Web:** Helps us create "REST APIs" (how the frontend talks to the backend).
*   **Spring Data JPA:** Makes it easy for Java to talk to the **PostgreSQL** database.
*   **Spring Security:** Handles the "Security Guard" duties.
*   **Spring Cloud (Eureka & Gateway):** Helps the microservices find and talk to each other.

### Other Key Technologies
*   **PostgreSQL:** Our "Digital Filing Cabinet." This is where all the data (users, accounts, transactions) is stored permanently.
*   **Flyway:** A "Time Machine" for our database. It tracks changes to the database structure so everyone has the same version.
*   **Lombok:** A tool that saves us from writing repetitive Java code (like getters and setters).
*   **Resilience4j:** A "Safety Net." If one service is slow or fails, this helps the system "retry" or handle the error gracefully instead of crashing.

---

## 4. How the Backend Works (A Beginner's Guide)
When you click "View Balance" in the browser, here is what happens:

1.  **Request:** The browser sends a request to the `gateway-service`.
2.  **Routing:** The Gateway asks the `eureka-server` where the `account-service` is, then sends the request there.
3.  **Controller Layer:** The request hits a "Controller" in the Java code. Think of this as the "Receptionist" who takes your order.
4.  **Service Layer:** The Controller passes the order to the "Service" layer. This is where the "Business Logic" lives (e.g., checking if you have enough money).
5.  **Repository Layer:** The Service asks the "Repository" to fetch data from the Database. The Repository uses **JPA** to translate Java into SQL (the database language).
6.  **DTOs (Data Transfer Objects):** We use DTOs to pack the data into a neat box to send back to the user, ensuring we don't share sensitive data (like passwords).
7.  **Response:** The data travels back through the layers and finally reaches your screen.

---

## 5. Recent Improvements (The "MOD" Changes)
We recently made several updates to make the system faster, safer, and more reliable:

*   **Decoupling (MOD1):** We organized the code better so different parts don't rely too heavily on each other.
*   **Performance Tracking (MOD2):** We added "Aspects" (AOP) that automatically measure how long a transaction takes, helping us find bottlenecks.
*   **Better Database Queries (MOD3):** We upgraded how we talk to the database to make the code easier to read and prevent errors.
*   **Smart Sorting (MOD4):** Fixed a bug where the system crashed if you tried to sort security alerts.
*   **Environment Profiles (MOD5):** We created "Dev" and "Prod" settings, so we can test safely on our laptops without affecting the real system.
*   **Safety Caps (MOD6):** Added a $50,000 limit on deposits to prevent massive errors or fraud.
*   **Caching (MOD7):** Added a "Short-term Memory" (Cache). Now, if you check your balance twice, the second time is instant because the system remembers it.
*   **Token Revocation (MOD8):** Improved security so that when you log out, your old session is truly "killed" and can't be used again.
*   **Automated Testing (MOD9):** Wrote "Robot Tests" that automatically check if the code is working correctly every time we make a change.
*   **Eureka Registry (MOD12):** Connected all services to a central registry so they can find each other automatically.

---

## 6. How to Run the Project
1.  **Start Database:** Ensure PostgreSQL is running on port 5432 with password `java`.
2.  **Start Eureka:** Run `eureka-server` first.
3.  **Start Services:** Run all other microservices. They will register themselves with Eureka.
4.  **Start Gateway:** Run `gateway-service` to enable API access.
5.  **Start Frontend:** Go to the `frontend` folder and run `npm run dev`.

This architecture ensures that Global Digital Bank is **scalable** (can handle more users), **maintainable** (easy to fix), and **robust** (hard to crash)!
