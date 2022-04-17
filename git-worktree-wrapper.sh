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

# git command overrider,
# selects override function according to the command passed to git (`$1`).
# Commands supported: `checkout` and `branch`
gww::override_command() {
    case "${1:-}" in
        checkout)   checkout::override_commands "${@:-}" ;;
        branch)     branch::override_commands "${@:-}" ;;
        *)          utils::git "${@:-}" ;;
    esac
}

# Detects if the repository is a bare repository and triggers
# the command overrider, else runs vanilla git.
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

# Checks and initializes script's libraries and environment
gww::init() {
    local script_real_dir

    script_real_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

    if [ "$0" == "${BASH_SOURCE[0]}" ]; then
        echo "git-worktree-wrapper must be sourced instead of executed."
        exit 1
    fi

    # shellcheck source=libs/_init_libs.sh
    source "${script_real_dir}/libs/_init_libs.sh"
}


# This script must be sourced to be able "cd" within the current shell,
# then we can't just use `set -e` on pipefails: this would close the shell.
# Here I emulate `set -e` by wrapping the script's execution in a while loop and
# forcing a `break` after an error is trapped.
# This is why we can ignore shellcheck's SC2164 code, since "cd'ing" into an
# inexisting directory returns an error that will be trapped and then 
# will abort the script, keeping the current shell.
trap 'break' ERR;

while true; do
    gww::init
    gww::main "${@:-}"
    break
done

# Revert traps and shell options
trap - ERR
set +u +o pipefail