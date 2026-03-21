# Historical Snapshots

This directory contains the unpacked AbTweak snapshots imported from the uploaded archive on 2026-03-14.

## Layout

- `Abtweak/Abtweak-1990-12`
- `Abtweak/Abtweak-1990-12b`
- `Abtweak/Abtweak-1991-05`
- `Abtweak/Abtweak-1991-08`
- `Abtweak/Abtweak-1992`
- `Abtweak/Abtweak-1993`
- `A-star`
- `KautzPR`
- `Mini-Tweak`
- `Mvl`
- `PlanMerge`
- `PlanMerge2`

## Notes

- These are preserved as historical working trees, not yet normalized source trees.
- These archival trees are read-only reference material for this project. Do not edit files under `historical/Abtweak/` as part of porting work.
- Some snapshots include compiled outputs, saved runs, shell scripts, and generated documentation alongside source code.
- The imported archive also includes macOS packaging artifacts such as `__MACOSX` and `.DS_Store`; these are not part of the historical AbTweak source itself.
- `A-star`, `Mini-Tweak`, `KautzPR`, and `Mvl` are preserved as adjacent historical research/code workspaces, not as part of the main AbTweak snapshot line.
- `PlanMerge` and `PlanMerge2` are preserved as adjacent historical Lisp workspaces, not as part of the main AbTweak snapshot line. They currently appear identical except for Finder metadata and should be treated as archival reference material until their exact provenance is clearer.

## Redundant vs. Potentially Valuable Archival Material

The following directories are currently treated as redundant archival imports:

- `PlanMerge2`: duplicate archival copy of `PlanMerge` unless contrary provenance appears later
- `__MACOSX`: macOS packaging artifact directory from the recovered archive, not source material

These are preserved for provenance only and should not be used as primary
reference trees.

The following directories still have potential go-forward archival value even
though they are not part of the active restored baseline:

- `historical/Abtweak/*`: primary provenance basis for the AbTweak code line
- `A-star`
- `Mini-Tweak`
- `KautzPR`
- `Mvl`
- `PlanMerge`

For the comparative review and recommended starting points, see [docs/snapshot-inventory.md](../docs/snapshot-inventory.md). For the broader archival side systems now preserved alongside AbTweak, see [docs/historical-adjacent-systems.md](../docs/historical-adjacent-systems.md).
