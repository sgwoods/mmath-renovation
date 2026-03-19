# Hanoi-4 Reinsertion Obligation Picture

This note captures the exact obligation picture at the key `add-a-level`
reinsertion points in the current best `hanoi-4` historical-control run.

It complements:

- [Hanoi-4 optimal versus traced lineages](/Users/stevenwoods/mmath-renovation/docs/hanoi4-optimal-lineage-comparison.md)
- [Hanoi-4 lineage divergence](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-divergence.md)
- [Hanoi-4 insertion score trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-insertion-score-trace.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Compared Run

This is the current best historical-control trace:

- planner mode: `abtweak`
- hierarchy: `isbm`
- `msp-mode`: `weak`
- `msp-weak-mode`: `pos`
- `left-wedge-mode`: `t`

Trace directory:

- [20260318-173205](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260318-173205)

## The Local Fork Revisited

The same branch is inserted repeatedly as it drops abstraction levels:

| Insertion | Plan id | Kval | Actual | No LW | Unsat-aware | Unsat | First unsat |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `6136` | `plan33620` | `2` | `5` | `8` | `8` | `0` | `NIL` |
| `6137` | `plan33621` | `2` | `5` | `8` | `9` | `1` | `(ONS PEG2)` on `op11383` |
| `6139` | `plan33620` | `1` | `1` | `8` | `9` | `1` | `(G (ONB PEG3))` |
| `6154` | `plan33690` | `1` | `1` | `8` | `8` | `0` | `NIL` |
| `6157` | `plan33690` | `0` | `-1` | `8` | `11` | `3` | `(NOT ONM PEG1)` on `op33629` |

These rows come directly from the insertion trace for the run above.

## What Changes Across The Level Drops

### At `kval 2`

The branch is genuinely clean or nearly clean:

- `plan33620` enters with no unsatisfied pairs at all
- `plan33621` differs only slightly, with one remaining obligation:
  `(ONS PEG2)`

This is the same early abstraction band that still looks plausible in the
optimal projection for `isbm`.

### Reintroduced At `kval 1`

The same `plan33620` line is reinserted at `kval 1` with:

- the same no-left-wedge score: `8`
- the same search cost: `5`
- the same plan length: `7`
- only one unsatisfied pair

But the obligation picture has changed from "clean abstract branch" to:

- unresolved top visible user goal: `(G (ONB PEG3))`

So the branch is no longer just a healthy early `k2` line. It is now being
rewarded as a lower-level branch whose main visible problem is the `B3`
goal slice.

### Reintroduced Again At `kval 0`

The same line reappears as `plan33690` at `kval 0`:

- actual score improves again from `1` to `-1`
- no-left-wedge score stays `8`
- unsatisfied pairs worsen from `0` to `3`

And the obligation picture changes again:

- the first unsatisfied pair is now a concrete blocker:
  `(NOT ONM PEG1)` on `op33629`

That is the key pattern:

- the branch is not being rewarded because closure improved
- it is being rewarded because each lower `kval` gets a stronger Left-Wedge
  bonus while exposing a new lower-level obligation picture
- by the time the branch reaches `k0`, the visible unsatisfied condition is no
  longer a high-level goal slice but a concrete enabling condition

## Why This Matters

This is the clearest local explanation so far for the `hanoi-4` failure shape.

Relative to the optimal `isbm` projection:

- early `k2` progress is plausible
- early `k1` and especially `k0` reward is much less plausible

What the trace now shows is that the search is not chasing one obviously
broken operator expansion. It is repeatedly re-valuing the same branch as it
descends:

1. clean abstract branch
2. lower-level goal branch
3. still more strongly favored concrete-enabling branch

That is a control-quality issue around reinsertion and scoring, not an obvious
domain-definition failure.

## Strongest Current Interpretation

The current best historical-baseline interpretation is:

- the `isbm` hierarchy itself is still defensible
- the branch looks healthy enough at `k2`
- the problematic step is that lower-level reinsertion is rewarded too quickly
  relative to the closure burden it exposes
- Left-Wedge is therefore amplifying a branch that has moved below the natural
  early-progress band of the optimal `isbm` solution shape

## Best Next Question

The next best `hanoi-4` question is now very specific:

- when `plan33620` is reinserted at `k1` with `(G (ONB PEG3))`
- and when `plan33690` is reinserted at `k0` with `(NOT ONM PEG1)`
- which exact visible-goal and non-goal accounting rules make those branches
  look better than the healthier remaining `k2` alternatives?
