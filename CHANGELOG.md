# Changelog

This changelog tracks named renovation snapshots for the restored
`Abtweak-1993` experiment environment.

The project is still pre-`1.0`. During this phase:

- `beta` releases are research-grade restoration checkpoints
- `rc` releases are publication-alignment candidates
- `1.0.0` is reserved for the first historically grounded restored release

## 1.0.0-rc.1 - 2026-03-22

This checkpoint marks the first release-candidate freeze of the historically
grounded restored AbTweak baseline.

Highlights:

- formal RC gate and repeatable validation sweep now checked into the repo
- `hanoi-4` explicitly accepted as an explained-but-open extension benchmark
  for RC purposes
- release-facing docs, compendium, and roadmap updated around RC readiness
- release snapshot and public status surfaces refreshed from the normal build
  path
- hosted remote experiment UI explicitly treated as a supporting `1.1` line,
  not a blocker for the historical `1.0` baseline
- post-RC go-forward plan added for UI work, research, domain expansion, and
  better visualizations

Known gaps at this checkpoint:

- `hanoi-4` remains open as a binary benchmark and is still the main planner
  research thread after RC
- the alternate `reset-domain` / `defstep` framework remains a separate later
  restoration phase
- the hosted UI and richer public interaction surfaces continue as post-RC
  supporting work, not part of the historical baseline claim

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

## 0.10.0-beta.1 - 2026-03-21

This checkpoint marks the stronger publication-alignment phase of the
restoration effort.

Highlights:

- exact archived-family `hanoi-2` reproduction added to the active harness
- exact publication-surface `hanoi-3` alignment documented and retained
- broader restored operator-style benchmark surface, including `stylistics`
- formal publication-to-code mapping for the four-disk Hanoi extension
- much sharper `hanoi-4` diagnostic story, including historical-control,
  replay, score, lineage, and hierarchy-mapping evidence
- expanded historical cataloging for adjacent systems and newly added archive
  material

Known gaps at this checkpoint:

- `hanoi-4` remains the main open extension benchmark
- the alternate `reset-domain` / `defstep` framework is still intentionally a
  separate later phase
- this remains a research-grade restored source release, not a packaged binary
