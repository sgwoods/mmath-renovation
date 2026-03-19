# Hanoi-4 Optimal Versus Traced Lineages

This note compares the strongest current `hanoi-4` traced lineages against the
retained optimal state-space reference projection.

It is meant to answer a narrower question than the broader `hanoi-4`
diagnosis:

- when the restored planner follows a dirty priority branch or a healthy
  closure-oriented branch under the current best historical-control path,
  how does that compare with the abstraction milestones on an optimal
  four-disk transfer?

It complements:

- [Hanoi-4 optimal projection report](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/hanoi4-optimal-projection.md)
- [Hanoi-4 lineage trace](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-trace.md)
- [Hanoi-4 lineage divergence](/Users/stevenwoods/mmath-renovation/docs/hanoi4-lineage-divergence.md)
- [Hanoi-4 diagnosis](/Users/stevenwoods/mmath-renovation/docs/hanoi4-diagnosis.md)

## Compared Configuration

The traced planner branch is the current best historical-control path:

- planner mode: `abtweak`
- hierarchy: `isbm`
- `msp-mode`: `weak`
- `msp-weak-mode`: `pos`
- `left-wedge-mode`: `t`

The comparison trace is:

- [20260318-173205 lineage report](/Users/stevenwoods/mmath-renovation/analysis/hanoi4-traces/hanoi4-abtweak-isbm-hist-t-mp-t-msp-weak-weak-pos-crit-nil-lw-t-drp-nil-20260318-173205/lineage-report.md)

The external reference is:

- [Hanoi-4 optimal projection report](/Users/stevenwoods/mmath-renovation/analysis/hanoi-baselines/hanoi4-optimal-projection.md)

## Reference Milestones On The Optimal Path

For the `isbm` hierarchy, the optimal four-disk transfer reaches these visible
goal slices:

| Kval | Visible slice | First reached on optimal path |
| --- | --- | --- |
| `2` | `S3` | step `3` |
| `1` | `B3 S3` | step `15` |
| `0` | `H3 B3 M3 S3` | step `15` |

That is the important shape:

- the `k2` slice becomes true early
- the `k1` slice stays hard until the very end
- the concrete full goal is also only achieved at the end

So on the optimal path, `isbm` does not provide much legitimate early
high-level progress beyond the small-disk slice.

## Healthy Closure Branch Versus The Reference

The healthiest traced closure branch is anchored at `plan33626`:

| Plan id | Insertion | Kval | Cost | Length | Unsat |
| --- | --- | --- | --- | --- | --- |
| `plan33621` | `6137` | `2` | `5` | `7` | `1` |
| `plan33626` | `6138` | `2` | `6` | `8` | `2` |

This branch stays at `kval 2`, short, and relatively clean. Relative to the
optimal reference projection, that is plausible:

- a healthy `isbm` branch can make genuine early progress on the `k2` slice
  (`S3`)
- but it should not yet be expected to have cleanly resolved the `k1` slice
  (`B3 S3`)

So this branch's shape is broadly compatible with the reference story: it is
still living in the early abstraction band where real progress is possible.

## Dirty Priority Branch Versus The Reference

The dirty branch starts from the same general region, but then concretizes
aggressively:

| Plan id | Insertion | Actual | Kval | Cost | Length | Unsat |
| --- | --- | --- | --- | --- | --- | --- |
| `plan33621` | `6137` | `5` | `2` | `5` | `7` | `1` |
| `plan33620` | `6139` | `1` | `1` | `5` | `7` | `1` |
| `plan33690` | `6154` | `1` | `1` | `6` | `8` | `0` |
| `plan33690` | `6157` | `-1` | `0` | `6` | `8` | `3` |

The key contrast with the optimal projection is:

1. the branch drops from `k2` to `k1` almost immediately
2. it then reaches a locally clean `k1` state extremely early
3. the same plan id is reintroduced at `k0`, where closure gets worse but
   score improves again

Relative to the reference projection, that looks suspiciously eager:

- on the optimal `isbm` path, the visible `k1` goal slice is not first reached
  until the final move
- in the traced priority branch, the search is already rewarding `k1` and then
  `k0` concretization while the plan is still very short and far from full
  closure

This does not prove a semantic bug by itself. But it does show that the
current best `isbm` AbTweak path is receiving strong scoring encouragement for
low-level commitment much earlier than the optimal projection would make
intuitively natural.

## What This Strengthens

This comparison strengthens a narrower version of the current diagnosis:

- the main `isbm` problem is not that the hierarchy itself is obviously wrong
- in fact, the reference projection makes `isbm` look structurally sensible
- the live problem is that the search is rewarded for dropping below the
  natural "early-progress" abstraction band too soon
- once it does that, Left-Wedge continues rewarding the same line even as
  unresolved obligations begin to grow again

So the current `hanoi-4` gap still looks more like a control-quality problem
inside the historical baseline than like a malformed hierarchy definition.

## Best Next Question

The next best `hanoi-4` question is now even more specific:

- when `add-a-level` reintroduces the same `isbm` branch at `k1` and then `k0`
- what exact goal or obligation picture makes that branch look good enough to
  beat the healthier `k2` alternatives?

That is a better next question than another generic bound increase, because we
now have a concrete external picture of what a healthy `isbm` abstraction
progression should roughly look like.
