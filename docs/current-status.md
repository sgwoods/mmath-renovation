# Current Status

This document is the concise project-status snapshot for the AbTweak renovation effort.

For deeper technical detail, see:

- [Abtweak-1993 baseline](/Users/stevenwoods/mmath-renovation/docs/abtweak-1993-baseline.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Historical sample cases](/Users/stevenwoods/mmath-renovation/docs/historical-sample-cases.md)
- [Publications index](/Users/stevenwoods/mmath-renovation/publications/README.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Unified restoration plan](/Users/stevenwoods/mmath-renovation/docs/unified-restoration-plan.md)
- [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Hanoi-4 trace workflow](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Hanoi-4b frontier comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md)
- [Hanoi-3 versus Hanoi-4](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md)
- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)
- [Hanoi-3 MSP correspondence](/Users/stevenwoods/mmath-renovation/docs/hanoi3-msp-correspondence.md)
- [Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Left-Wedge intent comparison](/Users/stevenwoods/mmath-renovation/docs/left-wedge-intent-comparison.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)
- [Reset-domain assessment](/Users/stevenwoods/mmath-renovation/docs/reset-domain-assessment.md)

## Repository State

- Primary preserved reference: [historical/Abtweak/Abtweak-1993](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993)
- Active porting tree: [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)
- Historical snapshots remain frozen reference material and are not edited during porting.

## Plan State

- Runtime restoration: first milestone substantially achieved
- Historical validation: in progress, and the validation matrix is now explicitly labeled against the published expectations
- Benchmark coverage: solid baseline, but still missing a full `hanoi-4` solve and some additional shipped sample coverage
- Top-level recommendation: converge the repo toward one unified restored
  experimental environment, then keep `hanoi-4` as the highest-priority open
  benchmark inside that structure
- First unification step now in place: the repo has a single experiment entry
  point at [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
- Benchmark-family status is now surfaced directly through the harness via
  `status` / `report benchmark-status`
- The harness now provides lightweight machine-readable summaries for
  `run`, `status`, `report`, and `trace`
- Recommended next track: unify the experiment infrastructure, push the
  strongest remaining `hanoi-4` path, then widen historically grounded
  coverage, then decide how much of the alternate `reset-domain` framework to
  revive

## Current Restoration Milestone

The working `Abtweak-1993` baseline now source-loads under SBCL and solves a small but meaningful set of historical example problems.

The active `hanoi-3` domain also now supports a wider historically relevant
hierarchy family, including `ibsm` and `isbm`, not just the smaller earlier
subset.

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
| `macro-hanoi4-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `macro-hanoi4-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `computer-tweak` | `tweak` | Solves | Cost `6`, plan length `8`, `kval 0` |
| `computer-abtweak` | `abtweak` | Solves | Cost `6`, plan length `8`, `kval 0` |
| `biology-goal1-abtweak` | `abtweak` | Solves | Cost `8`, plan length `10`, `kval 0` |
| `biology-goal2-abtweak` | `abtweak` | Solves | Cost `1`, plan length `3`, `kval 0` |
| `biology-goal3-abtweak` | `abtweak` | Solves | Cost `2`, plan length `4`, `kval 0` |
| `fly-dc-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `database-goal0-tweak` | `tweak` | Solves | Cost `2`, plan length `4`, `kval 0` |
| `database-goal2-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `database-goal2-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `database-goal4-tweak` | `tweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
| `database-goal4-abtweak` | `abtweak` | Solves | Cost `3`, plan length `5`, `kval 0` |
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
  - `biology` goals 1, 2, and 3 solve in `abtweak`
  - `fly` to Washington DC solves in `abtweak`
  - `database` query 0 solves in `tweak`, matching the domain file note that SQL world is not an AbTweak example
- The first broader cross-domain sweep now extends that coverage:
  - `registers` solves in both `tweak` and `abtweak`
  - `blocks` / `interchange` and `blocks` / `flatten` solve in both modes
  - `fly` to both Washington DC and San Francisco solves in both modes
  - `biology` goal 1 solves in both modes, and the full checked-in `biology` goal solves in `abtweak`
  - `database` query 1, query 2, query 3, and query 4 solve in both modes after a small numeric-constant compatibility fix in `var-p`
  - the larger shipped `macro-hanoi` goal pair now solves in both modes too
  - `driving.lisp` and large parts of `newd.lisp` still look like a different planner framework rather than direct AbTweak smoke targets
  - `scheduling.lisp` is a mixed case whose current checked-in entry point depends on that alternate framework
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
    - newly restored permutation-style four-disk variants show that the historical archive does justify additional `hanoi-4` candidates, but they do not beat `ismb` so far:
      - `isbm` is the strongest alternate candidate at `25235` generated on the 20k bound and `129865` on the 100k bound
      - `ibsm` is close behind at `26172` generated on the 20k bound and `133751` on the 100k bound
      - `imbs`, despite strong archived `hanoi3` results, is weak on the current four-disk benchmark at `34836` generated on the 20k bound and `178178` on the 100k bound
    - direct frontier tracing now refines that conclusion:
      - `ismb` still wins on raw search reduction and MP pruning
      - `isbm` keeps much cleaner states in the top priority bucket, with top-ranked nodes around `6` to `9` unsatisfied pairs instead of the `9` to `17` seen in `ismb`
      - `isbm` also keeps its best unsatisfied-pair node in the top bucket, while `ismb` demotes its best such node into the next bucket
      - so `isbm` is now the best comparison hierarchy for diagnosing ranking quality, even though `ismb` remains the strongest practical runtime hierarchy
    - the new direct `hanoi-3` versus `hanoi-4` comparison clarifies that there are really two different failure stories:
      - under the default hierarchy, `hanoi-3` solves almost immediately while `hanoi-4` blows up abstract branching (`3` abstract nodes versus `230`)
      - under `ismb`, both cases show the same general overconcretizing pattern, but `hanoi-4` carries a heavier closure burden because the added `onh` / `moveh` family only lands at the concrete level
    - `ismb` and `critical-list-2` both show strong MP sensitivity, while the default `critical-list-1` does not
    - after the latest cleanup pass, `ismb` with MP and left-wedge also reaches clean `EXPAND-LIMIT-EXCEEDED` results at `150000` expansions (`184610` generated, `183236` MP prunes) and `200000` expansions (`243578` generated, `245293` MP prunes)
    - `ismb` with `:drp-mode t` still does not solve, but it now reports `OPEN-EXHAUSTED` honestly instead of leaving the untouched initial plan in `*solution*`
    - `critical-list-2` has not improved as much under the same deeper runs and can still exhaust the default SBCL heap by `150000`, which makes `ismb` the clearer current restoration target
  - the new control comparison narrows the live `hanoi-4` question further:
    - on `ismb`, the default `num-of-unsat-goals` heuristic is better than a zero heuristic at both 20k and 100k
    - `:abstract-goal-mode t` materially helps on `ismb`, while `:existing-only t` makes no observed difference at the tested bounds
    - `critical-list-2` remains a useful comparison hierarchy, but it is no longer the best current runtime target
  - the checked-in publications now let us interpret those local hierarchies more precisely:
      - `critical-list-1` is the default `IBMS`-style family extended to four disks
      - `ismb` is the `ISMB` family, with omitted `onh` falling to criticality `0` by historical `find-crit` behavior
      - `critical-list-2` is best read as a positive/negative criticality-label experiment rather than a simple permutation like `IBMS`
  - the working-vs-historical review now shows that the `hanoi-4` domain and default abstraction hierarchy are unchanged from the archival code, and that the main precedence rewrite in the working tree preserves the historical reachability relation on randomized checks
  - a dedicated trace runner now exists for larger `hanoi-4` diagnosis:
    - it writes planner output, summary stats, open-frontier snapshots, and DRP-stack snapshots into timestamped directories under [analysis/hanoi4-traces](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)
    - direct frontier inspection now shows those "near-complete" states are actually valid but still heavily underconstrained partial plans:
      - the first open node at the 20k `ismb` bound has cost `15` and length `17`, but still `15` unsatisfied necessary preconditions
      - the highlighted `(ISPEG $var)` case is not a broken binding artifact; it branches cleanly into the expected `(MOVES PEG1 PEG3)` and `(MOVES PEG2 PEG3)` existing-establisher refinements from `I`
      - this points the remaining `hanoi-4` work more toward heuristic and control quality than toward a gross establisher-logic bug
    - the new frontier-quality snapshot sharpens that diagnosis further:
      - the best priority bucket is dominated by concrete `kval 0` plans with roughly `9` to `17` unsatisfied user/precondition pairs
      - the best open node by closure quality has only `2` unsatisfied pairs, but sits in a worse priority bucket at `kval 2`
      - this makes the current leading hypothesis a ranking problem that prefers concreteness over closure
      - a matching `tweak` trace at the same 20k bound still has a much larger frontier, but its best closure-oriented nodes stay in the same top priority bucket
      - that makes the bucket-separation effect look specific to the restored `abtweak` path rather than a generic property of `hanoi-4`
      - the score breakdown now makes the mechanism visible:
        - AbTweak is using `search-cost + num-of-unsat-goals + left-wedge-adjustment`
        - top concrete Hanoi nodes often win with base goal heuristic `0` and left-wedge `-7`
        - unresolved non-goal obligations are not represented directly in that score
      - comparison with the historical manual/report/thesis now suggests this raw Left-Wedge pressure toward refinement is intended design, not a bug by itself
      - the remaining question is whether the current Hanoi hierarchy/control pairing is a historically "good hierarchy" case where that pressure should help, or a case where it should hurt
  - details are recorded in [docs/hanoi4-diagnosis.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md#L1)
  - the hierarchy matrix is recorded in [docs/hanoi4-hierarchy-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md#L1)
  - the candidate-hierarchy follow-up is recorded in [docs/hanoi4b-candidate-hierarchies.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md#L1)
  - the ranking-quality follow-up is recorded in [docs/hanoi4b-frontier-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md#L1)
  - the cross-size comparison is recorded in [docs/hanoi3-vs-hanoi4.md](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md#L1)
  - the current `hanoi-3` hierarchy matrix is now much closer to the historical experiment space:
    - `critical-list-1`, `critical-list-2`, `imbs`, `ibsm`, `isbm`, and `ismb` are now all directly supported in the active domain
    - `critical-list-1` remains the best practical current default at `57` expanded / `99` generated
    - `imbs` is the strongest current permutation-style hierarchy with MP and Left-Wedge both enabled at `86` expanded / `129` generated
    - several of the apparent MP mismatches are now explained by historical control-surface drift between the 1991 and 1993 code lines
    - the new 1991 compatibility layer now reproduces a wider archived case family exactly:
      `isbm` weak-`NEC`, `imbs` weak-`NEC`, `imbs` weak-`POS`, `sbim` weak-`POS`, `sbmi` weak-`POS`, `simb` weak-`POS`, `sibm` weak-`POS`, `smib` weak-`POS`, `misb` weak-`POS`, and the no-MP critical-depth runs for `ismb`, `ibsm`, and `isbm`
  - the `hanoi-3` hierarchy matrix is recorded in [docs/hanoi3-hierarchy-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md#L1)
  - the MSP correspondence note is recorded in [docs/hanoi3-msp-correspondence.md](/Users/stevenwoods/mmath-renovation/docs/hanoi3-msp-correspondence.md#L1)
  - the compatibility harness note is recorded in [docs/hanoi3-1991-compatibility.md](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md#L1)
  - the four-disk historical-control wrapper has now been started too:
    - the archived 1991 `hanoi-4` default hierarchy is exposed as `legacy-1991-default`
    - the new wrapper supports the same `msp-mode`, `msp-weak-mode`, and `crit-depth-mode` vocabulary as the `hanoi-3` compatibility layer
    - at the standard 20k bound, `legacy-1991-default` is clearly weaker than the current best `ismb` path:
      `35214` to `37046` generated for the `legacy-1991-default` runs versus `24568` for `ismb` weak-`POS`
    - `ismb` remains the strongest raw four-disk historical-control path, but weak-`POS` helps `isbm` much more than it helps `ismb`:
      `isbm` improves from `26264` to `24748` generated under weak-`POS`, while `ismb` stays effectively flat at `24565` to `24568`
    - the weak-`POS` frontier traces sharpen that split:
      - `ismb` still has the better raw pruning story
      - `isbm` has the much cleaner top frontier, with top-ranked states around `3` to `6` unsatisfied pairs instead of the `11` to `16` seen in `ismb`
      - the weak-`NEC` versus weak-`POS` comparison suggests the mechanism is real pruning inside `isbm`, not a different abstraction tree:
        `isbm` keeps the same abstraction branching counts while weak-`POS` cuts the frontier from `6263` open nodes to `4747`
    - the starting point is recorded in [docs/hanoi4-1991-compatibility.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md#L1)
  - the control matrix is recorded in [docs/hanoi4-control-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md#L1)
  - the direct frontier inspection is recorded in [docs/hanoi4-frontier-forensics.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md#L1)
  - the frontier-quality comparison is recorded in [docs/hanoi4-frontier-quality.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md#L1)
  - the historical intent comparison is recorded in [docs/left-wedge-intent-comparison.md](/Users/stevenwoods/mmath-renovation/docs/left-wedge-intent-comparison.md#L1)
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
- The largest open gaps are now pushing the best `hanoi-4` configuration toward a full solve, widening historically grounded sample coverage, and deciding how much of the alternate `reset-domain` framework to restore after the main AbTweak path.

## Reproducible Commands

- Loader: [scripts/load-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/load-abtweak-1993-sbcl.sh)
- Smoke runner: [scripts/smoke-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh)
- Comparison runner: [scripts/compare-abtweak-1993-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-abtweak-1993-sbcl.sh)
- Wide sweep runner: [scripts/wide-domain-sweep-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/wide-domain-sweep-sbcl.sh)
- Hanoi-3 hierarchy runner: [scripts/compare-hanoi3-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-hierarchies-sbcl.sh)
- Hanoi-3 historical controls runner: [scripts/compare-hanoi3-historical-controls-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-historical-controls-sbcl.sh)
- Hanoi-4 historical controls runner: [scripts/compare-hanoi4-historical-controls-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-historical-controls-sbcl.sh)
- Hanoi hierarchy runner: [scripts/compare-hanoi4-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh)
- Hanoi controls runner: [scripts/compare-hanoi4-controls-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-controls-sbcl.sh)

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
