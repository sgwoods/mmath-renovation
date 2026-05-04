# Working Baseline: Abtweak-1993

This directory is the active working copy for porting the `Abtweak-1993` snapshot to a modern Common Lisp environment.

## Relationship To The Historical Snapshot

- Historical reference: [`../../historical/Abtweak/Abtweak-1993`](../../historical/Abtweak/Abtweak-1993)
- Working copy: this directory

The historical snapshot should remain unchanged as the recovered reference copy. Compatibility fixes, loader experiments, and cleanup belong here instead.

## Current Differences From The Historical Tree

- historical compiled artifacts were intentionally omitted from this working copy
- `init-sbcl.lisp` was added for source loading under SBCL
- compatibility edits have been limited to SBCL loading, heuristic dispatch, and type-declaration cleanup in the live planning path

## Current Status

- SBCL source load works through `init-sbcl.lisp`
- bounded `tweak`-mode searches now run under SBCL
- `blocks` / `sussman` in `tweak` mode now returns a concrete plan
- `blocks` / `sussman` in `abtweak` mode now also returns a concrete plan
- `hanoi-3` returns concrete plans in both `tweak` and `abtweak`
- `simple-robot-2` returns a concrete plan in `abtweak` with the manual-style user heuristic path
- `simple-robot-2` is currently the clearest left-wedge regression: it solves in `abtweak` with default left-wedge behavior and hits `EXPAND-LIMIT-EXCEEDED` when left-wedge is disabled at the same bounds
- current smoke tests terminate with `EXPAND-LIMIT-EXCEEDED` rather than crashing during initialization
- some larger historical benchmarks still need additional compatibility and validation work

See [docs/abtweak-1993-baseline.md](../docs/abtweak-1993-baseline.md) for the current status and next steps.
