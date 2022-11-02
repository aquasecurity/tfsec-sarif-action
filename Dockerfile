FROM alpine:3.16.2

RUN apk --no-cache --update add bash wget

SHELL ["/bin/bash", "-eo", "pipefail", "-c"]

COPY entrypoint.sh /entrypoint.sh
ADD --checksum=sha256:17c1bd99ebe13be77ac775651bc61f44b2b4409b4578485f1168eab8c3e97507 https://github.com/aquasecurity/tfsec/releases/download/v1.28.1/tfsec-linux-amd64 .
RUN install tfsec-linux-amd64 /usr/local/bin/tfsec

ENTRYPOINT ["/entrypoint.sh"]
