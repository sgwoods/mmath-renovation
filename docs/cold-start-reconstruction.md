# Cold-Start Reconstruction

This note describes how to continue the project from a new machine without
relying on memory or undeclared local setup.

It complements:

- [Project state and recovery audit](/Users/stevenwoods/mmath-renovation/docs/project-state-recovery-audit.md)
- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)
- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [Continuity and archival policy](/Users/stevenwoods/mmath-renovation/docs/continuity-and-archival-policy.md)

## Goal

The goal is to be able to recreate the full working continuation set for the
project, including:

- the main restoration repo
- the public publishing repo
- the hosted remote UI repo
- the release/public build flow
- the current evidence trail that the checked-in docs rely on

## Current Truthful Status

The project is not yet fully cold-start reproducible from this repo alone, but
the first real fresh-workspace reconstruction drill has now succeeded for the
main local continuation set, and there is now a concrete bootstrap script for
the next Mac.

The main remaining reasons are:

- the remote UI is in a separate repo
- the public publishing target is in a separate repo
- Vercel secrets are operationally required but not stored in git
- the hosted UI deployment continuity still depends on the external Vercel
  project and its secrets staying intact

## Required Repositories

A complete continuation setup should clone all of:

1. [sgwoods/mmath-renovation](https://github.com/sgwoods/mmath-renovation)
2. [sgwoods/public](https://github.com/sgwoods/public)
3. [sgwoods/abtweak-experiments-ui](https://github.com/sgwoods/abtweak-experiments-ui)

Suggested local layout:

```text
~/work/mmath-renovation
~/work/public
~/work/abtweak-experiments-ui
```

For this machine specifically, the preferred active workspace is now:

```text
/Users/stevenwoods/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/
```

The current scripts in the main repo now prefer the iCloud-backed public
checkout at:

```text
/Users/stevenwoods/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/public
```

They fall back to the older legacy path:

```text
/Users/stevenwoods/GitPages/public
```

The older non-iCloud local paths should now be treated as legacy fallback
locations rather than normal working roots.

So on a new machine, either:

- recreate that path, or
- override `PUBLIC_PAGES_DIR` when syncing public pages

## Main Repo Recovery

On a new machine:

1. clone `sgwoods/mmath-renovation`
2. check out the intended checkpoint or branch
3. install the planner/runtime prerequisites used by the repo
4. run:

```sh
sh scripts/bootstrap-new-machine.sh
```

That script now stands up the sibling repos, validates the harness, validates
the hosted UI build, runs the release/public drill, and returns the checked-out
repos to a clean state.
5. verify the release surface:
   - [VERSION](/Users/stevenwoods/mmath-renovation/VERSION)
   - [CHANGELOG.md](/Users/stevenwoods/mmath-renovation/CHANGELOG.md)
   - [releases](/Users/stevenwoods/mmath-renovation/releases/README.md)
6. verify the harness:
   - [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
7. verify the current status docs:
   - [docs/current-status.md](/Users/stevenwoods/mmath-renovation/docs/current-status.md)
   - [docs/project-goal-roadmap.md](/Users/stevenwoods/mmath-renovation/docs/project-goal-roadmap.md)
   - [docs/project-compendium.md](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)

## Public Surface Recovery

To restore the public page/dashboard/status flow:

1. clone `sgwoods/public`
2. make it available at the path expected by the main repo scripts, or set
   `PUBLIC_PAGES_DIR`
3. run:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/create-release-snapshot.sh
```

That should refresh:

- the release snapshot in this repo
- the public MMath project page
- the public release dashboard
- the public remote-experiments guide
- the MMath public status manifest

## First Recorded Drill

On `2026-05-03`, a fresh iCloud-backed workspace was created at:

```text
/Users/stevenwoods/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods
```

The following fresh clones were created there:

1. `mmath-renovation`
2. `public`
3. `abtweak-experiments-ui`

Validated successfully from the fresh `mmath-renovation` clone:

- `git status` clean on all three fresh clones immediately after clone
- harness status run succeeded:
  `scripts/abtweak-experiments.sh status --json`
- release snapshot and public sync succeeded from the fresh workspace using:

```sh
PUBLIC_PAGES_DIR="/Users/stevenwoods/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/public" \
sh "/Users/stevenwoods/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/mmath-renovation/scripts/create-release-snapshot.sh"
```

Observed post-build state:

- the fresh `mmath-renovation` clone became dirty only in the expected release
  snapshot files under `releases/1.0.0-rc.1/`
- the fresh `public` clone became dirty only in the expected MMath status
  manifest:
  `data/projects/mmath-renovation.json`

This means the main restoration repo and the main public-sync workflow have now
been successfully resumed from a fresh iCloud-backed workspace.

Additional hosted-UI continuity checks also now pass from the fresh iCloud
workspace:

- the fresh `abtweak-experiments-ui` clone remained clean after clone
- `npm install` succeeded there
- `npm run build` succeeded there
- the live hosted UI URL returned HTTP `200`

## Remote UI Recovery

The hosted UI is a separate project:

- [sgwoods/abtweak-experiments-ui](https://github.com/sgwoods/abtweak-experiments-ui)

To restore that continuation line:

1. clone the UI repo
2. connect it to the correct Vercel project
3. restore the required environment-variable names:
   - `GITHUB_TOKEN`
   - `GITHUB_OWNER`
   - `GITHUB_REPO`
   - `GITHUB_WORKFLOW_SINGLE`
   - `GITHUB_WORKFLOW_SET`
4. verify the GitHub Actions runner still points at
   `sgwoods/mmath-renovation`
5. verify the repo builds locally:

```sh
npm install
npm run build
```
6. verify the live hosted UI still responds at:
   [abtweak-experiments-ui.vercel.app](https://abtweak-experiments-ui.vercel.app)

## Bootstrap Script

The new-machine startup path is now encoded in:

- [scripts/bootstrap-new-machine.sh](/Users/stevenwoods/mmath-renovation/scripts/bootstrap-new-machine.sh)
- [New-machine bootstrap](/Users/stevenwoods/mmath-renovation/docs/new-machine-bootstrap.md)

Use that script as the first operational proof step on the next Mac after the
main repo has been cloned into the canonical iCloud-backed workspace root.

## Evidence Recovery

The main evidence gap is the local-only `hanoi-4` raw trace set.

The retained trace corpus should now travel with the repo. Going forward, if a
checked-in doc points at a raw trace directory, that directory must remain a
checked-in retained artifact rather than a disposable local scratch directory.

## Acceptance Standard

This project should only be considered truly cold-start reproducible when all
of the following are true:

1. the main repo is clean
2. no checked-in doc depends on a local-only ignored artifact
3. the public surface can be rebuilt from:
   - `sgwoods/mmath-renovation`
   - `sgwoods/public`
4. the hosted remote UI can be rebuilt from:
   - `sgwoods/abtweak-experiments-ui`
   - documented Vercel environment-variable names
5. one fresh-machine or fresh-workspace reconstruction drill has been run and
   written down
6. the hosted UI continuity is revalidated from the fresh workspace with the
   required Vercel configuration still in place

## Recommended Next Steps

1. treat the iCloud-backed workspace as the canonical continuation root on this
   machine
2. preserve the hosted UI's Vercel configuration and documented environment
   variable names as part of the continuation set
3. use [scripts/bootstrap-new-machine.sh](/Users/stevenwoods/mmath-renovation/scripts/bootstrap-new-machine.sh)
   as the standard startup/validation path on the next Mac
4. repeat this drill once after any major continuity change
