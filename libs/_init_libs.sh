#!/usr/bin/env bash

LIBS_DIR=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=libs/_branch.sh
source "${LIBS_DIR}"/_branch.sh

# shellcheck source=libs/_checkout.sh
source "${LIBS_DIR}"/_checkout.sh

# shellcheck source=libs/_utils.sh
source "${LIBS_DIR}"/_utils.sh
