FROM alpine:latest

# Install dependencies
RUN apk add --no-cache bash curl ca-certificates

# Download and install rclone binary
RUN curl -Of https://downloads.rclone.org/v1.63.1/rclone-v1.63.1-linux-amd64.zip \
    && unzip rclone-v1.63.1-linux-amd64.zip \
    && cp rclone-v1.63.1-linux-amd64/rclone /usr/bin/ \
    && chmod 755 /usr/bin/rclone \
    && rm -rf rclone-v1.63.1-linux-amd64*

EXPOSE 8080

CMD mkdir -p /root/.config/rclone && \
    echo "$RCLONE_CONFIG_B64" | base64 -d > /root/.config/rclone/rclone.conf && \
    rclone serve webdav gdrive: --addr :8080 --user $WEBDAV_USER --pass $WEBDAV_PASS
