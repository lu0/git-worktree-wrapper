`git-worktree-wrapper`
---

This wrapper script features an API for `git-worktree` commands
in order to easily create, switch and delete worktrees and branches of bare
repositories using widely known commands: `git checkout` and `git branch`.

Quiet built-in checkouts are made after each overridden checkout to trigger
post-checkout hooks.


Table of Contents
---

- [Installation](#installation)
  - [Wrapper script](#wrapper-script)
  - [Completion rules](#completion-rules)
- [Setup](#setup)
  - [Configure your default editor](#configure-your-default-editor)
  - [Clone a bare repository](#clone-a-bare-repository)
  - [Setup fetch rules to the remote](#setup-fetch-rules-to-the-remote)
- [Usage](#usage)
  - [Open an existing branch or worktree](#open-an-existing-branch-or-worktree)
    - [Comparison with vanilla `git-worktree`](#comparison-with-vanilla-git-worktree)
  - [Create a new branch or worktree](#create-a-new-branch-or-worktree)
    - [Comparison with vanilla `git-worktree`](#comparison-with-vanilla-git-worktree-1)
  - [Delete a branch and its worktree](#delete-a-branch-and-its-worktree)
    - [Comparison with vanilla `git-worktree`](#comparison-with-vanilla-git-worktree-2)

# Installation

## Wrapper script

Clone this repository

```sh
git clone https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper
```

Link `git-wrapper-script` to your local `PATH`

```sh
ln -srf git-worktree-wrapper.sh ~/.local/bin/git-worktree-wrapper
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
[my modified fork of complete_alias](https://github.com/lu0/complete-alias).

```sh
sudo apt install bash-completion
git clone https://github.com/lu0/complete-alias
cd complete-alias/
echo ". $PWD/complete_alias" >> ~/.bash_completion
```

Inherit `git`'s completion rules by pasting the following in your `~/.bashrc` or
`~/.bash_aliases`

```sh
alias git="source git-worktree-wrapper"
complete -F _complete_alias git
_complete_alias_overrides() {
    echo git git
}
```


# Setup

## Configure your default editor

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

## Clone a bare repository

Try it with this repo!

```sh
git clone --bare https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper.git
```

## Setup fetch rules to the remote

```sh
git config --local remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch
```


# Usage

After cloning a bare repository, you can use the following common `git checkout` and
`git branch` commands.

## Open an existing branch or worktree

Switch to branch `master` and *cd* into its worktree, **even if you are *cd'd* into
another worktree/branch**:

```sh
git checkout master
```

### Comparison with vanilla `git-worktree`

Next commands should be issued to achieve the same functionality described above when
`git-worktree-wrapper` is not installed:

If the branch exists but the worktree doesn't.
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

Create a branch `new_branch` and *cd* into its new worktree, **even if you are *cd'd* into
another worktree/branch**:

```sh
git checkout -b new_branch <from_branch (optional)>
# or use -B to force reset
```

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

Delete a branch and its worktree, **even if you are *cd'd* into the worktree/branch you want to delete**:
```sh
git branch -d new_branch # or -D to force removal
```

### Comparison with vanilla `git-worktree`

Next commands should be issued to achieve the same functionality described above when
`git-worktree-wrapper` is not installed:

```sh
cd /path/to/the/root/of/the/bare/repository
git worktree remove new_branch
git branch -d new_branch # or -D to force removal
```

