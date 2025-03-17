`git-worktree-wrapper`
---

This wrapper script features an API for `git-worktree` commands
in order to easily create, switch and delete worktrees of bare repositories
using commands you already know: `git checkout` and `git branch`.

Quiet built-in checkouts are made after each overridden checkout to trigger
post-checkout hooks.


Table of Contents
---

- [Installation](#installation)
  - [Wrapper script](#wrapper-script)
  - [Completion rules](#completion-rules)
  - [Setup default editor](#setup-default-editor)
- [Usage](#usage)
  - [Clone and setup a bare repository](#clone-and-setup-a-bare-repository)
    - [Setup fetch rules from the remote](#setup-fetch-rules-from-the-remote)
  - [Open an existing branch, tag or worktree](#open-an-existing-branch-tag-or-worktree)
    - [Comparison with vanilla `git-worktree`](#comparison-with-vanilla-git-worktree)
  - [Create a new branch or worktree](#create-a-new-branch-or-worktree)
    - [Comparison with vanilla `git-worktree`](#comparison-with-vanilla-git-worktree-1)
  - [Delete a branch and its worktree](#delete-a-branch-and-its-worktree)
    - [Comparison with vanilla `git-worktree`](#comparison-with-vanilla-git-worktree-2)

# Installation

## Wrapper script

Clone this repository

```sh
\git clone https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper
```

Link `git-wrapper-script` to your local `PATH`

```sh
mkdir -p ~/.local/bin && ln -srf git-worktree-wrapper.sh ~/.local/bin/git-worktree-wrapper
```

Add the following to your `~/.bashrc` or `~/.bash_aliases`

```sh
alias git="source git-worktree-wrapper"
```

Restart your terminal or re-run bash

```sh
bash
```

## Completion rules

Check if your current completion rules autocomplete `git` after installing
the wrapper script. Try `git checko` + <kbd>TAB</kbd>

If your git commands are no longer autocompleted, install
[complete_alias@3fc67e8](https://github.com/cykerway/complete-alias/tree/3fc67e8).

```sh
sudo apt install bash-completion
git clone https://github.com/cykerway/complete-alias ~/.complete-alias
cd ~/.complete-alias
git checkout 3fc67e8
echo ". ${PWD}/complete_alias" >> ~/.bash_completion
```

Inherit `git`'s completion rules by pasting the following in your `~/.bashrc` or
`~/.bash_aliases`

```sh
alias git="source git-worktree-wrapper"
complete -F _complete_alias git

__compal__get_alias_body() {
    local cmd="$1"
    local body; body="$(alias "$cmd")"

    # Overrides
    case "$cmd" in
        "git") body="git"
    esac

    echo "${body#*=}" | command xargs
}
```


## Setup default editor

Set the environment variable `EDITOR` in your `~/.bashrc`,
`git-worktree-wrapper` will try to open worktree directories using this editor.

```sh
# Example using vscode
export EDITOR=code
```

Or set `DISABLE_GIT_WORKTREE_EDITOR=1` to disable usage of editors.

```sh
export DISABLE_GIT_WORKTREE_EDITOR=1
```

# Usage

## Clone and setup a bare repository

Try with this repo!

```sh
git clone --bare https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper.git
```

### Setup fetch rules from the remote

```sh
git config --local remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch
```

## Open an existing branch, tag or worktree

Switch to **branch** `master`:

```sh
git checkout master
```

You can also switch to an existing **tag**:
```sh
git checkout v1.0.0
```

The script will automatically create the worktree, if it does not exist, and *cd*
into it, **even if you are *cd'd* into another worktree/branch/tag**:

### Comparison with vanilla `git-worktree`

Next commands should be issued to achieve the same functionality described above when
`git-worktree-wrapper` is not installed:

If the branch/tag exists but the worktree doesn't.
```language
cd /path/to/the/root/of/the/bare/repository
git worktree add master
cd master
```

When the worktree exists:
```sh
cd /path/to/the/root/of/the/bare/repository
cd master
```

## Create a new branch or worktree

To create a new branch, just issue the command you already know:

```sh
git checkout -b new_branch <from_branch (optional)>
# or use -B to force reset
```

The script will automatically create a new worktree and *cd* into it,
**even if you are *cd'd* into another worktree/branch/tag**:

### Comparison with vanilla `git-worktree`

Next commands should be issued to achieve the same functionality described above when
`git-worktree-wrapper` is not installed:

When both the branch and worktree don't exist
```language
git branch new_branch
cd /path/to/the/root/of/the/bare/repository
git worktree add new_branch
cd new_branch
```

When branch or worktree already exist and you want to reset it as 
`git checkout -B` would do:
```sh
cd /path/to/the/root/of/the/bare/repository
cd new_branch
git checkout -B new_branch <from_branch (optional)>
```

## Delete a branch and its worktree

To delete a branch, just issue the command you already use for
"normal" repositories:

```sh
git branch -d new_branch # or -D to force removal
```

The script will **delete both** the branch and its worktree.

If you are *cd'd* into the worktree/branch you are deleting, the script will
*cd* you into the root directory of the bare repository.

### Comparison with vanilla `git-worktree`

Next commands should be issued to achieve the same functionality described above when
`git-worktree-wrapper` is not installed:

```sh
cd /path/to/the/root/of/the/bare/repository
git worktree remove new_branch
git branch -d new_branch # or -D to force removal
```

