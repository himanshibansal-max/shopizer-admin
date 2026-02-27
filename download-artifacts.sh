#!/bin/bash

set -e

REPO="${GITHUB_REPOSITORY:-owner/repo}"
TOKEN="${GITHUB_TOKEN}"
WORKFLOW_NAME="ci.yml"
ARTIFACT_NAME="shopizer-admin-build"
OUTPUT_DIR="./downloaded-artifacts"

if [ -z "$TOKEN" ]; then
  echo "Error: GITHUB_TOKEN environment variable not set"
  echo "Usage: GITHUB_TOKEN=your_token ./download-artifacts.sh"
  exit 1
fi

echo "Fetching latest successful workflow run..."
RUN_ID=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$REPO/actions/workflows/$WORKFLOW_NAME/runs?status=success&per_page=1" \
  | grep -o '"id": [0-9]*' | head -1 | cut -d' ' -f2)

if [ -z "$RUN_ID" ]; then
  echo "No successful runs found"
  exit 1
fi

echo "Found run ID: $RUN_ID"
echo "Fetching artifact download URL..."

ARTIFACT_URL=$(curl -s -H "Authorization: token $TOKEN" \
  "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID/artifacts" \
  | grep -A3 "\"name\": \"$ARTIFACT_NAME\"" | grep "archive_download_url" | cut -d'"' -f4)

if [ -z "$ARTIFACT_URL" ]; then
  echo "Artifact not found"
  exit 1
fi

echo "Downloading artifact..."
mkdir -p "$OUTPUT_DIR"
curl -L -H "Authorization: token $TOKEN" "$ARTIFACT_URL" -o "$OUTPUT_DIR/artifact.zip"

echo "Extracting artifact..."
unzip -o "$OUTPUT_DIR/artifact.zip" -d "$OUTPUT_DIR"
rm "$OUTPUT_DIR/artifact.zip"

echo "Starting local server..."
cd "$OUTPUT_DIR"
npx http-server -p 8080 -o
