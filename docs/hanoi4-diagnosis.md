# Hanoi-4 Diagnosis

This note records the current diagnosis for the `hanoi-4` benchmark under the restored `Abtweak-1993` SBCL port.

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 frontier replay](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-replay.md)
- [Hanoi-4 score sensitivity](/Users/stevenwoods/mmath-renovation/docs/hanoi4-score-sensitivity.md)
- [Hanoi-4 insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [Hanoi-4 lineage trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md)
- [Hanoi-4 lineage divergence](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-divergence.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md)
- [Hanoi-4 optimal projection report](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/hanoi4-optimal-projection.md)

## Current Result

Under the currently restored search paths:

- `hanoi4-tweak` reaches `EXPAND-LIMIT-EXCEEDED`
- `hanoi4-abtweak` also reaches `EXPAND-LIMIT-EXCEEDED` at the standard exploratory bounds
- `hanoi4-abtweak` with `:left-wedge-mode nil` still reaches `EXPAND-LIMIT-EXCEEDED`
- raising the exploratory bounds to `100000` expansions does not produce a plan in `tweak`
- after replacing the precedence reachability test with a copy-free graph walk in the working tree, raising the same high bounds in `abtweak` with default MP no longer exhausts the SBCL heap
- both the default MP run and the `:mp-mode nil` run now fall back to `EXPAND-LIMIT-EXCEEDED`
- a DFS `abtweak` run with `:solution-limit 8` now ends in `OPEN-EXHAUSTED` rather than crashing
- after reducing allocator churn in ordering cleanup, precedence-neighbor collection, and MP violation checking, `ismb` with MP and left-wedge enabled now reaches clean bounded termination at both `150000` and `200000` expansions instead of exhausting the default SBCL heap sooner
- `ismb` with `:drp-mode t` still does not solve, but it now reports `OPEN-EXHAUSTED` honestly instead of leaving the untouched initial plan in `*solution*`

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
| `abtweak`, `ismb`, mp, left-wedge | `150000` | `150001` | `184610` | not captured in the ad hoc runner | `EXPAND-LIMIT-EXCEEDED` |
| `abtweak`, `ismb`, mp, left-wedge | `200000` | `200001` | `243578` | not captured in the ad hoc runner | `EXPAND-LIMIT-EXCEEDED` |

Observed DFS run:

| Config | Control strategy | Expanded | Generated | Outcome |
| --- | --- | --- | --- | --- |
| `abtweak` | `dfs`, `:solution-limit 8` | `6415` | `6414` | `OPEN-EXHAUSTED` |
| `abtweak`, `ismb`, mp, left-wedge, `:drp-mode t` | `bfs` | `7558` | `7558` | `OPEN-EXHAUSTED` |

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
- The strongest current hierarchy is now stable at substantially larger bounds than before:
  - `ismb` plus MP and left-wedge now survives to `150000` and `200000` expansions without exhausting the default SBCL heap
  - by contrast, `critical-list-2` can still exhaust the default heap by `150000`, so `ismb` is now clearly the better current restoration target
- The working-vs-historical algorithm review now strengthens the diagnosis:
  - the active `hanoi-4` domain and default hierarchy match the archival snapshots
  - the main working-tree precedence rewrite preserves the historical precedence relation on randomized equivalence checks
  - the search gap therefore looks more like a control or fidelity problem than a replaced planner algorithm
- The new hierarchy comparison sharpens that further:
  - `critical-list-1` still behaves like a poor hierarchy
  - `critical-list-2` and especially `ismb` now show the kind of MP-sensitive improvement the historical work would lead us to expect
  - the best 20k-bound configuration so far is `ismb` with MP enabled
  - the new historical-control comparison sharpens it again:
    - the archived `legacy-1991-default` four-disk hierarchy is clearly weaker than both `ismb` and `isbm`
    - under the same historical vocabulary at the original 20k bound, `ismb` remains slightly better on raw generated-node count
    - weak-`POS` helps `isbm` much more than `ismb`, and the deeper harness-native traces now show that `isbm` overtakes `ismb` by `50000` and stays ahead at `100000`
    - crit-depth remains materially worse than weak MSP for both of those hierarchies
    - frontier tracing under weak-`POS` now makes the tradeoff more concrete:
      - `ismb` still prunes harder, but its top frontier bucket remains dominated by dirty `kval 0` states with roughly `11` to `16` unsatisfied pairs
      - `isbm` keeps much cleaner states in the top bucket, often around `3` to `6` unsatisfied pairs, and retains its best `2`-unsatisfied node there as well
      - that cleaner frontier is no longer coming at a raw-search cost penalty once the weak-`POS` runs are pushed to `50000` and `100000`
    - the weak-`NEC` versus weak-`POS` follow-up now suggests why:
      - on `isbm`, weak-`POS` cuts generated nodes and open-node count substantially without changing the abstraction branching counts
      - on `ismb`, weak-`POS` barely changes either
      - this points to a pruning effect inside the same hierarchy, not a different hierarchy tree
      - the likely reason is that `isbm` lifts `onb` above `onm`, giving weak-`POS` more leverage to prune medium-disk concrete churn that might interfere with higher-level big-disk commitments
- Direct frontier inspection now narrows the likely failure mode:
  - the best-looking `ismb` frontier nodes are not one-step-away solutions
  - the first open node at the 20k bound has cost `15` and length `17`, but still `15` unsatisfied necessary preconditions
  - the highlighted `(ISPEG $var)` case is semantically valid and branches into the two expected existing-establisher refinements from `I`
  - that makes the remaining `hanoi-4` gap look more like heuristic and control quality than a broken establisher path
  - a direct frontier-quality pass now sharpens that further:
    - the best priority bucket is dominated by concrete `kval 0` move skeletons with roughly `9` to `17` unsatisfied user/precondition pairs
    - the best closure-oriented node in the same frontier has only `2` unsatisfied pairs, but sits in a worse priority bucket at higher abstraction
    - that suggests the active ranking is favoring concreteness more than closure quality
  - a matching `tweak` frontier trace makes that result more specific:
    - `tweak` still has a much larger frontier at the same 20k bound
    - but its best closure-oriented nodes remain in the same top priority bucket as the rest of the best-ranked frontier
    - the bucket-separation effect currently looks specific to the restored `abtweak` path rather than a generic `hanoi-4` property
  - the latest score breakdown now gives a concrete mechanism for that effect:
    - AbTweak priority is `search-cost + num-of-unsat-goals + left-wedge-adjustment`
    - the top `kval 0` nodes often have base goal heuristic `0` and left-wedge adjustment `-7`
    - cleaner `kval 1/2` nodes can still lose because unresolved non-goal obligations are not represented in the score

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
- the latest cleanup pass sharpens the remaining hotspot:
  - the old ordering-cleanup allocator path no longer stops `ismb` at the earlier point
  - `critical-list-2` still shows heap growth in the MP violation path, while `ismb` now gets through that same general region much more cleanly

## External Baseline Sanity Check

A retained side experiment now gives us plain state-space Hanoi baselines in
[analysis/hanoi-baselines/standard-transfer.md](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/standard-transfer.md#L1).

Those results are not directly comparable to AbTweak node counts, because they
operate on ordinary puzzle states rather than least-commitment partial plans.
But they are still useful as a sanity check:

- plain graph-search BFS solves standard `hanoi-4` at depth `15`
- plain graph-search DFS also solves it, though with a longer `27`-move path
- plain graph-search A* solves it at depth `15`

That strengthens the case that the current restored-planner failure is not
explained by the four-disk transfer problem being intrinsically difficult in a
generic search sense. The remaining gap is much more likely to be about the
planner's search/control behavior than about the existence of a reachable
solution.

The new optimal projection report sharpens the hierarchy story too:

- under `critical-list-1`, the highest visible goal slice (`H3`) is not first
  reached until the midpoint `H` move at step `8`
- under `ismb`, the visible `k2` and `k1` goal slices are first reached very
  early, already by step `3`
- under `isbm`, the top visible `k2` slice still reaches early, but the `k1`
  visible goal slice (`B3 S3`) is not first reached until the final step `15`

That makes `isbm` look structurally less prone to "early apparent progress"
than `ismb` on the optimal path itself, which is at least directionally
consistent with the cleaner `isbm` frontier we now see in the restored runs.

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
- more specifically, a search-quality problem among valid but heavily underconstrained partial plans
- no longer reproducing the earlier MP / ordering heap blow-up under the same high-bound SBCL run
- not evidence of a major semantic break in the Hanoi domain encoding itself
- not presently explained by a fundamental rewrite of the archived AbTweak algorithms in the working tree
- best revisited next as a hierarchy-quality, heuristic-quality, and historical-validation problem rather than a fatal-runtime bug
- current strongest historical-control path: `isbm` with weak-`POS` and Left-Wedge, because it improves further over the no-left-wedge `isbm` weak-`POS` line at `20000`, `50000`, and `100000`
- even that strongest current path still reaches `EXPAND-LIMIT-EXCEEDED` at `200000`, with `234872` generated and `224678` MP prunes
- plain `tweak` still does not solve `hanoi-4` in the restored code on the practical modes tested so far:
  - BFS still fails at the higher exploratory bounds
  - DFS with `:solution-limit 20` also fails at `50001` expanded / `50020` generated
- the new frozen-frontier replay experiment sharpens the `tweak` / `abtweak`
  split further:
  - under a neutral replay policy, all sampled `tweak` frontier nodes remain
    live to the replay bound
  - under the same replay policy, most sampled `abtweak` frontier nodes die
    quickly with `OPEN-EXHAUSTED`
- the replay-dead `abtweak` states are typically heavily concretized
  `kval 0` move skeletons around cost `14`, length `16`, and roughly `12` to
  `22` unsatisfied pairs
- the healthiest sampled `abtweak` replay is a cleaner `kval 2` state with
  cost `6`, length `8`, and only `2` unsatisfied pairs
- the new score-sensitivity pass makes the mechanism much more specific:
  - the best closure-oriented node sits at actual rank `1149`
  - without left-wedge, that same node jumps to rank `1`
  - with an unsat-aware score, it also jumps to rank `1`
  - the actual top-ranked node falls from rank `1` to rank `71` without
    left-wedge and to rank `724` under the unsat-aware score
  - the top-20 actual frontier and the top-20 no-left-wedge frontier have
    `0 / 20` overlap
- that makes the remaining gap look more like frontier-quality brittleness in
  the restored `abtweak` path than a generic inability to continue from any
  `hanoi-4` partial plan
- the new insertion-time score trace narrows that diagnosis again:
  - the insertion bias is real, but much less extreme than the final frontier
    distortion
  - the best closure-oriented inserted node is still actual rank `4`, not
    buried deep in the search immediately
  - the actual top inserted node is already a `kval 0` state helped strongly
    by left-wedge, but it is still relatively healthy compared with the later
    frontier leaders
  - this suggests the worst `hanoi-4` ranking problem compounds over repeated
    refinement steps rather than appearing fully formed at first insertion
- the new lineage trace strengthens that further:
  - the top dirty frontier leaders now have reconstructible long low-`kval`
    ancestry chains
  - along those chains, unsatisfied-pair counts steadily worsen while the
    actual score remains attractive
  - the healthiest closure-oriented frontier node keeps a much shorter and
    cleaner abstract lineage
  - so the current failure looks more like compounding overconcretization than
    a single bad expansion or a single catastrophically bad insertion event
- the new divergence note localizes the first clear fork:
  - around insertion `6137` to `6157`, a healthy `kval 2` continuation and a
    concretized `kval 1` continuation have almost the same closure quality
  - the concretized continuation wins immediately because its Left-Wedge
    adjustment is much stronger
  - the same effect repeats when the line is reinserted at `kval 0`, where
    unresolved obligations get worse but the actual score improves again
- most immediate open question: can the better-scaling `isbm` weak-`POS` path be pushed from cleaner bounded failure into a full solve, or explain more exactly why it still does not close
