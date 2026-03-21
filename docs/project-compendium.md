# Project Compendium

This is the most complete readable project overview in the repository.

It is intended to be the first place a human reader goes to understand:

1. what this project is trying to restore
2. what is already working
3. what has been validated against publications
4. what is still open
5. how the repository is organized
6. how the public-facing status and release process fit together

It complements rather than replaces the more focused notes.

Core companion documents:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Publication domain crosswalk](/Users/stevenwoods/mmath-renovation/docs/publication-domain-crosswalk.md)
- [Repository coverage matrix](/Users/stevenwoods/mmath-renovation/docs/repository-coverage-matrix.md)
- [Repository structure review](/Users/stevenwoods/mmath-renovation/docs/repository-structure-review.md)
- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)

## Index

- [At a glance](#at-a-glance)
- [Primary goal](#primary-goal)
- [Current release state](#current-release-state)
- [Primary working system](#primary-working-system)
- [Benchmark and validation state](#benchmark-and-validation-state)
- [Hanoi ladder](#hanoi-ladder)
- [Hanoi-4 state](#hanoi-4-state)
- [Repository structure](#repository-structure)
- [Publication and source basis](#publication-and-source-basis)
- [Experiment surface](#experiment-surface)
- [Public status and release surfaces](#public-status-and-release-surfaces)
- [Intake workflow](#intake-workflow)
- [Historical and adjacent systems](#historical-and-adjacent-systems)
- [Main open work](#main-open-work)
- [Recommended next steps](#recommended-next-steps)
- [Quick navigation](#quick-navigation)

## At a Glance

This repository is a living restoration of Steven Woods' Masters of
Mathematics work on AbTweak, a hierarchical nonlinear planner developed at the
University of Waterloo.

The project is no longer in a fragile bootstrap phase. It now has:

- one stable SBCL working line for the primary operator-style planner
- one unified experiment harness
- one formal validation story across publications, manual examples, and
  historical artifacts
- one explicit intake path for newly discovered material
- one public release/dashboard/status surface

The main remaining technical gap is not whether the restoration works at all.
It is the still-open `hanoi-4` extension benchmark.

## Primary Goal

The primary goal is:

build one maintained restored experimental environment that stands in for the
historical AbTweak code lines closely enough to reproduce the documented
capabilities, controls, benchmark behavior, and published experimental claims.

That means the finished project should provide:

- one primary working implementation base
- one historically grounded compatibility surface for important older controls
- one experiment front door for smoke cases, comparison reports, traces, and
  status summaries
- one clear publication-validation story
- one clear separation between restored historical behavior and later
  non-historical extensions

## Current Release State

Current named release checkpoint:

- `0.10.0-beta.1`

Current release interpretation:

- late beta
- research-grade restoration checkpoint
- strong on the core operator-style baseline
- not yet a release candidate because `hanoi-4` remains open and the alternate
  `reset-domain` framework is still separate

Release-facing references:

- [VERSION](/Users/stevenwoods/mmath-renovation/VERSION)
- [CHANGELOG.md](/Users/stevenwoods/mmath-renovation/CHANGELOG.md)
- [Release snapshot](/Users/stevenwoods/mmath-renovation/releases/0.10.0-beta.1/release-summary.md)
- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)

## Primary Working System

The active restored implementation is:

- [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)

This is the primary maintained code line for:

- `tweak`
- `abtweak`
- historically grounded compatibility controls layered onto the same baseline

Important supporting components:

- domains:
  [working/abtweak-1993/Domains](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains)
- compatibility surface:
  [working/abtweak-1993/historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp)
- release/build scripts:
  [scripts](/Users/stevenwoods/mmath-renovation/scripts)

The policy boundary for this baseline is explicit in:

- [Algorithm strategy policy](/Users/stevenwoods/mmath-renovation/docs/algorithm-strategy-policy.md)

## Benchmark and Validation State

The core validation story is now strong.

Broadly:

- `blocks`, `nils-blocks`, `registers`, `robot`, `computer`, `biology`,
  `fly`, `database`, `stylistics`, and macro-Hanoi variants are working
- the lower Hanoi families are historically aligned
- the main remaining benchmark gap is `hanoi-4`

Best overview documents:

- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Publication domain crosswalk](/Users/stevenwoods/mmath-renovation/docs/publication-domain-crosswalk.md)
- [Tweak vs AbTweak comparison](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)
- [Wide domain sweep](/Users/stevenwoods/mmath-renovation/docs/wide-domain-sweep.md)

High-level status by family:

| Family | State |
| --- | --- |
| Canonical blocks | strong |
| Nilsson blocks | strong |
| Robot planning | strong qualitative publication match |
| Registers and sample manual domains | strong |
| Hanoi-2 | exact archived-family match |
| Hanoi-3 | exact or near-exact publication alignment |
| Hanoi-4 | open, but tightly diagnosed |

## Hanoi Ladder

The repo now has a cleaner Hanoi ladder than it did earlier in the project:

1. `hanoi-2`
2. `hanoi-3`
3. `hanoi-4`

This matters because it means the larger open case sits on top of a validated
historical base rather than replacing it.

Supporting notes:

- [Hanoi-2 1990 compatibility](/Users/stevenwoods/mmath-renovation/docs/hanoi2-1990-compatibility.md)
- [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [Hanoi-3 1991 compatibility](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)
- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)

Current interpretation:

- `hanoi-2` is exact
- `hanoi-3` is the strongest exact publication-aligned slice of the repo
- `hanoi-4` is a historically grounded extension benchmark, not the core test
  of whether the thesis results reproduce at all

## Hanoi-4 State

`hanoi-4` is still the main open benchmark.

The important current conclusions are:

- the failure is not a loader or bootstrap defect
- the restored baseline is historically plausible
- several hierarchy and control families have been explored carefully
- the strongest current solve-oriented runtime line is still
  `isbm + weak-POS + stack + Left-Wedge`
- the strongest grouped-top analogue is `legacy-1991-isbm`
- none of the current lines solve classic 3-peg `hanoi-4` yet

Most important references:

- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 solve candidate comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-solve-candidate-comparison.md)
- [Hanoi-4 scaling graphic](/Users/stevenwoods/mmath-renovation/docs/hanoi4-scaling-graphic.md)
- [Hanoi-4 hierarchy experiment plan](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-experiment-plan.md)
- [Hanoi-4 publication-to-code mapping](/Users/stevenwoods/mmath-renovation/docs/hanoi4-publication-to-code-mapping.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)

Useful caution:

- cheaper failure is not benchmark progress on `hanoi-4`
- the problem is binary: either the rings end up on the goal peg or they do not
- lower node count on an unsolved run is diagnostic only unless it leads to a
  real solution or a much tighter causal explanation

## Repository Structure

Primary top-level areas:

- [working](/Users/stevenwoods/mmath-renovation/working):
  active restored systems
- [historical](/Users/stevenwoods/mmath-renovation/historical):
  frozen archival material and adjacent systems
- [publications](/Users/stevenwoods/mmath-renovation/publications):
  checked-in paper, report, and thesis sources
- [scripts](/Users/stevenwoods/mmath-renovation/scripts):
  runnable harness, reporting, build, and sync entry points
- [analysis](/Users/stevenwoods/mmath-renovation/analysis):
  generated outputs, trace captures, graphs, and datasets
- [docs](/Users/stevenwoods/mmath-renovation/docs):
  formal interpretation and planning notes
- [site](/Users/stevenwoods/mmath-renovation/site):
  public-facing page/dashboard sources
- [intake](/Users/stevenwoods/mmath-renovation/intake):
  new material waiting for review and proper placement

Structure references:

- [Repository coverage matrix](/Users/stevenwoods/mmath-renovation/docs/repository-coverage-matrix.md)
- [Repository structure review](/Users/stevenwoods/mmath-renovation/docs/repository-structure-review.md)

## Publication and Source Basis

The main checked-in publication set lives in:

- [publications](/Users/stevenwoods/mmath-renovation/publications/README.md)

Current source basis includes:

- AAAI 1990 paper
- Waterloo TR-65 report
- full MMath thesis PDF
- CMU AI Repository page

These are used throughout the repo for:

- validation claims
- publication crosswalks
- historical-control interpretation
- provenance and citation

The maintained thesis figure gallery now lives in:

- [Thesis side-by-side graphics](/Users/stevenwoods/mmath-renovation/docs/thesis-side-by-side-graphics.md)

## Experiment Surface

The unified experiment front door is:

- [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)

Main surfaces exposed there:

- `list`
- `run CASE`
- `trace NAME`
- `report NAME`
- `status`

This is the normal entry point for:

- smoke runs
- comparison reports
- historical-control matrices
- trace workflows
- benchmark-family status summaries

Details:

- [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md)

## Public Status and Release Surfaces

This project now maintains a public-facing status layer in addition to the
internal repo docs.

Main public surfaces:

- public project page
- release dashboard
- public status manifest for the shared homepage renderer

The repo source and process for those are documented in:

- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)

Current rule:

- public Pages should update on numbered checkpoints or deliberate status
  refreshes
- not on every experiment commit

The release snapshot build now refreshes:

- release snapshot files under [releases](/Users/stevenwoods/mmath-renovation/releases/README.md)
- the public MMath page
- the public release dashboard
- the MMath public status manifest

## Intake Workflow

Newly discovered material should go to:

- [intake](/Users/stevenwoods/mmath-renovation/intake/README.md)

This is the required staging lane for:

- newly found code
- new publications
- new experiments
- raw archival exports

Only after review should items move into:

- `working/`
- `historical/`
- `publications/`
- `analysis/`

This keeps provenance, redundancy, and current project relevance explicit.

## Historical and Adjacent Systems

The repo now distinguishes clearly between:

- primary system artifacts that belong to the active restoration
- separate but potentially useful adjacent systems
- redundant archival material with no current go-forward value

Key references:

- [Historical adjacent systems](/Users/stevenwoods/mmath-renovation/docs/historical-adjacent-systems.md)
- [PlanMerge inventory](/Users/stevenwoods/mmath-renovation/docs/planmerge-inventory.md)
- [Mini-Tweak lineage](/Users/stevenwoods/mmath-renovation/docs/mini-tweak-lineage.md)

Examples:

- separate but potentially useful:
  `Mini-Tweak`, `PlanMerge`, `A-star`, `KautzPR`, `Mvl`
- clearly redundant or packaging-only:
  `historical/PlanMerge2`, `historical/__MACOSX`

## Main Open Work

The biggest remaining work items are:

1. keep the `hanoi-4` investigation honest, narrow, and historically grounded
2. continue to tighten publication-facing validation where the sources justify it
3. decide when to open phase 2 for the alternate `reset-domain` / `defstep`
   framework

The project is not missing a general baseline anymore.
It is now in the phase of tightening and finishing.

## Recommended Next Steps

Current best order:

1. continue the focused `hanoi-4` path
2. keep validation and crosswalk docs current as the picture sharpens
3. only widen benchmark coverage where it materially improves the validation story
4. leave `reset-domain` and adjacent-system restoration as separate later tracks

## Quick Navigation

If you only open a few files, use this set:

- [docs/current-status.md](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [docs/project-goal-roadmap.md](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [docs/publication-domain-crosswalk.md](/Users/stevenwoods/mmath-renovation/docs/publication-domain-crosswalk.md)
- [docs/hanoi4-formal-state.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
- [publications/README.md](/Users/stevenwoods/mmath-renovation/publications/README.md)

If you want the public-facing summary instead:

- public project page
- public release dashboard

If you want the long historical benchmark story:

- [docs/hanoi-publication-alignment.md](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [docs/thesis-side-by-side-graphics.md](/Users/stevenwoods/mmath-renovation/docs/thesis-side-by-side-graphics.md)
