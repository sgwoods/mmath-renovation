# New-Machine Bootstrap

This note turns the continuity work into a concrete operating procedure for the
next Mac.

It complements:

- [Cold-start reconstruction](/Users/stevenwoods/mmath-renovation/docs/cold-start-reconstruction.md)
- [Continuity and archival policy](/Users/stevenwoods/mmath-renovation/docs/continuity-and-archival-policy.md)
- [Project state and recovery audit](/Users/stevenwoods/mmath-renovation/docs/project-state-recovery-audit.md)

## Goal

Be able to start from a clean Mac, recreate the full active continuation set,
and prove that the project can keep moving without depending on hidden local
state from the retiring machine.

## Current Local State

As of `2026-05-03`, the main project repo at commit `ae80e20` is clean and
pushed on `main`.

The canonical working root on this machine is now:

```text
/Users/stevenwoods/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/
```

with these active clones:

1. `mmath-renovation`
2. `public`
3. `abtweak-experiments-ui`

Those canonical iCloud-backed clones have been validated and cleaned back to a
pristine git state after the reconstruction drill.

The new bootstrap script has now also been run successfully from the clean
canonical iCloud `mmath-renovation` clone itself, and all three canonical
clones finished clean afterward:

1. `mmath-renovation`
2. `public`
3. `abtweak-experiments-ui`

The older local paths now count as legacy fallback only:

1. `/Users/stevenwoods/mmath-renovation`
2. `/Users/stevenwoods/GitPages/public`

They should not be treated as the normal ongoing working area.

## What Is Safely Preserved

The checked-in preservation surface now includes:

- the restored planner baseline and harness
- the release snapshots
- the thesis gallery and figure inventory
- the retained `hanoi-4` raw trace corpus
- the continuity/recovery documentation
- the hosted UI source repo
- the public project/dashboard source templates

The main external continuity surface that is still operational rather than
checked into git is:

- the Vercel deployment bound to `sgwoods/abtweak-experiments-ui`
- the Vercel environment variables and secret token values

The variable names that must remain configured are:

- `GITHUB_TOKEN`
- `GITHUB_OWNER`
- `GITHUB_REPO`
- `GITHUB_WORKFLOW_SINGLE`
- `GITHUB_WORKFLOW_SET`

## New-Machine Start Procedure

1. Ensure the target Mac has the required tools available in `PATH`.
2. Create the canonical iCloud-backed workspace root:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/
```

3. Clone the main repo into:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/mmath-renovation
```

4. Run the bootstrap script from that clone:

```sh
sh scripts/bootstrap-new-machine.sh
```

That script will:

- validate required tools
- clone or refresh the sibling `public` and `abtweak-experiments-ui` repos
- run the main harness status check
- run the hosted UI `npm install` and `npm run build`
- run the release snapshot + public sync continuity drill
- restore expected generated outputs so the workspace ends clean again

## Required Tools

The bootstrap script checks for:

- `git`
- `python3`
- `sbcl`
- `perl`
- `node`
- `npm`
- `pdf2ps`

On macOS, the expected install path is usually:

```sh
brew install sbcl ghostscript node
```

`git`, `python3`, and `perl` should also be available before continuing.

## Acceptance Standard

The new Mac should be considered ready when:

1. `scripts/bootstrap-new-machine.sh` succeeds
2. the canonical iCloud-backed clones exist for all three repos
3. all three canonical clones end clean after the drill cleanup
4. the hosted UI repo still matches the Vercel deployment expectations

That standard is now satisfied on this machine's canonical iCloud-backed
workspace.

## Recommended Next Step After Bootstrap

Once the script succeeds:

1. open Codex in the canonical `mmath-renovation` clone
2. continue from the current roadmap rather than the legacy local copies
3. keep the retiring MacBook only as a temporary fallback until the new Mac has
   been used successfully for normal work
