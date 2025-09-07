# Dockerfile - rclone WebDAV + WebUI-NG (Alpine, copy-paste ready)
FROM alpine:latest

# install required utilities (including base64 via coreutils, git, node for webui build)
RUN apk add --no-cache bash curl ca-certificates unzip coreutils git nodejs npm

# download a pinned rclone binary
ENV RCLONE_VER v1.63.1
RUN curl -fsSL "https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-amd64.zip" -o /tmp/rclone.zip \
  && unzip /tmp/rclone.zip -d /tmp \
  && cp /tmp/rclone-*-linux-amd64/rclone /usr/bin/ \
  && chmod 755 /usr/bin/rclone \
  && rm -rf /tmp/*

# clone & build rclone-webui-react (NG frontend)
RUN git clone https://github.com/romi/rclone-webui-react.git /app/webui \
  && cd /app/webui \
  && npm install && npm run build

EXPOSE 8080 5572

# defaults (overridable via Render env vars)
ENV WEBDAV_USER=webdav
ENV WEBDAV_PASS=webdavpass
ENV REMOTE_NAME=gdrive
ENV RCLONE_CONF_PATH=/root/.config/rclone/rclone.conf

# Start both services: WebDAV + RC with WebUI
CMD mkdir -p /root/.config/rclone && \
    if [ -n "$RCLONE_CONFIG_B64" ]; then echo "$RCLONE_CONFIG_B64" | base64 -d > "$RCLONE_CONF_PATH"; fi && \
    unset RCLONE_CONFIG && \
    # Run WebDAV (8080) in background
    /usr/bin/rclone --config "$RCLONE_CONF_PATH" serve webdav "${REMOTE_NAME}:" --addr :8080 --user "$WEBDAV_USER" --pass "$WEBDAV_PASS" & \
    # Run RC with WebUI (5572, serves built frontend)
    /usr/bin/rclone rcd --rc-addr :5572 --rc-web-gui --rc-web-gui-no-open-browser --rc-user "$WEBDAV_USER" --rc-pass "$WEBDAV_PASS" --config "$RCLONE_CONF_PATH" \
    --rc-web-gui-update --rc-web-gui-force-open-dir /app/webui/build
