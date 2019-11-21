FROM alpine:3.10

RUN apk add bash git rsync
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
