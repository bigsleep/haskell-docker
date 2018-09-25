#!/bin/bash

set -ue -o pipefail

WITHOUT_GIT=${WITHOUT_GIT:=''}

if [ -z "${WITHOUT_GIT}" ]; then
    git config --global user.email "bigsleep.mtkd@gmail.com"
    git config --global user.name "circleci"
fi

LATEST_GHC=$(./scripts/fetch-latest-package.sh ghc)

LATEST_ALEX=$(./scripts/fetch-latest-package.sh alex)
ALEX_VERSION=$(cut -b6- <<<"$LATEST_ALEX")
export ALEX_VERSION

LATEST_CABAL=$(./scripts/fetch-latest-package.sh cabal-install)
CABAL_VERSION=$(cut -b15- <<<"$LATEST_CABAL")
export CABAL_VERSION

LATEST_HAPPY=$(./scripts/fetch-latest-package.sh happy)
HAPPY_VERSION=$(cut -b7- <<<"$LATEST_HAPPY")
export HAPPY_VERSION

GHC_PACKAGES="$LATEST_GHC $LATEST_ALEX $LATEST_CABAL $LATEST_HAPPY"
export GHC_PACKAGES

GHC_VERSION=$(cut -b5- <<<"$LATEST_GHC")
export GHC_VERSION

BASE_VERSION=$(find ./versions -print0 xargs -n1 basename | awk -v version="$GHC_VERSION" '{ pattern="^"$1 ; if (version ~ pattern) print }' | sort -V | tail -n1)
if [ "$BASE_VERSION" = "" ]; then
    printf "env not found" >&2
    exit 1;
fi

BRANCH=$GHC_VERSION
if [ -z "${WITHOUT_GIT}" ]; then
    if [ -z "$(git branch -r | grep "$GHC_VERSION" | tr -d ' ')" ]; then
        git branch -D "$BRANCH" || true
        git checkout origin/master -b "$BRANCH"
    else
        git branch -D "$BRANCH" || true
        git checkout "origin/$BRANCH" -b "$BRANCH"
        git merge --no-edit origin/master
    fi
fi

export DOLLAR='$'
BUILD_DATE="$(date -u --rfc-3339 seconds)"
export BUILD_DATE
# shellcheck source=/dev/null
set -a && source "./versions/$BASE_VERSION/env" && set +a && envsubst < Dockerfile.template > Dockerfile

if [ -z "${WITHOUT_GIT}" ]; then
    git add Dockerfile
    git commit -m "build trigger $GHC_VERSION"
    git push origin "$BRANCH:$BRANCH"
fi
