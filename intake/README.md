# Intake

This directory is the single landing zone for newly found relevant material
before it is integrated into the rest of the repository.

Use it for:

- newly found historical source trees
- newly found publications or scans
- newly found experiment logs or data dumps
- newly found notes, screenshots, or metadata that may affect provenance or
  validation

## Intake Rule

When new material appears, place it in `intake/` first rather than putting it
directly into:

- [working](/Users/stevenwoods/mmath-renovation/working)
- [historical](/Users/stevenwoods/mmath-renovation/historical)
- [publications](/Users/stevenwoods/mmath-renovation/publications)
- [analysis](/Users/stevenwoods/mmath-renovation/analysis)

That gives the repository one clear review point for:

1. provenance
2. duplication or redundancy
3. likely long-term home
4. whether the material should be integrated, preserved as reference, or
   marked redundant

## Review Outcomes

After review, material should be moved out of `intake/` into one of these
outcomes:

- `working/` for active restored system artifacts
- `historical/` for frozen archival provenance or separate historical systems
- `publications/` for papers, reports, manuals, and primary source documents
- `analysis/` for generated outputs or numeric datasets
- or documented as redundant/provenance-only if it should stay preserved but
  not treated as a go-forward source base

## Guidance

- Keep the original names when possible so provenance stays traceable.
- Do not treat the presence of a file in `intake/` as evidence that it belongs
  in the main restored baseline.
- If `intake/` is non-empty, that should be treated as "new material pending
  review."

For the repository-level semantic map, see:

- [docs/repository-coverage-matrix.md](/Users/stevenwoods/mmath-renovation/docs/repository-coverage-matrix.md)
- [docs/repository-structure-review.md](/Users/stevenwoods/mmath-renovation/docs/repository-structure-review.md)
