# Tweak vs AbTweak Comparison

This note records the first structured side-by-side comparison of the restored `Abtweak-1993` working tree under SBCL.

It is meant to complement:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)

## Scope

This comparison uses the current scripted smoke cases for:

- `blocks` / `sussman`
- `Nilsson blocks`
- `hanoi-3`
- `hanoi-4`
- `macro-hanoi`
- `simple-robot-2`

All runs use the shared smoke settings in [scripts/smoke-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh#L1). The robot case also uses the manual-style user-defined heuristic path and primary effects setup, and one AbTweak run disables left-wedge for direct comparison.

## Current Comparison

| Domain | Config | Outcome | Cost | Length | Kval | What it shows |
| --- | --- | --- | --- | --- | --- | --- |
| `blocks` / `sussman` | `tweak` | Solves | `3` | `5` | `0` | Canonical TWEAK-style baseline |
| `blocks` / `sussman` | `abtweak` | Solves | `3` | `5` | `0` | No observed difference from `tweak` at current bounds |
| `Nilsson blocks` | `tweak` | Solves | `6` | `8` | `0` | Standard blocksworld variant from the manual |
| `Nilsson blocks` | `abtweak` | Solves | `6` | `8` | `0` | Same plan as `tweak`, with monotonic property enabled |
| `Nilsson blocks` | `abtweak` with `:mp-mode nil` | Solves | `6` | `8` | `0` | Same plan, but more search than the mp-enabled run |
| `hanoi-3` | `tweak` | Solves | `7` | `9` | `0` | Canonical abstraction-heavy benchmark |
| `hanoi-3` | `abtweak` | Solves | `7` | `9` | `0` | No observed difference from `tweak` at current bounds |
| `hanoi-4` | `tweak` | `EXPAND-LIMIT-EXCEEDED` | `-` | `-` | `-` | Larger Tower of Hanoi benchmark still exceeds current exploratory bounds |
| `hanoi-4` | `abtweak` | `EXPAND-LIMIT-EXCEEDED` | `-` | `-` | `-` | Same bounded failure as `tweak` at the current exploratory settings |
| `macro-hanoi` | `tweak` | Solves | `1` | `3` | `0` | Macro operator variant solves immediately at current settings |
| `macro-hanoi` | `abtweak` | Solves | `1` | `3` | `0` | No observed difference from `tweak` at current bounds |
| `simple-robot-2` | `tweak` | `EXPAND-LIMIT-EXCEEDED` | `-` | `-` | `-` | Same bounds do not currently reach a solution |
| `simple-robot-2` | `abtweak` | Solves | `12` | `14` | `0` | AbTweak plus the manual-style heuristic path reaches a real plan |
| `simple-robot-2` | `abtweak` with `:left-wedge-mode nil` | `EXPAND-LIMIT-EXCEEDED` | `-` | `-` | `-` | Left-wedge materially changes the observed outcome |

## Current Takeaways

- `blocks` / `sussman` is now a clean apples-to-apples proof that the restored `tweak` and `abtweak` paths can both produce the same small successful solution under SBCL.
- `Nilsson blocks` broadens that result to a second historically recognizable blocks variant:
  - `tweak` and `abtweak` return the same cost-`6`, length-`8`, `kval 0` plan
  - enabling the monotonic property reduces search from `70` expanded / `201` generated to `61` expanded / `168` generated, with `*mp-pruned*` increasing from `0` to `1`
- `hanoi-3` shows that the same is true for one abstraction-heavy benchmark, at least at the current smoke bounds and current metrics.
- `macro-hanoi` shows that a macro-operator variant also solves in both modes under SBCL, and currently does so with a compact cost-`1`, length-`3` plan.
- `hanoi-4` is now a useful larger benchmark even without a passing result, because both `tweak` and `abtweak` currently fail in the same bounded way at the exploratory settings rather than crashing.
- more detail on that `hanoi-4` result now lives in [docs/hanoi4-diagnosis.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md#L1), including the current evidence that the restored BFS path is search-bound-limited rather than obviously semantically broken
- `simple-robot-2` is the first benchmark where the comparison is behaviorally interesting instead of merely equal:
  - `tweak` does not solve at the current smoke bounds.
  - `abtweak` does solve with the manual-style heuristic path.
  - disabling left-wedge in the same AbTweak setup returns the run to bounded failure.

## Limits Of This Comparison

- These runs are still smoke tests, not full historical replications.
- Matching cost and plan length does not yet prove matching search effort or matching internal abstraction behavior.
- `plan` still returns `NIL`, with the actual solution recorded in `*solution*`; that appears to be historical interface behavior and is not treated here as a failure.

## Reproducible Commands

Compact comparison report:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-abtweak-1993-sbcl.sh
```

Individual cases:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh nils-blocks-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh nils-blocks-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh nils-blocks-abtweak-no-mp
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi3-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi3-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi4-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi4-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh macro-hanoi-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh macro-hanoi-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-abtweak-no-lw
```
