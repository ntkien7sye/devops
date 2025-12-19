#!/bin/bash
# Deploy script for Kubernetes

set -e

NAMESPACE="${NAMESPACE:-nestjs-backend}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
ECR_URL="${ECR_REPOSITORY_URL:-}"

echo "Deploying to namespace: $NAMESPACE"

kubectl apply -f kubernetes/namespace.yaml
kubectl apply -f kubernetes/configmap.yaml

if [ -n "$ECR_URL" ]; then
    cat kubernetes/deployment.yaml | \
        sed "s|\${ECR_REPOSITORY_URL}|$ECR_URL|g" | \
        sed "s|:latest|:$IMAGE_TAG|g" | \
        kubectl apply -f -
else
    kubectl apply -f kubernetes/deployment.yaml
fi

kubectl apply -f kubernetes/service.yaml
kubectl apply -f kubernetes/ingress.yaml
kubectl apply -f kubernetes/hpa.yaml
kubectl apply -f kubernetes/network-policy.yaml

echo "Waiting for rollout..."
kubectl rollout status deployment/nestjs-backend -n $NAMESPACE --timeout=300s

echo "Deploy complete!"
