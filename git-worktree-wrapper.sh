#!/bin/bash

# 
# git-worktree-wrapper
# 
# Wrapper script to easily execute common git-worktree commands.
# This script overrides git's checkout/switch/branch commands
# when working on bare repositories (worktrees).
# 

# Using an alias pointing to the binary to avoid
# _complete_alias to get confused
alias git_=$(which git)

clean_env() {
    unalias git_
    unset is_bare bare_dir
    unset git_switch_cmds override_switch_cmds
    unset git_branch_cmds override_branch_cmds
    unset to to_dir from
    unset cmd 
}

is_git_repo=$(git_ branch --show-current 2> /dev/null | wc -w)
is_bare=$(git_ config --get core.bare)

if [[ "${is_bare}" = false ]] || [[ ${is_git_repo} = 0 ]]; then
    # Return original git command to enable autocompletion
    git_ "$@"
    clean_env && return 1
fi

bare_dir=$(git_ worktree list | head -1 | cut -d" " -f1)

git_switch_cmds=("checkout switch")
override_switch_cmds=$(echo ${git_switch_cmds[@]} | grep -ow "$1" | wc -w)

git_branch_cmds=("branch")
override_branch_cmds=$(echo ${git_branch_cmds[@]} | grep -ow "$1" | wc -w)

if [[ "${override_switch_cmds}" = 0 ]] && [[ "${override_branch_cmds}" = 0 ]]; then
    # Return original git command to enable autocompletion
    git_ "$@"
    clean_env && return 1
fi

show() {
    echo -e >&2 "git-worktree-wrapper:\n  ${1}"
}

if [[ "${override_switch_cmds}" = 1 ]]; then

    if [[ "$2" == "-b" || "$2" == "-B" ]]; then
        # Create new branch/worktree ------------------------------------------

        # Use `.` instead of `/` for directories of subbranches
        to_dir=$(echo "${3}" | sed s,\/,.,g)

        # Replace `git_switch_cmds` with `worktree add`,
        # set `from` if not passed as argument,
        # and specify the path in which the new branch is going to be stored.
        if [[ "${4}" ]]; then
            set -- "worktree add --track ${@:2:2} ${to_dir} ${@:4}"
        else
            from=$(git_ branch --show-current)
            set -- "worktree add --track ${@:2:2} ${to_dir} ${from}"
        fi

        # Run from bare repo's dir
        cd ${bare_dir}

        cmd="git_ $@"
        show "Executing vanilla command:\n\t${cmd}"
        eval ${cmd}


        # Open with default editor
        cd ${to_dir} && [[ ${NO_GIT_WORKTREE_EDITOR} != 1 ]] && ${EDITOR} .

    else 
        # Open existing branch/worktree -----------------------------------

        to="${2}"
        if [[ "${to}" == "." ]]; then
            to_branch_count=0
        else
            to_branch_count=$(git branch | grep -w "${to}" | wc -l)
        fi
        checking_branch=$(( ${to_branch_count} >= 1 ))

        if [[ "${checking_branch}" = 0 ]]; then 
            # Run original git command
            git_ "$@"

        else
            # Use `.` instead of `/` for directories of subbranches
            to_dir=$(echo "${to}" | sed s,\/,.,g)

            if [[ $(git_ worktree list | grep -w "\[${to}\]") ]]; then

                cmd="cd ${bare_dir}/${to_dir} && [[ ${NO_GIT_WORKTREE_EDITOR} != 1 ]] && ${EDITOR} ."
                show "Executing vanilla command:\n\t${cmd}"
                eval ${cmd}

            else
                show "Worktree ${to_dir} does not exist."
                cd -
            fi
        fi
    fi
    
elif [[ "${override_branch_cmds}" = 1 ]]; then

    if [[ "$2" == "-d" || "$2" == "-D" ]]; then
        # Delete worktree before deleting branch ------------------------------

        # Use `.` instead of `/` for directories of subbranches
        to_dir=$(echo "${3}" | sed s,\/,.,g)

        if [[ "$2" == "-d" ]]; then
            # Soft remove
            cmd="git_ worktree remove ${to_dir}"
        else
            # Force removal
            cmd="git_ worktree remove -f ${to_dir}"
        fi

        # Run from bare repo's dir
        cd ${bare_dir}

        show "Executing vanilla command:\n\t${cmd}"
        eval ${cmd}

    fi

    # Delete branch or run original branch command ----------------------------
    git_ "$@"

fi

show "Last checked out branch: $(cat ${bare_dir}/.currentbranch)"
clean_env && return 0
