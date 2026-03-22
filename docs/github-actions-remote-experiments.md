# GitHub Actions Remote Experiments

This note defines the simplest free remote execution surface for this project.

The current recommendation is:

- use GitHub Actions as the remote run UI
- keep the repo's local command surface as the execution contract
- expose only curated experiment names and curated experiment-set presets

That gives the project a browser-based remote runner without requiring a
separate hosted backend.

## Why This Is The Current Remote Interface

The repo already has a stable local experiment front door in
[scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh).

The current planner runtime is shell-driven and SBCL-based, which makes it a
much better fit for batch execution than for a short-lived serverless request.

GitHub Actions therefore acts as:

- the free remote trigger surface
- the execution environment
- the log viewer
- the artifact store for run outputs

## Current Remote Surfaces

### Single Experiment Workflow

Workflow file:

- [.github/workflows/remote-experiment.yml](/Users/stevenwoods/mmath-renovation/.github/workflows/remote-experiment.yml)

Browser entry point:

- [Run remote experiment](https://github.com/sgwoods/mmath-renovation/actions/workflows/remote-experiment.yml)

Inputs:

- `kind`: `status`, `run`, `report`, or `trace`
- `name`: curated harness name, or `-` for `status`

The workflow uses:

- [scripts/github-actions-run-experiment.sh](/Users/stevenwoods/mmath-renovation/scripts/github-actions-run-experiment.sh)

That wrapper:

- validates the requested item against the harness lists
- runs the existing local harness command
- captures both plain output and JSON output where available
- writes a compact markdown summary for the Actions job summary
- copies trace directories into the uploaded artifacts when a trace run creates one

### Experiment Set Workflow

Workflow file:

- [.github/workflows/remote-experiment-set.yml](/Users/stevenwoods/mmath-renovation/.github/workflows/remote-experiment-set.yml)

Browser entry point:

- [Run remote experiment set](https://github.com/sgwoods/mmath-renovation/actions/workflows/remote-experiment-set.yml)

Preset runner:

- [scripts/github-actions-run-experiment-set.sh](/Users/stevenwoods/mmath-renovation/scripts/github-actions-run-experiment-set.sh)

Current presets:

- `status-snapshot`
- `hanoi4-focused`
- `publication-surface`

These are intentionally conservative. They are meant to be safe browser-driven
entry points into the existing harness, not a new arbitrary shell interface.

## What A Remote Run Produces

Each workflow run produces:

- an Actions job summary
- uploaded artifacts containing:
  - the exact command used
  - plain output
  - JSON output where supported
  - copied trace artifacts for trace workflows

## Curated Input Rule

The remote surface is intentionally limited to curated names already known to
the harness.

That means:

- no arbitrary shell commands
- no arbitrary Lisp expressions
- no arbitrary domain uploads

This keeps the remote interface aligned with the project's historical baseline
and makes the free hosted runner easier to trust.

## Relationship To The Main Harness

The remote runner is not a second execution model.

It is a thin browser-triggered layer over:

- [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)

So the same experiment vocabulary exists in both places:

- local shell use
- GitHub Actions remote use

## Current Limits

- The remote surface is intended for curated batch runs, not interactive
  sessions.
- Trace-heavy or especially large runs may still hit hosted-runner time or
  artifact-size limits.
- Domain-definition UI is out of scope for this phase.

## Next Remote Step

If this Actions-based remote surface proves useful, the next improvement would
be a small GitHub Pages front-end that links to the two workflow pages and
explains the curated input values in a more guided way.
