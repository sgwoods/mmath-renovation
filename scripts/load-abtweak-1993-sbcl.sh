#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
WORKDIR="$REPO_ROOT/working/abtweak-1993"

cd "$WORKDIR"
exec /opt/homebrew/bin/sbcl --noinform --disable-debugger \
  --eval '(progn (load "init-sbcl.lisp") (format t "SBCL init load succeeded.~%"))' \
  --quit
