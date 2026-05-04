# Worktree Status

This repo is now intended to be continued from a normal non-iCloud Git clone.

- Durable baseline: `main` at `1.0.0-rc.1`
- Preferred active-clone model: normal non-iCloud working copy
- iCloud role: intake, backup-oriented material, and convenience paths only

Quick check:

```bash
bash scripts/show-project-version.sh
```

If this folder lives inside an iCloud-backed path, treat it as a reference or
fallback clone rather than the preferred live worktree.
