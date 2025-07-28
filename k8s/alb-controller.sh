#!/bin/bash

set -e

CLUSTER_NAME="image-app"
AWS_REGION="us-east-1"
SERVICE_ACCOUNT_NAMESPACE="kube-system"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
ROLE_NAME="AmazonEKSLoadBalancerControllerRole"

echo "[*] Getting OIDC Provider for EKS Cluster..."
OIDC_PROVIDER=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

echo "[*] OIDC Provider: $OIDC_PROVIDER"
echo "[*] AWS Account ID: $ACCOUNT_ID"

# Step 1: Create IAM policy if not exists
echo "[*] Checking if IAM policy exists..."
if ! aws iam get-policy --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME >/dev/null 2>&1; then
  echo "[*] Policy not found. Creating custom policy..."
  curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
  aws iam create-policy \
    --policy-name $POLICY_NAME \
    --policy-document file://iam_policy.json
else
  echo "[*] IAM policy already exists."
fi

# Step 2: Create IAM role for ALB Controller
echo "[*] Creating IAM role and trust policy..."
TRUST_POLICY=$(cat <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/$OIDC_PROVIDER"
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

if ! aws iam get-role --role-name $ROLE_NAME >/dev/null 2>&1; then
  aws iam create-role \
    --role-name $ROLE_NAME \
    --assume-role-policy-document "$TRUST_POLICY"
else
  echo "[*] IAM Role $ROLE_NAME already exists. Skipping create."
fi

echo "[*] Attaching policy to IAM role..."
aws iam attach-role-policy \
  --role-name $ROLE_NAME \
  --policy-arn arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME

# Step 3: Create/patch service account with IRSA annotation
echo "[*] Creating or patching Kubernetes service account..."
kubectl create namespace $SERVICE_ACCOUNT_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

if kubectl get serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE >/dev/null 2>&1; then
  echo "[*] Service account exists. Patching annotation..."
  kubectl annotate serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE \
    eks.amazonaws.com/role-arn="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME" --overwrite
else
  echo "[*] Creating service account with IRSA annotation..."
  kubectl create serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE
  kubectl annotate serviceaccount $SERVICE_ACCOUNT_NAME -n $SERVICE_ACCOUNT_NAMESPACE \
    eks.amazonaws.com/role-arn="arn:aws:iam::$ACCOUNT_ID:role/$ROLE_NAME"
fi

# Step 4: Install ALB Controller via Helm
echo "[*] Adding Helm repo and installing ALB Controller..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n $SERVICE_ACCOUNT_NAMESPACE \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=$SERVICE_ACCOUNT_NAME \
  --set region=$AWS_REGION \
  --set vpcId=$(aws eks describe-cluster --name $CLUSTER_NAME --region $AWS_REGION --query "cluster.resourcesVpcConfig.vpcId" --output text) \
  --set image.repository=602401143452.dkr.ecr.$AWS_REGION.amazonaws.com/amazon/aws-load-balancer-controller

echo "[*] ALB Controller setup complete."
