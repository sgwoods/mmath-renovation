# Post-RC Go-Forward Plan

This note captures the intended follow-on work after the `1.0.0-rc.1`
checkpoint so the project can be resumed cleanly without reconstructing the
post-RC roadmap from issue comments or memory.

It complements:

- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [Post-1.0 research track](/Users/stevenwoods/mmath-renovation/docs/post-v1-research-track.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)

## Purpose

`1.0.0-rc.1` marks the point where the historical-restoration baseline is
stable enough to freeze as a release candidate.

That does not mean the project is finished. It means the next work should be
organized as deliberate follow-on tracks rather than still-mixed release
preparation.

## Priority Order

The recommended order after `1.0.0-rc.1` is:

1. `1.1` supporting surface work
2. post-`1.0` Hanoi research and `hanoi-4` follow-on work
3. domain and validation expansion
4. richer visualization and publication-facing explanation
5. alternate-framework restoration

## Track 1: `1.1` Remote UI And Public Surface

Goal:

- turn the hosted experiment UI into a genuinely comfortable way to browse,
  select, run, and inspect curated AbTweak experiments

Key next steps:

- add recent-run history to the hosted UI
- keep grouping experiment choices by domain and planning purpose
- improve domain visualizations for cases like Hanoi and Blocks
- make result previews easier to read than raw markdown dumps
- add stronger artifact browsing and cross-links from results back to project
  documentation
- keep the project page, release dashboard, remote guide, and hosted UI
  aligned through the same build/update discipline

Boundary:

- this is a supporting `1.1` line, not part of the historical `1.0` baseline

## Track 2: Post-`1.0` Hanoi Research

Goal:

- revisit open `hanoi-4` questions using later literature and named
  non-historical research ideas without blurring the restored baseline

Key next steps:

- analyze later work on Hanoi encoding and structural constraints, beginning
  with the Martins and Lynce paper already captured in
  [post-v1-research-track.md](/Users/stevenwoods/mmath-renovation/docs/post-v1-research-track.md)
- use that research to think through:
  - better hierarchy setups
  - alternative problem encodings
  - more rational recursive abstractions
  - constraint structures that better preserve closure pressure
- keep all such work explicitly named as post-`1.0` research or extension work

Boundary:

- do not retroactively claim these as part of the historical restored baseline

## Track 3: Domain And Validation Expansion

Goal:

- strengthen confidence outside the current main operator-style set

Key next steps:

- widen historically grounded sample coverage only where it adds validation
  value
- keep the coverage matrix and publication crosswalk current
- continue using the intake workflow for newly found material before moving it
  into the main repo structure

## Track 4: Better Visualizations

Goal:

- make the benchmark story easier to understand at a glance for both project
  readers and remote users

Key next steps:

- add more maintained side-by-side publication and regenerated graphics
- improve strategy scaling visuals and domain-state visualizations
- make experiment results easier to compare visually across planner modes,
  domains, and hierarchy/control families

## Track 5: Alternate Framework And Adjacent Systems

Goal:

- decide how far to go beyond the operator-style historical baseline

Key next steps:

- revisit the `reset-domain` / `defstep` line as a separate restoration track
- keep adjacent systems like `Mini-Tweak`, `PlanMerge`, and other preserved
  archival code clearly separated from the main baseline unless explicitly
  promoted into active work

## Resume Rule

When resuming later work, start from this order of questions:

1. is the work historical-baseline maintenance, or post-`1.0` extension work?
2. does it belong in the `1.1` supporting UI/public line, or the planner
   research line?
3. does it improve:
   - reproducibility
   - validation confidence
   - user readability
   - or post-`1.0` research understanding?

That keeps the repo from sliding back into mixed-purpose work after the RC
checkpoint.
