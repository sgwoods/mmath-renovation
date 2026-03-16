# Hanoi-3 Versus Hanoi-4

This note compares why `hanoi-3` works under the restored planner while
`hanoi-4` remains bounded, using both the default abstraction hierarchy and the
stronger `ismb` family.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Hanoi-4b frontier comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-frontier-comparison.md)

## Structural Difference In The Domains

The domain files already show the first important difference:

- [hanoi-3.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-3.lisp#L1)
- [hanoi-4.lisp](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1)

`hanoi-4` is not just `hanoi-3` plus one more goal literal. It adds:

1. a fourth operator, `moveh`
2. a fourth goal literal, `(onh peg3)`
3. a new family of late concrete preconditions:
   - `(not onb $x)` / `(not onb $y)`
   - `(not onm $x)` / `(not onm $y)`
   - `(not ons $x)` / `(not ons $y)`

So the extra disk adds both depth and a bigger concrete clearing burden at the
bottom of the hierarchy.

## Comparison 1: Default Hierarchy

Traces:

- `hanoi-3`: [hanoi3-abtweak-critical-list-1-mp-t-lw-t-drp-nil-20260316-155044](/Users/stevenwoods/mmath-renovation/analysis/hanoi3-traces/hanoi3-abtweak-critical-list-1-mp-t-lw-t-drp-nil-20260316-155044)
- `hanoi-4`: [hanoi4-abtweak-critical-list-1-mp-t-lw-t-drp-nil-20260316-155051](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-critical-list-1-mp-t-lw-t-drp-nil-20260316-155051)

Summary:

| Case | Outcome | Expanded | Generated | Open length | Abs node count | Abs branching counts |
| --- | --- | --- | --- | --- | --- | --- |
| `hanoi-3`, `critical-list-1` | solves | `57` | `99` | `42` | `3` | `#(0 1 1 1)` |
| `hanoi-4`, `critical-list-1` | bounded failure | `20001` | `35175` | `15174` | `230` | `#(0 217 11 1 1)` |

This is the clearest "why `hanoi-3` works and `hanoi-4` does not" result in
the current repo.

With the same top-down default hierarchy:

- `hanoi-3` barely branches abstractly at all
- `hanoi-4` explodes at the abstraction levels before it ever converges

So one important answer is simply:

- the default hierarchy scales badly from three disks to four
- the failure is not subtle there
- the extra disk turns a tiny abstract search into a very wide one

## Comparison 2: The `ismb` Family

Traces:

- `hanoi-3`: [hanoi3-abtweak-ismb-mp-t-lw-t-drp-nil-20260316-155004](/Users/stevenwoods/mmath-renovation/analysis/hanoi3-traces/hanoi3-abtweak-ismb-mp-t-lw-t-drp-nil-20260316-155004)
- `hanoi-4`: [hanoi4-abtweak-ismb-mp-t-lw-t-drp-nil-20260316-153531](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-ismb-mp-t-lw-t-drp-nil-20260316-153531)

Summary:

| Case | Outcome | Expanded | Generated | MP pruned | Open length | Abs node count | Abs branching counts |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `hanoi-3`, `ismb` | bounded failure | `20001` | `23778` | `23190` | `3777` | `16` | `#(0 9 6 1)` |
| `hanoi-4`, `ismb` | bounded failure | `20001` | `24228` | `22746` | `4227` | `16` | `#(0 9 6 1)` |

This is the surprising result.

Under `ismb`, `hanoi-3` does not cleanly solve either at the same 20k budget.
The hierarchy skeleton looks almost identical in the two runs:

- nearly the same generated nodes
- nearly the same MP pruning
- exactly the same abstract branching counts

So the current `ismb` story is not:

- "`hanoi-3` works but `hanoi-4` breaks"

It is:

- `ismb` already has a ranking problem on the smaller Hanoi benchmark
- `hanoi-4` makes that same problem more expensive

## Frontier Quality Under `ismb`

Top-ranked `ismb` frontier nodes:

| Case | Typical top cost | Typical top length | Typical top unsat count |
| --- | --- | --- | --- |
| `hanoi-3` | `15` | `17` | about `7` to `11` |
| `hanoi-4` | `15` | `17` | about `9` to `17` |

That means the extra disk is not changing the general shape of the bad `ismb`
ranking. The planner is overconcretizing in both cases.

What the extra disk does is make each such concrete skeleton harder to finish:

- more unresolved obligations remain on the frontier nodes
- the omitted `onh` family falls to criticality `0`
- the new `moveh` operator only becomes usable after clearing three smaller
  disks on both source and destination pegs

So the same kind of overconcretized frontier state is materially worse in
`hanoi-4` than in `hanoi-3`.

## Current Interpretation

There are really two different explanations, depending on which hierarchy we
mean.

### If We Mean The Default Hierarchy

Then the answer is:

- `hanoi-3` works because the default hierarchy stays tiny
- `hanoi-4` fails because the same hierarchy blows up abstract branching

### If We Mean The Stronger `ismb` Family

Then the answer is:

- `ismb` is not actually a cleanly solved hierarchy family on `hanoi-3` at the
  same trace budget
- it already overconcretizes and produces move-skeleton-heavy frontier states
- `hanoi-4` inherits that same ranking pattern, but the added `onh` / `moveh`
  burden makes those states much harder to close

## Bottom Line

The repo now supports a more precise answer than before:

1. `hanoi-4` is not failing for a single reason.
2. Under the default hierarchy, it is mostly an abstract branching explosion.
3. Under `ismb`, it is more a closure burden problem on top of an already weak
   ranking pattern.
4. So the "why does `hanoi-3` work?" answer depends on which hierarchy family
   we are comparing against.

## Recommended Next Step

The best next follow-up is:

1. keep `ismb` as the main high-performance `hanoi-4` target
2. keep `isbm` as the better ranking-quality comparison hierarchy
3. investigate whether the stronger `ismb` pruning can be combined with the
   cleaner `isbm` frontier behavior
