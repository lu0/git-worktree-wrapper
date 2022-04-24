#!/usr/bin/env bash
# shellcheck disable=SC2164

#
# Miscellaneous utilities
#


# Vanilla git to avoid aliases
utils::git() {
    if [ "${1:-}" == "" ]; then
        # No arguments
        /usr/bin/env git
    else
        /usr/bin/env git "${@:-}"
    fi
}


# Returns 1 if the specified reference is "worktreable".
# A reference is "worktreable" if it's a branch or a tag,
# this enables detached checkouts to commits within a worktree.
utils::is_worktreable() {
    local ref="${1}"
    local is_branch is_tag

    is_branch=$(utils::git show-ref --verify -q refs/heads/"${ref}" && echo 1)
    is_tag=$(utils::git show-ref --verify -q refs/tags/"${ref}" && echo 1)

    if [[ "${is_tag}" == 1 ]] || [[ "${is_branch}" == 1 ]]; then
        echo 1
    fi
}



# Non intrusive messages
utils::info() {
    echo -e >&2 "\ngit-worktree-wrapper:\n\t${1}\n"
}


# Use `.` instead of `/` to name worktree directories
utils::ref_to_dir_name() {
    echo "${1//'/'/'.'}"
}


# Returns the absolute path to the worktree of a given reference,
# the result is empty if the reference does not have a worktree.
utils::get_ref_path() {
    local ref="${1}"
    local bare_dir ref_dirname ref_path_to_check
    bare_dir=$(utils::get_bare_dir)
    ref_dirname=$(utils::ref_to_dir_name "${ref}")
    ref_path_to_check="${bare_dir}/${ref_dirname}"
    utils::git worktree list | grep -o "${ref_path_to_check} " | xargs
}


utils::get_bare_dir() {
    utils::git worktree list | head -1 | cut -d" " -f1
}


utils::__store_current_worktree_info() {
    local info_file_path current_worktree_info
    info_file_path="$(utils::get_bare_dir)/.lastcheckedout"
    current_worktree_info=$(utils::git worktree list | grep "$PWD " | xargs)
    echo -e "${current_worktree_info}" > "${info_file_path}"
}


# Opens the current worktree in a enabled and set editor and
# stores the information of the current worktree directory in the repository's root
utils::open_editor_and_store_reference() {
    if [[ "${EDITOR:-}" ]] && [[ "${DISABLE_GIT_WORKTREE_EDITOR:-}" != "1" ]]; then
        utils::info "Opening in editor: ${EDITOR:-}"
        ${EDITOR:-} .
    fi
    utils::__store_current_worktree_info
}