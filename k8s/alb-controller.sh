#!/bin/bash

set -euo pipefail

# CONFIGURE THESE
CLUSTER_NAME="your-eks-cluster-name"
AWS_REGION="us-east-1"
SERVICE_ACCOUNT_NAMESPACE="kube-system"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"

# 1. Get OIDC provider
OIDC_PROVIDER=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query "cluster.identity.oidc.issuer" \
  --output text | sed -e "s/^https:\/\///")

echo "[*] OIDC Provider: $OIDC_PROVIDER"

# 2. Create IAM Role for ServiceAccount if not exists
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$(aws sts get-caller-identity --query Account --output text):oidc-provider/$OIDC_PROVIDER"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "$OIDC_PROVIDER:sub": "system:serviceaccount:$SERVICE_ACCOUNT_NAMESPACE:$SERVICE_ACCOUNT_NAME"
        }
      }
    }
  ]
}
EOF
)

ROLE_NAME="AmazonEKSLoadBalancerControllerRole"
aws iam create-role \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document "$TRUST_POLICY" \
  || echo "[*] Role $ROLE_NAME already exists"

aws iam attach-role-policy \
  --role-name "$ROLE_NAME" \
  --policy-arn "arn:aws:iam::aws:policy/$POLICY_NAME"

# 3. Create Kubernetes service account with IRSA annotation
kubectl create namespace $SERVICE_ACCOUNT_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

kubectl delete serviceaccount "$SERVICE_ACCOUNT_NAME" -n "$SERVICE_ACCOUNT_NAMESPACE" --ignore-not-found

kubectl create serviceaccount "$SERVICE_ACCOUNT_NAME" \
  -n "$SERVICE_ACCOUNT_NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

eksctl create iamserviceaccount \
  --cluster "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --namespace "$SERVICE_ACCOUNT_NAMESPACE" \
  --name "$SERVICE_ACCOUNT_NAME" \
  --attach-policy-arn "arn:aws:iam::aws:policy/$POLICY_NAME" \
  --override-existing-serviceaccounts \
  --approve

# 4. Install the AWS Load Balancer Controller via Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n "$SERVICE_ACCOUNT_NAMESPACE" \
  --set clusterName="$CLUSTER_NAME" \
  --set region="$AWS_REGION" \
  --set serviceAccount.create=false \
  --set serviceAccount.name="$SERVICE_ACCOUNT_NAME" \
  --set vpcId=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.resourcesVpcConfig.vpcId" --output text) \
  --set image.repository=602401143452.dkr.ecr."$AWS_REGION".amazonaws.com/amazon/aws-load-balancer-controller

echo "[✔] AWS Load Balancer Controller installation complete."
