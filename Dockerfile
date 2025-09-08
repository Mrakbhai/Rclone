# Dockerfile - rclone WebUI on Alpine
FROM alpine:latest

RUN apk add --no-cache bash curl ca-certificates unzip coreutils

# download a pinned rclone binary
ENV RCLONE_VER v1.63.1
RUN curl -fsSL "https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-amd64.zip" -o /tmp/rclone.zip \
  && unzip /tmp/rclone.zip -d /tmp \
  && cp /tmp/rclone-*-linux-amd64/rclone /usr/bin/ \
  && chmod 755 /usr/bin/rclone \
  && rm -rf /tmp/*

EXPOSE 5572

# defaults
ENV RCLONE_CONF_PATH=/root/.config/rclone/rclone.conf
ENV RCLONE_CONFIG_B64=""
ENV RCLONE_RC_USER=webui
ENV RCLONE_RC_PASS=webuipass

# startup
CMD mkdir -p /root/.config/rclone && \
    if [ -n "$RCLONE_CONFIG_B64" ]; then echo "$RCLONE_CONFIG_B64" | base64 -d > "$RCLONE_CONF_PATH"; fi && \
    unset RCLONE_CONFIG && \
    /usr/bin/rclone --config "$RCLONE_CONF_PATH" rcd \
      --rc-web-gui \
      --rc-addr :5572 \
      --rc-user "$RCLONE_RC_USER" \
      --rc-pass "$RCLONE_RC_PASS"
