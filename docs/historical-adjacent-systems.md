# Historical Adjacent Systems

This note records historical directories imported into `historical/` that are
clearly related to the broader thesis-era research environment, but are not
part of the main AbTweak snapshot line.

These directories should be preserved as archival reference material and kept
out of the active `working/abtweak-1993` restoration path unless we later open
a dedicated restoration track for them.

## Summary Table

| Directory | Current interpretation | Evidence | Relationship to AbTweak |
| --- | --- | --- | --- |
| [historical/A-star](/Users/stevenwoods/mmath-renovation/historical/A-star) | Generic graph-search workspace, likely Qiang Yang's instructional/research code from May 1990 | [note](/Users/stevenwoods/mmath-renovation/historical/A-star/note#L1) is an email from Qiang describing reconstructed graph-search routines and asking for a blocks-world and IDA* extension; code includes `8puzzle`, `tower`, and `blocks` domain files | Adjacent search infrastructure, not the AbTweak planner itself |
| [historical/Mini-Tweak](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak) | Compact simplified TWEAK workspace derived from Jude Shavlik's teaching code | [Original/author.note](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/author.note#L1) and [Original/minitweak.lsp](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/minitweak.lsp#L1) preserve the source email and code; local files include `m-tweak.l` and `lens-domain.l` | Closest adjacent planner artifact; relevant to TWEAK lineage, but still separate from the AbTweak code line |
| [historical/KautzPR](/Users/stevenwoods/mmath-renovation/historical/KautzPR) | Henry Kautz plan-recognition system | [demo/instructions.text](/Users/stevenwoods/mmath-renovation/historical/KautzPR/demo/instructions.text#L1) explicitly identifies it as "A Plan Recognition System"; demo/test files and implementation subtrees survive | Related planning/recognition research context, not part of AbTweak proper |
| [historical/Mvl](/Users/stevenwoods/mmath-renovation/historical/Mvl) | Separate MVL theorem-proving system from Stanford | [README](/Users/stevenwoods/mmath-renovation/historical/Mvl/README#L1) identifies it as MVL; [ChangeLog](/Users/stevenwoods/mmath-renovation/historical/Mvl/ChangeLog#L1) shows 1991 development activity; includes manual, tests, many `.sbin` artifacts | Separate logic/theorem-proving codebase; not part of the AbTweak planner line |
| [historical/PlanMerge](/Users/stevenwoods/mmath-renovation/historical/PlanMerge) | Small April 1990 plan-merge workspace | [merge.good.lsp](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/merge.good.lsp#L1), [AA_IN-OUT_LOG](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/AA_IN-OUT_LOG#L1), and KCL-era [Backups/output.run](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/Backups/output.run#L1) survive | Adjacent planning experiment code; provenance still open |
| [historical/PlanMerge2](/Users/stevenwoods/mmath-renovation/historical/PlanMerge2) | Duplicate archival copy of `PlanMerge` pending contrary evidence | File comparison currently shows no content differences beyond `.DS_Store` | Preserve, but treat `PlanMerge` as canonical for reading |

## Notes By System

### `A-star`

This looks like a reusable state-space search shell with domain adapters for:

- 8-puzzle
- Tower of Hanoi
- blocks world

The preserved email in [historical/A-star/note](/Users/stevenwoods/mmath-renovation/historical/A-star/note#L1) is especially useful because it explains intent: layered data abstraction in the graph-search code, domain-dependent plug-ins, and a suggestion to extend it toward IDA*.

### `Mini-Tweak`

This is the most directly relevant adjacent archive beyond AbTweak itself.

The preserved source in [historical/Mini-Tweak/Original/minitweak.lsp](/Users/stevenwoods/mmath-renovation/historical/Mini-Tweak/Original/minitweak.lsp#L1) identifies it as:

- "A Simplified Version of Chapman's Non-Linear Planner TWEAK"
- Jude William Shavlik, 1988

The local wrapper files suggest this copy was used as working material in April 1990. It is not the same planner as the AbTweak line, but it is clearly relevant to the TWEAK background.

The dedicated comparison note is:

- [mini-tweak-lineage.md](/Users/stevenwoods/mmath-renovation/docs/mini-tweak-lineage.md#L1)
- [mini-tweak-side-experiment.md](/Users/stevenwoods/mmath-renovation/docs/mini-tweak-side-experiment.md#L1)

### `KautzPR`

The preserved demo and implementation files identify this as Henry Kautz's plan-recognition system. It has:

- implementation files under `imp/`
- test hierarchies under `test/`
- demos and showoff scripts under `demo/`
- a local interactive trace in [demo.trace.steve](/Users/stevenwoods/mmath-renovation/historical/KautzPR/demo.trace.steve#L1)

This appears to be a separate but nearby research tool preserved in the same historical material.

### `Mvl`

This is a much larger imported system with its own manual, compiled artifacts,
tests, and domain/problem files. The included documentation identifies it as a
theorem-proving system, not a planner.

Its presence is historically interesting, but it should not be mixed into the
AbTweak restoration story.

## Recommended Handling

- Keep all of these directories under `historical/` unchanged.
- Do not treat them as AbTweak snapshots.
- If one becomes relevant to the thesis reconstruction, open a separate
  restoration or provenance note for it rather than mixing it into the active
  planner baseline.
- Use `Mini-Tweak` as the first adjacent codebase to study later if we want a
  deeper TWEAK-lineage comparison.
