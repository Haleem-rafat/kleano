#!/usr/bin/env bash
# Copies the shared design system (lib/core/design/) from the User app (source
# of truth) into the Biker app, rewriting the package name.
#   tool/sync_design.sh          sync
#   tool/sync_design.sh --check  exit 1 (and list files) if the copies differ
set -euo pipefail

here="$(cd "$(dirname "$0")/.." && pwd)"
src="$here/lib/core/design"
dst="$here/../Kleano-Biker-Flutter-dev/lib/core/design"

render() { # $1 = output dir
  mkdir -p "$1"
  rsync -a --delete "$src/" "$1/"
  find "$1" -name '*.dart' -exec sed -i '' 's#package:thewasher/#package:thewhsherbiker/#g' {} +
}

if [[ "${1:-}" == "--check" ]]; then
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  render "$tmp"
  if diff -rq "$tmp" "$dst"; then
    echo "design system in sync"
  else
    echo "design system out of sync: run tool/sync_design.sh" >&2
    exit 1
  fi
else
  render "$dst"
  echo "synced $src -> $dst"
fi
