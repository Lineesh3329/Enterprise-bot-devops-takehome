# Enterprise Bot DevOps Take-Home

## Overview

This repository contains my implementation of the Enterprise Bot DevOps take-home assignment. It covers a containerized HTTP service, Kubernetes deployment with Helm, local cluster setup, and troubleshooting a broken Helm chart.

## Prerequisites

- Docker
- kubectl
- Helm
- kind
- curl
- Linux environment or WSL Ubuntu

## Project Structure

```text
.
├── service/              # HTTP application and Dockerfile
├── chart/                # Helm chart for the application
├── setup.sh              # Local Kubernetes environment setup
├── lab/
│   ├── broken-chart/      # Helm chart debugging exercise
│   └── FINDINGS.md        # Debugging findings and fixes
├── ANSWERS.md             # Written assignment responses
└── README.md              # Project documentation
```

## Run the Application

From the repository root, build the container image:

```bash
docker build -t enterprise-bot-service:local ./service
```

Run the local environment setup script:

```bash
chmod +x setup.sh
./setup.sh
```

Follow the output and instructions provided by the setup script.

## Verification

Check the Kubernetes workloads and services:

```bash
kubectl get pods
kubectl get services
helm list
```

Test the application endpoints using the URL configured by the setup script:

```bash
curl http://localhost/
curl http://localhost/healthz
```

## **Development Process — From Start to Finish**

### **1. Repository Setup**

- Created the project repository on GitHub.
- Set up the project structure for the application, Helm chart, and debugging lab.
- Used WSL Ubuntu as the local development environment.

### **2. Part 1 — Containerized HTTP Service**

- Developed the HTTP service using Python.
- Implemented the application endpoints, including `/` and `/healthz`.
- Created a Dockerfile using a multi-stage build.
- Built and tested the Docker image locally.

### **3. Part 2 — Kubernetes Deployment with Helm**

- Created a Helm chart to deploy the application to Kubernetes.
- Configured two application replicas.
- Added Kubernetes Services, health probes, and resource requests and limits.
- Used ConfigMaps for application configuration.
- Tested configuration updates and verified the application behavior.

### **4. Part 3 — Kubernetes Environment Setup**

- Created a `setup.sh` script to automate local Kubernetes environment setup.
- Used `kind` to create a local Kubernetes cluster.
- Configured the required ingress components.
- Loaded the application image into the cluster.
- Deployed the application using Helm and tested its HTTP endpoints.
- Checked that the setup script could be run repeatedly.

### **5. Part 4 — Debugging the Broken Helm Chart**

- Inspected the broken Helm chart and investigated the deployment failures.
- Used Helm linting, Kubernetes resource status, pod logs, and connectivity checks to identify problems.
- Investigated Job configuration, security contexts, RBAC permissions, resource settings, ports, and writable storage.
- Updated the relevant chart templates and values.
- Ran the provided scenario script to deploy and verify the lab.
- Recorded the findings in `lab/FINDINGS.md` and captured terminal evidence.

**Current status:** The latest verification reported 7 checks passing and 4 failing. Reporter readiness and application connectivity checks remain unresolved. Part 4 is not yet fully passing.

### **6. Part 5 — Gateway API Migration Plan**

- Prepared a migration plan explaining how to move from Kubernetes Ingress to Gateway API.
- Covered Gateway API CRDs, controller setup, `GatewayClass`, `Gateway`, and `HTTPRoute`.
- Included testing, gradual traffic migration, monitoring, and rollback considerations.

**Note:** This is a proposed migration plan; Gateway API migration was not implemented in this project.

### **7. Part 6 — Documentation**

- Prepared the README to explain the project structure, prerequisites, setup, and verification.
- Documented resource configuration, known limitations, and possible production improvements.
- Included an AI assistance disclosure.

### **8. Final Review**

- Reviewed the project files and Helm chart configuration.
- Used verification commands to check the Kubernetes workloads and application endpoints.
- Documented the outstanding failures instead of claiming that all checks passed.
- Prepared the repository documentation for submission.

## **Tools and Technologies Used**

- **Version Control:** Git, GitHub
- **Containerization:** Docker
- **Orchestration:** Kubernetes, kind
- **Package Management:** Helm
- **Networking:** Kubernetes Services, Ingress
- **Application:** Python HTTP service
- **Environment:** WSL Ubuntu
- **Validation and Troubleshooting:** Helm lint, kubectl, pod logs, curl, and the provided scenario script


## Resource Configuration

The Helm deployment uses two application replicas to improve availability. CPU and memory requests help Kubernetes schedule workloads, while limits constrain resource consumption.

Readiness and liveness probes help Kubernetes monitor application health. Application configuration is managed through Kubernetes configuration resources, allowing supported configuration changes without rebuilding the container image.

## Debugging Exercise

The debugging exercise covers Kubernetes Job configuration, security contexts, service-account permissions, resource settings, port configuration, and writable storage.

Detailed findings are documented in `lab/FINDINGS.md`.

**Current status:** The debugging exercise is not fully passing. The latest verification reported 7 checks passing and 4 failing. Reporter readiness and application connectivity checks remain unresolved. These results are documented honestly rather than reported as successful.

## Limitations and Future Improvements

- Resolve the remaining Part 4 verification failures.
- Add automated build, lint, and deployment checks through CI.
- Add integration tests for application endpoints.
- Introduce production-grade secret management and container image scanning.
- Configure monitoring, centralized logging, and alerting.
- Test deployment rollback and recovery procedures.

## AI Assistance

AI assistance was used to help understand this task and files inside it. Troubleshooting output wherever I stucked somewhile.## **Development Process — From Start to Finish**

