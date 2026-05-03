# Hanoi-4 Lineage Trace

- Recorded insertions: `5000`
- Open nodes at termination: `4747`
- Duplicate inserted plan ids: `24`

## Top Priority Frontier Lineages

## Frontier priority node `|plan132851|`

- Priority: `14`
- Kval: `0`
- Cost: `12`
- Length: `14`
- Unsatisfied pairs: `4`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan66387|`

- Priority: `14`
- Kval: `0`
- Cost: `12`
- Length: `14`
- Unsatisfied pairs: `6`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan66382|`

- Priority: `14`
- Kval: `0`
- Cost: `12`
- Length: `14`
- Unsatisfied pairs: `6`

### Insertion lineage

_No insertion lineage recovered._

## Top Closure-Oriented Frontier Lineages

## Frontier closure node `|plan66232|`

- Priority: `14`
- Kval: `2`
- Cost: `11`
- Length: `13`
- Unsatisfied pairs: `2`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan66377|`

- Priority: `14`
- Kval: `1`
- Cost: `12`
- Length: `14`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan66294|`

- Priority: `14`
- Kval: `1`
- Cost: `12`
- Length: `14`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Interpretation

- If the priority leaders all descend through repeated low-`kval` insertions with worsening unsatisfied counts, the compounding-refinement hypothesis gets stronger.
- If the closure leaders retain short, abstract lineages, then the historical baseline is still generating healthier alternatives that are simply not surviving as long in OPEN.
