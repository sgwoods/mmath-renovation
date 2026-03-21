# Hanoi-4 Headway Assessment

This note summarizes how much progress the project has made on the open
`hanoi-4` issue so far.

It complements:

- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)
- [Hanoi tree-ordering evidence](/Users/stevenwoods/mmath-renovation/docs/hanoi-tree-ordering-evidence.md)
- [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)

## Short Answer

We have made substantial headway on `hanoi-4`, even though the full four-disk
benchmark still does not solve in the restored planner.

The issue has moved from:

- "the larger Hanoi case is broken somehow"

to:

- "the restored planner is stable and historically plausible, but the exact
  four-disk hierarchy/control combination behind the successful behavior is
  still not fully reconstructed"

That is real progress.

## What Is Already Achieved

### 1. The runtime path is stable

We are no longer dealing with a loader failure or a fatal runtime blow-up as
the main story.

Progress made:

- fixed the earlier precedence-heavy heap failure
- restored honest failure signaling for bounded search and DRP paths
- restored DFS enough to use it diagnostically again
- confirmed that both `tweak` and `abtweak` can run the benchmark cleanly

So the open issue is now planner behavior, not whether the code can run.

### 2. The historical baseline is much clearer

We now know far more than we did at the start about what `hanoi-4` should and
should not mean historically.

Progress made:

- `hanoi-2` is now an exact archived-family rerun
- `hanoi-3` now reproduces the thesis figure rows directly on the original
  published hierarchy family
- `hanoi-4` is now clearly understood as a later historically grounded
  extension, not a figure-for-figure publication rerun

That matters because it keeps the `hanoi-4` problem in proportion:
it is the main open extension benchmark, not evidence that the published Hanoi
results were not reproduced.

### 3. The algorithm-drift suspicion is much weaker

We have done a meaningful amount of work ruling out the simplest
"maybe the port changed AbTweak too much" explanation.

Progress made:

- checked the working tree against the preserved `1993` algorithms
- confirmed the domain and abstraction structure correspond closely to the
  archived code
- checked the main precedence rewrite for behavioral equivalence
- confirmed the score/accounting split is historically inherited rather than a
  modern SBCL invention

So the live issue looks much more like incomplete control reconstruction than
like a gross planner rewrite.

### 4. The search failure is much better localized

The issue is no longer just "it hits the bound."

Progress made:

- frontier forensics showed the near-complete frontier states are valid partial
  plans, not obviously malformed ones
- replay experiments showed sampled `tweak` frontier nodes stay live much more
  reliably than sampled `abtweak` frontier nodes
- score-sensitivity work showed the clean closure-oriented nodes are being
  ranked far too low under the current Left-Wedge-weighted score
- lineage tracing showed the dirty frontier leaders arise through long
  low-`kval` refinement chains rather than one catastrophic step
- reinsertion analysis showed the same branch keeps winning as it drops levels
  even while the visible obligation picture becomes dirtier

So the failure is now localized to a historically inherited control/ranking
shape rather than a generic semantic mystery.

### 5. The hierarchy/control search space has been narrowed

We now have a much smaller and more meaningful set of live `hanoi-4`
candidates.

Progress made:

- identified `isbm + weak-POS + Left-Wedge` as the strongest current
  historical-control runtime path
- identified `ismb + MP + Left-Wedge` as the strongest current 1993-style path
- showed that the old four-disk default is not the leading strong hierarchy
- restored `strong` MSP
- restored tree goal ordering
- showed that tree is not a generic improvement and currently looks narrowest
  on `critical-list-2 + weak-POS`

That is a major narrowing of the search space.

## What Has Been Ruled Out

These explanations are now much less likely than they were earlier:

- "the port simply does not run the planner"
- "the benchmark only fails because of the precedence memory bug"
- "the benchmark fails because the planner cannot load historical controls"
- "tree ordering is obviously the missing ingredient"
- "the published Hanoi results themselves were not reproduced"
- "the current issue is probably just that Hanoi-4 is generically hard"

The external state-space baselines are especially important for that last point:
plain BFS/DFS/A* solve the same puzzle comfortably.

## What Is Still Open

The main open questions are now narrower and more historically grounded:

1. Which recovered four-disk hierarchy best corresponds to the publication-side
   good families such as `ILMS` and `IMLS`?
2. Is the strongest current stack-first path already the right historical
   direction, but still missing one more control detail?
3. Does the publication-side tree-ordering discussion point to a narrow
   hierarchy-and-control family strongly enough to matter for four-disk runs?
4. If not, is the correct conclusion that the preserved four-disk extension was
   simply never as strong in the local code line as the lower Hanoi families?

## Overall Assessment

Against the primary project goals, `hanoi-4` is now in a much better state
than before.

Assessment by goal:

- restore the code so it runs: strong progress
- restore historically important controls: strong progress
- reproduce the published Hanoi story: strong progress on `hanoi-2` and
  `hanoi-3`, partial on `hanoi-4`
- understand the remaining gap rather than just observing failure:
  strong progress
- reach a final four-disk result: still open

So the right overall assessment is:

- not solved yet
- but well past the exploratory stage
- and now close to a constrained historical-validation problem rather than a
  vague runtime-recovery problem
