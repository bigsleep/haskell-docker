#!/bin/bash

set -ue -o pipefail

curl -sf https://api.github.com/repos/commercialhaskell/stack/releases/latest | jq -r '.name' | cut -b2-
