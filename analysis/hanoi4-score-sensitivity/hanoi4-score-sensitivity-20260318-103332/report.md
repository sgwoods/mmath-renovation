# Hanoi-4 Score Sensitivity

Source configuration: 

## Source Search

- Expanded: 
- Generated: 
- Open nodes: 
- Best unsatisfied-pair count: 

## Representative Nodes

### Actual Top-Ranked Node

- Plan id: 
- Actual priority: 
- Search cost: 
- Base goal heuristic: 
- Left-wedge adjustment: 
- Plan kval: 
- Plan cost: 
- Plan length: 
- Unsatisfied-pair count: 
- Rank under actual score: 
- Rank without left-wedge: 
- Rank under unsat-aware score: 

### Best Closure-Oriented Node

- Plan id: 
- Actual priority: 
- Search cost: 
- Base goal heuristic: 
- Left-wedge adjustment: 
- Plan kval: 
- Plan cost: 
- Plan length: 
- Unsatisfied-pair count: 
- Rank under actual score: 
- Rank without left-wedge: 
- Rank under unsat-aware score: 

## Top-20 Frontier Averages

| Ranking | Avg kval | Avg cost | Avg length | Avg unsat |
| --- | --- | --- | --- | --- |
| Actual |  |  |  |  |
| No left-wedge |  |  |  |  |
| Unsat-aware |  |  |  |  |

## Top-20 Overlap With Actual Ranking

- Actual vs no-left-wedge overlap: 
- Actual vs unsat-aware overlap: 

## Interpretation

- If the best closure-oriented node rises sharply when left-wedge is removed, the ranking pressure is dominated by refinement bias.
- If it rises sharply again under an unsat-aware score, then the current score is also blind to unresolved obligations that matter for closure.
- Large top-20 average differences indicate that the score shape is selecting a qualitatively different frontier, not just reordering similar plans.
