#!/usr/bin/env bash
set -euo pipefail

# Build and package authentic Make.fun transcripts, keeping secrets out of Git.
if [[ $# -lt 3 ]]; then
  printf 'Usage: %s <kit-dir> <repo-dir> <output-bundle> [bundle options...]\n' "$0" >&2
  exit 2
fi
kit_dir=$(realpath "$1")
repo_dir=$(realpath "$2")
out=$3
shift 3
mkdir -p "$repo_dir/.makefun/transcripts"
case "$out" in
  /*) bundle_path=$out ;;
  *) bundle_path="$repo_dir/.makefun/transcripts/$out" ;;
esac
case "$bundle_path" in
  "$repo_dir"/.makefun/transcripts/*) ;;
  *) printf 'Bundle output must be inside %s/.makefun/transcripts\n' "$repo_dir" >&2; exit 2 ;;
esac
node "$kit_dir/cli/makefun.mjs" bundle --repo "$repo_dir" --out "$bundle_path" "$@"
node "$kit_dir/cli/makefun.mjs" check "$bundle_path"
sha256sum "$bundle_path" | tee "$bundle_path.sha256"
printf 'Saved transcript bundle: %s\n' "$bundle_path"
