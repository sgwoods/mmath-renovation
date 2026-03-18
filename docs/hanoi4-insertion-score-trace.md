# Hanoi-4 Insertion Score Trace

This note records the first insertion-time score trace for the current best
historical-control `hanoi-4` path:

- planner mode: `abtweak`
- hierarchy: `isbm`
- `msp-mode`: `weak`
- `msp-weak-mode`: `pos`
- `left-wedge-mode`: `t`

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md)
- [Hanoi-4 score sensitivity](/Users/stevenwoods/mmath-renovation/docs/hanoi4-score-sensitivity.md)

## Why This Trace Was Added

The earlier frontier analysis showed a dramatic ranking problem:

- the clean closure-oriented frontier node sat at actual rank `1149`
- the same node jumped to rank `1` without left-wedge

That still left one important question open:

- is the ranking failure already extreme when nodes are created, or
- does it become extreme only after repeated refinements and continued search?

The new insertion trace answers that more directly.

## Reproducible Path

The trace runner is still:

```sh
HISTORICAL_MODE=t \
HIERARCHY=isbm \
MP_WEAK_MODE=pos \
LEFT_WEDGE_MODE=t \
EXPAND_BOUND=10000 \
GENERATE_BOUND=40000 \
OPEN_BOUND=40000 \
SCORE_TRACE_LIMIT=5000 \
sh /Users/stevenwoods/mmath-renovation/scripts/trace-hanoi4-sbcl.sh
```

The first captured run is:

- [insertion score report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260318-171503/insertion-score-report.md)
- [raw insertion score trace](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260318-171503/insertion-score-trace.txt)

## Main Result

At insertion time, the scoring distortion is real, but much less extreme than
the later frontier distortion.

From the first 5000 inserted nodes:

- actual top inserted node:
  - insertion index `46`
  - actual score `-4`
  - no-left-wedge score `5`
  - unsat-aware score `8`
  - `kval 0`
  - plan cost `3`
  - plan length `5`
  - unsatisfied-pair count `3`
  - rank without left-wedge `27`
  - rank under unsat-aware score `8`
- best closure-oriented inserted node:
  - insertion index `3`
  - actual score `1`
  - no-left-wedge score `4`
  - unsat-aware score `4`
  - `kval 2`
  - plan cost `1`
  - plan length `3`
  - unsatisfied-pair count `0`
  - rank under actual score `4`
  - rank without left-wedge `3`
  - rank under unsat-aware score `1`

## Interpretation

This changes the diagnosis in an important way.

The earlier frontier reports made it look as if the clean closure-oriented
states were being buried immediately. The insertion-time trace shows that this
is not quite what happens:

1. cleaner abstract states are still ranked near the top when first inserted
2. left-wedge is already biasing the search toward lower `kval`, but the early
   bias is moderate rather than catastrophic
3. the much worse distortion seen at the frozen frontier appears to accumulate
   over repeated refinement and continued expansion

So the current best explanation is no longer just:

- "the insertion score is wrong"

It is now:

- the insertion score already leans too hard toward concretization, and
- that bias compounds over multiple refinement steps until the frontier is
  dominated by dirty `kval 0` descendants

## Best Next Question

The next most useful `hanoi-4` experiment is now narrower:

- trace the lineage from early well-ranked inserted nodes to the later dirty
  frontier leaders
- compare whether the problematic effect is mainly:
  - repeated left-wedge pressure on already favored lines, or
  - some interaction between abstraction, pruning, and reinsertion that keeps
    healthier alternatives from surviving in OPEN
