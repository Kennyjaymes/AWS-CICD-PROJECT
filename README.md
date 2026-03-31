# End-to-End AWS CI/CD Pipeline

This project contains a comprehensive, automated CI/CD pipeline and Infrastructure as Code (IaC) setup. It uses Jenkins to run a pipeline that provisions required AWS infrastructure (EKS, ECR, EC2, and networking), builds a Dockerized application, pushes it to the custom ECR repository, and finally deploys it onto the EKS cluster. During each step, notifications are sent to a designated Slack channel.

## Table of Contents
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Pipeline Stages Explained](#pipeline-stages-explained)
- [Setup Instructions](#setup-instructions)

## Architecture

1. **Infrastructure (Terraform)**
   - **VPC Module**: Sets up public, private, and **intra** subnets (specifically for the EKS control plane) across 3 Availability Zones.
   - **EKS Module**: Creates a managed Kubernetes cluster (`v1.28`) with an auto-scaling node group of `t3.medium` instances.
   - **ECR**: A private registry with image scanning enabled to store your application's builds.
   - **EC2**: A standalone Jenkins Agent server, pre-configured via `user_data` with all required tools (Docker, Terraform, AWS CLI v2, kubectl, and Java 11).
   - **Default Tags**: Every resource created is automatically tagged with `Project`, `Environment`, and `ManagedBy` for easy cost tracking.

2. **Application (Node.js)**
   - A lightweight Express-like API serving a JSON health response on port `3000`.
   - Optimized `Dockerfile` using `node:20-alpine` to ensure fast builds and pushes.

3. **Continuous Integration/Continuous Deployment (Jenkins)**
   - Orchestrates the full lifecycle: `Terraform Provisioning -> Docker Build -> ECR Push -> EKS Deployment`.
   - Real-time Slack notifications for every success or failure in the pipeline.

## Prerequisites

Before running this pipeline, ensure your Jenkins environment is ready:

1. **Jenkins Plugins**:
   - [Pipeline Plugin](https://plugins.jenkins.io/workflow-aggregator/)
   - [AWS Credentials Plugin](https://plugins.jenkins.io/aws-credentials/)
   - [Slack Notification Plugin](https://plugins.jenkins.io/slack/) (Optional if using raw `curl` notifications as implemented).

2. **Jenkins Credentials**:
   - **ID: `aws-credentials`**: (Type: AWS Credentials) Add your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
   - **ID: `slack-webhook-url`**: (Type: Secret Text) Your Slack Incoming Webhook URL.

## Directory Structure

```text
├── terraform/          # Infrastructure definition
│   ├── provider.tf     # AWS Config & S3 Backend (Local by default)
│   ├── variables.tf    # Region, CIDRs, and Cluster names
│   ├── vpc.tf          # Multi-AZ networking (Public/Private/Intra)
│   ├── eks.tf          # EKS Cluster & Managed Node Groups
│   ├── ecr.tf          # Private Container Registry
│   ├── ec2.tf          # Jenkins Agent Node with bootstrap script
│   └── outputs.tf      # Dynamic URL & ID outputs for Jenkins
├── app/                # Node.js source code
├── k8s/                # Kubernetes Deployment & Service manifests
├── Dockerfile          # Container build specification
└── Jenkinsfile         # The Pipeline Orchestrator
```

## Pipeline Stages Explained

1. **Terraform Init & Apply**: Provisions the AWS environment. The S3 backend is currently **commented out** in `provider.tf` to allow for immediate testing with local state.
2. **Build Container Image**: Containerizes the Node.js app using the dynamically retrieved ECR URL.
3. **Push to ECR**: Authenticates the Docker daemon to AWS and pushes the image tagged with the Jenkins `BUILD_ID`.
4. **Deploy to EKS**: 
    - Updates local `kubeconfig`.
    - Swaps the image placeholder in `k8s/deployment.yaml`.
    - Applies `kubectl` manifests to roll out the new version.

## Setup Instructions

1. **Infrastructure Config**: 
   - Check `terraform/variables.tf` to ensure `aws_region` is set correctly (Default: `us-east-1`).
   - If you want persistent state, uncomment and update the `backend "s3"` block in `terraform/provider.tf`.
2. **Key Pair**: If you need SSH access to the Jenkins Agent, add your existing AWS Key Pair name to `ec2_key_name` in `variables.tf`.
3. **CI/CD Hookup**:
   - Push this code to your GitHub/GitLab repository.
   - Point a Jenkins Pipeline job at your repository's `Jenkinsfile`.
4. **Run**: Trigger the build and watch the Slack alerts pop up as your infrastructure and app go live!
