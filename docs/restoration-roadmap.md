# Abtweak-1993 Restoration Roadmap

This document defines the recommended path from the current SBCL port to a historically grounded restoration of `Abtweak-1993`.

## Restoration Goal

A practical definition of "restored" for this project is:

- the working copy in [`working/abtweak-1993`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993) source-loads cleanly enough to run repeatable experiments under a modern Common Lisp
- `tweak` mode solves a small core of canonical examples from the historical distribution
- `abtweak` mode solves a comparable core of abstraction-enabled examples
- left-wedge and monotonic-property-related behavior can be exercised on domains that define the necessary abstractions
- results can be compared against the historical papers, thesis, and manual in a documented way

This does not require bit-for-bit reproduction of old raw counts on the first pass. It does require a faithful enough implementation that historically reported qualitative behavior can be checked.

## Current Position

The project is now beyond loader repair and into planner validation:

- SBCL source-load works through [`init-sbcl.lisp`](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/init-sbcl.lisp#L1)
- bounded `tweak`-mode searches run without immediate SBCL type failures
- `blocks` plus `(sussman)` in `tweak` mode now returns a concrete plan under SBCL
- `blocks` plus `(sussman)` in `abtweak` mode now also returns a concrete plan under SBCL
- `hanoi-3` now returns concrete plans in both `tweak` and `abtweak` modes under SBCL when run with larger bounds
- `macro-hanoi` now returns concrete plans in both `tweak` and `abtweak` modes under SBCL
- `hanoi-4` currently reaches `EXPAND-LIMIT-EXCEEDED` in both `tweak` and `abtweak` at the exploratory larger-Hanoi smoke bounds
- the current evidence suggests that `hanoi-4` is bounded by search growth in the restored BFS path more than by an obvious semantic break, but the DFS control path is not yet restored enough to use as a diagnostic comparison
- the stack-based DFS path now executes again under SBCL, but current DFS runs still tend toward solution-limit exhaustion or CPU-time exhaustion rather than useful benchmark comparisons
- `simple-robot-2` now returns a concrete plan in `abtweak` mode under SBCL using the manual-style user heuristic and primary effects configuration
- `simple-robot-2` also now gives the first clear left-wedge-sensitive result: the same `abtweak` configuration reaches `EXPAND-LIMIT-EXCEEDED` when `:left-wedge-mode nil`
- remaining work is now about broadening benchmark coverage and validating historical behavior, not just getting the abstraction path to execute once

## Recommended Phases

### Phase 1: Stabilize Plain Tweak

Goal:

- establish one or more canonical `tweak` cases that reliably return plans

Tasks:

- keep compatibility edits confined to the working tree
- reduce remaining accidental historical type declarations in the live `tweak` path
- add repeatable smoke cases for:
  - `blocks` / `sussman`
  - `loop`
  - `hanoi-3`
  - `registers`
- record termination reason, plan cost, and plan length for each run

Exit criteria:

- at least one canonical `tweak` example solves reproducibly
- bounded-search failures are understandable and repeatable rather than crash-driven

### Phase 2: Restore Core AbTweak Execution

Goal:

- get `abtweak` mode past initialization, validity checking, and successor generation on at least one abstraction-enabled domain

Tasks:

- clean the AbTweak-specific declaration issues in:
  - `ab-mtc`
  - `ab-successors`
  - abstraction bookkeeping helpers
  - critical-list and left-wedge support code
- confirm that initial abstraction level (`kval`) is set as expected
- verify that `abtweak` can refine plans rather than stopping in the abstraction-specific search path

Exit criteria:

- one small abstraction-enabled example returns a real plan in `abtweak` mode
- `plan-kval` reaches `0` at the returned solution

### Phase 3: Reconstruct Historical Benchmark Set

Goal:

- map the historically discussed domains and experiment themes to concrete runnable examples in the recovered tree

Tasks:

- use [`docs/historical-validation-matrix.md`](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md#L1) as the central checklist
- identify which local domain files correspond to benchmark themes in the papers and thesis
- capture baseline commands, bounds, and planner modes for each benchmark

Exit criteria:

- every historically important benchmark theme has a named local counterpart and a runnable command

### Phase 4: Validate Historically Reported Behavior

Goal:

- compare modern runs with the previously reported behavior rather than only checking whether code runs

Tasks:

- compare `tweak` versus `abtweak` on the same problems
- compare left-wedge on/off where domains define `*left-wedge-list*`
- compare monotonic-property modes where the abstraction hierarchy is meaningful
- record whether results match the historical claims qualitatively:
  - solved versus unsolved
  - plan size trends
  - search reduction trends
  - abstraction-level behavior

Exit criteria:

- a written comparison exists for the core benchmark set, including any mismatches
- at least one benchmark demonstrates a repeatable left-wedge effect rather than only a left-wedge toggle that happens to preserve the same result

### Phase 5: Reduce Noise And Preserve Reproducibility

Goal:

- make the restored system easier to rerun and analyze

Tasks:

- add explicit global `defvar` declarations where old implicit-special usage causes SBCL warnings
- keep smoke scripts under [`scripts/`](/Users/stevenwoods/mmath-renovation/scripts)
- write down known differences between historical Allegro behavior and current SBCL behavior

Exit criteria:

- the restoration process is scripted enough that the same checks can be rerun after each compatibility change

## Definition Of Done For A First Restoration Milestone

The first strong milestone should be:

- `tweak` solves `blocks` / `sussman`
- `tweak` solves at least one additional canonical example
- `abtweak` solves one abstraction-enabled example
- left-wedge can be toggled on at least one domain that defines `*left-wedge-list*`
- the benchmark matrix has current status for each historical theme

After that, the project can focus on tighter comparison with the thesis and reports rather than basic runtime recovery.
