#!/bin/sh
set -eu

ROOT_DIR="/Users/stevenwoods/mmath-renovation"
HARNESS_SCRIPT="$ROOT_DIR/scripts/abtweak-experiments.sh"
VERSION_FILE="$ROOT_DIR/VERSION"

TMP_DIR=$(mktemp -d "${TMPDIR:-/tmp}/abtweak-rc-sweep.XXXXXX")
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT INT TERM

status_json="$TMP_DIR/status.json"
benchmark_md="$TMP_DIR/benchmark-status.md"
hanoi2_md="$TMP_DIR/hanoi2-historical.md"
hanoi3_md="$TMP_DIR/hanoi3-historical.md"
hanoi4_md="$TMP_DIR/hanoi4-solve-candidates.md"
wide_md="$TMP_DIR/wide-domain-sweep.md"

sh "$HARNESS_SCRIPT" status --json >"$status_json"
sh "$HARNESS_SCRIPT" report benchmark-status >"$benchmark_md"
sh "$HARNESS_SCRIPT" report hanoi2-historical >"$hanoi2_md"
sh "$HARNESS_SCRIPT" report hanoi3-historical >"$hanoi3_md"
sh "$HARNESS_SCRIPT" report hanoi4-solve-candidates >"$hanoi4_md"
sh "$HARNESS_SCRIPT" report wide-domain-sweep >"$wide_md"

version=$(cat "$VERSION_FILE")
generated_at=$(TZ=UTC date +"%Y-%m-%d %H:%M:%SZ")

reproduced_count=$(grep -o '"status":"reproduced"' "$status_json" | wc -l | tr -d ' ')
partial_count=$(grep -o '"status":"partially-reproduced"' "$status_json" | wc -l | tr -d ' ')
open_count=$(grep -o '"status":"open"' "$status_json" | wc -l | tr -d ' ')

wide_solved_count=$(awk -F'|' '
  BEGIN { count = 0 }
  /^\| / {
    outcome = $4
    gsub(/^ +| +$/, "", outcome)
    if (outcome == "solves") {
      count++
    }
  }
  END { print count }
' "$wide_md")

wide_excluded_count=$(awk -F'|' '
  BEGIN { in_excluded = 0; count = 0 }
  /^## Not Yet In This Sweep/ { in_excluded = 1; next }
  /^## / && in_excluded { in_excluded = 0 }
  in_excluded && /^\| / {
    domain = $2
    gsub(/^ +| +$/, "", domain)
    if (domain != "Domain file" && domain != "---") {
      count++
    }
  }
  END { print count }
' "$wide_md")

cat <<EOF
# 1.0 Release Candidate Validation Sweep

Generated:

- UTC: '$generated_at'
- checkpoint under test: '$version'

This sweep is the current repeatable pre-'1.0.0-rc.1' validation bundle for
the historical-restoration baseline.

## Command Set

~~~sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status --json
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report benchmark-status
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi2-historical
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi3-historical
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-solve-candidates
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report wide-domain-sweep
~~~

## Verdict

- core restored operator-style baseline: ready
- historical validation surface: ready
- 'hanoi-4' status for RC: accepted as an explained-but-open extension
  benchmark
- remaining blocker before cutting '1.0.0-rc.1': release preparation and
  version/tag work, not another missing validation family

## Harness Family Snapshot

- reproduced families: '$reproduced_count'
- partially reproduced families: '$partial_count'
- open families: '$open_count'

~~~json
$(cat "$status_json")
~~~

## Historical Validation Checks

### Hanoi-2

- all six recovered hierarchy rows solve
- expanded/generated counts match the archived 1990 two-disk outputs exactly

~~~
$(grep '^| `' "$hanoi2_md")
~~~

### Hanoi-3

- the representative 1991-style compatibility slice still solves cleanly
- the main weak-MSP rows match the archived expanded/generated counts

~~~
$(grep '^| `' "$hanoi3_md")
~~~

## Open Benchmark Disposition

The RC interpretation now assumes that 'hanoi-4' does not block '1.0.0-rc.1'
if it remains clearly documented as a historically grounded extension benchmark
with an evidence-backed "explained but open" status.

Current narrow solve-candidate ladder:

~~~
$(grep '^| `' "$hanoi4_md")
~~~

Current read:

- the strongest live line remains 'isbm + weak-POS + stack + Left-Wedge'
- the strongest grouped-top comparison line remains 'legacy-1991-isbm'
- neither solves at '20000', '50000', '100000', or '200000'
- 'isbm' stays clearly ahead at every tested bound

## Wide Domain Sweep

- solved rows in the current wide operator-style sweep: '$wide_solved_count'
- intentionally excluded alternate/helper rows: '$wide_excluded_count'

The main wide-sweep result remains stable:

- the shipped operator-style sample domains are healthy under the restored
  SBCL path
- the excluded cases remain the alternate 'reset-domain' / 'defstep' track
  or helper-only files, not silent failures inside the main baseline

## Family Summary

$(sed -n '/^| Family /,$p' "$benchmark_md")

## Raw Report References

- 'report benchmark-status'
- 'report hanoi2-historical'
- 'report hanoi3-historical'
- 'report hanoi4-solve-candidates'
- 'report wide-domain-sweep'
EOF
