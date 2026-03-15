# Algorithm Correspondence Review

This note compares the preserved historical AbTweak sources with the current SBCL working tree to answer a narrow question:

- are we still running the historical AbTweak algorithms, or
- has the working port drifted enough that it could invalidate comparisons with the published experiments?

The short answer is that the working `abtweak-1993` tree still corresponds closely to the historical `Abtweak-1993` algorithms. The main differences are compatibility repairs, loader fixes, and one precedence-graph optimization that was checked for semantic equivalence.

## Main Conclusions

1. The active `hanoi-4` domain and abstraction hierarchy still match the historical sources.
2. Most working-tree edits are Common Lisp compatibility fixes rather than planner redesign.
3. The one major algorithmic rewrite in the working tree is the precedence reachability test, but it preserves the same boolean relation and was introduced to stop the SBCL heap blow-up.
4. The biggest semantic difference in the working tree is in search-limit handling, not in AbTweak abstraction itself.
5. The current `hanoi-4` mismatch is therefore more likely to be about hierarchy choice, control settings, or remaining performance/fidelity gaps than a fundamentally different planner.

## Hanoi Hierarchy Correspondence

The key `hanoi-4` domain file is unchanged between the historical `Abtweak-1991-05`, `Abtweak-1992`, `Abtweak-1993`, and the current working tree:

- [historical/Abtweak/Abtweak-1991-05/Domains/hanoi-4.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Domains/hanoi-4.lsp#L1)
- [historical/Abtweak/Abtweak-1992/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1992/Domains/hanoi-4.lisp#L1)
- [historical/Abtweak/Abtweak-1993/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Domains/hanoi-4.lisp#L1)
- [working/abtweak-1993/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1)

That includes:

- the same operators
- the same initial and goal states
- the same default Hanoi abstraction hierarchy in `*critical-list-1*`
- the same alternate hierarchy definitions such as `*critical-list-2*` and `*ismb*`
- the same left-wedge list `*k-list-1*` and default `*left-wedge-list*`

The 1993 users manual describes the same style of Hanoi criticality assignment and left-wedge setup at [historical/Abtweak/Abtweak-1993/Doc/users-manual.tex](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Doc/users-manual.tex#L352).

So the current `hanoi-4` behavior is not explained by an accidental rewrite of the domain or its default abstraction hierarchy.

## Historical Evolution Before The Port

The historical snapshots already show some algorithm evolution before the modern SBCL work began.

### Precedence Test

The most important historical change happened between `Abtweak-1991-05` and `Abtweak-1992`:

- `Abtweak-1991-05` uses the older recursive `transitive-test-before-p` implementation in [historical/Abtweak/Abtweak-1991-05/Tw-routines/Plan-infer/plan-dependent.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Tw-routines/Plan-infer/plan-dependent.lsp#L107)
- `Abtweak-1992` explicitly notes a July 28, 1992 replacement from Leonard Dickens in [historical/Abtweak/Abtweak-1992/Tw-routines/Plan-infer/plan-dependent.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1992/Tw-routines/Plan-infer/plan-dependent.lisp#L3)
- `Abtweak-1993` keeps that updated version in [historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/plan-dependent.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/plan-dependent.lisp#L115)
- the 1993 tree also preserves alternative candidate implementations in [historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/precedence.leo1](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/precedence.leo1#L1), [historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/precedence.leo2](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/precedence.leo2#L1), and [historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/precedence.old](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Tw-routines/Plan-infer/precedence.old#L1)

This matters for interpretation: the published 1991 experimental results are closer in time to the `1991-05` code than to the later `1992/1993` precedence cleanup.

### Search Driver

The search driver also evolved historically between `1991-05` and `1993`:

- `1991-05` uses the simpler `search` entry point in [historical/Abtweak/Abtweak-1991-05/Search-routines/search.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Search-routines/search.lsp#L1)
- `1993` has the richer `A-search` driver with BFS/DFS support and DRP handling in [historical/Abtweak/Abtweak-1993/Search-routines/search.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Search-routines/search.lisp#L1)

So some behavior changes are already part of the historical 1993 baseline and are not SBCL-port inventions.

## Working Tree Changes Vs Historical 1993

### Compatibility-Only Or Near-Compatibility Changes

Most edits in the working copy fall into one of these buckets:

- replacing brittle `array` type declarations with `plan` or `operator`
- widening declarations that were too narrow for actual historical return values
- changing backquoted lambdas to function objects with `#'`
- adding `defvar` declarations for historical specials
- loading support files earlier under SBCL
- restoring missing loader entries such as [working/abtweak-1993/Search-routines/init.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/init.lisp#L1) loading `stack-list-access`

Representative files:

- [working/abtweak-1993/Ab-routines/ab-successors.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-successors.lisp#L1)
- [working/abtweak-1993/Ab-routines/ab-general.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-general.lisp#L1)
- [working/abtweak-1993/Tw-routines/Succ/find-new-ests.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Succ/find-new-ests.lisp#L1)
- [working/abtweak-1993/Tw-routines/Plan-infer/plan-inference.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Plan-infer/plan-inference.lisp#L1)
- [working/abtweak-1993/init-sbcl.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/init-sbcl.lisp#L1)
- [working/abtweak-1993/sbcl-specials.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/sbcl-specials.lisp#L1)
- [working/abtweak-1993/sbcl-forward-decls.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/sbcl-forward-decls.lisp#L1)

These changes can affect whether SBCL accepts and runs the code, but they do not amount to a new planning algorithm.

### Precedence Reachability Rewrite

The biggest working-tree change is in [working/abtweak-1993/Tw-routines/Plan-infer/plan-dependent.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Plan-infer/plan-dependent.lisp#L115).

Historical `1993` uses Leonard Dickens's recursive reachability test. The working tree uses an iterative sweep-and-mark graph walk. The reason for the rewrite was practical:

- the historical implementation was a major hotspot on Hanoi
- one alternative historical implementation explicitly copies the ordering graph and was preserved in `precedence.leo2`
- under SBCL, high-bound `hanoi-4` AbTweak runs could exhaust the heap in precedence-heavy search before returning a planner result

To check whether the new implementation changed semantics, I compared the old recursive `1993` version and the new working version on 200,000 randomized `(op1, op2, pairs)` reachability queries in SBCL. Result:

- `tests = 200000`
- `mismatches = 0`

So this change looks like a semantic preservation of the historical precedence relation, with better runtime stability.

### Search Loop Changes That Do Affect Semantics

The working [Search-routines/search.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/search.lisp#L1) differs from the historical `1993` version in a few ways that are not just cosmetic:

1. open exhaustion now records `OPEN-EXHAUSTED`
2. `generate-bound` now returns `GENERATE-LIMIT-EXCEEDED`
3. `open-bound` now returns `OPEN-LIMIT-EXCEEDED`
4. `solution-limit` no longer forcibly empties `*open*` and sets `*num-expanded*` to `-1`; it now prunes successor generation for that over-limit node and lets the rest of the search continue

That fourth item is a real semantic change. It was made to get clearer modern failure behavior and to avoid misleading search state under SBCL.

For the current `hanoi-4` diagnosis, this probably is not the main explanation because:

- the historical and working defaults both use `:solution-limit 100`
- a four-disk Hanoi solution is far shorter than that
- our main `hanoi-4` BFS comparisons are failing on expansion growth well before a realistic solution-length cap would be the bottleneck

Still, it is one working-tree difference worth remembering if we compare runs that intentionally use very small `solution-limit` values, especially DFS diagnostics.

## What Has Not Fundamentally Changed

Across the preserved 1993 code and the working tree, the following core ideas remain the same:

- Tweak-style partial-order planning
- AbTweak refinement through criticality levels
- left-wedge heuristic adjustment via `*left-wedge-list*`
- monotonic-property handling and causal-relation bookkeeping
- the default Hanoi domain and default criticality assignments

The working tree is not using a different domain model, a different abstraction formalism, or a different planner architecture.

## What This Means For Hanoi-4

The current evidence points away from “wrong algorithm” and toward “wrong effective search behavior for this benchmark.”

The strongest current interpretation is:

- the working tree still corresponds to the historical AbTweak algorithm family
- the `hanoi-4` domain and default hierarchy are still the historical ones
- the main repaired precedence change preserves historical reachability semantics
- the remaining `hanoi-4` gap is more likely due to
  - control-setting fidelity,
  - hierarchy quality relative to the published experiments,
  - untested hierarchy permutations,
  - or remaining performance-sensitive behavior in the restored search path

## Recommended Follow-Up

1. Reconstruct the exact Hanoi hierarchy variants and permutations discussed in the reports and thesis, rather than testing only the default `*critical-list-1*`.
2. Add scripted `hanoi-4` runs for `*critical-list-1*`, `*critical-list-2*`, and `*ismb*`, with MP and left-wedge toggles.
3. Keep treating the working precedence rewrite as a runtime repair, not as evidence of a changed planner algorithm, unless a counterexample appears.
