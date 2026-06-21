# GDB CloudOps Project - Teacher Presentation & Explanation Guide

This guide is structured to help you present and explain this project to your teacher. It breaks down the implementation step-by-step, explains the engineering choices, and provides answers to common questions your teacher might ask.

---

## 1. Project Overview (The "Elevator Pitch")
> **How to introduce the project:**
> *"For this project, we took a Global Digital Bank (GDB) platform consisting of a React frontend and multiple Spring Boot microservices and transformed it into a cloud-native, production-ready system. We established a strict Git workflow, containerized all services using Docker, set up local deployment using Docker Compose, wrote Infrastructure as Code (IaC) using Terraform, automated builds with GitHub Actions CI/CD, routed traffic dynamically using Eureka Service Discovery and an API Gateway, and finally, modernized the deployment using Kubernetes with a path-based Ingress controller."*

---

## 2. Step-by-Step Implementation Walkthrough

Here is the exact order in which we built and configured this project:

### Step 1: Version Control & Git Flow (Level 1)
*   **What we did:** Initialized Git and established two main branches: `main` (for stable, production-ready code) and `dev` (the integration/staging branch where developers combine features).
*   **Why we did it:** To prevent team members from stepping on each other's code. We simulated the workflow by creating a feature branch `feature/GDB-100-documentation`, making commits, and merging it to `dev`.
*   **Key File:** [BRANCHING_STRATEGY.md](./BRANCHING_STRATEGY.md)

### Step 2: Docker Containerization (Level 2)
*   **What we did:** Wrote a `Dockerfile` for every single service.
    *   **For Backend:** Used `eclipse-temurin:17-jre-alpine` as the base image to copy and run the compiled JAR files.
    *   **For Frontend:** Used a **multi-stage build**. Stage 1 compiles the React code with Node, and Stage 2 copies the compiled assets to Nginx (`nginx:stable-alpine`) to serve it on port 80.
*   **Why we did it:** To resolve the "works on my machine" problem. Containers guarantee that the application runs identically on your laptop, the teacher's laptop, or AWS.
*   **Key Files:** [gateway-service/Dockerfile](./gateway-service/Dockerfile), [frontend/Dockerfile](./frontend/Dockerfile), and other backend Dockerfiles.

### Step 3: Local Orchestration (Level 3)
*   **What we did:** Designed a `docker-compose.yml` stack to run all services locally. We also wrote `init-db.sh` so that when the PostgreSQL container starts, it automatically creates four separate databases: `auth_db`, `users_db`, `accounts_db`, and `trasaction_db`.
*   **Why we did it:** To run the entire bank (11 containers) with a single command (`docker-compose up`). We also used health checks to make sure microservices don't start until the database and Eureka are fully up.
*   **Key Files:** [docker-compose.yml](./docker-compose.yml), [init-db.sh](./init-db.sh)

### Step 4: Infrastructure as Code (Level 4)
*   **What we did:** Used Terraform to define a secure cloud network on AWS. It provisions a Virtual Private Cloud (VPC), a Public Subnet (for Frontend and Gateway), a Private Subnet (for the app servers and databases), Internet Gateways, and Security Groups (firewalls).
*   **Why we did it:** Manual cloud provisioning is slow and error-prone. With Terraform, we define infrastructure in code, allowing us to spin up or tear down the entire AWS environment instantly.
*   **Key Files:** [terraform/main.tf](./terraform/main.tf), [terraform/variables.tf](./terraform/variables.tf)

### Step 5: CI/CD Automation (Level 5)
*   **What we did:** Created a GitHub Actions workflow in `.github/workflows/ci-cd.yml` that triggers on every push or pull request.
*   **Why we did it:** To automate testing and image publishing. It builds the Java JAR files, compiles the React assets, builds the Docker images, and pushes them directly to GitHub Container Registry (GHCR).
*   **Key File:** [.github/workflows/ci-cd.yml](./.github/workflows/ci-cd.yml)

### Step 6: Service Integration & Gateway Routing (Level 6 & 7)
*   **What we did:** Registered all microservices with the **Eureka Service Registry**. We also configured the **API Gateway** to route traffic dynamically using Eureka's load balancer (`lb://`).
*   **Why we did it:** Hardcoding IP addresses/ports in microservices is a anti-pattern. If we run multiple instances of a service, Eureka dynamically registers them, and the Gateway automatically routes incoming requests to healthy instances. We also routed the missing Aadhar, Company, and Payment Gateway services through the Gateway.
*   **Key File:** [gateway-service/src/main/resources/application.yml](./gateway-service/src/main/resources/application.yml)

### Step 7: Kubernetes Modernization (Level 9 - Bonus)
*   **What we did:** Translated our Docker Compose configuration into Kubernetes manifests.
    *   `gdb-namespace.yml` isolates the project.
    *   `gdb-config.yml` manages environment variables and base64-encoded Secrets.
    *   `gdb-db.yml` deploys PostgreSQL and mounts the database creation script via a ConfigMap volume.
    *   `gdb-services.yml` deploys the microservices.
    *   `gdb-frontend.yml` deploys the frontend and configures an **Ingress Router** (`gdb.local`) using Nginx to direct `/api/*` to the gateway and everything else to the frontend.
*   **Why we did it:** Kubernetes is the industry standard for container orchestration. It handles autoscaling, self-healing (restarting crashed containers), and zero-downtime rolling updates.
*   **Key Folder:** [k8s/](./k8s/)

### Step 8: Automated API Validation (Level 8)
*   **What we did:** Wrote a Python script `validate_api.py` that tests the end-to-end flow.
*   **Why we did it:** To verify the system works without manual testing. It tests:
    1.  Gateway Routing.
    2.  JWT Token Generation (Logging in as admin).
    3.  User Creation.
    4.  KYC Aadhar Verification.
    5.  Savings Account Creation.
    6.  Deposit Transactions (modifying the database).
*   **Key File:** [validate_api.py](./validate_api.py)

---

## 3. Expected Questions & Smart Answers

### Q1: Why did you use multi-stage Docker builds for the React frontend?
*   **Answer:** *"If we build a single-stage image, the final container would include Node.js, the package manager, source code, and node_modules, making the image size huge (over 1GB) and insecure. By using a multi-stage build, Stage 1 uses Node to compile the code into pure static HTML/JS/CSS assets. Stage 2 copies only those compiled files into a lightweight Nginx web server. This drops the final image size to under 30MB, speeds up deployments, and removes development-only security vulnerabilities from production."*

### Q2: How do your microservices communicate, and what is the role of Eureka?
*   **Answer:** *"The microservices register themselves dynamically with the Eureka Service Registry on startup. Instead of hardcoding URLs (like `http://localhost:8003`), services query Eureka to find where other services are running. The API Gateway also queries Eureka and uses Spring Cloud's load balancer (`lb://`) to route incoming requests. This makes the system resilient, scalable, and easy to maintain."*

### Q3: How did you initialize multiple databases in the PostgreSQL container?
*   **Answer:** *"By default, the official Postgres Docker image only creates a single database via `POSTGRES_DB`. To create the four databases needed for GDB (Auth, Users, Accounts, Transactions), we wrote a custom shell script `init-db.sh` and mounted it to the `/docker-entrypoint-initdb.d/` directory of the Postgres container. The container is designed to automatically run any `.sh` or `.sql` scripts placed in that directory during its first startup."*

### Q4: Why did you choose to use an Ingress Controller in Kubernetes instead of exposing all services with NodePorts or LoadBalancers?
*   **Answer:** *"Using LoadBalancers for every service is expensive (each LoadBalancer gets a public IP on AWS) and insecure. NodePorts expose high port numbers (30000-32767) directly on the nodes, which is a security risk. Instead, we used a single Ingress Controller which acts as a reverse proxy. It routes traffic based on URL paths (e.g., `/api/(.*)` goes to the Gateway Service, and everything else goes to the Frontend), using a single entrypoint under a clean domain (`gdb.local`)."*

---

## 4. Key Highlights to Emphasize for a Grade A+
1.  **Security**: Explain that database passwords and JWT Secret Keys are never hardcoded; they are managed using Kubernetes Secrets and environment variables.
2.  **Robust Health Checking**: Emphasize that in `docker-compose.yml`, we used database health checks (`pg_isready`) and Eureka health checks (`wget`) to configure startup sequences, preventing microservices from crashing due to databases not being fully initialized.
3.  **Dynamic Routing**: Emphasize that you corrected the API Gateway configuration to route dynamically via Eureka (`lb://`) instead of using static `localhost` paths, enabling real microservices load-balancing.
