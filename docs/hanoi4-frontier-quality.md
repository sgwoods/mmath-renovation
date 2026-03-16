# Hanoi-4 Frontier Quality

This note records the next step in the `hanoi-4` diagnosis: comparing frontier
ranking with the number of unresolved user/precondition obligations in both the
current best `abtweak` `ismb` run and a matching `tweak` run.

It complements:

- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)
- [Hanoi-4 frontier forensics](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-forensics.md)
- [Hanoi-4 control comparison](/Users/stevenwoods/mmath-renovation/docs/hanoi4-control-comparison.md)
- [Hanoi-4 trace workflow](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/README.md)

## Probe Setup

The first trace was taken with the current strongest bounded `hanoi-4`
AbTweak configuration:

- planner mode: `abtweak`
- hierarchy: `*ismb*`
- `:mp-mode t`
- `:left-wedge-mode t`
- `:abstract-goal-mode t`
- `:heuristic-mode 'num-of-unsat-goals`
- expand bound: `20000`

Trace directory:

- [hanoi4-ismb-mp-t-lw-t-drp-nil-20260316-132943](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-ismb-mp-t-lw-t-drp-nil-20260316-132943)

The second trace used the same bound budget under plain `tweak`:

- planner mode: `tweak`
- hierarchy inputs left at `*ismb*` for direct comparability, though they do not
  drive abstraction behavior in the same way
- expand bound: `20000`

Trace directory:

- [hanoi4-tweak-ismb-mp-t-lw-t-drp-nil-20260316-134400](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-tweak-ismb-mp-t-lw-t-drp-nil-20260316-134400)

## Main Findings

### 1. In `abtweak`, the best-ranked frontier nodes are not the closest to closure

The `abtweak` trace ended with:

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

### 2. The `abtweak` signal is “concreteness first,” not “closure first”

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

### 3. The best low-unsat `abtweak` nodes are still abstract

The best-closure nodes in the frontier are not final concrete plans. They are
still at higher abstraction levels such as `kval 2` and `kval 1`.

That means the current restored system is not simply “missing” good frontier
states. It is generating them, but it is not preferring them strongly enough
against the flood of more concrete partial plans.

### 4. `tweak` shows a different frontier-quality pattern

The matching `tweak` trace ended with:

- `14233` open nodes
- priority buckets:
  - `8981` nodes at priority `11`
  - `4900` nodes at priority `12`
  - `352` nodes at priority `13`
- best unsatisfied-pair count in the frontier: `5`

The important contrast is not that `tweak` is closer to a solution. It is not.
Its best low-unsat nodes still have `5` unsatisfied pairs, worse than
`abtweak`'s best `2`.

The important difference is ranking:

- in `tweak`, the best-closure nodes remain in the top priority bucket
- those nodes are still concrete `kval 0` plans, usually cost `9` to `10`,
  length `11` to `12`
- the top-priority `tweak` nodes and the best-unsat `tweak` nodes are drawn
  from the same search bucket rather than being separated by priority

So the larger plain-Tweak frontier still looks like an ordinary bounded search.
The frontier-quality mismatch is more specific to the abstraction-side ranking
in the restored `abtweak` path.

## Side-By-Side Summary

| Planner mode | Open nodes | Best unsat count | Top priority bucket | Best-closure node location | Main pattern |
| --- | --- | --- | --- | --- | --- |
| `abtweak` | `4227` | `2` | priority `8` | worse bucket: priority `9` | cleaner states exist, but ranking prefers more concrete move skeletons |
| `tweak` | `14233` | `5` | priority `11` | same top bucket: priority `11` | broader frontier, but no comparable bucket-separation effect |

## Current Conclusion

The new frontier-quality evidence strengthens the `hanoi-4` diagnosis:

- the remaining gap is not well explained by a bad top-level control setting
- it is also not well explained by a broken establisher or binding path
- the stronger current explanation is that the `abtweak` ranking function is
  overvaluing concretized move skeletons relative to closure quality
- the matching `tweak` trace makes this more specific:
  - the issue is not just that `hanoi-4` is hard
  - it is that the restored abstraction path appears to demote some of its best
    closure-oriented states behind more concrete partial plans

That makes the next best `hanoi-4` work more focused:

1. inspect which part of the `abtweak` ranking stack is pushing those better
   closure states behind the concrete `kval 0` bucket
2. inspect whether the left-wedge term or the current heuristic should be
   augmented by an unsatisfied-pair signal for diagnostic purposes
3. keep the existing historical algorithm intact while using these reports to
   isolate where the restored ranking diverges from the historically stronger
   behavior
