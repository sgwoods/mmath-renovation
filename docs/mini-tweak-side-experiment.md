# Mini-Tweak Side Experiment

This note records the first deliberate side experiment on the recovered
[historical/Mini-Tweak](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak)
workspace.

The goal was modest:

1. avoid modifying the historical files
2. see whether the preserved local `Mini-Tweak` copy is already runnable under SBCL
3. identify the first real blockers if it is not

## Probe Surface

The retained probe script is:

- [scripts/probe-mini-tweak-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/probe-mini-tweak-sbcl.sh#L1)

It checks three variants:

1. the original mailed source:
   [historical/Mini-Tweak/Original/minitweak.lsp](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/minitweak.lsp#L1)
2. the local working copy:
   [historical/Mini-Tweak/m-tweak.l](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/m-tweak.l#L1)
3. the alternate local copy:
   [historical/Mini-Tweak/modify.lsp](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/modify.lsp#L1)

The probe uses the surviving lens-maker sample domain in:

- [historical/Mini-Tweak/lens-domain.l](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/lens-domain.l#L1)

## Current Result

Current outcome from the first SBCL probe:

- `original-as-imported`: fails immediately because the preserved mail-header
  lines are still literal file contents, so SBCL reads `From` as an unbound variable
- `local-m-tweak`: gets past the mail-header issue, but fails after shadowing
  `STEP` because the local file has a reader-level unmatched close parenthesis
  around line `444`
- `local-modify`: same failure pattern as `local-m-tweak`

So the current `Mini-Tweak` state is:

- historically valuable
- close enough to modern Lisp to be worth preserving
- not yet runnable under SBCL without a small compatibility or repair layer

## What This Means

This is useful even without a successful run.

It tells us the first blockers are not deep planner semantics:

1. provenance formatting in the original mailed source
2. package-name collision on `STEP` under SBCL
3. a preserved syntax problem in the local edited copies

That means a future `Mini-Tweak` restoration track is plausible, but it should
be treated as a separate side project rather than mixed into the AbTweak
baseline.

## Recommended Next Step

If we later continue this side track, the next sensible move is:

1. create a non-historical working copy for `Mini-Tweak`
2. preserve the original files unchanged under `historical/`
3. fix only the minimum needed to load and run the lens-maker example

Until then, the main project should keep `Mini-Tweak` as documented context,
not as part of the active restored planner surface.
