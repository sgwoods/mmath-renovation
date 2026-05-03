# Hanoi-4 Lineage Trace

- Recorded insertions: `5000`
- Open nodes at termination: `16645`
- Duplicate inserted plan ids: `8`

## Top Priority Frontier Lineages

## Frontier priority node `|plan387200|`

- Priority: `8`
- Kval: `0`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `20`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan387199|`

- Priority: `8`
- Kval: `0`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `18`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan387185|`

- Priority: `8`
- Kval: `0`
- Cost: `16`
- Length: `18`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Top Closure-Oriented Frontier Lineages

## Frontier closure node `|plan278891|`

- Priority: `8`
- Kval: `2`
- Cost: `8`
- Length: `10`
- Unsatisfied pairs: `2`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan371351|`

- Priority: `8`
- Kval: `1`
- Cost: `13`
- Length: `15`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan269605|`

- Priority: `8`
- Kval: `1`
- Cost: `13`
- Length: `15`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Interpretation

- If the priority leaders all descend through repeated low-`kval` insertions with worsening unsatisfied counts, the compounding-refinement hypothesis gets stronger.
- If the closure leaders retain short, abstract lineages, then the historical baseline is still generating healthier alternatives that are simply not surviving as long in OPEN.
