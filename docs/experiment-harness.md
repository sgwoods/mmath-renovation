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

The unified harness supports six top-level commands:

1. `help`
2. `list`
3. `status`
4. `run`
5. `report`
6. `trace`

Examples:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh list
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak --json
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report benchmark-status
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report benchmark-status --json
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi3-historical
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos-lw
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

The `run` surface now also supports a first machine-readable summary mode:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh run blocks-sussman-abtweak --json
```

That JSON does not attempt to serialize the full returned plan. It standardizes
the main labeled summary fields already used in the smoke output.

### `status`

This is the benchmark-family status surface.

It provides the short project-level answer to:

- what major historical experiment families are reproduced already
- what is only partially reproduced
- what is still open

The current text form is backed by:

- [scripts/benchmark-status-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/benchmark-status-sbcl.sh)

It also supports a lightweight JSON form:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh status --json
```

### `report NAME`

This is the standard report surface.

The current named reports are:

- `benchmark-status`
- `compare-core`
- `hanoi-search-baselines`
- `wide-domain-sweep`
- `hanoi3-hierarchies`
- `hanoi3-historical`
- `hanoi4-controls`
- `hanoi4-hierarchies`
- `hanoi4-historical`

These map to the existing comparison scripts, but the intent is that users
should call them through one shared vocabulary instead of memorizing separate
script filenames.

The `report` surface now also supports a first JSON wrapper:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report benchmark-status --json
```

That wrapper exposes the report name, its top heading, and the emitted markdown
body as one machine-readable object.

The historical Hanoi report families should now be treated as harness-native
entry points:

- `report hanoi3-historical`
- `report hanoi4-historical`

### `trace NAME`

This is the standard trace surface.

The current named trace workflows are:

- `hanoi3`
- `hanoi4`
- `hanoi4-ismb-weak-pos`
- `hanoi4-isbm-weak-pos`
- `hanoi4-isbm-weak-pos-lw`
- `hanoi4-legacy-1991`

These keep the existing environment-variable control style where it is useful,
but the named Hanoi presets now expose the most important historical-control
cases through the same shared harness vocabulary.

The `trace` surface also now supports a first machine-readable summary mode:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos --json
```

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
- the project-level visibility of benchmark-family status
- the machine-readable summaries available for `run`, `status`, `report`, and
  `trace`

It does not by itself:

- solve `hanoi-4`
- generalize the historical compatibility layer beyond the currently restored
  families
- absorb the alternate `reset-domain` / `defstep` framework

Those remain separate project tracks.

## Next Consolidation Steps

The next natural follow-ons are:

1. add richer metadata around the available cases, reports, and trace presets
2. bring more of the historical-control naming used in the Hanoi compatibility work
   further into the same shared harness vocabulary
3. decide whether the alternate `reset-domain` framework should eventually be
   exposed through the same front door
