# Changelog

This changelog tracks named renovation snapshots for the restored
`Abtweak-1993` experiment environment.

The project is still pre-`1.0`. During this phase:

- `beta` releases are research-grade restoration checkpoints
- `rc` releases are publication-alignment candidates
- `1.0.0` is reserved for the first historically grounded restored release

## 0.9.0-beta.1 - 2026-03-18

This is the first formal late pre-release checkpoint for the restored
experiment harness.

Highlights:

- unified experiment entry point via
  [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
- broad operator-style domain coverage restored under SBCL
- exact representative `hanoi-3` matches for the historical 1991 MSP control
  family
- checked-in publications and a formal publication/domain crosswalk
- structured `hanoi-4` diagnostics, including replay, score-sensitivity,
  lineage, and divergence tracing

Known gaps at this checkpoint:

- `hanoi-4` remains only partially reproduced
- the alternate `reset-domain` / `defstep` framework is still a separate
  follow-on track
- this is a source-and-harness release, not a packaged binary release
