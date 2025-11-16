FROM actualbudget/actual-server:latest

ARG INSTALL_CLOUDFLARED=true
ARG INSTALL_CADDY=true
ARG SYNC_DATA_CLOUDFLARE_R2=false
ARG BACKUP_RCLONE_R2=false
ARG KEEP_ALIVE=false

ENV PORT=8080 \
    ACTUAL_HOSTNAME=localhost \
    LOG_FILE=/data/actual.log \
    R2_DATA_SYNC_LOG=false \
    SYNC_DATA_CLOUDFLARE_R2=${SYNC_DATA_CLOUDFLARE_R2} \
    FLY_SWAP=false \
    OVERMIND_DAEMONIZE=0 \
    OVERMIND_AUTO_RESTART=all \
    CFUSEREMAIL=${CFUSEREMAIL} \
    CFAPITOKEN=${CFAPITOKEN} \
    CFZONEID=${CFZONEID} \
    KEEP_ALIVE=${KEEP_ALIVE}

USER root
# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y sqlite3 libpq5 wget curl tar lsof jq gpg ca-certificates openssl tmux procps unzip && \
    rm -rf /var/lib/apt/lists/*

# Create Procfile for overmind
RUN echo "actualbudget: node app.js" > ./Procfile

# Install Overmind, Supercronic, Caddy, Cloudflared and setup Procfile
RUN set -ex; \
    OVERMIND_VERSION=$(curl -s https://api.github.com/repos/DarthSim/overmind/releases/latest | jq -r '.tag_name'); \
    SUPERCRONIC_VERSION=$(curl -s https://api.github.com/repos/aptible/supercronic/releases/latest | jq -r '.tag_name'); \
    CADDY_VERSION=$(curl -s https://api.github.com/repos/caddyserver/caddy/releases/latest | jq -r '.tag_name'); \
    CLOUDFLARED_VERSION=$(curl -s https://api.github.com/repos/cloudflare/cloudflared/releases/latest | jq -r '.tag_name'); \
    \
    curl -L -o overmind.gz "https://github.com/DarthSim/overmind/releases/download/$OVERMIND_VERSION/overmind-${OVERMIND_VERSION}-linux-amd64.gz" || exit 1; \
    gunzip overmind.gz && chmod +x overmind && mv overmind /usr/local/bin/; \
    \
    if [ "$BACKUP_RCLONE_R2" = "true" ]; then \
        curl -L -o /usr/local/bin/supercronic "https://github.com/aptible/supercronic/releases/download/${SUPERCRONIC_VERSION}/supercronic-linux-amd64" || exit 1; \
        chmod +x /usr/local/bin/supercronic; \
        echo "backup: supercronic ./crontab" >> ./Procfile; \
        echo "5 0 * * * ./backup-r2-rclone.sh" >> ./crontab; \
    fi; \
    \
    if [ "$INSTALL_CLOUDFLARED" = "true" ]; then \
        curl -L -o cloudflared.deb "https://github.com/cloudflare/cloudflared/releases/download/$CLOUDFLARED_VERSION/cloudflared-linux-amd64.deb" || exit 1; \
        dpkg -i cloudflared.deb; \
        echo "cf_tunnel: ./start_cloudflared.sh" >> ./Procfile; \
    fi; \
    \
    if [ "$INSTALL_CADDY" = "true" ]; then \
        wget -O caddy.tar.gz "https://github.com/caddyserver/caddy/releases/download/$CADDY_VERSION/caddy_${CADDY_VERSION#v}_linux_amd64.tar.gz" || exit 1; \
        tar -xzf caddy.tar.gz -C /usr/local/bin/ caddy; \
        echo "caddy: caddy run --config ./Caddyfile --adapter caddyfile" >> ./Procfile; \
    fi; \
    \
    if [ "$SYNC_DATA_CLOUDFLARE_R2" = "true" ]; then \
        echo "data-sync: ./sync-r2-rclone.sh" >> ./Procfile; \
    fi; \
    \
    if [ "$KEEP_ALIVE" = "true" ]; then \
    echo "keep-alive: ./keep-alive.sh" >> ./Procfile; \
    fi

# Copy the entrypoint script and other scripts
COPY scripts/*.sh ./
COPY Caddyfile ./Caddyfile

# Chmod the scripts
RUN chmod +x ./*.sh

# Set the entrypoint script as the entrypoint for the container
ENTRYPOINT ["./entrypoint.sh"]

# Start Overmind
CMD ["overmind", "start"]
