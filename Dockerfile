# first stage, can't use alpine for building armv7
FROM node:22 AS builder
WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git

# clone and build
RUN git clone --depth 1 -b v2024.12.1 https://github.com/symi-daguo/ha-fusion . && \
    npm install --verbose && \
    npm run build && \
    npm prune --omit=dev && \
    rm -rf ./data/*

# second stage
FROM node:22-alpine
WORKDIR /app

# copy files to /app
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/server.js .
COPY --from=builder /app/package.json .

# copy run script
COPY run.sh /
RUN chmod a+x /run.sh

# set environment
ENV PORT=5050 \
    NODE_ENV=production \
    ADDON=true \
    TZ=Asia/Shanghai \
    HOST=0.0.0.0 \
    HASS_URL=http://supervisor/core

# Labels
LABEL \
    io.hass.name="Fusion" \
    io.hass.description="A modern, easy-to-use and performant custom Home Assistant dashboard" \
    io.hass.type="addon" \
    io.hass.version="2024.12.1" \
    maintainer="symi-daguo"

CMD ["/run.sh"]
