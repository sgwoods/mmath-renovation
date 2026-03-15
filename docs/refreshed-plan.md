# Refreshed Plan

This document is the current planning snapshot for the AbTweak renovation after:

- restoring a working SBCL baseline for `Abtweak-1993`
- checking the core historical publications into [publications/](/Users/stevenwoods/mmath-renovation/publications/README.md)
- clarifying how the local `hanoi-4` hierarchies map to the published experiment language

It is the best place to answer two questions:

1. where are we now?
2. what should we do next?

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
- `hanoi-4` hierarchy behavior is no longer a black box
- the current code has been checked against the archival algorithm structure, and no major algorithm drift has been found

What is still open:

- benchmark rows still need explicit labels such as `matched`, `partially matched`, or `open`
- the most important published claims still need direct row-by-row comparison

### Track 3: Benchmark Coverage

Status: good baseline, but not yet broad enough to declare restoration finished

What is done:

- core blocks, Nilsson blocks, registers, Hanoi-3, macro-Hanoi, and robot examples run
- several shipped sample domains now run under SBCL

What is still open:

- more historically shipped sample cases can still be added
- `hanoi-4` remains the biggest high-value unsolved benchmark

## Recommended Next Sequence

### 1. Push `hanoi-4` Further

Focus on:

- `ismb` with MP enabled
- `critical-list-2` with MP enabled

Reason:

This is the highest-value remaining runtime question. We now know hierarchy choice matters and we know which hierarchy families look promising. The next step is to see whether better bounds, tuned settings, or a still-missing fidelity detail can turn that into a real `hanoi-4` solve.

Relevant issue:

- [#14 Investigate hanoi-4 performance after precedence-fix stabilization](https://github.com/sgwoods/mmath-renovation/issues/14)

### 2. Label The Validation Matrix

Focus on:

- mark each benchmark/theme as `matched`, `partially matched`, or `open`
- tie each label to a specific published claim

Reason:

The repo now has enough evidence that the next big improvement is interpretability. This turns the project from “working port” into “historically accountable restoration.”

Relevant issue:

- [#11 Label historical validation matrix against published claims](https://github.com/sgwoods/mmath-renovation/issues/11)

### 3. Trim Residual SBCL Noise

Focus on:

- remaining style warnings
- redefinition chatter
- historical stub/load-order cleanup that does not alter planner semantics

Reason:

This is the best support task for all later debugging. It is not as important as `hanoi-4` or historical validation, but it will make both of those easier.

Relevant issue:

- [#12 Trim residual SBCL style and redefinition noise](https://github.com/sgwoods/mmath-renovation/issues/12)

### 4. Expand Historical Sample Coverage

Focus on:

- more shipped 1993 sample domains
- additional runnable examples that exercise planner features not yet represented in the smoke suite

Reason:

This broadens confidence, but it is a lower priority than resolving the main remaining Hanoi question and labeling the current evidence.

Relevant issue:

- [#13 Expand historical shipped sample-domain smoke coverage](https://github.com/sgwoods/mmath-renovation/issues/13)

## Best Alternatives

### Option A: Performance-First

Order:

1. `#14`
2. `#11`
3. `#12`
4. `#13`

Why choose it:

This is the best option if the main goal is to get the planner closer to a fully convincing restored runtime story as quickly as possible.

Tradeoff:

Historical labeling stays a little behind while we keep working the hard benchmark.

### Option B: Validation-First

Order:

1. `#11`
2. `#14`
3. `#12`
4. `#13`

Why choose it:

This is the best option if the main goal is to state clearly, right now, what the project already matches from the papers and thesis.

Tradeoff:

The biggest live runtime question, `hanoi-4`, remains unresolved a bit longer.

### Option C: Coverage-First

Order:

1. `#13`
2. `#11`
3. `#14`
4. `#12`

Why choose it:

This is the best option if the main goal is to maximize the number of historically shipped examples that run under SBCL before going deeper on one difficult benchmark.

Tradeoff:

It risks deferring the hardest and most informative restoration question.

## Recommendation

Recommended order:

1. `#14`
2. `#11`
3. `#12`
4. `#13`

Why this order makes the most sense:

- `hanoi-4` is the clearest remaining boundary between “strong partial restoration” and “historically convincing restoration”
- the publications and hierarchy mapping work mean we now have enough context to investigate `hanoi-4` intelligently
- once that line is pushed as far as practical, the validation matrix can be labeled with much stronger confidence
- warning cleanup and broader sample coverage are both worthwhile, but they are secondary to those two higher-signal tasks
