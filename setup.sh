#!/usr/bin/env bash
set -Eeuo pipefail

CLUSTER_NAME="demo"
NAMESPACE="demo"
RELEASE_NAME="demo"
IMAGE_NAME="demo-app:1.0.0"
CHART_DIR="./chart"
INGRESS_MANIFEST="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

for cmd in docker kind kubectl helm; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Required command not found: $cmd" >&2
    exit 1
  fi
done

if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
  echo "Building $IMAGE_NAME..."
  docker build -t "$IMAGE_NAME" -f service/Dockerfile service
fi

if ! kind get clusters | grep -Fxq "$CLUSTER_NAME"; then
  echo "Creating kind cluster: $CLUSTER_NAME"

  cat > /tmp/demo-kind-config.yaml <<'KINDCFG'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
KINDCFG

  kind create cluster \
    --name "$CLUSTER_NAME" \
    --config /tmp/demo-kind-config.yaml \
    --wait 120s
else
  echo "Reusing existing kind cluster: $CLUSTER_NAME"
fi

kubectl config use-context "kind-${CLUSTER_NAME}"
kubectl wait --for=condition=Ready nodes --all --timeout=120s

echo "Installing ingress-nginx if needed..."
kubectl apply -f "$INGRESS_MANIFEST"

kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller \
  --timeout=180s

echo "Loading application image into kind..."
kind load docker-image "$IMAGE_NAME" --name "$CLUSTER_NAME"

kubectl create namespace "$NAMESPACE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Deploying Helm release..."
helm upgrade --install "$RELEASE_NAME" "$CHART_DIR" \
  --namespace "$NAMESPACE" \
  --set image.repository=demo-app \
  --set image.tag=1.0.0 \
  --wait \
  --timeout 180s

echo "Setup completed successfully."
