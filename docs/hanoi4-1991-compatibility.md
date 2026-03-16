# Hanoi-4 1991 Compatibility Start

This note records the first repo-level compatibility wrapper for comparing the
older 1991-style Hanoi-4 controls against the working `Abtweak-1993` SBCL port.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-3 1991 compatibility layer](/Users/stevenwoods/mmath-renovation/docs/hanoi3-1991-compatibility.md)

## What Was Added

The working tree now exposes a small `historical-hanoi4-plan` wrapper in
[historical-hanoi-compat.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/historical-hanoi-compat.lisp#L1).

That wrapper currently supports:

- hierarchy selection
- `msp-mode` = `nil` or `weak`
- `msp-weak-mode` = `nec` or `pos`
- `crit-depth-mode`

It also reintroduces the archived 1991 four-disk default hierarchy in
[hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1):

- `legacy-1991-default`: `ispeg` and `onh` share the top abstraction level

That differs from the later 1993 default, where `ispeg` and `onh` are split
across separate levels.

## Why This Matters

Up to now, most of the live `hanoi-4` diagnosis has compared:

- the current 1993 default hierarchy family
- later permutation-style four-disk variants like `ismb`, `imbs`, `ibsm`, and `isbm`

That was useful, but it skipped the older four-disk baseline that appears in
the 1991 code line. This wrapper gives us a reproducible way to answer a more
specific question:

does the larger-case gap look different when we start from the archived 1991
Hanoi-4 hierarchy and control vocabulary instead of only the later 1993 ones?

## Reproducible Command

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-historical-controls-sbcl.sh
```

## Current Result

At the standard 20k expansion bound, the initial four-disk historical-control
comparison currently looks like this:

| Hierarchy | MSP | Weak Mode | Crit-Depth | Current SBCL |
| --- | --- | --- | --- | --- |
| `legacy-1991-default` | `nil` | `nec` | `nil` | `20001 / 35214`, `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | `weak` | `nec` | `nil` | `20001 / 35214`, `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | `weak` | `pos` | `nil` | `20001 / 35214`, `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | `nil` | `nec` | `t` | `20001 / 37046`, `EXPAND-LIMIT-EXCEEDED` |
| `ismb` | `weak` | `pos` | `nil` | `20001 / 24568`, `EXPAND-LIMIT-EXCEEDED` |

The immediate takeaway is that the archived 1991 four-disk default hierarchy is
not the strongest current path. Even before solving `hanoi-4`, the current
port's `ismb` family is already generating substantially fewer nodes than the
older `legacy-1991-default` baseline.

## Current Interpretation

This is still a starting point, not a finished historical reproduction story.
Unlike `hanoi-3`, the archived repository currently does not give us the same
rich set of checked-in four-disk result files to match against directly. The
main immediate value is:

1. making the older control vocabulary runnable on the restored four-disk case
2. separating "1993 hierarchy tuning" from "1991 control-family comparison"
3. giving the ongoing `hanoi-4` investigation one more historically grounded
   baseline
