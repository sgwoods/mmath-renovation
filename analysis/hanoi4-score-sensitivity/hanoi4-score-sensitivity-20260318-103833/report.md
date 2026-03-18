# Hanoi-4 Score Sensitivity

Source configuration: abtweak + isbm + weak-POS + left-wedge

## Source Search

- Expanded: 10001
- Generated: 11684
- Open nodes: 1683
- Best unsatisfied-pair count: 2

## Representative Nodes

### Actual Top-Ranked Node

- Plan id: |plan52005|
- Actual priority: 5
- Search cost: 14
- Base goal heuristic: 0
- Left-wedge adjustment: -9
- Plan kval: 0
- Plan cost: 14
- Plan length: 16
- Unsatisfied-pair count: 14
- Rank under actual score: 1
- Rank without left-wedge: 71
- Rank under unsat-aware score: 724

### Best Closure-Oriented Node

- Plan id: |plan33626|
- Actual priority: 6
- Search cost: 6
- Base goal heuristic: 3
- Left-wedge adjustment: -3
- Plan kval: 2
- Plan cost: 6
- Plan length: 8
- Unsatisfied-pair count: 2
- Rank under actual score: 1149
- Rank without left-wedge: 1
- Rank under unsat-aware score: 1

## Top-20 Frontier Averages

| Ranking | Avg kval | Avg cost | Avg length | Avg unsat |
| --- | --- | --- | --- | --- |
| Actual | 0.00 | 13.65 | 15.65 | 15.75 |
| No left-wedge | 1.05 | 9.90 | 11.90 | 5.05 |
| Unsat-aware | 1.05 | 10.10 | 12.10 | 4.25 |

## Top-20 Overlap With Actual Ranking

- Actual vs no-left-wedge overlap: 0 / 20
- Actual vs unsat-aware overlap: 0 / 20

## Interpretation

- If the best closure-oriented node rises sharply when left-wedge is removed, the ranking pressure is dominated by refinement bias.
- If it rises sharply again under an unsat-aware score, then the current score is also blind to unresolved obligations that matter for closure.
- Large top-20 average differences indicate that the score shape is selecting a qualitatively different frontier, not just reordering similar plans.
