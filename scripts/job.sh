#!/bin/bash

set -ue -o pipefail

RELATED_PACKAGE_NAMES=(
    "alex"
    "cabal-install"
    "happy"
)

LATEST_GHC=$(./scripts/fetch-latest-package.sh ghc)

#if ./scripts/has-not-built-yet.sh "$LATEST_GHC"; then
if true; then
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

    export DOLLAR='$'
    set -a && source ./versions/$BASE_VERSION/env && set +a && envsubst < ./versions/$BASE_VERSION/Dockerfile.template > Dockerfile
fi
