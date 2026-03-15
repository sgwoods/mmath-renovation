# Hanoi-4 Diagnosis

This note records the current diagnosis for the `hanoi-4` benchmark under the restored `Abtweak-1993` SBCL port.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)

## Current Result

Under the currently restored search paths:

- `hanoi4-tweak` reaches `EXPAND-LIMIT-EXCEEDED`
- `hanoi4-abtweak` also reaches `EXPAND-LIMIT-EXCEEDED` at the standard exploratory bounds
- `hanoi4-abtweak` with `:left-wedge-mode nil` still reaches `EXPAND-LIMIT-EXCEEDED`
- raising the exploratory bounds to `100000` expansions does not produce a plan in `tweak`
- after replacing the precedence reachability test with a copy-free graph walk in the working tree, raising the same high bounds in `abtweak` with default MP no longer exhausts the SBCL heap
- both the default MP run and the `:mp-mode nil` run now fall back to `EXPAND-LIMIT-EXCEEDED`
- a DFS `abtweak` run with `:solution-limit 8` now ends in `OPEN-EXHAUSTED` rather than crashing

Observed BFS runs:

| Config | Expand bound | Expanded | Generated | CPU seconds | Outcome |
| --- | --- | --- | --- | --- | --- |
| `tweak` | `20000` | `20001` | `34234` | about `1.9` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak` | `20000` | `20001` | `35175` | about `5.4` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, no left-wedge | `20000` | `20001` | `35212` | about `5.8` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, no mp | `20000` | `20001` | `35175` | about `5.4` | `EXPAND-LIMIT-EXCEEDED` |
| `tweak` | `100000` | `100001` | `175268` | about `15.1` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, no mp | `100000` | `100001` | `178882` | about `20.4` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, default mp before precedence fix | `100000` | heap growth beyond the 1 GiB SBCL default | not safely reported | about `42.3` before failure | heap exhausted during precedence-heavy AbTweak search |
| `abtweak`, default mp after precedence fix | `100000` | `100001` | `178882` | about `26.2` | `EXPAND-LIMIT-EXCEEDED` |

Observed DFS run:

| Config | Control strategy | Expanded | Generated | Outcome |
| --- | --- | --- | --- | --- |
| `abtweak` | `dfs`, `:solution-limit 8` | `6415` | `6414` | `OPEN-EXHAUSTED` |

## What This Suggests

- At the standard exploratory bounds, the current `hanoi-4` failure is still primarily a bounded-search result, not a loader crash.
- At those same bounds, `abtweak` is not yet showing a search reduction advantage over `tweak` on the full `hanoi-4` goal.
- In fact, `tweak` currently generates fewer nodes than any of the tested AbTweak variants at the `20000`-expansion budget.
- `:mp-mode t` is not currently helping on this case:
  - the `abtweak` and `abtweak` with `:mp-mode nil` runs generate the same `35175` nodes at the standard bound
  - `*mp-pruned*` remains `0`
- `:left-wedge-mode nil` is also not the explanation for the failure:
  - disabling left-wedge makes the run slightly worse (`35212` generated vs `35175`)
- The fatal high-bound SBCL failure is now fixed in the working tree.
- At higher bounds, the benchmark is still expensive, but it now terminates normally with `EXPAND-LIMIT-EXCEEDED` rather than exhausting the heap.
- The no-MP and default-MP high-bound runs are now both stable enough to compare as ordinary planner results.
- The working-vs-historical algorithm review now strengthens the diagnosis:
  - the active `hanoi-4` domain and default hierarchy match the archival snapshots
  - the main working-tree precedence rewrite preserves the historical precedence relation on randomized equivalence checks
  - the search gap therefore looks more like a control or fidelity problem than a replaced planner algorithm
- The new hierarchy comparison sharpens that further:
  - `critical-list-1` still behaves like a poor hierarchy
  - `critical-list-2` and especially `ismb` now show the kind of MP-sensitive improvement the historical work would lead us to expect
  - the best 20k-bound configuration so far is `ismb` with MP enabled

## Evidence Against A Gross Semantic Break

The same domain still behaves sensibly on simpler targets:

| Case | Mode | Outcome | Cost | Length | Kval |
| --- | --- | --- | --- | --- | --- |
| `hanoi4-goalb` | `abtweak` | Solves | `4` | `6` | `0` |
| `hanoi4-goalm` | `abtweak` | Solves | `2` | `4` | `0` |
| `macro-hanoi` | `tweak` | Solves | `1` | `3` | `0` |
| `macro-hanoi` | `abtweak` | Solves | `1` | `3` | `0` |

That makes the current best explanation:

- the full `hanoi-4` problem is still expensive even in the restored planner, and
- the earlier precedence-driven heap blow-up has been repaired enough that the remaining problem is once again ordinary search growth rather than fatal runtime instability.
- the specific abstraction controls do matter, but only on some hierarchies:
  - under `critical-list-1`, MP is pruning nothing at the standard bound
  - under `critical-list-2` and `ismb`, MP becomes strongly active and search improves materially
  - left-wedge is a smaller effect than MP in the current hierarchy matrix, but it is directionally helpful on the stronger hierarchies

## Important Limitation

The DFS control-strategy path is now restored enough to run under SBCL, but it is not yet a useful comparison mode.

The immediate loader break was that [Search-routines/init.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/init.lisp#L1) did not load [Search-routines/stack-list-access.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/stack-list-access.lisp#L1). After fixing that, DFS no longer crashes on `STACK-INITIALIZE-OPEN`.

Current DFS behavior:

- the planner now reports DFS and bound failures more accurately under SBCL:
  - open exhaustion records `OPEN-EXHAUSTED`
  - `generate-bound` records `GENERATE-LIMIT-EXCEEDED`
  - `open-bound` records `OPEN-LIMIT-EXCEEDED`
- on small tuned cases such as `blocks` / `sussman`, DFS now returns real plans again when `solution-limit` is kept low
- with a larger `solution-limit`, DFS still tends to follow longer first-found plans and eventually hit `CPU-TIME-LIMIT-EXCEEDED`

So DFS is now available as an execution path, and on `hanoi-4` it now provides a cleaner signal than before, but it still is not a strong path to a solution and should be treated as a diagnostic rather than a primary benchmark mode.

## Current Conclusion

The best current classification for `hanoi-4` is:

- likely a search-growth and control-setting problem first
- no longer reproducing the earlier MP / ordering heap blow-up under the same high-bound SBCL run
- not evidence of a major semantic break in the Hanoi domain encoding itself
- not presently explained by a fundamental rewrite of the archived AbTweak algorithms in the working tree
- best revisited next as a hierarchy-quality and historical-validation problem rather than a fatal-runtime bug
- most immediate open question: which of the tested hierarchies correspond to the published “good” and “bad” Hanoi hierarchies, and what further tuning is needed to push the promising ones to a full solution
