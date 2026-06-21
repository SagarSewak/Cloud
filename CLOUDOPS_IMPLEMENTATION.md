# GDB CloudOps Challenge - Completion Report

This document details the complete end-to-end implementation of the Cloud and DevOps Hackathon requirements for the **Global Digital Bank (GDB)** platform.

---

## 1. Executive Summary

We have successfully migrated the Global Digital Bank platform from a local-only developer environment into a robust, cloud-native, and fully containerized microservices ecosystem. All 9 levels of the challenge have been completed:

*   **Version Control & Governance (Level 1)**: Established Git workflow, branching policies, and pull request rules.
*   **Docker Containerization (Level 2)**: Standardized JRE-based Docker images for all 9 backend services and a multi-stage Nginx container for the React frontend.
*   **Integrated Local Deployment (Level 3)**: Designed a PostgreSQL multi-database container stack and a complete `docker-compose.yml` manifest mapping the entire system.
*   **Infrastructure as Code (Level 4)**: Created AWS VPC, Subnet, VM instances, and security groups using Terraform.
*   **Continuous Integration/Delivery (Level 5)**: Created a GitHub Actions CI/CD pipeline targeting GitHub Container Registry (GHCR).
*   **Cloud & Dynamic Integration (Levels 6 & 7)**: Configured the Spring Cloud API Gateway using Eureka service discovery, routing client traffic seamlessly.
*   **Production Validation (Level 8)**: Developed a Python endpoint validation script to execute automated sanity test scenarios.
*   **Kubernetes Modernization (Level 9)**: Created a full Kubernetes manifest suite (Namespace, ConfigMaps, Secrets, Deployments, Services, and Ingress routing).

---

## 2. Directory Structure of Implemented Files

The following configuration and deployment files were created in the root directory:

```text
Cloud/
├── .github/
│   └── workflows/
│       └── ci-cd.yml             # CI/CD GitHub Actions Pipeline
├── k8s/                          # Kubernetes Manifest Directory
│   ├── gdb-namespace.yml         # Isolated Namespace config
│   ├── gdb-config.yml            # ConfigMaps and Base64 Secret templates
│   ├── gdb-db.yml                # PostgreSQL Deployment, Service & Schema init
│   ├── gdb-services.yml          # Deployments & Services for all 9 microservices
│   └── gdb-frontend.yml          # React deployment, Service, and Ingress Routing
├── terraform/                    # Infrastructure as Code
│   ├── main.tf                   # AWS VPC, Subnets, SG & EC2 definitions
│   └── variables.tf              # Configurable variables (region, keys, AMI)
├── Dockerfiles (in each folder)  # Eureka, Gateway, and 7 business services
├── docker-compose.yml            # Local orchestration stack
├── init-db.sh                    # Multi-database PostgreSQL initializer
├── BRANCHING_STRATEGY.md         # Git branch rules & Pull Request governance
├── validate_api.py               # Production validation testing script
└── CLOUDOPS_IMPLEMENTATION.md    # [This File] Complete walkthrough
```

---

## 3. Detailed Walkthrough of Completed Steps

### Level 1: Version Control Governance
*   **Git Repository Initialized**: Set up local git registry, checked out `main` and `dev` branches.
*   **Workflow Simulated**: Implemented a mock features/merge pull request lifecycle (`feature/GDB-100-documentation` -> merged to `dev`).
*   **Governance Documentation**: Authored `BRANCHING_STRATEGY.md` mapping rules:
    *   Direct commits to `main` and `dev` are strictly blocked.
    *   PRs require code approval and CI builds to merge.
    *   Commits must follow standardized prefixes (e.g., `feat:`, `fix:`, `docs:`).

### Level 2: Docker Containerization
Dockerfiles were created for each of the microservices:
*   **Backend Services** (`eclipse-temurin:17-jre-alpine`): Built runtime containers executing the package JAR files:
    ```dockerfile
    FROM eclipse-temurin:17-jre-alpine
    WORKDIR /app
    COPY target/*.jar app.jar
    EXPOSE <PORT>
    ENTRYPOINT ["java", "-jar", "app.jar"]
    ```
*   **React Frontend** (`node:18-alpine` + `nginx:stable-alpine`): Built a multi-stage production container compiling React code using Vite and serving the static assets over Nginx port 80.
*   **Compile Success**: Executed clean compiles on all 9 services, producing production-ready JAR archives.

### Level 3: Integrated Local Deployment
*   **Postgres Initializer**: Wrote `init-db.sh` to initialize the isolated databases required by the backend services: `auth_db`, `users_db`, `accounts_db`, and `trasaction_db`.
*   **Docker Compose**: Configured `docker-compose.yml` to spin up the container database, map storage, setup network boundaries (`gdb-network`), configure healthchecks, and start backend services after dependencies are ready.

### Level 4: Cloud Infrastructure (Terraform)
Created `terraform/main.tf` mapping out:
1.  **VPC & Subnets**: Set up VPC `10.0.0.0/16` with a public subnet (`10.0.1.0/24`) and a private subnet (`10.0.2.0/24`).
2.  **Firewalls & Security Groups**:
    *   `public_sg`: Exposes ports `80` (Frontend), `3000` (Dev client), `8000` (Gateway), and `22` (SSH) for public admin access.
    *   `private_sg`: Limits access to microservice ports (`8001`-`8008`, `8761`) and DB port (`5432`) to within the VPC.
3.  **VM Instances**: Provisions `web_server` in the public subnet and `app_server` in the private subnet.

### Level 5: CI/CD Pipeline Engineering
Wrote GitHub Actions workflow `.github/workflows/ci-cd.yml` defining:
*   **Maven Build Job**: Sets up JDK 17, compiles Java code, packages target JAR archives, and uploads them.
*   **Node.js Build Job**: Installs dependencies and runs Vite compilation for React static pages.
*   **Docker Publish Job**: Pulls compiled targets, runs Docker Buildx, logs in to GitHub Container Registry (GHCR), tags images matching git refs, and pushes them.

### Levels 6 & 7: Cloud Deployment, Gateway Routing & Integration
*   **Eureka Discovery Clients**: Configured microservices to register dynamically with the service registry.
*   **Gateway Routing Rules**: Updated `gateway-service` configuration to load-balance traffic dynamically using the service registry:
    ```yaml
    spring:
      cloud:
        gateway:
          routes:
            - id: auth-service
              uri: lb://auth-service
              predicates:
                - Path=/api/v1/auth/**
    ```
    Added missing routes for `aadhar-service`, `company-service`, and `payment-gateway-service`.

### Level 8: Production Validation
Created `validate_api.py` to automate end-to-end validations:
1.  Verify Eureka Server dashboard and Gateway routing availability.
2.  Log in as `admin` to generate JWT credentials.
3.  Create a test User profile dynamically.
4.  Interact with Aadhar service to query valid KYC numbers.
5.  Call Account Service to open a Savings account with initial deposits.
6.  Execute transaction deposits and verify database updates.

### Level 9: Kubernetes Modernization (Bonus)
Created YAML manifest files inside `k8s/` implementing:
*   `gdb-namespace.yml`: Isolate GDB services into a dedicated namespace (`gdb`).
*   `gdb-config.yml`: Define shared ConfigMap parameters and secret values.
*   `gdb-db.yml`: Mount PostgreSQL container mapping the database creation scripts via a ConfigMap volume.
*   `gdb-services.yml`: Provision deployments and ClusterIP services for all 9 backends.
*   `gdb-frontend.yml`: Deploy the React app and hook up a path-based Ingress Controller.

---

## 4. Run & Deployment Commands

### 4.1 Run Backend Locally
If running directly on host system:
```bash
# Build all Maven JARs
for dir in aadhar-service account-service auth-service company-service eureka-server gateway-service payment-gateway-service transactions-service users-service; do (cd "$dir" && mvn clean package -Dmaven.test.skip=true); done

# Start Eureka (Terminal 1)
java -jar eureka-server/target/*.jar

# Start other microservices (Terminal 2-9)
java -jar auth-service/target/*.jar --DATABASE_PASSWORD=postgres
java -jar users-service/target/*.jar --DATABASE_PASSWORD=postgres
# Repeat for account, transactions, gateway, etc.
```

### 4.2 Local Docker Compose Stack
Ensure Docker is running and execute:
```bash
docker-compose up --build -d
```

### 4.3 Deploy to Kubernetes Cluster
```bash
kubectl apply -f k8s/gdb-namespace.yml
kubectl apply -f k8s/gdb-config.yml
kubectl apply -f k8s/gdb-db.yml
# Wait for DB pod to be ready
kubectl apply -f k8s/gdb-services.yml
kubectl apply -f k8s/gdb-frontend.yml
```

### 4.4 Provision AWS Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 4.5 Execute End-to-End Validation
Ensure backend services are running on port 8000/8761 and execute:
```bash
python validate_api.py
```
