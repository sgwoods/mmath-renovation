# Thesis Figure Inventory

This inventory tracks the figures in the full checked-in thesis and their
current relationship to the restored project outputs.

Canonical thesis source:

- [publications/1991 mmath thesis final.pdf](/Users/stevenwoods/mmath-renovation/publications/1991%20mmath%20thesis%20final.pdf)

Status labels:

- `Mapped`: a maintained current comparison graphic exists and is checked in
- `Partial`: the thesis figure topic is supported by current runs or docs, but
  we do not yet have a maintained side-by-side recreation
- `Open`: the figure is understood, but no maintained modern counterpart exists

Current mapped gallery:

- [Thesis side-by-side graphics](/Users/stevenwoods/mmath-renovation/docs/thesis-side-by-side-graphics.md)

## Inventory

| Figure | Thesis caption | PDF page | Current status | Current evidence or gap |
| --- | --- | ---: | --- | --- |
| `1` | Spatially disjoint nail and hole | `2` | `Open` | Introductory illustrative figure. No maintained modern counterpart yet. |
| `2` | Interacting nail and hole | `2` | `Open` | Introductory illustrative figure. No maintained modern counterpart yet. |
| `3` | White Knight Justification | `18` | `Open` | The justification concept is discussed in the code lineage and theory text, but there is no maintained recreated figure yet. |
| `4` | Separation Justification | `19` | `Open` | Same status as Figure 3: understood theoretically, not yet recreated as a maintained modern graphic. |
| `5` | Promotion Justification | `19` | `Open` | Same status as Figures 3 and 4. |
| `6` | Representing the abstract solution space | `24` | `Partial` | Closely related to current abstraction-level diagnostics and lineage traces such as [docs/hanoi4-lineage-trace.md](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md), but no maintained side-by-side figure exists yet. |
| `7` | Robot Task Planning Domain | `27` | `Partial` | Strong current robot-domain validation exists in [docs/tweak-vs-abtweak-comparison.md](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md) and [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md), but the domain map itself is not yet recreated. |
| `8` | Violations versus CPU time, including regression fit curve; breadth-first with MP | `33` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-08-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-08-side-by-side.png). |
| `9` | Violations versus CPU time, including regression fit curve; left-wedge with MP | `34` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-09-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-09-side-by-side.png). |
| `10` | Comparing Tweak with AbTweak | `36` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-10-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-10-side-by-side.png). |
| `11` | Comparing Tweak with AbTweak in the robot task planning domain | `38` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-11-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-11-side-by-side.png). |

## Suggested Next Additions

The next strongest candidates for extension are:

1. Figure `6`, because the repo now has rich abstraction and lineage material
   that could support a clean modern counterpart.
2. Figure `7`, because the robot-domain validation story is already strong and
   only lacks the domain-structure panel.
3. Figures `3` to `5`, if we decide to recreate the theoretical justification
   diagrams as maintained explanatory artifacts.

## Maintenance Rule

When a new thesis figure is added to the side-by-side gallery:

1. update this inventory
2. update [docs/thesis-side-by-side-graphics.md](/Users/stevenwoods/mmath-renovation/docs/thesis-side-by-side-graphics.md)
3. regenerate the gallery through
   [scripts/generate-thesis-side-by-side.py](/Users/stevenwoods/mmath-renovation/scripts/generate-thesis-side-by-side.py)
4. refresh the release snapshot with
   [scripts/create-release-snapshot.sh](/Users/stevenwoods/mmath-renovation/scripts/create-release-snapshot.sh)
