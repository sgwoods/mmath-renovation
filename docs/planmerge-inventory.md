# PlanMerge Inventory

This note records the two newly imported archival directories:

- [historical/PlanMerge](/Users/stevenwoods/mmath-renovation/historical/PlanMerge)
- [historical/PlanMerge2](/Users/stevenwoods/mmath-renovation/historical/PlanMerge2)

They are preserved as historical reference material and are not part of the
active `Abtweak-1993` working tree.

## What They Contain

Both directories currently contain the same file set:

- [merge.good.lsp](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/merge.good.lsp#L1)
- [AA_IN-OUT_LOG](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/AA_IN-OUT_LOG#L1)
- `Backups/count.lsp`
- `Backups/merge.lsp`
- `Backups/output.run`
- `Backups/prob.lsp`
- `Backups/test.lsp`
- `Backups/uappend.lsp`

`PlanMerge2` appears identical to `PlanMerge` except for `.DS_Store`.

## Current Interpretation

The main source header in [merge.good.lsp](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/merge.good.lsp#L1) describes this as:

- `Plan Merge Algorithm`
- implemented by Steve Woods
- University of Waterloo
- dated April 1, 1990

The preserved [AA_IN-OUT_LOG](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/AA_IN-OUT_LOG#L1) suggests a small transfer-history trail for `merge.lsp` in early April 1990, and [Backups/output.run](/Users/stevenwoods/mmath-renovation/historical/PlanMerge/Backups/output.run#L1) shows KCL-era interactive test output.

At the moment, the safest interpretation is:

1. this is adjacent historical Lisp research code
2. it is not obviously part of the main AbTweak snapshot line
3. it may still be relevant as surrounding thesis-era planning research

## Recommended Handling

- Keep both directories under `historical/` unchanged.
- Treat `PlanMerge` as the canonical copy for reading.
- Treat `PlanMerge2` as a duplicated archival import unless later provenance
  shows otherwise.
- Do not mix this code into the active AbTweak restoration path without a
  separate review.

## Redundancy Status

At the current state of the repository:

- [historical/PlanMerge](/Users/stevenwoods/mmath-renovation/historical/PlanMerge)
  should be treated as the potentially valuable archival copy
- [historical/PlanMerge2](/Users/stevenwoods/mmath-renovation/historical/PlanMerge2)
  should be treated as a redundant duplicate preserved only for provenance

So `PlanMerge2` is no longer just "possibly duplicate" in the practical repo
sense. It is now explicitly labeled as the redundant copy unless later evidence
changes that interpretation.

## Open Questions

1. whether `PlanMerge` was used with AbTweak outputs, or is a separate planning
   side project
2. whether `PlanMerge2` was an intentional second working copy or just a later
   duplicate in the recovered media
3. whether the backup files correspond to any thesis text or experiments that
   should be cited in the formal documentation later
