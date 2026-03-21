# Repository Structure Review

This note reviews whether the repository layout makes it clear:

1. what the primary restored system is
2. where domain definitions live
3. where generators, traces, and output artifacts live
4. where public-facing deliverables live
5. what is not integrated into the main system

It also records naming and structure guidance so the repo stays understandable
as more material is added.

It complements:

- [Repository coverage matrix](/Users/stevenwoods/mmath-renovation/docs/repository-coverage-matrix.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Domain inventory](/Users/stevenwoods/mmath-renovation/docs/domain-inventory.md)
- [Historical adjacent systems](/Users/stevenwoods/mmath-renovation/docs/historical-adjacent-systems.md)

## Current Top-Level Structure

| Path | Current role | Clarity | Notes |
| --- | --- | --- | --- |
| [working](/Users/stevenwoods/mmath-renovation/working) | active restored implementation base | High | This clearly reads as the primary system area. |
| [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993) | main restored planner line | High | Best-labeled primary runtime tree in the repo. |
| [working/abtweak-1993/Domains](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains) | domain definitions and domain-side support files | Medium-high | Clear overall, though domain files and domain-specific helpers are mixed together. |
| [scripts](/Users/stevenwoods/mmath-renovation/scripts) | run, compare, trace, release, and sync entry points | High | This is a clear command surface. |
| [analysis](/Users/stevenwoods/mmath-renovation/analysis) | generated outputs, trace captures, replay logs, numeric datasets | Medium-high | Clear in intent, but raw traces and curated result datasets share the same top-level area. |
| [intake](/Users/stevenwoods/mmath-renovation/intake) | staging area for newly found relevant material pending review | High | Clear and useful as the single first stop for future imports. |
| [experiments](/Users/stevenwoods/mmath-renovation/experiments) | non-baseline experimental code used to generate side comparisons | High | Small and clearly scoped today. |
| [docs](/Users/stevenwoods/mmath-renovation/docs) | formal interpretation, status, plans, crosswalks, validation notes | High | This is the strongest-organized area of the repo. |
| [publications](/Users/stevenwoods/mmath-renovation/publications) | checked-in papers and primary reference artifacts | High | Clear and well-named. |
| [historical](/Users/stevenwoods/mmath-renovation/historical) | frozen source provenance, adjacent systems, raw archival context | Medium-high | Good overall, though duplicate/noise imports deserve continued labeling. |
| [releases](/Users/stevenwoods/mmath-renovation/releases) | numbered release snapshots | High | Clear and already useful. |
| [site](/Users/stevenwoods/mmath-renovation/site) | public page and dashboard source assets | High | Clear public-output source location. |

## What Is Already Clear

The current structure already does a good job separating the major concerns:

- `working/` means active restored code
- `historical/` means archival reference material
- `scripts/` means executable entry points
- `analysis/` means generated outputs and result artifacts
- `intake/` means newly found relevant material waiting to be reviewed and assigned
- `docs/` means interpretation, planning, and validation
- `site/` means public-facing assets

That is a good first-order shape and should be preserved.

## What Is Slightly Unclear

### 1. `Domains/` mixes domain definitions with domain-side support files

Examples:

- [working/abtweak-1993/Domains/blocks.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/blocks.lisp#L1)
- [working/abtweak-1993/Domains/robot-heuristic.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/robot-heuristic.lisp#L1)
- [working/abtweak-1993/Domains/check-primary-effects.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/check-primary-effects.lisp#L1)

This is historically understandable, but conceptually it means:

- some files are domain definitions
- some are domain-specific helpers
- some are alternate framework material

Current recommendation:

- keep the current historical file locations unchanged
- maintain the distinction in documentation rather than renaming files
- treat [docs/domain-inventory.md](/Users/stevenwoods/mmath-renovation/docs/domain-inventory.md#L1) as the authoritative semantic map

### 2. `analysis/` contains both raw run artifacts and curated numeric assets

Examples:

- raw traces in [analysis/hanoi4-traces](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)
- replay outputs in [analysis/hanoi4-frontier-replays](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/README.md)
- score-sensitivity runs in [analysis/hanoi4-score-sensitivity](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-score-sensitivity/README.md)
- curated dataset in [analysis/hanoi4-strategy-performance.csv](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-strategy-performance.csv#L1)

This is workable, but the naming does not yet distinguish:

- raw captured outputs
- summarized tabular datasets
- graph inputs

Current recommendation:

- keep `analysis/` as the umbrella area
- treat subdirectories ending in `-traces`, `-replays`, and similar as raw run
  captures
- treat standalone `.csv` files as curated numeric datasets
- continue to keep interpreted graph/report prose in `docs/` unless it is
  generated directly from a run

### 3. Graphs are represented in multiple ways

Right now the repo has:

- markdown bar-graph views in
  [docs/hanoi4-strategy-crosswalk.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md#L1)
- numeric backing data in
  [analysis/hanoi4-strategy-performance.csv](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-strategy-performance.csv#L1)
- public-facing infographic output in
  [site/mmath-renovation-release-dashboard.html](/Users/stevenwoods/mmath-renovation/site/mmath-renovation-release-dashboard.html#L1)

That is acceptable, but it means “graph outputs” are not yet one directory type.

Current recommendation:

- keep public infographic assets in `site/`
- keep numeric backing files in `analysis/`
- keep explanatory graphs embedded in docs when they are part of interpretation

### 4. Some archival noise is present

Examples:

- [historical/__MACOSX](/Users/stevenwoods/mmath-renovation/historical/__MACOSX)
- [historical/PlanMerge2](/Users/stevenwoods/mmath-renovation/historical/PlanMerge2)
- top-level `.DS_Store`

Current recommendation:

- preserve archival imports if they may matter for provenance
- continue to label them explicitly as non-primary
- avoid treating them as active restoration material

More specifically:

- [historical/PlanMerge2](/Users/stevenwoods/mmath-renovation/historical/PlanMerge2)
  and [historical/__MACOSX](/Users/stevenwoods/mmath-renovation/historical/__MACOSX)
  should now be read as redundant or packaging-only archival material
- [historical/PlanMerge](/Users/stevenwoods/mmath-renovation/historical/PlanMerge),
  [historical/Mini-Tweak](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak),
  [historical/A-star](/Users/stevenwoods/mmath-renovation/historical/A-star),
  [historical/KautzPR](/Users/stevenwoods/mmath-renovation/historical/KautzPR),
  and [historical/Mvl](/Users/stevenwoods/mmath-renovation/historical/Mvl)
  remain separate but potentially useful historical systems

## Recommended Semantic Map

This is the intended mental model of the repo.

| Category | Preferred location | Examples |
| --- | --- | --- |
| Primary restored system artifacts | [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993) | planner code, domain files, compatibility layer |
| Domain definitions | [working/abtweak-1993/Domains](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains) | blocks, Hanoi, robot, manual sample domains |
| Example runners and generators | [scripts](/Users/stevenwoods/mmath-renovation/scripts), [experiments](/Users/stevenwoods/mmath-renovation/experiments) | smoke runs, historical comparisons, baselines |
| New material pending review | [intake](/Users/stevenwoods/mmath-renovation/intake) | newly found source trees, publications, notes, or data dumps waiting to be categorized |
| Raw output results | [analysis](/Users/stevenwoods/mmath-renovation/analysis) | trace directories, replay outputs, generated markdown summaries |
| Output graphs and graph inputs | [analysis](/Users/stevenwoods/mmath-renovation/analysis) for data, [docs](/Users/stevenwoods/mmath-renovation/docs) for interpretive graph displays, [site](/Users/stevenwoods/mmath-renovation/site) for public infographics | CSVs, markdown bar graphs, release dashboard |
| Formal interpretation and validation | [docs](/Users/stevenwoods/mmath-renovation/docs) | status, plans, crosswalks, structure reviews |
| Non-tested or non-integrated systems | [historical](/Users/stevenwoods/mmath-renovation/historical) | Mini-Tweak, PlanMerge, A-star, alternate framework inputs |
| Publication/reference basis | [publications](/Users/stevenwoods/mmath-renovation/publications) | papers, thesis, archival package page |

Within `historical/`, the practical distinction should be:

- potentially useful separate systems: `Mini-Tweak`, `PlanMerge`, `A-star`,
  `KautzPR`, `Mvl`, and the `Abtweak/*` snapshots
- redundant or packaging-only material: `PlanMerge2`, `__MACOSX`, Finder
  metadata artifacts

## Current Structure Assessment

Overall assessment:

- primary system artifacts: clear
- domain definitions: mostly clear
- example generators/runners: clear
- output results: clear enough, though mixed between raw and curated artifacts
- output graphs: understandable, but not centralized in one artifact type
- non-integrated systems and datasets: clear enough if the reader notices
  `historical/`, but worth continuing to label explicitly in docs

So the structure is already good enough to work with confidently, but the repo
benefits from documentation that explains the semantic boundaries.

That is why this note and
[Repository coverage matrix](/Users/stevenwoods/mmath-renovation/docs/repository-coverage-matrix.md)
should now be treated as first-class orientation artifacts.

## Naming Guidance Going Forward

To keep the repo readable, new additions should follow these conventions:

1. primary-system code stays under `working/abtweak-1993`
2. historical imports stay under `historical/` and should not be silently mixed
   into `working/`
3. newly found material should land in `intake/` first, not directly in
   `working/`, `historical/`, `publications/`, or `analysis/`
4. generated raw runs should go under `analysis/<family>-traces`,
   `analysis/<family>-replays`, or similarly explicit output directories
5. curated numeric result tables should go under `analysis/` with descriptive
   filenames
6. interpretive summaries should go in `docs/`
7. public-facing HTML assets should go in `site/`

## Update Rule

Update this note whenever:

1. a new major top-level area is added
2. a previously separate family becomes integrated
3. a new class of generated artifact appears
4. the structure becomes clear enough that one of the current “slightly
   unclear” areas can be promoted to “clear”
