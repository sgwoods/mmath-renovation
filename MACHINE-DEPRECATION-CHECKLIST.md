# Machine Deprecation Checklist

This file is the practical answer to:

**When is the current MacBook no longer the authoritative home of this
project?**

Use it when we want to retire a local machine confidently without losing
project state, setup knowledge, or supporting continuity surfaces.

## Goal

We want a state where:

1. the durable baseline is in git and on the remote,
2. the preferred active clone on the next machine is a clean non-iCloud
   working copy,
3. the supported startup path works there,
4. intake and preservation workflows are documented there too, and
5. the old machine can be treated as secondary without anxiety.

## Current Read

At the current checkpoint:

- `main` is the durable baseline branch.
- `1.0.0-rc.1` is the stable restoration baseline.
- the recommended active-clone model is now non-iCloud:
  `~/Projects/mmath-renovation-working`
- the companion repos should likewise live outside iCloud:
  - `~/Projects/public`
  - `~/Projects/abtweak-experiments-ui`
- the preferred iCloud helper path is now intake-only:
  `~/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/mmath-renovation-intake`

That means the old machine should no longer be treated as the only place where
the project "really works" once the gate below is satisfied.

## Retirement Gate

Treat the old machine as non-authoritative only when all of the following are
true:

1. `main` is pushed and current.
2. Any newer working-branch changes are also pushed.
3. The next machine has a clean non-iCloud active working clone at the
   intended commit.
4. `bash scripts/start-codex-new-mac.sh` has passed from that non-iCloud
   active clone.
5. The preferred intake path exists there:
   `~/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/mmath-renovation-intake`
6. If public publishing is needed, the companion `public` repo is present and
   the release/public drill has passed there too.
7. If hosted remote-experiment continuity is needed, the companion UI repo
   builds there and the Vercel configuration remains intact.

## Preferred Ongoing Local Home

Going forward, the preferred local working model is:

- active Git clone outside iCloud
- companion repos outside iCloud
- intake and backup-oriented paths inside iCloud

If older iCloud-backed live worktrees still exist, treat them as reference or
fallback copies, not the preferred active repos.

## What The Old Machine Still Matters For

Once the retirement gate above is satisfied, the old machine should be treated
as:

- a temporary convenience copy,
- a place to verify nothing unexpected was left behind,
- but not the source of truth for day-to-day continuation.

## Big-Picture Rule

The project should remain:

- git-backed,
- explicit about its companion repos and external services,
- non-iCloud for active working clones,
- iCloud-backed only for intake/backups,
- and recoverable from a fresh checkout plus documented dependencies.

If that remains true, machine retirement is an operational change, not a
project risk.
