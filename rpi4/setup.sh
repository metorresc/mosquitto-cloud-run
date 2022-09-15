export MOSQUITTO_VERSION=2.0.15-openssl
podman pull docker.io/eclipse-mosquitto:$MOSQUITTO_VERSION
podman images
podman run -it docker.io/eclipse-mosquitto:$MOSQUITTO_VERSION
podman ps

sudo apt-get update --fix-missing
sudo apt-get upgrade
sudo apt-get -y install podman

export MQTT_DATA="mosquitto-data"
podman volume create $MQTT_DATA

export MQTT_CFG="mosquitto-config"
podman volume create $MQTT_CFG

# Clone the kit onto the Raspberry Pi
sudo mkdir -p /opt/podman-compose
sudo chmod a+rw -R /opt/podman-compose/
sudo mkdir -p /opt/podman-compose/rpi4
cd /opt/podman-compose/rpi4

# Create bind mounted directories and copy starting files into place
sudo mkdir -p /opt/mqtt/config
sudo mkdir -p /opt/mqtt/config/conf.d
sudo mkdir -p /opt/mqtt/config/certs
sudo mkdir -p /opt/mqtt/data
sudo mkdir -p /opt/mqtt/log
sudo chmod -R a+rw /opt/mqtt
sudo cp mosquitto.conf /opt/mqtt/config/mosquitto.conf
sudo cp passwd /opt/mqtt/config/passwd
sudo cp aclfile /opt/mqtt/config/aclfile
sudo cp TCP_8883_Encrypted_MQTT.conf /opt/mqtt/config/conf.d/TCP_8883_Encrypted_MQTT.conf
sudo cp TCP_9883_Encrypted_Websockets.conf /opt/mqtt/config/conf.d/TCP_9883_Encrypted_Websockets.conf
sudo cp generate-CA.sh /opt/mqtt/config/certs/generate-CA.sh
# sudo cp passwd /opt/mqtt/config/passwd
# sudo cp aclfile /opt/mqtt/config/aclfile
sudo chmod +x /opt/mqtt/config/certs/generate-CA.sh
# Generate CA
sudo bash -c "cd /opt/mqtt/config/certs; /opt/mqtt/config/certs/generate-CA.sh"
# Generate certs for various other users/services
#sudo bash -c "cd /opt/mqtt/config/certs; /opt/mqtt/config/certs/generate-CA.sh SomeUserName"

# Move hostname specific files to generic mqtt namming
mv /opt/mqtt/config/certs/$(hostname).crt /opt/mqtt/config/certs/mqtt.crt
mv /opt/mqtt/config/certs/$(hostname).csr /opt/mqtt/config/certs/mqtt.csr
mv /opt/mqtt/config/certs/$(hostname).key /opt/mqtt/config/certs/mqtt.key

# Reverse link naming so the generate-CA.sh script does not attempt to create these again
ln -s /opt/mqtt/config/certs/mqtt.crt /opt/mqtt/config/certs/$(hostname).crt
ln -s /opt/mqtt/config/certs/mqtt.csr /opt/mqtt/config/certs/$(hostname).csr
ln -s /opt/mqtt/config/certs/mqtt.key /opt/mqtt/config/certs/$(hostname).key
ls -alF /opt/mqtt/config/certs

# Set perms for bind mount as root and container group 1883
sudo chown -R root:1883 /opt/mqtt
ls -alF /opt/mqtt

# Install Mosquitto Client
sudo apt install -y mosquitto-clients

docker run -v $MQTT_CFG:/mnt --rm hypriot/armhf-busybox \
 mkdir /mnt/ca_certificates /mnt/certs

docker run -v $MQTT_CFG:/mnt --rm -v $(pwd):/src hypriot/armhf-busybox \
 cp /src/config/mosquitto.conf /mnt/mosquitto.conf

