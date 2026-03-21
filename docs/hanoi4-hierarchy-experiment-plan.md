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

### A4. `imbs-hb`

Idea:

- start from `imbs`
- group `H` with `B`

Rationale:

- same motivation as `isbm-hb`, but on the `IMBS` side of the analogue family
- lets us compare whether explicit `H` helps more on a medium-first or
  small-first hierarchy

### A5. `critical-list-1h-lite`

Idea:

- stay close to `critical-list-1`
- reduce the dominance of the pure top-down `H > B > M > S` drop sequence by
  grouping or softening the `H` level

Rationale:

- useful as a historically conservative default-family comparison
- tests whether the main problem in the default family is not “top-down” per
  se, but the sharpness of the `H` transition

### A6. `legacy-1991-default` follow-up family

Idea:

- keep the older grouped-top structure
- vary only where `B`, `M`, and `S` separate below it

Rationale:

- useful if we want a more historically conservative four-disk analogue track
- especially relevant if we find stronger publication evidence for grouped-top
  four-disk runs later

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
4. `imbs-hb`
5. one conservative default-family follow-up:
   - `critical-list-1h-lite` or a `legacy-1991-default` variant
6. only after that, decide whether Bucket B is justified

## Success Criteria

A hierarchy experiment should be considered promising if it does at least one
of these:

1. reaches a full `hanoi-4` solve under historically plausible controls
2. materially improves bounded performance over the current `isbm + weak-POS +
   Left-Wedge` path
3. keeps cleaner frontier states in the top bucket while scaling at least as
   well as the current best path
4. gives a clearer publication-facing explanation of which four-disk family is
   the best analogue of the good Hanoi hierarchy families

## Current Recommendation

The first two hierarchy experiments are now complete:

- `isbm-h1` runs correctly but is weaker than the current `isbm` path at the
  standard 20k bound, both with and without Left-Wedge
- `isbm-hb` also runs correctly after the grouped-level bookkeeping fix, but
  is still weaker than `isbm`

So the best next hierarchy experiment is now:

- implement and compare `imbs-h1` next

That is now the cleanest follow-up test of the current working hypothesis:

- move from the `ISBM` analogue family to the `IMBS` analogue family
- keep explicit `H` structure before `k0`
- test whether the publication-good `IMLS`/`IMBS` side gives a better
  four-disk shape than the healthier-but-still-open `isbm` line.
