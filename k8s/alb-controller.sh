#!/bin/bash

set -euo pipefail

# ----- CONFIGURATION -----
CLUSTER_NAME="image-app"
AWS_REGION="us-east-1"
SERVICE_ACCOUNT_NAMESPACE="kube-system"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
POLICY_FILE_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
CHART_VERSION="1.7.1"  # Use latest compatible with your EKS version
HELM_REPO="https://aws.github.io/eks-charts"

# ----- STEP 1: Download IAM policy -----
echo "Downloading IAM policy..."
curl -o iam-policy.json ${POLICY_FILE_URL}

# ----- STEP 2: Create IAM policy -----
echo "Creating IAM policy..."
aws iam create-policy \
  --policy-name ${POLICY_NAME} \
  --policy-document file://iam-policy.json || echo "Policy may already exist"

# ----- STEP 3: Associate OIDC provider -----
echo "Associating OIDC provider..."
eksctl utils associate-iam-oidc-provider \
  --cluster ${CLUSTER_NAME} \
  --approve

# ----- STEP 4: Create IAM role for ServiceAccount -----
echo "Creating IAM role for ServiceAccount..."
eksctl create iamserviceaccount \
  --cluster ${CLUSTER_NAME} \
  --namespace ${SERVICE_ACCOUNT_NAMESPACE} \
  --name ${SERVICE_ACCOUNT_NAME} \
  --attach-policy-arn arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):policy/${POLICY_NAME} \
  --approve \
  --override-existing-serviceaccounts

# ----- STEP 5: Add Helm repo -----
echo "Adding Helm repo..."
helm repo add eks ${HELM_REPO}
helm repo update

# ----- STEP 6: Install ALB controller with Helm -----
echo "Installing AWS Load Balancer Controller via Helm..."
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace ${SERVICE_ACCOUNT_NAMESPACE} \
  --set clusterName=${CLUSTER_NAME} \
  --set serviceAccount.name=${SERVICE_ACCOUNT_NAME} \
  --set serviceAccount.create=false \
  --set region=${AWS_REGION} \
  --set vpcId=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.resourcesVpcConfig.vpcId" --output text) \
  --set ingressClass=alb \
  --version ${CHART_VERSION}

echo " AWS Load Balancer Controller installation complete."
