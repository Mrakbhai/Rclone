# Dockerfile - rclone WebDAV on Alpine (copy-paste ready)
FROM alpine:latest

# install required utilities (including base64 via coreutils)
RUN apk add --no-cache bash curl ca-certificates unzip coreutils

# download a pinned rclone binary
ENV RCLONE_VER v1.63.1
RUN curl -fsSL "https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-amd64.zip" -o /tmp/rclone.zip \
  && unzip /tmp/rclone.zip -d /tmp \
  && cp /tmp/rclone-*-linux-amd64/rclone /usr/bin/ \
  && chmod 755 /usr/bin/rclone \
  && rm -rf /tmp/*

EXPOSE 8080

# defaults (you can override via Render env vars)
ENV WEBDAV_USER=webdav
ENV WEBDAV_PASS=webdavpass
ENV REMOTE_NAME=gdrive
ENV RCLONE_CONF_PATH=/root/.config/rclone/rclone.conf

# Start: create config dir, decode config if provided, unset RCLONE_CONFIG (avoid rclone path-conflict),
# show a quick ls (for debugging), then run rclone pointing to the explicit config file.
CMD mkdir -p /root/.config/rclone && \
    if [ -n "$RCLONE_CONFIG_B64" ]; then echo "$RCLONE_CONFIG_B64" | base64 -d > "$RCLONE_CONF_PATH"; fi && \
    ls -l /root/.config/rclone && \
    /usr/bin/rclone --version && \
    unset RCLONE_CONFIG && \
    /usr/bin/rclone --config "$RCLONE_CONF_PATH" serve webdav "${REMOTE_NAME}:" --addr :8080 --user "$WEBDAV_USER" --pass "$WEBDAV_PASS"
