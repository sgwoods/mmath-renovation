# Continuity And Archival Policy

This note defines how the project should preserve continuity going forward.

It complements:

- [Project state and recovery audit](/Users/stevenwoods/mmath-renovation/docs/project-state-recovery-audit.md)
- [Cold-start reconstruction](/Users/stevenwoods/mmath-renovation/docs/cold-start-reconstruction.md)
- [Project compendium](/Users/stevenwoods/mmath-renovation/docs/project-compendium.md)
- [Release process](/Users/stevenwoods/mmath-renovation/docs/release-process.md)

## Purpose

The goal is:

- keep all substantive project information
- preserve work-in-progress versions that may later become useful
- avoid losing evidence because it lived only in one local working tree
- make future recovery and continuation routine rather than heroic

## What Must Be Preserved

Going forward, preserve all substantive project artifacts, including:

- code
- documentation
- generated reports that support checked-in claims
- raw trace evidence that current or likely future docs depend on
- local patches or alternate drafts that are not yet promoted but may matter
- public-facing page/dashboard sources
- release snapshots

Do not treat these as disposable scratch:

- meaningful `hanoi-4` trace directories
- one-off restoration diagnostics that support a checked-in interpretation
- uncommitted but potentially useful document rewrites

## Preferred Preservation Rule

Use this order:

1. if the artifact is polished and part of the main story, put it in its
   natural long-term home
2. if it is meaningful but not yet ready for the main story, retain it under
   [analysis/recovery-artifacts](/Users/stevenwoods/mmath-renovation/analysis/recovery-artifacts/README.md)
3. if it is pure operating-system noise, do not preserve it

Examples of things we do not preserve:

- `.DS_Store`
- clearly duplicated packaging noise
- generated garbage with no evidentiary or operational value

## Working Directory Policy

For this machine going forward, all active local working directories related to
this project should live inside an iCloud-backed workspace root.

Recommended structure:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/
  mmath-renovation/
  public/
  abtweak-experiments-ui/
```

This workspace root has now been created and validated as a real continuation
workspace on this machine.

The main build/sync tooling should now treat this iCloud-backed workspace as
the default working root when possible, rather than the older local-only
`/Users/stevenwoods/GitPages/public` path.

That means the following continuation set should all be backed up together:

1. `mmath-renovation`
2. `public`
3. `abtweak-experiments-ui`

## External Surface Policy

The full project continuity surface is larger than one repo.

Treat these as one coordinated working set:

- [sgwoods/mmath-renovation](https://github.com/sgwoods/mmath-renovation)
- [sgwoods/public](https://github.com/sgwoods/public)
- [sgwoods/abtweak-experiments-ui](https://github.com/sgwoods/abtweak-experiments-ui)

The hosted UI also depends on operational environment variables whose names
should stay documented even though the secret values are not checked in:

- `GITHUB_TOKEN`
- `GITHUB_OWNER`
- `GITHUB_REPO`
- `GITHUB_WORKFLOW_SINGLE`
- `GITHUB_WORKFLOW_SET`

## Recovery Discipline

After any major milestone, do the following:

1. make sure substantive local-only work is either committed or retained as an
   explicit recovery artifact
2. keep the release-facing docs current
3. run the normal release snapshot build when the checkpoint changes materially
4. periodically verify that the project can be reconstructed from the
   documented repo set and hosted configuration

## Near-Term Continuity Goal

The immediate continuity goal is:

- keep the new iCloud-backed workspace as the canonical working root
- remove any remaining dependence on undeclared local configuration
- keep the repo clean except for deliberate in-progress work
- continue validating recovery through real drills, not just documentation

The first fresh-workspace reconstruction drill has now succeeded for:

- the main repo
- the public-sync flow
- the hosted UI repo's local install/build path
- a live HTTP check of the hosted UI URL

The remaining continuity sensitivity is now mostly the external Vercel
configuration and secrets rather than the local repo content.
