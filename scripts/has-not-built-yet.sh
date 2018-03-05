#!/bin/bash

set -e

GIT_OWNER="bigsleep"
GIT_REPO="haskell-docker"
TAG_NAME="$1"

tags=$(curl -fs https://api.github.com/repos/${GIT_OWNER}/${GIT_REPO}/tags)

result=$(echo $tags | jq "[.[] | select(.name == \"${TAG_NAME}\")][0]")

if [ "$result" == "null" ]; then
    exit 0
else
    exit 1
fi
