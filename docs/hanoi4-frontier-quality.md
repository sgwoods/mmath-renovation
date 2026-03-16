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

### 5. The AbTweak score breakdown points straight at left-wedge plus goal-only heuristic

The traced score components make the ranking effect more concrete.

For the strongest top-ranked `abtweak` nodes:

- search cost: `15`
- base goal heuristic: `0`
- left-wedge adjustment: `-7`
- resulting heuristic component: `-7`
- final priority: `8`

Those are the concrete `kval 0`, length-`17` move skeletons that still carry
roughly `9` to `17` unsatisfied user/precondition pairs.

By contrast, the best closure-oriented `abtweak` node has:

- search cost: `7`
- base goal heuristic: `3`
- left-wedge adjustment: `-1`
- resulting heuristic component: `2`
- final priority: `9`

So the cleaner node loses even though it has only `2` unsatisfied pairs,
because:

1. the base heuristic only counts unsatisfied goal literals on `G`
2. it does not count the broader unresolved user/precondition obligations
3. left-wedge gives the concrete `kval 0` nodes a strong `-7` bonus

That means the current bad ranking is not mysterious. It follows directly from
the present score formula:

- `priority = search-cost + num-of-unsat-goals + left-wedge-adjustment`

and in this case the left-wedge reward for concreteness is strong enough to
outweigh closure quality.

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
- the immediate numeric explanation is now visible in the traces:
  - the base heuristic only sees unsatisfied goal literals
  - left-wedge gives `kval 0` nodes a strong negative bonus
  - unresolved non-goal obligations are currently invisible to the score

That makes the next best `hanoi-4` work more focused:

1. inspect whether this left-wedge-dominated ranking is historically intended
   for Hanoi-4, or whether the restored search is applying the score in a way
   that differs from the original experimental setup
2. inspect whether the left-wedge term or the current heuristic should be
   augmented by an unsatisfied-pair signal for diagnostic purposes
3. keep the existing historical algorithm intact while using these reports to
   isolate where the restored ranking diverges from the historically stronger
   behavior

## Weak-POS Follow-Up

The latest follow-up traces compare the two most interesting four-disk
hierarchies under the historical weak-`POS` control vocabulary, with
left-wedge disabled to isolate the weak-MSP effect:

- [hanoi4-abtweak-ismb-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-nil-drp-nil-20260316-173414](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-ismb-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-nil-drp-nil-20260316-173414)
- [hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-nil-drp-nil-20260316-173414](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-nil-drp-nil-20260316-173414)

The split is now quite clear.

For `ismb` weak-`POS`:

- `24568` generated
- `27007` MP pruned
- `4567` open nodes
- top priority buckets: `2416` nodes at `16`, `2151` at `17`
- best unsatisfied-pair count in OPEN: `2`
- but the top-ranked nodes are still mostly:
  - `kval 0`
  - plan cost `15` to `16`
  - plan length `17` to `18`
  - unsatisfied-pair counts around `11` to `16`

For `isbm` weak-`POS`:

- `24748` generated
- `21293` MP pruned
- `4747` open nodes
- top priority buckets: `1680` nodes at `14`, `2963` at `15`, `104` at `16`
- best unsatisfied-pair count in OPEN: `2`
- and the top-ranked nodes are much cleaner:
  - usually unsatisfied-pair counts around `3` to `6`
  - many top states remain at `kval 1`
  - the best-closure node with unsatisfied count `2` is still in the top bucket

So weak-`POS` changes the four-disk story in a very specific way:

1. `ismb` still wins slightly on raw generated-node count.
2. `isbm` wins decisively on frontier quality.
3. under weak-`POS`, the earlier AbTweak “good node demoted behind concrete
   skeletons” problem is much less severe for `isbm` than for `ismb`.

That means the live tradeoff is now explicit:

- `ismb`: stronger pruning, dirtier frontier
- `isbm`: weaker pruning, cleaner frontier

The next meaningful question is whether we can borrow `isbm`'s cleaner weak-`POS`
ranking behavior without giving up too much of `ismb`'s pruning strength.
