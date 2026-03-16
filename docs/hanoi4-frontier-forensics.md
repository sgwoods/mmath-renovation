# Hanoi-4 Frontier Forensics

This note records a focused inspection of the best-looking `hanoi-4` frontier
states produced by the restored `Abtweak-1993` SBCL port.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Hanoi-4 trace workflow](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)

## Why This Inspection Was Needed

The first trace snapshots under `ismb` plus MP and left-wedge showed many open
nodes with:

- `kval 0`
- plan cost around `15`
- plan length around `17`
- repeated small-disk peg shuffling
- unresolved preconditions such as `(ISPEG $var)`

That looked close enough to a complete 4-disk Hanoi plan that it raised a
reasonable question: are we failing because of a logic bug in variable binding
or establisher selection?

## Probe Setup

The inspection reproduced the standard `hanoi-4` trace configuration:

- planner mode: `abtweak`
- hierarchy: `*ismb*`
- `:mp-mode t`
- `:left-wedge-mode t`
- expand bound: `20000`
- generate bound: `80000`
- open bound: `80000`

Then it examined the first open node directly in memory after the bounded run.

## Main Findings

### 1. The suspicious frontier node is not a one-step-away solution

For the first open node from the `20000`-expansion run:

- priority: `8`
- plan cost: `15`
- plan length: `17`
- selected unsatisfied pair: `(|op102982| (ISPEG $102980))`

But the same node still has many unsatisfied necessary preconditions, not just
that single one. A direct probe found `15` unsatisfied `(user precondition)`
pairs, including:

- `(|op102982| (ISPEG $102980))`
- `(|op102982| (ONS $102980))`
- `(|op98145| (NOT ONS PEG2))`
- `(|op98145| (ONM PEG1))`
- `(|op96950| (NOT ONS PEG3))`
- `(|op96950| (NOT ONM PEG3))`
- `(|op96910| (NOT ONB PEG3))`
- `(|op96910| (NOT ONM PEG3))`
- `(|op96910| (NOT ONS PEG3))`

So the node is structurally suggestive of the known 15-move solution, but it is
still far from satisfying all necessary conditions.

### 2. The unresolved `(ISPEG $var)` condition is semantically valid

For that same node:

- `HOLD-P` for `(|op102982| (ISPEG $102980))` is `NIL`
- `FIND-ESTABLISHERS` returns `NIL`
- the operator is `(MOVES $102980 PEG3)`
- its preconditions are `((ISPEG $102980) (ISPEG PEG3) (ONS $102980))`
- the plan carries non-codesignation `(($102980 PEG3))`

This is not obviously malformed. In Tweak/AbTweak, `hold-p` requires a
necessary establisher, not merely a possible one. An initial fact like
`(ISPEG PEG1)` only possibly codesignates with `(ISPEG $102980)`, so it does
not count as already holding necessarily.

That means the open condition is a legitimate partial-plan obligation, not
evidence that an earlier binding step silently failed.

### 3. Existing-establisher branching is working as expected

For that same unsatisfied pair:

- `find-new-ests` returns `NIL`
- `find-exist-ests` returns two branches, both from `I`

Those two branches are exactly the expected source-peg instantiations:

- `(MOVES PEG1 PEG3)`
- `(MOVES PEG2 PEG3)`

After taking either branch, the next selected precondition becomes:

- `(ONS PEG1)` for the `PEG1` branch
- `(ONS PEG2)` for the `PEG2` branch

and the unsatisfied-pair count drops from `15` to `13`.

This is strong evidence that the establisher and binding machinery is behaving
coherently on the inspected frontier state.

## Current Interpretation

The inspected `hanoi-4` frontier states are:

- semantically valid partial plans
- heavily underconstrained
- not just one missing binding away from success

So the current bottleneck looks less like a binding bug and more like a search
quality problem:

- the restored planner is willing to carry many still-open necessary conditions
  in plans that already have solution-like move skeletons
- the current heuristic and control choices are not driving those plans toward
  closure efficiently enough
- the strongest next diagnostic is therefore heuristic and frontier-quality
  analysis, not a repair of `find-exist-ests`, `find-new-ests`, or
  `apply-mapping-to-plan`

## Recommended Next Step

The next `hanoi-4` investigation should focus on search quality:

1. rank frontier nodes by unsatisfied-pair count as well as heuristic priority
2. inspect whether the current heuristic overvalues move-count skeletons with
   many open conditions
3. compare the first few frontier layers under `tweak`, `abtweak`, and the
   strongest `ismb` settings to see where AbTweak is or is not buying useful
   focus
