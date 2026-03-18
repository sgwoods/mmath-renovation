# Hanoi-4 Lineage Trace

This note records the first lineage trace for the current best historical
`hanoi-4` path:

- planner mode: `abtweak`
- hierarchy: `isbm`
- `msp-mode`: `weak`
- `msp-weak-mode`: `pos`
- `left-wedge-mode`: `t`

It complements:

- [Hanoi-4 insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Why This Matters

The insertion-time score trace already showed:

- the closure-oriented states are not buried immediately
- the strong distortion seen later in OPEN must accumulate over continued
  search

The lineage trace tests that directly by following top frontier nodes back
through their insertion history.

## Reproducible Path

The trace runner is:

```sh
HISTORICAL_MODE=t \
HIERARCHY=isbm \
MP_WEAK_MODE=pos \
LEFT_WEDGE_MODE=t \
EXPAND_BOUND=10000 \
GENERATE_BOUND=40000 \
OPEN_BOUND=40000 \
SCORE_TRACE_LIMIT=15000 \
sh /Users/stevenwoods/mmath-renovation/scripts/trace-hanoi4-sbcl.sh
```

Representative generated files:

- [lineage report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260318-173205/lineage-report.md)
- [insertion score report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260318-173205/insertion-score-report.md)

## Main Result

The compounding-refinement hypothesis is now strongly supported.

### Priority frontier leaders

The top dirty frontier leaders are not isolated bad insertions. They descend
through long low-`kval` refinement chains.

Representative top priority node:

- frontier plan id: `|plan52005|`
- final frontier state:
  - priority `5`
  - `kval 0`
  - cost `14`
  - length `16`
  - unsatisfied pairs `14`

Its lineage shows:

- the chain runs at least `25` insertion steps
- it reaches `kval 0` early and stays there
- unsatisfied-pair count climbs from `0` to `2`, `3`, `4`, `6`, `8`, `12`,
  and finally `14`
- actual score remains artificially attractive because left-wedge keeps the
  actual score below the no-left-wedge and unsat-aware alternatives

This is not one bad node. It is a repeated refinement pattern.

### Closure frontier leaders

The clean closure-oriented frontier states show a very different lineage.

Representative closure node:

- frontier plan id: `|plan33626|`
- final frontier state:
  - priority `6`
  - `kval 2`
  - cost `6`
  - length `8`
  - unsatisfied pairs `2`

Its lineage shows:

- a short, stable abstract chain from `INITIAL-PLAN`
- low unsatisfied counts throughout
- no forced plunge into the dirty `kval 0` region

So the restored planner is still generating healthy abstract continuations. The
problem is that the search keeps preferring longer concretizing descendants of
other lines.

## Strongest Interpretation

This is the clearest diagnosis so far:

1. the insertion score already biases toward concretization
2. repeated left-wedge-favored refinement then compounds that bias
3. the dirtiest `kval 0` frontier leaders are descendants of earlier cleaner
   states whose unresolved obligations steadily worsen
4. healthier abstract alternatives remain available, but they survive less well
   in OPEN

So the current `hanoi-4` failure mode is best described as:

- compounding overconcretization under historically intended refinement pressure

rather than:

- a single broken successor step
- or a single catastrophically bad insertion score

## Best Next Question

The next most useful baseline-preserving experiment is now:

- compare one dirty priority-lineage branch and one healthy closure-lineage
  branch step by step
- identify the exact refinement move where the dirty branch starts increasing
  unresolved obligations faster than it is reducing goal distance
- then compare that behavior with the historical Left-Wedge description and
  published hierarchy-quality story
