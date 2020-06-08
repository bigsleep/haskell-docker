#!/bin/bash

set -ue -o pipefail

WITHOUT_GIT=${WITHOUT_GIT:=''}

if [ -z "${WITHOUT_GIT}" ]; then
    git config --global user.email "bigsleep.mtkd@gmail.com"
    git config --global user.name "circleci"
fi

TARGET_GHC=${TARGET_GHC:=$(./scripts/fetch-latest-package.sh ghc)}
GHC_VERSION=$(cut -b5- <<<"$TARGET_GHC")
export GHC_VERSION

TARGET_CABAL=${TARGET_CABAL:=$(./scripts/fetch-latest-package.sh cabal-install)}
CABAL_VERSION=$(cut -b15- <<<"$TARGET_CABAL")
export CABAL_VERSION

GHC_PACKAGES="${TARGET_GHC} ${TARGET_GHC}-prof ${TARGET_GHC}-dyn ${TARGET_GHC}-htmldocs ${TARGET_CABAL}"
export GHC_PACKAGES

BASE_VERSION=$(find ./versions -mindepth 1 -maxdepth 1 -type d -print0 | xargs -0 -n1 basename | awk -v "version=$GHC_VERSION" '{ pattern="^"$1 ; if (version ~ pattern) print }' | sort -V | tail -n1)
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
BUILD_DATE="$(date -u +'%Y-%m-%d %H:%M:%S+00:00')"
export BUILD_DATE
# shellcheck source=/dev/null
set -a && source "./versions/$BASE_VERSION/env" && set +a && envsubst < Dockerfile.template > Dockerfile

if [ -z "${WITHOUT_GIT}" ]; then
    git add Dockerfile
    git commit -m "build trigger $GHC_VERSION"
    git push origin "$BRANCH:$BRANCH"
fi
