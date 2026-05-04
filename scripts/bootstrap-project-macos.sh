#!/usr/bin/env bash
set -euo pipefail

DEFAULT_TARGET_DIR="${HOME}/Projects/mmath-renovation-working"
DEFAULT_PUBLIC_DIR="${HOME}/Projects/public"
DEFAULT_UI_DIR="${HOME}/Projects/abtweak-experiments-ui"
DEFAULT_REPO_URL="https://github.com/sgwoods/mmath-renovation.git"
DEFAULT_PUBLIC_REPO_URL="https://github.com/sgwoods/public.git"
DEFAULT_UI_REPO_URL="https://github.com/sgwoods/abtweak-experiments-ui.git"

TARGET_DIR="$DEFAULT_TARGET_DIR"
PUBLIC_DIR="$DEFAULT_PUBLIC_DIR"
UI_DIR="$DEFAULT_UI_DIR"
REPO_URL="$DEFAULT_REPO_URL"
PUBLIC_REPO_URL="$DEFAULT_PUBLIC_REPO_URL"
UI_REPO_URL="$DEFAULT_UI_REPO_URL"
BRANCH="main"
INSTALL_HOMEBREW=0
SKIP_SUPPORTING_CLONES=0
SKIP_UI_BUILD=0
SKIP_PUBLIC_DRILL=0
SKIP_VALIDATION=0
BRANCH_EXPLICIT=0

usage() {
  cat <<'EOF'
Usage:
  bash scripts/bootstrap-project-macos.sh [options]

Options:
  --target-dir DIR          Active non-iCloud working clone path
  --branch BRANCH           Branch to check out after cloning/updating (default: main)
  --repo-url URL            Repo URL to clone/update
  --public-dir DIR          Companion public repo path
  --ui-dir DIR              Companion hosted UI repo path
  --public-repo-url URL     Companion public repo URL
  --ui-repo-url URL         Companion hosted UI repo URL
  --skip-supporting-clones  Do not clone/update the companion repos
  --skip-ui-build           Skip npm install/build for the hosted UI repo
  --skip-public-drill       Skip the release snapshot/public sync drill
  --skip-validation         Skip the repo-local validation spine
  --install-homebrew        Install Homebrew first if it is missing
  --help                    Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target-dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      BRANCH_EXPLICIT=1
      shift 2
      ;;
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --public-dir)
      PUBLIC_DIR="$2"
      shift 2
      ;;
    --ui-dir)
      UI_DIR="$2"
      shift 2
      ;;
    --public-repo-url)
      PUBLIC_REPO_URL="$2"
      shift 2
      ;;
    --ui-repo-url)
      UI_REPO_URL="$2"
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
    --skip-public-drill)
      SKIP_PUBLIC_DRILL=1
      shift
      ;;
    --skip-validation)
      SKIP_VALIDATION=1
      shift
      ;;
    --install-homebrew)
      INSTALL_HOMEBREW=1
      shift
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

ensure_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi

  if [[ "$INSTALL_HOMEBREW" -ne 1 ]]; then
    echo "Homebrew is required but not installed." >&2
    echo "Either install Homebrew first or re-run with --install-homebrew." >&2
    exit 1
  fi

  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_brew_package() {
  local package="$1"
  if brew list "$package" >/dev/null 2>&1; then
    echo "brew package present: $package"
    return 0
  fi

  echo "Installing brew package: $package"
  brew install "$package"
}

detect_default_branch() {
  if [[ "$BRANCH_EXPLICIT" -eq 1 ]]; then
    return 0
  fi

  if git -C "$(pwd)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local current_branch
    current_branch="$(git -C "$(pwd)" branch --show-current 2>/dev/null || true)"
    if [[ -n "$current_branch" ]]; then
      BRANCH="$current_branch"
    fi
  fi
}

clone_or_update_repo() {
  local repo_url="$1"
  local target_dir="$2"
  local branch="$3"

  mkdir -p "$(dirname "$target_dir")"

  if [[ ! -d "$target_dir/.git" ]]; then
    if [[ -e "$target_dir" ]]; then
      echo "Target path exists but is not a git repo: $target_dir" >&2
      exit 1
    fi
    echo "Cloning repo into: $target_dir"
    git clone "$repo_url" "$target_dir"
  fi

  echo "Refreshing repo: $target_dir"
  git -C "$target_dir" fetch origin --prune
  git -C "$target_dir" checkout "$branch"
  git -C "$target_dir" merge --ff-only "origin/$branch"
}

main() {
  detect_default_branch

  echo "== MMath Renovation macOS bootstrap =="
  echo "Target repo: $TARGET_DIR"
  echo "Branch: $BRANCH"

  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to bootstrap this machine." >&2
    exit 1
  fi

  ensure_homebrew
  ensure_brew_package git
  ensure_brew_package python
  ensure_brew_package sbcl
  ensure_brew_package ghostscript
  ensure_brew_package node

  clone_or_update_repo "$REPO_URL" "$TARGET_DIR" "$BRANCH"

  if [[ "$SKIP_SUPPORTING_CLONES" -eq 0 ]]; then
    clone_or_update_repo "$PUBLIC_REPO_URL" "$PUBLIC_DIR" main
    clone_or_update_repo "$UI_REPO_URL" "$UI_DIR" main
  fi

  local startup_args=()
  startup_args+=(--public-dir "$PUBLIC_DIR")
  startup_args+=(--ui-dir "$UI_DIR")

  if [[ "$SKIP_VALIDATION" -eq 1 ]]; then
    startup_args+=(--skip-validation)
  fi
  if [[ "$SKIP_UI_BUILD" -eq 0 ]]; then
    startup_args+=(--validate-ui)
  fi
  if [[ "$SKIP_PUBLIC_DRILL" -eq 0 ]]; then
    startup_args+=(--run-public-drill)
  fi

  echo
  echo "Handing off to startup validation..."
  bash "$TARGET_DIR/scripts/start-codex-new-mac.sh" "${startup_args[@]}"
}

main "$@"
