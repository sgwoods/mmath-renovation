# Hanoi-4 Hierarchy Experiment Plan

This note captures the next disciplined step for `hanoi-4`:

- keep the restored `AbTweak-1993` baseline historically clean
- explore whether alternative hierarchy descriptions produce better
  four-disk behavior
- separate historically grounded analogue variants from later experimental
  extensions

It complements:

- [Algorithm strategy policy](/Users/stevenwoods/mmath-renovation/docs/algorithm-strategy-policy.md)
- [Hanoi-4 publication to code mapping](/Users/stevenwoods/mmath-renovation/docs/hanoi4-publication-to-code-mapping.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)

## Goal

The goal is not to invent a domain-specific hack for `hanoi-4`.

The goal is to test whether a more effective four-disk hierarchy description
can be recovered or designed while preserving the historical restoration
boundary:

- first by testing historically plausible four-disk analogue hierarchies
- only later, if needed, by testing clearly named non-historical extensions

One evaluation rule should now be explicit:

- a bounded failure is still a failure
- lower generated or expanded counts on an unsolved run are diagnostic evidence,
  not benchmark progress
- for `hanoi-4`, a hierarchy is only a real benchmark improvement if it
  actually produces a full solve

## Design Principles

The current `hanoi-4` evidence suggests that a better hierarchy should do at
least some of the following:

1. delay cheap-looking apparent progress
   - especially early `k1` or `k0` drops that Left-Wedge rewards too strongly
2. expose commitments that weak pruning can protect
   - especially where weak-`POS` can prune medium-disk churn against higher
     big-disk commitments
3. avoid collapsing too much real work into `k0`
   - especially by leaving all `onh` structure until the concrete level
4. remain understandable in terms of the historical publication family
   - so we can still explain the result against the thesis and report

## Behavioral Target

The behavioral target should be the natural recursive Hanoi strategy:

1. move the largest remaining disk to the destination peg
2. then recurse on the smaller remaining tower

In the current predicate language, that means a useful hierarchy should not
merely reward "more concrete plans." It should encourage the planner to treat
the next-largest remaining disk and the conditions for moving it as the active
problem.

For the largest disk family, that means a rational abstraction should make it
look something like:

- primary commitment:
  - `(onh peg3)`
- support obligations for that commitment:
  - source and destination must be clear of smaller disks
  - but those support obligations should be seen as enabling conditions for the
    `onh` commitment, not as independent low-level churn opportunities

Then, once `H` is placed, the same pattern should recur for `B`, then `M`,
then `S`.

So the hierarchy shape we want is not just:

- "largest disk high, smallest disk low"

It is closer to:

- "at each level, the active disk-goal and the clearance obligations required
  to move that disk are coupled tightly enough that the planner behaves
  recursively"

That is the practical meaning of a "rational" four-disk hierarchy here.

## Two Experiment Buckets

### Bucket A: Historical-Analogue Variants

These are acceptable within the historical restoration story as long as they
are documented as analogues, not exact recovered rows.

They should:

- use the existing AbTweak control surface
- preserve the same scoring and successor logic
- differ only in hierarchy description
- be explained as plausible four-disk extensions of the published three-disk
  family

### Bucket B: Named Extension Variants

These are allowed only if Bucket A fails to produce a convincing result.

They must:

- carry a distinct strategy name under the policy in
  [Algorithm strategy policy](/Users/stevenwoods/mmath-renovation/docs/algorithm-strategy-policy.md)
- be evaluated against the already matched baseline benchmarks
- never be described as the restored historical AbTweak baseline

## Candidate Bucket-A Variants

These are the most interesting next hierarchy experiments.

### A1. `isbm-h1`

Idea:

- start from `isbm`
- keep `S` above `B`
- keep `B` above `M`
- introduce `H` explicitly on its own non-concrete level between `S` and `B`

Rationale:

- preserves the cleaner frontier behavior of `isbm`
- avoids leaving all `H` work at `k0`
- still looks like a plausible four-disk extension of the `ISBM` family

Initial result:

- implemented in the working tree and tested at the standard 20k bound
- weak-`POS`, stack, no Left-Wedge: `26535` generated versus `24748` for
  `isbm`
- weak-`POS`, stack, Left-Wedge: `25259` generated versus `23272` for `isbm`
- so the first explicit-`H` insertion is historically interesting, but not a
  performance improvement over the current `isbm` baseline

### A2. `isbm-hb`

Idea:

- start from `isbm`
- group `H` with `B`

Rationale:

- makes the large-disk commitment visible alongside the big-disk family
- may give weak pruning more leverage earlier
- still keeps the `S > B > M` shape that looks healthiest in the current traces

Initial result:

- required a small baseline bookkeeping fix so grouped-level hierarchies are
  sized by max criticality plus one, not just by the number of critical-list
  entries
- weak-`POS`, stack, no Left-Wedge: `26479` generated versus `24748` for
  `isbm`
- weak-`POS`, stack, Left-Wedge: `24745` generated versus `23272` for `isbm`
- so grouping `H` with `B` is cleaner than the first `isbm-h1` insertion, but
  it is still not an improvement over the current `isbm` baseline

### A3. `imbs-h1`

Idea:

- start from `imbs`
- introduce `H` explicitly at level `1`

Rationale:

- gives us a direct four-disk test of the other publication-good family
  analogue line
- useful because the publication-side “good” discussion is centered on
  `ILMS` / `IMLS`, not only on the `ISBM`-style family

Initial result:

- implemented in the working tree and tested at the standard 20k bound
- weak-`POS`, stack, no Left-Wedge: `24132` generated versus `33992` for
  plain `imbs`
- weak-`POS`, stack, Left-Wedge: `23810` generated versus `34067` for plain
  `imbs`
- this is the first explicit-`H` analogue that materially improves its parent
  family
- it also beats the current `isbm` path on the no-Left-Wedge weak-`POS` line
  (`24132` versus `24748`), though it still trails `isbm + weak-POS +
  Left-Wedge` (`23810` versus `23272`)
- deeper Left-Wedge follow-up:
  - `50000`: `60971` generated versus `58817` for `isbm`
  - `100000`: `121223` generated versus `116646` for `isbm`
  - `200000`: default 1 GiB SBCL heap exhaustion in MP checking; with a 2 GiB
    heap, still `EXPAND-LIMIT-EXCEEDED` at `241472` generated
- so `imbs-h1` remains diagnostically interesting, but it is not a better
  `hanoi-4` solving path under the stronger historical controls

### A4. `imbs-hb`

Idea:

- start from `imbs`
- group `H` with `B`

Rationale:

- same motivation as `isbm-hb`, but on the `IMBS` side of the analogue family
- lets us compare whether explicit `H` helps more on a medium-first or
  small-first hierarchy

Initial result:

- implemented in the working tree and tested at the standard 20k bound
- weak-`POS`, stack, no Left-Wedge: `26598` generated versus `33992` for
  plain `imbs`
- weak-`POS`, stack, Left-Wedge: `33415` generated versus `34067` for plain
  `imbs`
- so `imbs-hb` still improves plain `imbs`, but far less than `imbs-h1`
- grouping `H` with `B` on the `IMBS` side appears to give up most of the
  benefit that made `imbs-h1` look promising

### A5. `critical-list-1h-lite`

Idea:

- stay close to `critical-list-1`
- reduce the dominance of the pure top-down `H > B > M > S` drop sequence by
  grouping or softening the `H` level

Rationale:

- useful as a historically conservative default-family comparison
- tests whether the main problem in the default family is not “top-down” per
  se, but the sharpness of the `H` transition

Initial result:

- implemented in the working tree and tested at the standard 20k bound
- weak-`POS`, stack, no Left-Wedge: `35217` generated
- weak-`POS`, stack, Left-Wedge: `36982` generated
- MP pruning remains absent in both runs
- so this conservative grouped-top default-family follow-up does not improve
  on `critical-list-1`, and Left-Wedge makes it clearly worse

### A6. `legacy-1991-default` follow-up family

Idea:

- keep the older grouped-top structure
- vary only where `B`, `M`, and `S` separate below it

Rationale:

- useful if we want a more historically conservative four-disk analogue track
- especially relevant if we find stronger publication evidence for grouped-top
  four-disk runs later

First result:

- `legacy-1991-isbm` is now implemented as the first grouped-top follow-up:
  - top level keeps `I + H`
  - lower levels use the healthier `S > B > M` ordering
- standard 20k weak-`POS`, stack:
  - no Left-Wedge: `32845` generated
  - with Left-Wedge: `26215` generated
- 20k weak-`POS`, tree, Left-Wedge:
  - `28349` generated
- deeper 50k weak-`POS`, stack, Left-Wedge:
  - `66327` generated
- interpretation:
  - this is much stronger than `legacy-1991-default`
  - but it still trails the current `isbm + weak-POS + Left-Wedge` line
  - and `tree` makes it worse at the standard 20k bound
- `legacy-1991-imbs` is now implemented as the sibling grouped-top follow-up:
  - top level still keeps `I + H`
  - lower levels use `M > B > S`
  - standard 20k weak-`POS`, stack:
    - no Left-Wedge: `32881` generated
    - with Left-Wedge: `29863` generated
  - so within the grouped-top family, the `S > B > M` lower ordering is
    clearly stronger than `M > B > S`

## Candidate Bucket-B Variants

These should not be attempted until Bucket A has been explored first.

### B1. Explicit “deferred concretization” hierarchy family

Idea:

- design a hierarchy specifically to resist early low-`kval` reward

Possible strategy name:

- `AbTweak-1993/deferred-concretization`

### B2. Frontier-quality-oriented hierarchy family

Idea:

- design hierarchies specifically around keeping the best closure-oriented
  states in the top priority buckets

Possible strategy name:

- `AbTweak-1993/frontier-balanced-hanoi`

### B3. Recursive-clearance hierarchy

Idea:

- make the largest-disk goal and all of its clearance predicates visible
  together at the top abstraction level
- then expose the smaller disk-goals below that

Working hierarchy:

- `recursive-clearance`

Current result:

- this extension is now implemented as a named non-historical hierarchy
- weak-`POS`, stack, no Left-Wedge: `33730` generated
- weak-`POS`, stack, Left-Wedge: `33727` generated
- both runs still fail with `EXPAND-LIMIT-EXCEEDED`
- MP pruning is almost absent (`6` and `39`)

Interpretation:

- coupling all large-disk clearance predicates at the top does not create the
  desired recursive behavior in the current planner
- instead, it appears to make the hierarchy too coarse and too weakly prunable
- so this specific "couple everything needed for `H`" idea is not the right
  abstraction shape

## Evaluation Matrix

Every candidate hierarchy should be checked at least against:

1. `hanoi-4` under the strongest historically relevant controls
   - `stack`
   - weak-`POS`
   - Left-Wedge on
2. `hanoi-4` under a matching no-Left-Wedge control
3. `hanoi-3` with the closest matching family where possible
   - to make sure the analogue still behaves sensibly on the already aligned
     lower Hanoi benchmark

Primary metrics:

- generated nodes
- expanded nodes
- MP-pruned counts
- open-frontier quality
- whether the best closure-oriented states remain in the top priority bucket
- whether the run reaches a full solve

Secondary metrics:

- score-sensitivity behavior
- replay viability
- lineage cleanliness

## Naming Rule

Use these conventions:

- recovered or historically plausible analogue families:
  - plain hierarchy names such as `isbm-h1`
  - documented as `hanoi-4` analogue experiments
- non-historical generic strategy work:
  - `AbTweak-1993/<strategy-name>`

This keeps hierarchy exploration from silently becoming an algorithm rewrite.

## Recommended Order

Recommended sequence:

1. `isbm-h1`
2. `isbm-hb`
3. `imbs-h1`
4. direct `imbs-h1` versus `isbm` frontier-quality comparison
5. one conservative default-family follow-up:
   - `critical-list-1h-lite` or a `legacy-1991-default` variant
6. only after that, decide whether Bucket B is justified

## Success Criteria

A hierarchy experiment should be considered promising if it does at least one
of these:

1. reaches a full `hanoi-4` solve under historically plausible controls
2. gives a clearer explanation of why a historically plausible family should
   solve, even if the current run still fails
3. keeps cleaner frontier states in the top bucket while scaling at least as
   well as the current best path
4. gives a clearer publication-facing explanation of which four-disk family is
   the best analogue of the good Hanoi hierarchy families

Important caution:

- item 2 or 3 does not make an unsolved run a better benchmark result
- those are diagnostic criteria only
- for benchmark progress in the strict sense, item 1 is the real target

## Current Recommendation

The first two hierarchy experiments are now complete:

- `isbm-h1` runs correctly but is weaker than the current `isbm` path at the
  standard 20k bound, both with and without Left-Wedge
- `isbm-hb` also runs correctly after the grouped-level bookkeeping fix, but
  is still weaker than `isbm`
- `imbs-h1` is the first explicit-`H` analogue that materially helps its
  parent family and comes close to the current best `isbm + weak-POS +
  Left-Wedge` path
- `imbs-hb` still improves plain `imbs`, but is much weaker than `imbs-h1`,
  especially once Left-Wedge is re-enabled

That direct `imbs-h1` versus `isbm` frontier comparison is now done:

- `imbs-h1` wins on raw no-Left-Wedge bounded counts and pruning
- `isbm` still looks cleaner at the very top of the frontier

So the best next hierarchy experiment is now no longer "does `imbs-h1`
survive Left-Wedge?" That answer is now no.

The best next hierarchy experiment is now:

- keep `isbm + weak-POS + Left-Wedge` as the main historical-control runtime
  target
- treat `imbs-h1` as a useful diagnostic comparison family, not as the new
  benchmark leader
- treat `critical-list-1h-lite` as a completed negative result
- treat `legacy-1991-isbm` as the first positive grouped-top follow-up, but
  not as the new benchmark leader
- treat `legacy-1991-imbs` as a useful family comparison that confirms the
  grouped-top line prefers the `isbm`-style lower ordering
- if the next hierarchy move stays in the historical-analogue bucket, prefer a
  more targeted grouped-top refinement around the `legacy-1991-isbm` line over
  more `critical-list-1` softening or a broader grouped-top permutation sweep

That is now the cleanest follow-up to the current working hypothesis:

- the `ISBM`-side explicit-`H` variants did not help
- the first `IMBS`-side explicit-`H` variant did help a lot
- the grouped `IMBS` follow-up did not preserve that gain
- and the deeper Left-Wedge runs now answer the next question too:
  `imbs-h1` mainly improves bounded no-Left-Wedge behavior without becoming a
  better solving family once the stronger historical control path returns
