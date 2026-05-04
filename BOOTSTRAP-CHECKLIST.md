# Bootstrap Checklist

This file is the shortest explicit checklist for bringing the project up on a
new machine in the currently recommended way.

For the most complete single-command path now available, use:

```bash
bash scripts/bootstrap-project-macos.sh
```

## Canonical Truth

The durable source of truth for the project is:

1. the Git history in `sgwoods/mmath-renovation`,
2. `main` as the durable baseline branch,
3. any intentionally newer pushed working branch, and
4. the companion repos `sgwoods/public` and
   `sgwoods/abtweak-experiments-ui` for the mirrored public surface and hosted
   remote-experiment UI.

The durable truth is not any single local machine, local cache, or iCloud live
worktree.

## Recommended Local Layout

Use normal non-iCloud working clones for day-to-day development:

```text
~/Projects/mmath-renovation-working
~/Projects/public
~/Projects/abtweak-experiments-ui
```

Use iCloud for intake and backup-oriented convenience paths:

```text
~/Library/Mobile Documents/com~apple~CloudDocs/Projects/mmath-renovation/incoming-landing
```

Use the repo-local `intake/` directory as the durable first repo stop after
anything is copied in from the iCloud landing path.

Do not treat an iCloud-backed live Git worktree as the preferred active clone.

## Machine Dependencies

Required commands/tools for the full portability path:

- `git`
- `python3`
- `sbcl`
- `perl`
- `node`
- `npm`
- `pdf2ps`
- `curl`

The repo's supported startup validation path currently uses:

- `sh scripts/abtweak-experiments.sh status --json`
- `sh scripts/abtweak-experiments.sh run blocks-sussman-abtweak --json`
- `sh scripts/abtweak-experiments.sh run hanoi3-abtweak --json`

Optional companion validation can also run:

- hosted UI `npm install` + `npm run build`
- release snapshot + public sync drill with cleanup back to a clean git state

## Suggested macOS Setup Order

### Preferred one-command path

From an existing checkout of this repo, the preferred complete bootstrap is:

```bash
bash scripts/bootstrap-project-macos.sh
```

That script now:

1. verifies or optionally installs Homebrew,
2. installs the command-line dependencies with Homebrew,
3. creates or refreshes the recommended non-iCloud active clone,
4. preserves the current branch if run from an existing repo checkout unless
   `--branch` is given,
5. clones or refreshes the companion `public` and UI repos by default,
6. runs the supported startup validation path, and
7. can also run the public release drill and UI build validation.

Useful options:

```bash
bash scripts/bootstrap-project-macos.sh --target-dir "$HOME/Projects/mmath-renovation-working"
bash scripts/bootstrap-project-macos.sh --branch main
bash scripts/bootstrap-project-macos.sh --skip-ui-build
bash scripts/bootstrap-project-macos.sh --skip-public-drill
bash scripts/bootstrap-project-macos.sh --skip-supporting-clones
bash scripts/bootstrap-project-macos.sh --skip-validation
bash scripts/bootstrap-project-macos.sh --install-homebrew
```

### Manual step-by-step path

1. Install or verify Homebrew if needed.
2. Install the command-line dependencies:

```bash
brew install sbcl ghostscript node
```

`git`, `python3`, `perl`, and `curl` should also be available in `PATH`.

3. Clone the repo outside iCloud:

```bash
mkdir -p ~/Projects
git clone https://github.com/sgwoods/mmath-renovation.git ~/Projects/mmath-renovation-working
cd ~/Projects/mmath-renovation-working
```

4. Run the normal startup/validation path:

```bash
bash scripts/start-codex-new-mac.sh
```

5. If you also want the companion-public and hosted-UI checks:

```bash
git clone https://github.com/sgwoods/public.git ~/Projects/public
git clone https://github.com/sgwoods/abtweak-experiments-ui.git ~/Projects/abtweak-experiments-ui
bash scripts/start-codex-new-mac.sh --validate-ui --run-public-drill
```

## What The Startup Script Covers

`scripts/start-codex-new-mac.sh` currently:

1. checks the required commands,
2. ensures the preferred iCloud intake path exists,
3. prints branch state,
4. runs the supported repo-local validation spine unless `--skip-validation`
   is passed,
5. optionally validates the hosted UI build, and
6. optionally runs the release snapshot/public sync drill and restores the
   touched tracked artifacts so the checked-out repos end clean again.

The more complete outer bootstrap script is:

- `scripts/bootstrap-project-macos.sh`

That script exists to make the from-scratch machine path cleaner and more
repeatable than relying on a partially prepared machine.

## Companion Repos

If you need the full mirrored-public and hosted-UI continuity path, clone:

```bash
git clone https://github.com/sgwoods/public.git ~/Projects/public
git clone https://github.com/sgwoods/abtweak-experiments-ui.git ~/Projects/abtweak-experiments-ui
```

The main repo's harness and smoke validation work without those repos. The
public-sync drill and local hosted-UI build checks depend on them.
