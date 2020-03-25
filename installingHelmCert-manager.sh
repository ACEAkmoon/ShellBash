#!/bin/bash
echo "====== Installing with Helm cert-manager / Documentation v0.13 ======"
echo ''
echo "================ STEP:Install the Helm chart ========================"
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.13/deploy/manifests/00-crds.yaml
echo ''
echo "================ STEP:Create the namespace for cert-manager ========="
kubectl create namespace cert-manager
echo ''
echo "================ STEP:Add the Jetstack Helm repository =============="
helm repo add jetstack https://charts.jetstack.io
helm repo update
echo ''
echo "================ STEP:Install the cert-manager Helm chart ==========="
helm install \
	cert-manager jetstack/cert-manager \
    --namespace cert-manager \
    --set ingressShim.defaultIssuerName=letsencrypt-prod \
    --set ingressShim.defaultIssuerKind=ClusterIssuer \
    --version v0.13.1
echo ''
echo "================ STEP:Certificate create timer ======================"
TIME=180
while [ $TIME -gt 0 ]
        do
                echo "Time: $TIME"
                TIME=$(( --TIME ))
                sleep 1
        done
echo ''
echo "================ STEP:Verifying the installation ===================="
kubectl get pods --namespace cert-manager
echo ''
echo "================ STEP:kubectl apply ================================="
kubectl apply -f clusterissuer.yaml
echo ''
echo Well Done!
exit 0
