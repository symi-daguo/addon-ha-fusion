#!/usr/bin/with-contenv bashio

export HASS_PORT=$(bashio::core.port)
export EXPOSED_PORT=$(bashio::addon.port "5050/tcp")

echo "Starting Fusion..."

cd /rootfs
node server.js
