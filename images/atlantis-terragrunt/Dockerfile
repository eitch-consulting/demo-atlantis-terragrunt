# ------------------------------------------------------------------------------
# BUILDER IMAGE
# ------------------------------------------------------------------------------
FROM docker.io/python:3.13-alpine AS builder

ARG terraform_version=1.12.1
ARG terragrunt_version=0.80.4
ARG atlantis_version=0.34.0

RUN apk add curl

RUN set -ex && \
curl -L \
  -s "https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip" \
  -o terraform.zip && \
unzip terraform.zip && \
mv terraform /usr/local/bin/terraform && \
chown -v root:root /usr/local/bin/terraform && \
chmod -v 755 /usr/local/bin/terraform

RUN set -ex && \
curl -L \
 -s "https://github.com/gruntwork-io/terragrunt/releases/download/v${terragrunt_version}/terragrunt_linux_amd64" \
 -o /usr/local/bin/terragrunt && \
chown -v root:root /usr/local/bin/terragrunt && \
chmod -v 755 /usr/local/bin/terragrunt

RUN set -ex && \
curl -L \
 -s "https://github.com/runatlantis/atlantis/releases/download/v${atlantis_version}/atlantis_linux_amd64.zip" \
 -o atlantis.zip && \
unzip atlantis.zip && \
mv atlantis /usr/local/bin/atlantis && \
chown -v root:root /usr/local/bin/atlantis && \
chmod -v 755 /usr/local/bin/atlantis

# ------------------------------------------------------------------------------
# MAIN IMAGE
# ------------------------------------------------------------------------------
FROM python:3.13-alpine

LABEL maintainer="hugo@eitch-consulting.com"

ARG BUILD_DATE=unspecified
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="atlantis-terragrunt"
LABEL org.label-schema.description="Customized image of atlantis with terraform and terragrunt"
LABEL org.label-schema.vcs-url="https://github.com/eitch-consulting/demo-atlantis-terragrunt"
LABEL org.label-schema.vendor="eitch-consulting"

RUN apk add --no-cache \
  bash \
  ca-certificates \
  curl \
  git \
  git-lfs \
  jq \
  openssh \
  openssl \
  unzip \
  expat \
  sqlite

RUN addgroup -g 565 "atlantis" && \
  adduser -h "/home/atlantis" -D -u 565 -G "atlantis" "atlantis"

ENV ATLANTIS_REPO_CONFIG=/etc/repos.yaml \
    ATLANTIS_DATA_DIR=/home/atlantis/data \
    TF_CLI_CONFIG_FILE=/etc/terraformrc

COPY --from=builder \
  /usr/local/bin/terraform \
  /usr/local/bin/terragrunt \
  /usr/local/bin/atlantis \
  /usr/local/bin/

COPY terraformrc repos.yaml /etc/
COPY --chmod=755 entrypoint.sh /usr/local/bin/

USER atlantis

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
