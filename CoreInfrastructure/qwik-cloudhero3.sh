#!/bin/bash

# mynet-eu-vm
PROJECT_NAME=$1

gcloud auth login
gcloud config set project $PROJECT_NAME

./qwik-cloudhero3_1.sh $PROJECT_NAME &
./qwik-cloudhero3_2.sh $PROJECT_NAME &

wait < <(jobs -p)
gcloud compute instances create managementnet-us-vm --zone=us-central1-c --machine-type=f1-micro --subnet=managementsubnet-us
gcloud compute instances create privatenet-us-vm --zone=us-central1-c --machine-type=n1-standard-1 --subnet=privatesubnet-us
gcloud compute instances create vm-appliance --zone=us-central1-c --machine-type=n1-standard-4 --network-interface subnet=privatesubnet-us --network-interface subnet=managementsubnet-us --network-interface subnet=mynetwork
