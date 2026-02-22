#!/bin/bash
set -e
echo "🚀 Initializing Staff-Level Portfolio Environment..."

# Check if cluster exists
if kind get clusters | grep -q "portfolio-cluster"; then
    echo "✅ Cluster 'portfolio-cluster' already exists."
else
    echo "📦 Creating Kind Cluster..."
    kind create cluster --name portfolio-cluster --config infra/kind/kind-config.yaml
fi
# Install NGINX Ingress
echo "🌐 Installing NGINX Ingress Controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for Ingress
echo "⏳ Waiting for Ingress Controller..."
kubectl wait --namespace ingress-nginx   --for=condition=ready pod   --selector=app.kubernetes.io/component=controller   --timeout=90s
# Create Namespaces
echo "WM Creating Environment Namespaces..."
namespaces=("dev" "qa" "perf" "prod" "argocd" "monitoring")
for ns in "${namespaces[@]}"; do
    kubectl create ns $ns --dry-run=client -o yaml | kubectl apply -f -
done

echo "🎉 Cluster is Ready! Access it via localhost:80"
