# AbTweak Snapshot Inventory

This document summarizes the historical AbTweak snapshots imported from the uploaded archive and gives us a working baseline for porting and verification.

## Provenance

- Imported from: `/Users/stevenwoods/Downloads/Abtweak.zip`
- Imported on: 2026-03-14
- Extracted to: `/Users/stevenwoods/mmath-renovation/historical/Abtweak`

The archive contains six top-level snapshots:

- `Abtweak-1990-12`
- `Abtweak-1990-12b`
- `Abtweak-1991-05`
- `Abtweak-1991-08`
- `Abtweak-1992`
- `Abtweak-1993`

## At A Glance

| Snapshot | Approx. era | Shape | Files | What stands out | Porting value |
| --- | --- | --- | ---: | --- | --- |
| `Abtweak-1990-12` | December 1990 | Single `Plan/` tree | 126 | Earliest packaged planner, `Planner.README`, original user manual, Allegro startup notes | Best early reference for original packaging and startup expectations |
| `Abtweak-1990-12b` | Late 1990 to early 1991 workspace | Split `Planner` / `Tweak2` / `AbTweak2` | 697 | Large experimental workspace with batch scripts, result logs, and saved domains | Good for reconstructing old experiments and batch runs |
| `Abtweak-1991-05` | Spring 1991 | Refactored routine-based tree | 59 | Cleanest small source tree, routine modules, compact domain set, manual | Best minimal source baseline for understanding the refactored system |
| `Abtweak-1991-08` | August 1991 snapshot of older layout | Split `Planner` / `Tweak2` / `AbTweak2` | 594 | Heavy experimental output, especially `Planner/Batcher/hanoi3/Save/Results` | Strong historical evidence for evaluations but noisy as a port target |
| `Abtweak-1992` | October 1992 | Routine-based `.lisp` tree | 102 | Similar to `1991-05`, renamed to `.lisp`, includes many `.sbin` compiled files and a DVI manual | Useful intermediate port target and evidence of later ACL/KCL use |
| `Abtweak-1993` | November 1995 snapshot of 1993-era tree | Expanded routine-based `.lisp` tree | 144 | Richest source snapshot, `Doc/`, many more domains, `Mcallester-plan`, `.fasl` artifacts, conversion scripts | Best primary candidate for a first serious port |

## Differences Over Time

| Snapshot | Structure | Documentation | Domains/examples | Compiled/runtime artifacts | Notable differences from earlier snapshots |
| --- | --- | --- | --- | --- | --- |
| `Abtweak-1990-12` | `Plan/Planner`, `Plan/Tweak2`, `Plan/AbTweak2` under one top-level tree | `Planner.README`, `users-manual.tex` | Blocks, Hanoi, robot, Nils blocks, saved run inputs | `.fasl`, `.clinit.cl` | Earliest packaged delivery; README explicitly says to start Allegro Common Lisp and run `(compile-all)` |
| `Abtweak-1990-12b` | `Planner`, `Tweak2`, `AbTweak2` split into sibling trees | No top-level manual beyond inherited assets | Same core domains plus many batch experiment trees | Many `.sh`, `.out`, `.fasl`, saved result files | Looks like an expanded research workspace rather than a clean release |
| `Abtweak-1991-05` | Refactored into `Ab-routines`, `Tw-routines`, `Plan-routines`, `Search-routines`, `Domains` | `users-manual.tex` | Blocks, Hanoi, macro-Hanoi, loop, registers, simple robot | Source-heavy `.lsp`, almost no compiled residue | Major reorganization into cleaner modules; manual says it runs on Kyoto or Allegro Common Lisp |
| `Abtweak-1991-08` | Older split layout persists | No new manual at top level | Same older domains plus robot examples and very large Hanoi result sets | Very large raw output corpus from batch runs | Keeps the pre-refactor structure but adds a lot more experimental output than `1990-12b` |
| `Abtweak-1992` | Same modular layout as `1991-05` | `users-manual.tex`, plus `.dvi`, `.aux`, `.log` | Essentially same compact domain set as `1991-05` | `.sbin` across modules | Mostly a renamed and recompiled branch: `.lsp` becomes `.lisp`, compiled outputs are preserved |
| `Abtweak-1993` | Modular layout plus `Mcallester-plan` and `Doc` | `Doc/users-manual.tex` and `Doc/users-manual.ps` | Adds biology, computer, database, driving, fly, scheduling, stylistics, multiple robot variants | `.fasl`, `compiled-load.lisp`, `lisptolsp`, `lsptolisp` | Biggest feature growth: broader domains, McAllester planner branch, and explicit support for moving between `.lisp/.sbin` and `.lsp/.fasl` conventions |

## What We Have To Start With

### 1. Early packaged planner lineage

- `Abtweak-1990-12` captures the closest thing to an original packaged planner release.
- `Planner.README` contains concrete startup instructions for Allegro Common Lisp.
- The accompanying manual explicitly says the planner was implemented in Allegro Common Lisp.

### 2. Experiment-heavy legacy workspace

- `Abtweak-1990-12b` and `Abtweak-1991-08` preserve a lot of saved runs, shell scripts, and batch outputs.
- These snapshots are valuable for reproducing or checking historical evaluation claims, especially the Hanoi experiments.
- They are not the cleanest place to begin a port because a large fraction of the tree is output rather than source.

### 3. Cleaner modular source baselines

- `Abtweak-1991-05` is the cleanest small source tree.
- `Abtweak-1992` is very similar but uses `.lisp` filenames and preserves `.sbin` compiled output.
- `Abtweak-1993` is the richest modular source tree and appears to be the best overall starting point for a modern port.

## Snapshot Notes

### `Abtweak-1990-12`

- Contains a `Planner.README` with restoration and Allegro startup instructions.
- Includes `users-manual.tex` and the classic early planner layout.
- Good source of original assumptions about directory structure and build flow.

### `Abtweak-1990-12b`

- Same family as the early tree, but clearly a working research directory rather than a minimal release.
- Includes large `Planner/Batcher` and `Planner/Save` material.
- Useful for historical experiment reconstruction.

### `Abtweak-1991-05`

- First clearly modularized snapshot.
- Small enough to reason about quickly.
- Good candidate for reading and structural cleanup before any runtime work.

### `Abtweak-1991-08`

- Preserves the older split architecture but includes much more output data.
- Largest files in the archive are raw experiment outputs in this tree.
- Best treated as historical evaluation evidence rather than the initial port target.

### `Abtweak-1992`

- Very close to `1991-05` in organization.
- Adds compiled `.sbin` outputs and generated TeX outputs.
- Good bridge between the earlier `.lsp` tree and the later `1993` branch.

### `Abtweak-1993`

- Adds `Mcallester-plan`, more domains, and a `Doc/` directory.
- Includes helper scripts for managing `.lsp/.lisp` and `.fasl/.sbin` variants.
- Best candidate for a first runnable reconstruction, with `1991-05` as a cleaner cross-check.

## Recommended Porting Baseline

For the first porting pass, use the snapshots this way:

1. primary code baseline: `Abtweak-1993`
2. clean structural cross-check: `Abtweak-1991-05`
3. historical startup/build reference: `Abtweak-1990-12`
4. historical experiment/result archive: `Abtweak-1990-12b` and `Abtweak-1991-08`

That gives us the best combination of source richness, minimality, and historical provenance.

## Likely Porting Challenges

- Allegro/Kyoto-specific behavior and loader assumptions
- old compiled artifacts (`.fasl`, `.sbin`) that should not be treated as source of truth
- filename convention drift between `.lsp` and `.lisp`
- batch scripts and saved experiment files mixed into the same trees as code
- possible reliance on implementation-specific reader, compiler, or path behavior

## Current Verification Status

No snapshot has been executed yet in this repository. We have unpacked and reviewed the trees, but we have not yet verified runtime behavior under any current Common Lisp implementation.
