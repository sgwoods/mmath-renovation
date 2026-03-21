# Hanoi-4 Five-Peg Sanity Check

This note records a retained diagnostic variant of the `hanoi-4` benchmark:
the same four-disk transfer, but with two extra empty pegs added to the initial
world.

It is not a historical publication benchmark. It is a quality check that helps
separate:

- "the planner cannot handle four disks at all"
- from
- "the classic three-peg `hanoi-4` case is specifically stressing the current
  abstraction and control behavior"

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Hanoi search baselines](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/README.md)

## Variant Definition

Starting from the normal [hanoi-4 domain](/Users/stevenwoods/mmath-renovation/working/abtweak-1993/Domains/hanoi-4.lisp#L1),
the retained five-peg variant leaves the goal unchanged but appends two empty
pegs to the initial state:

```lisp
((ispeg peg4) (ispeg peg5)
 (not onh peg4) (not onh peg5)
 (not onb peg4) (not onb peg5)
 (not onm peg4) (not onm peg5)
 (not ons peg4) (not ons peg5))
```

So the task is still "move all four disks from `peg1` to `peg3`", but now the
planner has five pegs available instead of three.

## Current Retained Results

All three retained modes solve comfortably at the standard exploratory bounds:

| Case | Expanded | Generated | MP pruned | Outcome | Plan |
| --- | ---: | ---: | ---: | --- | --- |
| `hanoi4-5peg-tweak` | `1528` | `2816` | n/a | solves | cost `7`, length `9`, `kval 0` |
| `hanoi4-5peg-abtweak` | `36` | `66` | `0` | solves | cost `7`, length `9`, `kval 0` |
| `hanoi4-5peg-isbm-weak-pos-lw` | `3086` | `4526` | `1099` | solves | cost `7`, length `9`, `kval 0` |

## Representative Solution Shape

The retained five-peg solution is the expected relaxed transfer:

1. move `S` to `peg2`
2. move `M` to `peg4`
3. move `B` to `peg5`
4. move `H` to `peg3`
5. move `B` to `peg3`
6. move `M` to `peg3`
7. move `S` to `peg3`

That is a seven-move transfer, which is exactly what we would expect once two
additional temporary pegs are available.

## Why This Matters

This is a useful sanity reminder for the main `hanoi-4` investigation:

- the restored planner can handle a four-disk Hanoi transfer
- plain `abtweak` is actually very strong on this easier geometry
- the hard part is specifically the classic three-peg `hanoi-4` case
- that strengthens the interpretation that the open problem is about
  abstraction and control behavior under tight resource constraints, not about
  four disks in the abstract

## Reproducible Commands

```sh
sh /Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi4-5peg-tweak
sh /Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi4-5peg-abtweak
sh /Users/stevenwoods/mmath-renovation/scripts/smoke-abtweak-1993-sbcl.sh hanoi4-5peg-isbm-weak-pos-lw
```
