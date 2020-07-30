#!/bin/bash

USER=<fill>
PROJECT_ID=<fill>

rm spinnaker-sa.json
rm -rf sample-app
cp -rf sample-app_ref sample-app

helm repo add stable https://kubernetes-charts.storage.googleapis.com
helm repo update

sed -i.bak "s/PROJECT/$PROJECT_ID/g" sample-app/k8s/deployments/*

gcloud config set compute/zone us-central1-f
gsutil mb -l us-central1 gs://$PROJECT_ID-kubernetes-manifests &

./run_cluster.sh $PROJECT_ID $USER &

gcloud source repos create sample-app &
gcloud builds submit -t gcr.io/$PROJECT_ID/sample-app:v1.0.0 sample-app --machine-type=n1-highcpu-32 &
gcloud builds submit -t gcr.io/$PROJECT_ID/sample-app:v1.0.1 sample-app --machine-type=n1-highcpu-32 &
