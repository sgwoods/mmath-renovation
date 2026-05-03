# Hanoi-4 Lineage Trace

- Recorded insertions: `5000`
- Open nodes at termination: `4131`
- Duplicate inserted plan ids: `41`

## Top Priority Frontier Lineages

## Frontier priority node `|plan133259|`

- Priority: `18`
- Kval: `1`
- Cost: `17`
- Length: `19`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan133240|`

- Priority: `18`
- Kval: `1`
- Cost: `17`
- Length: `19`
- Unsatisfied pairs: `10`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan133233|`

- Priority: `18`
- Kval: `1`
- Cost: `17`
- Length: `19`
- Unsatisfied pairs: `11`

### Insertion lineage

_No insertion lineage recovered._

## Top Closure-Oriented Frontier Lineages

## Frontier closure node `|plan107690|`

- Priority: `18`
- Kval: `3`
- Cost: `15`
- Length: `17`
- Unsatisfied pairs: `2`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan110354|`

- Priority: `18`
- Kval: `2`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan110215|`

- Priority: `18`
- Kval: `2`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Interpretation

- If the priority leaders all descend through repeated low-`kval` insertions with worsening unsatisfied counts, the compounding-refinement hypothesis gets stronger.
- If the closure leaders retain short, abstract lineages, then the historical baseline is still generating healthier alternatives that are simply not surviving as long in OPEN.
