#!/bin/bash

PROJECT_NAME=<fill>

gcloud auth login
gcloud config set project $PROJECT_NAME
gcloud config set compute/zone us-central1-a

gcloud compute instances create lamp-1-vm --zone=us-central1-a --machine-type=n1-standard-2 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --tags=http-server --image=debian-10-buster-v20200714 --image-project=debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=lamp-1-vm --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
gcloud compute firewall-rules create default-allow-http --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:80 --source-ranges=0.0.0.0/0 --target-tags=http-server
LAMP_ID=`gcloud compute instances describe lamp-1-vm --format='get(id)'`
gcloud compute ssh lamp-1-vm -- 'sudo apt-get update && sudo apt-get install -y apache2 php7.0 && sudo service apache2 restart'
gcloud services enable monitoring
gcloud compute ssh lamp-1-vm -- 'curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh && sudo bash add-monitoring-agent-repo.sh && sudo apt-get update && sudo apt-get install -y stackdriver-agent'
gcloud compute ssh lamp-1-vm -- 'curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh && sudo bash add-logging-agent-repo.sh && sudo apt-get update && sudo apt-get install -y google-fluentd'

ACCESS_TOKEN=`gcloud auth print-access-token`
curl --request POST \
  "https://monitoring.googleapis.com/v3/projects/$PROJECT_NAME/uptimeCheckConfigs" \
  --header "Authorization: Bearer $ACCESS_TOKEN" \
  --header 'Accept: application/json' \
  --header 'Content-Type: application/json' \
  --data-binary "{\"checkerType\":\"CHECKER_TYPE_UNSPECIFIED\",\"displayName\":\"Lamp Uptime Check2\",\"httpCheck\":{\"port\":80,\"validateSsl\":false},\"logCheckFailures\":true,\"monitoredResource\":{\"labels\":{\"instance_id\":\"$LAMP_ID\",\"zone\":\"us-central1-a\",\"project_id\":\"$PROJECT_NAME\"},\"type\":\"gce_instance\"},\"period\":\"60s\",\"timeout\":\"10s\"}" \
  --compressed

gcloud alpha monitoring policies create --policy-from-file="policy.json"