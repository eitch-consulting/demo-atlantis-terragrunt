#!/bin/bash
#

if [ -z "$1" ]; then
  echo "ERROR: No project ID defined."
  echo "Use: $(basename "$0") <project_id>"
  exit 1
fi

COMMAND=$(gcloud projects describe "$1" --format json)
if [ $? -eq 1 ]; then
  echo "ERROR: Project ${1} doesn't exist or you don't have permission to see it. Exiting."
  exit 1
else
  GCLOUD_PROJECT=$(echo "$COMMAND" | jq -r .projectId)
  PROJECT_NUMBER=$(echo "$COMMAND" | jq -r .projectNumber)
fi
unset COMMAND

BUCKET_NAME="tfstate-${PROJECT_NUMBER}-${GCLOUD_PROJECT}"

gcloud storage buckets create \
  "gs://${BUCKET_NAME}" \
  --location="us-central1" \
  --project="$GCLOUD_PROJECT" \
  --soft-delete-duration="7d" \
  --uniform-bucket-level-access \
  --public-access-prevention

gcloud storage buckets update \
  "gs://${BUCKET_NAME}" \
  --project="$GCLOUD_PROJECT" \
  --versioning

TMPFILE=$(mktemp)
cat <<EOF >"$TMPFILE"
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {
          "numNewerVersions": 2,
          "isLive": false
        }
      },
      {
        "action": {"type": "Delete"},
        "condition": {
          "daysSinceNoncurrentTime": 7
        }
      }
    ]
  }
}
EOF
gcloud storage buckets update \
  "gs://${BUCKET_NAME}" \
  --project="$GCLOUD_PROJECT" \
  --lifecycle-file="$TMPFILE"
rm -f "$TMPFILE"
