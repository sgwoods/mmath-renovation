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
| `1` | Spatially disjoint nail and hole | `3` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-01-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-01-side-by-side.png), with a modern explanatory sketch emphasizing the no-interaction case. |
| `2` | Interacting nail and hole | `3` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-02-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-02-side-by-side.png), with a modern explanatory sketch emphasizing why ordering matters when actions interact. |
| `3` | White Knight Justification | `19` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-03-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-03-side-by-side.png), with a modern explanatory sketch of the White-Knight justification idea. |
| `4` | Separation Justification | `20` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-04-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-04-side-by-side.png), with a modern separation-justification sketch. |
| `5` | Promotion Justification | `20` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-05-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-05-side-by-side.png), with a modern promotion-justification sketch. |
| `6` | Representing the abstract solution space | `24` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-06-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-06-side-by-side.png), using a modern refinement-ladder diagram grounded in the current abstraction and lineage diagnosis. |
| `7` | Robot Task Planning Domain | `27` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-07-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-07-side-by-side.png), combining the thesis domain map with a modern redraw and current robot-domain outcome summary. |
| `8` | Violations versus CPU time, including regression fit curve; breadth-first with MP | `33` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-08-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-08-side-by-side.png). |
| `9` | Violations versus CPU time, including regression fit curve; left-wedge with MP | `34` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-09-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-09-side-by-side.png). |
| `10` | Comparing Tweak with AbTweak | `36` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-10-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-10-side-by-side.png). |
| `11` | Comparing Tweak with AbTweak in the robot task planning domain | `38` | `Mapped` | Maintained side-by-side panel at [analysis/thesis-side-by-side/figure-11-side-by-side.png](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-11-side-by-side.png). |

## Suggested Next Additions

The thesis figure set is now fully mapped into the maintained gallery.

Possible refinement work from here:

1. attach each explanatory figure to a more explicit theory note or code-path
   reference
2. add a compact legend or navigation index to the gallery page
3. reuse the same pattern for other publication or manual figures in the repo

## Maintenance Rule

When a new thesis figure is added to the side-by-side gallery:

1. update this inventory
2. update [docs/thesis-side-by-side-graphics.md](/Users/stevenwoods/mmath-renovation/docs/thesis-side-by-side-graphics.md)
3. regenerate the gallery through
   [scripts/generate-thesis-side-by-side.py](/Users/stevenwoods/mmath-renovation/scripts/generate-thesis-side-by-side.py)
4. refresh the release snapshot with
   [scripts/create-release-snapshot.sh](/Users/stevenwoods/mmath-renovation/scripts/create-release-snapshot.sh)
