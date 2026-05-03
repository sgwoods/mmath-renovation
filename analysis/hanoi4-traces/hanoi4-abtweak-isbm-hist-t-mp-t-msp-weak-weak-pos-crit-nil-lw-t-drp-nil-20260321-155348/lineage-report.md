# Hanoi-4 Lineage Trace

- Recorded insertions: `5000`
- Open nodes at termination: `34871`
- Duplicate inserted plan ids: `8`

## Top Priority Frontier Lineages

## Frontier priority node `|plan943543|`

- Priority: `9`
- Kval: `0`
- Cost: `18`
- Length: `20`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan943537|`

- Priority: `9`
- Kval: `0`
- Cost: `18`
- Length: `20`
- Unsatisfied pairs: `12`

### Insertion lineage

_No insertion lineage recovered._

## Frontier priority node `|plan943531|`

- Priority: `9`
- Kval: `0`
- Cost: `18`
- Length: `20`
- Unsatisfied pairs: `18`

### Insertion lineage

_No insertion lineage recovered._

## Top Closure-Oriented Frontier Lineages

## Frontier closure node `|plan694507|`

- Priority: `9`
- Kval: `2`
- Cost: `9`
- Length: `11`
- Unsatisfied pairs: `2`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan838161|`

- Priority: `9`
- Kval: `1`
- Cost: `14`
- Length: `16`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Frontier closure node `|plan838126|`

- Priority: `9`
- Kval: `1`
- Cost: `14`
- Length: `16`
- Unsatisfied pairs: `3`

### Insertion lineage

_No insertion lineage recovered._

## Interpretation

- If the priority leaders all descend through repeated low-`kval` insertions with worsening unsatisfied counts, the compounding-refinement hypothesis gets stronger.
- If the closure leaders retain short, abstract lineages, then the historical baseline is still generating healthier alternatives that are simply not surviving as long in OPEN.
