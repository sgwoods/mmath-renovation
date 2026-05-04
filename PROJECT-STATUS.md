# Project Status

This file is the quick root-level answer to "what state is this folder
supposed to represent?"

- Project: `Masters of Mathematics Thesis Renovation: AbTweak`
- Durable baseline: `1.0.0-rc.1`
- Current track: `1.0 RC hardening`
- Current focus: `Portability hardening and disciplined post-RC continuation`
- Build line: `1.0.0-rc.1`
- Canonical branch: `main`
- Active working branch: `main`
- Updated: `May 4, 2026`

## Source Of Truth

Git history in `sgwoods/mmath-renovation`, with `sgwoods/public` and
`sgwoods/abtweak-experiments-ui` as companion repos for the mirrored public
surface and the hosted remote-experiment UI.

## Recommended Working Model

Use a normal non-iCloud active clone for day-to-day work. Use iCloud for
intake, backup-oriented material, and convenience paths only.

## Quick Commands

See the live folder state:

```bash
bash scripts/show-project-version.sh
```

Run the explicit startup validation path from an existing clone:

```bash
bash scripts/start-codex-new-mac.sh
```

Bootstrap a fresh non-iCloud Mac working clone:

```bash
bash scripts/bootstrap-project-macos.sh
```
