#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

DEFAULT_WORKSPACE_ROOT="$HOME/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods"
WORKSPACE_ROOT="${WORKSPACE_ROOT:-$DEFAULT_WORKSPACE_ROOT}"
PUBLIC_DIR=""
UI_DIR=""
FULL_DRILL=1
SKIP_SUPPORTING_CLONES=0
SKIP_UI_BUILD=0
ALLOW_DIRTY=0
TMP_DIR=""

PUBLIC_REMOTE_URL="${PUBLIC_REMOTE_URL:-https://github.com/sgwoods/public.git}"
UI_REMOTE_URL="${UI_REMOTE_URL:-https://github.com/sgwoods/abtweak-experiments-ui.git}"

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Legacy iCloud-centered bootstrap and validation drill for the AbTweak
continuation workspace on a new Mac.

Preferred current migration path:
  bash scripts/bootstrap-project-macos.sh

Use this legacy script only when you specifically want to recreate the older
iCloud-backed continuity drill.

Options:
  --workspace-root PATH   Canonical workspace root
                          (default: $DEFAULT_WORKSPACE_ROOT)
  --skip-supporting-clones
                          Do not clone/fetch the sibling public/UI repos
  --skip-ui-build         Skip npm install/build for the hosted UI repo
  --skip-full-drill       Skip the release-snapshot/public-sync continuity drill
  --allow-dirty           Allow already-dirty git repos during validation
  --help                  Show this help

Expected canonical layout:
  <workspace-root>/mmath-renovation
  <workspace-root>/public
  <workspace-root>/abtweak-experiments-ui

Typical new-machine flow:
  1. Clone sgwoods/mmath-renovation into <workspace-root>/mmath-renovation
  2. cd into that clone
  3. Run this script
EOF
}

log() {
  printf '%s\n' "$*"
}

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || missing_commands="$missing_commands $1"
}

repo_dirty() {
  repo_path=$1
  if ! git -C "$repo_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    return 1
  fi
  if [ -n "$(git -C "$repo_path" status --short --untracked-files=normal)" ]; then
    return 0
  fi
  return 1
}

require_clean_repo() {
  repo_path=$1
  repo_label=$2

  if [ "$ALLOW_DIRTY" -eq 1 ]; then
    return 0
  fi

  if repo_dirty "$repo_path"; then
    fail "$repo_label is dirty: $repo_path"
  fi
}

ensure_repo() {
  repo_label=$1
  repo_path=$2
  repo_url=$3

  if [ -d "$repo_path/.git" ]; then
    log "Refreshing $repo_label at $repo_path"
    git -C "$repo_path" fetch --all --prune
    return 0
  fi

  if [ -e "$repo_path" ]; then
    fail "$repo_label path exists but is not a git repo: $repo_path"
  fi

  log "Cloning $repo_label into $repo_path"
  git clone "$repo_url" "$repo_path"
}

restore_full_drill_outputs() {
  version=$(tr -d ' \n\r' <"$REPO_ROOT/VERSION")

  if git -C "$REPO_ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$REPO_ROOT" restore \
      "releases/$version/manifest.json" \
      "releases/$version/status.json" \
      "releases/$version/benchmark-status.md" \
      "releases/$version/current-status.md" \
      "releases/$version/release-summary.md"
  fi

  if git -C "$PUBLIC_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git -C "$PUBLIC_DIR" restore \
      data/projects/mmath-renovation.json \
      mmath-renovation-release-dashboard.html \
      mmath-renovation.html \
      mmath-renovation-remote-experiments.html \
      mmath-thesis.pdf \
      mmath-thesis.ps
  fi
}

while [ $# -gt 0 ]; do
  case "$1" in
    --workspace-root)
      [ $# -ge 2 ] || fail "--workspace-root requires a path"
      WORKSPACE_ROOT=$2
      shift 2
      ;;
    --skip-supporting-clones)
      SKIP_SUPPORTING_CLONES=1
      shift
      ;;
    --skip-ui-build)
      SKIP_UI_BUILD=1
      shift
      ;;
    --skip-full-drill)
      FULL_DRILL=0
      shift
      ;;
    --allow-dirty)
      ALLOW_DIRTY=1
      shift
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown option: $1"
      ;;
  esac
done

PUBLIC_DIR="$WORKSPACE_ROOT/public"
UI_DIR="$WORKSPACE_ROOT/abtweak-experiments-ui"
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mmath-bootstrap.XXXXXX")
trap cleanup EXIT INT TERM

missing_commands=""
require_command git
require_command python3
require_command sbcl
require_command perl

if [ "$SKIP_UI_BUILD" -eq 0 ]; then
  require_command node
  require_command npm
fi

if [ "$FULL_DRILL" -eq 1 ]; then
  require_command pdf2ps
fi

if [ -n "$missing_commands" ]; then
  cat >&2 <<EOF
Missing required commands:$missing_commands

Suggested installs on macOS:
  brew install sbcl gh ghostscript node

git, python3, and perl should also be available in PATH before continuing.
EOF
  exit 1
fi

log "Canonical workspace root: $WORKSPACE_ROOT"
log "Main repo in use: $REPO_ROOT"

if [ ! -d "$WORKSPACE_ROOT" ]; then
  log "Creating workspace root: $WORKSPACE_ROOT"
  mkdir -p "$WORKSPACE_ROOT"
fi

if [ "$SKIP_SUPPORTING_CLONES" -eq 0 ]; then
  ensure_repo "public repo" "$PUBLIC_DIR" "$PUBLIC_REMOTE_URL"
  ensure_repo "hosted UI repo" "$UI_DIR" "$UI_REMOTE_URL"
fi

if [ ! -d "$PUBLIC_DIR/.git" ]; then
  fail "Public repo is missing at $PUBLIC_DIR"
fi

if [ "$SKIP_UI_BUILD" -eq 0 ] && [ ! -d "$UI_DIR/.git" ]; then
  fail "Hosted UI repo is missing at $UI_DIR"
fi

require_clean_repo "$REPO_ROOT" "Main repo"
require_clean_repo "$PUBLIC_DIR" "Public repo"
if [ "$SKIP_UI_BUILD" -eq 0 ]; then
  require_clean_repo "$UI_DIR" "Hosted UI repo"
fi

log "Running harness validation"
sh "$REPO_ROOT/scripts/abtweak-experiments.sh" status --json >"$TMP_DIR/status.json"

if [ "$SKIP_UI_BUILD" -eq 0 ]; then
  log "Running hosted UI install/build validation"
  npm install --prefix "$UI_DIR"
  npm run build --prefix "$UI_DIR"
fi

if [ "$FULL_DRILL" -eq 1 ]; then
  log "Running release-snapshot/public-sync continuity drill"
  PUBLIC_PAGES_DIR="$PUBLIC_DIR" sh "$REPO_ROOT/scripts/create-release-snapshot.sh"
  log "Restoring expected generated outputs after drill"
  restore_full_drill_outputs
fi

if [ "$SKIP_UI_BUILD" -eq 0 ]; then
  require_clean_repo "$UI_DIR" "Hosted UI repo after validation"
fi
if [ "$FULL_DRILL" -eq 1 ]; then
  require_clean_repo "$REPO_ROOT" "Main repo after drill cleanup"
  require_clean_repo "$PUBLIC_DIR" "Public repo after drill cleanup"
fi

cat <<EOF

Bootstrap validation succeeded.

Canonical workspace:
  $WORKSPACE_ROOT

Validated surfaces:
  - main harness status
EOF

if [ "$SKIP_UI_BUILD" -eq 0 ]; then
  cat <<EOF
  - hosted UI npm install/build
EOF
fi

if [ "$FULL_DRILL" -eq 1 ]; then
  cat <<EOF
  - release snapshot + public sync continuity drill
  - cleanup back to clean git state after the drill
EOF
fi

cat <<EOF

External continuity that remains out-of-band:
  - the Vercel project bound to sgwoods/abtweak-experiments-ui
  - Vercel environment variables:
    GITHUB_TOKEN
    GITHUB_OWNER
    GITHUB_REPO
    GITHUB_WORKFLOW_SINGLE
    GITHUB_WORKFLOW_SET

Recommended next step on the new machine:
  Open Codex in:
    $REPO_ROOT
  Or, if you cloned mmath-renovation into the canonical root:
    $WORKSPACE_ROOT/mmath-renovation
EOF
