#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

PUBLIC_PAGES_DIR=${PUBLIC_PAGES_DIR:-/Users/stevenwoods/GitPages/public}
VERSION_FILE="$REPO_ROOT/VERSION"
DASHBOARD_SOURCE="$REPO_ROOT/site/mmath-renovation-release-dashboard.html"
PROJECT_PAGE_SOURCE="$REPO_ROOT/site/mmath-renovation-public-page.html"
PUBLIC_DASHBOARD="$PUBLIC_PAGES_DIR/mmath-renovation-release-dashboard.html"
PUBLIC_PROJECT_PAGE="$PUBLIC_PAGES_DIR/mmath-renovation.html"
PUBLIC_STATUS_DIR="$PUBLIC_PAGES_DIR/data/projects"
PUBLIC_STATUS_FILE="$PUBLIC_STATUS_DIR/mmath-renovation.json"
TMP_DIR=""

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}

capture_status_paths() {
  output_file=$1
  git -C "$PUBLIC_PAGES_DIR" status --porcelain --untracked-files=all \
    | sed 's/^...//' \
    | sort -u >"$output_file"
}

check_newly_dirty_paths() {
  before_file=$1
  after_file=$2

  awk '
    NR == FNR { before[$0] = 1; next }
    !before[$0] { print $0 }
  ' "$before_file" "$after_file" >"$TMP_DIR/newly-dirty.txt"

  if [ ! -s "$TMP_DIR/newly-dirty.txt" ]; then
    return 0
  fi

  while IFS= read -r path; do
    case "$path" in
      mmath-renovation-release-dashboard.html|mmath-renovation.html|data/projects/mmath-renovation.json)
        ;;
      *)
        echo "Refusing to continue: sync introduced a newly dirty non-MMath path: $path" >&2
        exit 1
        ;;
    esac
  done <"$TMP_DIR/newly-dirty.txt"
}

if [ ! -d "$PUBLIC_PAGES_DIR" ]; then
  echo "Public Pages directory not found, skipping sync: $PUBLIC_PAGES_DIR"
  exit 0
fi

if [ ! -f "$VERSION_FILE" ]; then
  echo "Missing VERSION file: $VERSION_FILE" >&2
  exit 1
fi

version=$(tr -d ' \n\r' <"$VERSION_FILE")
today=$(date +"%B %d, %Y")
repo_pushed_at=$(TZ=UTC git -C "$REPO_ROOT" log -1 --date=format-local:%Y-%m-%dT%H:%M:%SZ --format=%cd)
status_generated_at=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/mmath-public-sync.XXXXXX")
trap cleanup EXIT INT TERM

mkdir -p "$PUBLIC_STATUS_DIR"

if git -C "$PUBLIC_PAGES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  capture_status_paths "$TMP_DIR/status-before.txt"
fi

cp "$DASHBOARD_SOURCE" "$PUBLIC_DASHBOARD"
cp "$PROJECT_PAGE_SOURCE" "$PUBLIC_PROJECT_PAGE"

perl -0pi -e 's/Public project note: active restoration work is underway\..*?Hanoi-4 remains the main open extension benchmark\./Public project note: active restoration work is underway. As of '"$today"', the repository is at `'"$version"'`, with exact lower-Hanoi reproduction, broad operator-style benchmark coverage, and a dedicated release dashboard tracking the road to `1.0.0`. Hanoi-4 remains the main open extension benchmark./s' "$PUBLIC_PROJECT_PAGE"

cat >"$PUBLIC_STATUS_FILE" <<EOF
{
  "schema_version": "1.0",
  "project_id": "mmath-renovation",
  "active": true,
  "display_name": "Masters of Mathematics renovation project",
  "project_page_path": "mmath-renovation.html",
  "repo_url": "https://github.com/sgwoods/mmath-renovation",
  "dashboard_url": "https://sgwoods.github.io/public/mmath-renovation-release-dashboard.html",
  "experience_url": null,
  "repo_pushed_at": "$repo_pushed_at",
  "status_generated_at": "$status_generated_at",
  "status_label": "Current release",
  "status_value": "$version",
  "focus_label": "Current focus",
  "focus_value": "Hanoi-4 extension benchmark"
}
EOF

if git -C "$PUBLIC_PAGES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  capture_status_paths "$TMP_DIR/status-after.txt"
  check_newly_dirty_paths "$TMP_DIR/status-before.txt" "$TMP_DIR/status-after.txt"
fi

echo "Synced public release pages to: $PUBLIC_PAGES_DIR"
