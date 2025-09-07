FROM alpine:latest

# Install rclone + bash + ca-certificates
RUN apk add --no-cache bash curl ca-certificates \
    && curl https://rclone.org/install.sh | bash

EXPOSE 8080

# Serve rclone as WebDAV using env variables
CMD echo "$RCLONE_CONFIG" > /root/.config/rclone/rclone.conf && \
    rclone serve webdav gdrive: --addr :8080 --user $WEBDAV_USER --pass $WEBDAV_PASS
