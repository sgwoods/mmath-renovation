# Hanoi-3 1991 Compatibility Layer

This note records the first compatibility layer for reproducing the older 1991
Hanoi experiment families on top of the working `Abtweak-1993` SBCL port.

It complements:

- [Hanoi-3 MSP correspondence](/Users/stevenwoods/mmath-renovation/docs/hanoi3-msp-correspondence.md)
- [Hanoi-3 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi3-hierarchy-comparison.md)

## What Was Added

The working tree now exposes:

- explicit `:mp-weak-mode` support in [plan.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/plan.lisp#L5)
- weak-`NEC` versus weak-`POS` branching in [ab-mp-check.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Ab-routines/ab-mp-check.lisp#L1)
- a small historical wrapper in [historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1)
- a reproducible comparison runner in [compare-hanoi3-historical-controls-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-historical-controls-sbcl.sh#L1)

The compatibility wrapper currently supports the 1991-style controls that are
most relevant to the published and archived Hanoi runs:

- hierarchy selection
- `msp-mode` = `nil`, `weak`, or `strong`
- `msp-weak-mode` = `nec` or `pos`
- `crit-depth-mode`
- `determine-mode` = `stack` or `tree`, restored as an optional 1991-era
  compatibility control rather than a 1993 default

## Current Result

The comparison set now includes both the originally strongest correspondence
cases and a wider weak-`POS` family recovered from the archived 1991 batch
files.

Current representative results:

| Hierarchy | MSP | Weak Mode | Crit-Depth | Current SBCL | Historical |
| --- | --- | --- | --- | --- | --- |
| `isbm` | `weak` | `nec` | `nil` | `1083 / 1433` | `1083 / 1433` |
| `imbs` | `weak` | `nec` | `nil` | `166 / 233` | `166 / 233` |
| `imbs` | `weak` | `pos` | `nil` | `149 / 206` | `149 / 206` |
| `sbim` | `weak` | `pos` | `nil` | `332 / 490` | `332 / 490` |
| `sbmi` | `weak` | `pos` | `nil` | `573 / 1071` | `573 / 1071` |
| `simb` | `weak` | `pos` | `nil` | `785 / 995` | `785 / 995` |
| `sibm` | `weak` | `pos` | `nil` | `482 / 620` | `482 / 620` |
| `smib` | `weak` | `pos` | `nil` | `899 / 1236` | `899 / 1236` |
| `misb` | `weak` | `pos` | `nil` | `682 / 1040` | `682 / 1040` |
| `isbm` | `nil` | `nec` | `t` | `168 / 284` | `168 / 284` |
| `ibsm` | `nil` | `nec` | `t` | `828 / 1471` | `828 / 1471` |
| `ismb` | `nil` | `nec` | `t` | `963 / 1771` | `963 / 1771` |
| `isbm` | `strong` | `nec` | `nil` | `1083 / 1433` | no isolated archived row yet |
| `isbm`, `tree` | `weak` | `nec` | `nil` | `2630 / 3779` | no isolated archived row yet |

Those cases now match the archived 1991 results exactly at the expanded /
generated level across both weak-`NEC` and a broader weak-`POS` slice.

The exact publication-side Hanoi alignment is now even stronger as well:

- the original thesis figure rows for `IBMS`, `IMBS`, `IBSM`, `IMSB`, `ISBM`,
  and `ISMB` are now compared directly in
  [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- `IMSB` is now restored as a named active hierarchy in the working tree, and
  its thesis rows (`918`, `636`, `5170`, `2672`) now reproduce exactly too

The first restored `strong` MSP check is also informative:

- on representative `hanoi-3` `isbm`, `strong` currently produces the same
  expanded/generated counts as weak-`NEC`
- the difference is visible in pruning attribution instead:
  `strong-mp-pruned = 800`, `mp-pruned = 0`
- that is historically plausible and gives us a live restored `strong` mode
  for future comparisons, even though we do not yet have a clean archived row
  isolated specifically for that control

The comparison can be rerun with:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-historical-controls-sbcl.sh
```

## Interpretation

This compatibility layer narrows the remaining historical-validation gap in two
ways:

1. it makes the old control vocabulary explicit in the current working tree
2. it separates "1993 baseline behavior" from "1991 experiment emulation"

That gives us a cleaner path for future comparisons, especially as we begin
extending the same compatibility surface to `hanoi-4`.

One boundary is clearer now too:

- the older Hanoi experiment line also used tree-style goal ordering
- that control is now runnable again in the working compatibility layer
- on the representative `isbm` weak-`NEC` case, `stack` still beats `tree`
  (`1083 / 1433` versus `2630 / 3779`)
- so tree ordering is now best treated as a recovered historical comparison
  mode, not as a candidate default replacement for the restored 1993 baseline
