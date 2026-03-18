# Hanoi-4 Frontier Replay

## Source Frontier

- Open nodes: `3271`
- Best unsatisfied-pair count: `2`
- Priority bucket leader count: `88`
- Replay heuristic: `user-defined` (zero)
- Replay left-wedge: `nil`
- Replay control strategy: `bfs`

## Replay Outcomes

| Cohort | Rank | Source priority | Source kval | Source cost | Source unsat | Replay outcome | Replay expanded | Replay solution length |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PRIORITY | 1 | 4 | 0 | 12 | 7 | OPEN-EXHAUSTED | 263 | NIL |
| PRIORITY | 2 | 4 | 0 | 12 | 7 | CPU-TIME-LIMIT-EXCEEDED | 2857 | NIL |
| PRIORITY | 3 | 4 | 0 | 12 | 14 | OPEN-EXHAUSTED | 3 | NIL |
| PRIORITY | 4 | 4 | 0 | 12 | 11 | OPEN-EXHAUSTED | 3 | NIL |
| PRIORITY | 5 | 4 | 0 | 12 | 12 | EXPAND-LIMIT-EXCEEDED | 10001 | NIL |
| CLOSURE | 1 | 7 | 2 | 7 | 2 | EXPAND-LIMIT-EXCEEDED | 10001 | NIL |
| CLOSURE | 2 | 5 | 1 | 10 | 3 | OPEN-EXHAUSTED | 271 | NIL |
| CLOSURE | 3 | 5 | 1 | 10 | 3 | OPEN-EXHAUSTED | 271 | NIL |
| CLOSURE | 4 | 6 | 1 | 11 | 3 | OPEN-EXHAUSTED | 268 | NIL |
| CLOSURE | 5 | 6 | 1 | 11 | 3 | OPEN-EXHAUSTED | 268 | NIL |

## Cohort Summary

- Priority cohort solved count: `0`
- Closure cohort solved count: `0`
- Priority cohort best replay solution length: `NIL`
- Closure cohort best replay solution length: `NIL`
