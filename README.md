# Masters of Mathematics Thesis Renovation: AbTweak

This repository is the starting point for reviving the code and research artifacts associated with Steven Woods' Masters of Mathematics thesis work on AbTweak, a hierarchical nonlinear planner developed at the University of Waterloo.

The goal is not only to recover old source code, but also to rebuild enough surrounding context that the implementation can be understood, evaluated, and extended with confidence.

## Project Scope

This renovation effort is centered on four closely related historical artifacts:

- the original AAAI 1990 conference paper introducing ABTWEAK
- the 1991 University of Waterloo technical report expanding the formal treatment and experiments
- the CMU AI Repository package page for the historical code distribution
- the 1991 Masters thesis summarizing the implementation and evaluation work

## Current Status

This repository is now past the initial documentation bootstrap. The current focus is:

1. recover the historical problem statements, terminology, and algorithmic claims
2. identify the structure and provenance of the old implementation
3. reconstruct a runnable baseline with tests or example planning problems
4. document any semantic differences between the recovered code, the thesis, and the published papers
5. create a clean platform for future modernization work

Current milestone:

- the SBCL working copy now solves `blocks` / `sussman` in both `tweak` and `abtweak`, solves `registers` in `tweak`, solves `hanoi-3` and `macro-hanoi` in both `tweak` and `abtweak`, shows a meaningful left-wedge effect on `simple-robot-2` in `abtweak`, runs `hanoi-4` to a bounded search outcome in both modes under the restored BFS path, and can execute the historical DFS path again under SBCL

## What AbTweak Is

AbTweak combines abstraction with nonlinear, least-commitment planning. In the cited work, abstraction is used to simplify planning problems by suppressing lower-criticality preconditions at higher levels of the hierarchy, while TWEAK-style nonlinear planning preserves partial ordering and deferred commitment in the evolving plan structure.

The papers and thesis emphasize several themes that should guide this renovation:

- preserving the relationship between abstraction levels and concrete plans
- understanding the monotonic property described in the formal work
- evaluating whether abstraction actually reduces search in practice
- separating historically accurate reconstruction from later modernization

## Documentation Map

- [Reference documents](./docs/references.md): annotated list of the core papers, thesis, and archived code page
- [Snapshot inventory](./docs/snapshot-inventory.md): comparison of the recovered AbTweak trees and recommended porting baseline
- [Abtweak-1993 baseline](./docs/abtweak-1993-baseline.md): current working baseline, SBCL load status, and next porting steps
- [Current status](./docs/current-status.md): concise live project snapshot and currently verified benchmark results
- [Restoration roadmap](./docs/restoration-roadmap.md): staged plan for turning the working copy into a historically grounded restored system
- [Historical validation matrix](./docs/historical-validation-matrix.md): mapping from historically reported benchmark themes to runnable local domains
- [Tweak vs AbTweak comparison](./docs/tweak-vs-abtweak-comparison.md): first structured side-by-side comparison across the current passing SBCL benchmarks
- [Hanoi-4 diagnosis](./docs/hanoi4-diagnosis.md): current evidence on whether the larger Hanoi benchmark is blocked by bounds, control settings, or a deeper porting issue
- [Algorithm correspondence review](./docs/algorithm-correspondence.md): comparison of the archival 1993 algorithms and the SBCL working tree, including what changed and what did not
- [Next steps](./docs/next-steps.md): living short-list of recommended technical and historical follow-up work

As the project grows, this repository should add:

- a source provenance note for recovered code and scans
- a build-and-run guide for any reconstructed implementation
- a benchmark or examples directory with representative planning problems
- notes comparing the historical system with any modernized variant

## Research References

The renovation is grounded in the following source documents:

1. Qiang Yang and Josh D. Tenenberg, "ABTWEAK: Abstracting a Nonlinear, Least Commitment Planner," AAAI-90.
2. Qiang Yang, Josh D. Tenenberg, and Steve Woods, "Abstraction in Nonlinear Planning," University of Waterloo Technical Report CS-91-65, December 1991.
3. Steven G. Woods, "An Implementation and Evaluation of a Hierarchical Nonlinear Planner," University of Waterloo Technical Report CS-91-17, March 1991.
4. CMU AI Repository entry for the historical `abtweak` package.

Direct links and brief notes for each item are collected in [docs/references.md](./docs/references.md).

## Immediate Next Steps

1. locate or import any surviving source snapshots associated with the CMU AI Repository package
2. identify the original implementation language, build assumptions, and example domains
3. compare the recovered historical snapshots and choose an initial runnable baseline
4. capture a small set of canonical planning scenarios from the papers and thesis
5. decide how much of the initial work should aim at faithful reconstruction versus a modern reference implementation

## Historical Code

Recovered snapshots from the uploaded archive are currently unpacked under [`historical/`](./historical/README.md). The current recommendation is to treat `Abtweak-1993` as the primary porting target, with `Abtweak-1991-05` as the cleanest structural cross-check and the earlier trees as provenance and experiment archives.

The active working copy for that port is [`working/abtweak-1993`](./working/abtweak-1993/README.md).

## Notes

This repository currently treats the historical documents as the primary source of truth. Where the papers, thesis, and archived code disagree, those differences should be documented explicitly rather than silently normalized away.
