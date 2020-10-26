#!/bin/bash

if ! command -v kubectl &> /dev/null; then
    echo 'kubectl is not installed'
    exit 1
fi

kubectl delete all --all -n transmission
kubectl delete ingress transmission -n transmission
kubectl delete pvc transmission-pvc -n transmission
kubectl delete pv transmission-pv-nfs
kubectl delete secret transmission-creds -n transmission
kubectl delete namespace transmission
