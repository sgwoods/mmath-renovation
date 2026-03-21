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
PUBLIC_INDEX="$PUBLIC_PAGES_DIR/index.html"

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
latest_commit_subject=$(git -C "$REPO_ROOT" log -1 --pretty=%s)

cp "$DASHBOARD_SOURCE" "$PUBLIC_DASHBOARD"
cp "$PROJECT_PAGE_SOURCE" "$PUBLIC_PROJECT_PAGE"

perl -0pi -e 's/Repository work last updated: .*?\./Repository work last updated: '"$today"'\./s' "$PUBLIC_INDEX"
perl -0pi -e 's#(<a href="mmath-renovation.html">Masters of Mathematics renovation project</a>\s*<span class="label">)Public project page for reviving the AbTweak thesis code and documentation\..*?(</span>)#${1}Public project page for reviving the AbTweak thesis code and documentation. Last repo update: '"$today"'. Current release: '"$version"'. Dashboard: mmath-renovation-release-dashboard.html.${2}#s' "$PUBLIC_INDEX"

perl -0pi -e 's/Public project note: active restoration work is underway\..*?Hanoi-4 remains the main open extension benchmark\./Public project note: active restoration work is underway. As of '"$today"', the repository is at `'"$version"'`, with exact lower-Hanoi reproduction, broad operator-style benchmark coverage, and a dedicated release dashboard tracking the road to `1.0.0`. Hanoi-4 remains the main open extension benchmark./s' "$PUBLIC_PROJECT_PAGE"
perl -0pi -e 's#<li>\s*Last repository update: .*?\s*</li>#<li>\n            Last repository update: '"$today"'\n        </li>#s' "$PUBLIC_PROJECT_PAGE"
perl -0pi -e 's#<li>\s*Latest recorded commit: <em>.*?</em>\s*</li>#<li>\n            Latest recorded commit: <em>'"$latest_commit_subject"'</em>\n        </li>#s' "$PUBLIC_PROJECT_PAGE"
perl -0pi -e 's#<li>\s*Formal checkpoint version: <code>.*?</code>\s*</li>#<li>\n            Formal checkpoint version: <code>'"$version"'</code>\n        </li>#s' "$PUBLIC_PROJECT_PAGE"

echo "Synced public release pages to: $PUBLIC_PAGES_DIR"
