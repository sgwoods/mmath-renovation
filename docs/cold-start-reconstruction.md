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

The project is not yet fully cold-start reproducible from this repo alone.

The main remaining reasons are:

- the remote UI is in a separate repo
- the public publishing target is in a separate repo
- Vercel secrets are operationally required but not stored in git
- a fresh-machine reconstruction drill has not yet been recorded

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

The current scripts in the main repo default to a public checkout at:

```text
/Users/stevenwoods/GitPages/public
```

So on a new machine, either:

- recreate that path, or
- override `PUBLIC_PAGES_DIR` when syncing public pages

## Main Repo Recovery

On a new machine:

1. clone `sgwoods/mmath-renovation`
2. check out the intended checkpoint or branch
3. install the planner/runtime prerequisites used by the repo
4. verify the release surface:
   - [VERSION](/Users/stevenwoods/mmath-renovation/VERSION)
   - [CHANGELOG.md](/Users/stevenwoods/mmath-renovation/CHANGELOG.md)
   - [releases](/Users/stevenwoods/mmath-renovation/releases/README.md)
5. verify the harness:
   - [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh)
6. verify the current status docs:
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

## Recommended Next Steps

1. resolve the current uncommitted local file in the main repo
2. preserve or distill the raw `hanoi-4` traces that current docs still cite
3. rerun this checklist on a clean workspace
4. record the first successful cold-start drill in this note
