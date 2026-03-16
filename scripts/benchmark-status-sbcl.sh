#!/bin/sh
set -eu

cat <<'EOF'
# AbTweak Benchmark Family Status

This report is the short benchmark-family view of the current restoration
status. It complements the detailed matrix in
`docs/historical-validation-matrix.md`.

| Family | Status | Main evidence | Next step |
| --- | --- | --- | --- |
| Blocks baseline | reproduced | `blocks-sussman` solves in `tweak` and `abtweak`; Nilsson blocks also solves in both modes | keep as stable regression baseline |
| Hanoi-3 | reproduced | `hanoi-3` solves in both modes and the 1991 compatibility layer now reproduces a broad historical control slice exactly | widen historical comparison only when useful |
| Hanoi-4 | partially reproduced | hierarchy sensitivity, MP effects, historical-control vocabulary, and frontier traces are all restored enough to explain much of the behavior, but a full solve is still missing | keep `ismb` and `isbm` as the main open comparison path |
| Robot with user heuristic | reproduced | both robot benchmarks show the historically important AbTweak plus left-wedge advantage over the comparable bounded runs | keep as application benchmark and left-wedge validation case |
| Registers and tiny regressions | reproduced | `registers` solves in both modes and the tiny sanity cases are usable as quick regressions | preserve as fast smoke checks |
| Macro-Hanoi variants | reproduced | `macro-hanoi` and `macro-hanoi4` solve in both modes | keep as compact later-1993 success cases |
| Shipped operator-style sample domains | reproduced | `computer`, `biology`, `fly`, and multiple `database` queries now run correctly under the restored planner path | continue widening where it improves validation coverage |
| 1991 Hanoi MSP compatibility | reproduced | weak-`NEC`, weak-`POS`, and critical-depth representative runs now match archived `hanoi-3` outputs exactly | decide how far to extend this beyond Hanoi |
| Alternate `reset-domain` framework | open | `driving`, `newd`, and parts of `scheduling` still sit outside the restored operator-style experiment path | treat as separate phase-2 restoration track |

## Labels

- `reproduced`: strong evidence that the family behaves as expected in the restored environment
- `partially reproduced`: important behavior is restored and explained, but a key historical result is still incomplete
- `open`: still outside the main restored environment

## Detailed Sources

- `docs/historical-validation-matrix.md`
- `docs/current-status.md`
- `docs/hanoi4-diagnosis.md`
- `docs/hanoi3-1991-compatibility.md`
- `docs/wide-domain-sweep.md`
EOF
