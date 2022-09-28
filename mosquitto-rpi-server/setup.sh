#!/bin/bash
# Copyright 2022 axmos.tech

export username=$(whoami)

export MQTT_DATA="mosquitto-data"
docker volume create --name $MQTT_DATA

export MQTT_LOG="mosquitto-log"
docker volume create --name $MQTT_LOG

export MQTT_CFG="mosquitto-config"
docker volume create --name $MQTT_CFG

mkdir -p /home/$username/mqtt-server
mkdir -p /home/$username/mqtt-server/config
mkdir -p /home/$username/mqtt-server/config/certs
mkdir -p /home/$username/mqtt-server/data
mkdir -p /home/$username/mqtt-server/log

cp mosquitto.conf /home/$username/mqtt-server/config/mosquitto.conf
cp Dockerfile /home/$username/mqtt-server
cp generate-certificates.sh /home/$username/mqtt-server/config/certs/generate-certificates.sh
chmod +x /home/$username/mqtt-server/config/certs/generate-certificates.sh

# Generate CA For Server
sudo bash -c "cd /home/$username/mqtt-server/config/certs; /home/$username/mqtt-server/config/certs/generate-certificates.sh"

# Rename Certificates for the Server and crete the required ln to avoid cert recreation
mv /home/$username/mqtt-server/config/certs/$(hostname).crt /home/$username/mqtt-server/config/certs/axmos-mqtt.crt
mv /home/$username/mqtt-server/config/certs/$(hostname).csr /home/$username/mqtt-server/config/certs/axmos-mqtt.csr
mv /home/$username/mqtt-server/config/certs/$(hostname).key /home/$username/mqtt-server/config/certs/axmos-mqtt.key
ln -s /home/$username/mqtt-server/config/certs/axmos-mqtt.crt /home/$username/mqtt-server/config/certs/$(hostname).crt 
ln -s /home/$username/mqtt-server/config/certs/axmos-mqtt.csr /home/$username/mqtt-server/config/certs/$(hostname).csr 
ln -s /home/$username/mqtt-server/config/certs/axmos-mqtt.key /home/$username/mqtt-server/config/certs/$(hostname).key

rm -rf /home/$username/mqtt-server/config/certs/generate-certificates.sh

cd /home/$username/mqtt-server
docker build -t .