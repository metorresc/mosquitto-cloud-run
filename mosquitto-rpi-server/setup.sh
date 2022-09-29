#!/bin/bash
# Copyright 2022 axmos.tech

export username=$(whoami)

export MQTT_DATA="mosquitto-data"
docker volume create --name $MQTT_DATA

export MQTT_LOG="mosquitto-log"
docker volume create --name $MQTT_LOG

export MQTT_CFG="mosquitto-config"
docker volume create --name $MQTT_CFG

sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install uidmap -y
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh 
dockerd-rootless-setuptool.sh install
sudo usermod -aG docker $username
sudo apt-get install libffi-dev libssl-dev -y
sudo apt install python3-dev -y
sudo apt-get install -y python3 python3-pip
sudo pip3 install docker-compose
sudo systemctl enable docker

mkdir -p /home/$username/mqtt-server
mkdir -p /home/$username/mqtt-server/config
mkdir -p /home/$username/mqtt-server/config/certs
mkdir -p /home/$username/mqtt-server/data
mkdir -p /home/$username/mqtt-server/log

cp mosquitto.conf /home/$username/mqtt-server/config/mosquitto.conf
cp Dockerfile /home/$username/mqtt-server
cp docker-compose.yml /home/$username/mqtt-server
cp generate-certificates.sh /home/$username/mqtt-server/config/certs/generate-certificates.sh
chmod +x /home/$username/mqtt-server/config/certs/generate-certificates.sh

# Generate CA For Server
sudo bash -c "cd /home/$username/mqtt-server/config/certs; /home/$username/mqtt-server/config/certs/generate-certificates.sh"

# Rename Certificates for the Server and crete the required ln to avoid cert recreation
mv /home/$username/mqtt-server/config/certs/$(hostname).crt /home/$username/mqtt-server/config/certs/server.crt
mv /home/$username/mqtt-server/config/certs/$(hostname).csr /home/$username/mqtt-server/config/certs/server.csr
mv /home/$username/mqtt-server/config/certs/$(hostname).key /home/$username/mqtt-server/config/certs/server.key
ln -s /home/$username/mqtt-server/config/certs/server.crt /home/$username/mqtt-server/config/certs/$(hostname).crt 
ln -s /home/$username/mqtt-server/config/certs/server.csr /home/$username/mqtt-server/config/certs/$(hostname).csr 
ln -s /home/$username/mqtt-server/config/certs/server.key /home/$username/mqtt-server/config/certs/$(hostname).key

#rm -rf /home/$username/mqtt-server/config/certs/generate-certificates.sh
sudo chown -R $username:$username config/certs

cd /home/$username/mqtt-server
docker build -t mosquitto-rpi4 .
docker tag mosquitto-rpi4:latest mosquitto-rpi4:latest-rpi4
docker-compose -f docker-compose.yaml up -d