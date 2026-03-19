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
- [Hanoi-4 lineage trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md)
- [Hanoi-4 lineage divergence](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-divergence.md)
- [Hanoi-4 optimal versus traced lineages](/Users/stevenwoods/mmath-renovation/docs/hanoi4-optimal-lineage-comparison.md)
- [Hanoi-4 reinsertion obligation picture](/Users/stevenwoods/mmath-renovation/docs/hanoi4-reinsertion-obligations.md)
- [Hanoi-4 goal and obligation accounting rules](/Users/stevenwoods/mmath-renovation/docs/hanoi4-accounting-rules.md)
- [Hanoi-4 historical fidelity of the accounting split](/Users/stevenwoods/mmath-renovation/docs/hanoi4-historical-fidelity-of-accounting.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md)
- [Hanoi-4 optimal projection report](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/hanoi4-optimal-projection.md)

## Current Problem Statement

We are trying to determine why the restored `Abtweak-1993` planner still does
not solve the shipped `hanoi-4` benchmark under SBCL, even though:

- `hanoi-3` is working well
- the original published Hanoi figure rows now reproduce directly on the
  restored `hanoi-3` family
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
- the same score/accounting split now also appears to be historically faithful,
  which makes the remaining gap look more like incomplete recovery of the best
  historical four-disk control combination than like a modern porting defect

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
- [lineage trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md#L1):
  the dirty frontier leaders now show long low-`kval` ancestry chains with
  steadily worsening unsatisfied counts, while the clean closure-oriented
  nodes keep shorter healthier abstract lineages
- [lineage divergence](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-divergence.md#L1):
  the first clear fork happens around insertion `6137` to `6157`, where a
  concretized branch wins over a similarly clean abstract branch because the
  Left-Wedge bonus strengthens sharply on the lower `kval`
- [optimal projection report](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/hanoi4-optimal-projection.md):
  on the optimal four-disk state-space path, `ismb` reaches its visible `k1`
  goal slice much earlier than `isbm`, while `isbm` keeps a harder visible
  `k1` target until the final step; that gives us a clean external picture of
  why `isbm` may resist premature apparent progress better
- [optimal versus traced lineages](/Users/stevenwoods/mmath-renovation/docs/hanoi4-optimal-lineage-comparison.md):
  on the current best `isbm` AbTweak trace, the healthy branch stays in the
  same early `k2` band where the optimal projection still makes sense, while
  the dirty priority branch is rewarded for dropping to `k1` and `k0` much
  earlier than the reference path would make natural
- [reinsertion obligation picture](/Users/stevenwoods/mmath-renovation/docs/hanoi4-reinsertion-obligations.md):
  the exact local fork now shows the same branch going from clean `k2`, to
  `k1` with visible goal `(G (ONB PEG3))`, to `k0` with concrete blocker
  `(NOT ONM PEG1)`, while the no-left-wedge score stays fixed and the actual
  score improves through stronger Left-Wedge reward
- [goal and obligation accounting rules](/Users/stevenwoods/mmath-renovation/docs/hanoi4-accounting-rules.md):
  the code-level split is now explicit: the base heuristic counts full
  unsatisfied `G` goals only, while level-correctness and subgoal choice
  operate on current-level visible preconditions, so newly visible concrete
  blockers do not necessarily worsen the base heuristic
- [historical fidelity of the accounting split](/Users/stevenwoods/mmath-renovation/docs/hanoi4-historical-fidelity-of-accounting.md):
  the same split is now confirmed in the archived `1991-05` and `1993` code
  lines and is broadly consistent with the shipped manual text, so it looks
  much more like historical baseline behavior than a new porting defect

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
- `lineage-report.md`

External sanity check:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/run-hanoi-search-baselines.sh
sh /Users/stevenwoods/mmath-renovation/scripts/run-hanoi-projection-report.sh
```

## Current Open Questions

When we return to `hanoi-4`, the most useful questions are now:

1. Does the current left-wedge application in this four-disk setup correspond
   closely enough to the historical intended experiment, or is it too strong in
   the restored path?
2. Is the goal-only heuristic appropriate for this benchmark, given how many
   unresolved non-goal obligations remain on the preferred `kval 0` plans?
3. Which recovered four-disk hierarchy actually corresponds most closely to the
   publication-side good hierarchy families such as `ILMS` and `IMLS`?
4. Did explicit goal-ordering controls or `strong` MSP materially affect the
   published four-disk successes, now that `strong` MSP and `tree`
   goal-ordering are both runnable again as compatibility controls?
5. Can we reproduce a historically plausible `hanoi-4` success by changing only
   historically defensible controls, rather than inventing a new heuristic?
6. If not, is there still a semantic mismatch in the abstraction-side successor
   ranking or pruning path?

## Recommended Re-entry Point

If work resumes here later, the best immediate next experiment is:

- continue from the same `isbm + weak-POS + left-wedge` source run
- tighten the publication-to-code mapping for the good four-disk hierarchy
  families
- treat `strong` MSP and `tree` goal-ordering as restored historical controls,
  but keep `stack` as the current representative winner on the main `isbm`
  four-disk path
- inspect whether any other historically plausible hierarchy/control pairing
  makes better use of the restored tree mode before considering any new
  strategy extension

That is a better next step than another generic bound increase or a new
non-historical heuristic.
