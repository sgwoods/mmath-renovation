# New Mac Handoff

This file is the shortest practical guide for bringing the project up on a
different Mac and retiring the current machine safely.

The canonical durable state is the Git repo and its pushed branches, not any
single local machine or iCloud working copy.

## Current Portability Goal

We want to be able to:

1. clone the repo on a different Mac,
2. install or verify the required dependencies,
3. run one bootstrap script,
4. validate the supported baseline from a normal non-iCloud clone,
5. and continue work without reconstructing local context by hand.

## Current Local State

At the current portability checkpoint:

- the durable baseline branch is `main`
- the stable restoration line is `1.0.0-rc.1`
- the preferred active clone model is now a normal non-iCloud working copy,
  not an iCloud-backed live worktree
- the recommended active paths are:
  - `~/Projects/mmath-renovation-working`
  - `~/Projects/public`
  - `~/Projects/abtweak-experiments-ui`
- the preferred iCloud-backed intake path is:
  - `~/Library/Mobile Documents/com~apple~CloudDocs/StevenWoods/mmath-renovation-intake`
- the repo-local intake handoff area remains:
  - `intake/`

The older iCloud-centered continuity notes in `docs/` are still useful as the
record of the earlier drill, but they are no longer the preferred active
working model.

## Required Dependencies

For the shortest explicit setup order, see `BOOTSTRAP-CHECKLIST.md`.

The supported startup path expects:

- `git`
- `python3`
- `sbcl`
- `perl`
- `node`
- `npm`
- `pdf2ps`
- `curl`

## Start Scripts

For the cleanest from-scratch machine setup now available, prefer:

```bash
bash scripts/bootstrap-project-macos.sh
```

That script can install the machine dependencies, create or refresh the
recommended non-iCloud active clone, optionally refresh the companion repos,
and then hand off to the validated startup path below. If you run it from an
existing project checkout, it preserves that checkout's current branch unless
you explicitly override it with `--branch`.

The lower-level startup script remains:

```bash
bash scripts/start-codex-new-mac.sh
```

If you want the companion repo validation too:

```bash
bash scripts/start-codex-new-mac.sh --validate-ui --run-public-drill
```

The startup script:

1. checks required commands,
2. creates the preferred iCloud intake path,
3. prints branch state,
4. runs the supported harness summary and representative smoke cases unless
   `--skip-validation` is passed,
5. optionally validates the hosted UI repo if present, and
6. optionally runs the release snapshot/public sync drill while restoring the
   touched tracked outputs afterward.

## What Still Needs Deliberate Care

1. Keep `main` pushed and current.
2. Keep any newer intentional working branch pushed too.
3. Keep the companion `public` repo pushed when public-facing outputs change.
4. Keep the companion `abtweak-experiments-ui` repo pushed when the hosted UI
   changes.
5. Preserve the Vercel environment-variable names for the hosted UI:
   - `GITHUB_TOKEN`
   - `GITHUB_OWNER`
   - `GITHUB_REPO`
   - `GITHUB_WORKFLOW_SINGLE`
   - `GITHUB_WORKFLOW_SET`
6. Put all new material through `intake/` or the iCloud intake landing path.

## Deprecating The Current MacBook

Before retiring the current MacBook, the safest minimum is:

1. push `main`,
2. push any newer working branch,
3. verify `bash scripts/start-codex-new-mac.sh` from the new Mac's non-iCloud
   active clone,
4. verify the preferred iCloud intake path exists there,
5. verify any needed companion repo checks there too, and
6. only then treat the old machine as non-authoritative.

The practical machine-retirement gate now lives in
`MACHINE-DEPRECATION-CHECKLIST.md`.
