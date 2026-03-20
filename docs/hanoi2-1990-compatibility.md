# Hanoi-2 1990 Compatibility Layer

This note records the current two-disk Hanoi compatibility surface recovered
from the early AbTweak trees.

The goal here is narrower than the `hanoi-3` publication-alignment work:

1. restore the archived `hanoi-2` hierarchy family into the active SBCL tree
2. preserve the historical hierarchy names and their batch-output mapping
3. verify whether the recovered counts match the archived outputs exactly

## Source Surface

The active restored domain is:

- [working/abtweak-1993/Domains/hanoi-2.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-2.lisp#L1)

The historical compatibility wrapper is:

- [working/abtweak-1993/historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1)

The main archival sources are:

- [historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi-2.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi-2.lsp#L1)
- [historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi2/load-tests.lsp](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi2/load-tests.lsp#L1)
- [historical/Abtweak/Abtweak-1990-12b/Planner/Batcher/hanoi2](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1990-12b/Planner/Batcher/hanoi2)

## Restored Hierarchy Mapping

The archival `load-tests.lsp` mapping is:

| Archived run | Restored hierarchy symbol | Archived output |
| --- | --- | --- |
| `crit1` | `ibs` | `crit1-raw.out` |
| `crit2` | `sib` | `crit2-raw.out` |
| `crit3` | `bsi` | `crit3-raw.out` |
| `crit4` | `bis` | `crit4-raw.out` |
| `crit5` | `sbi` | `crit5-raw.out` |
| `crit6` | `isb` | `crit6-raw.out` |

Those hierarchy symbols and their left-wedge analogues are now preserved in
the active working-tree domain.

## Current Rerun Surface

Single-case smoke runs:

- `run hanoi2-tweak`
- `run hanoi2-abtweak`

Historical family report:

- `report hanoi2-historical`

All are exposed through:

- [scripts/abtweak-experiments.sh](/Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh#L1)

## Verified Results

The active SBCL restoration now exactly matches the archived expanded and
generated counts for all six recovered hierarchy variants.

| Hierarchy | Outcome | Current expanded | Current generated | Archived expanded | Archived generated | Archived abstract generated |
| --- | --- | --- | --- | --- | --- | --- |
| `ibs` | solves | `11` | `19` | `11` | `19` | `2` |
| `sib` | solves | `25` | `47` | `25` | `47` | `4` |
| `bsi` | solves | `11` | `20` | `11` | `20` | `2` |
| `bis` | solves | `11` | `19` | `11` | `19` | `2` |
| `sbi` | solves | `23` | `46` | `23` | `46` | `3` |
| `isb` | solves | `24` | `46` | `24` | `46` | `3` |

The default restored smoke path also behaves as expected:

- `hanoi2-tweak`: solves with cost `3`, plan length `5`, `kval 0`
- `hanoi2-abtweak`: solves with cost `3`, plan length `5`, `kval 0`

## Interpretation

`hanoi-2` is now best treated as an `Exact` archived-family rerun, even though
it is not one of the main later publication benchmark tables.

That gives the repo a cleaner Hanoi ladder:

1. `hanoi-2`: exact early archived-family reproduction
2. `hanoi-3`: exact publication-aligned reproduction
3. `hanoi-4`: historically grounded extension benchmark, still the main open case

## Recommended Use

`hanoi-2` should now be used as:

- a very fast historical regression for the Hanoi compatibility layer
- a sanity check on hierarchy mapping and archived batch-output reproduction
- a compact complement to the richer `hanoi-3` publication family
