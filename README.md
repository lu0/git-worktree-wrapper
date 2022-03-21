# git-worktree-wrapper

Wrapper script to easily execute common git-worktree commands.

This script works kind of like a pre hook for checkout/switch/branch to
create, switch and delete worktrees by using only widely known commands.


## Installation

Clone this repository, try with a bare clone!

```sh
git clone --bare https://github.com/lu0/git-worktree-wrapper
cd git-worktree-wrapper.git
git worktree add master && cd master
```

Add the `git-wrapper-script` to your local `PATH`

```sh
ln -srf git-worktree-wrapper.sh ~/.local/bin/git-worktree-wrapper
```

Install [my modified fork of
complete_alias](https://github.com/lu0/complete-alias).

```sh
sudo apt install bash-completion
git clone https://github.com/lu0/complete-alias
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

### Prerequisites

Set the `EDITOR` environment variable in your `~/.bashrc`. The script will try
to open worktrees using this editor. Set `NO_GIT_WORKTREE_EDITOR=1` to handle
your editor workspaces manually.

```sh
# Example using vscode
export EDITOR=code
```

### Create a new worktree

This will also create a new branch.

```sh
git checkout [-b|-B] another_branch
```

### Open an existing worktree

This can be executed even if the current directory is the root of the bare
repository.

```sh
git checkout master
```

### Delete a worktree

This will also delete the branch.

```sh
git branch [-d|-D] another_branch
```
