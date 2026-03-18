# Hanoi-4 Frontier Replay

## Source Frontier

- Open nodes: `6840`
- Best unsatisfied-pair count: `5`
- Priority bucket leader count: `1258`
- Replay heuristic: `user-defined` (zero)
- Replay left-wedge: `nil`
- Replay control strategy: `bfs`

## Replay Outcomes

| Cohort | Rank | Source priority | Source kval | Source cost | Source unsat | Replay outcome | Replay expanded | Replay solution length |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PRIORITY | 1 | 10 | 0 | 9 | 6 | EXPAND-LIMIT-EXCEEDED | 3001 | NIL |
| PRIORITY | 2 | 10 | 0 | 9 | 6 | EXPAND-LIMIT-EXCEEDED | 3001 | NIL |
| PRIORITY | 3 | 10 | 0 | 9 | 6 | EXPAND-LIMIT-EXCEEDED | 3001 | NIL |
| CLOSURE | 1 | 10 | 0 | 9 | 5 | EXPAND-LIMIT-EXCEEDED | 3001 | NIL |
| CLOSURE | 2 | 10 | 0 | 9 | 5 | EXPAND-LIMIT-EXCEEDED | 3001 | NIL |
| CLOSURE | 3 | 10 | 0 | 9 | 5 | EXPAND-LIMIT-EXCEEDED | 3001 | NIL |

## Cohort Summary

- Priority cohort solved count: `0`
- Closure cohort solved count: `0`
- Priority cohort best replay solution length: `NIL`
- Closure cohort best replay solution length: `NIL`
