# Hanoi-4 Solve Candidate Comparison

This note keeps the `hanoi-4` candidate set intentionally narrow.

The goal is to judge the strongest live candidates by the only benchmark
criterion that matters for classic three-peg `hanoi-4`:

- solved, or not solved

Generated-node counts remain useful as diagnostics, but they are not benchmark
progress on their own.

It complements:

- [Hanoi-4 formal state](/Users/stevenwoods/mmath-renovation/docs/hanoi4-formal-state.md)
- [Hanoi-4 hierarchy experiment plan](/Users/stevenwoods/mmath-renovation/docs/hanoi4-hierarchy-experiment-plan.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Current Focused Candidate Set

The current focused candidate set is:

1. `isbm + weak-POS + stack + Left-Wedge`
2. `legacy-1991-isbm + weak-POS + stack + Left-Wedge`

These are the two strongest historically plausible live families now that the
broader hierarchy exploration has been narrowed.

## Current Read

At the current exploratory bounds:

- neither candidate solves classic three-peg `hanoi-4`
- `isbm + weak-POS + stack + Left-Wedge` remains the stronger live runtime path
- `legacy-1991-isbm + weak-POS + stack + Left-Wedge` remains the strongest
  grouped-top analogue

| Hierarchy | Expand bound | Outcome | Expanded | Generated | MP Pruned |
| --- | --- | --- | --- | --- | --- |
| `isbm` | `20000` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `23272` | `21286` |
| `legacy-1991-isbm` | `20000` | `EXPAND-LIMIT-EXCEEDED` | `20001` | `26215` | `15791` |
| `isbm` | `50000` | `EXPAND-LIMIT-EXCEEDED` | `50001` | `58817` | `54466` |
| `legacy-1991-isbm` | `50000` | `EXPAND-LIMIT-EXCEEDED` | `50001` | `66327` | `41518` |
| `isbm` | `100000` | `EXPAND-LIMIT-EXCEEDED` | `100001` | `116646` | `110674` |
| `legacy-1991-isbm` | `100000` | `EXPAND-LIMIT-EXCEEDED` | `100001` | `132286` | `83535` |
| `isbm` | `200000` | `EXPAND-LIMIT-EXCEEDED` | `200001` | `234872` | `224678` |
| `legacy-1991-isbm` | `200000` | `EXPAND-LIMIT-EXCEEDED` | `200001` | `265691` | `167921` |

So the practical benchmark read is still binary:

- `isbm`: strongest open candidate
- `legacy-1991-isbm`: still open, still secondary

## Update Rule

Update this note when any of the following changes:

1. either candidate solves
2. the focused candidate set changes
3. a new bound comparison materially changes which path is the stronger live
   candidate
