#!/bin/bash

gcloud config set compute/zone us-central1-a
time gcloud container clusters create nginx-tutorial --num-nodes 2

./run_1.sh &
kubectl create serviceaccount --namespace kube-system tiller &
./run_2.sh &

wait < <(jobs -p)
helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --debug
while [ $? -ne 0 ]; do
    time helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --debug
done