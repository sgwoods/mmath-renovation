# Left-Wedge Intent Comparison

This note compares the currently observed `hanoi-4` Left-Wedge behavior under
SBCL with the historical intent described in the users manual, report, and
thesis.

It answers a narrow question:

- is the strong preference for more refined plans actually what Left-Wedge was
  meant to do?
- and if so, does the current `hanoi-4` behavior look historically plausible or
  suspicious?

It complements:

- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Publications index](/Users/stevenwoods/mmath-renovation/publications/README.md)

## Short Answer

Yes: the observed Left-Wedge pressure toward more refined plans is historically
intended.

The historical sources explicitly say that Left-Wedge is supposed to give
priority to plans that are more refined, meaning lower in the abstraction
hierarchy. The current traced `hanoi-4` score behavior is therefore not itself
evidence of a porting bug.

However, the same sources also say that this preference helps only on good
abstraction hierarchies. On bad hierarchies, Left-Wedge can be worse than
breadth-first abstract planning. So the currently observed `hanoi-4` behavior is
best read as:

1. the raw Left-Wedge bias is historically correct
2. the remaining question is whether the hierarchy and control setup we are
   using is the kind of case where that bias should help or hurt

## What The Historical Sources Say

### Users Manual

The 1993 users manual describes Left-Wedge as a cost adjustment that explicitly
rewards deeper refinement levels.

In [historical/Abtweak/Abtweak-1993/Doc/users-manual.tex](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Doc/users-manual.tex#L376):

- the planner is said to "heavier invest" in the first abstract solution and
  its refinements
- the `i`th left-wedge value `v_i` adjusts plan cost by `cost(plan) - v_i`
- the Hanoi example uses `*left-wedge-list* '(0 1 3 7)`

That is exactly the shape of the current traced score:

- `kval 0` Hanoi plans receive the largest negative adjustment
- higher abstraction levels receive smaller negative adjustments

So the current numeric behavior is consistent with the manual's stated design.

### 1991 Technical Report

The report says Left-Wedge was designed for good hierarchies because early
choices are less likely to be abandoned there.

The statement is explicit in the report:

- Left-Wedge "gives priority to those plans that are most refined" and prefers
  pushing deeper into refinements while still considering abstract alternatives.
  Source: [TR-91-65](https://cs.uwaterloo.ca/research/tr/1991/65/final.pdf)
- With good abstraction hierarchies, Left-Wedge "improves search efficiency
  dramatically" over straightforward breadth-first search. Source:
  [TR-91-65](https://cs.uwaterloo.ca/research/tr/1991/65/final.pdf)
- But on a poorly chosen hierarchy, AbTweak with MP and Left-Wedge can perform
  worst. Source: [TR-91-65](https://cs.uwaterloo.ca/research/tr/1991/65/final.pdf)

Those source passages are summarized in:

- [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md#L18)

### Thesis

The thesis makes the tradeoff even more explicit:

- good Hanoi hierarchies solve hard disk-placement problems first
- bad Hanoi hierarchies solve the easier small-disk problems first and leave the
  hard medium/big-disk work to the end
- with good hierarchies, Left-Wedge plus MP is often the best performer
- with bad hierarchies, Left-Wedge can search more than breadth-first

That historical summary is especially clear in the thesis conclusion passages
already reflected in:

- [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md#L22)
- [docs/hanoi4-hierarchy-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md#L127)

## What We Observe Now

From the current traced `hanoi-4` frontier behavior:

- AbTweak priority is `search-cost + num-of-unsat-goals + left-wedge-adjustment`
- the base heuristic only counts unsatisfied goal literals
- unresolved non-goal user/precondition obligations are not directly scored
- the top `kval 0` nodes often have left-wedge adjustment `-7`
- some cleaner `kval 1/2` nodes lose because their left-wedge bonus is much
  smaller

See:

- [docs/hanoi4-frontier-quality.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md#L128)

## Comparison Against Historical Intent

| Question | Historical intent | Current `hanoi-4` observation | Interpretation |
| --- | --- | --- | --- |
| Should Left-Wedge prefer more refined plans? | Yes | Yes | Matched |
| Should lower `kval` plans get stronger cost preference? | Yes | Yes | Matched |
| Is that preference always beneficial? | No | No | Matched in spirit |
| Can Left-Wedge be worse on bad hierarchies? | Yes | Plausible for some current Hanoi settings | Historically plausible |
| Does the current score ignore some unresolved obligations? | Not discussed directly in the papers, but compatible with goal-count heuristic design | Yes | Important current diagnostic detail |

## Current Best Reading

The strongest current interpretation is:

1. The Left-Wedge bias we are seeing is not a surprise or a bug by itself.
2. The sources strongly support the idea that this bias is supposed to help only
   when the hierarchy already encodes good control knowledge.
3. Our current `hanoi-4` traces show that the bias is strong enough to dominate
   the goal-count heuristic.
4. That makes the remaining restoration question more specific:
   - are we using a historically good hierarchy/control combination for this
     four-disk case, or
   - are we seeing the historically expected downside of Left-Wedge on a poor or
     mismatched hierarchy?

## Practical Consequence

This comparison suggests that the next best work is not to remove or weaken
Left-Wedge immediately.

Instead, the right next questions are:

1. Compare the currently traced `hanoi-4` Left-Wedge behavior with the exact
   hierarchy families the thesis treats as good and bad.
2. Check whether the current `ismb` and `critical-list-2` results correspond to
   historically intended good-hierarchy cases, or to something more accidental
   in the four-disk extension.
3. Only after that, decide whether there is a real implementation mismatch in
   the restored search control.
