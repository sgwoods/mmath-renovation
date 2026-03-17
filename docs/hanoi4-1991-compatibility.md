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
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh report hanoi4-historical
```

## Current Result

At the standard 20k expansion bound, the current four-disk historical-control
comparison looks like this:

| Hierarchy | MSP | Weak Mode | Crit-Depth | Current SBCL |
| --- | --- | --- | --- | --- |
| `legacy-1991-default` | `nil` | `nec` | `nil` | `20001 / 35214`, `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | `weak` | `nec` | `nil` | `20001 / 35214`, `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | `weak` | `pos` | `nil` | `20001 / 35214`, `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | `nil` | `nec` | `t` | `20001 / 37046`, `EXPAND-LIMIT-EXCEEDED` |
| `ismb` | `weak` | `nec` | `nil` | `20001 / 24565`, `EXPAND-LIMIT-EXCEEDED` |
| `ismb` | `weak` | `pos` | `nil` | `20001 / 24568`, `EXPAND-LIMIT-EXCEEDED` |
| `ismb` | `nil` | `nec` | `t` | `20001 / 38142`, `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `weak` | `nec` | `nil` | `20001 / 26264`, `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `weak` | `pos` | `nil` | `20001 / 24748`, `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `nil` | `nec` | `t` | `20001 / 36898`, `EXPAND-LIMIT-EXCEEDED` |

The immediate takeaway is that the archived 1991 four-disk default hierarchy is
not the strongest current path. Even before solving `hanoi-4`, the current
port's `ismb` and `isbm` families are already generating substantially fewer
nodes than the older `legacy-1991-default` baseline.

The more specific takeaway is:

1. `ismb` still has the best raw bounded behavior in this historical-control
   comparison.
2. weak-`POS` helps `isbm` materially more than it helps `ismb`:
   `26264` down to `24748` generated for `isbm`, versus essentially no change
   for `ismb` (`24565` to `24568`).
3. crit-depth remains clearly worse than weak MSP for both `ismb` and `isbm`.

## Deeper Weak-POS Follow-Up

The new harness-native trace presets make it easier to compare the two most
interesting historical-control paths directly:

```sh
EXPAND_BOUND=50000 GENERATE_BOUND=200000 OPEN_BOUND=200000 CPU_SEC_LIMIT=30 \
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-ismb-weak-pos --json

EXPAND_BOUND=50000 GENERATE_BOUND=200000 OPEN_BOUND=200000 CPU_SEC_LIMIT=30 \
  sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos --json
```

At deeper bounds, the story changes in a useful way:

| Hierarchy | Bound | Expanded | Generated | MP Pruned | Open length | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
| `ismb`, weak-`POS` | `20000` | `20001` | `24568` | `27007` | `4567` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS` | `20000` | `20001` | `24748` | `21293` | `4747` | `EXPAND-LIMIT-EXCEEDED` |
| `ismb`, weak-`POS` | `50000` | `50001` | `61943` | `68448` | `11942` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS` | `50000` | `50001` | `61605` | `54586` | `11604` | `EXPAND-LIMIT-EXCEEDED` |
| `ismb`, weak-`POS` | `100000` | `100001` | `125029` | `139321` | `25028` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS` | `100000` | `100001` | `123240` | `111179` | `23239` | `EXPAND-LIMIT-EXCEEDED` |

So the live scaling picture is now:

1. `ismb` is slightly better at the original 20k comparison point.
2. `isbm` catches up by 50k and is slightly ahead on raw generated nodes.
3. that advantage is still present at 100k.
4. `isbm` keeps the cleaner frontier while doing so.

That is a stronger result than the earlier 20k-only comparison, because it
shows the `isbm` weak-`POS` path is not just "cleaner but a little slower."
At deeper bounds it is now the better historical-control path on both
frontier quality and raw generated-node count.

## Left-Wedge Return On The Stronger Path

Once `isbm` weak-`POS` emerged as the better deep-bound historical-control
path, the next question was whether re-enabling Left-Wedge would help or hurt.

Using the harness-native preset:

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/abtweak-experiments.sh trace hanoi4-isbm-weak-pos-lw
```

the current result is clearly positive:

| Config | Bound | Expanded | Generated | MP Pruned | Open length | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
| `isbm`, weak-`POS`, no left-wedge | `20000` | `20001` | `24748` | `21293` | `4747` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS`, left-wedge | `20000` | `20001` | `23272` | `21286` | `3271` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS`, no left-wedge | `50000` | `50001` | `61605` | `54586` | `11604` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS`, left-wedge | `50000` | `50001` | `58817` | `54466` | `8816` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS`, no left-wedge | `100000` | `100001` | `123240` | `111179` | `23239` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS`, left-wedge | `100000` | `100001` | `116646` | `110674` | `16645` | `EXPAND-LIMIT-EXCEEDED` |
| `isbm`, weak-`POS`, left-wedge | `200000` | `200001` | `234872` | `224678` | `34871` | `EXPAND-LIMIT-EXCEEDED` |

This makes `isbm` weak-`POS` plus Left-Wedge the strongest current `hanoi-4`
historical-control path in the restored environment.

## Current Interpretation

This is still a starting point, not a finished historical reproduction story.
Unlike `hanoi-3`, the archived repository currently does not give us the same
rich set of checked-in four-disk result files to match against directly. The
main immediate value is:

1. making the older control vocabulary runnable on the restored four-disk case
2. separating "1993 hierarchy tuning" from "1991 control-family comparison"
3. giving the ongoing `hanoi-4` investigation one more historically grounded
   baseline
4. showing that the main remaining four-disk tradeoff has sharpened:
   `ismb` still prunes more aggressively, but `isbm` weak-`POS` now scales
   better overall at the deeper tested bounds, and adding Left-Wedge improves
   that stronger path further
