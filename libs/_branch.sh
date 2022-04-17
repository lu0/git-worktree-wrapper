#
# Functions to wrap git's branch command in bare repositories
#


# Override branch commands. Triggered by:
# > git branch ...
branch::override_commands() {
    # Most common cases
    case "${2:-}" in
        -d|-D)
            branch::_delete_worktree_and_branch "${@:-}"
            return ;;
        *)
            # Run vanilla git for other cases
            utils::git "${@:-}"
            return ;;
    esac
}


# Delete worktree then branch
branch::_delete_worktree_and_branch() {
    local opt="${2:-}" branch="${3:-}"
    local to_dir cd_to_bare_dir worktree_abs_dir
    local bare_dir

    bare_dir="$(utils::get_bare_dir)"
    to_dir=$(utils::branch_to_dir_name "${branch}")
    cd_to_bare_dir=false

    worktree_abs_dir="${bare_dir%%/}/${to_dir}"

    case "${2}" in
        -d)
            # Soft remove
            utils::git worktree remove "${worktree_abs_dir}" 2> /dev/null \
                && cd_to_bare_dir=true
            ;;
        -D)
            # Force removal
            utils::git worktree remove -f "${worktree_abs_dir}" 2> /dev/null \
                && cd_to_bare_dir=true
            ;;
    esac

    if [ "${cd_to_bare_dir}" == true ]; then
        cd "${bare_dir}"
        utils::open_editor_and_store_reference
    fi

    # Let vanilla git handle removal of the branch
    utils::git "${@:-}"
}
