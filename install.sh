#!/usr/bin/env bash
#
# Symlink every dotfiles package into $HOME using GNU Stow.
#
# Usage:
#   ./install.sh                 # link all packages
#   ./install.sh claude ghostty  # link only the named packages
#   ./install.sh --adopt         # pull existing files in $HOME into the repo, then link
#   ./install.sh --delete        # unlink packages
#   ./install.sh --dry-run       # show what would happen, change nothing
#
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${STOW_TARGET:-$HOME}"

STOW_FLAGS=()
PACKAGES=()
ACTION="--restow"

for arg in "$@"; do
  case "$arg" in
    --adopt)   STOW_FLAGS+=(--adopt) ;;
    --dry-run) STOW_FLAGS+=(--no --verbose) ;;
    --delete)  ACTION="--delete" ;;
    -h|--help) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)        echo "unknown option: $arg" >&2; exit 1 ;;
    *)         PACKAGES+=("$arg") ;;
  esac
done

if ! command -v stow >/dev/null 2>&1; then
  echo "GNU Stow is not installed."
  if command -v brew >/dev/null 2>&1; then
    echo "Installing with Homebrew..."
    brew install stow
  else
    echo "Install it first (e.g. 'brew install stow' or 'sudo apt install stow')." >&2
    exit 1
  fi
fi

# A package is any top-level directory that isn't hidden.
if [ ${#PACKAGES[@]} -eq 0 ]; then
  while IFS= read -r dir; do
    PACKAGES+=("$(basename "$dir")")
  done < <(find "$DOTFILES_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '.*' | sort)
fi

if [ ${#PACKAGES[@]} -eq 0 ]; then
  echo "No packages found in $DOTFILES_DIR" >&2
  exit 1
fi

echo "dotfiles: $DOTFILES_DIR"
echo "target:   $TARGET"
echo "packages: ${PACKAGES[*]}"
echo

stow --dir "$DOTFILES_DIR" --target "$TARGET" "$ACTION" "${STOW_FLAGS[@]}" "${PACKAGES[@]}"

echo
echo "Done."
