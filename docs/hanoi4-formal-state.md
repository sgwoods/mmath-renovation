# Hanoi-4 Formal State

This note is the formal handoff snapshot for the current `hanoi-4`
investigation so it can be resumed later without reconstructing context from
scratch.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md)
- [Hanoi-4 score sensitivity](/Users/stevenwoods/mmath-renovation/docs/hanoi4-score-sensitivity.md)
- [Hanoi-4 insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md)

## Current Problem Statement

We are trying to determine why the restored `Abtweak-1993` planner still does
not solve the shipped `hanoi-4` benchmark under SBCL, even though:

- `hanoi-3` is working well
- the broader operator-style restoration is strong across many other domains
- plain state-space Hanoi solvers solve the same four-disk transfer easily

## Best Current Runtime Path

The strongest current `hanoi-4` path is:

- planner mode: `abtweak`
- hierarchy: `isbm`
- historical-control vocabulary:
  - `msp-mode weak`
  - `msp-weak-mode pos`
  - `left-wedge-mode t`

At larger bounds, this is currently the best-performing four-disk historical
control path we have restored, but it still terminates with
`EXPAND-LIMIT-EXCEEDED`.

## Strongest Current Findings

### 1. This is no longer a loader or fatal runtime bug

- earlier precedence/heap failures are fixed
- both `tweak` and `abtweak` now fail cleanly on `hanoi-4`
- the open question is planner behavior, not whether the code can run

### 2. The domain and algorithm lineage look historically faithful

- the active `hanoi-4` domain still corresponds closely to the archival source
- the major precedence rewrite was checked for equivalence against the older
  relation and did not show randomized mismatches
- the remaining gap therefore does not currently look like "we accidentally
  replaced AbTweak with a different planner"

### 3. The frontier evidence points at abstraction-side ranking, not at generic search hardness

The main chain of evidence now is:

- [frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md#L1):
  cleaner closure-oriented states exist in OPEN, but are ranked behind more
  concrete move skeletons
- [frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md#L1):
  sampled `tweak` frontier nodes remain live under neutral replay, while most
  sampled `abtweak` frontier nodes do not
- [score sensitivity](/Users/stevenwoods/mmath-renovation/docs/hanoi4-score-sensitivity.md#L1):
  the clean closure-oriented node is actual rank `1149`, but jumps to rank `1`
  as soon as left-wedge is removed
- [insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md#L1):
  the same general bias is already present at insertion time, but much less
  extremely; the best closure-oriented inserted node is still actual rank `4`

That makes the current best diagnosis:

- the restored `abtweak` score is over-selecting increasingly dirty,
  concretized partial plans
- unresolved obligations are not being charged strongly enough
- left-wedge refinement pressure is dominating the `hanoi-4` search shape
- the strongest distortion appears to compound over repeated refinements, not
  arise fully formed at the first insertion

## Exact Score-Sensitivity Result To Remember

From the current score-sensitivity report:

- actual top-ranked node:
  - rank under actual score: `1`
  - rank without left-wedge: `71`
  - rank under unsat-aware score: `724`
- best closure-oriented node:
  - rank under actual score: `1149`
  - rank without left-wedge: `1`
  - rank under unsat-aware score: `1`
- actual top-20 vs no-left-wedge top-20 overlap: `0 / 20`

This is the cleanest single summary of the current `hanoi-4` failure mode.

## Commands To Resume

Core reports:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-historical
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-frontier-replay
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-score-sensitivity
```

Trace presets:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos-lw
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-legacy-1991
```

Those traces now also write:

- `insertion-score-trace.txt`
- `insertion-score-report.md`

External sanity check:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/run-hanoi-search-baselines.sh
```

## Current Open Questions

When we return to `hanoi-4`, the most useful questions are now:

1. Does the current left-wedge application in this four-disk setup correspond
   closely enough to the historical intended experiment, or is it too strong in
   the restored path?
2. Is the goal-only heuristic appropriate for this benchmark, given how many
   unresolved non-goal obligations remain on the preferred `kval 0` plans?
3. Can we reproduce a historically plausible `hanoi-4` success by changing only
   historically defensible controls, rather than inventing a new heuristic?
4. If not, is there still a semantic mismatch in the abstraction-side successor
   ranking or pruning path?

## Recommended Re-entry Point

If work resumes here later, the best immediate next experiment is:

- keep the same `isbm + weak-POS + left-wedge` source run
- trace the lineage from early well-ranked inserted nodes to the later dirty
  `kval 0` frontier leaders
- compare that against the historically intended left-wedge use described in
  the report/thesis

That is a much better next step than another generic bound increase.
