# Cloud-Native Automated DevOps Pipeline

An end-to-end DevOps production-ready pipeline that automates the deployment of a containerized FastAPI application into AWS. This project leverages Infrastructure as Code (IaC) to provision cloud resources and implements a GitOps methodology using CI/CD automation.

## 🚀 Architecture & Tech Stack

The infrastructure and application flow follow industry-standard practices for isolation, automation, and minimal footprint:

* **Backend API:** Python 3.11 + FastAPI structured with automated health-check endpoints.
* **Containerization:** Docker & Docker Compose utilizing optimized multi-stage builds to minimize image sizes.
* **Infrastructure as Code (IaC):** Terraform for predictable provisioning of cloud infrastructure.
* **CI/CD Pipeline:** GitHub Actions triggering automated remote SSH deployments upon code changes.
* **Cloud Provider:** Amazon Web Services (AWS) utilizing Free-Tier eligible instances wrapped in strict Security Groups.

---

## 📐 System Architecture Flow

1. **Code & Push:** Developers push infrastructure or application updates to the `main` branch.
2. **Infrastructure Lifecycle:** Terraform manages, provisions, and maps the virtual firewall (Security Groups) and the virtual machine (EC2).
3. **Automation Pipeline:** GitHub Actions securely captures repository secrets (`SSH_PRIVATE_KEY` and `SERVER_IP`) and initializes a remote runner.
4. **Remote Orchestration:** The runner establishes a secure SSH connection to AWS, pulls the latest repository state, stops the stale workload, and triggers an isolated compilation via Docker Compose.

---

## 🛠️ Infrastructure Management (Terraform)

The cloud architecture is completely defined as code inside the `terraform/` directory.

### Prerequisites

* AWS CLI configured with programmatic access keys.
* Terraform CLI installed locally.

### Provisioning the Infrastructure

```bash
cd terraform/

# Initialize the AWS provider and download required plugins
terraform init

# Preview changes before applying them to your live cloud environment
terraform plan

# Deploy the security groups and EC2 instance to AWS
terraform apply
```

### De-provisioning (Teardown)

To clean up resources and guarantee zero residual AWS charges:

```bash
terraform destroy
```

---

## 📦 Containerization & Local Development

The application is fully containerized, ensuring identical runtime environments between your local machine and the live AWS production instance.

To spin up the ecosystem locally for testing:

```bash
# Build images and start the application layer in the background
docker-compose up -d --build

# Inspect running container states
docker ps

# Stream application logs in real-time
docker-compose logs -f app
```

Once active, the interactive API documentation layer is accessible at `http://localhost:8000/docs`.

---

## 🔄 CI/CD GitOps Pipeline

The deployment sequence is fully automated via GitHub Actions (`.github/workflows/deploy.yml`).


### Workflow Pipeline Steps

1. **Environment Setup:** Spins up a secure `ubuntu-latest` runner and checks out the source code.
2. **SSH Handshake:** Establishes an encrypted session with the AWS node.
3. **Git Ingestion:** Clones the codebase on initial birth or pulls the incremental delta if the repository already exists on the host.
4. **Live Hot-Swap:** Orchestrates `docker-compose down` followed by `docker-compose up -d --build` to safely transition running processes with near-zero deployment downtime.

---

## 🚀 Getting Started

```bash
# Clone this repository
git clone <repository-url>
cd <project-directory>

# Provision infrastructure
cd terraform && terraform init && terraform apply

# Deploy locally for development
docker-compose up -d --build
```

---

## 📄 License

This project is provided as-is for educational and portfolio demonstration purposes.
