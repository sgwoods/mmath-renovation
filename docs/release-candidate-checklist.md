# 1.0 Release Candidate Checklist

This note defines what should be true before cutting `1.0.0-rc.1`.

It is intentionally narrower than the eventual `1.0.0` story. The goal here
is to decide when the historical restoration baseline is stable enough to be
treated as release-candidate quality.

It complements:

- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

## Scope Rule

`1.0` is the historically grounded restored AbTweak baseline.

That means `1.0-rc` covers:

- the restored SBCL operator-style baseline
- the historical compatibility surface
- the curated experiment harness
- the publication/manual/archive validation story
- the release/public status surfaces

It does **not** require:

- the hosted remote experiment UI to be feature-complete
- post-`1.0` research extensions
- the alternate `reset-domain` / `defstep` framework to be folded in

The hosted remote UI is now treated as a `1.1` supporting line, not a blocker
for `1.0-rc`.

## Release Candidate Gate

Before cutting `1.0.0-rc.1`, all of the following should be true.

### 1. Core Baseline Stability

- [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993)
  loads and runs reliably under SBCL
- no known correctness bug threatens the core historical-restoration story
- the unified harness remains the standard front door:
  [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)

### 2. Historical Validation Is Strong Enough

- `hanoi-2` is treated as exact
- `hanoi-3` is treated as publication-aligned
- the broader operator-style domain surface remains documented and reproducible
- the validation matrix and publication crosswalk are current

### 3. Hanoi-4 Is Formally Disposed

For `1.0-rc`, `hanoi-4` does **not** need to solve if the repo states clearly
that:

- the published core Hanoi figure story is already reproduced on `hanoi-3`
- `hanoi-4` is a historically grounded extension benchmark
- the current best judgment is evidence-backed and explicit

So the acceptable `hanoi-4` outcomes for `1.0-rc` are:

1. a historically defensible successful run, or
2. an evidence-backed "explained but open" conclusion

The current planning assumption is that option `2` is acceptable.

### 4. Release And Build Flow Is Stable

- [scripts/create-release-snapshot.sh](/Users/stevenwoods/mmath-renovation/scripts/create-release-snapshot.sh)
  works as the normal release refresh path
- [scripts/sync-public-release-pages.sh](/Users/stevenwoods/mmath-renovation/scripts/sync-public-release-pages.sh)
  updates only the intended MMath public surfaces
- the release snapshot, project page, release dashboard, and public status
  manifest remain aligned

### 5. Release-Facing Documentation Is Ready

At minimum, these should be coherent and current:

- [docs/project-goal-roadmap.md](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [docs/current-status.md](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [docs/project-compendium.md](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [docs/hanoi4-formal-state.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [docs/release-process.md](/Users/stevenwoods/mmath-renovation/docs/release-process.md)
- [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

### 6. Scope Boundaries Stay Explicit

- post-`1.0` research remains separated in
  [docs/post-v1-research-track.md](/Users/stevenwoods/mmath-renovation/docs/post-v1-research-track.md)
- later generic strategy work remains governed by
  [docs/algorithm-strategy-policy.md](/Users/stevenwoods/mmath-renovation/docs/algorithm-strategy-policy.md)
- the alternate framework remains outside the `1.0` claim unless that scope is
  deliberately changed

## Recommended RC Procedure

When the checklist is satisfied:

1. refresh the key docs
2. run the normal release snapshot build
3. run the final curated validation sweep
4. bump to `1.0.0-rc.1`
5. tag and publish the checkpoint

## Current Lean

The repo is now close enough that `1.0-rc` is realistic.

The remaining non-trivial decision is not whether the restoration broadly
works. It is whether we are comfortable declaring the current `hanoi-4`
position as:

- historically grounded
- tightly diagnosed
- and acceptable as an "explained but open" extension benchmark at `1.0-rc`
