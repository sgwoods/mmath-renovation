# Hanoi-4 Frontier Replay

## Source Frontier

- Open nodes: `1683`
- Best unsatisfied-pair count: `2`
- Priority bucket leader count: `700`
- Replay heuristic: `user-defined` (zero)
- Replay left-wedge: `nil`
- Replay control strategy: `bfs`

## Replay Outcomes

| Cohort | Rank | Source priority | Source kval | Source cost | Source unsat | Replay outcome | Replay expanded | Replay generated | Replay solution length |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| PRIORITY | 1 | 5 | 0 | 14 | 14 | EXPAND-LIMIT-EXCEEDED | 1001 | 1075 | NIL |
| PRIORITY | 2 | 5 | 0 | 14 | 22 | OPEN-EXHAUSTED | 3 | 2 | NIL |
| PRIORITY | 3 | 5 | 0 | 14 | 12 | OPEN-EXHAUSTED | 259 | 258 | NIL |
| PRIORITY | 4 | 5 | 0 | 14 | 19 | OPEN-EXHAUSTED | 259 | 258 | NIL |
| PRIORITY | 5 | 5 | 0 | 14 | 21 | OPEN-EXHAUSTED | 259 | 258 | NIL |
| CLOSURE | 1 | 6 | 2 | 6 | 2 | EXPAND-LIMIT-EXCEEDED | 1001 | 1386 | NIL |
| CLOSURE | 2 | 5 | 1 | 10 | 3 | OPEN-EXHAUSTED | 271 | 270 | NIL |
| CLOSURE | 3 | 5 | 1 | 10 | 3 | OPEN-EXHAUSTED | 271 | 270 | NIL |
| CLOSURE | 4 | 6 | 1 | 11 | 3 | OPEN-EXHAUSTED | 268 | 267 | NIL |
| CLOSURE | 5 | 6 | 1 | 11 | 3 | OPEN-EXHAUSTED | 268 | 267 | NIL |

## Cohort Summary

- Priority cohort solved count: `0`
- Closure cohort solved count: `0`
- Priority cohort best replay solution length: `NIL`
- Closure cohort best replay solution length: `NIL`
