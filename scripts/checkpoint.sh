#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./scripts/checkpoint.sh ["message"]

Creates a local Git checkpoint commit.

Behavior:
  - Commits all current changes with `git add -A`.
  - Creates an empty commit when the worktree is clean.
  - Never pushes to any remote.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  echo "checkpoint: git is not installed or not available in PATH." >&2
  exit 1
fi

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "checkpoint: current directory is not inside a Git repository." >&2
  echo "checkpoint: use a git clone, or run git init before creating checkpoints." >&2
  exit 1
fi

if ! git config user.name >/dev/null || ! git config user.email >/dev/null; then
  echo "checkpoint: Git user.name and user.email must be configured before committing." >&2
  echo "checkpoint: run:" >&2
  echo "  git config user.name \"Your Name\"" >&2
  echo "  git config user.email \"you@example.com\"" >&2
  exit 1
fi

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

message="${1:-}"
if [[ -z "$message" ]]; then
  message="local checkpoint $(date '+%Y-%m-%d %H:%M:%S')"
fi

case "$message" in
  checkpoint:*)
    commit_message="$message"
    ;;
  *)
    commit_message="checkpoint: $message"
    ;;
esac

if [[ -n "$(git status --porcelain)" ]]; then
  git add -A
  git commit -m "$commit_message"
else
  git commit --allow-empty -m "$commit_message"
fi

echo "checkpoint: created $(git rev-parse --short HEAD)"
