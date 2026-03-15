# Hanoi-4 Diagnosis

This note records the current diagnosis for the `hanoi-4` benchmark under the restored `Abtweak-1993` SBCL port.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

## Current Result

Under the currently restored BFS search path:

- `hanoi4-tweak` reaches `EXPAND-LIMIT-EXCEEDED`
- `hanoi4-abtweak` also reaches `EXPAND-LIMIT-EXCEEDED`
- raising the exploratory bounds from `20000` expansions to `100000` expansions still produces bounded termination rather than a plan

Observed BFS runs:

| Config | Expand bound | Expanded | Generated | CPU seconds | Outcome |
| --- | --- | --- | --- | --- | --- |
| `tweak` | `20000` | `20001` | `34234` | about `1.9` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak` | `20000` | `20001` | `35175` | about `5.4` | `EXPAND-LIMIT-EXCEEDED` |
| `tweak` | `100000` | `100001` | `175268` | about `15.1` | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak` | `100000` | `100001` | `178882` | about `42.3` | `EXPAND-LIMIT-EXCEEDED` |

## What This Suggests

- The current `hanoi-4` failure is primarily a bounded-search result, not a loader crash and not a CPU timeout.
- At the current restored defaults, `abtweak` is not yet showing a search reduction advantage over `tweak` on the full `hanoi-4` goal.
- That does not by itself prove a semantic bug, because the search behavior is still coherent and scales upward when bounds are raised.

## Evidence Against A Gross Semantic Break

The same domain still behaves sensibly on simpler targets:

| Case | Mode | Outcome | Cost | Length | Kval |
| --- | --- | --- | --- | --- | --- |
| `hanoi4-goalb` | `abtweak` | Solves | `4` | `6` | `0` |
| `hanoi4-goalm` | `abtweak` | Solves | `2` | `4` | `0` |
| `macro-hanoi` | `tweak` | Solves | `1` | `3` | `0` |
| `macro-hanoi` | `abtweak` | Solves | `1` | `3` | `0` |

That makes the current best explanation:

- the full `hanoi-4` problem is still too expensive for the restored BFS settings we have tried so far, and
- if there is a remaining semantic issue, it is subtler than a wholesale failure of Hanoi abstractions.

## Important Limitation

The DFS control-strategy path is now restored enough to run under SBCL, but it is not yet a useful comparison mode.

The immediate loader break was that [Search-routines/init.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/init.lisp#L1) did not load [Search-routines/stack-list-access.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/stack-list-access.lisp#L1). After fixing that, DFS no longer crashes on `STACK-INITIALIZE-OPEN`.

Current DFS behavior:

- with the historical default `solution-limit`, DFS tends to exhaust open after diving deeply and leaves `*solution*` at the initial plan
- with a larger `solution-limit`, DFS runs longer but tends to hit `CPU-TIME-LIMIT-EXCEEDED` even on small cases such as `blocks` / `sussman`

So DFS is now available as an execution path, but it still needs separate tuning or investigation before it is a trustworthy diagnostic lever for `hanoi-4`.

## Current Conclusion

The best current classification for `hanoi-4` is:

- likely a search-growth and control-setting problem first
- not yet evidence of a major semantic break in the Hanoi domain encoding
- still worth revisiting after either:
  - improving the newly restored DFS path so it produces meaningful comparisons, or
  - adding more historically grounded benchmark expectations from the thesis and reports
