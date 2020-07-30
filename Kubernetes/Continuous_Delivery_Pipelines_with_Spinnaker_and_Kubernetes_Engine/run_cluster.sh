#!/bin/bash

PROJECT_ID=$1
USER=$2

SA_EMAIL="spinnaker-account@$PROJECT_ID.iam.gserviceaccount.com"
BUCKET=$PROJECT_ID-spinnaker-config
time gcloud container clusters create spinnaker-tutorial --machine-type=n1-standard-2 & 

gcloud iam service-accounts create spinnaker-account --display-name spinnaker-account
gcloud projects add-iam-policy-binding $PROJECT_ID --role roles/storage.admin --member serviceAccount:$SA_EMAIL
gcloud iam service-accounts keys create spinnaker-sa.json --iam-account $SA_EMAIL
SA_JSON=$(cat spinnaker-sa.json)
gcloud pubsub topics create projects/$PROJECT_ID/topics/gcr

gcloud pubsub subscriptions create gcr-triggers --topic projects/${PROJECT_ID}/topics/gcr
while [ $? -ne 0 ]; do
    gcloud pubsub subscriptions create gcr-triggers --topic projects/${PROJECT_ID}/topics/gcr
done
gcloud beta pubsub subscriptions add-iam-policy-binding gcr-triggers --role roles/pubsub.subscriber --member serviceAccount:$SA_EMAIL

gsutil mb -c regional -l us-central1 gs://$BUCKET
cat > spinnaker-config.yaml <<EOF
gcs:
  enabled: true
  bucket: $BUCKET
  project: $PROJECT_ID
  jsonKey: '$SA_JSON'

dockerRegistries:
- name: gcr
  address: https://gcr.io
  username: _json_key
  password: '$SA_JSON'
  email: 1234@5678.com

# Disable minio as the default storage backend
minio:
  enabled: false

# Configure Spinnaker to enable GCP services
halyard:
  additionalScripts:
    create: true
    data:
      enable_gcs_artifacts.sh: |-
        \$HAL_COMMAND config artifact gcs account add gcs-$PROJECT_ID --json-path /opt/gcs/key.json
        \$HAL_COMMAND config artifact gcs enable
      enable_pubsub_triggers.sh: |-
        \$HAL_COMMAND config pubsub google enable
        \$HAL_COMMAND config pubsub google subscription add gcr-triggers \
          --subscription-name gcr-triggers \
          --json-path /opt/gcs/key.json \
          --project $PROJECT_ID \
          --message-format GCR
EOF

wait < <(jobs -p)
./run_cluster_1.sh &
kubectl create clusterrolebinding user-admin-binding --clusterrole=cluster-admin --user=$USER
kubectl create clusterrolebinding --clusterrole=cluster-admin --serviceaccount=default:default spinnaker-admin
time helm install -n default cd stable/spinnaker -f spinnaker-config.yaml --version 1.23.0 --timeout 10m0s --wait --debug