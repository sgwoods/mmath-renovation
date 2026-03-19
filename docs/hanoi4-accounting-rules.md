# Hanoi-4 Goal And Obligation Accounting Rules

This note records the exact accounting split that currently shapes the
`hanoi-4` reinsertion behavior in the restored `Abtweak-1993` baseline.

It complements:

- [Hanoi-4 reinsertion obligation picture](/Users/stevenwoods/mmath-renovation/docs/hanoi4-reinsertion-obligations.md)
- [Hanoi-4 optimal versus traced lineages](/Users/stevenwoods/mmath-renovation/docs/hanoi4-optimal-lineage-comparison.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## The Crucial Split

The current `abtweak` score and the current `abtweak` correctness/subgoal logic
do not account for obligations in the same way.

### Score

The search score is:

- `search-cost`
- plus the `tweak` heuristic
- plus the Left-Wedge adjustment

In code:

- [ab-heuristic.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-heuristic.lisp#L1)
- [state-expansion.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/state-expansion.lisp#L1)

The default `tweak` heuristic is:

- [tw-heuristic.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/tw-heuristic.lisp#L1)

and it is exactly:

- `num-of-unsat-goals(plan)`

where:

- `num-of-unsat-goals` counts unsatisfied preconditions of operator `G`
- it does **not** abstract `G`
- it does **not** count non-goal open obligations

So the base heuristic sees:

- full-goal progress only

It does **not** see:

- unresolved non-goal preconditions
- concrete enabling blockers
- total open-condition burden

### Level-Correctness And Subgoal Choice

By contrast, AbTweak level-correctness and subgoal choice work on the
preconditions visible at the current abstraction level.

In code:

- [ab-mtc.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-mtc.lisp#L1)
- [ab-successors.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-successors.lisp#L1)
- [ab-general.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-general.lisp#L1)

The important rule is:

- `adjust-pre-list` filters preconditions by current `kval`
- `ab-mtc` checks only those currently visible preconditions
- `ab-determine-first-u-and-p` picks unsatisfied visible preconditions at the
  current level

So the correctness/subgoal machinery sees:

- level-visible obligations

not the full plan burden.

## Why This Matters On The Reinsertion Fork

This explains the key fork in
[hanoi4-reinsertion-obligations.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-reinsertion-obligations.md#L1).

For the same branch:

| Insertion | Plan id | Kval | Base goal heuristic | Unsat pairs | First unsat |
| --- | --- | --- | --- | --- | --- |
| `6136` | `plan33620` | `2` | `3` | `0` | `NIL` |
| `6139` | `plan33620` | `1` | `3` | `1` | `(G (ONB PEG3))` |
| `6154` | `plan33690` | `1` | `2` | `0` | `NIL` |
| `6157` | `plan33690` | `0` | `2` | `3` | `(NOT ONM PEG1)` |

The most important detail is:

- the base goal heuristic stays the same across each reinsertion pair
- the no-left-wedge score also stays the same
- only the visible obligation picture changes

So:

- `plan33620` at `k2` and `plan33620` at `k1` both still look like `3`
  unsatisfied goals to the heuristic
- `plan33690` at `k1` and `plan33690` at `k0` both still look like `2`
  unsatisfied goals to the heuristic

But the visible obligation picture becomes more concrete:

- from nothing at `k2`
- to visible goal `(G (ONB PEG3))` at `k1`
- to concrete blocker `(NOT ONM PEG1)` at `k0`

The score does not directly charge that increasing non-goal burden.

## The Local Mechanism

So the branch keeps winning because:

1. full-goal progress is unchanged enough that the base heuristic does not
   worsen
2. the no-left-wedge score therefore stays flat
3. Left-Wedge becomes more favorable at the lower `kval`
4. the new lower-level obligations are mostly non-goal obligations, so they are
   not directly charged by the heuristic

That is the clearest current local explanation for why the branch can become
more concrete and locally dirtier while still improving in actual score.

## What This Does And Does Not Mean

This does **not** prove a bug yet.

It does show that the current baseline has a structural pressure that can be
harmful on `hanoi-4`:

- score is dominated by full-goal progress plus Left-Wedge
- level-specific non-goal burden is mostly invisible to that score

That is consistent with:

- historically intended Left-Wedge pressure
- plus a benchmark where early concretization becomes counterproductive

So the current best interpretation remains:

- the hierarchy can still be historically sensible
- the planner may still be historically faithful
- but the interaction of full-goal heuristic accounting with level-drop
  Left-Wedge reward is a strong candidate explanation for the `hanoi-4`
  failure mode

## Best Next Question

The next best baseline-preserving question is now:

- is this score/accounting split exactly what the historical Hanoi-4
  experiments were using when they reported good outcomes on good hierarchies,
  or is there still a fidelity mismatch in how the restored path applies goal
  abstraction and Left-Wedge together?
