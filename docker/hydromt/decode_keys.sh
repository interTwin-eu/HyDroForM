#!/bin/bash
# Decode base64 AWS credentials and export them

if [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Both AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY must be set (base64 encoded)."
  exit 1
fi

export AWS_ACCESS_KEY_ID="$(echo "$AWS_ACCESS_KEY_ID" | base64 --decode)"
export AWS_SECRET_ACCESS_KEY="$(echo "$AWS_SECRET_ACCESS_KEY" | base64 --decode)"

echo "Decoded and exported AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY."