# Hanoi-4 Publication To Code Mapping

This note makes the four-disk Hanoi hierarchy story explicit.

The main point is simple:

- the published Hanoi figure rows map exactly onto the three-disk family
- the shipped four-disk benchmark is a later extension
- so the four-disk families should be treated as closest historical analogues,
  not as exact publication row names

It complements:

- [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [Hanoi-4 strategy crosswalk](/Users/stevenwoods/mmath-renovation/docs/hanoi4-strategy-crosswalk.md)
- [Hanoi-4 successful combination hypothesis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-successful-combination-hypothesis.md)
- [Hanoi tree-ordering evidence](/Users/stevenwoods/mmath-renovation/docs/hanoi-tree-ordering-evidence.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Naming Convention

The publication prose uses `L`, `M`, and `S` for the three movable disk-size
families.

The local code uses:

- `B` where the publications say `L`
- `M` where the publications say `M`
- `S` where the publications say `S`

So the publication hierarchy label `ILMS` corresponds directly to the code
label `IBMS` in the restored three-disk family.

The four-disk domain adds:

- `H` for the largest disk family

That is why the four-disk mapping has to be stated as an analogue instead of a
direct row name.

## Exact Three-Disk Mapping

These mappings are now exact and reproduced in the restored code line.

| Publication label | Restored three-disk code label | Status |
| --- | --- | --- |
| `ILMS` | `IBMS` | exact |
| `IMLS` | `IMBS` | exact |
| `ILSM` | `IBSM` | exact |
| `IMSL` | `IMSB` | exact |
| `ISLM` | `ISBM` | exact |
| `ISML` | `ISMB` | exact |

This exact figure-level reproduction is documented in
[Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md).

## Four-Disk Family Types

The current four-disk code exposes three different kinds of hierarchy family in
[hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1):

1. Default top-down extensions
   - `critical-list-1`
   - `legacy-1991-default`

2. Permutation-style extensions of the published three-disk family
   - `ismb`
   - `imbs`
   - `ibsm`
   - `isbm`

3. Positive/negative criticality experiments
   - `critical-list-2`

Those families do not mean the same thing historically:

- `critical-list-1` is the closest 1993 default extension of the old top-down
  `IBMS` family
- `legacy-1991-default` is the closest recovered older four-disk default, where
  `ispeg` and `onh` share the top level
- the permutation-style four-disk families are the cleanest local way to carry
  the old three-disk ordering ideas into four-disk space
- `critical-list-2` is not a simple permutation family at all

## Closest Four-Disk Analogues

The table below is the practical crosswalk to use when discussing `hanoi-4`.

| Publication family | Exact three-disk code family | Closest four-disk analogue | Confidence | Why |
| --- | --- | --- | --- | --- |
| `ILMS` | `IBMS` | `critical-list-1` | medium | top-down default extension with `H > B > M > S` and explicit four-level stack |
| `IMLS` | `IMBS` | `imbs` | medium | direct permutation-style extension of the `IMBS` ordering, with omitted `H` falling to crit `0` |
| `ILSM` | `IBSM` | `ibsm` | medium | direct permutation-style extension of the `IBSM` ordering, again with omitted `H` falling to crit `0` |
| `IMSL` | `IMSB` | no active exact analogue | low | the exact `imsb` four-disk variant is not currently exposed in the shipped working four-disk family |
| `ISLM` | `ISBM` | `isbm` | medium | direct permutation-style extension of the `ISBM` ordering |
| `ISML` | `ISMB` | `ismb` | medium | direct permutation-style extension of the `ISMB` ordering |

Important caveat:

- the permutation-style four-disk analogues omit `onh`
- by historical `find-crit` behavior, omitted predicates fall to criticality
  `0`
- so these are historically plausible extensions, not publication-exact labels

## Where The Current Families Fit

### `critical-list-1`

This is best read as the later 1993 default family:

- `I`
- then `H`
- then `B`
- then `M`
- then `S`

So it is closest to an `IHBMS` extension of publication `ILMS` / code `IBMS`.

### `legacy-1991-default`

This is the closest older four-disk default we have recovered:

- `I` and `H` share the top level
- then `B`
- then `M`
- then `S`

It is historically important, but it is better treated as an archived default
surface than as the direct analogue of any one published good hierarchy row.

### `ismb`, `imbs`, `ibsm`, `isbm`

These are the most useful local analogues for extending the published
three-disk permutation family into four-disk space.

They preserve the relative ordering of the lower three disk families while
allowing `H` to remain concrete.

That makes them the best current bridge between:

- exact publication-side three-disk hierarchy labels
- and the later shipped four-disk benchmark

### `critical-list-2`

This should not be treated as the code equivalent of `ILMS`, `IMLS`, `ISML`,
or any other publication permutation label.

It is better read as a separate thesis-era positive/negative criticality-label
experiment family.

That is why it can still be historically interesting without being the direct
answer to the publication-label mapping problem.

## Current Best Read

The current evidence now supports this interpretation:

1. Exact publication alignment is already achieved on the three-disk family.
2. The four-disk mapping must therefore be expressed by analogue, not by exact
   row identity.
3. The best current analogue families for the published permutation rows are:
   - `imbs`
   - `ibsm`
   - `isbm`
   - `ismb`
4. The best current analogue for the later default top-down family is
   `critical-list-1`, with `legacy-1991-default` as the older grouped-top
   variant.
5. `critical-list-2` remains historically relevant, but it belongs to a
   different family of control experiments.

## What This Changes In Practice

When discussing `hanoi-4` from here:

- do say that `isbm` is the strongest current historical-control runtime path
- do say that `ismb` is the strongest current 1993-style path
- do say that `critical-list-1` and `legacy-1991-default` are the closest
  default-family extensions
- do not say that any current four-disk family is an exact publication row
  match
- do not treat `critical-list-2` as if it were simply another permutation label

That keeps the restored baseline historically careful while still giving us a
usable four-disk comparison vocabulary.
