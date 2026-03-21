# Hanoi-4 Successful Combination Hypothesis

This note records the current best reading of which `hanoi-4`
hierarchy/control combinations were historically meant to work well, which of
those combinations are currently reconstructed in the repo, and which control
details may still be missing from the restored comparison surface.

It complements:

- [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [Hanoi-4 publication to code mapping](/Users/stevenwoods/mmath-renovation/docs/hanoi4-publication-to-code-mapping.md)
- [Hanoi tree-ordering evidence](/Users/stevenwoods/mmath-renovation/docs/hanoi-tree-ordering-evidence.md)
- [Hanoi-4 strategy crosswalk](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi-4 historical fidelity of the accounting split](/Users/stevenwoods/mmath-renovation/docs/hanoi4-historical-fidelity-of-accounting.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)

## Published Story

One scope distinction is now important:

- the original published numeric Hanoi rows align directly with the three-disk
  predicate family in
  [hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1)
- the current shipped four-disk benchmark in
  [hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1)
  is a later extension with added `onh`
- so the publication story below applies to `hanoi-4` primarily by hierarchy
  and control analogy, not as a direct row-for-row figure match
- the exact row-level publication reproduction now lives in
  [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)

The publication set does not support the claim that AbTweak should always beat
Tweak on `hanoi-4`. The stronger historical claim is narrower:

- `tweak` is a meaningful baseline and can outperform abstraction on poor
  hierarchies.
- good abstraction hierarchies can let AbTweak outperform Tweak.
- monotonic-property pruning and Left-Wedge are the main mechanisms behind the
  strong Hanoi results.

The checked-in Waterloo report and thesis point most strongly at these Hanoi
hierarchy families:

- good or near-best families:
  - `ILMS`
  - `IMLS`
  - also `ILSM` in some Left-Wedge discussion
- poor families:
  - `ISML`
  - `ISLM`

The same sources also indicate that:

- plain breadth-first AbTweak can be worse than Tweak on a bad hierarchy
- P-WMP can materially improve the good hierarchies
- Left-Wedge can be dramatically better on the good hierarchies

The checked-in thesis/report now support a more precise reading:

- the original published numeric Hanoi rows correspond directly to the
  three-disk predicate family now reproduced in
  [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- those rows show exactly the expected pattern: some hierarchy/control pairs
  are excellent, some are poor, and Left-Wedge plus P-WMP can be either very
  strong or very weak depending on hierarchy
- the shipped four-disk `hanoi-4` benchmark should therefore inherit the
  publication claim directionally, not numerically

The exact-to-analogue mapping is now documented separately in
[Hanoi-4 publication to code mapping](/Users/stevenwoods/mmath-renovation/docs/hanoi4-publication-to-code-mapping.md):

- publication `ILMS` maps exactly to code `IBMS` on `hanoi-3`
- four-disk families such as `critical-list-1`, `legacy-1991-default`,
  `imbs`, `ibsm`, `isbm`, and `ismb` are best treated as closest local
  extensions of those three-disk publication families
- `critical-list-2` is not a direct permutation-family row analogue

The directional result is much clearer than any one four-disk extrapolation:

- good hierarchy + P-WMP helps
- good hierarchy + Left-Wedge helps more
- bad hierarchy can make AbTweak worse than Tweak

## Reconstructed Control Surface

The current restored code base supports these `hanoi-4` control families:

| Family | Current support | Notes |
| --- | --- | --- |
| `tweak` baseline | yes | direct 1993 planner surface |
| plain `abtweak` | yes | direct 1993 planner surface |
| Left-Wedge | yes | direct 1993 planner surface |
| 1993 MP boolean mode | yes | direct 1993 planner surface |
| weak MSP `nec` | yes | via 1991 compatibility wrapper |
| weak MSP `pos` | yes | via 1991 compatibility wrapper |
| crit-depth mode | yes | via 1991 compatibility wrapper |
| strong MSP | yes | restored in the compatibility layer; representative Hanoi checks now run |
| alternate goal-ordering families | partial | `stack` and `tree` now run through the compatibility layer, but `tree` is not presently a better four-disk path |

The currently active four-disk hierarchy families are:

- `legacy-1991-default`
- `critical-list-1`
- `critical-list-2`
- `ismb`
- `isbm`
- `ibsm`
- `imbs`

## What Looks Historically Promising

Within the current reconstruction, the most promising `hanoi-4`
historically-shaped combinations are:

1. `isbm + weak-POS + Left-Wedge`
2. `ismb + weak-POS`
3. `ismb + MP + Left-Wedge`

What makes those three interesting is different:

- `isbm + weak-POS + Left-Wedge` is currently the best deeper-bounds runtime
  path in the reconstructed historical-control vocabulary.
- `ismb + weak-POS` and `ismb + MP + Left-Wedge` still show very strong
  pruning, which means they remain useful for understanding the historical
  abstraction advantage.

By contrast, the archived early four-disk default is now best read as a
historical baseline, not as the missing strong hierarchy.

## Likely Missing Historical Detail

The remaining gap no longer looks like "the port invented a new AbTweak."
The stronger remaining possibilities are:

1. The publication hierarchy labels are not yet mapped cleanly enough onto the
   exact four-disk hierarchy variants recovered in the code.
   The report's `ILMS` and `IMLS` families are clearly important, and the
   new mapping note now narrows the best local analogues substantially, but the
   four-disk line is still not a publication-exact row surface.
2. The thesis figures appear to involve explicit goal-ordering variants such as
   stack and tree goal ordering.
   Those controls are now runnable again through the compatibility layer, but
   the newer four-disk checks now suggest that tree is not a generic win:
   it is worse on the representative recovered `isbm` cases, flips against the
   `legacy-1991-default` hierarchy at deeper bounds, and currently looks most
   plausible only on `critical-list-2` under weak-`POS`.
   The preserved local batch corpus also now points the same way:
   the recovered Hanoi experiment drivers and result logs appear to inherit the
   default stack/`FIRST` selection mode unless explicitly changed, and we do
   not currently have a matching preserved `hanoi-4` batcher corpus showing
   tree as a dominant setting.

So the most plausible missing ingredients are not domain-specific hacks. They
are historically motivated control details that were present in the experiment
lineage but are not yet fully reconstructed in the current four-disk harness.

## Current Working Hypothesis

The best current hypothesis is:

- the modern SBCL restoration is broadly faithful to the historical AbTweak
  score shape and accounting rules
- the remaining `hanoi-4` gap is therefore more likely to be about incomplete
  recovery of the historically successful hierarchy/control combination than a
  gross modern regression in the base planner
- the next historically defensible things to recover are:
  - cleaner mapping from publication hierarchy labels to four-disk code
  - any goal-ordering controls that materially affected the thesis runs,
    especially where tree ordering might matter on a different hierarchy family
  - tighter mapping from the publication figure labels onto the recovered
    four-disk hierarchy names now that tree ordering itself is runnable again

There is also a clearer behavioral target now for what a good four-disk
hierarchy should induce.

The natural Hanoi strategy is recursive:

1. get the next-largest remaining disk onto the destination peg
2. then recurse on the smaller remaining tower

So a historically plausible four-disk hierarchy that really behaves well
should do more than rank disk families from large to small. It should make the
active problem at each level look like:

- disk-goal for the next-largest remaining disk
- paired support obligations that clear source and destination for that disk
- only after that, the recursive subproblem for the smaller disks

In other words, the hierarchy should make the planner see:

- "move `H` to `peg3`, with the needed clearance conditions"
- then "move `B` to `peg3`, with the needed clearance conditions"
- and so on

rather than simply:

- "reward lower `kval` concreteness and hope the right recursive behavior
  emerges"

That gives us a more rational target for future hierarchy work:

- not just better failed-run counts
- but a hierarchy definition that structurally encourages the same recursive
  decomposition that an ordinary Hanoi solver follows

This matters because a bounded failure with slightly lower generated-node
counts is still a benchmark failure. It may be diagnostically useful, but it
is not an improvement in the strict Hanoi sense unless it actually reaches the
goal configuration.

Until that reconstruction is done, the strongest current `hanoi-4` result
should be treated as "historically plausible but not yet publication-equivalent"
rather than as the final verdict on AbTweak's four-disk capability.
