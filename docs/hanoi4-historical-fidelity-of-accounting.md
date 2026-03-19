# Hanoi-4 Historical Fidelity Of The Accounting Split

This note evaluates whether the current `hanoi-4` score/accounting split looks
like a restoration mismatch or a historically faithful part of AbTweak.

It complements:

- [Hanoi-4 goal and obligation accounting rules](/Users/stevenwoods/mmath-renovation/docs/hanoi4-accounting-rules.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)

## Short Answer

The current evidence says this split is very likely historical baseline
behavior, not a new porting artifact.

More specifically:

- the same score formula appears in the archived 1991 and 1993 code lines
- the same default heuristic appears in the archived 1991 and 1993 code lines
- the same `adjust-pre-list` / `abstract-goal-mode` logic appears in the
  archived 1991 and 1993 code lines
- the manual text explicitly describes the default heuristic as counting
  unsatisfied goals and Left-Wedge as a level-based cost adjustment

So if this interaction is harmful on `hanoi-4`, it looks much more like an
original algorithmic pressure than a regression introduced by the SBCL port.

## Code-Line Evidence

### 1991 and 1993 AbTweak Heuristic Structure

The archived `1991-05` and `1993` code both implement AbTweak scoring as:

- the `tweak` heuristic
- plus the Left-Wedge adjustment

Relevant files:

- [historical/Abtweak/Abtweak-1991-05/Ab-routines/ab-heuristic.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Ab-routines/ab-heuristic.lsp)
- [historical/Abtweak/Abtweak-1993/Ab-routines/ab-heuristic.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Ab-routines/ab-heuristic.lisp)
- [working/abtweak-1993/Ab-routines/ab-heuristic.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-heuristic.lisp)

The structure is materially the same across those versions.

### 1991 and 1993 Default Heuristic

The archived `1991-05` and `1993` code both implement the default heuristic as:

- `num-of-unsat-goals(plan)`

and that function counts only unsatisfied preconditions of operator `G`.

Relevant files:

- [historical/Abtweak/Abtweak-1991-05/Tw-routines/tw-heuristic.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Tw-routines/tw-heuristic.lsp)
- [historical/Abtweak/Abtweak-1993/Tw-routines/tw-heuristic.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Tw-routines/tw-heuristic.lisp)
- [working/abtweak-1993/Tw-routines/tw-heuristic.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/tw-heuristic.lisp)

So the "goal-only" part of the current score is not new.

### 1991 and 1993 Goal-Abstraction Logic

The archived `1991-05` and `1993` code both use the same `adjust-pre-list`
logic that filters visible preconditions by current `kval`, with the same
special case for `G`.

Relevant files:

- [historical/Abtweak/Abtweak-1991-05/Ab-routines/ab-general.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-05/Ab-routines/ab-general.lsp)
- [historical/Abtweak/Abtweak-1993/Ab-routines/ab-general.lisp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993/Ab-routines/ab-general.lisp)
- [working/abtweak-1993/Ab-routines/ab-general.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-general.lisp)

The important point is that this same score/correctness split already exists in
the historical code:

- heuristic counts full `G`
- level-correctness and subgoal choice work on current-level visible
  preconditions

So the split is not a modern reconstruction choice.

## Manual Evidence

The shipped manual says two relevant things explicitly:

1. The default heuristic counts unsatisfied goals.
   From [Doc/users-manual.tex](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Doc/users-manual.tex#L269):
   it says `'num-of-unsat-goals` takes the total number of unsatisfied goals as
   a heuristic, and the example implementation counts `G` preconditions.
2. Left-Wedge is a level-based cost adjustment.
   From [Doc/users-manual.tex](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Doc/users-manual.tex#L383):
   it says Left-Wedge adjusts plan cost by abstraction level using
   `*left-wedge-list*`.

Those descriptions fit the current restored behavior closely.

## Publication Evidence

The publications do not spell out this accounting split line by line, but they
do describe the high-level behavior that matches it:

- AbTweak plans at successively lower abstraction levels
- Left-Wedge is a complete control strategy that invests more search in the
  first abstract solution
- hierarchy quality is central, and Left-Wedge can help on good hierarchies
  and hurt on bad ones

That is consistent with the current `hanoi-4` diagnosis:

- the level-drop reward is strong
- it can become counterproductive on some branch shapes

So the papers do not directly prove this exact implementation detail, but they
are broadly compatible with it.

## Important Caveat

There is one caution worth preserving.

The comment above `adjust-pre-list` says:

- if `*abstract-goal-mode*` then do not abstract goal preconditions

but the code actually does:

- if `not *abstract-goal-mode*` and `opid = 'g`, return the full goal list
- otherwise filter `G` through abstraction like other operators

This is a real source of confusion.

However:

- the same comment/code mismatch exists in the archived `1991-05` and `1993`
  code
- the working port preserved that behavior

So this is not a new restoration regression either. At most, it is a
historically inherited ambiguity or historical bug.

## Best Current Conclusion

The best current conclusion is:

- the `hanoi-4` score/accounting split is probably faithful to the historical
  baseline
- the current failure therefore looks less like "the port broke AbTweak"
  and more like "this historical strategy combination is brittle on this
  benchmark unless the hierarchy/control pairing is especially good"

That still leaves room for a historical bug or mismatch in the original system,
but it no longer looks like a new bug introduced by the modern restoration.

## Best Next Question

The next best question is now:

- given that this split appears historically faithful, did the published
  successful Hanoi runs rely on hierarchy/control combinations that avoid this
  concretization trap, or are we still missing another historically relevant
  control detail?
