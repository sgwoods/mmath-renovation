# Hanoi-4 Frontier Quality

This note records the next step in the `hanoi-4` diagnosis: comparing the
frontier ranking with the number of unresolved user/precondition obligations in
the current best `ismb` run.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4 trace workflow](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)

## Probe Setup

The new trace was taken with the current strongest bounded `hanoi-4`
configuration:

- planner mode: `abtweak`
- hierarchy: `*ismb*`
- `:mp-mode t`
- `:left-wedge-mode t`
- `:abstract-goal-mode t`
- `:heuristic-mode 'num-of-unsat-goals`
- expand bound: `20000`

Trace directory:

- [hanoi4-ismb-mp-t-lw-t-drp-nil-20260316-132943](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-ismb-mp-t-lw-t-drp-nil-20260316-132943)

## Main Findings

### 1. The best-ranked frontier nodes are not the closest to closure

The trace ended with:

- `4227` open nodes
- priority buckets:
  - `1280` nodes at priority `8`
  - `2924` nodes at priority `9`
  - `23` nodes at priority `10`

But the best unsatisfied-precondition count in the entire frontier was only
`2`, and that node was not in the best priority bucket.

The strongest low-unsat node found was:

- priority `9`
- plan cost `7`
- `kval 2`
- plan length `9`
- unsatisfied-pair count `2`

By contrast, the top priority-`8` nodes were typically:

- plan cost `15`
- `kval 0`
- plan length `17`
- unsatisfied-pair counts between about `9` and `17`

So the frontier is currently preferring more concrete, solution-shaped move
skeletons even when they still carry far more open obligations than some
higher-priority alternatives deeper up the abstraction hierarchy.

### 2. The current signal is “concreteness first,” not “closure first”

The highest-ranked nodes are mostly the same kind of state we saw in the
earlier manual forensics:

- `kval 0`
- cost around the expected 15-move Hanoi solution
- repeated `(ISPEG $var)`-style unresolved preconditions
- many remaining necessary obligations

That makes the current search behavior more specific than before:

- AbTweak is successfully generating plausible concrete move skeletons
- but the active ranking is not strongly favoring the states that are closest
  to satisfying all remaining necessary conditions

### 3. The best low-unsat nodes are still abstract

The best-closure nodes in the frontier are not final concrete plans. They are
still at higher abstraction levels such as `kval 2` and `kval 1`.

That means the current restored system is not simply “missing” good frontier
states. It is generating them, but it is not preferring them strongly enough
against the flood of more concrete partial plans.

## Current Conclusion

The new frontier-quality evidence strengthens the `hanoi-4` diagnosis:

- the remaining gap is not well explained by a bad top-level control setting
- it is also not well explained by a broken establisher or binding path
- the stronger current explanation is that the ranking function is
  overvaluing concretized move skeletons relative to closure quality

That makes the next best `hanoi-4` work more focused:

1. compare this frontier-quality pattern with `tweak` on the same benchmark
2. inspect whether the left-wedge term or the current heuristic should be
   augmented by an unsatisfied-pair signal for diagnostic purposes
3. keep the existing historical algorithm intact while using these reports to
   isolate where the restored ranking diverges from the historically stronger
   behavior
