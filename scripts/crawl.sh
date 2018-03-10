#!/bin/bash

set -ue -o pipefail

LATEST_GHC=$(./scripts/fetch-latest-package.sh ghc)

LATEST_ALEX=$(./scripts/fetch-latest-package.sh alex)
export ALEX_VERSION=$(cut -b6- <<<"$LATEST_ALEX")

LATEST_CABAL=$(./scripts/fetch-latest-package.sh cabal-install)
export CABAL_VERSION=$(cut -b15- <<<"$LATEST_CABAL")

LATEST_HAPPY=$(./scripts/fetch-latest-package.sh happy)
export HAPPY_VERSION=$(cut -b7- <<<"$LATEST_HAPPY")

export GHC_PACKAGES="$LATEST_GHC $LATEST_ALEX $LATEST_CABAL $LATEST_HAPPY"

export GHC_VERSION=$(cut -b5- <<<"$LATEST_GHC")

export STACK_VERSION=$(./scripts/fetch-stack-version.sh)

BASE_VERSION=$(ls -d versions/* | xargs -n1 basename | awk -v version=$GHC_VERSION '{ pattern="^"$1 ; if (version ~ pattern) print }' | sort -V | tail -n1)
if [ "$BASE_VERSION" = "" ]; then
    printf "env not found" >&2
    exit 1;
fi

BRANCH=$GHC_VERSION
if [ -z "$(git branch -r | grep $GHC_VERSION | tr -d ' ')" ]; then
    git branch -D $BRANCH || true
    git checkout origin/master -b $BRANCH
else
    git branch -D $BRANCH || true
    git checkout origin/$BRANCH -b $BRANCH
fi

export DOLLAR='$'
export BUILD_DATE=$(date -u --rfc-3339 seconds)
set -a && source ./versions/$BASE_VERSION/env && set +a && envsubst < Dockerfile.template > Dockerfile

git add Dockerfile
git commit -m "build trigger $GHC_VERSION"
git push origin $BRANCH:$BRANCH
