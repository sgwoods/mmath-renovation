# Historical Snapshots

This directory contains the unpacked AbTweak snapshots imported from the uploaded archive on 2026-03-14.

## Layout

- `Abtweak/Abtweak-1990-12`
- `Abtweak/Abtweak-1990-12b`
- `Abtweak/Abtweak-1991-05`
- `Abtweak/Abtweak-1991-08`
- `Abtweak/Abtweak-1992`
- `Abtweak/Abtweak-1993`
- `PlanMerge`
- `PlanMerge2`

## Notes

- These are preserved as historical working trees, not yet normalized source trees.
- These archival trees are read-only reference material for this project. Do not edit files under `historical/Abtweak/` as part of porting work.
- Some snapshots include compiled outputs, saved runs, shell scripts, and generated documentation alongside source code.
- The imported archive also includes macOS packaging artifacts such as `__MACOSX` and `.DS_Store`; these are not part of the historical AbTweak source itself.
- `PlanMerge` and `PlanMerge2` are preserved as adjacent historical Lisp workspaces, not as part of the main AbTweak snapshot line. They currently appear identical except for Finder metadata and should be treated as archival reference material until their exact provenance is clearer.

For the comparative review and recommended starting points, see [docs/snapshot-inventory.md](../docs/snapshot-inventory.md).
