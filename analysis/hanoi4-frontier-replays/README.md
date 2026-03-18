# Hanoi-4 Frontier Replays

This directory contains frozen-frontier replay experiments for the restored
`hanoi-4` planner runs.

The point of these runs is to separate:

1. frontier generation quality
2. frontier ranking quality

Each timestamped directory captures:

- one source search to a fixed frontier bound
- one replay cohort selected by actual search priority
- one replay cohort selected by closure quality
- a markdown report summarizing the replay outcomes

The standard entry points are:

- [scripts/replay-hanoi4-frontier-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/replay-hanoi4-frontier-sbcl.sh)
- [scripts/compare-hanoi4-frontier-replay-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-frontier-replay-sbcl.sh)
- [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh) via `report hanoi4-frontier-replay`

Representative run directories:

- [hanoi4-replay-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-lw-t-20260317-141722](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/hanoi4-replay-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-lw-t-20260317-141722)
- [hanoi4-replay-tweak-critical-list-1-hist-nil-mp-nil-msp-weak-weak-nec-lw-nil-20260317-143544](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/hanoi4-replay-tweak-critical-list-1-hist-nil-mp-nil-msp-weak-weak-nec-lw-nil-20260317-143544)
