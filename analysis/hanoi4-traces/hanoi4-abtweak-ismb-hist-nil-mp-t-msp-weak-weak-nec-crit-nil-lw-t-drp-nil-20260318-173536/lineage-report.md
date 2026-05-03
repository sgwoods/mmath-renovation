# Hanoi-4 Lineage Trace

- Recorded insertions: `5000`
- Open nodes at termination: `10335`
- Duplicate inserted plan ids: `8`

## Top Priority Frontier Lineages

## Frontier priority node `|plan293159|`

- Priority: `10`
- Kval: `0`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `11`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan293152|`

- Priority: `10`
- Kval: `0`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan293140|`

- Priority: `10`
- Kval: `0`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Top Closure-Oriented Frontier Lineages

## Frontier closure node `|plan219645|`

- Priority: `10`
- Kval: `2`
- Cost: `8`
- Length: `10`
- Unsatisfied pairs: `2`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan273488|`

- Priority: `10`
- Kval: `1`
- Cost: `11`
- Length: `13`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan245260|`

- Priority: `10`
- Kval: `1`
- Cost: `11`
- Length: `13`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Interpretation

- If the priority leaders all descend through repeated low-`kval` insertions with worsening unsatisfied counts, the compounding-refinement hypothesis gets stronger.
- If the closure leaders retain short, abstract lineages, then the historical baseline is still generating healthier alternatives that are simply not surviving as long in OPEN.
