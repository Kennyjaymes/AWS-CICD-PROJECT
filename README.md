# End-to-End AWS CI/CD Pipeline

This project contains a comprehensive, automated CI/CD pipeline and Infrastructure as Code (IaC) setup. It uses Jenkins to run a pipeline that provisions required AWS infrastructure (EKS, ECR, and networking), builds a Dockerized application, pushes it to the custom ECR repository, and finally deploys it onto the EKS cluster. During each step, notifications are sent to a designated Slack channel.

## Table of Contents
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Directory Structure](#directory-structure)
- [Pipeline Stages Explained](#pipeline-stages-explained)
- [Setup Instructions](#setup-instructions)

## Architecture

1. **My Infrastructure (Terraform)**
   - **VPC Module**: I've configured this to set up public, private, and **intra** subnets (specifically for the EKS control plane) across 3 Availability Zones in `eu-west-2`.
   - **EKS Module**: I use this to create a managed Kubernetes cluster (`v1.30`) with an auto-scaling node group of `t3.small` instances (optimized for my vCPU quotas).
   - **ECR**: I've set up a private registry with image scanning enabled to store my application's builds.
   - **Default Tags**: I ensure every resource I create is automatically tagged with `Project`, `Environment`, and `ManagedBy` for easy cost tracking.

2. **My Application (Node.js)**
   - I built a lightweight Express-like API that serves a JSON health response on port `3000`.
   - I optimized the `Dockerfile` using `node:20-alpine` to ensure my builds and pushes are fast.

3. **My CI/CD (Jenkins)**
   - I use Jenkins to orchestrate the full lifecycle: `Terraform Init -> Terraform Apply -> Docker Build -> ECR Push -> EKS Deployment`.
   - I designed this for execution on my Windows-based Jenkins build agent (using `bat` and `powershell`).
   - I've integrated real-time Slack notifications for every success or failure in my pipeline.

## Prerequisites

Before running my pipeline, ensure your Jenkins environment is ready:

1. **Jenkins Plugins**:
   - [Pipeline Plugin](https://plugins.jenkins.io/workflow-aggregator/)
   - [AWS Credentials Plugin](https://plugins.jenkins.io/aws-credentials/)
   - [Slack Notification Plugin](https://plugins.jenkins.io/slack/) (Optional if you use raw `curl` notifications as I've implemented).

2. **Jenkins Credentials**:
   - **ID: `aws-credentials`**: (Type: AWS Credentials) Add your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
   - **ID: `slack-webhook-url`**: (Type: Secret Text) Your Slack Incoming Webhook URL.

## Directory Structure

```text
├── terraform/          # My infrastructure definition
│   ├── provider.tf     # My AWS Config & S3 Backend
│   ├── variables.tf    # My Region (eu-west-2), CIDRs, and Cluster names
│   ├── vpc.tf          # My Multi-AZ networking (Public/Private/Intra)
│   ├── eks.tf          # My EKS Cluster & Managed Node Groups
│   ├── ecr.tf          # My Private Container Registry
│   └── outputs.tf      # Dynamic URL & ID outputs I use for Jenkins
├── app/                # My Node.js source code (server.js)
├── k8s/                # My Kubernetes Deployment & Service manifests
├── Dockerfile          # My container build specification (Node 20 Alpine)
├── Jenkinsfile         # My Pipeline Orchestrator (PowerShell/Bat)
└── AWSCLIV2.msi        # Standalone AWS CLI installer I use
```

## Pipeline Stages Explained

1. **Terraform Init**: I initialize my configuration and download the necessary providers.
2. **Terraform Apply**: I provision my AWS environment (VPC, EKS, ECR). I've currently **commented out** the S3 backend in `provider.tf` to allow for immediate testing with local state.
3. **Build Container Image**: I containerize my Node.js app using the dynamically retrieved ECR URL.
4. **Push to ECR**: I authenticate my Docker daemon to AWS and push the image tagged with the Jenkins `BUILD_ID`.
5. **Deploy to EKS**: 
    - I update my local `kubeconfig`.
    - I swap the image placeholder in `k8s/deployment.yaml`.
    - I apply my `kubectl` manifests to roll out the new version.

## Setup Instructions

Here is how you can set up and run my pipeline:

1. **Infrastructure Config**: 
   - Check `terraform/variables.tf` to ensure `aws_region` is set correctly (My default is `eu-west-2`).
   - If you want persistent state, uncomment and update the `backend "s3"` block in `terraform/provider.tf`.
2. **CI/CD Hookup**:
   - Push this code to your GitHub/GitLab repository.
   - Point a Jenkins Pipeline job at your repository's `Jenkinsfile`.
3. **Run**: Trigger the build and watch my Slack alerts pop up as the infrastructure and app go live!
