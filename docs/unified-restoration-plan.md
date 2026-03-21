# Unified Restoration Plan

This document reframes the project around the top-level goal that now matters
most:

build one single restored experimental environment that can stand in for the
historical AbTweak code lines closely enough to reproduce the documented
capabilities, controls, and experimental results.

It complements:

- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Restoration roadmap](/Users/stevenwoods/mmath-renovation/docs/restoration-roadmap.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

## North Star

The project should not end as:

- a working 1993 SBCL port plus
- a separate pile of one-off historical investigations plus
- a second pile of archived trees that happen to explain some differences

It should end as:

- one maintained working environment
- one coherent experiment harness
- one documented compatibility surface for historically important controls
- one benchmark matrix that lets us rerun and compare the historically reported
  AbTweak behavior
- one explicit boundary between the historical restored baseline and any later
  non-domain-specific strategy extensions

In practical terms, that means the working tree should eventually provide a
single place from which we can run:

1. the core 1993 `tweak` and `abtweak` planner behavior
2. the historically important 1991-era control variations where those matter
3. the shipped operator-style examples and the main published benchmark cases
4. the comparison and tracing workflows needed to validate the results

## Strategy Boundary

The restored `Abtweak-1993` baseline should remain historically aligned by
default.

That means:

- historical controls, scoring, and abstraction behavior stay in the baseline
  unless there is strong evidence that the restored code is simply wrong
- instrumentation and diagnostics are encouraged
- generic non-domain-specific search improvements should not be folded into the
  baseline silently

If we introduce a new general strategy to help cases like `hanoi-4`, it should
be named and documented as a distinct extension rather than relabeled as the
historical AbTweak baseline.

## Where We Are Now

The project is already much closer to that than it was at the start.

What is effectively working today:

- the 1993 operator-style planner path runs under SBCL
- the core `plan` path supports both `tweak` and `abtweak`
- a meaningful historical sample set now solves
- the repo has a repeatable smoke suite, comparison scripts, and trace tooling
- historically important 1991 Hanoi control families are now exposed through a
  compatibility layer in the working tree

What is still fragmented:

- the historical-control compatibility surface is strong for Hanoi, but not yet
  generalized as a single experiment harness concept
- the larger `hanoi-4` result is still not a solve
- the alternate `reset-domain` / `defstep` framework is still outside the main
  restored environment
- the validation story is strong qualitatively, but not yet complete as a
  claim-by-claim reproduction of the published experiments

## Recommended Top-Level Architecture

The cleanest target from here is to make the restored repo converge on three
layers.

### Layer 1: Core Restored Planner

This is the main working environment in
[working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993).

It should remain the single implementation base for:

- `tweak`
- `abtweak`
- the current SBCL compatibility fixes
- the default domain and experiment runners

This is already the right place to keep semantic fixes and compatibility work.

### Layer 2: Historical Compatibility Surface

This should be a thin, explicit layer on top of the core planner, not a second
planner.

Its job is to re-expose historically important controls such as:

- `msp-mode`
- `msp-weak-mode`
- `crit-depth-mode`
- historically named hierarchy selections
- historically named experiment families

The new Hanoi compatibility work shows this is feasible and useful.

This layer should become the standard way to express older experimental runs in
the restored environment.

### Layer 3: Experiment Harness

This should be the single user-facing way to reproduce results.

It should unify:

- smoke runs
- historical comparison runs
- trace runs
- benchmark matrices
- result summaries

Right now the pieces exist, but they are spread across many scripts. The next
real consolidation step is to make them feel like one environment instead of a
toolbox of separate probes.

## Main Gaps To Close

From the perspective of the unified goal, the remaining gaps are:

1. `hanoi-4` is still the biggest missing benchmark result.
2. The historical compatibility layer is still domain-specific rather than a
   general experiment surface.
3. The alternate `reset-domain` / `defstep` framework is still a separate
   restoration problem.
4. The validation matrix still needs a clearer "reproduced / explained / open"
   summary at the experiment-family level.

## Best Forward Options

### Option 1: Unify The Main Experiment Infrastructure

Goal:

- turn the current scripts and compatibility helpers into one coherent restored
  experimental environment

What this means:

- define a standard runner model for:
  - core planner runs
  - historical-control runs
  - trace runs
  - result-comparison runs
- normalize how experiments are named, invoked, and summarized
- treat the current Hanoi compatibility layer as the first example of the
  restored historical-control surface, not a special-case side path

Why this is attractive:

- it directly serves the "single working equivalent version" goal
- it reduces future drift between runtime work and validation work
- it makes later reproduction of paper results much easier

Tradeoff:

- it does not by itself solve `hanoi-4`

### Option 2: Finish The Main Runtime Story First

Goal:

- keep pushing the current `hanoi-4` line until the core AbTweak runtime story
  feels as complete as practical

What this means:

- continue the current `isbm`-centered investigation
- keep `legacy-1991-isbm` as the strongest grouped-top analogue line
- focus on scoring, frontier quality, and pruning behavior
- aim either for:
  - a full solve, or
  - a historically grounded explanation of why the solve is still missing

Why this is attractive:

- `hanoi-4` is still the clearest remaining boundary between “restored enough”
  and “historically convincing”

Tradeoff:

- the overall infrastructure can continue to feel fragmented while we keep
  focusing on one hard benchmark

### Option 3: Broaden To Full Historical Infrastructure Parity

Goal:

- bring the alternate `reset-domain` / `defstep` framework into the same
  restored environment

What this means:

- restore the non-operator-style experimental framework behind:
  - `driving.lisp`
  - `newd.lisp`
  - the mixed `scheduling.lisp` cases

Why this is attractive:

- this is the path to a truly broader “all versions over time” environment

Tradeoff:

- it is a larger fork in scope
- it risks delaying the cleaner closure of the main AbTweak restoration story

## Recommendation

The best overall path is:

1. unify the main experiment infrastructure
2. within that unified structure, keep `hanoi-4` as the highest-priority open
   runtime/validation target
3. only after that, decide whether to absorb the `reset-domain` framework into
   the same restored environment or keep it as a deliberate phase-2 subsystem

That recommendation balances the real state of the repo:

- the core planner is now strong enough to deserve consolidation
- the historical-control surface is now real enough to standardize
- `hanoi-4` is still important, but no longer the only thing that defines the
  project's success

## Suggested Next Sequence

1. Create a unified experiment-harness plan for the current scripts and control
   surfaces.
2. Recast the current Hanoi compatibility work as the first standardized
   historical experiment family in that harness.
3. Add a benchmark-status summary layer that says, for each historically
   important experiment family:
   - reproduced
   - partially reproduced
   - explained but not yet reproduced
   - still open
4. Continue the `hanoi-4` investigation inside that new structure.
5. Decide whether the `reset-domain` framework belongs in the same milestone or
   in a later dedicated phase.

## Definition Of Success

The unified restoration should be considered successful when the repo offers:

1. one maintained restored implementation base
2. one explicit historical compatibility surface
3. one coherent experiment harness
4. one documented benchmark matrix tied to the publications
5. one clear statement of what has been fully reproduced, what is only
   explained, and what remains open
