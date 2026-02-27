#!/bin/bash
set -e

SOURCE_ENV=$1
TARGET_ENV=$2

if [ -z "$SOURCE_ENV" ] || [ -z "$TARGET_ENV" ]; then
  echo "Usage: ./promote.sh <source_env> <target_env>"
  echo "Example: ./promote.sh dev qa"
  exit 1
fi

echo "🚀 Promoting from $SOURCE_ENV to $TARGET_ENV..."

# 1. Extract the LAST (most recent) deployed image tag from the Source Environment
IMAGE_TAG=$(grep 'newTag:' apps/boutique/overlays/$SOURCE_ENV/kustomization.yaml | tail -1 | awk '{print $2}')

if [ -z "$IMAGE_TAG" ]; then
  echo "❌ Could not find a custom image tag in $SOURCE_ENV. Aborting."
  exit 1
fi

echo "✅ Found verified image tag in $SOURCE_ENV: $IMAGE_TAG"

# 2. Update the Target Environment with Kustomize
cd apps/boutique/overlays/$TARGET_ENV
kustomize edit set image gcr.io/google-samples/microservices-demo/frontend=ghcr.io/AmarGmail/boutique-frontend:$IMAGE_TAG
cd - > /dev/null

# 3. Commit and Push the Promotion (GitOps)
git add apps/boutique/overlays/$TARGET_ENV/kustomization.yaml
git commit -m "chore: promote frontend to $IMAGE_TAG in $TARGET_ENV"
git push origin main

echo "🎉 Promotion successful! ArgoCD will now deploy $IMAGE_TAG to $TARGET_ENV."
