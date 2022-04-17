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


utils::get_branch_path() {
    utils::git worktree list | grep -w "\[${1}\]" | cut -d" " -f1
}


utils::get_bare_dir() {
    utils::git worktree list | head -1 | cut -d" " -f1
}


utils::__store_last_checkedout() {
    branch=$(git branch --show-current)
    worktree_path=$(utils::get_branch_path ${branch})
    info="${worktree_path}\t[${branch}]"
    echo -e "${info}" > $(utils::get_bare_dir)/.lastcheckedout
}


# Open the current worktree in a enabled and set editor and
# store a reference to the worktree directory in the repository's roots
utils::open_editor_and_store_reference() {
    if [[ "${EDITOR:-}" ]] && [[ "${DISABLE_GIT_WORKTREE_EDITOR:-}" != "1" ]]; then
        utils::info "Opening in editor: ${EDITOR:-}"
        ${EDITOR:-} .
    fi
    utils::__store_last_checkedout
}