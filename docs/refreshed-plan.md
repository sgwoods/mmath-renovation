# Refreshed Plan

This document is the current planning snapshot for the AbTweak renovation after:

- restoring a working SBCL baseline for `Abtweak-1993`
- checking the core historical publications into [publications/](/Users/stevenwoods/mmath-renovation/publications/README.md)
- clarifying how the local `hanoi-4` hierarchies map to the published experiment language

It is the best place to answer two questions:

1. where are we now?
2. what should we do next?

For the shortest current top-level answer to those questions, see
[Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md).

For the newer top-level framing around one unified restored experimental
environment, see [Unified restoration plan](/Users/stevenwoods/mmath-renovation/docs/unified-restoration-plan.md).

The first concrete consolidation step is now the shared experiment front door
documented in [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md).

The algorithm-boundary rule is now documented in
[Algorithm strategy policy](/Users/stevenwoods/mmath-renovation/docs/algorithm-strategy-policy.md).

## Plan State

### Track 1: Runtime Restoration

Status: mostly complete for the first restoration milestone

What is done:

- the working tree source-loads under SBCL
- `tweak` and `abtweak` both solve a meaningful set of historical examples
- DFS, bound handling, and planner failure reporting are restored enough for diagnostics
- the earlier `hanoi-4` precedence-related heap blow-up is fixed

What is still open:

- `hanoi-4` still does not fully solve at the tested bounds
- some non-fatal SBCL style and redefinition noise remains

### Track 2: Historical Validation

Status: in progress, now on much stronger footing

What is done:

- the core papers, reports, and archive page are checked into the repo
- the validation matrix exists and is source-backed
- the early `hanoi-2` family is now restored as an exact archived-family rerun
- `hanoi-4` hierarchy behavior is no longer a black box
- the current code has been checked against the archival algorithm structure, and no major algorithm drift has been found

What is still open:

- the labeled matrix still needs to be kept current as new benchmark evidence is added
- the most important published claims still need more exact row-by-row metric comparison where the papers report counts

### Track 3: Benchmark Coverage

Status: good baseline, but not yet broad enough to declare restoration finished

What is done:

- core blocks, Nilsson blocks, registers, Hanoi-2, Hanoi-3, macro-Hanoi, and robot examples run
- several shipped sample domains now run under SBCL

What is still open:

- more historically shipped sample cases can still be added
- `hanoi-4` remains the biggest high-value unsolved benchmark

## Recommended Next Sequence

This sequence is still valid, but it should now be read inside the broader
unified-goal framing:

- one implementation base
- one historical compatibility surface
- one experiment harness

### 1. Unify The Main Experiment Infrastructure

Focus on:

- treating the current runners and compatibility helpers as one restored
  experimental environment rather than separate local tools
- standardizing how historical-control runs, smoke runs, and trace runs are
  expressed
- using the Hanoi compatibility layer as the first model for that structure
- extending the new shared entry point in
  [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
  so it becomes the normal way to invoke the environment

Reason:

The project is now mature enough that consolidation is a higher-value next step
than continuing to accumulate isolated probes. This is the cleanest route to a
single working equivalent of the historical experimental infrastructure.

### 2. Push `hanoi-4` Further

Focus on:

- `isbm` weak-`POS` plus Left-Wedge as the strongest current historical-control
  runtime path
- `legacy-1991-isbm` as the first positive grouped-top analogue family
- `critical-list-2` weak-`POS` tree behavior as a smaller historically
  interesting niche

Reason:

This is the highest-value remaining runtime question. We now have a cleaner historical Hanoi ladder, with exact `hanoi-2` and exact `hanoi-3` below it, so `hanoi-4` is now more clearly the main open larger extension benchmark. The next step is to see whether better bounds, tuned settings, or a still-missing fidelity detail can turn that into a real `hanoi-4` solve.

Relevant issue:

- [#14 Investigate hanoi-4 performance after precedence-fix stabilization](https://github.com/sgwoods/mmath-renovation/issues/14)

### 3. Expand Historically Grounded Coverage

Focus on:

- more shipped operator-style sample domains
- more directly reproducible examples that exercise features not yet represented
  in the smoke suite

Reason:

The matrix is now labeled, `stylistics` is restored, and the direct
operator-style sweep is healthy enough that broader historically grounded
coverage is now a secondary confidence-builder after `hanoi-4`, not a primary
gap.

Relevant issue:

- [#13 Expand historical shipped sample-domain smoke coverage](https://github.com/sgwoods/mmath-renovation/issues/13)

### 4. Decide The Alternate Framework Boundary

Focus on:

- `driving.lisp`
- `newd.lisp`
- the mixed `scheduling.lisp` entry points

Reason:

The repo now has enough evidence to say this is not just “more domains.”
It is a separate planner framework boundary, and deciding that explicitly keeps
the main restoration story clean.

Relevant issue:

- [#16 Evaluate reset-domain planner files as a separate restoration track](https://github.com/sgwoods/mmath-renovation/issues/16)

### 5. Trim Residual SBCL Noise

Focus on:

- remaining style warnings
- redefinition chatter
- historical stub/load-order cleanup that does not alter planner semantics

Reason:

This is the best support task for all later debugging. It is not as important as `hanoi-4` or historical validation, but it will make both of those easier.

Relevant issue:

- [#12 Trim residual SBCL style and redefinition noise](https://github.com/sgwoods/mmath-renovation/issues/12)

## Best Alternatives

### Option A: Performance-First

Order:

1. `#14`
2. `#13`
3. `#16`
4. `#12`

Why choose it:

This is the best option if the main goal is to get the planner closer to a fully convincing restored runtime story as quickly as possible.

Tradeoff:

Broader non-Hanoi validation grows a little more slowly while we keep working
the hard larger-Hanoi benchmark.

### Option B: Validation-First

Order:

1. `#13`
2. `#14`
3. `#16`
4. `#12`

Why choose it:

This is the best option if the main goal is to state clearly, right now, what the project already matches from the papers and thesis.

Tradeoff:

The biggest live runtime question, `hanoi-4`, remains unresolved a bit longer.

### Option C: Coverage-First

Order:

1. `#16`
2. `#13`
3. `#14`
4. `#12`

Why choose it:

This is the best option if the main goal is to maximize the number of historically shipped examples that run under SBCL before going deeper on one difficult benchmark.

Tradeoff:

It risks deferring the hardest and most informative restoration question.

## Recommendation

Recommended order:

1. `#14`
2. `#13`
3. `#16`
4. `#12`

Why this order makes the most sense:

- `hanoi-4` is still the clearest remaining benchmark boundary between “strong
  partial restoration” and “historically convincing restoration”
- the repo now has a cleaner historical Hanoi ladder below it, with exact
  `hanoi-2` and exact `hanoi-3` compatibility surfaces already in place
- the publications and hierarchy mapping work mean we now have enough context to investigate `hanoi-4` intelligently
- once that line is pushed as far as practical, broader sample coverage is the
  highest-value way to widen confidence in the restoration
- the alternate `reset-domain` material should be treated deliberately as a
  separate framework question, not mixed into the main smoke story by accident
- warning cleanup is still worthwhile, but it is now a support task rather than
  the main line of progress
