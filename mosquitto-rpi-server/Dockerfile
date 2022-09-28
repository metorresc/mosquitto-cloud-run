#!/bin/bash
# Copyright 2022 axmos.tech

# Use the official lightweight Python image.
# https://hub.docker.com/_/python
FROM python:3.10-buster

# Install system dependencies for GCS
RUN set -e; \
    apt-get update -y && apt-get install -y \
    tini \
    lsb-release; \
    gcsFuseRepo=gcsfuse-`lsb_release -c -s`; \
    echo "deb http://packages.cloud.google.com/apt $gcsFuseRepo main" | \
    tee /etc/apt/sources.list.d/gcsfuse.list; \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
    apt-key add -; \
    apt-get update; \
    apt-get install -y gcsfuse \
    && apt-get clean

# Define Mosquitto Version
ARG MOSQUITTO_VERSION=2.0.15
ENV MOSQUITTO_VERSION=$MOSQUITTO_VERSION

# Installing Mosquitto
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get install -y build-essential libssl-dev libossp-uuid16 uuid-dev libev4 libuv1 libwebsockets-dev libwrap0 libossp-uuid16 \
    && cd /tmp/ \
    && wget http://mosquitto.org/files/source/mosquitto-${MOSQUITTO_VERSION}.tar.gz \
    && useradd mosquitto \
    && tar xvzf mosquitto-${MOSQUITTO_VERSION}.tar.gz \
    && cd mosquitto-${MOSQUITTO_VERSION} \
    && make -j$(nproc) \
    && make install \
    && chown -R mosquitto:mosquitto /etc/mosquitto \
    && /sbin/ldconfig \
    && make clean \
    && cd /tmp/ \
    && rm -Rf mosquitto-${MOSQUITTO_VERSION} \
    && apt-get clean -y

# Set fallback mount directory
ENV MNT_DIR /mnt/gcs

# Copy local code to the container image.
ENV APP_HOME /app
WORKDIR $APP_HOME
COPY . ./

# Install production dependencies.
RUN pip install -r requirements.txt

# Ensure the script is executable
RUN chmod +x /app/gcsfuse_run.sh

# Use tini to manage zombie processes and signal forwarding
# https://github.com/krallin/tini
ENTRYPOINT ["/usr/bin/tini", "--"] 

# Pass the startup script as arguments to Tini
CMD ["/app/gcsfuse_run.sh"]

CMD ["/usr/local/sbin/mosquitto"]