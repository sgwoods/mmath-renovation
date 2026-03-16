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
- `msp-mode` = `nil` or `weak`
- `msp-weak-mode` = `nec` or `pos`
- `crit-depth-mode`

It does not yet implement historical `strong` MSP.

## Current Result

The first comparison set is aimed at the previously strongest correspondence
cases:

- `isbm`, weak `NEC`, no critical-depth
- `imbs`, weak `NEC`, no critical-depth
- `isbm`, no MSP, critical-depth
- `ibsm`, no MSP, critical-depth
- `ismb`, no MSP, critical-depth

These are the cases where the restored SBCL port was already closest to the
archived 1991 outputs.

Current representative results:

| Hierarchy | MSP | Weak Mode | Crit-Depth | Current SBCL | Historical |
| --- | --- | --- | --- | --- | --- |
| `isbm` | `weak` | `nec` | `nil` | `1083 / 1433` | `1083 / 1433` |
| `imbs` | `weak` | `nec` | `nil` | `166 / 233` | `166 / 233` |
| `imbs` | `weak` | `pos` | `nil` | `149 / 206` | `149 / 206` |
| `isbm` | `nil` | `nec` | `t` | `168 / 284` | `168 / 284` |
| `ibsm` | `nil` | `nec` | `t` | `828 / 1471` | `828 / 1471` |
| `ismb` | `nil` | `nec` | `t` | `963 / 1771` | `963 / 1771` |

Those cases now match the archived 1991 results exactly at the expanded /
generated level, including one verified weak-`POS` case.

The comparison can be rerun with:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-historical-controls-sbcl.sh
```

## Interpretation

This compatibility layer narrows the remaining historical-validation gap in two
ways:

1. it makes the old control vocabulary explicit in the current working tree
2. it separates "1993 baseline behavior" from "1991 experiment emulation"

That gives us a cleaner path for future comparisons, especially if we decide to
extend the same compatibility surface to larger Hanoi cases and to more of the
weak-`POS` families later.
