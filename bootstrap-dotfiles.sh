#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${HOME}/.config-backup"
DOTFILES_DIR="${HOME}/dotfiles"
REPO_URL="git@github.com:ReeceYankey/dotfiles.git"

usage() {
  echo "Usage: $0 <clone|nvim|all>" >&2
  exit 2
}

config() {
  /usr/bin/env git --git-dir="${DOTFILES_DIR}/" --work-tree="${HOME}" "$@"
}

ensure_repo_cloned() {
  if [ -d "${DOTFILES_DIR}" ]; then
    echo "Dotfiles repo already exists at ${DOTFILES_DIR}. Skipping clone."
  else
    echo "Cloning dotfiles repo..."
    git clone --bare "${REPO_URL}" "${DOTFILES_DIR}"
  fi
  config config status.showUntrackedFiles no
}

add_alias() {
  local alias_line='alias config="/usr/bin/env git --git-dir=$HOME/dotfiles/ --work-tree=$HOME"'

  if grep -Fxq "$alias_line" "${HOME}/.bashrc"; then
    echo "config alias already present in .bashrc"
  else
    echo "Adding config alias to .bashrc"
    echo "$alias_line" >> "${HOME}/.bashrc"
  fi
}

backup_conflicts() {
  echo "Backing up pre-existing dotfiles to ${BACKUP_DIR}"

  config ls-tree --full-tree -r --name-only HEAD | while read -r file; do
    target="${HOME}/${file}"
    backup="${BACKUP_DIR}/${file}"

    if [ -e "$target" ] && [ ! -L "$target" ]; then
      mkdir -p "$(dirname "$backup")"
      mv "$target" "$backup"
      echo "Moved $target → $backup"
    fi
  done
}

install_all() {
  echo "Installing all config files..."

  if config checkout; then
    echo "Checked out config."
  else
    backup_conflicts
    config checkout
    echo "Checked out config after backing up conflicts."
  fi

}

install_nvim() {
  echo "Installing Neovim config..."
  echo "!Not implemented!"
}

# ------------------------
# Main
# ------------------------

if [ "$#" -ne 1 ]; then
  usage
fi

case "$1" in
  clone)
    ensure_repo_cloned
    add_alias
    ;;

  nvim)
    ensure_repo_cloned
    install_nvim
    ;;

  all)
    ensure_repo_cloned
    install_all
    ;;

  *)
    usage
    ;;
esac

