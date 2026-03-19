# Hanoi-4 Optimal Projection Report

This report projects the retained optimal reference `hanoi-4` A* path
through the active abstraction families used in the restored planner.

It is meant as a comparison aid for the ongoing `hanoi-4` AbTweak
investigation: what should a healthy branch look like when viewed
through `critical-list-1`, `ismb`, and `isbm`?

- reference algorithm: `astar`
- solved: `yes`
- optimal depth: `15`
- expanded: `54`
- generated: `158`

## Optimal Move Sequence

| Step | Move | Full state |
| --- | --- | --- |
| 0 | start | S1 M1 B1 H1 |
| 1 | `S:1->2` | `S2 M1 B1 H1` |
| 2 | `M:1->3` | `S2 M3 B1 H1` |
| 3 | `S:2->3` | `S3 M3 B1 H1` |
| 4 | `B:1->2` | `S3 M3 B2 H1` |
| 5 | `S:3->1` | `S1 M3 B2 H1` |
| 6 | `M:3->2` | `S1 M2 B2 H1` |
| 7 | `S:1->2` | `S2 M2 B2 H1` |
| 8 | `H:1->3` | `S2 M2 B2 H3` |
| 9 | `S:2->3` | `S3 M2 B2 H3` |
| 10 | `M:2->1` | `S3 M1 B2 H3` |
| 11 | `S:3->1` | `S1 M1 B2 H3` |
| 12 | `B:2->3` | `S1 M1 B3 H3` |
| 13 | `S:1->2` | `S2 M1 B3 H3` |
| 14 | `M:1->3` | `S2 M3 B3 H3` |
| 15 | `S:2->3` | `S3 M3 B3 H3` |

## critical-list-1

| Kval | Visible goal slice | First optimal-path step reaching that slice | Distinct projected states on optimal path |
| --- | --- | --- | --- |
| 4 | `-` | 0 | 1 |
| 3 | `H3` | 8 | 2 |
| 2 | `H3 B3` | 12 | 4 |
| 1 | `H3 B3 M3` | 14 | 8 |
| 0 | `H3 B3 M3 S3` | 15 | 16 |

| Step | Projection |
| --- | --- |
| 0 | `k4: - ; k3: H1 ; k2: H1 B1 ; k1: H1 B1 M1 ; k0: H1 B1 M1 S1` |
| 1 | `k4: - ; k3: H1 ; k2: H1 B1 ; k1: H1 B1 M1 ; k0: H1 B1 M1 S2` |
| 2 | `k4: - ; k3: H1 ; k2: H1 B1 ; k1: H1 B1 M3 ; k0: H1 B1 M3 S2` |
| 3 | `k4: - ; k3: H1 ; k2: H1 B1 ; k1: H1 B1 M3 ; k0: H1 B1 M3 S3` |
| 4 | `k4: - ; k3: H1 ; k2: H1 B2 ; k1: H1 B2 M3 ; k0: H1 B2 M3 S3` |
| 5 | `k4: - ; k3: H1 ; k2: H1 B2 ; k1: H1 B2 M3 ; k0: H1 B2 M3 S1` |
| 6 | `k4: - ; k3: H1 ; k2: H1 B2 ; k1: H1 B2 M2 ; k0: H1 B2 M2 S1` |
| 7 | `k4: - ; k3: H1 ; k2: H1 B2 ; k1: H1 B2 M2 ; k0: H1 B2 M2 S2` |
| 8 | `k4: - ; k3: H3 ; k2: H3 B2 ; k1: H3 B2 M2 ; k0: H3 B2 M2 S2` |
| 9 | `k4: - ; k3: H3 ; k2: H3 B2 ; k1: H3 B2 M2 ; k0: H3 B2 M2 S3` |
| 10 | `k4: - ; k3: H3 ; k2: H3 B2 ; k1: H3 B2 M1 ; k0: H3 B2 M1 S3` |
| 11 | `k4: - ; k3: H3 ; k2: H3 B2 ; k1: H3 B2 M1 ; k0: H3 B2 M1 S1` |
| 12 | `k4: - ; k3: H3 ; k2: H3 B3 ; k1: H3 B3 M1 ; k0: H3 B3 M1 S1` |
| 13 | `k4: - ; k3: H3 ; k2: H3 B3 ; k1: H3 B3 M1 ; k0: H3 B3 M1 S2` |
| 14 | `k4: - ; k3: H3 ; k2: H3 B3 ; k1: H3 B3 M3 ; k0: H3 B3 M3 S2` |
| 15 | `k4: - ; k3: H3 ; k2: H3 B3 ; k1: H3 B3 M3 ; k0: H3 B3 M3 S3` |

## ismb

| Kval | Visible goal slice | First optimal-path step reaching that slice | Distinct projected states on optimal path |
| --- | --- | --- | --- |
| 3 | `-` | 0 | 1 |
| 2 | `S3` | 3 | 3 |
| 1 | `M3 S3` | 3 | 9 |
| 0 | `H3 B3 M3 S3` | 15 | 16 |

| Step | Projection |
| --- | --- |
| 0 | `k3: - ; k2: S1 ; k1: M1 S1 ; k0: H1 B1 M1 S1` |
| 1 | `k3: - ; k2: S2 ; k1: M1 S2 ; k0: H1 B1 M1 S2` |
| 2 | `k3: - ; k2: S2 ; k1: M3 S2 ; k0: H1 B1 M3 S2` |
| 3 | `k3: - ; k2: S3 ; k1: M3 S3 ; k0: H1 B1 M3 S3` |
| 4 | `k3: - ; k2: S3 ; k1: M3 S3 ; k0: H1 B2 M3 S3` |
| 5 | `k3: - ; k2: S1 ; k1: M3 S1 ; k0: H1 B2 M3 S1` |
| 6 | `k3: - ; k2: S1 ; k1: M2 S1 ; k0: H1 B2 M2 S1` |
| 7 | `k3: - ; k2: S2 ; k1: M2 S2 ; k0: H1 B2 M2 S2` |
| 8 | `k3: - ; k2: S2 ; k1: M2 S2 ; k0: H3 B2 M2 S2` |
| 9 | `k3: - ; k2: S3 ; k1: M2 S3 ; k0: H3 B2 M2 S3` |
| 10 | `k3: - ; k2: S3 ; k1: M1 S3 ; k0: H3 B2 M1 S3` |
| 11 | `k3: - ; k2: S1 ; k1: M1 S1 ; k0: H3 B2 M1 S1` |
| 12 | `k3: - ; k2: S1 ; k1: M1 S1 ; k0: H3 B3 M1 S1` |
| 13 | `k3: - ; k2: S2 ; k1: M1 S2 ; k0: H3 B3 M1 S2` |
| 14 | `k3: - ; k2: S2 ; k1: M3 S2 ; k0: H3 B3 M3 S2` |
| 15 | `k3: - ; k2: S3 ; k1: M3 S3 ; k0: H3 B3 M3 S3` |

## isbm

| Kval | Visible goal slice | First optimal-path step reaching that slice | Distinct projected states on optimal path |
| --- | --- | --- | --- |
| 3 | `-` | 0 | 1 |
| 2 | `S3` | 3 | 3 |
| 1 | `B3 S3` | 15 | 9 |
| 0 | `H3 B3 M3 S3` | 15 | 16 |

| Step | Projection |
| --- | --- |
| 0 | `k3: - ; k2: S1 ; k1: B1 S1 ; k0: H1 B1 M1 S1` |
| 1 | `k3: - ; k2: S2 ; k1: B1 S2 ; k0: H1 B1 M1 S2` |
| 2 | `k3: - ; k2: S2 ; k1: B1 S2 ; k0: H1 B1 M3 S2` |
| 3 | `k3: - ; k2: S3 ; k1: B1 S3 ; k0: H1 B1 M3 S3` |
| 4 | `k3: - ; k2: S3 ; k1: B2 S3 ; k0: H1 B2 M3 S3` |
| 5 | `k3: - ; k2: S1 ; k1: B2 S1 ; k0: H1 B2 M3 S1` |
| 6 | `k3: - ; k2: S1 ; k1: B2 S1 ; k0: H1 B2 M2 S1` |
| 7 | `k3: - ; k2: S2 ; k1: B2 S2 ; k0: H1 B2 M2 S2` |
| 8 | `k3: - ; k2: S2 ; k1: B2 S2 ; k0: H3 B2 M2 S2` |
| 9 | `k3: - ; k2: S3 ; k1: B2 S3 ; k0: H3 B2 M2 S3` |
| 10 | `k3: - ; k2: S3 ; k1: B2 S3 ; k0: H3 B2 M1 S3` |
| 11 | `k3: - ; k2: S1 ; k1: B2 S1 ; k0: H3 B2 M1 S1` |
| 12 | `k3: - ; k2: S1 ; k1: B3 S1 ; k0: H3 B3 M1 S1` |
| 13 | `k3: - ; k2: S2 ; k1: B3 S2 ; k0: H3 B3 M1 S2` |
| 14 | `k3: - ; k2: S2 ; k1: B3 S2 ; k0: H3 B3 M3 S2` |
| 15 | `k3: - ; k2: S3 ; k1: B3 S3 ; k0: H3 B3 M3 S3` |

## Notes

- `critical-list-1` is a large-disk-first hierarchy: the optimal path
  does not first satisfy the top visible goal slice until the `H` move
  in the middle of the plan.
- `ismb` and `isbm` delay `H` to the concrete layer, so their earlier
  abstraction levels can match smaller-disk slices much sooner.
- This report does not prove which hierarchy AbTweak should prefer,
  but it gives a concrete standard-transfer sequence to compare against
  the traced `hanoi-4` lineages in the planner.
