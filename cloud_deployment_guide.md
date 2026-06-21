# Global Digital Bank (GDB) - Cloud Deployment & Hackathon Guide

This guide details how to deploy the **Global Digital Bank (GDB)** microservices application to a cloud provider and implements all 9 levels of the [Cloud and DevOps Hackathon PDF](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/Cloud%20and%20DevOps%20Hackathon.pdf).

---

## 1. System Architecture

The GDB application is built using a **Microservices Architecture** with Java Spring Boot, React, and PostgreSQL. 

```mermaid
graph TD
    Client[React Frontend (Port 3000/80)] --> |HTTP Requests| Gateway[API Gateway-service (Port 8000)]
    Gateway --> |Dynamic Routing| Eureka[Eureka Server (Port 8761)]
    
    subgraph VPC Public Subnet
        Client
        Gateway
    end

    subgraph VPC Private Subnet
        Eureka
        Auth[Auth-service (Port 8004)]
        Users[Users-service (Port 8003)]
        Accounts[Account-service (Port 8001)]
        Transactions[Transactions-service (Port 8002)]
        Aadhar[Aadhar-service (Port 8005)]
        Company[Company-service (Port 8006)]
        Payment[Payment-Gateway-service (Port 8008)]
        Postgres[(PostgreSQL DB (Port 5432))]
    end

    Auth --> Users
    Accounts --> Aadhar
    Accounts --> Company
    Transactions --> Accounts
    Transactions --> Payment
    
    Auth & Users & Accounts & Transactions --> |JDBC| Postgres
```

---

## 2. Hackathon Levels & Codebase Implementation

Here is a map of the 9 levels outlined in the hackathon challenge and how they are implemented:

| Level | Hackathon Challenge Goal | Codebase Implementation Files | Key Features Implemented |
|---|---|---|---|
| **Level 1** | **Git Foundation & Governance** | [BRANCHING_STRATEGY.md](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/BRANCHING_STRATEGY.md) | Standardized branching (`main`, `dev`, `feature/*`), protection rules, PR workflow guidelines. |
| **Level 2** | **Containerization** | Dockerfiles in each service directory (e.g. [auth-service/Dockerfile](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/auth-service/Dockerfile), [frontend/Dockerfile](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/frontend/Dockerfile)) | Multi-stage Nginx builds for frontend, standardized Eclipse Temurin 17 JRE Alpine containers for Java microservices. |
| **Level 3** | **Local Integrated Deployment** | [docker-compose.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/docker-compose.yml), [init-db.sh](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/init-db.sh) | Postgres multi-database initialization, docker networks, service depends_on healthchecks, static environment configuration. |
| **Level 4** | **Cloud Infrastructure Setup (IaC)** | [terraform/main.tf](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/terraform/main.tf), [terraform/variables.tf](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/terraform/variables.tf) | AWS VPC, Public/Private Subnets, Internet Gateways, Route Tables, Public/Private Security Groups, Web and App EC2 instances. |
| **Level 5** | **CI/CD Pipeline Engineering** | [.github/workflows/ci-cd.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/.github/workflows/ci-cd.yml) | GitHub Actions CI compiling Maven JARs, building Vite bundle, and publishing container images to GitHub Container Registry (GHCR). |
| **Level 6** | **Cloud Deployment & Service Startup** | [terraform/main.tf](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/terraform/main.tf) / [docker-compose.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/docker-compose.yml) | Deploying the databases, Eureka, gateway, microservices, and React frontend into the cloud VPC. |
| **Level 7** | **Configuration & Integration** | Service resource configuration (e.g. `application.yml` in each service), [docker-compose.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/docker-compose.yml) | Service Registry lookup, load-balanced Gateway route mappings, database connections dynamically injected via env variables. |
| **Level 8** | **Production Validation** | [validate_api.py](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/validate_api.py) | Python integration test script validating Eureka discovery, JWT Authentication, Customer creation, Aadhar verification, Account creation, and Transactions. |
| **Level 9** | **Kubernetes Modernization (Bonus)** | Configuration files in [k8s directory](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/k8s/) | K8s Isolated Namespace, ConfigMaps, Secrets, PostgreSQL state deployment, Service ClusterIP allocations, and Frontend ingress. |

---

## 3. Option A: Virtual Machine Deployment (AWS EC2 via Terraform)

This option deploys the application across two EC2 instances inside a custom VPC.

### Step 3.1: Initialize & Provision Infrastructure
Run Terraform commands on your local machine to set up the network and VMs:
```bash
cd "/Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud /terraform"
terraform init
terraform plan
terraform apply -auto-approve
```
*   This creates a VPC (`10.0.0.0/16`), a public subnet (`10.0.1.0/24`), and a private subnet (`10.0.2.0/24`).
*   It spins up `gdb-web-server` (t3.medium) in the public subnet and `gdb-app-server` (t3.large) in the private subnet.

### Step 3.2: Pull and Run Containers on EC2
Once the infrastructure is ready, SSH into the EC2 instances. 
Since the private VM (`gdb-app-server`) has only a private IP, you must jump through the public VM (`gdb-web-server` acting as a bastion host):

1.  **Configure SSH keys** on your local machine and connect to the public VM:
    ```bash
    ssh -i ~/.ssh/gdb-ssh-key.pem ubuntu@<WEB_SERVER_PUBLIC_IP>
    ```
2.  **Install Docker & Docker Compose** on both servers:
    ```bash
    sudo apt-get update && sudo apt-get install -y docker.io docker-compose
    sudo usermod -aG docker ubuntu
    ```
3.  **Run Microservices on `gdb-app-server`**:
    Deploy Postgres and all backend microservices here. Copy [docker-compose.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/docker-compose.yml) and [init-db.sh](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/init-db.sh) to the app server and start the services:
    ```bash
    docker-compose up -d postgres eureka-server auth-service users-service account-service transactions-service aadhar-service company-service payment-gateway-service
    ```
4.  **Run Frontend and Gateway on `gdb-web-server`**:
    Configure the Gateway to route traffic to the services hosted on the app server, and start them:
    ```bash
    docker-compose up -d gateway-service frontend
    ```

---

## 4. Option B: Kubernetes Container Orchestration (AWS EKS, GKE, or local K8s)

This option deploys the entire application in a modern Kubernetes cluster utilizing the configurations in the [k8s directory](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/k8s/).

### Step 4.1: Access Kubernetes Cluster
Verify connection to your cloud Kubernetes cluster (e.g. AWS EKS or GKE) or local cluster (Minikube):
```bash
kubectl cluster-info
```

### Step 4.2: Apply Kubernetes Configurations
Run these commands in order from the project root:

1.  **Create isolated namespace**:
    ```bash
    kubectl apply -f k8s/gdb-namespace.yml
    ```
2.  **Apply configurations & secrets**:
    ```bash
    kubectl apply -f k8s/gdb-config.yml
    ```
3.  **Deploy PostgreSQL instance & initialize schemas**:
    ```bash
    kubectl apply -f k8s/gdb-db.yml
    ```
    *Wait for the PostgreSQL pod to be fully ready before proceeding:*
    ```bash
    kubectl wait --namespace=gdb --for=condition=ready pod -l app=postgres --timeout=120s
    ```
4.  **Deploy Eureka, Gateway, and Microservices**:
    ```bash
    kubectl apply -f k8s/gdb-services.yml
    ```
5.  **Deploy React frontend & expose paths using ingress**:
    ```bash
    kubectl apply -f k8s/gdb-frontend.yml
    ```

### Step 4.3: Verify Pods and Services
Check the statuses of all resources under the `gdb` namespace:
```bash
kubectl get pods -n gdb
kubectl get svc -n gdb
kubectl get ingress -n gdb
```

---

## 5. Automated CI/CD Pipeline (GitHub Actions)

The CI/CD pipeline defined in [.github/workflows/ci-cd.yml](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/.github/workflows/ci-cd.yml) automates the release process when changes are made.

### Flow
1.  **Triggers**: On code push or pull requests to `main` or `dev` branches.
2.  **Build Phase**:
    *   `build-and-test-backend`: Sets up JDK 17, compiles all backend services with Maven, and uploads compiled `.jar` archives.
    *   `build-frontend`: Sets up Node.js 18, installs dependencies, compiles React static assets using Vite.
3.  **Publish Phase** (`build-and-push-docker-images`):
    *   Runs only on code merge (`push` event).
    *   Logs into **GitHub Container Registry (GHCR)**.
    *   Downloads maven jars and builds standard Docker images.
    *   Tags images with target git branches (`prod` for `main`, `dev` for `dev`) and the unique GitHub SHA, and pushes them.

---

## 6. End-to-End Production Validation

Once deployed to a cloud environment (IP address or Kubernetes domain), you can validate all business functionalities using [validate_api.py](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/validate_api.py).

### Running validation locally or from admin workstation:
1.  Open [validate_api.py](file:///Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud%20/validate_api.py) and update the `BASE_URL` on line 6 to point to your cloud gateway IP (e.g. `http://YOUR_AWS_LOAD_BALANCER_IP:8000`).
2.  Install dependencies:
    ```bash
    pip install requests
    ```
3.  Execute the test suite:
    ```bash
    python "/Users/sagarsewak/Documents/Personal/College/STEP/OFFLINE/Cloud /validate_api.py"
    ```

### Test Phases Executed:
*   **Phase 1**: Checks Gateway availability (Port 8000) and Eureka dashboard registry availability (Port 8761).
*   **Phase 2**: Queries JWT access credentials using Admin logs via Auth service.
*   **Phase 3**: Creates a new Customer account dynamically via Users service.
*   **Phase 4**: Queries valid Aadhar records dynamically from Aadhar service.
*   **Phase 5**: Opens a new savings account with a base deposit ($5000.00) via Account service.
*   **Phase 6**: Performs a deposit transaction ($2500.00), updates database records via Transactions service, and queries final account balance to verify accuracy.
