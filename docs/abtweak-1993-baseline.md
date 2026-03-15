# Abtweak-1993 Baseline

This document records the decision to use `Abtweak-1993` as the primary working baseline for the renovation effort.

## Chosen Baseline

- Historical source snapshot: [`historical/Abtweak/Abtweak-1993`](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1993)
- Working copy for porting: [`working/abtweak-1993`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)

The historical tree remains the preserved reference snapshot and should not be edited during porting. The working copy is where compatibility edits and runtime experiments should happen.

## What Was Set Up

- Created a source-first working copy of the 1993 tree.
- Excluded stale compiled artifacts such as historical `.fasl` and `.sbin` files from the working copy so SBCL does not try to load implementation-specific binaries.
- Added [`init-sbcl.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/init-sbcl.lisp#L1) as a modern source loader for SBCL.
- Applied early SBCL compatibility fixes in:
  - [`Search-routines/search.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Search-routines/search.lisp#L6)
  - [`plan.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/plan.lisp#L64)
  - [`Tw-routines/tw-heuristic.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/tw-heuristic.lisp#L1)
  - [`Tw-routines/Plan-infer/plan-dependent.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Plan-infer/plan-dependent.lisp#L1)
  - [`Tw-routines/Plan-infer/plan-inference.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Plan-infer/plan-inference.lisp#L115)
  - [`Tw-routines/Plan-infer/plan-modification.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Plan-infer/plan-modification.lisp#L1)
  - [`Tw-routines/Succ/find-nec-exist-ests.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Succ/find-nec-exist-ests.lisp#L1)
  - [`Tw-routines/Succ/find-new-ests.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Succ/find-new-ests.lisp#L1)
  - [`Tw-routines/Succ/select-ops.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/Succ/select-ops.lisp#L1)
  - [`Tw-routines/successors.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/successors.lisp#L1)
  - [`Tw-routines/general.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/general.lisp#L1)
  - [`Tw-routines/tweak-planner-interface.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Tw-routines/tweak-planner-interface.lisp#L1)
  - [`Ab-routines/ab-heuristic.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-heuristic.lisp#L1)
  - [`Ab-routines/abtweak-planner-interface.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/abtweak-planner-interface.lisp#L1)
  - [`Mcallester-plan/mr-planner-interface.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Mcallester-plan/mr-planner-interface.lisp#L1)
  - [`Domains/robot-heuristic.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/robot-heuristic.lisp#L1)
  - [`My-routines/heuristic.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/My-routines/heuristic.lisp#L1)

## Current Verification

### Loader status

SBCL can source-load the working baseline successfully using `init-sbcl.lisp`.

Reusable command:

```sh
/Users/stevenwoods/mmath-renovation/scripts/load-abtweak-1993-sbcl.sh
```

### Runtime status

The planner now runs real bounded searches under SBCL.

What currently works:

- source-loading the planner stack
- loading alternate domains such as `Domains/loop.lisp`
- reaching the `plan` entry point
- entering heuristic evaluation, successor generation, and plan modification
- completing bounded search runs without immediate SBCL type crashes
- solving the local `blocks` / `sussman` problem in `tweak` mode under SBCL
- solving the local `registers` problem in `tweak` mode under SBCL
- solving the local `blocks` / `sussman` problem in `abtweak` mode under SBCL
- solving `hanoi-3` in both `tweak` and `abtweak` modes under SBCL with larger search bounds
- solving `simple-robot-2` in `abtweak` mode under SBCL with `:heuristic-mode 'user-defined` and `:use-primary-effect-p t`
- showing a left-wedge-sensitive outcome on `simple-robot-2`, where the same `abtweak` configuration fails at the current bounds when `:left-wedge-mode nil`

What currently works but does not yet solve:

- `loop` in `tweak` mode now runs to a search outcome of `EXPAND-LIMIT-EXCEEDED`
- `simple-robot-2` in `tweak` mode with the manual-style heuristic configuration still hits `EXPAND-LIMIT-EXCEEDED` at the current smoke bounds

Current observed blocker:

- the next phase is no longer loader repair, but planner validation:
- we need to determine whether current bounded failures reflect historically expected search behavior, conservative bounds, or remaining semantic/typing issues in successor generation and search bookkeeping
- the most important remaining gaps are benchmark breadth and historical comparison, especially `hanoi`, robot domains, left-wedge behavior, and monotonic-property experiments

### Smoke tests used

Reusable loader:

```sh
/Users/stevenwoods/mmath-renovation/scripts/load-abtweak-1993-sbcl.sh
```

Loop stress case:

```sh
/opt/homebrew/bin/sbcl --noinform --disable-debugger \
  --eval '(progn
    (load "init-sbcl.lisp")
    (load "Domains/loop.lisp")
    (let ((result (plan initial goal
                        :planner-mode (quote tweak)
                        :output-file (quote no-output)
                        :expand-bound 50
                        :generate-bound 100
                        :open-bound 100
                        :cpu-sec-limit 10)))
      (format t "PLAN-RESULT: ~S~%" result)
      (format t "SOLUTION-VALUE: ~S~%" *solution*)
      (format t "SOLUTION-TYPE: ~S~%" (type-of *solution*)))))' \
  --quit
```

Current `hanoi-3` working checks:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi3-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi3-abtweak
```

Current observed result:

- `hanoi3-tweak` returns a concrete plan with cost `7`, length `9`, and `kval 0`
- `hanoi3-abtweak` returns a concrete plan with cost `7`, length `9`, and `kval 0`
- these runs currently need larger search bounds than the earlier exploratory smoke settings

Current `simple-robot-2` working checks:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-tweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-abtweak
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh robot2-abtweak-no-lw
```

Current observed result:

- `robot2-abtweak` returns a concrete plan with cost `12`, length `14`, and `kval 0`
- `robot2-tweak` currently terminates with `EXPAND-LIMIT-EXCEEDED` at the same smoke bounds
- `robot2-abtweak-no-lw` currently terminates with `EXPAND-LIMIT-EXCEEDED` at the same smoke bounds
- this is the first validated benchmark using the user-defined heuristic path described in the manual
- this is also the first clear local case where left-wedge changes the observed search outcome under SBCL

Canonical `blocks` / `sussman` check:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-tweak
```

Current observed result:

- `PLAN-RESULT: NIL`
- `SOLUTION-TYPE: PLAN`
- `plan-cost`: `3`
- `plan-kval`: `0`
- solution operator count in `plan-a`: `5` including `I` and `G`

This is the first confirmed planning success in the SBCL port.

Canonical `registers` check:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh registers-tweak
```

Current observed result:

- `PLAN-RESULT: NIL`
- `SOLUTION-TYPE: PLAN`
- `plan-cost`: `3`
- `plan-kval`: `0`
- solution operator count in `plan-a`: `5` including `I` and `G`

Canonical `blocks` / `sussman` AbTweak check:

```sh
/Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh blocks-sussman-abtweak
```

Current observed result:

- `PLAN-RESULT: NIL`
- `SOLUTION-TYPE: PLAN`
- `plan-cost`: `3`
- `plan-kval`: `0`
- solution operator count in `plan-a`: `5` including `I` and `G`
- abstraction bookkeeping is present in `plan-cr` and `plan-op-count`

Initial left-wedge comparison:

- on this small `blocks` / `sussman` benchmark, `:left-wedge-mode t` and `:left-wedge-mode nil` currently produce the same observed solution cost, length, and final `kval`
- on `simple-robot-2`, `:left-wedge-mode t` currently solves with cost `12`, length `14`, and `kval 0`, while `:left-wedge-mode nil` reaches `EXPAND-LIMIT-EXCEEDED` at the same bounds
- that makes `simple-robot-2` the first local benchmark showing a historically meaningful left-wedge difference in the restored working tree

## Why This Baseline Still Makes Sense

Even with the current runtime blocker, `Abtweak-1993` is still the best base because it gives us:

- the richest modular source tree
- the broadest set of domains
- the McAllester planner branch
- local documentation in `Doc/`
- the clearest platform for iterative compatibility fixes

## Recommended Next Porting Steps

1. keep `blocks` / `sussman` as the first passing `tweak` regression and rerun it after each compatibility change
2. keep `blocks` / `sussman` as the first passing `abtweak` regression and compare it directly with the `tweak` result
3. keep `hanoi-3` as the first abstraction-heavy regression in both `tweak` and `abtweak`
4. keep `simple-robot-2` as the first left-wedge-sensitive regression and compare it more structurally with `hanoi-3`
5. add explicit declarations for global special variables early enough to reduce SBCL source-load noise
