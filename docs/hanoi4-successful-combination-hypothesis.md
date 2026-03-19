# Hanoi-4 Successful Combination Hypothesis

This note records the current best reading of which `hanoi-4`
hierarchy/control combinations were historically meant to work well, which of
those combinations are currently reconstructed in the repo, and which control
details may still be missing from the restored comparison surface.

It complements:

- [Hanoi-4 strategy crosswalk](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi-4 historical fidelity of the accounting split](/Users/stevenwoods/mmath-renovation/docs/hanoi4-historical-fidelity-of-accounting.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)

## Published Story

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

The thesis OCR text suggests a representative `hanoi-4` outcome pattern of
roughly:

- `tweak`: about `524` expanded
- plain `abtweak` on a poor hierarchy: about `723` expanded
- AbTweak with P-WMP on a good hierarchy: about `314` expanded
- AbTweak with Left-Wedge on a good hierarchy: about `82` expanded

Those exact digits should still be treated as publication-derived but
OCR-mediated until they are transcribed directly from the figures. The
directional result is much clearer than the exact numbers:

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
| strong MSP | not yet | historically present in 1991 control vocabulary, not yet reconstructed |
| alternate goal-ordering families | uncertain | referenced in thesis figure labels, not yet isolated as harness-level controls |

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
   The report's `ILMS` and `IMLS` families are clearly important, but the best
   current reconstructed four-disk path is `isbm`, which is only a partial
   naming match rather than a proved publication-equivalent hierarchy.
2. The thesis figures appear to involve explicit goal-ordering variants such as
   stack and tree goal ordering.
   Those labels are visible in the extracted thesis text, but we have not yet
   recovered them as named runnable controls in the current harness.
3. The 1991 control surface included `strong` MSP in addition to weak `NEC`
   and weak `POS`.
   The current compatibility layer restores weak `NEC`, weak `POS`, and
   crit-depth, but not `strong`.

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
  - any goal-ordering controls that materially affected the thesis runs
  - `strong` MSP, if the archived code still supports enough of it to rebuild

Until that reconstruction is done, the strongest current `hanoi-4` result
should be treated as "historically plausible but not yet publication-equivalent"
rather than as the final verdict on AbTweak's four-disk capability.
