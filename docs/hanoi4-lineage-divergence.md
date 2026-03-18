# Hanoi-4 Lineage Divergence

This note isolates the first clear divergence point between:

- the dirty `hanoi-4` priority branch
- the healthy `hanoi-4` closure-oriented branch

for the current best historical control path:

- planner mode: `abtweak`
- hierarchy: `isbm`
- `msp-mode`: `weak`
- `msp-weak-mode`: `pos`
- `left-wedge-mode`: `t`

It complements:

- [Hanoi-4 lineage trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md)
- [Hanoi-4 insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Main Observation

The important fork happens much earlier than the final dirty frontier states.

Around insertion `6137` to `6157`, the search has two nearby continuations:

- a healthy abstract continuation that stays at `kval 2`
- a concretizing continuation that drops to `kval 1`, then `kval 0`

The concretizing continuation does not initially look much worse by closure.
What changes immediately is its Left-Wedge advantage.

## Local Fork

| Plan id | Insertion | Actual | No LW | Unsat-aware | Kval | Cost | Length | Unsat | Note |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `plan11385` | `2112` | `5` | `8` | `10` | `2` | `5` | `7` | `2` | shared abstract ancestor region |
| `plan33621` | `6137` | `5` | `8` | `9` | `2` | `5` | `7` | `1` | healthy closure branch stays abstract |
| `plan33620` | `6139` | `1` | `8` | `9` | `1` | `5` | `7` | `1` | same general region, but now concretized |
| `plan33634` | `6141` | `1` | `8` | `10` | `1` | `6` | `8` | `2` | dirty branch continues |
| `plan33680` | `6151` | `1` | `8` | `9` | `1` | `6` | `8` | `1` | still favored by actual score |
| `plan33690` | `6154` | `1` | `8` | `8` | `1` | `6` | `8` | `0` | branch reaches locally clean `kval 1` state |
| `plan33690` | `6157` | `-1` | `8` | `11` | `0` | `6` | `8` | `3` | same plan id reinserted at lower level |

## What Changes At The Fork

The key transition is:

- `plan33621`: `kval 2`, unsat `1`, actual score `5`
- `plan33620`: `kval 1`, unsat `1`, actual score `1`

That is a four-point priority swing with essentially the same closure quality.

The score components explain it:

- `plan33621` has Left-Wedge adjustment `-3`
- `plan33620` has Left-Wedge adjustment `-7`
- both have `no-left-wedge score 8`
- both have `unsat-aware score 9`

So the fork is not caused by a large closure improvement. It is caused by the
Left-Wedge reward attached to the lower abstraction level.

## Why The Branch Becomes Dirty Later

The branch then keeps the same basic pattern:

1. it is rewarded for moving to a lower `kval`
2. it remains competitive even when unresolved obligations stop improving
3. when the branch is reinserted again at `kval 0`, the same effect repeats

The most striking example is `plan33690`:

- at insertion `6154`, it is a locally clean `kval 1` state with unsat `0`
- at insertion `6157`, the same plan id reappears at `kval 0`
- its actual score improves from `1` to `-1`
- its unsatisfied-pair count gets worse from `0` to `3`

So the later dirty frontier states are not just random bad descendants. The
branch is already being rewarded at the exact moments where level-drop
reintroduction increases unresolved obligations.

## Interpretation

This is the clearest step-by-step diagnosis so far:

- the damaging pressure starts at the abstraction-level transition itself
- the search is not merely preferring a different plan
- it is preferring the same line more strongly once that line is reintroduced
  at a lower `kval`
- from there, repeated concretization compounds the problem until the frontier
  is dominated by brittle `kval 0` skeletons

The most important caution is that this still does not prove a historical bug.
It is also consistent with Left-Wedge behaving as designed on a hierarchy or
instance where concretization becomes counterproductive.

## Best Next Question

The next best baseline-preserving experiment is now:

- inspect the exact `add-a-level` / reinsertion path for these repeated plan-id
  level drops
- confirm whether the same-score improvement with worse closure is faithful to
  the original 1993 Left-Wedge strategy on this kind of branch
