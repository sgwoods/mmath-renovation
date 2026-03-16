# Experiment Harness

This document defines the current front door for running the restored AbTweak
environment.

The immediate goal is not to replace every existing script. It is to make the
repo behave like one coherent experimental system by providing one stable entry
point and one stable vocabulary for:

- named single-case runs
- named comparison reports
- named trace workflows

The current front door is:

- [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)

## Top-Level Commands

The unified harness supports five top-level commands:

1. `help`
2. `list`
3. `run`
4. `report`
5. `trace`

Examples:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report compare-core
HIERARCHY=isbm MP_WEAK_MODE=pos HISTORICAL_MODE=t LEFT_WEDGE_MODE=nil \
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4
```

## Standardized Surfaces

### `run CASE`

This is the single-case surface.

It delegates to the working SBCL smoke runner and should be the default way to
run one named experiment case.

The available cases are whatever the smoke runner currently exposes. They can
be listed with:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list cases
```

### `report NAME`

This is the standard report surface.

The current named reports are:

- `compare-core`
- `wide-domain-sweep`
- `hanoi3-hierarchies`
- `hanoi3-historical`
- `hanoi4-controls`
- `hanoi4-hierarchies`
- `hanoi4-historical`

These map to the existing comparison scripts, but the intent is that users
should call them through one shared vocabulary instead of memorizing separate
script filenames.

### `trace NAME`

This is the standard trace surface.

The current named trace workflows are:

- `hanoi3`
- `hanoi4`

These keep the existing environment-variable control style, which is useful for
experimental work, but they now sit behind a common dispatch point.

## Current Layering

The harness now makes the repo read more clearly as three layers:

1. core planner implementation in
   [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)
2. historical compatibility helpers in the same working tree
3. one experiment entry point in
   [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)

That is the first concrete step toward the project goal of one restored
experimental environment rather than a collection of separate local probes.

## What This Does And Does Not Solve

This harness improves:

- discoverability
- reproducibility
- naming consistency
- the distinction between single-case runs, reports, and traces

It does not by itself:

- solve `hanoi-4`
- generalize the historical compatibility layer beyond the currently restored
  families
- absorb the alternate `reset-domain` / `defstep` framework

Those remain separate project tracks.

## Next Consolidation Steps

The next natural follow-ons are:

1. add a benchmark-family status command or generated summary
2. standardize machine-readable result summaries across `run`, `report`, and
   `trace`
3. bring the historical-control naming used in the Hanoi compatibility work
   into the same shared harness vocabulary
4. decide whether the alternate `reset-domain` framework should eventually be
   exposed through the same front door
