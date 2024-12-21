# ha base image
ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19

# first stage, can't use alpine for building armv7
FROM node:22.12.0-alpine AS builder
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache python3 make g++ git

# clone, build and remove repo example data
RUN git clone --depth 1 https://github.com/symi-daguo/ha-fusion . && \
    npm install && \
    npm run build && \
    npm prune --omit=dev && \
    rm -rf ./data/*

# second stage
FROM ${BUILD_FROM}
WORKDIR /rootfs

# copy files to /rootfs
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js .
COPY --from=builder /app/package.json .

# copy run
COPY run.sh /

# install node
RUN apk add --no-cache nodejs-current && \
    ln -s /rootfs/data /data && \
    chmod a+x /run.sh

# set environment
ENV PORT=5050 \
    NODE_ENV=production \
    ADDON=true \
    TZ=Asia/Shanghai \
    HOST=0.0.0.0 \
    HASS_URL=http://supervisor/core

CMD [ "/run.sh" ]
