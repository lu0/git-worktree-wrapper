#!/usr/bin/env bash

#
# git-worktree-wrapper
#
# Wrapper script to easily execute common git-worktree commands.
# This script overrides git's checkout/branch commands
# when working within bare repositories (worktrees).
#
# Quiet built-in checkouts are made after each overridden checkout
# to trigger post-checkout hooks.
#


# shellcheck disable=SC2164
set -uo pipefail


gww::override_command() {
    case "${1:-}" in
        checkout)   checkout::override_commands "${@:-}" ;;
        branch)     branch::override_commands "${@:-}" ;;
        *)          utils::git "${@:-}" ;;
    esac
}


gww::main() {
    local is_bare_repo

    is_bare_repo=$(
        utils::git config --local --get core.bare 2> /dev/null | grep -i true | wc -w
    )

    if [[ "${is_bare_repo}" == 1 ]]; then
        gww::override_command "${@:-}"
    else
        utils::git "${@:-}"
    fi
}

gww::init() {
    local script_real_dir

    script_real_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    if [ "$0" == "${BASH_SOURCE[0]}" ]; then
        echo "git-worktree-wrapper must be sourced instead of executed."
        exit 1
    fi

    # Load libraries
    # shellcheck source=libs/_init_libs.sh
    source "${script_real_dir}/libs/_init_libs.sh"
}


trap 'break' ERR;

while true; do
    gww::init
    gww::main "${@:-}"
    break
done

trap - ERR
set +u +o pipefail