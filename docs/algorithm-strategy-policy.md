# Algorithm Strategy Policy

This note defines the policy for algorithmic changes in the restored
`Abtweak-1993` working tree.

The goal is to preserve alignment with the historical AbTweak publications and
thesis work while still allowing carefully separated later experimentation.

It complements:

- [Unified restoration plan](/Users/stevenwoods/mmath-renovation/docs/unified-restoration-plan.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Publication domain crosswalk](/Users/stevenwoods/mmath-renovation/docs/publication-domain-crosswalk.md)

## Baseline Rule

The default working baseline remains:

- restored `Abtweak-1993`

That baseline should continue to mean:

- the historical domain encodings
- the historical abstraction structures
- the historically intended planner controls and scoring behavior
- only the compatibility and correctness fixes needed to recover the original
  behavior under a modern Common Lisp

We should not silently change the core algorithmic strategy of this baseline in
ways that would weaken alignment with the papers, thesis, or archived runs.

## What Counts As Acceptable Baseline Work

The following kinds of changes belong in the historical baseline:

1. source-load and runtime compatibility fixes
2. bug fixes where the restored behavior is clearly wrong relative to the
   historical code or documented intent
3. instrumentation and diagnostics that do not alter planner behavior
4. restoration of historically documented controls, modes, and experiment
   surfaces

## What Must Be Delineated As A New Strategy

If we introduce a change that is:

- not domain-specific
- meaningfully changes planner search behavior
- intended to improve support for hard cases such as `hanoi-4`
- and is not clearly required to recover the historical published behavior

then it should be treated as a new strategy, not as the historical baseline.

Examples:

- changing score shape or heuristic composition
- weakening or retiming left-wedge pressure
- adding a new generic obligation-aware term
- changing generic successor ranking or pruning policy

## Naming Rule For New Strategies

If such a strategy is introduced, it should receive a distinct name and be
documented separately from historical `abtweak`.

Recommended naming pattern:

- `AbTweak-1993` for the historical restored baseline
- `AbTweak-1993/<strategy-name>` for a clearly separated extension

Examples:

- `AbTweak-1993/balanced-left-wedge`
- `AbTweak-1993/unsat-aware-ranking`
- `AbTweak-1993/deferred-concretization`

The baseline should keep its historical name. The extension should carry the
new strategy name.

## Validation Rule

Before we treat a new strategy as successful, it should be checked against the
historically important benchmark set and should:

1. preserve the baseline published behavior where that behavior is already
   matched
2. not regress the thesis-era sample domains and control stories
3. improve or at least preserve the historically documented results on:
   - blocks
   - Nilsson blocks
   - Hanoi-3
   - robot
   - registers
4. document any tradeoff explicitly if the new strategy improves one benchmark
   while degrading another

## Current Practical Consequence

For the immediate `hanoi-4` work, this means:

- continue with instrumentation, diagnosis, historical-control comparison, and
  fidelity checks inside the `Abtweak-1993` baseline
- do not change the baseline ranking strategy just to help `hanoi-4`
- if we later test a general non-domain-specific ranking adjustment, give it a
  new strategy name and compare it against the historical baseline rather than
  folding it in silently
