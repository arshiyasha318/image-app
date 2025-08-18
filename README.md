#image-app
# Image Upload App on AWS using Terraform + EKS + GitHub Actions

This project provisions the full AWS infrastructure using **Terraform**, deploys an **image upload/display application** on **EKS**, and uses **GitHub Actions** for CI/CD.

---

## Architecture

**Provisioned Components via Terraform:**

- VPC with public/private subnets
- EKS cluster (with IRSA for S3 access)
- IAM roles/policies
- S3 bucket for storing images
- Application Load Balancer (ALB)
- ALB Ingress Controller
- ACM certificate (HTTPS)
- Route 53 record 
- GitHub Actions for infra + app deployment

## Features

- Upload image from frontend UI
- Backend stores image in **private S3 bucket**
- App fetches and displays images using `listObjects`
- IRSA used for secure pod-to-S3 access
- HTTPS support (via ACM)
- Full CI/CD via GitHub Actions 

## Terraform Directory Structure

infra/
├── main.tf
├── terraform.tfvars
├── variables.tf
├── outputs.tf
├── modules/
│   ├── vpc/
│   ├── eks/
│   ├── s3/
│   ├── iam/
│   ├── route53/
│   ├── alb_controller/
    ├── oidc/
│   ├── eks_node_group/

Setup Instructions

1️. Clone the Repo
git clone https://github.com/arshiyasha318/image-app.git
cd image-app-infra/Modules
2️. Configure Backend 
Using remote state (e.g., S3 backend), updated backend.tf.

3️. Created Terraform Variables
Updated terraform.tfvars:

vpc_cidr           = "10.10.0.0/16"
public_subnets     = ["10.10.1.0/24", "10.10.3.0/24"]
private_subnets    = ["10.10.2.0/24", "10.10.4.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
cluster_name       = "image-app"
region             = "us-east-1"
eks_version        = "1.32"
desired_size       = 1
max_size           = 1
min_size           = 1
node_group_name    = "image-node-group"
instance_types     = ["t3.medium"]
s3_bucket_name     = "image-upload-bucket-dev-20250719"

4️. Initialize and Apply Terraform
terraform init
terraform plan
terraform apply
This creates:

EKS cluster

IAM roles

S3 bucket

ALB + Ingress controller

5️. Connect kubectl to EKS
aws eks update-kubeconfig --region us-east-1 --name image-app
kubectl get nodes
6️. Deploy App (via GitHub Actions or manually)

Create and apply manifests in 
├── k8s/
│   ├── backend-configmap.yaml/
│   ├── backend-deployment.yaml/
│   ├── frontend-configmap.yaml/
│   ├── ingress.yaml/
│   ├── sa.yaml/
│   
alb-controller.sh :- Bash script for alb creation
 Triggered the GitHub Actions workflow.

GitHub Actions Setup
Secrets to add in GitHub → Settings → Secrets:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

AWS_REGION

ECR_REPO_URL

Workflows
Terraform-ci.yml — Deploy Terraform infra

docker-images.yml — Build Docker image → Push to ECR → Deploy to EKS

 Testing
Visit the frontend:https://gallery.arshiyaops.shop

Upload an image → It should appear on the home screen

Uploaded images are stored in S3 (private bucket)

App uses signed URLs or listObjects to retrieve images

Security Notes

S3 bucket is private (no public ACLs)

Access via IRSA-based IAM role

HTTPS via ACM/Route53 

GitHub Secrets
GitHub actions working and application working & Terraform
