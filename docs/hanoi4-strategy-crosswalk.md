# Hanoi-4 Strategy Crosswalk

This document consolidates the current `hanoi-4` strategy story into one place.

It answers three questions:

1. Which `hanoi-4` strategy families were actually claimed in the publication
   set?
2. Which strategy and control surfaces are supported in the historical and
   current code lines?
3. How do the current measured strategies compare numerically?

It is meant to be maintained as the project evolves.

It complements:

- [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
- [Hanoi-4 publication to code mapping](/Users/stevenwoods/mmath-renovation/docs/hanoi4-publication-to-code-mapping.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 hierarchy comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-comparison.md)
- [Hanoi-4 1991 compatibility start](/Users/stevenwoods/mmath-renovation/docs/hanoi4-1991-compatibility.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)
- [Left-Wedge intent comparison](/Users/stevenwoods/mmath-renovation/docs/left-wedge-intent-comparison.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/standard-transfer.md)

Maintained data file:

- [analysis/hanoi4-strategy-performance.csv](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-strategy-performance.csv)
- [analysis/hanoi4-scaling-strategies.svg](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.svg)
- [analysis/hanoi4-scaling-strategies.png](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.png)

## Reading Guide

Important scope note:

- the exact published numeric Hanoi figure rows we can now reproduce are for
  the original three-disk predicate family in
  [hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1)
- the shipped four-disk benchmark in
  [hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1)
  adds `onh` / `moveh`, so it is best treated as a later historically grounded
  extension rather than as a direct figure-for-figure publication rerun
- see [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
  for the exact reproduction surface
- see [Hanoi-4 publication to code mapping](/Users/stevenwoods/mmath-renovation/docs/hanoi4-publication-to-code-mapping.md)
  for the exact three-disk to four-disk analogue map

This crosswalk uses three evidence labels:

- `Specific`: a strategy/result family is explicitly reported in the papers or
  thesis as part of the Hanoi evaluation story
- `Qualitative`: the publications clearly discuss the strategy family, but the
  exact local `hanoi-4` digits are not yet transcribed into the repo
- `Code-only`: the strategy exists in the historical code or compatibility
  surface, but not as a clearly isolated publication-facing `hanoi-4` result

## A. Publication-Facing Hanoi-4 Strategy Families

| Strategy family | Publication evidence | What the publication set says | Local status |
| --- | --- | --- | --- |
| `tweak` baseline | `Specific` | Tweak is the main non-abstract baseline for Hanoi. The publications treat it as a real comparator, not a straw man. The repo already records that the thesis/report present good-hierarchy AbTweak variants as better than Tweak, and bad hierarchy settings as potentially worse. | Supported historically and currently. Current restored `tweak` still fails on shipped `hanoi-4` at the tested bounds. |
| Breadth-first `abtweak` without monotonic pruning | `Specific` | The publication story explicitly includes abstract planning without the stronger pruning/control help, and warns that abstraction is not always superior to Tweak. | Supported historically and currently. Current poor/default hierarchy runs match the “can be worse than Tweak” story qualitatively. |
| `abtweak` with monotonic-property pruning on good hierarchies | `Specific` | The papers and thesis present MP/P-WMP as the main way AbTweak becomes stronger on good hierarchies. | Supported historically and currently. Current `critical-list-2` and `ismb` runs now show the expected direction of improvement. |
| `abtweak` with Left-Wedge on good hierarchies | `Specific` | Left-Wedge is explicitly described as a completeness-preserving control strategy that can dramatically improve search on good hierarchies and can hurt on poor ones. | Supported historically and currently. Current `hanoi-4` traces show the intended refinement pressure, but the full problem still does not close. |
| Good versus bad hierarchy families | `Specific` | The publication set treats hierarchy quality as central. The report/thesis discussion clearly distinguishes good Hanoi hierarchy families from poor ones and says the outcome can reverse depending on that choice. | Partially mapped. The exact three-disk publication rows are aligned, and the new four-disk mapping note now distinguishes exact row matches from closest local analogues such as `critical-list-1`, `legacy-1991-default`, `ismb`, and `isbm`. |
| Weak MSP variants such as weak-`NEC` and weak-`POS` | `Code-only` for `hanoi-4` | These are part of the 1991 experiment vocabulary we recovered, but we do not yet have them tied to a clearly isolated publication-side `hanoi-4` table in the checked-in docs. | Supported through the 1991 compatibility layer and now central to the strongest current `hanoi-4` path. |
| `crit-depth` mode | `Code-only` for `hanoi-4` | Recovered from the 1991 experimental framework. Historically meaningful, but not yet isolated as a publication-side `hanoi-4` claim in the checked-in notes. | Supported through the compatibility layer. Current `hanoi-4` results make it look weaker than weak MSP. |

## B. Strategy Surface By Effort Period

| Strategy or control surface | Publications | 1990-era code line | 1991 experiment line | 1993 shipped line | Current restored line | Reference framework |
| --- | --- | --- | --- | --- | --- | --- |
| `tweak` breadth-first baseline | yes | yes | yes | yes | yes | analogous only |
| Plain `abtweak` breadth-first abstraction | yes | yes | yes | yes | yes | no |
| Boolean `mp-mode` style monotonic pruning | yes | partial | yes | yes | yes | no |
| Weak MSP, weak-`NEC`, weak-`POS` | partial | no clear evidence | yes | no direct surface | yes via compatibility wrapper | no |
| `crit-depth-mode` | partial | no clear evidence | yes | no direct surface | yes via compatibility wrapper | no |
| Left-Wedge lists and scoring | yes | yes | yes | yes | yes | no |
| Hierarchy permutations such as `ISMB`, `ISBM`, `IMBS`, `IBSM` | yes | partial | yes | partial | yes | no |
| Positive/negative criticality-label families (`critical-list-2` style) | yes | unknown | yes | yes | yes | no |
| DRP path | no clear publication-facing `hanoi-4` claim | no clear evidence | partial | yes | yes | no |
| DFS control strategy | partial | partial | yes | yes | yes, diagnostic only | yes |
| Plain graph-search BFS | no | no | no | no | no | yes |
| Plain graph-search DFS | no | no | no | no | no | yes |
| Plain graph-search A* | no | no | no | no | no | yes |

## C. Current Numeric Strategy Table

The most comparable current partial-plan runs are the standard `20000`
expansion-bound results.

| Strategy | Family | Budget | Generated | Outcome | Notes |
| --- | --- | --- | --- | --- | --- |
| `tweak` BFS | 1993/current baseline | `20000` | `34234` | `EXPAND-LIMIT-EXCEEDED` | main non-abstract comparator |
| `legacy-1991-default` + weak-`NEC` | 1991 compatibility | `20000` | `35214` | `EXPAND-LIMIT-EXCEEDED` | recovered older four-disk default |
| `legacy-1991-default` + weak-`POS` | 1991 compatibility | `20000` | `35214` | `EXPAND-LIMIT-EXCEEDED` | same as weak-`NEC` at this bound |
| `legacy-1991-default` + `crit-depth` | 1991 compatibility | `20000` | `37046` | `EXPAND-LIMIT-EXCEEDED` | clearly weaker |
| `critical-list-1` + MP + Left-Wedge | 1993/current hierarchy | `20000` | `35175` | `EXPAND-LIMIT-EXCEEDED` | poor/default hierarchy behavior |
| `critical-list-2` + MP + Left-Wedge | 1993/current hierarchy | `20000` | `32461` | `EXPAND-LIMIT-EXCEEDED` | first clear better-than-Tweak hierarchy |
| `critical-list-2` + no MP + Left-Wedge | 1993/current hierarchy | `20000` | `38621` | `EXPAND-LIMIT-EXCEEDED` | shows MP matters here |
| `ismb` + MP + Left-Wedge | 1993/current hierarchy | `20000` | `24228` | `EXPAND-LIMIT-EXCEEDED` | strongest current 1993-style hierarchy result |
| `ismb` + no MP + Left-Wedge | 1993/current hierarchy | `20000` | `38610` | `EXPAND-LIMIT-EXCEEDED` | dramatic regression without MP |
| `ismb` + weak-`NEC` | 1991 compatibility | `20000` | `24565` | `EXPAND-LIMIT-EXCEEDED` | close to the 1993-style `ismb` MP path |
| `ismb` + weak-`POS` | 1991 compatibility | `20000` | `24568` | `EXPAND-LIMIT-EXCEEDED` | almost identical to weak-`NEC` here |
| `isbm` + weak-`NEC` | 1991 compatibility | `20000` | `26264` | `EXPAND-LIMIT-EXCEEDED` | weaker than `ismb` on raw count |
| `isbm` + weak-`POS` | 1991 compatibility | `20000` | `24748` | `EXPAND-LIMIT-EXCEEDED` | cleaner frontier than `ismb` |
| `isbm` + weak-`POS` + Left-Wedge | 1991 compatibility | `20000` | `23272` | `EXPAND-LIMIT-EXCEEDED` | strongest current historical-control path |

### Deeper Scaling For The Strongest Historical-Control Families

| Strategy | `20000` | `50000` | `100000` | `200000` |
| --- | --- | --- | --- | --- |
| `ismb` + weak-`POS` | `24568` | `61943` | `125029` | `-` |
| `isbm` + weak-`POS` | `24748` | `61605` | `123240` | `-` |
| `isbm` + weak-`POS` + Left-Wedge | `23272` | `58817` | `116646` | `234872` |

### Reference State-Space Baselines

These are not directly comparable to the least-commitment partial-plan counts
above, but they are useful sanity checks because they solve the same standard
three-peg four-disk transfer problem.

| Strategy | Generated | Solved | Depth |
| --- | --- | --- | --- |
| Reference BFS | `209` | yes | `15` |
| Reference DFS | `199` | yes | `27` |
| Reference A* | `158` | yes | `15` |

## D. Performance Graphs

Checked-in graphic:

- [Hanoi-4 scaling graphic note](/Users/stevenwoods/mmath-renovation/docs/hanoi4-scaling-graphic.md)
- [analysis/hanoi4-scaling-strategies.svg](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.svg)
- [analysis/hanoi4-scaling-strategies.png](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-scaling-strategies.png)

These are shown as simple horizontal bar graphs so they stay readable in plain
Markdown and terminal views.

### Comparable Current Partial-Plan Strategies At The Standard 20k Bound

Scale: longest bar in this graph is `38621` generated nodes.

```text
ISBM + weak-POS + Left-Wedge   23272 | ########################
ISMB + MP + Left-Wedge         24228 | #########################
ISMB + weak-POS                24568 | #########################
ISBM + weak-POS                24748 | ##########################
ISBM + weak-NEC                26264 | ###########################
Critical-list-2 + MP + LW      32461 | ##################################
Tweak BFS baseline             34234 | ####################################
Legacy 1991 default + weak-POS 35214 | #####################################
Legacy 1991 default + weak-NEC 35214 | #####################################
Critical-list-1 + MP + LW      35175 | #####################################
Legacy 1991 default + crit     37046 | #######################################
Critical-list-2 + no MP + LW   38621 | ########################################
```

Lower is better here.

### Strongest Historical-Control Families Across Larger Bounds

Scale: longest bar in this graph is `234872` generated nodes.

```text
20k  ISBM + weak-POS + LW  23272  | ####
20k  ISMB + weak-POS       24568  | ####
20k  ISBM + weak-POS       24748  | ####

50k  ISBM + weak-POS + LW  58817  | ##########
50k  ISBM + weak-POS       61605  | ##########
50k  ISMB + weak-POS       61943  | ###########

100k ISBM + weak-POS + LW 116646  | ####################
100k ISBM + weak-POS      123240  | #####################
100k ISMB + weak-POS      125029  | #####################

200k ISBM + weak-POS + LW 234872  | ########################################
```

This is the clearest current scaling picture:

- `ISBM + weak-POS + Left-Wedge` is the best measured path so far
- `ISBM + weak-POS` becomes slightly better than `ISMB + weak-POS` at deeper
  bounds
- none of these runs closes the full `hanoi-4` problem yet

### Reference State-Space Baselines

Scale: longest bar in this graph is `209` generated states.

```text
Reference A*   158 | ##############################
Reference DFS  199 | ######################################
Reference BFS  209 | ########################################
```

Lower is better here too, but this is a different search model from the
partial-plan runs above.

## E. What This Means Right Now

The cleanest current summary is:

1. `hanoi-4` is not hard in a generic state-space sense; the reference
   framework solves it comfortably.
2. In the restored planner, plain `tweak` is still a real baseline and is not
   obviously dominated by bad abstraction settings.
3. The strongest currently supported historical-control path is:
   `isbm` + weak-`POS` + Left-Wedge.
4. The strongest current 1993-style hierarchy result is:
   `ismb` + MP + Left-Wedge.
5. The old 1991 four-disk default hierarchy is not the strongest path in the
   recovered environment.
6. The publication story and the current measurements line up qualitatively:
   hierarchy quality and control choice matter a great deal.

## F. Open Follow-Up

The next most useful update to this document would be:

1. keep the exact publication-side alignment concentrated in
   [Hanoi publication alignment](/Users/stevenwoods/mmath-renovation/docs/hanoi-publication-alignment.md)
   and use this note for the four-disk extension story
2. add any newly measured strategy/control combinations to
   [analysis/hanoi4-strategy-performance.csv](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-strategy-performance.csv)
3. keep the `20000`-bound graph stable as the main like-for-like comparison
   surface
