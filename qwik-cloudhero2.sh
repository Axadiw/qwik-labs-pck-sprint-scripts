#!/bin/bash

PROJECT_NAME=$1

gcloud auth login
gcloud config set project $PROJECT_NAME
./qwik-cloudhero2_1.sh $PROJECT_NAME &
gcloud sql instances create qwiklabs-demo
gcloud sql databases create bike --instance="qwiklabs-demo"