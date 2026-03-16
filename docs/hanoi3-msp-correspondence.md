# Hanoi-3 MSP Correspondence

This note records an important historical comparison result for the restored
`hanoi-3` experiments: some of the current SBCL outcomes only look surprising if
they are compared against the wrong historical control family.

It complements:

- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)
- [Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)

## Core Finding

The 1991 experiment code exposed a richer monotonic-solution-property control
surface than the 1993 code we are currently porting.

In the 1991 planner:

- `:msp-mode` could be `nil`, `weak`, or `strong`
- `:msp-weak-mode` could be `nec` or `pos`
- `:crit-depth-mode` could be enabled separately

Those controls are visible in:

- [historical/Abtweak/Abtweak-1991-08/Planner/planner.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/planner.lsp#L35)
- [historical/Abtweak/Abtweak-1991-08/AbTweak2/ab-msp.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/AbTweak2/ab-msp.lsp#L8)

By contrast, the 1993 codebase and the working SBCL port expose only:

- boolean `:mp-mode`
- boolean `:left-wedge-mode`

with a single weak-style MP checker in:

- [working/abtweak-1993/plan.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/plan.lisp#L5)
- [working/abtweak-1993/Ab-routines/ab-mp-check.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-mp-check.lisp#L8)

So the current port is historically faithful to the archived `Abtweak-1993`
baseline, but it is not equivalent to the richer `Abtweak-1991-08` experiment
driver.

## Why This Matters

When the current SBCL `hanoi-3` runs are compared directly with the 1991 saved
outputs, several "mismatches" disappear once the historical control family is
matched correctly.

Examples:

| Hierarchy | Current SBCL run | Current result | Historical file | Historical result |
| --- | --- | --- | --- | --- |
| `isbm` | MP on, LW off | `1083` expanded / `1433` generated | [isbm-ab-WN.1126](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/isbm-ab-WN.1126#L23) | `1083` / `1433` |
| `imbs` | MP on, LW off | `166` / `233` | [imbs-ab-Wn.1129](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/imbs-ab-Wn.1129#L23) | `166` / `233` |
| `isbm` | MP off, LW on | `168` / `284` | [isbmK-raw.out](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/isbmK-raw.out#L135) | `168` / `284` |
| `ibsm` | MP off, LW on | `828` / `1471` | [ibsmK-raw.out](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/ibsmK-raw.out#L135) | `828` / `1471` |
| `ismb` | MP off, LW on | `963` / `1771` | [ismbK-raw.out](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results/ismbK-raw.out#L304) | `963` / `1771` |

That means the restored port is already reproducing several historically
reported `hanoi-3` regimes quite closely.

## Best Current Interpretation

The current evidence suggests:

1. the `Abtweak-1993` MP behavior is not simply "wrong"
2. some current `hanoi-3` outcomes were being compared to the wrong 1991
   experiment families
3. the 1993 code appears closer to the older weak-`NEC` family than to the
   weak-`POS` family
4. reproducing the full 1991 `hanoi-3` matrix would require re-exposing
   historical controls that do not exist in the 1993 planner interface

Point 3 is an inference from the exact or near-exact `NEC` matches above and
from the current checker's structure: it uses necessary ordering and direct
effect checks, but it does not expose the explicit `poss-est-p` / `pos` branch
that the 1991 `ab-msp.lsp` implementation supported.

## Project Impact

This changes the restoration story in a useful way.

Before this comparison, the natural reading was:

- "`ismb` and `isbm` only look plausible when MP is off, so the MP path may be
  broken."

The better current reading is:

- "the 1993 baseline collapses part of the older 1991 MSP experiment surface,
  so some current MP-on comparisons are apples-to-oranges unless they are lined
  up against the right historical run family."

That does not prove the current `hanoi-3` MP path is perfect, but it does mean
the remaining gap is narrower and more historically specific.

## Follow-Through

The first version of that compatibility layer now exists in
[Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md),
including exact representative matches for the strongest archived `NEC` and
critical-depth comparison cases.
