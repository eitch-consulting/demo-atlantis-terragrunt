#!/bin/bash
#

podman build \
  -t localhost/atlantis-terragrunt:latest \
  -t localhost/atlantis-terragrunt:0.34.0 \
  -t localhost/atlantis-terragrunt:0.34.0-2 \
  --build-arg BUILD_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')" \
  .
