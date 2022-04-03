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


# Non intrusive messages
utils::info() {
    echo -e >&2 "\ngit-worktree-wrapper:\n\t${1}\n"
}



# Use `.` instead of `/` to name worktree directories
utils::branch_to_dir_name() {
    echo "${1//'/'/'.'}"
}


utils::get_bare_dir() {
    utils::git worktree list | head -1 | cut -d" " -f1
}


# Open directory in the preferred editor (if set and enabled)
utils::open_editor_in_current() {
    if [[ ${EDITOR:-} ]] && [[ ${DISABLE_GIT_WORKTREE_EDITOR:-} != 1 ]]; then
        utils::info "Opening in editor: ${EDITOR:-}"
        ${EDITOR:-} .
    fi
}
