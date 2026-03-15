# Hanoi-4 Diagnosis

This note records the current diagnosis for the `hanoi-4` benchmark under the restored `Abtweak-1993` SBCL port.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

## Current Result

Under the currently restored search paths:

- `hanoi4-tweak` reaches `EXPAND-LIMIT-EXCEEDED`
- `hanoi4-abtweak` also reaches `EXPAND-LIMIT-EXCEEDED` at the standard exploratory bounds
- `hanoi4-abtweak` with `:left-wedge-mode nil` still reaches `EXPAND-LIMIT-EXCEEDED`
- raising the exploratory bounds to `100000` expansions does not produce a plan in `tweak`
- raising the same high bounds in `abtweak` with `:mp-mode t` exhausts the SBCL heap inside the monotonic-property / ordering path instead of returning a normal bound result
- raising the same high bounds in `abtweak` with `:mp-mode nil` falls back to `EXPAND-LIMIT-EXCEEDED`
- a DFS `abtweak` run with `:solution-limit 8` now ends in `OPEN-EXHAUSTED` rather than crashing

Observed BFS runs:

| Config | Expand bound | Expanded | Generated | CPU seconds | Outcome |
| --- | --- | --- | --- | --- | --- |
| `tweak` | `20000` | `20001` | `34234` | about `1.9` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak` | `20000` | `20001` | `35175` | about `5.4` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, no left-wedge | `20000` | `20001` | `35212` | about `5.8` | `EXPAND-LIMIT-EXCEEDED` |
| `tweak` | `100000` | `100001` | `175268` | about `15.1` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, no mp | `100000` | `100001` | `178882` | about `20.4` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, default mp | `100000` | heap growth beyond the 1 GiB SBCL default | not safely reported | about `42.3` before failure | heap exhausted in `VIOLATES-MP-WEAK` / ordering checks |

Observed DFS run:

| Config | Control strategy | Expanded | Generated | Outcome |
| --- | --- | --- | --- | --- |
| `abtweak` | `dfs`, `:solution-limit 8` | `6415` | `6414` | `OPEN-EXHAUSTED` |

## What This Suggests

- At the standard exploratory bounds, the current `hanoi-4` failure is still primarily a bounded-search result, not a loader crash.
- At those same bounds, `abtweak` is not yet showing a search reduction advantage over `tweak` on the full `hanoi-4` goal.
- At higher bounds, the most concrete new problem is not “plain search is still too big” so much as “the MP-enabled AbTweak path blows the heap in ordering / MP checks before it can return a normal result.”
- The fact that the same high-bound AbTweak run without MP falls back to an ordinary `EXPAND-LIMIT-EXCEEDED` outcome makes the MP path the clearest current pressure point.

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
- the biggest remaining implementation risk is now concentrated in monotonic-property / ordering-cost behavior rather than in basic Hanoi encoding or abstraction descent.

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
- with a newly identified MP / ordering memory blow-up on higher-bound `abtweak` runs
- not yet evidence of a major semantic break in the Hanoi domain encoding itself
- best revisited next by isolating or profiling the MP path rather than simply raising bounds again
