# Current Status

This document is the concise project-status snapshot for the AbTweak renovation effort.

For deeper technical detail, see:

- [Abtweak-1993 baseline](/Users/stevenwoods/mmath-renovation/docs/abtweak-1993-baseline.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Historical sample cases](/Users/stevenwoods/mmath-renovation/docs/historical-sample-cases.md)
- [Publications index](/Users/stevenwoods/mmath-renovation/publications/README.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)

## Repository State

- Primary preserved reference: [historical/Abtweak/Abtweak-1993](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993)
- Active porting tree: [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)
- Historical snapshots remain frozen reference material and are not edited during porting.

## Plan State

- Runtime restoration: first milestone substantially achieved
- Historical validation: in progress, with a much stronger source base now that the publications are checked into the repo
- Benchmark coverage: solid baseline, but still missing a full `hanoi-4` solve and some additional shipped sample coverage
- Recommended next track: push `hanoi-4`, then label the validation matrix, then trim remaining SBCL warning noise

## Current Restoration Milestone

The working `Abtweak-1993` baseline now source-loads under SBCL and solves a small but meaningful set of historical example problems.

Verified smoke results:

| Case | Mode | Outcome | Notes |
| --- | --- | --- | --- |
| `blocks-sussman-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `blocks-sussman-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `nils-blocks-tweak` | `tweak` | Solves | Cost `6`, plan length `8`, `kval 0` |
| `nils-blocks-abtweak` | `abtweak` | Solves | Cost `6`, plan length `8`, `kval 0`, with `*mp-pruned* = 1` |
| `registers-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `hanoi3-tweak` | `tweak` | Solves | Cost `7`, plan length `9`, `kval 0` |
| `hanoi3-abtweak` | `abtweak` | Solves | Cost `7`, plan length `9`, `kval 0` |
| `hanoi4-tweak` | `tweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at the current exploratory larger-Hanoi bounds |
| `hanoi4-abtweak` | `abtweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at the same exploratory larger-Hanoi bounds |
| `macro-hanoi-tweak` | `tweak` | Solves | Cost `1`, plan length `3`, `kval 0` |
| `macro-hanoi-abtweak` | `abtweak` | Solves | Cost `1`, plan length `3`, `kval 0` |
| `computer-tweak` | `tweak` | Solves | Cost `6`, plan length `8`, `kval 0` |
| `computer-abtweak` | `abtweak` | Solves | Cost `6`, plan length `8`, `kval 0` |
| `biology-goal1-abtweak` | `abtweak` | Solves | Cost `8`, plan length `10`, `kval 0` |
| `fly-dc-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `database-goal0-tweak` | `tweak` | Solves | Cost `2`, plan length `4`, `kval 0` |
| `robot1-abtweak` | `abtweak` | Solves | User-defined heuristic path, primary effects, cost `16`, plan length `18`, `kval 0` |
| `robot1-abtweak-no-lw` | `abtweak` | Bounded failure | Same robot setup, `:left-wedge-mode nil`, `EXPAND-LIMIT-EXCEEDED` |
| `robot1-tweak` | `tweak` | Bounded failure | Still `EXPAND-LIMIT-EXCEEDED` even with a larger exploratory bound set |
| `robot2-abtweak` | `abtweak` | Solves | User-defined heuristic path, primary effects, cost `12`, plan length `14`, `kval 0` |
| `robot2-abtweak-no-lw` | `abtweak` | Bounded failure | Same robot setup, `:left-wedge-mode nil`, `EXPAND-LIMIT-EXCEEDED` |
| `robot2-tweak` | `tweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at current smoke bounds |
| `loop-tweak` | `tweak` | Bounded failure | `EXPAND-LIMIT-EXCEEDED` at current smoke bounds |

## Key Technical Findings

- The port is beyond loader repair and into planner-validation work.
- `plan` still appears to return `NIL` on success, with the actual solution recorded in `*solution*`; this looks like historical behavior rather than a current regression.
- `simple-robot-2` is the first benchmark using the manual-style user-defined heuristic path and primary effects setup.
- `simple-robot-1` now adds distinct coverage instead of duplicating `simple-robot-2`:
  - `robot1-abtweak` solves with cost `16`, plan length `18`, and `kval 0`
  - `robot1-tweak` still fails at a larger exploratory bound set
  - `robot1-abtweak-no-lw` also fails, which makes it a second robot-domain left-wedge comparison rather than a duplicate of `simple-robot-2`
- Several additional historically shipped sample domains are now verified under SBCL:
  - `computer` solves in both `tweak` and `abtweak`
  - `biology` goal 1 solves in `abtweak`
  - `fly` to Washington DC solves in `abtweak`
  - `database` query 0 solves in `tweak`, matching the domain file note that SQL world is not an AbTweak example
- The most useful side-by-side comparison currently lives in [docs/tweak-vs-abtweak-comparison.md](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md#L1).
- `macro-hanoi` now solves in both `tweak` and `abtweak`.
- The current `hanoi-4` diagnosis is now more specific than “just bound-limited”:
  - `tweak` and `abtweak` both still hit `EXPAND-LIMIT-EXCEEDED` at the standard exploratory bounds
  - `abtweak` with `:left-wedge-mode nil` also hits `EXPAND-LIMIT-EXCEEDED`
  - the earlier higher-bound `abtweak` heap exhaustion is now fixed
  - the same higher-bound `abtweak` run with default MP now returns a normal `EXPAND-LIMIT-EXCEEDED` result instead of crashing SBCL
  - the same higher-bound `abtweak` run with `:mp-mode nil` still returns `EXPAND-LIMIT-EXCEEDED`, so the benchmark remains expensive but no longer fails fatally
  - at the standard bound, `tweak` actually generates fewer nodes than the current AbTweak variants, `:mp-mode t` prunes `0` nodes, and disabling left-wedge is slightly worse than the default AbTweak run
  - the new hierarchy comparison changes that story substantially:
    - `critical-list-2` with MP and left-wedge enabled generates `32461` nodes at the standard 20k bound, beating `tweak`
    - `ismb` with MP and left-wedge enabled generates `24228` nodes at the same bound, which is the best `hanoi-4` result seen so far
    - `ismb` and `critical-list-2` both show strong MP sensitivity, while the default `critical-list-1` does not
    - after the latest cleanup pass, `ismb` with MP and left-wedge also reaches clean `EXPAND-LIMIT-EXCEEDED` results at `150000` expansions (`184610` generated, `183236` MP prunes) and `200000` expansions (`243578` generated, `245293` MP prunes)
    - `ismb` with `:drp-mode t` still does not solve, but it now reports `OPEN-EXHAUSTED` honestly instead of leaving the untouched initial plan in `*solution*`
    - `critical-list-2` has not improved as much under the same deeper runs and can still exhaust the default SBCL heap by `150000`, which makes `ismb` the clearer current restoration target
    - the checked-in publications now let us interpret those local hierarchies more precisely:
      - `critical-list-1` is the default `IBMS`-style family extended to four disks
      - `ismb` is the `ISMB` family, with omitted `onh` falling to criticality `0` by historical `find-crit` behavior
      - `critical-list-2` is best read as a positive/negative criticality-label experiment rather than a simple permutation like `IBMS`
  - the working-vs-historical review now shows that the `hanoi-4` domain and default abstraction hierarchy are unchanged from the archival code, and that the main precedence rewrite in the working tree preserves the historical reachability relation on randomized checks
  - details are recorded in [docs/hanoi4-diagnosis.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md#L1)
  - the hierarchy matrix is recorded in [docs/hanoi4-hierarchy-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md#L1)
  - the algorithm comparison note is [docs/algorithm-correspondence.md](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md#L1)
- Planner bound handling is now healthier under SBCL:
  - open exhaustion now records `OPEN-EXHAUSTED` instead of leaving the initial plan in `*solution*`
  - `generate-bound` and `open-bound` now terminate search with `GENERATE-LIMIT-EXCEEDED` and `OPEN-LIMIT-EXCEEDED` respectively
- The DFS control-strategy path is now usable for small tuned cases:
  - `blocks-sussman-tweak-dfs` and `blocks-sussman-abtweak-dfs` both solve with `:solution-limit 6`
  - larger `solution-limit` values still lead DFS toward longer first-found plans and eventual CPU exhaustion, so DFS is currently a tuning-sensitive diagnostic rather than a general replacement for the restored BFS path
- The SBCL loader is cleaner now:
  - the working tree loads an early [sbcl-specials.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/sbcl-specials.lisp#L1) compatibility file
  - plain source loads no longer emit the earlier wave of undefined-special-variable warnings
  - on the representative init load, the warning profile dropped from `217` undefined-function warnings, `49` bad type-specifier warnings, and `1` asserted-type conflict to `0` in all three categories
  - the remaining SBCL load noise is now mostly style warnings in historical stubs and some expected redefinition chatter from domains that intentionally replace shared helper names
- Nilsson blocks and monotonic-property validation are now active:
  - `nils-blocks-tweak` and `nils-blocks-abtweak` both solve with cost `6`, plan length `8`, `kval 0`
  - in `nils-blocks-abtweak`, `:mp-mode t` reduces search from `70` expanded / `201` generated to `61` expanded / `168` generated while preserving the same returned plan, and `*mp-pruned*` increases from `0` to `1`
- Left-wedge behavior now has a meaningful comparison target:
  - `blocks` / `sussman` shows no observed difference at current bounds.
  - `simple-robot-1` solves in `abtweak` with default left-wedge behavior, but the same run with `:left-wedge-mode nil` reaches `EXPAND-LIMIT-EXCEEDED`.
  - `simple-robot-2` solves in `abtweak` with default left-wedge behavior, but the same run with `:left-wedge-mode nil` reaches `EXPAND-LIMIT-EXCEEDED`.

## Current Constraints

- The archival source trees are preserved as historical artifacts, including old compiled Lisp outputs.
- Most remaining risk is semantic validation, not basic SBCL compatibility.
- The largest open gaps are now pushing the best `hanoi-4` hierarchy configurations toward a full solve, labeling the current benchmark set against the published claims, and trimming the remaining non-fatal SBCL style/redefinition noise.

## Reproducible Commands

- Loader: [scripts/load-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/load-abtweak-1993-sbcl.sh)
- Smoke runner: [scripts/smoke-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh)
- Comparison runner: [scripts/compare-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-abtweak-1993-sbcl.sh)
- Hanoi hierarchy runner: [scripts/compare-hanoi4-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh)

Representative checks:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-tweak-dfs
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-abtweak-dfs
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-generate-bound
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-open-bound
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh nils-blocks-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh nils-blocks-abtweak-no-mp
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi3-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh macro-hanoi-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh computer-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh biology-goal1-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh fly-dc-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh database-goal0-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot1-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot1-abtweak-no-lw
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-abtweak
sh /Users/stevenwoods/mmath-renovation/scripts/compare-abtweak-1993-sbcl.sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh
```
