#!/bin/bash

PROJECT_ID=<fill>

SA_EMAIL="apigee-stackdriver@$PROJECT_ID.iam.gserviceaccount.com"
gcloud iam service-accounts create apigee-stackdriver --display-name apigee-stackdriver
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:$SA_EMAIL --role=roles/logging.logWriter
gcloud iam service-accounts keys create apigee-sa.json --iam-account $SA_EMAIL

CALL1=$(cat call1.json)
CALL2=$(cat call2.json)
gcloud logging write example-log "$CALL2" --payload-type=json
gcloud logging write example-log "$CALL1" --payload-type=json