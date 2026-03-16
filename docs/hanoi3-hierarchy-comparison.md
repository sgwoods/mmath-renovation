# Hanoi-3 Hierarchy Comparison

This note records the current `hanoi-3` hierarchy matrix in the SBCL working
port, using the historically relevant variation families now restored into the
active domain.

It complements:

- [Hanoi-3 versus Hanoi-4](/Users/stevenwoods/mmath-renovation/docs/hanoi3-vs-hanoi4.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

## Supported Current Variants

The active three-disk domain now exposes:

- `*critical-list-1*`
- `*critical-list-2*`
- `*ismb*`
- `*imbs*`
- `*ibsm*`
- `*isbm*`

in [hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1).

That is closer to the historically reported experiment space in
[historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Domains/hanoi3).

## Current SBCL Results

All runs below use:

- planner mode `abtweak`
- expand bound `20000`
- generate bound `80000`
- open bound `80000`
- CPU limit `30`

### Baseline

| Planner | Outcome | Expanded | Generated |
| --- | --- | --- | --- |
| `tweak` | solves | `379` | `632` |

### AbTweak Hierarchy Matrix

| Hierarchy | MP | Left-Wedge | Outcome | Expanded | Generated | MP pruned |
| --- | --- | --- | --- | --- | --- | --- |
| `critical-list-1` | `t` | `t` | solves | `57` | `99` | `0` |
| `critical-list-1` | `nil` | `t` | solves | `57` | `99` | `0` |
| `critical-list-1` | `t` | `nil` | solves | `471` | `794` | `0` |
| `critical-list-1` | `nil` | `nil` | solves | `471` | `794` | `0` |
| `critical-list-2` | `t` | `t` | solves | `75` | `119` | `9` |
| `critical-list-2` | `nil` | `t` | solves | `81` | `135` | `0` |
| `critical-list-2` | `t` | `nil` | solves | `270` | `399` | `66` |
| `critical-list-2` | `nil` | `nil` | solves | `480` | `800` | `0` |
| `ismb` | `t` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `23778` | `23190` |
| `ismb` | `nil` | `t` | solves | `963` | `1771` | `0` |
| `ismb` | `t` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `24790` | `23298` |
| `ismb` | `nil` | `nil` | solves | `3142` | `6171` | `0` |
| `imbs` | `t` | `t` | solves | `86` | `129` | `16` |
| `imbs` | `nil` | `t` | solves | `1009` | `1811` | `0` |
| `imbs` | `t` | `nil` | solves | `166` | `233` | `65` |
| `imbs` | `nil` | `nil` | solves | `550` | `934` | `0` |
| `ibsm` | `t` | `t` | solves | `608` | `808` | `408` |
| `ibsm` | `nil` | `t` | solves | `828` | `1471` | `0` |
| `ibsm` | `t` | `nil` | solves | `765` | `1205` | `172` |
| `ibsm` | `nil` | `nil` | solves | `1112` | `1973` | `0` |
| `isbm` | `t` | `t` | solves | `6879` | `8836` | `5398` |
| `isbm` | `nil` | `t` | solves | `168` | `284` | `0` |
| `isbm` | `t` | `nil` | solves | `1083` | `1433` | `800` |
| `isbm` | `nil` | `nil` | solves | `1771` | `3142` | `0` |

## What Currently Works Best

The strongest current `hanoi-3` strategies are:

1. `critical-list-1` with or without MP, and with Left-Wedge on
2. `critical-list-2` with MP and Left-Wedge on
3. `imbs` with MP and Left-Wedge on

Those all solve far below the plain `tweak` baseline.

## Most Important Current Surprises

### 1. `ismb` is not healthy in the current `hanoi-3` port when MP is on

With MP and Left-Wedge both enabled, `ismb` does not solve `hanoi-3` at all at
the 20k bound. That is the biggest mismatch between the restored current port
and the intuitive "strong Hanoi hierarchy" story.

But disabling MP immediately makes it solve:

- `ismb`, MP off, LW on: `963` expanded, `1771` generated

So the current issue is not that `ismb` is a dead hierarchy in general. It is
that the current `ismb` plus MP path is behaving poorly on `hanoi-3`.

### 2. `isbm` has a strong no-MP result but a weak MP-on result

`isbm` also behaves very asymmetrically:

- MP on, LW on: `6879` expanded, `8836` generated
- MP off, LW on: `168` expanded, `284` generated

So for `hanoi-3`, MP is not uniformly helping all historically plausible
hierarchies in the current port.

### 3. Left-Wedge still matters a lot on the good hierarchies

Examples:

- `critical-list-1`: `57` expanded with LW on vs `471` with LW off
- `critical-list-2`: `75` expanded with LW on vs `270` with LW off
- `imbs`: `86` expanded with LW on vs `166` with LW off

That part matches the historical picture much better.

## Relation To The Archived Results

The archival `hanoi3` result files already showed that multiple hierarchy
families could work well, not just one.

Examples from
[historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results](/Users/stevenwoods/mmath-renovation/historical/Abtweak/Abtweak-1991-08/Planner/Batcher/hanoi3/Save/Results):

- `imbs2-raw.out`: `149` expanded, `206` generated
- `isbmK-raw.out`: `168` expanded, `284` generated
- `ibsmK-raw.out`: `828` expanded, `1471` generated
- `ismbK-raw.out`: `963` expanded, `1771` generated

That archive lines up surprisingly well with some of the current no-MP or
alternate-control results:

- current `isbm`, MP off, LW on: `168` / `284`
- current `ibsm`, MP off, LW on: `828` / `1471`
- current `ismb`, MP off, LW on: `963` / `1771`

So the restored port is now much closer to the historically reported variation
support, even though the MP-on behavior of some hierarchies still looks off.

## Current Takeaway

The current restored `hanoi-3` story is:

1. the historically relevant hierarchy family is now mostly supported directly
   in the active domain
2. several hierarchy strategies work well
3. `critical-list-1` is still the best current practical default
4. `imbs` is the strongest restored permutation-style hierarchy with MP and
   Left-Wedge both enabled
5. `ismb` and `isbm` look much more historically plausible when MP is off than
   when it is on

## Reproducibility

The full matrix can now be rerun via
[compare-hanoi3-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-hierarchies-sbcl.sh#L1):

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/compare-hanoi3-hierarchies-sbcl.sh
```
