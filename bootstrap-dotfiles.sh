#!/usr/bin/env bash
set -euo pipefail

export BACKUP_DIR="$HOME/.config-backup"

if [ "$#" -eq 0 ]; then
  echo "Unknown arguments" >&2
  echo "Usage: $0 <all/nvim/clone>:" >&2
  exit 2
fi

if [ $1 == "clone" ]; then
  echo "cloning repo"
  exit 0
fi

if [ ! -d "$HOME/dotfiles" ]; then
  git clone --bare git@github.com:ReeceYankey/dotfiles.git "$HOME/dotfiles"
else
  echo "Dotfiles already cloned. You may want to delete it if you're having issues. Skipping..."
fi

function config {
   /usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $@
}
config config status.showUntrackedFiles no

if [ $1 == "clone" ]; then
  echo "adding config alias to .bashrc"
  if grep "alias config" $HOME/.bashrc; then
    echo "config alias already in .bashrc"
  else
    echo 'alias config="/usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"' >> .bashrc
  fi
  exit 0
fi

if [ $1 == "nvim" ]; then
  echo "Installing nvim config"
  # do I clone my separate repo or merge that repo with this repo?
  exit 0
fi

if [ $1 == "all" ]; then
  echo "Installing all config files..."
  
  if config checkout; then
    echo "Checked out config."
  else
    echo "Backing up pre-existing dot files to $BACKUP_DIR"
    config ls-tree --full-tree -r --name-only HEAD | xargs -I {} sh -c ' 
    if [ -e "$HOME/{}" ]; then 
      mkdir -p "$BACKUP_DIR/$(dirname "{}")"
      mv "$HOME/{}" "$BACKUP_DIR/{}" 
      echo "moved $HOME/{} -> $BACKUP_DIR/{}"
    fi
    '
    config checkout
    echo "Checked out config."
  fi;
  exit 0
fi

