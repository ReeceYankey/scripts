#!/usr/bin/env bash
set -euo pipefail

if [ ! -d "$HOME/dotfiles" ]; then
  git clone --bare git@github.com:ReeceYankey/dotfiles.git "$HOME/dotfiles"
fi

function config {
   /usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME $@
}

config config status.showUntrackedFiles no

if config checkout; then
  echo "Checked out config.";
else
  echo "Backing up pre-existing dot files to .config-backup";
  mkdir -p .config-backup
  config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I {} mv {} .config-backup/{}
  config checkout
fi;

