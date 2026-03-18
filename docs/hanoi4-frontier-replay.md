# Hanoi-4 Frontier Replay

This note records the first frozen-frontier replay experiment for the current
`hanoi-4` restoration work.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md)

## Goal

The question here is narrower than "does `hanoi-4` solve?"

We wanted to distinguish:

1. whether the restored planner is generating bad frontier states, or
2. whether it is generating viable frontier states but ranking them badly

To probe that, this experiment freezes a frontier at a fixed bound, selects
two cohorts from it, and replays each node under a neutral continuation
policy.

## Replay Setup

The standardized report is:

- `sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-frontier-replay`

That report currently reruns two source searches:

1. `abtweak + isbm + weak-POS + left-wedge`
2. plain `tweak`

For each source frontier:

- source bound: `10000` expansions
- replay cohort size: `5`
- cohorts:
  - top `5` nodes by actual search priority
  - top `5` nodes by lowest unsatisfied-pair count
- replay policy:
  - same planner mode as the source run
  - BFS
  - `:heuristic-mode 'user-defined` with the checked-in zero heuristic
  - `:left-wedge-mode nil`
- replay bound: `1000` expansions

The generated reports for one representative run are:

- [AbTweak replay report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/hanoi4-replay-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-lw-t-20260317-141722/report.md)
- [Tweak replay report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/hanoi4-replay-tweak-critical-list-1-hist-nil-mp-nil-msp-weak-weak-nec-lw-nil-20260317-143544/report.md)

## Main Result

The split is strong enough to matter.

For the current best `abtweak` path:

- priority cohort still live at replay bound: `1 / 5`
- priority cohort dead-ended early: `4 / 5`
- closure cohort still live at replay bound: `1 / 5`
- closure cohort dead-ended early: `4 / 5`

For the current `tweak` baseline:

- priority cohort still live at replay bound: `5 / 5`
- priority cohort dead-ended early: `0 / 5`
- closure cohort still live at replay bound: `5 / 5`
- closure cohort dead-ended early: `0 / 5`

So under the same neutral continuation idea:

- `tweak` frontier states are broadly search-live
- many `abtweak` frontier states are not

## What This Says About The Bug Hypothesis

This is the first experiment that makes the `tweak` / `abtweak` behavioral
gap look less like a generic search-hardness issue and more like a
planner-specific frontier-quality issue.

The result does **not** prove that successor generation is wrong. But it does
show:

- the dramatic divergence is not just "AbTweak keeps searching longer"
- many currently high-ranked or near-top `abtweak` frontier states collapse
  almost immediately once replayed without the original ranking pressure
- the same is not true of the sampled `tweak` frontier states

That makes the current best interpretation:

- `abtweak` is generating too many locally poor or overconcretized frontier
  states for `hanoi-4`
- the problem is likely in ranking, pruning interaction, or abstraction-side
  control quality rather than in the mere existence of a valid solution path

## A Smaller But Useful Secondary Signal

Within the `abtweak` run, the healthiest replayed node came from the
closure-oriented cohort rather than the actual top-ranked cohort:

- best live priority replay generated: `1075`
- best live closure replay generated: `1386`

That is not yet a full solve, but it is consistent with the earlier
frontier-quality diagnosis: closure-oriented nodes appear healthier than the
states the current scoring actually prefers.

## Current Conclusion

The frozen-frontier replay experiment strengthens the working diagnosis:

- the remaining `hanoi-4` gap is not well explained by "the planner simply
  cannot generate viable continuation states"
- the restored `abtweak` path appears to surface many frontier nodes that are
  much more locally brittle than the corresponding `tweak` frontier nodes
- the next best investigation is therefore not another broad parameter sweep
  first; it is to inspect what makes these replay-dead `abtweak` states rank
  so highly in the original search
