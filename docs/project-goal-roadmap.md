# Project Goal And Roadmap

This note is the clearest current statement of:

1. the overall goal of the project
2. the current roadmap toward that goal
3. where the repo stands against that roadmap
4. the recommended next steps

It complements:

- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [1.0 release candidate checklist](/Users/stevenwoods/mmath-renovation/docs/release-candidate-checklist.md)
- [1.0 release candidate sweep](/Users/stevenwoods/mmath-renovation/docs/release-candidate-sweep.md)
- [Refreshed plan](/Users/stevenwoods/mmath-renovation/docs/refreshed-plan.md)
- [Unified restoration plan](/Users/stevenwoods/mmath-renovation/docs/unified-restoration-plan.md)
- [Experiment harness](/Users/stevenwoods/mmath-renovation/docs/experiment-harness.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Publication domain crosswalk](/Users/stevenwoods/mmath-renovation/docs/publication-domain-crosswalk.md)
- [Post-1.0 research track](/Users/stevenwoods/mmath-renovation/docs/post-v1-research-track.md)

## Overall Goal

The project goal is:

build one maintained restored experimental environment that stands in for the
historical AbTweak code lines closely enough to reproduce the documented
capabilities, controls, benchmark behavior, and published experimental claims.

That means the project should finish with:

- one primary working implementation base
- one explicit historical compatibility surface for important older controls
- one experiment harness for smoke runs, historical-control runs, reports, and traces
- one formal validation story against the papers, thesis, and shipped examples
- one explicit intake lane for newly found relevant material before it is
  merged into the main repo structure
- one explicit boundary between the restored historical baseline and any later
  non-domain-specific strategy extensions

It should not finish as:

- a runnable 1993 port plus scattered one-off probes
- a pile of partially documented archive trees
- or a mix of historical behavior and modern experimental changes that are not
  clearly distinguished

## Current Roadmap

The roadmap is now best understood as six tracks.

### Track 1: Core Restored Planner

Target:

- a stable SBCL working copy of the main operator-style `tweak` and `abtweak`
  planner path

Current state:

- substantially achieved

Main remaining gap:

- no full shipped `hanoi-4` solve yet

### Track 2: Historical Compatibility Surface

Target:

- a thin compatibility layer for historically important older controls without
  forking the planner into a second implementation

Current state:

- strong for the Hanoi family
- still limited outside the historically important recovered experiment lines

Main remaining gap:

- broaden only where the publications or archived experiment families make it worthwhile

### Track 3: Unified Experiment Harness

Target:

- one front door for named runs, reports, status views, and traces

Current state:

- in good shape and already useful through
  [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)

Main remaining gap:

- continue converging older ad hoc comparison flows into the same naming and reporting model

### Track 4: Historical Validation

Target:

- a benchmark and claim matrix that can say which publication/manual/archive
  results are exactly reproduced, strongly reproduced, partially reproduced,
  explained, or still open

Current state:

- strong and getting stronger

Main remaining gap:

- keep the matrix current as new benchmark evidence is added, especially on the
  harder extension cases

### Track 5: Extended Historical Infrastructure

Target:

- decide how much of the adjacent or alternate historical systems should be
  restored within this project

Current state:

- archival cataloging is strong
- the alternate `reset-domain` / `defstep` framework is still intentionally a
  separate phase

Main remaining gap:

- decide when or whether to open that phase relative to the main AbTweak restoration goal

### Track 6: Public And Remote Interaction Surface

Target:

- one maintained public-facing status/dashboard/project surface
- one safe remote experiment surface that exposes curated AbTweak choices
  without exposing raw GitHub workflow details to the user

Current state:

- strong
- the public project page, release dashboard, remote experiments guide, and
  browser-facing remote UI now exist and are tied into the normal build/update
  flow

Main remaining gap:

- improve domain/task/result readability in the remote UI, especially around
  domain grouping, starting-state/goal explanation, and readable result
  previews and history

## Post-1.0 Research Extension

After the historical restoration reaches a true `1.0` checkpoint, the roadmap
should open an explicit later-research phase rather than silently mixing newer
ideas into the baseline.

The first named input for that later phase is now captured in:

- [Post-1.0 research track](/Users/stevenwoods/mmath-renovation/docs/post-v1-research-track.md)

That track exists to revisit open questions such as `hanoi-4` using later
literature on hierarchy design, problem encoding, and structural constraints,
while keeping the restored historical baseline clearly delineated.

## Where We Are Against The Goal

The project is now in its first release-candidate restoration state.

### Already Strong

- the main [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)
  line runs under SBCL
- both `tweak` and `abtweak` solve a meaningful set of historically important
  operator-style examples
- the publications are checked into
  [publications/](/Users/stevenwoods/mmath-renovation/publications/README.md)
- the repo has a unified experiment front door through
  [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
- `hanoi-2` is now an exact archived-family rerun
- `hanoi-3` now reproduces the published thesis figure rows directly on the
  original three-disk family
- the project has a clear historical-baseline policy in
  [docs/algorithm-strategy-policy.md](/Users/stevenwoods/mmath-renovation/docs/algorithm-strategy-policy.md)
- the repo now has a clear intake lane through
  [intake/README.md](/Users/stevenwoods/mmath-renovation/intake/README.md),
  so new finds can be reviewed before they are assigned to `working/`,
  `historical/`, `publications/`, or `analysis/`
- the thesis-gallery milestone is effectively complete, and the gallery is now
  a maintained publication-validation asset instead of an active project phase
- the public-facing interaction layer is now real:
  - project page
  - release dashboard
  - remote experiments guide
  - hosted remote experiment UI backed by GitHub Actions
- the current RC-prep sweep is now complete, and `hanoi-4` is accepted as an
  explained-but-open extension benchmark for `1.0.0-rc.1`
- the next work is now organized explicitly through the
  [post-RC go-forward plan](/Users/stevenwoods/mmath-renovation/docs/post-rc-go-forward-plan.md)

### Strong But Still Open

- the wider operator-style benchmark surface is good, but not exhaustive
- the historical compatibility layer is real and useful, but still centered on
  the Hanoi family
- the validation story is strong, but still evolving as new evidence is added

### Main Remaining Gap

- the biggest open benchmark is still `hanoi-4`

That gap is now better defined than it used to be:

- it is not a loader failure
- it is not the earlier fatal precedence/heap bug
- it is not evidence that the restored code broadly fails on published work
- it is a historically grounded extension benchmark where the remaining
  question is which hierarchy-and-control combinations best reflect the
  historical successful behavior

### Separate Future Phase

- the `reset-domain` / `defstep` work remains outside the main restoration milestone
- adjacent systems like `Mini-Tweak`, `PlanMerge`, `A-star`, `KautzPR`, and
  `Mvl` are now cataloged, but not part of the main baseline

## Recommended Next Steps

Recommended order from here:

1. Maintain `1.0.0-rc.1` cleanly.
   The formal gate and the sweep that justified the RC are now recorded in:
   - [1.0 release candidate checklist](/Users/stevenwoods/mmath-renovation/docs/release-candidate-checklist.md)
   - [1.0 release candidate sweep](/Users/stevenwoods/mmath-renovation/docs/release-candidate-sweep.md)
   The immediate task after the cut is to keep the RC baseline stable and
   understandable rather than reopening broad exploratory churn.

2. Keep the formal validation documents current as the repo moves through RC.
   This keeps the repo aligned with the actual restoration evidence rather than
   leaving important conclusions only in shell output or issue comments.

3. Resume from the post-RC go-forward plan.
   The next organized work now lives in:
   - [Post-RC go-forward plan](/Users/stevenwoods/mmath-renovation/docs/post-rc-go-forward-plan.md)
   That is where UI work, research, domain expansion, and visual improvements
   should restart from.

4. Keep the completed thesis-gallery and release surfaces maintained through
   the normal build flow.
   The gallery is now feature-complete for the thesis figure set and should be
   preserved as a validation asset, not expanded further unless a new
   publication-mapping need appears.

5. Keep the remote/public interaction surface maintained as a supporting track, not a replacement for the core benchmark work.
   The browser-triggered remote UI is now a real project asset and should stay
   aligned with the curated harness vocabulary and project status surfaces, but
   it should support the restoration effort rather than become the main effort.

6. Keep `hanoi-4` narrow and binary after RC.
   The main runtime target remains `isbm` weak-`POS` plus Left-Wedge, with
   `legacy-1991-isbm` as the comparison line. Further work should now be
   justified only when it improves the solve case or materially tightens the
   explanation.

7. Widen historically grounded operator-style coverage only where it clearly improves the validation story.
   This is now secondary because the repo already has a strong baseline across
   blocks, Nilsson blocks, registers, robot, multiple sample domains, and the
   lower Hanoi families.

8. Keep the alternate `reset-domain` / `defstep` framework as a separate phase unless priorities change.
   That work is real, but it is a framework-restoration branch rather than a
   direct continuation of the main operator-style AbTweak baseline.

9. Continue trimming non-fatal SBCL noise when it helps clarity, but not at the expense of the main benchmark work.

10. After `1.0`, open the explicit post-restoration research track.
   That is the right place to analyze later material such as Martins and
   Lynce's 2008 Hanoi encoding work and ask what it implies for future named
   extensions, hierarchy redesigns, or problem-encoding experiments.

## Short Version

The project is already succeeding on most of its core restoration goals.

What remains is not “make AbTweak work at all.” It is:

- finish tightening the historical validation story
- resolve or convincingly explain the `hanoi-4` extension benchmark,
  where `isbm + weak-POS + Left-Wedge` remains the main runtime target and
  `legacy-1991-isbm` is now the strongest grouped-top analogue
- keep the restored baseline cleanly separated from any later strategy experiments
