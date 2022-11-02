FROM alpine:3.16.2

RUN apk --no-cache --update add bash wget

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

COPY entrypoint.sh /entrypoint.sh
ADD https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-amd64 .
RUN install tfsec-linux-amd64 /usr/local/bin/tfsec

ENTRYPOINT ["/entrypoint.sh"]
