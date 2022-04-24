#!/usr/bin/env bash
# shellcheck disable=SC2164

# 
# Functions to wrap git's checkout command in bare repositories
#
# Uses globals:
#   BARE_DIR


# Override checkout commands. Triggered by:
# > git checkout ...
checkout::override_commands() {
    local existing_branch
    # Most common cases
    case "${2:-}" in
        -b|-B)
            # Create or reset a branch/worktree
            checkout::_create_branch_and_worktree "${@:-}"
            return ;;
        .)
            # Simplest file checkout, run vanilla git
            utils::git "${@:-}"
            return ;;
    esac


    if [[ -z "${3:-}" ]] && [[ $(utils::is_worktreable "${2:-}") == 1 ]]; then
        # If `git checkout` received only 1 argument (other than the previous
        # cases) and is a "worktreable" reference, switch and cd into it ...
        checkout::_switch_to_ref_and_worktree "${@:-}"
    else
        # ... otherwise, either an unsupported option was passed ...
        if echo "${@:-}" | grep -qo " -" ; then
            utils::info "Options other than [-b|-B] are not supported.
            Running vanilla git."
        fi
        # ... or the checkout is not a branch checkout,
        # either way, handle it with vanilla git
        utils::git "${@:-}"
    fi
}


# Create or reset a branch/worktree, emulates git command:
# - `git checkout [-b|B] ${to} ${from}`
# - Call: `checkout::_create_branch_and_worktree $opt $to $from`
checkout::_create_branch_and_worktree() {
    local opt="${2:-}" to="${3:-}" from="${4:-}"
    local to_dir existing_branch

    to_dir=$(utils::ref_to_dir_name "${to}")
    existing_branch=$(utils::git branch --list "${to}")

    if [ "${existing_branch:-}" ] && [ "${opt}" == "-b" ]; then
        # Branch exists and we are not forcing its reset,
        # let vanilla git handle it by issuing a soft creation
        # of the existing branch
        utils::git branch "${to}"
    else
        # Create branch if does not exist
        if [ -z "${existing_branch:-}" ]; then
            # shellcheck disable=SC2086
            utils::git branch "${to}" ${from}
        fi

        # Create worktree if does not exist
        worktree_dir=$(checkout::__create_worktree_from_ref "${to}")

        # cd into the worktree dir
        cd "${worktree_dir}"

        if [ "${opt}" == "-B" ]; then
            # Let git handle resets. Vanilla checkouts
            # always trigger post-checkout hooks.
            # shellcheck disable=SC2086
            utils::git checkout -B "${to}" ${from}
        else
            # Trigger post-checkout hooks
            checkout::__trigger_post_hook
        fi

        utils::open_editor_and_store_reference
    fi
}


# Switch to a branch/tag/worktree, emulates git command:
# - `git checkout ${to}`
# - Call: `checkout::_switch_to_ref_and_worktree $to`
checkout::_switch_to_ref_and_worktree() {
    local to="${2:-}"
    local existing_branch
    local worktree_dir

    # Create worktree if does not exist
    worktree_dir=$(checkout::__create_worktree_from_ref "${to}")

    if [ -d "${worktree_dir:-}" ]; then
        # If successful, cd to the created worktree
        cd "${worktree_dir}"
        checkout::__trigger_post_hook
        utils::open_editor_and_store_reference
    fi
}


# Creates worktree from a given reference if the worktree does not exist.
# Worktree directories are created in the root of the bare repository.
# Vanilla git handles non-existence of the given reference.
# Post-checkout hooks are disabled within this function.
# - Call: `checkout::__create_worktree_from_ref "${ref}"`
# - Returns: Path to the created or existing worktree for `ref` or
#             an empty string if the creation was not successful.
checkout::__create_worktree_from_ref() {
    local to="${1}"
    local to_dir
    local bare_dir

    bare_dir=$(utils::get_bare_dir)
    to_dir=$(utils::ref_to_dir_name "${to}")

    # Create worktree if does not exist
    if [ -z "$(utils::get_ref_path "${to}")" ]; then
        # Created in the directory of the bare repository
        cd "${bare_dir}"

        # Create worktree silently
        if utils::git worktree add "${to_dir}" "${to}" --no-checkout -q; then
            # Return directory of the new worktree
            echo "${bare_dir%%/}/${to_dir}"
            return
        fi
    fi

    utils::get_ref_path "${to}"
}


# Triggers post-checkout hooks by executing a silent
# checkout to the current branch or reference using vanilla git.
# - Call: `checkout::__trigger_post_hook`
checkout::__trigger_post_hook() {
    local branch
    branch="$(utils::git branch --show-current)"
    if [[ "${branch}" ]]; then
        utils::git checkout -q "${branch}"
    else
        utils::git checkout -q "$(git rev-parse HEAD)"
    fi
}
