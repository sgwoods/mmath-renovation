# Hanoi-4 Frontier Replay

## Source Frontier

- Open nodes: `706`
- Best unsatisfied-pair count: `2`
- Priority bucket leader count: `338`
- Replay heuristic: `user-defined` (zero)
- Replay left-wedge: `nil`
- Replay control strategy: `bfs`

## Replay Outcomes

| Cohort | Rank | Source priority | Source kval | Source cost | Source unsat | Replay outcome | Replay expanded | Replay solution length |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PRIORITY | 1 | 5 | 0 | 13 | 8 | EXPAND-LIMIT-EXCEEDED | 1001 | NIL |
| PRIORITY | 2 | 5 | 0 | 13 | 21 | OPEN-EXHAUSTED | 3 | NIL |
| CLOSURE | 1 | 5 | 2 | 5 | 2 | EXPAND-LIMIT-EXCEEDED | 1001 | NIL |
| CLOSURE | 2 | 5 | 1 | 10 | 3 | OPEN-EXHAUSTED | 271 | NIL |

## Cohort Summary

- Priority cohort solved count: `0`
- Closure cohort solved count: `0`
- Priority cohort best replay solution length: `NIL`
- Closure cohort best replay solution length: `NIL`
