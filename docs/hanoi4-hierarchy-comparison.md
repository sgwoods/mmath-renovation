# Hanoi-4 Hierarchy Comparison

This note records the first direct comparison of the historical `hanoi-4` hierarchy choices under the current SBCL working tree.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Algorithm correspondence review](/Users/stevenwoods/mmath-renovation/docs/algorithm-correspondence.md)
- [Historical validation matrix](/Users/stevenwoods/mmath-renovation/docs/historical-validation-matrix.md)

The runner for these results is [scripts/compare-hanoi4-hierarchies-sbcl.sh](/Users/stevenwoods/mmath-renovation/scripts/compare-hanoi4-hierarchies-sbcl.sh#L1).

## Setup

The comparison uses the historical hierarchy definitions from [working/abtweak-1993/Domains/hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1):

- `*critical-list-1*`
- `*critical-list-2*`
- `*ismb*`

Left-wedge setup:

- `critical-list-1` uses the domain default `*k-list-1*`
- `critical-list-2` uses the domain default `*k-list-2*`
- `ismb` has no dedicated left-wedge list in the domain file, so the comparison uses the four-level Hanoi list `(0 1 3 7)` as an explicit reconstruction assumption

## Standard 20k-Bound Comparison

Bounds:

- expand bound `20000`
- generate bound `80000`
- open bound `80000`
- CPU limit `30`

| Planner | Hierarchy | MP | Left-Wedge | Outcome | Expanded | Generated | MP Pruned |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `tweak` | `-` | `-` | `-` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `34234` | `-` |
| `abtweak` | `critical-list-1` | `t` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `35175` | `0` |
| `abtweak` | `critical-list-1` | `nil` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `35175` | `0` |
| `abtweak` | `critical-list-1` | `t` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `35212` | `0` |
| `abtweak` | `critical-list-1` | `nil` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `35212` | `0` |
| `abtweak` | `critical-list-2` | `t` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `32461` | `8957` |
| `abtweak` | `critical-list-2` | `nil` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `38621` | `0` |
| `abtweak` | `critical-list-2` | `t` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `35508` | `3139` |
| `abtweak` | `critical-list-2` | `nil` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `35752` | `0` |
| `abtweak` | `ismb` | `t` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `24228` | `22746` |
| `abtweak` | `ismb` | `nil` | `t` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `38610` | `0` |
| `abtweak` | `ismb` | `t` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `24565` | `22445` |
| `abtweak` | `ismb` | `nil` | `nil` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `38460` | `0` |

## High-Bound Follow-Up

Promising cases were rerun at:

- expand bound `100000`
- generate bound `400000`
- open bound `400000`
- CPU limit `90`

| Hierarchy | MP | Left-Wedge | Outcome | Expanded | Generated | MP Pruned | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `critical-list-2` | `t` | `t` | `EXPAND-LIMIT-EXCEEDED` | `100001` | `164967` | `42158` | stable |
| `critical-list-2` | `nil` | `t` | `EXPAND-LIMIT-EXCEEDED` | `100001` | `193697` | `0` | stable |
| `ismb` | `t` | `t` | `EXPAND-LIMIT-EXCEEDED` | `100001` | `121238` | `119916` | stable |
| `ismb` | `nil` | `t` | SBCL heap exhausted | `-` | `-` | `0` | failed near the 1 GiB default heap limit |

## What Changed In The Diagnosis

These results are the first clear sign that the restored planner can reproduce the qualitative hierarchy story from the historical work.

### Default Hierarchy Still Looks Poor

`critical-list-1` behaves like a poor hierarchy for `hanoi-4` in the current port:

- MP prunes nothing
- left-wedge barely changes anything
- AbTweak generates slightly more nodes than plain `tweak`

That matches the earlier concern that the default hierarchy was not producing the expected abstraction benefit.

### Alternative Hierarchies Behave Much Better

`critical-list-2` is already more plausible historically:

- with MP and left-wedge both enabled, it beats plain `tweak` at the same 20k bound
- disabling MP makes it noticeably worse
- disabling left-wedge also makes it worse

`ismb` is stronger still:

- with MP enabled, it is the best 20k-bound configuration tested so far
- it reduces generated nodes from `34234` in `tweak` to `24228`
- it prunes aggressively via MP
- at 100k, it remains the strongest stable configuration tested so far

### MP Matters Again

The original worry was that MP seemed irrelevant on `hanoi-4`. That is no longer true once the hierarchy changes.

At the same 20k bound:

- `critical-list-2` with MP generates `32461` nodes, without MP `38621`
- `ismb` with MP generates `24228` nodes, without MP `38610`

That is much closer to the published claim that MP helps on good hierarchies and can fail to help on poor ones.

### Left-Wedge Is Secondary Here, But Real

Left-wedge is not the main driver of improvement in these first hierarchy comparisons, but it is no longer inert:

- for `critical-list-2`, left-wedge improves generated nodes from `35508` to `32461`
- for `ismb`, left-wedge improves generated nodes from `24565` to `24228`

So left-wedge is directionally helpful on the better hierarchies, even though the effect is much smaller than the MP effect in these runs.

## Current Interpretation

The best current explanation for `hanoi-4` is now:

1. the default `critical-list-1` hierarchy is a poor match for the historically strong Hanoi behavior
2. the restored AbTweak implementation does show historically plausible MP-sensitive improvement once better hierarchies are used
3. the project is no longer blocked on “does hierarchy choice matter?” because the answer is clearly yes
4. the next challenge is turning the promising `critical-list-2` and `ismb` behavior into either
   - a full `hanoi-4` solution under higher or better-tuned bounds, or
   - a direct mapping from these tested hierarchies to the “good” and “bad” hierarchies discussed in the reports and thesis

## Recommended Follow-Up

1. Compare these three hierarchy definitions directly against the hierarchy descriptions and permutations in the thesis and technical report.
2. Add the hierarchy matrix to the historical validation story for Hanoi rather than treating `hanoi-4` as a single undifferentiated benchmark.
3. Revisit higher-bound runs with the promising hierarchies first, especially `ismb` with MP enabled and `critical-list-2` with MP enabled.
