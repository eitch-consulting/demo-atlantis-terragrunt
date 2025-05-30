#!/bin/bash
#

mkdir -p "$ATLANTIS_DATA_DIR"

terraform -version
terragrunt --version
atlantis version

atlantis server
