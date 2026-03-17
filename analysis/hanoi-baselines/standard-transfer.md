# Hanoi Search Baselines

This report records simple retained classical-search baselines for the
standard 3-peg Tower of Hanoi transfer problem.

| Case | Algorithm | Solved | Depth | Expanded | Generated | Frontier peak | Visited |
| --- | --- | --- | --- | --- | --- | --- | --- |
| hanoi-3-standard-transfer | bfs | yes | 7 | 25 | 70 | 8 | 27 |
| hanoi-3-standard-transfer | dfs | yes | 9 | 23 | 64 | 10 | 27 |
| hanoi-3-standard-transfer | astar | yes | 7 | 18 | 50 | 6 | 23 |
| hanoi-4-standard-transfer | bfs | yes | 15 | 71 | 209 | 16 | 81 |
| hanoi-4-standard-transfer | dfs | yes | 27 | 68 | 199 | 28 | 81 |
| hanoi-4-standard-transfer | astar | yes | 15 | 54 | 158 | 8 | 61 |

## hanoi-3-standard-transfer / bfs

- solved: yes
- depth: 7
- expanded: 25
- generated: 70
- frontier peak: 8
- visited: 27
- moves: d1:1->3, d2:1->2, d1:3->2, d3:1->3, d1:2->1, d2:2->3, d1:1->3

## hanoi-3-standard-transfer / dfs

- solved: yes
- depth: 9
- expanded: 23
- generated: 64
- frontier peak: 10
- visited: 27
- moves: d1:1->2, d2:1->3, d1:2->1, d2:3->2, d1:1->2, d3:1->3, d1:2->1, d2:2->3, d1:1->3

## hanoi-3-standard-transfer / astar

- solved: yes
- depth: 7
- expanded: 18
- generated: 50
- frontier peak: 6
- visited: 23
- moves: d1:1->3, d2:1->2, d1:3->2, d3:1->3, d1:2->1, d2:2->3, d1:1->3

## hanoi-4-standard-transfer / bfs

- solved: yes
- depth: 15
- expanded: 71
- generated: 209
- frontier peak: 16
- visited: 81
- moves: d1:1->2, d2:1->3, d1:2->3, d3:1->2, d1:3->1, d2:3->2, d1:1->2, d4:1->3, d1:2->3, d2:2->1, d1:3->1, d3:2->3, d1:1->2, d2:1->3, d1:2->3

## hanoi-4-standard-transfer / dfs

- solved: yes
- depth: 27
- expanded: 68
- generated: 199
- frontier peak: 28
- visited: 81
- moves: d1:1->2, d2:1->3, d1:2->1, d2:3->2, d1:1->2, d3:1->3, d1:2->1, d2:2->3, d1:1->2, d2:3->1, d1:2->1, d3:3->2, d1:1->2, d2:1->3, d1:2->1, d2:3->2, d1:1->2, d4:1->3, d1:2->1, d2:2->3, d1:1->2, d2:3->1, d1:2->1, d3:2->3, d1:1->2, d2:1->3, d1:2->3

## hanoi-4-standard-transfer / astar

- solved: yes
- depth: 15
- expanded: 54
- generated: 158
- frontier peak: 8
- visited: 61
- moves: d1:1->2, d2:1->3, d1:2->3, d3:1->2, d1:3->1, d2:3->2, d1:1->2, d4:1->3, d1:2->3, d2:2->1, d1:3->1, d3:2->3, d1:1->2, d2:1->3, d1:2->3
