#!/bin/bash

set -euo pipefail

# ----- CONFIGURATION -----
CLUSTER_NAME="image-app"
AWS_REGION="us-east-1"
SERVICE_ACCOUNT_NAMESPACE="kube-system"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
POLICY_FILE_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json"
CHART_VERSION="1.7.1"
HELM_REPO="https://aws.github.io/eks-charts"

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
POLICY_ARN="arn:aws:iam::${ACCOUNT_ID}:policy/${POLICY_NAME}"

echo "=== STEP 1: Download IAM policy ==="
curl -s -o iam-policy.json "${POLICY_FILE_URL}" || {
  echo "❌ Failed to download IAM policy JSON"
  exit 1
}

echo "=== STEP 2: Create IAM policy (if not exists) ==="
if ! aws iam get-policy --policy-arn "${POLICY_ARN}" >/dev/null 2>&1; then
  aws iam create-policy \
    --policy-name "${POLICY_NAME}" \
    --policy-document file://iam-policy.json
  echo "✅ IAM Policy created: ${POLICY_ARN}"
else
  echo "ℹ️  IAM Policy already exists: ${POLICY_ARN}"
fi

echo "=== STEP 3: Associate OIDC provider with EKS ==="
eksctl utils associate-iam-oidc-provider \
  --cluster "${CLUSTER_NAME}" \
  --approve \
  --region "${AWS_REGION}" || {
    echo "❌ Failed to associate OIDC provider"
    exit 1
}

echo "=== STEP 4: Create IAM Role and ServiceAccount ==="
if ! kubectl get serviceaccount "${SERVICE_ACCOUNT_NAME}" -n "${SERVICE_ACCOUNT_NAMESPACE}" >/dev/null 2>&1; then
  eksctl create iamserviceaccount \
    --cluster "${CLUSTER_NAME}" \
    --namespace "${SERVICE_ACCOUNT_NAMESPACE}" \
    --name "${SERVICE_ACCOUNT_NAME}" \
    --attach-policy-arn "${POLICY_ARN}" \
    --approve \
    --override-existing-serviceaccounts \
    --region "${AWS_REGION}" || {
      echo "❌ Failed to create ServiceAccount and IAM Role"
      exit 1
  }
  echo "✅ ServiceAccount ${SERVICE_ACCOUNT_NAME} created in namespace ${SERVICE_ACCOUNT_NAMESPACE}"
else
  echo "ℹ️  ServiceAccount ${SERVICE_ACCOUNT_NAME} already exists"
fi

echo "=== STEP 5: Add Helm repo ==="
helm repo add eks "${HELM_REPO}" || true
helm repo update

echo "=== STEP 6: Install AWS Load Balancer Controller ==="
VPC_ID=$(aws eks describe-cluster \
  --name "${CLUSTER_NAME}" \
  --region "${AWS_REGION}" \
  --query "cluster.resourcesVpcConfig.vpcId" \
  --output text)

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  --namespace "${SERVICE_ACCOUNT_NAMESPACE}" \
  --set clusterName="${CLUSTER_NAME}" \
  --set serviceAccount.name="${SERVICE_ACCOUNT_NAME}" \
  --set serviceAccount.create=false \
  --set region="${AWS_REGION}" \
  --set vpcId="${VPC_ID}" \
  --set ingressClass=alb \
  --version "${CHART_VERSION}" || {
    echo "❌ Helm install failed"
    exit 1
}

echo "✅ AWS Load Balancer Controller installation complete"
