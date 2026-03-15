# Current Status

This document is the concise project-status snapshot for the AbTweak renovation effort.

For deeper technical detail, see:

- [Abtweak-1993 baseline](/Users/stevenwoods/mmath-renovation/docs/abtweak-1993-baseline.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Repository State

- Primary preserved reference: [historical/Abtweak/Abtweak-1993](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993)
- Active porting tree: [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)
- Historical snapshots remain frozen reference material and are not edited during porting.

## Current Restoration Milestone

The working `Abtweak-1993` baseline now source-loads under SBCL and solves a small but meaningful set of historical example problems.

Verified smoke results:

| Case | Mode | Outcome | Notes |
| --- | --- | --- | --- |
| `blocks-sussman-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `blocks-sussman-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `registers-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `hanoi3-tweak` | `tweak` | Solves | Cost `7`, plan length `9`, `kval 0` |
| `hanoi3-abtweak` | `abtweak` | Solves | Cost `7`, plan length `9`, `kval 0` |
| `hanoi4-tweak` | `tweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at the current exploratory larger-Hanoi bounds |
| `hanoi4-abtweak` | `abtweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at the same exploratory larger-Hanoi bounds |
| `macro-hanoi-tweak` | `tweak` | Solves | Cost `1`, plan length `3`, `kval 0` |
| `macro-hanoi-abtweak` | `abtweak` | Solves | Cost `1`, plan length `3`, `kval 0` |
| `robot2-abtweak` | `abtweak` | Solves | User-defined heuristic path, primary effects, cost `12`, plan length `14`, `kval 0` |
| `robot2-abtweak-no-lw` | `abtweak` | Bounded failure | Same robot setup, `:left-wedge-mode nil`, `EXPAND-LIMIT-EXCEEDED` |
| `robot2-tweak` | `tweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at current smoke bounds |
| `loop-tweak` | `tweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at current smoke bounds |

## Key Technical Findings

- The port is beyond loader repair and into planner-validation work.
- `plan` still appears to return `NIL` on success, with the actual solution recorded in `*solution*`; this looks like historical behavior rather than a current regression.
- `simple-robot-2` is the first benchmark using the manual-style user-defined heuristic path and primary effects setup.
- The most useful side-by-side comparison currently lives in [docs/tweak-vs-abtweak-comparison.md](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md#L1).
- `macro-hanoi` now solves in both `tweak` and `abtweak`, while `hanoi-4` still ends in bounded failure in both modes at the current exploratory settings.
- The current `hanoi-4` diagnosis is “bound-limited under the restored BFS path, with partial abstraction goals still solving”; details are recorded in [docs/hanoi4-diagnosis.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md#L1).
- The DFS control-strategy path now executes under SBCL again after restoring the stack-open loader path, but current DFS runs still tend to hit `solution-limit` or `CPU-TIME-LIMIT-EXCEEDED` rather than producing useful comparison results.
- Left-wedge behavior now has a meaningful comparison target:
  - `blocks` / `sussman` shows no observed difference at current bounds.
  - `simple-robot-2` solves in `abtweak` with default left-wedge behavior, but the same run with `:left-wedge-mode nil` reaches `EXPAND-LIMIT-EXCEEDED`.

## Current Constraints

- The archival source trees are preserved as historical artifacts, including old compiled Lisp outputs.
- Most remaining risk is semantic validation, not basic SBCL compatibility.
- The largest open gaps are broader benchmark coverage, left-wedge comparisons on additional domains, monotonic-property validation, and cleaner handling of historical implicit specials under SBCL.

## Reproducible Commands

- Loader: [scripts/load-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/load-abtweak-1993-sbcl.sh)
- Smoke runner: [scripts/smoke-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh)
- Comparison runner: [scripts/compare-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-abtweak-1993-sbcl.sh)

Representative checks:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi3-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh macro-hanoi-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-abtweak
sh /Users/stevenwoods/mmath-renovation/scripts/compare-abtweak-1993-sbcl.sh
```
