gcloud container --project "axmos-cloud" \
    clusters create-auto "xmos-mqtt-svc" \
    --region "southamerica-west1" \
    --release-channel "regular" \
    --enable-private-nodes \
    --master-ipv4-cidr "172.16.0.0/28" \
    --network "projects/axmos-cloud/global/networks/default" \
    --subnetwork "projects/axmos-cloud/regions/southamerica-west1/subnetworks/default" \
    --cluster-ipv4-cidr "/17" \
    --services-ipv4-cidr "/22"