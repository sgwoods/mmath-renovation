# Hanoi-4 Insertion Score Trace

- Recorded inserted nodes: `5000`

## Actual Top Inserted Node

- Plan id: `|plan199|`
- Insertion index: `51`
- Actual score: `-2`
- No-left-wedge score: `5`
- Unsat-aware score: `7`
- Kval: `0`
- Cost: `3`
- Length: `5`
- Unsatisfied pairs: `2`
- Base heuristic: `2`
- Left-wedge adjustment: `-7`
- Rank without left-wedge: `29`
- Rank under unsat-aware score: `8`

## Best Closure-Oriented Inserted Node

- Plan id: `|plan8|`
- Insertion index: `3`
- Actual score: `3`
- No-left-wedge score: `4`
- Unsat-aware score: `4`
- Kval: `2`
- Cost: `1`
- Length: `3`
- Unsatisfied pairs: `0`
- Base heuristic: `3`
- Left-wedge adjustment: `-1`
- Rank under actual score: `151`
- Rank without left-wedge: `3`
- Rank under unsat-aware score: `1`

## Interpretation

- This report captures the score shape at insertion time, before OPEN ordering and later pruning distort the picture further.
- Large rank shifts here indicate the ranking bias is already present when nodes are created, not only after they accumulate in the frontier.
