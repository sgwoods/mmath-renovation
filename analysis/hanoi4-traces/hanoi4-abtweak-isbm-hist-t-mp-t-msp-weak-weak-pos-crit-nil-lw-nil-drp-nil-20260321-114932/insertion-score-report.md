# Hanoi-4 Insertion Score Trace

- Recorded inserted nodes: `5000`

## Actual Top Inserted Node

- Plan id: `INITIAL-PLAN`
- Insertion index: `1`
- Actual score: `4`
- No-left-wedge score: `4`
- Unsat-aware score: `5`
- Kval: `2`
- Cost: `0`
- Length: `2`
- Unsatisfied pairs: `1`
- Base heuristic: `4`
- Left-wedge adjustment: `0`
- Rank without left-wedge: `1`
- Rank under unsat-aware score: `2`

## Best Closure-Oriented Inserted Node

- Plan id: `|plan8|`
- Insertion index: `3`
- Actual score: `4`
- No-left-wedge score: `4`
- Unsat-aware score: `4`
- Kval: `2`
- Cost: `1`
- Length: `3`
- Unsatisfied pairs: `0`
- Base heuristic: `3`
- Left-wedge adjustment: `0`
- Rank under actual score: `3`
- Rank without left-wedge: `3`
- Rank under unsat-aware score: `1`

## Interpretation

- This report captures the score shape at insertion time, before OPEN ordering and later pruning distort the picture further.
- Large rank shifts here indicate the ranking bias is already present when nodes are created, not only after they accumulate in the frontier.
