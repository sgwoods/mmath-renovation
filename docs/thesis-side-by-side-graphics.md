# Thesis Side-By-Side Graphics

This gallery pairs the thesis experimental figures with current regenerated
comparison surfaces.

Full figure inventory:

- [Thesis figure inventory](/Users/stevenwoods/mmath-renovation/docs/thesis-figure-inventory.md)

For each item:

- left: the original thesis figure, rendered from the full checked-in thesis
- right: the nearest current regenerated evidence for that figure surface

Current gallery outputs:

- [Figure 8 side by side](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-08-side-by-side.png)
- [Figure 9 side by side](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-09-side-by-side.png)
- [Figure 10 side by side](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-10-side-by-side.png)
- [Figure 11 side by side](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/figure-11-side-by-side.png)
- [Gallery contact sheet](/Users/stevenwoods/mmath-renovation/analysis/thesis-side-by-side/gallery-contact-sheet.png)

Source basis:

- [publications/1991 mmath thesis final.pdf](/Users/stevenwoods/mmath-renovation/publications/1991%20mmath%20thesis%20final.pdf)
- [docs/hanoi-publication-alignment.md](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [docs/historical-validation-matrix.md](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [docs/tweak-vs-abtweak-comparison.md](/Users/stevenwoods/mmath-renovation/docs/tweak-vs-abtweak-comparison.md)

Interpretation:

- Figures 8 and 9 currently use the nearest regenerated Hanoi publication-alignment surfaces.
- Figure 10 uses the exact-or-qualitative publication-match matrix for the original three-disk Hanoi rows.
- Figure 11 uses the current reproduced robot-domain claim surface.
- Figures 1 to 7 are inventoried but not yet all mapped into maintained
  side-by-side panels.

These are intended to be maintained artifacts, not one-off exports.

Regenerate with:

```sh
python3 /Users/stevenwoods/mmath-renovation/scripts/generate-thesis-side-by-side.py
```
