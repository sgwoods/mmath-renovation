#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_PUBLIC_DIR="${HOME}/Projects/public"
DEFAULT_UI_DIR="${HOME}/Projects/abtweak-experiments-ui"
ICLOUD_INTAKE="${HOME}/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/mmath-renovation-intake"

SKIP_VALIDATION=0
RUN_PUBLIC_DRILL=0
VALIDATE_UI=0
PUBLIC_DIR="${PUBLIC_PAGES_DIR:-$DEFAULT_PUBLIC_DIR}"
UI_DIR="${MMATH_UI_DIR:-$DEFAULT_UI_DIR}"

usage() {
  cat <<'EOF'
Usage:
  bash scripts/start-codex-new-mac.sh [options]

Options:
  --skip-validation     Skip the repo-local validation spine
  --run-public-drill    Run release snapshot + public sync drill with cleanup
  --validate-ui         Run npm install/build in the hosted UI repo
  --public-dir DIR      Companion public repo path
  --ui-dir DIR          Companion hosted UI repo path
  --help                Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-validation)
      SKIP_VALIDATION=1
      shift
      ;;
    --run-public-drill)
      RUN_PUBLIC_DRILL=1
      shift
      ;;
    --validate-ui)
      VALIDATE_UI=1
      shift
      ;;
    --public-dir)
      PUBLIC_DIR="$2"
      shift 2
      ;;
    --ui-dir)
      UI_DIR="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_cmd() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing required command: $cmd" >&2
    exit 1
  fi
}

repo_dirty() {
  local repo_path="$1"
  if [[ ! -d "$repo_path/.git" ]]; then
    return 1
  fi
  [[ -n "$(git -C "$repo_path" status --short --untracked-files=normal)" ]]
}

require_clean_repo() {
  local repo_path="$1"
  local repo_label="$2"
  if repo_dirty "$repo_path"; then
    echo "$repo_label is dirty: $repo_path" >&2
    exit 1
  fi
}

restore_public_drill_outputs() {
  local version
  version="$(tr -d ' \n\r' <"$ROOT_DIR/VERSION")"

  git -C "$ROOT_DIR" restore \
    "releases/$version/manifest.json" \
    "releases/$version/status.json" \
    "releases/$version/benchmark-status.md" \
    "releases/$version/current-status.md" \
    "releases/$version/release-summary.md"

  git -C "$PUBLIC_DIR" restore \
    data/projects/mmath-renovation.json \
    mmath-renovation-release-dashboard.html \
    mmath-renovation.html \
    mmath-renovation-remote-experiments.html \
    mmath-thesis.pdf \
    mmath-thesis.ps
}

summarize_validation() {
  local status_json="$1"
  local blocks_json="$2"
  local hanoi_json="$3"

  python3 - "$status_json" "$blocks_json" "$hanoi_json" <<'PY'
import json
import sys

status = json.load(open(sys.argv[1], encoding="utf-8"))
blocks = json.load(open(sys.argv[2], encoding="utf-8"))
hanoi = json.load(open(sys.argv[3], encoding="utf-8"))

families = status.get("families", [])
reproduced = sum(1 for item in families if item.get("status") == "reproduced")
partial = sum(1 for item in families if item.get("status") == "partially-reproduced")
open_count = sum(1 for item in families if item.get("status") == "open")

print("Validation summary:")
print(f"  reproduced families: {reproduced}")
print(f"  partially reproduced families: {partial}")
print(f"  open families: {open_count}")
print(f"  blocks-sussman-abtweak: {blocks.get('solution_type')} len={blocks.get('solution_len')} cost={blocks.get('solution_cost')}")
print(f"  hanoi3-abtweak: {hanoi.get('solution_type')} len={hanoi.get('solution_len')} cost={hanoi.get('solution_cost')}")
PY
}

echo "== MMath Renovation new-Mac startup =="
echo "Repo root: $ROOT_DIR"

require_cmd git
require_cmd python3
require_cmd sbcl
require_cmd perl

if [[ "$VALIDATE_UI" -eq 1 ]]; then
  require_cmd node
  require_cmd npm
fi

if [[ "$RUN_PUBLIC_DRILL" -eq 1 ]]; then
  require_cmd pdf2ps
fi

mkdir -p "$ICLOUD_INTAKE"
echo "Ensured iCloud intake path: $ICLOUD_INTAKE"

echo "Branch state:"
git -C "$ROOT_DIR" status -sb

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/mmath-startup.XXXXXX")"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

if [[ "$SKIP_VALIDATION" -eq 0 ]]; then
  echo "== Running supported validation spine =="
  sh "$ROOT_DIR/scripts/abtweak-experiments.sh" status --json >"$TMP_DIR/status.json"
  sh "$ROOT_DIR/scripts/abtweak-experiments.sh" run blocks-sussman-abtweak --json >"$TMP_DIR/blocks.json"
  sh "$ROOT_DIR/scripts/abtweak-experiments.sh" run hanoi3-abtweak --json >"$TMP_DIR/hanoi3.json"
  summarize_validation "$TMP_DIR/status.json" "$TMP_DIR/blocks.json" "$TMP_DIR/hanoi3.json"
fi

if [[ "$VALIDATE_UI" -eq 1 ]]; then
  echo "== Running hosted UI install/build validation =="
  if [[ ! -d "$UI_DIR/.git" ]]; then
    echo "Hosted UI repo is missing: $UI_DIR" >&2
    exit 1
  fi
  require_clean_repo "$UI_DIR" "Hosted UI repo before validation"
  npm install --prefix "$UI_DIR"
  npm run build --prefix "$UI_DIR"
  require_clean_repo "$UI_DIR" "Hosted UI repo after validation"
fi

if [[ "$RUN_PUBLIC_DRILL" -eq 1 ]]; then
  echo "== Running release/public continuity drill =="
  if [[ ! -d "$PUBLIC_DIR/.git" ]]; then
    echo "Public repo is missing: $PUBLIC_DIR" >&2
    exit 1
  fi
  require_clean_repo "$ROOT_DIR" "Main repo before public drill"
  require_clean_repo "$PUBLIC_DIR" "Public repo before public drill"
  PUBLIC_PAGES_DIR="$PUBLIC_DIR" sh "$ROOT_DIR/scripts/create-release-snapshot.sh"
  restore_public_drill_outputs
  require_clean_repo "$ROOT_DIR" "Main repo after public drill cleanup"
  require_clean_repo "$PUBLIC_DIR" "Public repo after public drill cleanup"
fi

cat <<EOF

Startup complete.

Preferred active clone model:
  normal non-iCloud repo clone

Repo-local intake handoff:
  $ROOT_DIR/intake

Preferred iCloud intake path:
  $ICLOUD_INTAKE

Optional companion repos:
  public: $PUBLIC_DIR
  hosted UI: $UI_DIR
EOF
