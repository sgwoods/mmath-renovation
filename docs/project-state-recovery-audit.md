# Project State And Recovery Audit

This note is the precise audit of the repository state on `2026-05-03`.

It is intended to answer, in one place:

1. what the project is trying to achieve
2. what its current checkpoint and status actually are
3. what is safely checked in and recoverable from git
4. what is still local-only, ignored, or externally hosted
5. whether a fresh machine can recreate the full working state without redoing work

It complements:

- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [Repository coverage matrix](/Users/stevenwoods/mmath-renovation/docs/repository-coverage-matrix.md)
- [Repository structure review](/Users/stevenwoods/mmath-renovation/docs/repository-structure-review.md)
- [Cold-start reconstruction](/Users/stevenwoods/mmath-renovation/docs/cold-start-reconstruction.md)
- [Continuity and archival policy](/Users/stevenwoods/mmath-renovation/docs/continuity-and-archival-policy.md)

## Precise Goal

The precise goal of the project is:

build one maintained restored experimental environment that stands in for the
historical AbTweak code lines closely enough to reproduce the documented
capabilities, controls, benchmark behavior, and published experimental claims.

In practical terms, that means:

- one primary SBCL working baseline for the restored planner
- one unified experiment harness
- one historical validation story against papers, thesis, manual examples, and
  archived outputs
- one clear distinction between the historical restoration baseline and later
  extension or research work
- one durable enough artifact trail that the project can be resumed on a new
  machine without reconstructing its state from memory

## Current Named State

Current named checkpoint:

- `1.0.0-rc.1`

Current interpretation:

- the historical restoration baseline is at its first release-candidate state
- the lower Hanoi families are historically aligned
- the thesis-gallery milestone is complete and maintained
- the public-facing status/dashboard/project surfaces are real and build-backed
- the hosted remote experiment UI is real, but considered part of the later
  `1.1` supporting line rather than the historical `1.0` baseline
- `hanoi-4` is explicitly accepted for RC as an explained-but-open extension
  benchmark

Best existing status references:

- [Project goal and roadmap](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
- [Current status](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [1.0 release candidate sweep](/Users/stevenwoods/mmath-renovation/docs/release-candidate-sweep.md)
- [Post-RC go-forward plan](/Users/stevenwoods/mmath-renovation/docs/post-rc-go-forward-plan.md)

## Worktree Snapshot At Audit Start

Audit-time local git state:

- branch: `main`
- tracking: `origin/main`
- tracked local modifications:
  - [docs/hanoi4-strategy-crosswalk.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)
- ignored local artifacts:
  - many `.DS_Store` files
  - one ignored scaling log:
    [analysis/hanoi4-scaling-ql.log](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-ql.log)
  - `42` ignored raw `hanoi-4` trace directories under
    [analysis/hanoi4-traces](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)

This matters because the repository's checked-in state and the local working
state were not identical at the beginning of the audit.

## Recommended Next Steps

Recommended order from the current checkpoint:

1. keep the `1.0.0-rc.1` baseline stable and understandable
2. treat the hosted remote UI and public surfaces as the main `1.1` support
   track
3. reopen `hanoi-4` only through narrow, explicit post-`1.0` follow-on work
4. preserve or distill the remaining local-only evidentiary artifacts so the
   repo becomes cold-start reproducible
5. perform one real fresh-machine reconstruction drill after the remaining
   recovery gaps are closed

## Audit Verdict

The project is strong as a release-candidate restoration baseline, but it is
not yet in a state where this repository alone guarantees full recovery of the
entire work thread on a new machine without any rework.

The honest current verdict is:

- the core restored system is checked in and recoverable
- the formal documentation and release checkpoints are checked in and recoverable
- the publication corpus and thesis assets are checked in and recoverable
- the remote experiment workflow definitions are checked in and recoverable
- but some evidentiary and operational parts of the work are still outside the
  main repo or still only local

So the answer to "are we 100% sure a new machine can recreate everything from
the checked-in project state alone?" is currently:

- `No, not yet`

However, the first real fresh-workspace reconstruction drill has now succeeded
for:

- the main `mmath-renovation` clone
- the `public` clone
- the main harness status path
- the release snapshot path
- the public sync path using an overridden `PUBLIC_PAGES_DIR`

That moves the project much closer to a true cold-start-safe state than it was
at the beginning of this audit.

## What Is Checked In And Recoverable

The following are checked into `sgwoods/mmath-renovation` and recoverable from
git:

| Family | Main locations | Recovery status |
| --- | --- | --- |
| Primary restored planner baseline | [working/abtweak-1993](/Users/stevenwoods/mmath-renovation/working/abtweak-1993) | Recoverable |
| Historical reference trees and adjacent systems | [historical](/Users/stevenwoods/mmath-renovation/historical) | Recoverable |
| Publications and thesis source basis | [publications](/Users/stevenwoods/mmath-renovation/publications/README.md) | Recoverable |
| Main harness and report scripts | [scripts](/Users/stevenwoods/mmath-renovation/scripts) | Recoverable |
| Release checkpoints | [releases](/Users/stevenwoods/mmath-renovation/releases/README.md) | Recoverable |
| Formal docs and project interpretation | [docs](/Users/stevenwoods/mmath-renovation/docs) | Recoverable |
| Thesis side-by-side gallery outputs | [analysis/thesis-side-by-side](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side) | Recoverable |
| Retained baseline comparison outputs | [analysis/hanoi-baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md) | Recoverable |
| Checked-in scaling graphics and datasets | [analysis/hanoi4-scaling-strategies.svg](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.svg), [analysis/hanoi4-scaling-strategies.png](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.png), [analysis/hanoi4-strategy-performance.csv](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-strategy-performance.csv) | Recoverable |
| Checked-in replay and distilled diagnostic reports | [analysis/hanoi4-frontier-replays](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-frontier-replays/README.md), [analysis/hanoi4-score-sensitivity](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-score-sensitivity/README.md) | Recoverable |
| GitHub Actions remote experiment workflows | [.github/workflows/remote-experiment.yml](/Users/stevenwoods/mmath-renovation/.github/workflows/remote-experiment.yml), [.github/workflows/remote-experiment-set.yml](/Users/stevenwoods/mmath-renovation/.github/workflows/remote-experiment-set.yml) | Recoverable |
| Public page and dashboard source templates | [site](/Users/stevenwoods/mmath-renovation/site) | Recoverable |

## What Is Not Fully Captured In This Repo

The following are not fully captured by a fresh clone of this repo alone.

### 1. Local tracked change at audit start

At audit time, the repo has one modified tracked file:

- [docs/hanoi4-strategy-crosswalk.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)

That change has now been preserved as a retained recovery artifact:

- [analysis/recovery-artifacts/hanoi4-strategy-crosswalk-local-2026-05-03.patch](/Users/stevenwoods/mmath-renovation/analysis/recovery-artifacts/hanoi4-strategy-crosswalk-local-2026-05-03.patch)

The main checked-in document was then restored to the baseline version so the
project can move back toward a clean reproducible state without losing that
alternate draft.

### 2. Raw `hanoi-4` trace directories were local-only at audit start

The repo currently contains many timestamped raw trace directories under:

- [analysis/hanoi4-traces](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)

At audit time:

- `42` trace directories exist locally
- they are ignored by git because the top-level `.gitignore` ignores `*.log`
  and each trace directory is excluded by
  [analysis/hanoi4-traces/.gitignore](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/.gitignore)

These raw trace directories were not recoverable from a fresh clone until they
were explicitly promoted into version control.

### 3. Several checked-in docs still point at retained raw trace directories

At audit time, checked-in docs that still reference specific local raw trace
directories include:

- [docs/current-status.md](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
- [docs/hanoi3-vs-hanoi4.md](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md)
- [docs/hanoi4-convergence-check.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-convergence-check.md)
- [docs/hanoi4-frontier-forensics.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [docs/hanoi4-frontier-quality.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [docs/hanoi4-insertion-score-trace.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [docs/hanoi4-lineage-trace.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md)
- [docs/hanoi4-optimal-lineage-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-optimal-lineage-comparison.md)
- [docs/hanoi4-reinsertion-obligations.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-reinsertion-obligations.md)
- [docs/hanoi4b-frontier-comparison.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md)
- [docs/next-steps.md](/Users/stevenwoods/mmath-renovation/docs/next-steps.md)
- [docs/repository-structure-review.md](/Users/stevenwoods/mmath-renovation/docs/repository-structure-review.md)

The right long-term rule is therefore:

- if checked-in docs point at a raw trace directory, that directory must remain
  a retained checked-in artifact

### 4. Hosted UI code lives in a separate repo

The browser-facing remote experiment UI is not contained in this repo.

It lives in the separate repo:

- [sgwoods/abtweak-experiments-ui](https://github.com/sgwoods/abtweak-experiments-ui)

That means full project continuation after machine loss requires cloning both:

- `sgwoods/mmath-renovation`
- `sgwoods/abtweak-experiments-ui`

### 5. Public publication surface lives in a separate repo

The published project pages and status-manifest target are not stored here.

They are synced into:

- [sgwoods/public](https://github.com/sgwoods/public)

The main integration script assumes a local checkout at:

- `/Users/stevenwoods/GitPages/public`

So full public-surface continuity requires that second repo too.

### 6. Hosted-service secrets and environment are not recreated from git alone

The project currently depends on hosted configuration not stored in this repo,
including:

- Vercel project configuration for the remote UI
- the Vercel environment variables and secret token names used by that UI

The key environment-variable names are known and should be preserved:

- `GITHUB_TOKEN`
- `GITHUB_OWNER`
- `GITHUB_REPO`
- `GITHUB_WORKFLOW_SINGLE`
- `GITHUB_WORKFLOW_SET`

But the secret values themselves are not and should not be checked into git.

## External Dependencies That Matter For Recovery

These are the external pieces needed to recover the full working thread rather
than only the core planner repo.

| External dependency | Role |
| --- | --- |
| [sgwoods/public](https://github.com/sgwoods/public) | Public Pages publishing target and status-manifest contract |
| [sgwoods/abtweak-experiments-ui](https://github.com/sgwoods/abtweak-experiments-ui) | Hosted remote experiment UI codebase |
| Vercel project for `abtweak-experiments-ui` | Hosted remote UI deployment and server-side proxy environment |
| GitHub Actions in `sgwoods/mmath-renovation` | Remote experiment execution backend |

## Practical Recovery Judgment

### What We Can Recover Today Without Rework

If the local tree disappeared today, we could recover without major historical
reconstruction work:

- the primary restored planner code
- the historical references and publications
- the release checkpoints
- the thesis gallery
- the harness and reporting scripts
- the main documentation and RC rationale
- the GitHub Actions remote-runner workflows
- the retained raw `hanoi-4` trace corpus
- the preserved recovery patch artifacts

### What We Would Still Need To Recreate Or Repair

If the local tree disappeared today, we would still need to do at least some
recovery work for:

- the uncommitted local changes in
  [docs/hanoi4-strategy-crosswalk.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)
- the ignored raw `hanoi-4` trace directories
- the local clone and environment of [sgwoods/public](https://github.com/sgwoods/public)
- the local clone and deployment context of
  [sgwoods/abtweak-experiments-ui](https://github.com/sgwoods/abtweak-experiments-ui)
- the Vercel secret configuration

## What Must Be Done To Reach A True "100% Recoverable" State

The minimum remaining steps are:

1. preserve the raw `hanoi-4` trace evidence in one of two ways:
   - check in the retained trace directories that the docs actually depend on
   - or replace raw trace-directory links with checked-in distilled artifacts
2. document the external continuation set explicitly:
   - `sgwoods/mmath-renovation`
   - `sgwoods/public`
   - `sgwoods/abtweak-experiments-ui`
   - required Vercel environment-variable names
3. perform one real cold-start drill on a fresh machine or fresh workspace and
   record the result

Until those steps are done, the project is strong and well documented, but not
yet fully self-contained.

## Recommended Immediate Follow-Up

Recommended order from this audit:

1. promote this audit, the reconstruction checklist, and the continuity policy
   into the normal documentation map
2. preserve or distill the trace artifacts that current docs still depend on
3. align the active working directories for `mmath-renovation`, `public`, and
   `abtweak-experiments-ui` under the iCloud-backed workspace root defined in
   [Continuity and archival policy](/Users/stevenwoods/mmath-renovation/docs/continuity-and-archival-policy.md)
4. run one real reconstruction drill and update this note with the result
