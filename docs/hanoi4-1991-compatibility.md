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
- `msp-mode` = `nil`, `weak`, or `strong`
- `msp-weak-mode` = `nec` or `pos`
- `crit-depth-mode`
- `determine-mode` = `stack` or `tree`, restored as an optional historical
  compatibility control rather than a 1993 default

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
| `isbm-h1` | `weak` | `pos` | `nil` | `20001 / 26535`, `EXPAND-LIMIT-EXCEEDED` |
| `isbm-hb` | `weak` | `pos` | `nil` | `20001 / 26479`, `EXPAND-LIMIT-EXCEEDED` |
| `imbs-h1` | `weak` | `pos` | `nil` | `20001 / 24132`, `EXPAND-LIMIT-EXCEEDED` |
| `imbs-hb` | `weak` | `pos` | `nil` | `20001 / 26598`, `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `nil` | `nec` | `t` | `20001 / 36898`, `EXPAND-LIMIT-EXCEEDED` |
| `isbm` | `strong` | `nec` | `nil` | `20001 / 26264`, `EXPAND-LIMIT-EXCEEDED` |

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
3. the first explicit-`H` analogue on the `ISBM` side, `isbm-h1`, now runs correctly but is not
   an improvement at the same bound:
   `26535` generated under weak-`POS` versus `24748` for `isbm`.
4. the grouped-`H` follow-up, `isbm-hb`, is also runnable after a small
   grouped-level bookkeeping fix, but it also underperforms `isbm`:
   `26479` generated under weak-`POS` versus `24748` for `isbm`.
5. the first explicit-`H` analogue on the `IMBS` side, `imbs-h1`, is much
   stronger:
   `24132` generated under weak-`POS` versus `33992` for plain `imbs`, and
   slightly better than `isbm` on the same no-Left-Wedge weak-`POS` line
   (`24132` versus `24748`).
6. the grouped `IMBS` follow-up, `imbs-hb`, still improves plain `imbs`, but
   loses most of the gain that `imbs-h1` found:
   `26598` generated under weak-`POS` versus `33992` for plain `imbs`.
7. `strong` MSP is now restored and, on representative `isbm`, currently
   matches the weak-`NEC` expanded/generated counts while shifting the pruning
   attribution from `mp-pruned` to `strong-mp-pruned`.
8. crit-depth remains clearly worse than weak MSP for both `ismb` and `isbm`.
9. the conservative default-family follow-up `critical-list-1h-lite` is also
   now tested and is not an improvement:
   `35217` generated under weak-`POS` without Left-Wedge,
   `36982` with Left-Wedge, and `0` MP prunes in both runs.
10. the first grouped-top legacy-family follow-up `legacy-1991-isbm` is now
    also tested and is a genuine improvement over `legacy-1991-default`, but
    not over `isbm`:
    `32845` generated under weak-`POS` without Left-Wedge,
    `26215` with Left-Wedge, `28349` under tree plus Left-Wedge at 20k, and
    `66327` at the 50k stack plus Left-Wedge bound.

The report script now also exposes `Determine` and `Left-Wedge` columns, so it
can include representative non-default rows such as the restored tree-ordering
comparison:

- `isbm`, weak-`POS`, `tree`, `left-wedge t`:
  `20001 / 27373`, `EXPAND-LIMIT-EXCEEDED`

## Wider Determine-Mode Family Sweep

The historical-control report now also includes a broader weak-`POS` plus
Left-Wedge determine-mode sweep across the recovered four-disk hierarchy
families.

At the standard 20k bound:

| Hierarchy | Stack | Tree | Better at 20k |
| --- | --- | --- | --- |
| `legacy-1991-default` | `20001 / 37046` | `20001 / 36727` | `tree` |
| `critical-list-1` | `20001 / 35175` | `20001 / 36274` | `stack` |
| `critical-list-2` | `20001 / 31080` | `20001 / 29744` | `tree` |
| `ismb` | `20001 / 23623` | `20001 / 27013` | `stack` |
| `isbm` | `20001 / 23272` | `20001 / 27373` | `stack` |
| `isbm-h1` | `20001 / 25259` | `-` | `stack` |
| `isbm-hb` | `20001 / 24745` | `-` | `stack` |
| `imbs-h1` | `20001 / 23810` | `-` | `stack` |
| `imbs-hb` | `20001 / 33415` | `-` | `stack` |
| `ibsm` | `20001 / 27277` | `20001 / 29709` | `stack` |
| `imbs` | `20001 / 34067` | `20001 / 36002` | `stack` |

That changes the earlier reading of tree goal ordering in an important way.
The restored tree path is not uniformly worse on `hanoi-4`. At the standard
20k bound it helps `legacy-1991-default` and `critical-list-2`, while clearly
hurting the later permutation-style families such as `ismb`, `isbm`, `ibsm`,
and `imbs`.

The explicit-`H` analogue results are useful too:

- `isbm-h1` is runnable and historically plausible, but weaker than `isbm`
  with and without Left-Wedge
- `isbm-hb` becomes runnable once grouped-level hierarchies are sized by max
  criticality rather than by raw critical-list length, but it is still weaker
  than `isbm` with and without Left-Wedge
- `imbs-h1` is the first explicit-`H` analogue that materially improves its
  parent family:
  - no Left-Wedge: `24132` versus `33992` for plain `imbs`
  - with Left-Wedge: `23810` versus `34067` for plain `imbs`
  - it also slightly beats `isbm` on the no-Left-Wedge weak-`POS` line, while
    still trailing `isbm + weak-POS + Left-Wedge`
- the deeper Left-Wedge follow-up now answers the live question about whether
  `imbs-h1` becomes the better solver candidate once the stronger historical
  control path returns:
  - at `50000`, `imbs-h1` still fails and trails `isbm`
    (`60971` versus `58817` generated)
  - at `100000`, it still trails `isbm`
    (`121223` versus `116646` generated)
  - at `200000`, it exhausts the default 1 GiB SBCL heap in MP checking
  - rerun with `--dynamic-space-size 2048`, it still reaches only
    `EXPAND-LIMIT-EXCEEDED` at `241472` generated
  - so `imbs-h1` is useful diagnostically, but it is not the new main
    `hanoi-4` solving path
- `imbs-hb` confirms that this is not just "add `H` anywhere" on the `IMBS`
  side:
  - no Left-Wedge: `26598` versus `24132` for `imbs-h1`
  - with Left-Wedge: `33415` versus `23810` for `imbs-h1`
  - so grouping `H` with `B` largely gives away the `imbs-h1` advantage

The first deeper follow-ups make that result more specific rather than more
general:

| Hierarchy | MSP | Determine | Expanded | Generated | MP Pruned | Outcome |
| --- | --- | --- | --- | --- | --- | --- |
| `legacy-1991-default` | weak-`NEC` | `stack` | `50001` | `91819` | `0` | `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | weak-`NEC` | `tree` | `50001` | `93361` | `0` | `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | weak-`POS` | `stack` | `50001` | `91819` | `0` | `EXPAND-LIMIT-EXCEEDED` |
| `legacy-1991-default` | weak-`POS` | `tree` | `50001` | `93361` | `0` | `EXPAND-LIMIT-EXCEEDED` |
| `critical-list-2` | weak-`NEC` | `stack` | `50001` | `82501` | `20721` | `EXPAND-LIMIT-EXCEEDED` |
| `critical-list-2` | weak-`NEC` | `tree` | `50001` | `82569` | `21789` | `EXPAND-LIMIT-EXCEEDED` |
| `critical-list-2` | weak-`POS` | `stack` | `50001` | `77708` | `25536` | `EXPAND-LIMIT-EXCEEDED` |
| `critical-list-2` | weak-`POS` | `tree` | `50001` | `77587` | `17109` | `EXPAND-LIMIT-EXCEEDED` |

So tree ordering is now better understood as a hierarchy-and-control-sensitive
historical option rather than a globally inferior one. The more precise live
question is no longer "does tree help `isbm`?" or even "does tree help old
hierarchies?" It is whether tree was historically meant to pair with a
specific control family like `critical-list-2` plus weak-`POS`, rather than
with the default legacy hierarchy or the later permutation-style families.

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

## Tree Goal Ordering Follow-Up

Tree goal ordering is no longer blocked. The working compatibility layer now
restores the needed plan-tree support, tree helpers, and `determine-mode tree`
selection path as an explicitly optional historical control.

Representative direct checks now show:

- `hanoi-3`, `isbm`, weak-`NEC`, no Left-Wedge:
  - `stack`: `1083 / 1433`
  - `tree`: `2630 / 3779`
- `hanoi-4`, `isbm`, weak-`POS`, Left-Wedge:
  - `stack`: `20001 / 23272`, `EXPAND-LIMIT-EXCEEDED`
  - `tree`: `20001 / 27373`, `EXPAND-LIMIT-EXCEEDED`

So tree ordering is now a live historical comparison surface, but it is not
currently improving the representative `isbm` runs. That makes it useful for
fidelity checking, not yet for promoting a new main `hanoi-4` path.

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
5. showing that restored tree ordering is hierarchy-family-sensitive on
   `hanoi-4`, helping some older/default-style families while hurting the
   later permutation-style ones
