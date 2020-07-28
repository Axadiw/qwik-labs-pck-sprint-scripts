#!/bin/bash

USER2=<fill>
PROJECT_NAME=<fill>
BUCKET_NAME=<fill>
TEST_FILE_PATH=./sample.txt

gcloud auth login
gcloud config set project $PROJECT_NAME
gsutil mb gs://$BUCKET_NAME
gsutil cp $TEST_FILE_PATH gs://$BUCKET_NAME/

gcloud projects remove-iam-policy-binding $PROJECT_NAME --member=user:$USER2 --role=roles/viewer
gcloud projects add-iam-policy-binding $PROJECT_NAME --member=user:$USER2 --role=roles/storage.objectViewer