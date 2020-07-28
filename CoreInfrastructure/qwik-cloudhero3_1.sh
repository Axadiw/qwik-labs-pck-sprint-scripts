#!/bin/bash
PROJECT_NAME=$1
gcloud config set project $PROJECT_NAME

gcloud compute networks create managementnet --project=$PROJECT_NAME --subnet-mode=custom --bgp-routing-mode=regional
gcloud compute networks subnets create managementsubnet-us --project=$PROJECT_NAME --range=10.130.0.0/20 --network=managementnet --region=us-central1
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=tcp:22,tcp:3389,icmp --source-ranges=0.0.0.0/0