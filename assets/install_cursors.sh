#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/cursors"
TARGET_DIR="${HOME}/.icons"

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "error: cursor source directory not found: $SOURCE_DIR" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

shopt -s nullglob
for theme in "$SOURCE_DIR"/*/; do
  name="$(basename "$theme")"
  link="$TARGET_DIR/$name"

  if [[ -L "$link" && "$(readlink "$link")" == "$theme" ]]; then
    echo "up to date: $name"
    continue
  fi

  if [[ -e "$link" || -L "$link" ]]; then
    echo "replacing existing: $link"
    rm -rf "$link"
  fi

  ln -s "$theme" "$link"
  echo "linked: $name -> $link"
done

echo "cursor themes installed to $TARGET_DIR"
