FROM alpine:latest

# install utilities
RUN apk add --no-cache bash curl ca-certificates unzip coreutils

# rclone version
ENV RCLONE_VER v1.63.1

# download rclone binary
RUN curl -fsSL "https://downloads.rclone.org/${RCLONE_VER}/rclone-${RCLONE_VER}-linux-amd64.zip" -o /tmp/rclone.zip \
  && unzip /tmp/rclone.zip -d /tmp \
  && cp /tmp/rclone-*-linux-amd64/rclone /usr/bin/ \
  && chmod 755 /usr/bin/rclone \
  && rm -rf /tmp/*

# download and bundle webui assets
RUN mkdir -p /app/webui \
  && curl -fsSL https://github.com/rclone/rclone-webui-react/releases/download/v2.0.5/currentbuild.zip -o /tmp/webui.zip \
  && unzip /tmp/webui.zip -d /app/webui \
  && rm -rf /tmp/webui.zip

EXPOSE 5572

# env vars
ENV RCLONE_RC_USER=webui
ENV RCLONE_RC_PASS=webuipass
ENV RCLONE_CONF_PATH=/root/.config/rclone/rclone.conf

# start rclone with bundled webui
CMD mkdir -p /root/.config/rclone && \
    if [ -n "$RCLONE_CONFIG_B64" ]; then echo "$RCLONE_CONFIG_B64" | base64 -d > "$RCLONE_CONF_PATH"; fi && \
    unset RCLONE_CONFIG && \
    /usr/bin/rclone rcd \
      --rc-addr :5572 \
      --rc-user "$RCLONE_RC_USER" \
      --rc-pass "$RCLONE_RC_PASS" \
      --rc-web-gui \
      --rc-web-gui-no-open-browser \
      --rc-web-gui-update off \
      --rc-web-gui-root /app/webui
