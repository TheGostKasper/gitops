# create local kind cluster
kind create cluster --name my-cluster
kubectl create ns flux-system
# create aws secret key for external secrets operator
kubectl create secret generic awssm-secret --from-literal access-key=$AWS_ACCESS_KEY_ID --from-literal secret-access-key=$AWS_SECRET_ACCESS_KEY  -n flux-system --dry-run=client -o yaml > aws-sm-crs-data.yaml
kubectl apply -f aws-sm-crs-data.yaml
kubectl create secret generic aws-sm-crs-secret --from-file=aws-sm-crs-data.yaml --type=addons.cluster.x-k8s.io/resource-set
rm aws-sm-crs-data.yaml

# create secret for sshkey
kubectl create secret -n flux-system generic ssh-credentials --from-file=./identity --from-file=./identity.pub --from-file=./known_hosts

flux bootstrap github --owner=waleedhammam --repository=gitops --branch="secrets" --path=clusters/my-cluster --personal
