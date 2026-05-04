#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)

VERSION_FILE="$REPO_ROOT/VERSION"
CHANGELOG_FILE="$REPO_ROOT/CHANGELOG.md"
CURRENT_STATUS_FILE="$REPO_ROOT/docs/current-status.md"
RELEASES_DIR="$REPO_ROOT/releases"
HARNESS_SCRIPT="$REPO_ROOT/scripts/abtweak-experiments.sh"
SYNC_PUBLIC_PAGES_SCRIPT="$REPO_ROOT/scripts/sync-public-release-pages.sh"
THESIS_GALLERY_SCRIPT="$REPO_ROOT/scripts/generate-thesis-side-by-side.py"
THESIS_PDF="$REPO_ROOT/publications/1991 mmath thesis final.pdf"
THESIS_PS="$REPO_ROOT/publications/1991 mmath thesis final.ps"

if [ ! -f "$VERSION_FILE" ]; then
  echo "Missing VERSION file: $VERSION_FILE" >&2
  exit 1
fi

version=$(tr -d ' \n\r' <"$VERSION_FILE")

if [ -z "$version" ]; then
  echo "VERSION file is empty" >&2
  exit 1
fi

if [ -f "$THESIS_PDF" ] && [ ! -f "$THESIS_PS" ] && command -v pdf2ps >/dev/null 2>&1; then
  pdf2ps "$THESIS_PDF" "$THESIS_PS"
fi

if [ -f "$THESIS_GALLERY_SCRIPT" ] && [ -f "$THESIS_PDF" ]; then
  python3 "$THESIS_GALLERY_SCRIPT"
fi

release_dir="$RELEASES_DIR/$version"
mkdir -p "$release_dir"

commit=$(git -C "$REPO_ROOT" rev-parse HEAD)
branch=$(git -C "$REPO_ROOT" branch --show-current)
timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
status_json_file="$release_dir/status.json"
benchmark_status_file="$release_dir/benchmark-status.md"
release_summary_file="$release_dir/release-summary.md"
manifest_file="$release_dir/manifest.json"

sh "$HARNESS_SCRIPT" status --json >"$status_json_file"
sh "$HARNESS_SCRIPT" report benchmark-status >"$benchmark_status_file"
cp "$CURRENT_STATUS_FILE" "$release_dir/current-status.md"

cat >"$release_summary_file" <<EOF
# Release Summary: $version

- Timestamp (UTC): \`$timestamp\`
- Git branch: \`$branch\`
- Source git commit captured by snapshot: \`$commit\`
- Version: \`$version\`

This release snapshot captures the checked-in documentation and benchmark
status for the current AbTweak restoration state.

Included files:

- \`manifest.json\`
- \`status.json\`
- \`benchmark-status.md\`
- \`current-status.md\`

Primary references:

- [CHANGELOG](../../CHANGELOG.md)
- [Release process](../../docs/release-process.md)
- [Current status](../../docs/current-status.md)
EOF

cat >"$manifest_file" <<EOF
{
  "version": "$version",
  "timestamp_utc": "$timestamp",
  "git_branch": "$branch",
  "git_commit": "$commit",
  "version_file": "VERSION",
  "changelog_file": "CHANGELOG.md",
  "current_status_file": "docs/current-status.md",
  "generated_files": [
    "releases/$version/manifest.json",
    "releases/$version/status.json",
    "releases/$version/benchmark-status.md",
    "releases/$version/current-status.md",
    "releases/$version/release-summary.md"
  ]
}
EOF

if [ -f "$SYNC_PUBLIC_PAGES_SCRIPT" ]; then
  sh "$SYNC_PUBLIC_PAGES_SCRIPT"
fi

echo "Release snapshot generated: $release_dir"
