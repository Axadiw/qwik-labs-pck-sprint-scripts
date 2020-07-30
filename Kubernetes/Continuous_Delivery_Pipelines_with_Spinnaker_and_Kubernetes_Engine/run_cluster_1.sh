#!/bin/bash

kubectl create -f sample-app/k8s/deployments/sample-backend-canary.yaml
kubectl create -f sample-app/k8s/deployments/sample-backend-production.yaml
kubectl create -f sample-app/k8s/deployments/sample-frontend-canary.yaml
kubectl create -f sample-app/k8s/deployments/sample-frontend-production.yaml
kubectl create -f sample-app/k8s/services/sample-backend-canary.yaml
kubectl create -f sample-app/k8s/services/sample-backend-prod.yaml
kubectl create -f sample-app/k8s/services/sample-frontend-canary.yaml
kubectl create -f sample-app/k8s/services/sample-frontend-prod.yaml