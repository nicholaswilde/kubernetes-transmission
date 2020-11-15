#!/bin/bash

if ! command -v kubectl &> /dev/null; then
    echo 'kubectl is not installed'
    exit 1
fi

kubectl apply -f manifests/namespace.yaml
#kubectl apply -f manifests/nfs-persistentVolume.yaml
#kubectl apply -f manifests/persistentVolumeClaim.yaml
kubectl apply -f manifests/pvc.yaml
kubectl apply -f manifests/secret.yaml
kubectl apply -f manifests/configMap.yaml
kubectl apply -f manifests/service.yaml
kubectl apply -f manifests/deployment.yaml
kubectl apply -f manifests/ingress.yaml
