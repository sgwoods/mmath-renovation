# Hanoi-4 Lineage Trace

- Recorded insertions: `5000`
- Open nodes at termination: `1683`
- Duplicate inserted plan ids: `8`

## Top Priority Frontier Lineages

## Frontier priority node `|plan52005|`

- Priority: `5`
- Kval: `0`
- Cost: `14`
- Length: `16`
- Unsatisfied pairs: `14`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan52000|`

- Priority: `5`
- Kval: `0`
- Cost: `14`
- Length: `16`
- Unsatisfied pairs: `22`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan51980|`

- Priority: `5`
- Kval: `0`
- Cost: `14`
- Length: `16`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Top Closure-Oriented Frontier Lineages

## Frontier closure node `|plan33626|`

- Priority: `6`
- Kval: `2`
- Cost: `6`
- Length: `8`
- Unsatisfied pairs: `2`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan10615|`

- Priority: `5`
- Kval: `1`
- Cost: `10`
- Length: `12`
- Unsatisfied pairs: `3`

### Insertion lineage

| Step | Plan id | Parent id | Insertion | Actual | No LW | Unsat-aware | Kval | Cost | Length | Unsat |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | |plan10615| | |plan10610| | 1972 | 5 | 12 | 15 | 1 | 10 | 12 | 3 |
| 2 | |plan10610| | |plan5884| | 1971 | 4 | 11 | 12 | 1 | 9 | 11 | 1 |
| 3 | |plan5884| | |plan5879| | 1114 | 4 | 11 | 14 | 1 | 9 | 11 | 3 |
| 4 | |plan5879| | |plan4696| | 1113 | 3 | 10 | 11 | 1 | 8 | 10 | 1 |
| 5 | |plan4696| | |plan4691| | 903 | 3 | 10 | 13 | 1 | 8 | 10 | 3 |
| 6 | |plan4691| | |plan2156| | 902 | 2 | 9 | 10 | 1 | 7 | 9 | 1 |
| 7 | |plan2156| | |plan2151| | 435 | 2 | 9 | 12 | 1 | 7 | 9 | 3 |
| 8 | |plan2151| | |plan2070| | 434 | 1 | 8 | 9 | 1 | 6 | 8 | 1 |
| 9 | |plan2070| | |plan2065| | 420 | 1 | 8 | 11 | 1 | 6 | 8 | 3 |
| 10 | |plan2065| | |plan862| | 419 | 0 | 7 | 8 | 1 | 5 | 7 | 1 |
| 11 | |plan862| | |plan855| | 171 | 0 | 7 | 10 | 1 | 5 | 7 | 3 |
| 12 | |plan855| | |plan847| | 170 | -1 | 6 | 7 | 1 | 4 | 6 | 1 |
| 13 | |plan847| | |plan839| | 167 | -1 | 6 | 8 | 1 | 4 | 6 | 2 |
| 14 | |plan839| | |plan835| | 165 | -1 | 6 | 9 | 1 | 4 | 6 | 3 |
| 15 | |plan835| | |plan824| | 163 | -1 | 6 | 10 | 1 | 4 | 6 | 4 |
| 16 | |plan824| | |plan148| | 159 | 3 | 6 | 6 | 2 | 3 | 5 | 0 |
| 17 | |plan148| | |plan143| | 33 | 3 | 6 | 8 | 2 | 3 | 5 | 2 |
| 18 | |plan143| | |plan14| | 32 | 2 | 5 | 6 | 2 | 2 | 4 | 1 |
| 19 | |plan14| | |plan9| | 5 | 2 | 5 | 7 | 2 | 2 | 4 | 2 |
| 20 | |plan9| | |plan5| | 4 | 1 | 4 | 5 | 2 | 1 | 3 | 1 |
| 21 | |plan5| | INITIAL-PLAN | 2 | 1 | 4 | 6 | 2 | 1 | 3 | 2 |
| 22 | INITIAL-PLAN | INITIAL-PLAN | 1 | 1 | 4 | 5 | 2 | 0 | 2 | 1 |

## Frontier closure node `|plan8037|`

- Priority: `5`
- Kval: `1`
- Cost: `10`
- Length: `12`
- Unsatisfied pairs: `3`

### Insertion lineage

| Step | Plan id | Parent id | Insertion | Actual | No LW | Unsat-aware | Kval | Cost | Length | Unsat |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | |plan8037| | |plan8032| | 1503 | 5 | 12 | 15 | 1 | 10 | 12 | 3 |
| 2 | |plan8032| | |plan8023| | 1502 | 4 | 11 | 12 | 1 | 9 | 11 | 1 |
| 3 | |plan8023| | |plan8018| | 1500 | 4 | 11 | 14 | 1 | 9 | 11 | 3 |
| 4 | |plan8018| | |plan134| | 1499 | 3 | 10 | 11 | 1 | 8 | 10 | 1 |
| 5 | |plan134| | |plan129| | 30 | 3 | 10 | 13 | 1 | 8 | 10 | 3 |
| 6 | |plan129| | |plan120| | 29 | 2 | 9 | 10 | 1 | 7 | 9 | 1 |
| 7 | |plan120| | |plan115| | 27 | 2 | 9 | 12 | 1 | 7 | 9 | 3 |
| 8 | |plan115| | |plan106| | 26 | 1 | 8 | 9 | 1 | 6 | 8 | 1 |
| 9 | |plan106| | |plan101| | 24 | 1 | 8 | 11 | 1 | 6 | 8 | 3 |
| 10 | |plan101| | |plan92| | 23 | 0 | 7 | 8 | 1 | 5 | 7 | 1 |
| 11 | |plan92| | |plan87| | 21 | 0 | 7 | 10 | 1 | 5 | 7 | 3 |
| 12 | |plan87| | |plan78| | 20 | -1 | 6 | 7 | 1 | 4 | 6 | 1 |
| 13 | |plan78| | |plan73| | 18 | -1 | 6 | 9 | 1 | 4 | 6 | 3 |
| 14 | |plan73| | |plan36| | 17 | -2 | 5 | 6 | 1 | 3 | 5 | 1 |
| 15 | |plan36| | |plan29| | 11 | -2 | 5 | 8 | 1 | 3 | 5 | 3 |
| 16 | |plan29| | |plan23| | 10 | -3 | 4 | 5 | 1 | 2 | 4 | 1 |
| 17 | |plan23| | |plan19| | 9 | -3 | 4 | 6 | 1 | 2 | 4 | 2 |
| 18 | |plan19| | |plan8| | 7 | -3 | 4 | 8 | 1 | 2 | 4 | 4 |
| 19 | |plan8| | |plan5| | 3 | 1 | 4 | 4 | 2 | 1 | 3 | 0 |
| 20 | |plan5| | INITIAL-PLAN | 2 | 1 | 4 | 6 | 2 | 1 | 3 | 2 |
| 21 | INITIAL-PLAN | INITIAL-PLAN | 1 | 1 | 4 | 5 | 2 | 0 | 2 | 1 |

## Interpretation

- If the priority leaders all descend through repeated low-`kval` insertions with worsening unsatisfied counts, the compounding-refinement hypothesis gets stronger.
- If the closure leaders retain short, abstract lineages, then the historical baseline is still generating healthier alternatives that are simply not surviving as long in OPEN.
