# git-worktree-wrapper

Wrapper script to easily execute common git-worktree commands.

This script works kind of like a pre hook for checkout/switch/branch to
create, switch and delete worktrees by using only widely known commands.

- [git-worktree-wrapper](#git-worktree-wrapper)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Configure default editor](#configure-default-editor)
    - [Clone a bare repository](#clone-a-bare-repository)
    - [Setup fetch to remote](#setup-fetch-to-remote)
    - [Create initial worktree](#create-initial-worktree)
    - [Create a new branch/worktree](#create-a-new-branchworktree)
    - [Open an existing worktree](#open-an-existing-worktree)
    - [Delete a branch/worktree](#delete-a-branchworktree)

## Installation

Clone this repository, try with a bare clone!

```sh
git clone https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper
```

Add the `git-wrapper-script` to your local `PATH`

```sh
ln -srf git-worktree-wrapper.sh ~/.local/bin/git-worktree-wrapper
```

Install [my modified fork of complete_alias](https://github.com/lu0/complete-alias).

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

## Usage

### Configure default editor

Set the environment variable `EDITOR` in your `~/.bashrc`,
`git-worktree-wrapper` will try to open worktree directories using this editor.

```sh
# Example using vscode
export EDITOR=code
```

Or set `NO_GIT_WORKTREE_EDITOR=1` to disable usage of editors.

```sh
export NO_GIT_WORKTREE_EDITOR=1
```

### Clone a bare repository

Try with this repo!

```sh
git clone --bare https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper.git
```

### Setup fetch to remote

```sh
git config --local remote.origin.fetch +refs/heads/*:refs/remotes/origin/*
git fetch
```

### Create initial worktree

```sh
git checkout -B $(git branch --show-current)
```

### Create a new branch/worktree

```sh
git checkout [-b|-B] another_branch
```

### Open an existing worktree

```sh
git checkout master
```

### Delete a branch/worktree

This will remove both the branch and the worktree.

```sh
git branch [-d|-D] another_branch
```
