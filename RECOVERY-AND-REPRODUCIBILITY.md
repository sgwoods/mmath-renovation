# Recovery And Reproducibility

This file answers a practical continuity question:

**If this local working directory disappeared today, could the project be
recreated on a new machine without redoing the work?**

Short answer: **mostly yes, if we keep treating GitHub as the durable source
of truth, keep `main` current, and keep the companion repos and hosted-service
assumptions explicit.**

The most important practical rule is that **Git history is the durable source
of truth**. Local clones, iCloud paths, and generated caches are operational
layers, not the canonical record.

## Precise Goal

At this stage, the project goal is:

1. keep one maintained restored SBCL experimental environment that stands in
   for the historical AbTweak code line closely enough to support the checked
   claims,
2. keep the release/documentation/public surfaces buildable from checked-in
   source,
3. keep enough documentation and validation structure that the work can resume
   from a fresh clone rather than from memory, and
4. keep later `hanoi-4` follow-on work clearly separated from the frozen
   `1.0.0-rc.1` restoration baseline.

## Current Project State

As of this migration checkpoint:

- `1.0.0-rc.1` is the stable restoration baseline.
- `main` is the durable baseline branch.
- the preferred active working-clone model is a normal non-iCloud checkout,
  not an iCloud-backed live worktree.
- the recommended bootstrap/handoff path is now documented at the repo root:
  - `BOOTSTRAP-CHECKLIST.md`
  - `NEW-MAC-HANDOFF.md`
  - `MACHINE-DEPRECATION-CHECKLIST.md`
  - `PROJECT-STATUS.md`
- the practical repo-local validation spine is:
  - `sh scripts/abtweak-experiments.sh status --json`
  - `sh scripts/abtweak-experiments.sh run blocks-sussman-abtweak --json`
  - `sh scripts/abtweak-experiments.sh run hanoi3-abtweak --json`
- the full mirrored-public and hosted-UI continuity path still depends on the
  separate repos:
  - `https://github.com/sgwoods/public`
  - `https://github.com/sgwoods/abtweak-experiments-ui`

## What Is Checked In

The current repo already checks in the main material needed to resume work on
a new machine:

### Core source and restoration assets

- `working/abtweak-1993/`
- `historical/`
- `publications/`
- `experiments/`

### Validation and reporting harnesses

- `scripts/`
- `analysis/`
- `releases/`

### Tracked project-state documentation

- `README.md`
- `CHANGELOG.md`
- `VERSION`
- `docs/`
- the root migration/handoff artifacts added for this portability pass

### Tracked generated/public-facing templates

- `site/`
- release snapshots under `releases/`

## What Is Intentionally Not Fully Inside This Repo

The project still has deliberate external or companion surfaces:

1. **Public publishing repo**
   The mirrored public project pages and status-manifest target live in
   `sgwoods/public`.

2. **Hosted remote-experiment UI repo**
   The browser-facing remote-experiment UI lives in
   `sgwoods/abtweak-experiments-ui`.

3. **Hosted-service configuration**
   The Vercel project and the secret values behind these environment-variable
   names are intentionally not stored here:
   - `GITHUB_TOKEN`
   - `GITHUB_OWNER`
   - `GITHUB_REPO`
   - `GITHUB_WORKFLOW_SINGLE`
   - `GITHUB_WORKFLOW_SET`

4. **Ignored operating-system or run-cache noise**
   From `.gitignore`, this includes `.DS_Store` and `*.log`.

## Can The Work Be Recreated On A New Machine?

### For the main repo work: yes

A new machine can recover the practical main-repo state if it does all of the
following:

1. clone `https://github.com/sgwoods/mmath-renovation.git`
2. start from `main`, then check out a newer pushed working branch only if
   unreleased work is intentionally needed
3. install the required runtime tools:
   - `git`
   - `python3`
   - `sbcl`
   - `perl`
4. run:

```bash
bash scripts/start-codex-new-mac.sh
```

That is enough to validate the supported repo-local baseline without relying
on an iCloud live worktree.

### For the public and hosted-UI continuity path: yes, but they are companion repos

To recreate the full continuation surface, a new machine should also clone:

- `https://github.com/sgwoods/public`
- `https://github.com/sgwoods/abtweak-experiments-ui`

Then it can run:

```bash
bash scripts/start-codex-new-mac.sh --validate-ui --run-public-drill
```

That path validates the hosted UI build and the release/public sync drill while
restoring the touched tracked artifacts afterward so the repos end clean again.

## Remaining Reproducibility Risks

The remaining risks are mostly workflow and external-service risks:

1. **Companion repo risk**
   The public and hosted-UI surfaces do not live only in this repo.

2. **Hosted-service risk**
   The Vercel project and secret values are operationally required but are not
   and should not be checked into git.

3. **Future local-only evidence risk**
   New diagnostics, traces, or public-surface changes that are left only in a
   single local clone would weaken recoverability.

4. **Stale handoff risk**
   If `PROJECT-STATUS.*` and the bootstrap/handoff docs stop being updated,
   future machine moves will again depend on memory.

## What To Do To Be Confident

To stay confident that no work has to be redone, treat this as the minimum
continuity checklist:

1. keep `main` pushed,
2. keep any active newer working branch pushed too,
3. keep the companion repos pushed when their surfaces change,
4. keep new material flowing through `intake/` or the documented iCloud intake
   path,
5. keep the startup validation path passing,
6. periodically prove the non-iCloud fresh-clone path again rather than only
   assuming it still works.
