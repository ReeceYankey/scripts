#!/usr/bin/env bash
set -euo pipefail

export BACKUP_DIR="$HOME/.config-backup"

if [ ! -d "$HOME/dotfiles" ]; then
  git clone --bare git@github.com:ReeceYankey/dotfiles.git "$HOME/dotfiles"
fi

function config {
   /usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $@
}

config config status.showUntrackedFiles no

if config checkout; then
  echo "Checked out config."
else
  echo "Backing up pre-existing dot files to .config-backup"
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

