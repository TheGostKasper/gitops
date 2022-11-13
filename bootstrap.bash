# create local kind cluster
kind delete cluster --name my-cluster
kind create cluster --name my-cluster
kubectl create ns flux-system

# images
kind load docker-image ghcr.io/fluxcd/helm-controller:v0.25.0 --name my-cluster
kind load docker-image ghcr.io/fluxcd/kustomize-controller:v0.29.0 --name my-cluster
kind load docker-image ghcr.io/fluxcd/notification-controller:v0.27.0 --name my-cluster
kind load docker-image ghcr.io/fluxcd/source-controller:v0.30.0 --name my-cluster
kind load docker-image quay.io/jetstack/cert-manager-controller:v1.6.0 --name my-cluster
kind load docker-image ghcr.io/external-secrets/external-secrets:v0.3.9 --name my-cluster

# create secret for external-secrets operator for pulling from AWS secret manager and create ClusterResourceSet for deploying the secret to workload clusters

kubectl create secret generic awssm-secret --from-literal access-key=$AWS_ACCESS_KEY_ID --from-literal secret-access-key=$AWS_SECRET_ACCESS_KEY  -n flux-system --dry-run=client -o yaml > aws-sm-crs-data.yaml
kubectl apply -f aws-sm-crs-data.yaml
kubectl create secret generic aws-sm-crs-secret --from-file=aws-sm-crs-data.yaml --type=addons.cluster.x-k8s.io/resource-set
rm aws-sm-crs-data.yaml

# create secret for sshkey
kubectl create secret -n flux-system generic ssh-credentials --from-file=./identity --from-file=./identity.pub --from-file=./known_hosts

# Enable support for `ClusterResourceSet`s for automatically installing CNIs
export EXP_CLUSTER_RESOURCE_SET=true

flux bootstrap github --owner=waleedhammam --repository=gitops --branch="secrets" --path=clusters/my-cluster --personal
