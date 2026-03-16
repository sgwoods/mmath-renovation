# Hanoi-4b Frontier Comparison

This note compares the frontier quality of the current best `hanoi-4`
hierarchy, `ismb`, against the strongest alternate "Hanoi-4b" candidate,
`isbm`.

It complements:

- [Hanoi-4 frontier quality](/Users/stevenwoods/mmath-renovation/docs/hanoi4-frontier-quality.md)
- [Hanoi-4b candidate hierarchies](/Users/stevenwoods/mmath-renovation/docs/hanoi4b-candidate-hierarchies.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Probe Setup

Both traces used:

- planner mode: `abtweak`
- `:mp-mode t`
- `:left-wedge-mode t`
- expand bound: `20000`
- generate bound: `80000`
- open bound: `80000`
- CPU limit: `30`

Trace directories:

- `ismb`: [hanoi4-abtweak-ismb-mp-t-lw-t-drp-nil-20260316-153531](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-ismb-mp-t-lw-t-drp-nil-20260316-153531)
- `isbm`: [hanoi4-abtweak-isbm-mp-t-lw-t-drp-nil-20260316-153615](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-mp-t-lw-t-drp-nil-20260316-153615)

## Summary Table

| Hierarchy | Generated | MP pruned | Open nodes | Top bucket | Best unsat count |
| --- | --- | --- | --- | --- | --- |
| `ismb` | `24228` | `22746` | `4227` | `1280` nodes at priority `8` | `2` |
| `isbm` | `25235` | `18434` | `5234` | `4695` nodes at priority `8` | `2` |

So `ismb` is still better on raw search reduction, while `isbm` retains a
larger frontier and gets less help from MP.

## Main Findings

### 1. `isbm` ranks cleaner top-bucket states than `ismb`

The highest-ranked `ismb` nodes are still the same problematic pattern seen
earlier:

- priority `8`
- cost `15`
- `kval 0`
- plan length `17`
- unsatisfied-pair counts mostly between `9` and `17`

The highest-ranked `isbm` nodes look much cleaner:

- priority `8`
- cost `13` to `14`
- `kval 0`
- plan length `15` to `16`
- unsatisfied-pair counts mostly between `6` and `9`

That means `isbm` is doing a better job of keeping relatively closure-oriented
states in the best priority bucket.

### 2. `isbm` eliminates the clearest bucket-separation problem

Under `ismb`, the best closure-oriented node in the frontier has:

- unsatisfied-pair count `2`
- priority `9`
- `kval 2`
- plan cost `7`

So the best unsatisfied node is not in the top bucket.

Under `isbm`, the best closure-oriented node has:

- unsatisfied-pair count `2`
- priority `8`
- `kval 2`
- plan cost `6`

So the best unsatisfied node remains in the top bucket.

This is a real improvement in ranking quality. It means `isbm` behaves more
like the earlier `tweak` comparison, where the best-closure nodes did not get
demoted behind worse concrete skeletons.

### 3. Better ranking does not automatically mean less search

Even though `isbm` ranks closure better, it still loses to `ismb` on total
generated nodes and on MP pruning:

- `ismb`: `24228` generated, `22746` MP pruned
- `isbm`: `25235` generated, `18434` MP pruned

So the current picture is:

- `isbm` appears better at frontier prioritization
- `ismb` appears better at global search reduction

That is the most useful distinction to carry forward.

## Interpretation

This changes the role of `isbm`.

Earlier, the natural question was "can we find a hierarchy that simply beats
`ismb`?"

The current answer is more nuanced:

1. `ismb` is still the best practical hierarchy for raw bounded performance.
2. `isbm` is the better diagnostic hierarchy for ranking quality.
3. The remaining `hanoi-4` problem may therefore split into two subproblems:
   - pruning and hierarchy effectiveness, where `ismb` is stronger
   - closure-oriented priority quality, where `isbm` currently looks healthier

## Recommended Next Question

The best follow-up is now narrower:

1. Compare why `ismb` gets much stronger MP pruning than `isbm`.
2. Keep `isbm` as the main comparison hierarchy when inspecting frontier
   ranking and left-wedge effects.
3. Keep `ismb` as the main hierarchy when pushing for a full bounded solve.
