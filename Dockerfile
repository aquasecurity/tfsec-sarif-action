FROM alpine:3.12

RUN apk --no-cache --update add bash git \
    && rm -rf /var/cache/apk/*

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
