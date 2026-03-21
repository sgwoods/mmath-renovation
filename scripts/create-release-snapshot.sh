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

if [ ! -f "$VERSION_FILE" ]; then
  echo "Missing VERSION file: $VERSION_FILE" >&2
  exit 1
fi

version=$(tr -d ' \n\r' <"$VERSION_FILE")

if [ -z "$version" ]; then
  echo "VERSION file is empty" >&2
  exit 1
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

- [CHANGELOG](/Users/stevenwoods/mmath-renovation/CHANGELOG.md)
- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
EOF

cat >"$manifest_file" <<EOF
{
  "version": "$version",
  "timestamp_utc": "$timestamp",
  "git_branch": "$branch",
  "git_commit": "$commit",
  "version_file": "/Users/stevenwoods/mmath-renovation/VERSION",
  "changelog_file": "/Users/stevenwoods/mmath-renovation/CHANGELOG.md",
  "current_status_file": "/Users/stevenwoods/mmath-renovation/docs/current-status.md",
  "generated_files": [
    "/Users/stevenwoods/mmath-renovation/releases/$version/manifest.json",
    "/Users/stevenwoods/mmath-renovation/releases/$version/status.json",
    "/Users/stevenwoods/mmath-renovation/releases/$version/benchmark-status.md",
    "/Users/stevenwoods/mmath-renovation/releases/$version/current-status.md",
    "/Users/stevenwoods/mmath-renovation/releases/$version/release-summary.md"
  ]
}
EOF

if [ -f "$SYNC_PUBLIC_PAGES_SCRIPT" ]; then
  sh "$SYNC_PUBLIC_PAGES_SCRIPT"
fi

echo "Release snapshot generated: $release_dir"
