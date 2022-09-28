#!/bin/bash
# Copyright 2022 axmos.tech

FROM arm64v8/eclipse-mosquitto:2.0.15-openssl

RUN mkdir -p /mosquitto/config /mosquitto/data /mosquitto/log /mosquitto/config/certs
COPY config/mosquitto.conf /mosquitto/config
COPY config/certs/axmos-mqtt.crt /mosquitto/config/certs
COPY config/certs/axmos-mqtt.csr /mosquitto/config/certs
COPY config/certs/axmos-mqtt.key /mosquitto/config/certs
RUN chown -R mosquitto:mosquitto /mosquitto/config /mosquitto/data /mosquitto/log

VOLUME [ "/mosquitto/data", "/mosquitto/config", "/mosquitto/log" ]

EXPOSE 8883

CMD ["/usr/local/sbin/mosquitto", "-c", "/mosquitto/config/mosquitto.conf"]